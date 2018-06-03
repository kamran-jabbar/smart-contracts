/**
 * This contract is based on to send equal ethers/salary to four employees
 * Owner can deposit ethers contract and once all the employees withdraw ethers owner can depost more ether
 * Author: Kamran Jabbar
 * */

pragma solidity ^0.4.19;

contract salary {
    
    uint256 public totalRecieved = 0;
    uint256 public remaining = 0;
    address  owner = msg.sender; 
    mapping (address => bool)  Wallets;
    mapping (address => bool)  employees;
    
    modifier canWithdraw() {
        require(msg.sender != owner);
        require(employees[msg.sender] == true);
        _;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    modifier updateCondition() {
        require(msg.value > 0 ether);
        updateTotal();
        _;
    }
    
    function withdraw() canWithdraw {
        uint amountAllocated = totalRecieved;
        require(Wallets[msg.sender] == false && amountAllocated > 0);
        msg.sender.transfer(amountAllocated);
        remaining -= amountAllocated;
        Wallets[msg.sender] = true;
    }
    
    modifier updatePermission(){
        employees[msg.sender] = false;
        _;
    }
    

    function salary() payable updateCondition {
        
    }
    
    function deposit() payable onlyOwner updateCondition {

    }
     
    function() payable updateCondition {

    }
    
    function addEmployee(address _employeeAddress) {
        employees[_employeeAddress] = true;
    }

    function updateTotal() internal  {
        require(remaining <= 0);
        totalRecieved += msg.value;
        remaining = msg.value;
    }
}
