// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../src/EqualRedPacketFundingPrototype.sol";

interface Vm {
    struct Log {
        bytes32[] topics;
        bytes data;
        address emitter;
    }
    function prank(address sender) external;
    function warp(uint256 timestamp) external;
    function deal(address account, uint256 balance) external;
    function expectRevert(bytes4 selector) external;
    function recordLogs() external;
    function getRecordedLogs() external returns (Log[] memory);
}

contract MockToken {
    enum Mode {
        Standard,
        FalseReturn,
        NoReturn,
        MalformedReturn,
        InvalidBoolean,
        NoMovement,
        RecipientFee,
        SenderFee,
        Overcredit,
        RevertTransfer,
        Reenter,
        SwallowReentry
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    Mode public mode;
    EqualRedPacketFundingPrototype public target;
    bool public nestedSucceeded;
    bytes4 public nestedError;

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
    }

    function burn(address account, uint256 amount) external {
        balanceOf[account] -= amount;
    }

    function configure(Mode next, EqualRedPacketFundingPrototype escrow) external {
        mode = next;
        target = escrow;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "allowance");
        allowance[from][msg.sender] -= amount;
        if (mode == Mode.RevertTransfer) revert("token transfer failure");
        if (mode == Mode.Reenter || mode == Mode.SwallowReentry) {
            (bool ok, bytes memory reason) = address(target)
                .call(
                    abi.encodeCall(
                        target.fund,
                        (keccak256("nested"), 10, 1, uint64(block.timestamp + 1 days), keccak256("eligibility"))
                    )
                );
            nestedSucceeded = ok;
            if (reason.length >= 4) {
                bytes4 errorSelector;
                assembly {
                    errorSelector := mload(add(reason, 32))
                }
                nestedError = errorSelector;
            }
            if (mode == Mode.Reenter) require(ok, "nested funding rejected");
        }
        if (mode != Mode.NoMovement) {
            uint256 debit = mode == Mode.SenderFee ? amount + 1 : amount;
            uint256 credit = mode == Mode.RecipientFee ? amount - 1 : amount;
            if (mode == Mode.Overcredit) credit = amount + 1;
            balanceOf[from] -= debit;
            balanceOf[to] += credit;
        }
        if (mode == Mode.FalseReturn) return false;
        if (mode == Mode.NoReturn) {
            assembly { return(0, 0) }
        }
        if (mode == Mode.MalformedReturn) {
            assembly { return(0, 1) }
        }
        if (mode == Mode.InvalidBoolean) {
            assembly {
                mstore(0, 2)
                return(0, 32)
            }
        }
        return true;
    }
}

contract EqualRedPacketFundingPrototypeTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);
    bytes32 private constant ID = keccak256("packet");
    bytes32 private constant ELIGIBILITY = keccak256("opaque future eligibility commitment");
    MockToken private token;
    EqualRedPacketFundingPrototype private escrow;

    function setUp() public {
        vm.warp(1_800_000_000);
        token = new MockToken();
        escrow = new EqualRedPacketFundingPrototype(address(token));
        token.mint(ALICE, 1000);
        token.mint(BOB, 1000);
        vm.prank(ALICE);
        token.approve(address(escrow), 1000);
        vm.prank(BOB);
        token.approve(address(escrow), 1000);
    }

    function _fund(address sender, bytes32 id, uint256 amount, uint32 count) private {
        vm.prank(sender);
        escrow.fund(id, amount, count, uint64(block.timestamp + 1 days), ELIGIBILITY);
    }

    function _expectRejected(
        bytes4 reason,
        bytes32 id,
        uint256 amount,
        uint32 count,
        uint64 expiry,
        bytes32 eligibility
    ) private {
        vm.expectRevert(reason);
        vm.prank(ALICE);
        escrow.fund(id, amount, count, expiry, eligibility);
        require(escrow.totalReserved() == 0, "reserved after rejected input");
        require(token.balanceOf(ALICE) == 1000, "input rejection debited sender");
    }

    function testFundingStoresExactTermsAndEmitsReceipt() public {
        vm.recordLogs();
        _fund(ALICE, ID, 120, 3);
        EqualRedPacketFundingPrototype.Packet memory packet = escrow.packetOf(ALICE, ID);
        require(address(escrow.token()) == address(token), "locked token");
        require(packet.sender == ALICE && packet.totalAmount == 120, "funding identity");
        require(packet.amountPerRecipient == 40 && packet.recipientCount == 3, "equal shares");
        require(packet.expiresAt == block.timestamp + 1 days, "expiry");
        require(packet.eligibilityCommitment == ELIGIBILITY, "eligibility");
        require(escrow.totalReserved() == 120 && token.balanceOf(address(escrow)) == 120, "funded balance");
        require(token.balanceOf(ALICE) == 880, "sender debit");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        require(logs.length == 1 && logs[0].emitter == address(escrow), "one receipt");
        require(
            logs[0].topics[0]
                == keccak256("PacketFunded(address,bytes32,address,uint256,uint256,uint32,uint64,bytes32)"),
            "event type"
        );
        require(logs[0].topics[1] == bytes32(uint256(uint160(ALICE))) && logs[0].topics[2] == ID, "event identity");
        require(logs[0].topics[3] == bytes32(uint256(uint160(address(token)))), "event token");
        require(
            keccak256(logs[0].data)
                == keccak256(
                    abi.encode(uint256(120), uint256(40), uint32(3), uint64(block.timestamp + 1 days), ELIGIBILITY)
                ),
            "event terms"
        );
    }

    function testSenderCannotFundSameIdTwiceEvenAfterExpiry() public {
        _fund(ALICE, ID, 120, 3);
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert(EqualRedPacketFundingPrototype.PacketAlreadyFunded.selector);
        _fund(ALICE, ID, 200, 2);
        require(escrow.totalReserved() == 120 && token.balanceOf(ALICE) == 880, "duplicate debit");
        require(escrow.packetOf(ALICE, ID).totalAmount == 120, "duplicate overwrote packet");
    }

    function testPacketIdIsScopedToSenderAndCannotBeSquatted() public {
        _fund(BOB, ID, 200, 2);
        _fund(ALICE, ID, 120, 3);
        require(escrow.packetOf(BOB, ID).sender == BOB, "bob sender");
        require(escrow.packetOf(ALICE, ID).sender == ALICE, "alice sender");
        require(escrow.totalReserved() == 320, "independent packets");
    }

    function testDonationsDoNotCountAsPacketFunding() public {
        token.mint(address(escrow), 700);
        _fund(ALICE, ID, 120, 3);
        require(escrow.totalReserved() == 120 && token.balanceOf(address(escrow)) == 820, "donation bookkeeping");
    }

    function testMissingApprovalAndInsufficientBalanceRevertWithoutReserving() public {
        vm.prank(ALICE);
        token.approve(address(escrow), 0);
        vm.expectRevert(EqualRedPacketFundingPrototype.TokenTransferFailed.selector);
        _fund(ALICE, ID, 120, 3);
        require(escrow.totalReserved() == 0, "approval failure reserved");
        vm.prank(ALICE);
        token.approve(address(escrow), 2000);
        vm.expectRevert(EqualRedPacketFundingPrototype.TokenTransferFailed.selector);
        _fund(ALICE, ID, 2000, 2);
        require(escrow.totalReserved() == 0 && token.balanceOf(ALICE) == 1000, "balance failure mutated");
    }

    function testInvalidPacketTerms() public {
        uint64 future = uint64(block.timestamp + 1 days);
        _expectRejected(
            EqualRedPacketFundingPrototype.InvalidPacketId.selector, bytes32(0), 120, 3, future, ELIGIBILITY
        );
        _expectRejected(EqualRedPacketFundingPrototype.InvalidAmount.selector, ID, 0, 3, future, ELIGIBILITY);
        _expectRejected(EqualRedPacketFundingPrototype.InvalidRecipientCount.selector, ID, 120, 0, future, ELIGIBILITY);
        _expectRejected(EqualRedPacketFundingPrototype.AmountNotDivisible.selector, ID, 121, 3, future, ELIGIBILITY);
        _expectRejected(EqualRedPacketFundingPrototype.AmountNotDivisible.selector, ID, 2, 3, future, ELIGIBILITY);
        _expectRejected(
            EqualRedPacketFundingPrototype.InvalidExpiry.selector, ID, 120, 3, uint64(block.timestamp), ELIGIBILITY
        );
        _expectRejected(
            EqualRedPacketFundingPrototype.InvalidExpiry.selector, ID, 120, 3, uint64(block.timestamp - 1), ELIGIBILITY
        );
        _expectRejected(
            EqualRedPacketFundingPrototype.InvalidEligibilityCommitment.selector, ID, 120, 3, future, bytes32(0)
        );
    }

    function testConstructorRejectsZeroAndNonContractToken() public {
        vm.expectRevert(EqualRedPacketFundingPrototype.InvalidToken.selector);
        new EqualRedPacketFundingPrototype(address(0));
        vm.expectRevert(EqualRedPacketFundingPrototype.InvalidToken.selector);
        new EqualRedPacketFundingPrototype(ALICE);
    }

    function testFalseAbsentMalformedAndRevertingTransferRollBack() public {
        MockToken.Mode[5] memory modes = [
            MockToken.Mode.FalseReturn,
            MockToken.Mode.NoReturn,
            MockToken.Mode.MalformedReturn,
            MockToken.Mode.InvalidBoolean,
            MockToken.Mode.RevertTransfer
        ];
        for (uint256 i; i < modes.length; i++) {
            token.configure(modes[i], escrow);
            vm.expectRevert(EqualRedPacketFundingPrototype.TokenTransferFailed.selector);
            _fund(ALICE, ID, 120, 3);
            _assertNoFunding();
        }
        token.configure(MockToken.Mode.Standard, escrow);
        _fund(ALICE, ID, 120, 3);
        require(escrow.totalReserved() == 120, "retry after failure");
    }

    function testTransferFeesOvercreditAndNoMovementRollBack() public {
        MockToken.Mode[4] memory modes = [
            MockToken.Mode.RecipientFee, MockToken.Mode.SenderFee, MockToken.Mode.Overcredit, MockToken.Mode.NoMovement
        ];
        for (uint256 i; i < modes.length; i++) {
            token.configure(modes[i], escrow);
            vm.expectRevert(EqualRedPacketFundingPrototype.UnexpectedTokenBalanceChange.selector);
            _fund(ALICE, ID, 120, 3);
            _assertNoFunding();
        }
    }

    function testExistingDeficitBlocksNewFunding() public {
        _fund(ALICE, ID, 120, 3);
        token.burn(address(escrow), 1);
        vm.expectRevert(EqualRedPacketFundingPrototype.ExistingFundingDeficit.selector);
        _fund(BOB, keccak256("next"), 120, 3);
        require(token.balanceOf(BOB) == 1000 && escrow.totalReserved() == 120, "deficit concealed");
    }

    function testPropagatedReentryRevertsFundingAndAllTokenChanges() public {
        token.configure(MockToken.Mode.Reenter, escrow);
        vm.expectRevert(EqualRedPacketFundingPrototype.TokenTransferFailed.selector);
        _fund(ALICE, ID, 120, 3);
        _assertNoFunding();
        require(escrow.packetOf(address(token), keccak256("nested")).sender == address(0), "nested packet");
    }

    function testSwallowedReentryCannotCreateNestedPacket() public {
        token.configure(MockToken.Mode.SwallowReentry, escrow);
        _fund(ALICE, ID, 120, 3);
        require(!token.nestedSucceeded(), "reentry succeeded");
        require(token.nestedError() == EqualRedPacketFundingPrototype.ReentrantCall.selector, "reentry error");
        require(escrow.packetOf(address(token), keccak256("nested")).sender == address(0), "nested packet");
        require(escrow.totalReserved() == 120 && token.balanceOf(address(escrow)) == 120, "outer conservation");
    }

    function testNativeCurrencyAndWithdrawalSelectorsAreRejected() public {
        vm.deal(address(this), 1 ether);
        (bool nativeOk,) = address(escrow).call{value: 1}("");
        require(!nativeOk, "native deposit accepted");
        (bool payableFundOk,) = address(escrow).call{value: 1}(
            abi.encodeCall(escrow.fund, (ID, 120, 3, uint64(block.timestamp + 1 days), ELIGIBILITY))
        );
        require(!payableFundOk, "payable funding accepted");
        _fund(ALICE, ID, 120, 3);
        (bool withdrawOk,) = address(escrow).call(abi.encodeWithSignature("withdraw(address,uint256)", ALICE, 120));
        (bool rescueOk,) = address(escrow)
            .call(abi.encodeWithSignature("rescueTokens(address,address,uint256)", address(token), ALICE, 120));
        require(!withdrawOk && !rescueOk, "withdrawal path");
        require(token.balanceOf(address(escrow)) == 120, "withdrawal changed balance");
    }

    function testFuzzEqualFundingConservesAmount(uint128 shareSeed, uint16 countSeed) public {
        uint256 share = uint256(shareSeed) + 1;
        uint32 count = uint32(countSeed) + 1;
        uint256 total = share * count;
        token.mint(ALICE, total);
        vm.prank(ALICE);
        token.approve(address(escrow), total);
        _fund(ALICE, ID, total, count);
        EqualRedPacketFundingPrototype.Packet memory packet = escrow.packetOf(ALICE, ID);
        require(packet.amountPerRecipient == share && packet.recipientCount == count, "equal shares");
        require(packet.amountPerRecipient * packet.recipientCount == packet.totalAmount, "amount conservation");
        require(escrow.totalReserved() == total && token.balanceOf(address(escrow)) == total, "escrow conservation");
        require(token.balanceOf(ALICE) == 1000, "sender conservation");
    }

    function _assertNoFunding() private view {
        require(escrow.totalReserved() == 0, "reserved after failure");
        require(escrow.packetOf(ALICE, ID).sender == address(0), "packet after failure");
        require(token.balanceOf(ALICE) == 1000 && token.balanceOf(address(escrow)) == 0, "balances after failure");
        require(token.allowance(ALICE, address(escrow)) == 1000, "allowance after failure");
    }
}
