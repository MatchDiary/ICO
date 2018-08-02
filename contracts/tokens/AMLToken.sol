/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.24;

import "./ReleasableToken.sol";


/**
 * The AML Token
 *
 * This subset of ReleasableToken gives the Owner a possibility to
 * reclaim tokens from a participant before the token is released
 * after a participant has failed a prolonged AML process.
 *
 * It is assumed that the anti-money laundering process depends on blockchain data.
 * The data is not available before the transaction and not for the smart contract.
 * Thus, we need to implement logic to handle AML failure cases post payment.
 * We give a time window before the token release for the token sale owners to
 * complete the AML and claw back all token transactions that were
 * caused by rejected purchases.
 */
contract AMLToken is ReleasableToken {

  // An event when the owner has reclaimed non-released tokens
  event OwnerReclaim(address fromWhom, uint amount);

  constructor(string _name, string _symbol, uint _initialSupply, uint _decimals) public {
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    totalSupply = _initialSupply;
    decimals = _decimals;

    balances[owner] = totalSupply;
  }

  /// @dev Here the owner can reclaim the tokens from a participant if
  ///      the token is not released yet. Refund will be handled offband.
  /// @param fromWhom address of the participant whose tokens we want to claim
  function transferToOwner(address fromWhom) public onlyOwner {
    if (released) revert();

    uint amount = balanceOf(fromWhom);
    balances[fromWhom] = balances[fromWhom].sub(amount);
    balances[owner] = balances[owner].add(amount);
    bytes memory empty;
    emit Transfer(fromWhom, owner, amount, empty);
    emit OwnerReclaim(fromWhom, amount);
  }
}
