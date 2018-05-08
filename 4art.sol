/**
 * The Scalify token contract bases on the ERC20 standard token contracts from
 * zeppelin and is extended by functions to issue tokens as needed by the
 * Scalify ICO.
 * authors: ghulam murtaza
 * */

pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event DelegatedTransfer(address indexed from, address indexed to, address indexed delegate, uint256 value, uint256 fee);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        //call function to check 85%
        locker(_value);
        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev check address of team and founder
    * @param _value The amount to be transferred.
    */
    function locker(uint256 _value) public returns (bool) {
        //founder address
        if(msg.sender == 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c){
            lockerAllowed(_value ,1275000000);
        }
        //team address
        else if(msg.sender == 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db){
            lockerAllowed(_value ,33150000);
        }
    }
    /**
    * @dev check if 85% exceeded for team and founder address
    * @param _value The amount to be transferred.
    * @param percentAllowedValue The amount to be transferred.
    */
    function lockerAllowed(uint256 _value,uint256 percentAllowedValue)  public returns (bool) {
            //check 1 year date for the team and founder transaction
            if(now < 1522753200){
            uint256 remainingBalance = balances[msg.sender].sub(_value);
            //check if transfers exceeded from 85%
            require(remainingBalance >= percentAllowedValue);
            return true;
            }else{
                return true;
            }
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
        assert(token.transfer(to, value));
    }

    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        assert(token.transferFrom(from, to, value));
    }

    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        assert(token.approve(spender, value));
    }
}

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
    using SafeERC20 for ERC20Basic;

    // ERC20 basic token contract being held
    ERC20Basic public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint64 public releaseTime;

    function TokenTimelock(ERC20Basic _token, address _beneficiary, uint64 _releaseTime) public {
        require(_releaseTime > uint64(block.timestamp));
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        require(uint64(block.timestamp) >= releaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        token.safeTransfer(beneficiary, amount);
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        //call function to check 85%
        locker(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Owned() public {
        owner = msg.sender;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract Scalifyt5Token is StandardToken, Owned {
    string public constant name = "4ArtCoin";
    string public constant symbol = "4Art";
    uint8 public constant decimals = 18;
    uint256 public totalSold = 0;
    uint256 public sellPrice = 1412e18;///last cap stage price
    uint256 public buyPrice = 1412e18;///last cap stage price

    /// Maximum tokens to be allocated on the sale
    uint256 public constant TOKENS_SALE_HARD_CAP = 1705243055e18;

    /// Base exchange rate according to active cap
    uint16[4] private BASE_RATES = [4238, 4238, 2342,1412];

    /// seconds since 01.01.1970 to 29.03.2018 (18:00:00 o'clock UTC)
    uint256 public constant datePreCloseGroup = 1525780873;

    /// seconds since 01.01.1970 to 29.03.2018 (18:00:00 o'clock UTC)
    uint256 public constant dateCloseGroup = 3525780873;

    /// seconds since 01.01.1970 to 29.03.2018 (18:00:00 o'clock UTC)
    /// dateCloseGroup ends and Pre ICO 1 start time 04.04.2018
    uint256 public constant datePreIcoSale1 = 4525780873;

    /// seconds since 01.01.1970 to 15.04.2018 (18:00:00 o'clock UTC)
    /// datePreIcoSale1 ends and datePreIcoSale2 time 15.04.2018
    uint256 public constant datePreIcoSale2 = 5525780873;

    /// seconds since 01.01.1970 to 15.04.2018 (18:00:00 o'clock UTC)
    /// datePreIcoSale2 ends and dateIcoSale time 15.04.2018
    uint256 public constant dateIcoSale = 6525780873;

    /// seconds since 01.01.1970 to 15.04.2018 (18:00:00 o'clock UTC)
    /// datePreIcoSale2 ends time 15.04.2018
    uint256 public constant saleEndDate = 7525780873;

    address private FounderToken = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    address private teamToken = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
    address private advisorToken =  0xd3a33fc1ad3e52d6a23f0c2d432dda9f77f67c14;
    address private partnershipToken = 0x24d88dc6720380eedc1320d4669a75d420c7efce;
    address private bountyToken = 0xbb98db886fc3993eaa24996bf84e2fe5176e6189;
    address private affiliateToken = 0x345ca3e014aaf5dca488057592ee47305d9b3e10;
    address private miscToken =  0xe0f5206bbd039e7b0592d8918820024e2a7437b9;

    /// token caps for each round
    uint256[4] public roundCaps = [
      555555555e18, // closegroup sale  (555555555*.30)
      375000000e18, // PreIco Sale1   (375000000*.30)
      346875000e18, // PreIco Sale2   (346875000*.30)
      427812500e18  // Ico Sale   (346875000*.30)
    ];

    modifier inProgress {
      uint256 currenttime = now;
      require(totalSold < TOKENS_SALE_HARD_CAP);
      require( currenttime > dateCloseGroup);
      _;
    }

    function Scalifyt5Token() public {
    totalSupply = 6500000000e18;

    //assign initial tokens for sale to contracter
    balances[msg.sender] = 1705243055;

    ///Assign token to the address at contract deployment
    balances[teamToken] = 39000000;
    balances[FounderToken] = 1500000000;
    balances[advisorToken] = 39000000;
    balances[partnershipToken] = 39000000;
    balances[bountyToken] = 65000000;
    balances[affiliateToken] = 364000000;
    balances[miscToken] = 100000000;
    }

    /// @dev This default function allows token to be purchased by directly
    /// sending ether to this smart contract.
    function () public payable {
      purchaseTokens(msg.sender);
    }

    /// @dev Issue token based on Ether received.
    /// @param _beneficiary Address that newly issued token will be sent to.
    function purchaseTokens(address _beneficiary) public payable inProgress  {
      require(msg.value >= 0.000000000000000001 ether);
      uint256 tokens = computeTokenAmount(msg.value);
      issueTokens(_beneficiary, tokens);
      /// forward the raised funds to the contract creator
      //this.transfer(this.balance);
    }

    /// @dev issue tokens for a single buyer
    /// @param _beneficiary addresses that the tokens will be sent to.
    /// @param _tokens the amount of tokens, with decimals expanded (full).
    function issueTokens(address _beneficiary, uint256 _tokens) internal {
      require(_beneficiary != address(0));
      // increase total sold count
      totalSold = totalSold.add(_tokens);
      _transfer(owner, _beneficiary, _tokens);
      //this.transfer(this.balance);
    }

    /// @dev Returns the current price.
    function price() public view returns (uint256 tokens) {
      return computeTokenAmount(1 ether);
    }

    /// @dev Compute the amount of DOR token that can be purchased.
    /// @param weiAmount Amount of Ether in WEI to purchase DOR.
    /// @return Amount of token to purchase
    function computeTokenAmount(uint256 weiAmount) public returns (uint256 tokens) {
      uint8 roundNum = currentRoundIndexByDate();
      require(roundNum <= 3);
      uint256 prev_caps;
      // sum up previos caps allowed values
      for(uint8 i = 0 ;i <= roundNum ; i++) {
         prev_caps = prev_caps.add(roundCaps[i]);
      }
      tokens = (weiAmount.mul(BASE_RATES[roundNum]))/1000000000000000000;
      require(totalSold.add(tokens) <= prev_caps);
    }

    /// @dev Determine the current sale tier.
    /// @return the index of the current sale tier by date.
    function currentRoundIndexByDate() internal view returns (uint8 roundNum) {
        uint256 currenttime = now;
        require( currenttime < saleEndDate );
        if(now > dateIcoSale) return 3;
        if(now > datePreIcoSale2) return 2;
        if(now > datePreIcoSale1) return 1;
        if(now > dateCloseGroup) return 0;
        if(now > datePreCloseGroup) return 100;
    }

    /// @dev if owner wants to get all contract balance
    function transferAllBalanceToOwner() public onlyOwner {
      /// forward the raised funds to the contract creator
      owner.transfer(this.balance);
    }

    /// Set buy and sell price of 1 token in wei.
    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value/buyPrice;       /// calculates the amount
        _transfer(owner, msg.sender, amount);   /// makes the transfers
         //owner.transfer(msg.value);             /// transfer ether to owner account
    }


    /// @notice Sell `amount` tokens to contract
    /// @param amount of tokens to be sold
    function sell(uint256 amount) public {
        uint256 requiredBalance = (amount * sellPrice)/1000000000000000000;
        require(owner.balance >= requiredBalance);  /// checks if the  owner has enough ether to buy
        msg.sender.transfer(amount * sellPrice);        /// sends ether to the seller. It's important to do this last to avoid recursion attacks
        _transfer(msg.sender, owner, amount);       /// makes the transfers
    }

    /**
     * Internal transfer, only can be called by this contract
     * dynamically take three parameter from,to and value and other transfer function is taking two parameter to and value
     */
    function _transfer(address _from, address _to, uint _value) internal {
        /// Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        /// Check if the sender has enough
        require(balances[_from] >= _value);
        /// Check for overflows
        require(balances[_to] + _value > balances[_to]);
        /// Subtract from the sender
        balances[_from] -= _value;
        /// Add the same to the recipient
        balances[_to] += _value;
        Transfer(_from, _to, _value);
    }

    /// @dev if owner wants to transfer contract ether balance to own account.
    /// @param _value of balance in wei to be transferred
    function transferBalanceToOwner(uint256 _value) public onlyOwner {
        require(_value <= this.balance);
        owner.transfer(this.balance);
    }
}