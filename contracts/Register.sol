//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract register{

    event userRegister(address indexed _addr , uint64 indexed _payout);

    uint64 FACTOR = 6000 ;
    uint64 PAYOUT_PER_ACRE = 200000;


    struct info{
        uint64 districtCode;
        uint64 premiumPerMonth;
        uint64 numberOfPremiums;
        uint64 payoutAmount;
        uint256 nextDueAt;
    }



    mapping(address => info) public farmers;



    function registerFarmers(uint64 _districtCode , uint64 _landArea) external returns(bool){
        uint64 _premiumPerMonth = _calculatePremium(_landArea); 
        uint64 _payoutAmount = PAYOUT_PER_ACRE*_landArea;

        farmers[msg.sender] = info(_districtCode , _premiumPerMonth , 0 , _payoutAmount , block.timestamp + 2592000);
        emit userRegister(msg.sender, _payoutAmount);
        return true;
    }


    function _calculatePremium(uint64 landArea) internal view returns(uint64){
        uint64 premium = FACTOR*landArea;
        return premium;
    }


}