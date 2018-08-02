pragma solidity ^0.4.24;

import "./tokens/AMLToken.sol";

contract MediarToken is AMLToken {

  uint256 public constant INITIAL_SUPPLY = 420000000 * (10 ** uint256(18));

  /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
  constructor() public 
    AMLToken("Mediar", "MDR", INITIAL_SUPPLY, 18) {
  }
}