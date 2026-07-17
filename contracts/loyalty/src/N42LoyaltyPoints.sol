// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title N42 Loyalty Points
/// @notice Non-transferable loyalty ledger operated by the official gas relayer.
contract N42LoyaltyPoints {
    error Unauthorized();
    error InvalidAddress();
    error InvalidAmount();
    error InvalidRequestId();
    error RequestAlreadyProcessed();
    error AlreadyCheckedInToday();
    error ReferralAlreadyRegistered();
    error InsufficientPoints();
    error ContractPaused();

    struct Account {
        uint128 available;
        uint128 totalEarned;
        uint128 totalSpent;
        uint64 lastCheckInDay;
    }

    bytes32 public constant DAILY_CHECK_IN = keccak256("DAILY_CHECK_IN");

    address public owner;
    uint128 public dailyCheckInPoints = 10;
    bool public paused;

    mapping(address => bool) public operators;
    mapping(address => Account) private _accounts;
    mapping(address => bool) private _hasCheckedIn;
    mapping(bytes32 => bool) public processedRequests;
    mapping(address => address) public referrerOf;
    mapping(address => bool) private _knownMember;
    address[] private _members;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OperatorUpdated(address indexed operator, bool enabled);
    event DailyCheckInPointsUpdated(uint256 previousAmount, uint256 newAmount);
    event PauseUpdated(bool paused);
    event PointsAwarded(address indexed account, uint256 amount, bytes32 indexed reason, bytes32 indexed requestId);
    event PointsSpent(address indexed account, uint256 amount, bytes32 indexed reason, bytes32 indexed requestId);
    event DailyCheckedIn(address indexed account, uint256 indexed day, bytes32 indexed requestId);
    event TaskCompleted(address indexed account, bytes32 indexed taskId, bytes32 indexed requestId);
    event ReferralRegistered(
        address indexed referrer,
        address indexed referred,
        uint256 referrerPoints,
        uint256 referredPoints,
        bytes32 requestId
    );

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyOperator() {
        if (!operators[msg.sender]) revert Unauthorized();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    constructor(address initialOperator) {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
        if (initialOperator != address(0)) {
            operators[initialOperator] = true;
            emit OperatorUpdated(initialOperator, true);
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function setOperator(address operator, bool enabled) external onlyOwner {
        if (operator == address(0)) revert InvalidAddress();
        operators[operator] = enabled;
        emit OperatorUpdated(operator, enabled);
    }

    function setDailyCheckInPoints(uint128 amount) external onlyOwner {
        if (amount == 0) revert InvalidAmount();
        uint128 previousAmount = dailyCheckInPoints;
        dailyCheckInPoints = amount;
        emit DailyCheckInPointsUpdated(previousAmount, amount);
    }

    function setPaused(bool value) external onlyOwner {
        paused = value;
        emit PauseUpdated(value);
    }

    function checkInFor(address account, bytes32 requestId) external onlyOperator whenNotPaused {
        _validateAccountAndRequest(account, requestId);
        uint64 today = uint64(block.timestamp / 1 days);
        Account storage state = _accounts[account];
        if (_hasCheckedIn[account] && state.lastCheckInDay == today) {
            revert AlreadyCheckedInToday();
        }

        processedRequests[requestId] = true;
        _hasCheckedIn[account] = true;
        state.lastCheckInDay = today;
        _award(account, dailyCheckInPoints, DAILY_CHECK_IN, requestId);
        emit DailyCheckedIn(account, today, requestId);
    }

    function awardTaskFor(address account, bytes32 taskId, uint128 amount, bytes32 requestId)
        external
        onlyOperator
        whenNotPaused
    {
        if (taskId == bytes32(0)) revert InvalidRequestId();
        _validateAccountAndRequest(account, requestId);
        processedRequests[requestId] = true;
        _award(account, amount, taskId, requestId);
        emit TaskCompleted(account, taskId, requestId);
    }

    function awardFor(address account, uint128 amount, bytes32 reason, bytes32 requestId)
        external
        onlyOperator
        whenNotPaused
    {
        if (reason == bytes32(0)) revert InvalidRequestId();
        _validateAccountAndRequest(account, requestId);
        processedRequests[requestId] = true;
        _award(account, amount, reason, requestId);
    }

    function registerReferral(
        address referrer,
        address referred,
        uint128 referrerPoints,
        uint128 referredPoints,
        bytes32 requestId
    ) external onlyOperator whenNotPaused {
        if (referrer == address(0) || referred == address(0) || referrer == referred) {
            revert InvalidAddress();
        }
        _validateAccountAndRequest(referred, requestId);
        if (referrerOf[referred] != address(0)) revert ReferralAlreadyRegistered();

        processedRequests[requestId] = true;
        referrerOf[referred] = referrer;
        if (referrerPoints > 0) {
            _award(referrer, referrerPoints, keccak256("REFERRAL_REFERRER"), requestId);
        }
        if (referredPoints > 0) {
            _award(referred, referredPoints, keccak256("REFERRAL_REFERRED"), requestId);
        }
        emit ReferralRegistered(referrer, referred, referrerPoints, referredPoints, requestId);
    }

    function spendFor(address account, uint128 amount, bytes32 reason, bytes32 requestId)
        external
        onlyOperator
        whenNotPaused
    {
        if (reason == bytes32(0)) revert InvalidRequestId();
        _validateAccountAndRequest(account, requestId);
        if (amount == 0) revert InvalidAmount();

        Account storage state = _accounts[account];
        if (state.available < amount) revert InsufficientPoints();
        processedRequests[requestId] = true;
        state.available -= amount;
        state.totalSpent += amount;
        emit PointsSpent(account, amount, reason, requestId);
    }

    function accountOf(address account) external view returns (Account memory) {
        return _accounts[account];
    }

    function checkedInToday(address account) external view returns (bool) {
        return _hasCheckedIn[account] && _accounts[account].lastCheckInDay == uint64(block.timestamp / 1 days);
    }

    function memberCount() external view returns (uint256) {
        return _members.length;
    }

    function memberAt(uint256 index) external view returns (address) {
        return _members[index];
    }

    function _validateAccountAndRequest(address account, bytes32 requestId) private view {
        if (account == address(0)) revert InvalidAddress();
        if (requestId == bytes32(0)) revert InvalidRequestId();
        if (processedRequests[requestId]) revert RequestAlreadyProcessed();
    }

    function _award(address account, uint128 amount, bytes32 reason, bytes32 requestId) private {
        if (amount == 0) revert InvalidAmount();
        Account storage state = _accounts[account];
        state.available += amount;
        state.totalEarned += amount;
        if (!_knownMember[account]) {
            _knownMember[account] = true;
            _members.push(account);
        }
        emit PointsAwarded(account, amount, reason, requestId);
    }
}
