//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./registry.sol";
import "../Oracle/Ichainlink.sol";

contract Insurance is Registry{

    IChainlink data ;
    event PremiumPaid(address indexed _user , uint256 timestamp);

    // enter feed contract address
    constructor(address _data , uint64 floodPremiumRate ,uint64 droughtPremiumRate) Registry(floodPremiumRate , droughtPremiumRate){
        data = IChainlink(_data);
    }


    // function for users to pay premium before expiry
    function payPremium() external payable returns(bool){
        require(users[msg.sender].premiumPaidOn == 0 , "already paid some premium " );
        require(users[msg.sender].premiumToPay == msg.value , "Not the right amount");
        require(users[msg.sender].expiryTimestamp < block.timestamp , "already expired , register again");
        users[msg.sender].premiumPaidOn = block.timestamp;

        emit PremiumPaid(msg.sender , block.timestamp);

        return true;
    }

    // function for users to claim insurance if severity is greater than 10
    function claim() external returns(bool){
        require(users[msg.sender].premiumPaidOn != 0 , "premium not paid");
        require(users[msg.sender].expiryTimestamp < block.timestamp , "already expired");
        uint256 severity;
        if(users[msg.sender].protectionAgainst){
            severity = data.getFloodSeverity(users[msg.sender].districtCode);
        }else{
            severity = data.getDroughtSeverity(users[msg.sender].districtCode);
        }
        if(severity < 10){
            revert("Not eligible for a claim ");
        }else{
            uint256 _amountToPay = severity*users[msg.sender].premiumToPay;
            payable(msg.sender).transfer(_amountToPay );
        }

        users[msg.sender].expiryTimestamp += uint(15811200);
        users[msg.sender].premiumPaidOn = 0;
        return true; 
    }

}