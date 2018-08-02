pragma solidity ^0.4.24; 

import "openzeppelin-solidity/contracts/math/SafeMath.sol"; 
import "./FinalizableCrowdsale.sol"; 
import "./tokens/ReleasableToken.sol";

/**
  * @title RefundableCrowdsale
  * @dev Extension of Crowdsale contract add
  * the possibility of users getting a refund if goal is not met.
  */
contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  State public state;

  // How much wei we have returned back to the contract after a failed crowdfund. 
  uint256 public loadedRefund = 0;

  // How much wei we have given back to investors.
  uint public weiRefunded = 0;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  /**
    * @dev Constructor, set crowdsale to active.
    */
  constructor() public {
    state = State.Active;
  }

  /**
    * @dev Investors can claim refunds here if crowdsale is unsuccessful
    */
  function claimRefund() public {
    require(isFinalized);
    require(state == State.Refunding);
    refund(msg.sender);
  }

  /**
    * @dev As an owner refund for investor, used when KYC 
    * check didn't pass.
    */
  function claimRefundForInvestor(address investor) public onlyOwner {
    require(investor != address(0));
    refund(investor);
  }

  /**
    * @dev vault finalization task, called when owner calls finalize()
    * when successful release token and disable refunding.
    */
  function finalization(bool isSuccessful) internal {
    if (isSuccessful) {
      close();
      ReleasableToken(token).releaseTokenTransfer();
    } else {
      enableRefunds();
    }

    super.finalization(isSuccessful);
  }

  /**
    * @dev Allow load refunds back on the contract for the refunding.
    * The team can transfer the funds back on the smart contract in the case the minimum goal was not reached.
    */
  function loadRefund() public payable {
    require(msg.value != 0);
    loadedRefund = loadedRefund.add(msg.value);
  }

  /**
    * @dev Overrides Crowdsale fund forwarding, sending funds to wallet when crowdsale in active state.
  */
  function _forwardFunds() internal {
    require(state == State.Active);
    super._forwardFunds();
  }

  function close() onlyOwner internal {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
  }

  function enableRefunds() onlyOwner internal {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  function refund(address investor) internal {
    uint256 depositedValue = investedAmountOf[investor];
    require(depositedValue != 0);
    investedAmountOf[investor] = 0;
    weiRefunded = weiRefunded.add(depositedValue);
    investor.transfer(depositedValue);
    emit Refunded(investor, depositedValue);
  }
}
