pragma solidity ^0.4.24; 

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./../utils/RefundVaultExt.sol";
import "./PrevFinalizableCrowdsale.sol";
import "./../tokens/ReleasableToken.sol";

/**
 * @title PrevRefundableCrowdsale
 * @dev Extension of Crowdsale contract add
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract PrevRefundableCrowdsale is PrevFinalizableCrowdsale {
  using SafeMath for uint256;

  // refund vault used to hold funds for refunding while crowdsale is running
  RefundVaultExt public vault;

  /**
    * @dev Constructor, creates RefundVault.
    */
  constructor() public {
    vault = new RefundVaultExt();
  }

  /**
    * @dev Investors can claim refunds here if crowdsale is unsuccessful
    */
  function claimRefund() public {
    require(isFinalized);

    vault.refund(msg.sender);
  }

  /**
    * @dev As an owner refund for investor, used when KYC 
    * check didn't pass.
    */
  function claimRefundForInvestor(address investor) public onlyOwner {
    require(investor != address(0));

    vault.refundAsOwner(investor);
  }

  /**
    * @dev vault finalization task, called when owner calls finalize()
    * when successful release token and disable refunding.
    */
  function finalization(bool isSuccessful) internal {
    if (isSuccessful) {
      vault.close();
      ReleasableToken(token).releaseTokenTransfer();
    } else {
      vault.enableRefunds();
    }

    super.finalization(isSuccessful);
  }

  /**
    * Allow load refunds back on the contract for the refunding.
    *
    * The team can transfer the funds back on the smart contract in the case the minimum goal was not reached..
    */
  function loadRefund() public payable {
    vault.loadRefund.value(msg.value)();
  }

  /**
    * @dev Overrides Crowdsale fund forwarding, sending funds to wallet.
    * Stores info about investor deposit.
  */
  function _forwardFunds() internal {
    vault.deposit(msg.sender, msg.value);
    wallet.transfer(msg.value);
  }
}