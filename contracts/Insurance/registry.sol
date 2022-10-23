//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./verifier.sol";

contract Registry is Verifier{

    address public OWNER;
    // Premium rate per hectare of land area for protection against Flood
    uint64 public FLOODPREMIUMRATE;
    // Premium rate per hectare of land area for protection against Drought
    uint64 public DROUGHTPREMIUMRATE;

    event userRegistered(address indexed _addr , bool _protectionAgainst , uint64 _premiumToPay);


    struct info{
        // location address of user where protection is needed (sha256 hash of the string)
        bytes32 location;
        // district code where the location is based
        uint64 districtCode;
        // True if protection is needed against flood , false for drought
        bool protectionAgainst;
        // Amount of premium the user needs to pay
        uint64 premiumToPay;
        // Timestamp at which premium is paid
        uint256 premiumPaidOn;
        // Expiry Timestamp for the insurance (6 months)
        uint256 expiryTimestamp;
    }


    // storing user information
    mapping (address => info) public users;
    // ensuring one insurance per residence address
    mapping (bytes32 => bool) public isLocationRegistered;


    modifier onlyOwner() {
        require (msg.sender == OWNER , "not the owner");
        _;
    }


    constructor(uint64 floodPremiumRate ,uint64 droughtPremiumRate){
        OWNER = msg.sender;
        FLOODPREMIUMRATE = floodPremiumRate;
        DROUGHTPREMIUMRATE = droughtPremiumRate;
    }

    // function to register the user
    function register(Proof memory _proof, 
                    uint[3] memory _input,
                    bytes32 _location , 
                    uint64 _districtCode , 
                    bool _protectionAgainst , 
                    uint64 _landArea) external returns(bool)
    {   

        require(isLocationRegistered[_location] == false , "Location already registered");
        require(verifyTx(_proof , _input) , "Details not valid");
        
        uint64 _premiumToPay = _calculatePremium(_landArea , _protectionAgainst);
        uint256 expiryTimestamp = uint(block.timestamp) + uint(15811200);
        users[msg.sender] = info(_location ,
                                _districtCode , 
                                _protectionAgainst , 
                                _premiumToPay , 
                                0,
                                expiryTimestamp);

        isLocationRegistered[_location] = true;
        emit userRegistered(msg.sender, _protectionAgainst, _premiumToPay);
        return true;
    }

    function deRegister() external returns(bool){
        require(users[msg.sender].expiryTimestamp > 0 && block.timestamp > users[msg.sender].expiryTimestamp , "Cannot de register");
        isLocationRegistered[users[msg.sender].location] = false;

        delete users[msg.sender];
        return true; 
    }

    // calculating the premium value
    function _calculatePremium(uint64 _landArea , 
                                bool _protectionAgainst) internal view returns(uint64)
    {
        if(_protectionAgainst == true){
            return _landArea*FLOODPREMIUMRATE;
        }else{
            return _landArea*DROUGHTPREMIUMRATE;
        }
    }

    // function to change flood premium rate
    function _changeFloodRate(uint64 _newFloodRate) external onlyOwner() {
        FLOODPREMIUMRATE = _newFloodRate;
    }

    // function to change drought premium rate
    function _changeDroughtRate(uint64 _newDroughtRate) external onlyOwner() {
        DROUGHTPREMIUMRATE = _newDroughtRate;
    }

    // function to change owner
    function _changeOwner(address _newOwner) external onlyOwner() {
        OWNER = _newOwner;
    }

}