pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ERC223/ERC223_Interface.sol";
import "./ERC223/Receiver_Interface.sol";

/**
  * @title TimedStagesCrowdsale
  */
contract TimedStagesCrowdsale is ContractReceiver {
  using SafeMath for uint256;

  struct Stage {
    uint256 rate;
    uint256 minInvest;
    uint256 openingTime;
    uint256 closingTime;
  }

  // The token being sold
  ERC223 public token; 
  
  // Address where funds are collected
  address public wallet;

  // Amount of wei collected
  uint256 public collectedAmountInWei;

  // Crowdsale stages
  Stage[] public stages;

  // List of investors
  address[] public investors;

  // How much ETH each address has invested to this crowdsale
  mapping(address => uint256) public investedAmountOf;

  /**
  * Event for token purchase logging
  * @param investor who bought tokens
  * @param value weis paid for purchase
  * @param amountOfTokens amount of tokens purchased
  */
  event TokenPurchase(address indexed investor, uint256 value, uint256 amountOfTokens);

  modifier onlyWhileOpen() {
    require(checkStage() >= 0);
    _;
  }

  constructor(address _wallet, ERC223 _token) public {
    require(_wallet != address(0));
    require(_token != address(0));

    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /*
   * @dev For ERC223 support
   */
  function tokenFallback(address /*_from*/, uint /*_value*/, bytes /*_data*/) public {
    // accept only one type of ERC223 tokens
    require(ERC223(msg.sender) == token);
  }

  function () external payable {
    buyTokens();
  }

  function buyTokens() public payable onlyWhileOpen {
    uint256 amountInWei = msg.value;
    uint8 stageNumber = uint8(checkStage());
    require(amountInWei >= stages[stageNumber].minInvest);
    require(amountInWei != 0);

    if(investedAmountOf[msg.sender] == 0) {
      // Add new investor
      investors.push(msg.sender);
    }

    // update investor
    investedAmountOf[msg.sender] = investedAmountOf[msg.sender].add(amountInWei);

    // update total
    collectedAmountInWei = collectedAmountInWei.add(amountInWei);

    // assign tokens
    uint256 tokens = amountInWei.mul(stages[stageNumber].rate);
    _tokenPurchase(msg.sender, tokens);
    emit TokenPurchase(msg.sender, amountInWei, tokens);

    // forward ether to wallet
    _forwardFunds();
  }

  function hasClosed() public view returns (bool) {
    return ( block.timestamp > stages[stages.length-1].closingTime ||
      token.balanceOf(this) == 0 );
  }

  // -----------------------------------------
  // Internal interface (extensible) - similar to protected
  // -----------------------------------------

  function checkStage() internal view returns(int8) {
    for (uint8 i = 0; i < stages.length; ++i) {
      if (block.timestamp <= stages[i].closingTime && block.timestamp >= stages[i].openingTime) {
        return int8(i);
      }
    }
    
    return -1;
  } 

  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function _tokenPurchase(address investor, uint tokens) internal {
    token.transfer(investor, tokens);
  }
}
