//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Register.sol";
import "./feed.sol";

contract kitty is register , feed{
    

    function payPremium() public  payable returns(bool){


        require(block.timestamp > farmers[msg.sender].nextDueAt - 2592000, "Already paid for this month");
        require(block.timestamp < farmers[msg.sender].nextDueAt , "Sorry , you are late");

        require(msg.value == farmers[msg.sender].premiumPerMonth , "Recheck premium amount");

        farmers[msg.sender].nextDueAt += 2592000;
        farmers[msg.sender].numberOfPremiums += 1;

        return true;
    }
    

    function getClaim() public returns(bool){

        require(farmers[msg.sender].numberOfPremiums > 0 , "No premiums paid");
        require(getData(farmers[msg.sender].districtCode) , "No drought or flood condition");

        payable(msg.sender).transfer(farmers[msg.sender].payoutAmount);
        return true;

    }


}