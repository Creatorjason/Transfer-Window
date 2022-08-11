//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IJuventus{
    function transfer(string calldata _name, uint _playerNumber, uint _worth, bytes32 _playerId) external payable returns(bool);
}
contract Juventus is IJuventus{
    // transfer function
    // hardcoded
    constructor (){
        assignNumber["Ronaldo"] = 7;
        setWorth(7, 10);
    }
    mapping(bytes32 => bool) public sold;
    mapping(uint => uint) public worthCheck;
    mapping(string => uint) public assignNumber;    
    function setWorth(uint _playerNumber, uint _worth) private{
        worthCheck[_playerNumber] = _worth;
    }
    function transfer(string calldata _name, uint _playerNumber, uint _worth, bytes32 _playerId) external payable override returns(bool){
        bytes32 playerId = keccak256(abi.encodePacked(_name, _playerNumber, _worth));
        require(assignNumber[_name] == _playerNumber, "Player not on team");
        require(playerId == _playerId, "Match not found");
        require(worthCheck[_playerNumber] <= _worth, "Amount too low");
        sold[_playerId] = true;
        return true;
        }
}





contract ManchesterUnited{
    
    error NotEnlisted(string error);
    error TooEarly(string time_error, uint timestamp, uint mim_timetamp);
    error Expired(string time_error, uint timestamp, uint max_timestamp);
 
    event Enlisted(bytes32 _playerId, string _name);
   // event Opened(string _state);
    event NewPlayer(bytes32 _playerId, string _name, bool bought);

    //event Closed(string state);

    uint public constant MIN_DELAY = 10;
    uint public constant MAX_DELAY = 10000;
    address public manager;
    mapping(bytes32 => bool) public enlist;
    mapping(bytes32 => bool) public onTeam;
    
    constructor(){
        manager = msg.sender;
    }
    receive() external payable{}

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }
    
    function wantedPlayer(
        string calldata _name,
        uint _playerNumber,
        uint _worth
       
    ) public onlyManager returns(bytes32 _id){
        // create player id = h(_name, _playerNumber, _worth)
        bytes32 playerId = keccak256(abi.encodePacked(_name, _playerNumber, _worth));
        enlist[playerId] = true;
        emit Enlisted(playerId, _name);
        _id = playerId;

    }
    function purchase(
        string calldata _name,
        uint _playerNumber,
        uint _worth,
        uint _timestamp,
        address _club
    ) external payable onlyManager {
        bytes32 pId = wantedPlayer(_name, _playerNumber, _worth);
        if (!enlist[pId]){
            revert NotEnlisted("Player is not enlisted");
            }
        if(_timestamp < block.timestamp + MIN_DELAY){
            revert TooEarly("Kindly wait for the transfer window to open", block.timestamp, block.timestamp + MIN_DELAY);
        } 

        if (block.timestamp + MAX_DELAY < _timestamp){
            revert Expired("Transfer window has closed", block.timestamp, block.timestamp + MAX_DELAY);
        } 
        // I recommend you use an inteface instead of call
        
        //(bool confirm,) = _club.call{value :_worth}(abi.encodeWithSignature(_funcSign, _name, _playerNumber, _worth, pId));
        //require(confirm, "Purchase failed");
        IJuventus club = IJuventus(_club);
        bool confirm = club.transfer(_name,_playerNumber,_worth,pId);
        if(confirm){ 
        //enlist[pId] = false;
        onTeam[pId] = true;
        emit NewPlayer(pId, _name, confirm);
        }
    }
    function getTimeStamp() external view returns(uint time){
        time = block.timestamp + 300;
    }
}

