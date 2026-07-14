// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/N42LoyaltyPoints.sol";

contract LoyaltyCaller {
    function checkIn(N42LoyaltyPoints points, address account, bytes32 requestId) external {
        points.checkInFor(account, requestId);
    }
}

contract N42LoyaltyPointsTest {
    N42LoyaltyPoints private points;
    address private constant USER = address(0x1234);
    address private constant USER_TWO = address(0x5678);

    function setUp() public {
        points = new N42LoyaltyPoints(address(this));
    }

    function testDailyCheckInAwardsTenPoints() public {
        points.checkInFor(USER, keccak256("check-in-1"));
        N42LoyaltyPoints.Account memory account = points.accountOf(USER);
        require(account.available == 10, "available");
        require(account.totalEarned == 10, "earned");
        require(points.checkedInToday(USER), "checked in");
    }

    function testCannotCheckInTwiceInSameDay() public {
        points.checkInFor(USER, keccak256("check-in-1"));
        try points.checkInFor(USER, keccak256("check-in-2")) {
            revert("duplicate check-in accepted");
        } catch {}
    }

    function testOwnerCanChangeDailyCheckInPoints() public {
        points.setDailyCheckInPoints(25);
        points.checkInFor(USER, keccak256("configured-check-in"));
        require(points.accountOf(USER).available == 25, "configured award");
    }

    function testRequestIdsCannotBeReplayed() public {
        bytes32 requestId = keccak256("task-request");
        points.awardTaskFor(USER, keccak256("task"), 25, requestId);
        try points.awardTaskFor(USER, keccak256("task"), 25, requestId) {
            revert("replay accepted");
        } catch {}
    }

    function testReferralAwardsBothAccountsOnce() public {
        points.registerReferral(USER, USER_TWO, 100, 10, keccak256("referral"));
        require(points.accountOf(USER).available == 100, "referrer");
        require(points.accountOf(USER_TWO).available == 10, "referred");
        require(points.referrerOf(USER_TWO) == USER, "relationship");
        try points.registerReferral(USER, USER_TWO, 100, 10, keccak256("referral-2")) {
            revert("duplicate referral accepted");
        } catch {}
    }

    function testSpendUpdatesAvailableAndTotalSpent() public {
        points.awardFor(USER, 50, keccak256("BONUS"), keccak256("award"));
        points.spendFor(USER, 20, keccak256("REWARD"), keccak256("spend"));
        N42LoyaltyPoints.Account memory account = points.accountOf(USER);
        require(account.available == 30, "available");
        require(account.totalSpent == 20, "spent");
    }

    function testNonOperatorCannotAward() public {
        LoyaltyCaller caller = new LoyaltyCaller();
        try caller.checkIn(points, USER, keccak256("unauthorized")) {
            revert("unauthorized caller accepted");
        } catch {}
    }

    function testOwnerCanPauseAllPointMutations() public {
        points.setPaused(true);
        try points.checkInFor(USER, keccak256("paused")) {
            revert("paused mutation accepted");
        } catch {}
        require(points.accountOf(USER).available == 0, "paused balance");

        points.setPaused(false);
        points.checkInFor(USER, keccak256("unpaused"));
        require(points.accountOf(USER).available == 10, "unpaused balance");
    }
}
