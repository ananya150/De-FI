// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';


// SAMPLE CONTRACT

// An api endpoint is needed that gives flood and drought severity in a district location
// If such than api does not exist we can create one. This can increase precision and reduce gas
// as complex severity calculation is moved off chain.

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    // param can be the severity data for the past year from that day
    uint256 public floodSeverity;
    uint256 public droughtSeverity;
    bytes32 private jobId;
    uint256 private fee;

    // lets assume there exists an api that gives cummulative lastr one yearseverity data for the given district
    string API_url = '---';

    event RequestFloodSeverity( uint256 floodSeverity);
    event RequestDroughtSeverity( uint256 droughtSeverity);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Goerli Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Oracle address) 
     * jobId: ca98366cc7314957b8c012c72f05aeeb  (Job Id for the task)
     *
     */
    constructor(address _linkToken , address _oracleAdd ,bytes32 _jobAdd ) ConfirmedOwner(msg.sender) {
        setChainlinkToken(_linkToken);
        setChainlinkOracle(_oracleAdd);
        jobId = _jobAdd;
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestFloodSeverity(uint64 _districtCode) public returns(uint256) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.floodFulfill.selector);

        // Set the URL to perform the GET request on
        req.add('get', API_url);

        // Set the path to find the desired data in the API response, where the response format is:

        // Set path for api request
        // req.add('path', 'RAW,ETH,USD,VOLUME24HOUR'); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        // int256 timesAmount = 10**18;
        // req.addInt('times', timesAmount);

        // Sends the request
        sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function floodFulfill(bytes32 _requestId , uint256 _floodSeverity) public recordChainlinkFulfillment(_requestId) returns(uint256) {
        emit RequestFloodSeverity(_floodSeverity);
        return _floodSeverity;

    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestDroughtSeverity(uint64 _districtCode) public returns(uint256) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.droughtFulfill.selector);

        // Set the URL to perform the GET request on
        req.add('get', API_url);

        // Set the path to find the desired data in the API response, where the response format is:

        // Set path for api request
        // req.add('path', 'RAW,ETH,USD,VOLUME24HOUR'); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        // int256 timesAmount = 10**18;
        // req.addInt('times', timesAmount);

        // Sends the request
        sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function droughtFulfill(bytes32 _requestId , uint256 _droughtSeverity) public recordChainlinkFulfillment(_requestId) returns(uint256) {
        emit RequestDroughtSeverity(_droughtSeverity);
        return _droughtSeverity;
    }


    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}
