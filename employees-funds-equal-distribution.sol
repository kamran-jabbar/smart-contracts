/**
 * This contract is based on to send equal ethers/salary to four employees
 * Owner can deposit ethers contract and once all the employees withdraw ethers owner can depost more ether
 * Author: Kamran Jabbar
 * */

pragma solidity ^0.4.19;

contract salary {
    address[] employees = [
        0xdd870fa1b7c4700f2bd7f44238821c26f7392148,
        0x583031d1113ad414f02576bd6afabfb302140225,
        0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db,
        0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
        ]; 
    uint256 public totalRecieved = 0;
    uint256 public remaining = 0;
    address  owner = msg.sender; 
    mapping (address => bool)  Wallets;
    
    modifier canWithdraw() {
        require(msg.sender != owner);
        bool contains = false;
        for(uint i = 0 ; i < employees.length ; i++){
            if(employees[i] == msg.sender){
                contains = true;
            }
        }
        require(contains);
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function withdraw() canWithdraw {
        uint amountAllocated = totalRecieved/employees.length;
        require(Wallets[msg.sender] == false && amountAllocated > 0);
        msg.sender.transfer(amountAllocated);
        remaining -= amountAllocated;
        Wallets[msg.sender] = true;
    }
    
    modifier updateCondition(){
        require(msg.value > 0 ether);
        updateTotal();
        _;
    }
    
    modifier updatePermission(){
        for(uint i = 0 ; i < employees.length ; i++){
            Wallets[employees[i]] = false;
        }
        _;
    }
    

    function salary() payable updateCondition {
        
    }
    
    function deposit() payable onlyOwner updateCondition {

    }
     
    function() payable updateCondition {

    }

    function updateTotal() internal updatePermission {
        require(remaining <= 0);
        totalRecieved += msg.value;
        remaining = totalRecieved;
    }
}
