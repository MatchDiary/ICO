pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./PrevTimedStagesCrowdsale.sol";

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract PrevFinalizableCrowdsale is PrevTimedStagesCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized(bool isSuccessful);

  /**
    * @dev Must be called after crowdsale ends, to do some extra finalization
    * work. Calls the contract's finalization function.
    * Sends as parameter crowdsale result
    */
  function finalize(bool isSuccessful) onlyOwner public {
    require(!isFinalized);
    require(hasClosed());

    finalization(isSuccessful);
    emit Finalized(isSuccessful);

    isFinalized = true;
  }

  /**
    * @dev Can be overridden to add finalization logic. The overriding function
    * should call super.finalization() to ensure the chain of finalization is
    * executed entirely.
    */
  function finalization(bool) internal {
  }

}