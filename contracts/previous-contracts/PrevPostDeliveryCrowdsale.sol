pragma solidity ^0.4.24; 

import "openzeppelin-solidity/contracts/math/SafeMath.sol"; 
import "./PrevTimedStagesCrowdsale.sol"; 

/**
 * @title PrevPostDeliveryCrowdsale
 * @dev Crowdsale that locks tokens from withdrawal until it ends.
 */
contract PrevPostDeliveryCrowdsale is PrevTimedStagesCrowdsale, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) public shares;

  uint256 public totalShares;
  
  // all tokens which will be distributed among post delivery purchases
  uint256 public tokensForDistribution;
  
  bool once = true;

  /**
    * @dev Withdraw tokens only after crowdsale ends.
    */
  function withdrawTokens() public {
    _withdrawTokens(msg.sender);
  }

  /**
    * @dev As an owner withdraw tokens for investor only after crowdsale ends.
    */
  function withdrawTokensForInvestor(address investor) public onlyOwner {
    _withdrawTokens(investor);
  }

  function _withdrawTokens(address investor) internal {
    require(hasClosed());
    require(investor != address(0));

    // get tokens left after closing crowdsale
    getTokensForDistribution();

    uint256 amount = tokensForDistribution.mul(shares[investor]).div(totalShares);
    require(amount != 0);
    shares[investor] = 0;
    _tokenPurchase(investor, amount);
  }

  function getTokensForDistribution() internal {
    if(once) {
      once = false;
      tokensForDistribution = token.balanceOf(this);
    }
  }

  /**
    * @dev Overrides parent by storing balances instead of issuing tokens right away.
    * @param _beneficiary Token purchaser
    * @param _amountInWei payed for tokens
    */
  function _postponedTokenPurchase(address _beneficiary, uint256 _amountInWei) internal {
    shares[_beneficiary] = shares[_beneficiary].add(_amountInWei);
    totalShares = totalShares.add(_amountInWei);
  }

}