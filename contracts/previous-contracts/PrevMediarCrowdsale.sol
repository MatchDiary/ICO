pragma solidity ^0.4.24;

import "./PrevRefundableCrowdsale.sol";
import "./PrevPostDeliveryCrowdsale.sol";

contract PrevMediarCrowdsale is PrevPostDeliveryCrowdsale, PrevRefundableCrowdsale {
  using SafeMath for uint256;

  constructor(
    address _wallet,
    ReleasableToken _token
  ) 
    public
    PrevTimedStagesCrowdsale(_wallet, _token)
  {
    stages.push(Stage(3500, 200 finney, 1533081600, 1533167940));
    stages.push(Stage(3000, 200 finney, 1533168000, 1533254340));
  }
}