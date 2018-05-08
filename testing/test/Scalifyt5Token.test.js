const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3'); //web3 require needs to call through constructor function
const web3 = new Web3(ganache.provider());
const {interface, bytecode} = require('../compile');

let accounts;
let contract;
let owner;
let FounderToken = "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c";
let teamToken = "0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db";
let advisorToken =  "0xd3a33fc1ad3e52d6a23f0c2d432dda9f77f67c14";
let partnershipToken = "0x24d88dc6720380eedc1320d4669a75d420c7efce";
let bountyToken = "0xbb98db886fc3993eaa24996bf84e2fe5176e6189";
let affiliateToken = "0x345ca3e014aaf5dca488057592ee47305d9b3e10";
let miscToken =  "0xe0f5206bbd039e7b0592d8918820024e2a7437b9";

beforeEach(async () => {
  //git list of accounts
  accounts = await web3.eth.getAccounts();


  owner = accounts[0];
 // use one of the available accounts to deploy contract;
 contract = await new web3.eth.Contract(JSON.parse(interface))
     .deploy({'data': bytecode, 'arguments': []})
     .send({'from': accounts[0], 'gas' : 3000000});

});

describe('Scalifyt5Token', () => {
  //make sure contract has been deployed
  it('deploys a new contract', () => {
    assert.ok(contract.options.address);
  });

  /***********Initial Balance Checking*********/
  it('should return initial token wei balance of owner 1705243055', async function() {
    let Balance = await contract.methods.balanceOf(owner).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '1705243055');
  });

  it('should return inital token wei balance of founder 1500000000', async function() {
    let Balance = await contract.methods.balanceOf(FounderToken).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '1500000000');
  });

  it('should return inital token wei balance of teamToken 39000000', async function() {
    let Balance = await contract.methods.balanceOf(teamToken).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '39000000');
  });

  it('should return inital token wei balance of advisorToken 39000000', async function() {
    let Balance = await contract.methods.balanceOf(advisorToken).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '39000000');
  });

  it('should return inital token wei balance of partnershipToken 39000000', async function() {
    let Balance = await contract.methods.balanceOf(partnershipToken).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '39000000');
  });

  it('should return inital token wei balance of bountyToken 65000000', async function() {
    let Balance = await contract.methods.balanceOf(bountyToken).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '65000000');
  });

  it('should return inital token wei balance of affiliateToken  364000000', async function() {
    let Balance = await contract.methods.balanceOf(affiliateToken).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '364000000');
  });

  it('should return inital token wei balance of miscToken 100000000', async function() {
    let Balance = await contract.methods.balanceOf(miscToken).call();
    Balance = Balance.toString();
    assert.strictEqual(Balance, '100000000');
  });



  it('Get current round index', async function() {
    let round = await contract.methods.currentRoundIndexByDate().call();
    console.log(round);
    //assert.strictEqual(Balance, '100000000');
  });
  it('should properly [transfer] token', async function() {
    let recipient = accounts[1];
    let tokenWei = 1000000;
    let status = await contract.methods.transfer(recipient, tokenWei).send({from: owner});    
    let ownerBalance = await contract.methods.balanceOf(owner).call();
    let recipientBalance = await contract.methods.balanceOf(recipient).call();
    assert.strictEqual(ownerBalance, '1704243055');
    assert.strictEqual(recipientBalance, '1000000');
  });
 

  it('Allow 15 tokens to accounts[1] address and transfer to miscToken = 2 and affiliateToken = 13', async function() {
    //allow 15 token to account[1] to transfer
    await contract.methods.approve(accounts[1],15).send({from: owner});
    let tokenAllowed = await contract.methods.allowance(owner,accounts[1]).call();
    assert.strictEqual(tokenAllowed, '15');

    //transfer allowed banlace
    await contract.methods.transferFrom(owner, miscToken,2).send({from: accounts[1]});
    await contract.methods.transferFrom(owner, affiliateToken,13).send({from: accounts[1]});

    //check token balances
    let affiliateTokenBalance = await contract.methods.balanceOf(affiliateToken).call();
    assert.strictEqual(affiliateTokenBalance, '364000013');

    let miscTokenBalance = await contract.methods.balanceOf(miscToken).call();
    assert.strictEqual(miscTokenBalance, '100000002');

    let ownerBalance = await contract.methods.balanceOf(owner).call();
    assert.strictEqual(ownerBalance, '1705243040');
    
  });
  it('Purchase token of 1 ether', async function() {
    let otherAddress = "0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF";
    await contract.methods.purchaseTokens(otherAddress).send({from: owner, value: "1000000000000000000"});
    let round = await contract.methods.currentRoundIndexByDate().call();
    if(round == 0 || round == 1){
      let otherBalance = await contract.methods.balanceOf(otherAddress).call();
      assert.strictEqual(otherBalance, '4238');
      let ownerBalance = await contract.methods.balanceOf(owner).call();
      assert.strictEqual(ownerBalance, '1705238817');
    }else if(round == 2){
      let otherBalance = await contract.methods.balanceOf(otherAddress).call();
      assert.strictEqual(otherBalance, '2342');
      let ownerBalance = await contract.methods.balanceOf(owner).call();
      assert.strictEqual(ownerBalance, '1705240713');
    }
    else if(round == 3){
      let otherBalance = await contract.methods.balanceOf(otherAddress).call();
      assert.strictEqual(otherBalance, '1412');
      let ownerBalance = await contract.methods.balanceOf(owner).call();
      assert.strictEqual(ownerBalance, '1705241643');
    }   
  });

  it('Set buy price of 1 token to 4000000000000000 wei and sell on 3000000000000000 wei purchase from accounts[1] of 1eth = 250tokens', async function() {

    //set buy price = 4000000000000000 / token  and sell price 3000000000000000 / token
    await contract.methods.setPrices("3000000000000000","4000000000000000").send({from: owner});
    //buy from accounts[1] with 1eth = 1000000000000000000 wei and verify tokens
    await contract.methods.buy().send({from: accounts[1], value: "1000000000000000000"});
    let otherBalance = await contract.methods.balanceOf(accounts[1]).call();
    assert.strictEqual(otherBalance, '250');

    await contract.methods.sell(250).send({from: accounts[1]});
    let Balance = await contract.methods.balanceOf(accounts[1]).call();
    assert.strictEqual(Balance, '0');
    
  });


  // it('Check 85% of founder transfer', async function() {
  //   FounderToken = "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c";
  //   let Balance = await contract.methods.balanceOf(FounderToken).call();
  //   console.log(Balance);

  //   await contract.methods.transfer(teamToken,100000).send({from: FounderToken});

  //   let Balance1 = await contract.methods.balanceOf(FounderToken).call();
  //   console.log(Balance1);

    
  // });


});
