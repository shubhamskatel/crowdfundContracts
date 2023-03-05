//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./interfaces/IERC20.sol";
import "./libraries/TransferHelper.sol";
import "./utils/Ownable.sol";
import "./utils/ReentrancyGuard.sol";

contract Crowdfunding is Ownable, ReentrancyGuard {
    ///////////////////////////////////
    ////// VARIABLES
    uint256 public totalFunds;
    bool isInitialzed;
    IERC20 public token;

    ///////////////////////////////////
    ////// EVENTS
    event FundCreated(
        uint256 fundIndex,
        uint256 amountToRaise,
        uint256 amountRaised,
        uint32 endtTime,
        address creator,
        bool isClaimed
    );

    event Donation(uint256 fundIndex, uint256 amount, address donorAddress);

    event FundWithdrawal(uint256 fundIndex, bool isClaimed);

    ///////////////////////////////////
    ////// STRUCTS
    struct Crowdfund {
        uint256 amountToRaise;
        uint256 amountRaised;
        uint32 endTime;
        address creator;
        bool isClaimed;
    }
    mapping(uint256 => Crowdfund) public fundInfo;

    struct Donor {
        uint256 donatedAmount;
    }
    mapping(address => mapping(uint256 => Donor)) public donorInfo;

    ///////////////////////////////////
    ////// CONSTRUCTOR/INITIALIZE

    receive() external payable {
        TransferHelper.safeTransferETH(owner, msg.value);
    }

    // constructor(IERC20 _tokenAddress) {
    //     token = _tokenAddress;
    // }

    function initialize(address _owner, IERC20 _tokenAddress) public {
        require(!isInitialzed, "Already initialzed");
        isInitialzed = true;

        _setOwner(_owner);
        token = _tokenAddress;
    }

    ///////////////////////////////////
    ////// FUND CREATION

    // Function let users create a new fund
    function createNewFund(uint256 _amountToRaise, uint32 _endTime)
        external
        nonReentrant
    {
        require(_amountToRaise > 0, "Amount to raise cannot be zero.");
        require(
            block.timestamp < _endTime + uint32(block.timestamp),
            "Current time cannot be more than end time."
        );

        // Values set
        Crowdfund memory newFund = Crowdfund({
            amountToRaise: _amountToRaise,
            amountRaised: 0,
            endTime: _endTime + uint32(block.timestamp),
            creator: msg.sender,
            isClaimed: false
        });
        fundInfo[++totalFunds] = newFund;

        // Emits an event
        emit FundCreated(
            totalFunds,
            _amountToRaise,
            0,
            newFund.endTime,
            msg.sender,
            false
        );
    }

    ///////////////////////////////////
    ////// FUND DONATION

    // Function let donors donate to a fund
    function donateToFund(uint256 _fundIndex, uint256 _amount)
        external
        nonReentrant
    {
        require(_fundIndex <= totalFunds, "Fund doesn't exist.");

        Crowdfund storage fund = fundInfo[_fundIndex];

        require(fund.endTime > block.timestamp, "Fund time is over.");

        require(
            fund.amountRaised < fund.amountToRaise,
            "Amount is already raised."
        );

        // User's balance check
        require(
            token.balanceOf(msg.sender) >= _amount,
            "User doesn't have enough balance to bet."
        );
        require(
            token.allowance(msg.sender, address(this)) >= _amount,
            "Allowance issue."
        );

        donorInfo[msg.sender][_fundIndex].donatedAmount += _amount;
        fundInfo[_fundIndex].amountRaised += _amount;

        TransferHelper.safeTransferFrom(
            address(token),
            msg.sender,
            address(this),
            _amount
        );

        emit Donation(_fundIndex, _amount, msg.sender);
    }

    ///////////////////////////////////
    ////// RAISED AMOUNT CLAIM

    // Function let user claim the raised amount
    function claimRaisedAmount(uint256 _fundIndex) external nonReentrant {
        Crowdfund storage fund = fundInfo[_fundIndex];

        require(
            fund.creator == msg.sender,
            "You are not the creator of the fund"
        );

        require(
            fund.amountRaised >= fund.amountToRaise,
            "Fund has not been raised."
        );

        require(!fund.isClaimed, "Already claimed");

        fund.isClaimed = true;

        TransferHelper.safeTransfer(
            address(token),
            msg.sender,
            fund.amountRaised
        );
    }

    ///////////////////////////////////
    ////// DONATION WITHDRAWAL

    // Function let users claim their donation back in case the fund fails
    function withdrawDonation(uint256 _fundIndex) external nonReentrant {
        require(_fundIndex <= totalFunds, "Fund doesn't exist.");

        Crowdfund storage fund = fundInfo[_fundIndex];
        Donor storage donor = donorInfo[msg.sender][_fundIndex];

        require(donor.donatedAmount > 0, "You have not donated to this fund.");
        require(fund.endTime < block.timestamp, "Fund is still active.");

        fund.amountRaised -= donor.donatedAmount;

        TransferHelper.safeTransfer(
            address(token),
            msg.sender,
            donor.donatedAmount
        );

        donor.donatedAmount = 0;
    }
}
