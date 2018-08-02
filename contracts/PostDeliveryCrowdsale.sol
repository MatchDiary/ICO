pragma solidity ^0.4.24; 

import "openzeppelin-solidity/contracts/math/SafeMath.sol"; 
import "./RefundableCrowdsale.sol"; 

/**
  * @title PostDeliveryCrowdsale
  * @dev Crowdsale that distributes bonus tokens after successful finalization.
  */
contract PostDeliveryCrowdsale is RefundableCrowdsale {
  using SafeMath for uint256;

  // bonus tokens withdrawned or not.
  mapping(address => bool) public withdrawned;
  
  // left tokens, which will be distributed after crowdsale
  uint256 public tokensForDistribution = 0;

  /**
    * @dev Withdraw tokens only after crowdsale finalization.
    */
  function withdrawTokens() public {
    _withdrawTokens(msg.sender);
  }

  /**
    * @dev As an owner withdraw tokens for investor only after crowdsale finalization.
    */
  function withdrawTokensForInvestor(address investor) public onlyOwner {
    require(investor != address(0));
    _withdrawTokens(investor);
  }

  function _withdrawTokens(address investor) internal {
    require(tokensForDistribution != 0);
    require(withdrawned[investor] == false, "Investor withdrew the funds previously");
    
    withdrawned[investor] = true;
    uint256 amount = tokensForDistribution.mul(investedAmountOf[investor]).div(collectedAmountInWei - weiRefunded);
    require(amount != 0);
    _tokenPurchase(investor, amount);
  }

  /**
    * @dev finalization task, called when owner calls finalize()
    * when successful calculate tokens for distribution.
    */
  function finalization(bool isSuccessful) internal {
    if (isSuccessful) {
      tokensForDistribution = token.balanceOf(this);
    } 

    super.finalization(isSuccessful);
  }
  
}