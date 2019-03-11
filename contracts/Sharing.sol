pragma solidity ^0.4.18;//compiler version greater or equal to 0.4.0

contract Sharing {
  
  //use the enum datatype to define the status of the object.
  //FORRENT:the object waiting to be rent.
  //RENTED:the object have been rented.
  //NOTRENT:The owner does not want to rent object.
  enum Status {FORRENT,RENTED,NOTRENT}
  
  //use the struct datatype to store the object information
  struct Object {
    address owner; // The address of the object'owner
    bytes32 des;   // The description of the object
    Status sta;   // The status of the object
    uint price; // The hourly rental price of the object 
    uint deposit; // The deposit of the object
    address renter; // The address of the object'renter
    uint256 start; // The start time of renting
    uint256 end; // The end time of renting
  }

  uint public numObjects; //The number of objects which have been registered
  mapping (uint => Object) public objects;
  
  //Constructor
  function Sharing() public {
    numObjects = 0;
  }

  /* This function is used to register new object.
     The function will be called by someone who want to share the object.
 */
  function registerObject(bytes32 _objDes,uint _price,uint _deposit) public {

    require(_deposit > _price*24);
    objects[++numObjects] = Object(msg.sender,_objDes,Status.FORRENT,_price,_deposit,0x0,0,0);
  }


  /* This function is used to rent the object.
     The function will be called by someone who want to rent the object.
 */
  function rentObject(uint _objId) payable public {

    //Judge whether the object can be rented
    require(objects[_objId].sta == Status.FORRENT);
    require(msg.value >= objects[_objId].deposit);

    // add renter to object and store the current timestamp
    objects[_objId].renter = msg.sender;
    objects[_objId].start = now;

    //Modify the object status
    objects[_objId].sta = Status.RENTED;

    // send back any excess ether
    uint change = msg.value - objects[_objId].deposit;
    require(objects[_objId].renter.send(change));
    
  }


  /* This function is used to stop the sharing.
     The function will be called by renter.
     The sharing can stop when two sides agree.
     If the renter call this function , it means that the renter agree to stop the sharing.
     If the bicycle is locked and is parked in the right place, the owner will agree to stop the sharingby default.
 */
  function finishSharing(uint _objId) public {
    
    //Determine whether the bike is locked and is parked in the right place.
    //Judge the transaction'sender 
    //Now assume that the bike is locked and is parked in the right place.
    require(msg.sender == objects[_objId].renter);

    //Add the end time of renting
    objects[_objId].end = now;
    
    //caculate the rental fee
    //The system's time unit is seconds and the price unit is ether per hour.
    //For testing convenience, assume the price unit is ether per minute.
    uint fee = (objects[_objId].end - objects[_objId].start)/60*objects[_objId].price;

    //send the rental fee to the owner
    require(objects[_objId].owner.send(fee));
    
    //send the remaining deposit(less the rental fee)back to the renter.
    //Because of the settlement mechanism, the deposit always greater than the fee.
    require(objects[_objId].renter.send(objects[_objId].deposit - fee));

    //Modify the object status
    objects[_objId].sta = Status.FORRENT;

    //delete the Info of the renter
    objects[_objId].renter = 0x0;
    objects[_objId].start = 0;
    objects[_objId].end = 0;
  }

  /* This function is used to reclaim the object.
     The function will be called by owner.
     Only the object is not rented, it can be reclaimed by owner.
 */
  function reclaimObject(uint _objId) public {
    
    //Judge the transaction'sender and the object status.
    require(msg.sender == objects[_objId].owner);
    require(objects[_objId].sta == Status.FORRENT);
    
    //Modify the object status
    objects[_objId].sta = Status.NOTRENT;
  }

  /* This function is used to guarantee will not appear arrears, that is, the deposit is always greater than the fee.
     The function will be called by system every day at 4 a.m.
     The object whose status is RENTED nend to settlemnt.
 */
  function settlement() public {
     for(uint i=1;i<=numObjects;i++){
       if(objects[i].sta == Status.RENTED){
          
          //Add the end time of renting
          objects[i].end = now;
    
          //caculate the rental fee
          //The system's time unit is seconds and the price unit is ether per hour.
          //For testing convenience, assume the price unit is ether per minute.
          uint fee = (objects[i].end - objects[i].start)/60*objects[i].price;

          //send the rental fee to the owner
          require(objects[i].owner.send(fee));
    
          //send the remaining deposit(less the rental fee)back to the renter.
          //Because of the settlement mechanism, the deposit always greater than the fee.
          require(objects[i].renter.send(objects[i].deposit - fee));

          //Modify the object status
          objects[i].sta = Status.FORRENT;

          //delete the Info of the renter
          objects[i].renter = 0x0;
          objects[i].start = 0;
          objects[i].end = 0;         
      }
    }
  }

  function getObjInfo(uint _objId) view public returns (bytes32,uint,uint,uint,uint256,uint256){
    return (objects[_objId].des,uint(objects[_objId].sta),objects[_objId].price,objects[_objId].deposit,objects[_objId].start,objects[_objId].end);
  }
  
  function getnumObjs() view public returns (uint){
    return numObjects;
  }

}
