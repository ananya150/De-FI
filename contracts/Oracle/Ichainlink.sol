//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChainlink {

    event RequestFloodSeverity(uint64 _districtCode , uint256 floodSeverity);
    event RequestDroughtSeverity(uint64 _districtCode , uint256 droughtSeverity);    

    function getFloodSeverity(uint64 _districtCode) external  returns(uint256);

    function getDroughtSeverity(uint64 _districtCode) external  returns(uint256);

}