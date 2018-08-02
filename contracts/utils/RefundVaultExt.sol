pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract RefundVaultExt is Ownable
{
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  // How much wei every investor deposited 
  mapping (address => uint256) public deposited;
  State public state;

  // How much wei we have returned back to the contract after a failed crowdfund. 
  uint256 public loadedRefund = 0;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  constructor() public {
    state = State.Active;
  }

  /**
    * @param investor Investor address
    */
  function deposit(address investor, uint weiAmount) onlyOwner public {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(weiAmount);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  /**
    * @param investor Investor address
    */
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    emit Refunded(investor, depositedValue);
  }

  function loadRefund() public payable {
    require(msg.value != 0);
    loadedRefund = loadedRefund.add(msg.value);
  }

  /**
    * @dev As an owner I can always refund.
    */
  function refundAsOwner(address investor) public onlyOwner {
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    emit Refunded(investor, depositedValue);
  }
}