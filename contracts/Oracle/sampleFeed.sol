//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This is just a sample feed for testing purpose that returns a value between 1-100 for severity

contract feed {

    event RequestFloodSeverity(uint64 _districtCode , uint256 floodSeverity);
    event RequestDroughtSeverity(uint64 _districtCode , uint256 droughtSeverity);

    function getFloodSeverity() external view returns(uint256){
        return (block.timestamp % 100);
    }

    function getDroughtSeverity() external view returns(uint256){
        return (block.timestamp % 100);
    }

}