// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFundingToken {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @notice Unaudited, local-test-only funding prototype. NO claim or refund path.
/// @dev Never deploy with real funds: deposited tokens cannot be withdrawn.
contract EqualRedPacketFundingPrototype {
    error InvalidToken();
    error InvalidPacketId();
    error PacketAlreadyFunded();
    error InvalidAmount();
    error InvalidRecipientCount();
    error AmountNotDivisible();
    error InvalidExpiry();
    error InvalidEligibilityCommitment();
    error ReentrantCall();
    error TokenTransferFailed();
    error UnexpectedTokenBalanceChange();
    error ExistingFundingDeficit();

    struct Packet {
        address sender;
        uint256 totalAmount;
        uint256 amountPerRecipient;
        uint32 recipientCount;
        uint64 expiresAt;
        // Opaque reserved commitment only. No recipient/proof validation exists yet.
        bytes32 eligibilityCommitment;
    }

    IFundingToken public immutable token;
    uint256 public totalReserved;
    mapping(address sender => mapping(bytes32 packetId => Packet)) private _packets;
    bool private _funding;

    event PacketFunded(
        address indexed sender,
        bytes32 indexed packetId,
        address indexed token,
        uint256 totalAmount,
        uint256 amountPerRecipient,
        uint32 recipientCount,
        uint64 expiresAt,
        bytes32 eligibilityCommitment
    );

    modifier nonReentrant() {
        if (_funding) revert ReentrantCall();
        _funding = true;
        _;
        _funding = false;
    }

    constructor(address tokenAddress) {
        if (tokenAddress == address(0) || tokenAddress.code.length == 0) revert InvalidToken();
        token = IFundingToken(tokenAddress);
    }

    /// @dev Amounts are integer token base units. IDs are unique per sender.
    /// Caller must approve this contract. Only strict boolean-returning ERC20s
    /// are accepted; no-return tokens and transfer-fee/rebasing behavior are unsupported.
    function fund(
        bytes32 packetId,
        uint256 totalAmount,
        uint32 recipientCount,
        uint64 expiresAt,
        bytes32 eligibilityCommitment
    ) external nonReentrant {
        if (packetId == bytes32(0)) revert InvalidPacketId();
        if (_packets[msg.sender][packetId].sender != address(0)) revert PacketAlreadyFunded();
        if (totalAmount == 0) revert InvalidAmount();
        if (recipientCount == 0) revert InvalidRecipientCount();
        if (totalAmount % recipientCount != 0) revert AmountNotDivisible();
        if (expiresAt <= block.timestamp) revert InvalidExpiry();
        if (eligibilityCommitment == bytes32(0)) revert InvalidEligibilityCommitment();

        _receiveExact(msg.sender, totalAmount);

        // Store only fully funded packets; a revert rolls back token state as well.
        uint256 share = totalAmount / recipientCount;
        _packets[msg.sender][packetId] = Packet({
            sender: msg.sender,
            totalAmount: totalAmount,
            amountPerRecipient: share,
            recipientCount: recipientCount,
            expiresAt: expiresAt,
            eligibilityCommitment: eligibilityCommitment
        });
        totalReserved += totalAmount;
        emit PacketFunded(
            msg.sender, packetId, address(token), totalAmount, share, recipientCount, expiresAt, eligibilityCommitment
        );
    }

    function _receiveExact(address sender, uint256 totalAmount) private {
        uint256 escrowBefore = token.balanceOf(address(this));
        uint256 senderBefore = token.balanceOf(sender);
        if (escrowBefore < totalReserved) revert ExistingFundingDeficit();

        // Strict ABI result validation rejects false, absent and malformed returns.
        (bool success, bytes memory result) =
            address(token).call(abi.encodeCall(IFundingToken.transferFrom, (sender, address(this), totalAmount)));
        if (!success || result.length != 32) revert TokenTransferFailed();
        uint256 returned;
        assembly {
            returned := mload(add(result, 32))
        }
        if (returned != 1) revert TokenTransferFailed();

        uint256 escrowAfter = token.balanceOf(address(this));
        uint256 senderAfter = token.balanceOf(sender);
        if (
            escrowAfter < escrowBefore || escrowAfter - escrowBefore != totalAmount || senderAfter > senderBefore
                || senderBefore - senderAfter != totalAmount
        ) revert UnexpectedTokenBalanceChange();
    }

    function packetOf(address sender, bytes32 packetId) external view returns (Packet memory) {
        return _packets[sender][packetId];
    }
}
