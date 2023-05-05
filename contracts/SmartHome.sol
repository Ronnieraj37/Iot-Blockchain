// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract SmartHome{

    address public owner ;

    constructor(){
        owner = msg.sender;
    }

    struct Data{
        uint256 value;
        uint256 timestamp;
    }
    struct Sensor{
        address id;
        string name;
        uint stores;
        mapping(uint256 => Data) value;
        uint256 joint;
        bool isJoined;
    }

    struct Channel{
        uint256 id;
        address creator;
        string name;
        uint256 sensors; 
    }

    Channel[] public channels;
    mapping( string => uint256) channelNameId;
    mapping( uint256 => mapping(uint256 => Sensor)) public accessList;
    mapping( uint256 => mapping(address => bool)) joined;
    //mapping( uint256 => Data[]) public fullData;
    event Export(string name , uint256 val , uint256 time);

    function createChannel(string memory _name) public{
        Channel memory chad = Channel( channels.length ,msg.sender , _name , 0);
        channelNameId[_name] =  channels.length;
        channels.push(chad);
    }

    function getChannel() external view returns(Channel[] memory){
        return channels;
    }

    function addSensor( uint256 _channelId ,address _id, string memory _name) external{
        Channel memory chad = channels[_channelId];
        require( chad.creator == msg.sender,"Only Creator Can Add sensors");
        accessList[_channelId][chad.sensors].id = _id;
        accessList[_channelId][chad.sensors].name = _name;
        accessList[_channelId][chad.sensors].joint += 1 ;
        accessList[_channelId][chad.sensors].stores = 0 ;
        accessList[_channelId][chad.sensors].isJoined = true;
        joined[_channelId][_id] = true;
        channels[_channelId].sensors += 1;
    }

    function addData( uint256 _channelId ,uint256 _value) external {
        Channel memory chad = channels[_channelId];
        require(joined[chad.id][msg.sender],"Sensor Not Connected to Channel");
        for(uint i =0 ;i < chad.sensors; i++ ){
            if(accessList[_channelId][i].id == msg.sender){
                Sensor storage sens = accessList[_channelId][i];
                Data memory data = Data(_value , block.timestamp);
                accessList[_channelId][i].value[sens.stores] = data;
                accessList[_channelId][i].stores += 1;
            }
        }
    }

    function getData(string memory _channelName) external {
        uint256 _channelId = channelNameId[_channelName];
        Channel memory chad = channels[_channelId];
        require(chad.creator == msg.sender || joined[_channelId][msg.sender],"You Don't have Access to this data");
        for(uint i=0;i<chad.sensors;i++){
            for(uint j=0;j < accessList[_channelId][i].stores;j++){
                Data memory instance = accessList[_channelId][i].value[j];
                emit Export( accessList[_channelId][i].name ,instance.value , instance.timestamp);
                //fullData[_channelId].push(instance);
            }
        }
    }

    function removeSensor(string memory _channelName ,uint256 _id) external{
        uint256 _channelId = channelNameId[_channelName];
        require(msg.sender == channels[_channelId].creator,"Only creator can remove Sensor");
        accessList[_channelId][_id].joint -= 1 ;
        accessList[_channelId][_id].isJoined = false ;
        joined[_channelId][accessList[_channelId][_id].id] = false;
        channels[_channelId].sensors -= 1;
    }
}