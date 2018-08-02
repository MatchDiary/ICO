pragma solidity ^0.4.24;

import "./PostDeliveryCrowdsale.sol";
import "./previous-contracts/PrevTimedStagesCrowdsale.sol";
import "./previous-contracts/PrevPostDeliveryCrowdsale.sol";

// ----------------------------------------------------------------------------
// @title MediarCrowdsale
// @dev Crowdsale contract is used for selling ERC223 tokens.
// Below points describes rules for tokens distribution by this contract.
//      1. Sale is only available during certain period of time called stage.
//      2. Price for single token will be constant during standard stage. Every next stage 
//         will start with higher price for token.
//      3. At the end of final stage all unsold tokens will be distributed among
//         investors. Addresses which purchased more tokens 
//         will receive proportionally more unsold tokens.
//      4. After final stage, won't be possible to buy more tokens. 
//         Payable functions will be disabled.
//      5. Refunding when goal not reached.
//      6. AML token support.
// ----------------------------------------------------------------------------
contract MediarCrowdsale is PostDeliveryCrowdsale {
  using SafeMath for uint256;

  address public oldCrowdsale;

  constructor(
    address _oldCrowdsale
  ) 
    public
    TimedStagesCrowdsale(PrevTimedStagesCrowdsale(_oldCrowdsale).wallet(), PrevTimedStagesCrowdsale(_oldCrowdsale).token())
  {
    oldCrowdsale = _oldCrowdsale;
    collectedAmountInWei = PrevTimedStagesCrowdsale(oldCrowdsale).collectedAmountInWei();

    // fill stages in crowdsale
    stages.push(Stage(3000, 200 finney, 1533254400, 1536364799));
    stages.push(Stage(2500, 200 finney, 1536883200, 1538783999));
    stages.push(Stage(2000, 200 finney, 1539302400, 1541203199));
    stages.push(Stage(0, 200 finney, 1541721600, 1543622399));

    // fill investors which already took part in crowdsale
    investors.push(0x5CF41F92dBe726Bb5Addc09baD6e8F1c69CC3E2f);
    investors.push(0xcBf22E891202c90af8bd1cB8a37A9FD1338AD487);
    investors.push(0x54B05C7ec94a9CB8E99762C31EB78824FD5eeFbB);
    investors.push(0xf35A262AB1cf4Fe86ff9E9f03199226b81F6530B);
    investors.push(0xf7e4c1F7EB733E4C0f6B0059BabD4a3d258FD476);
    investors.push(0x3D0eBf06F04BAB909AF3Ae42e1aAEAe474687562);
    investors.push(0xcA39e1399e07F33Df3F18cd481B6B4939e6a6bC4);
    investors.push(0x286eE3f8528b4dCfb91E59b5ED3B60033a11CAb9);
    investors.push(0x6afF0f23aC5130da27c6898620724c81e652993F);
    investors.push(0x4D68289E7f3B823B877275B3745d437c38A9b653);
    investors.push(0xbA7f3995432D5Eb881E2CDd7ddfa454f4765CD85);
    investors.push(0x7676BeCEAac651F8489431C82Ecb17B0906BE884);
    investors.push(0x4f953b6b0a9e990382dc169e21761127826627D1);
    investors.push(0x8c8b167504911f7EdC4f4F9277B27082CBDd9A2b);
    investors.push(0xA0bD339989a4Aba8503fa05578B61c8E8543E27d);
    investors.push(0x3C7e7661a76e03Bf16fB1C1DE18CEDD673eAfabf);
    investors.push(0x3015985AE5198CAc18CbbB167F8dc7Ad2733F2EC);
    investors.push(0xca071536c54Faf8cFCB0F7b22e5a91ed48ED2cEe);
    investors.push(0xa0C50BA04F028AEa547fde6Eb41437A0B1bB8961);
    investors.push(0x6c16fC079a146b2Da93FE20f91c848a6C9829b9a);
    investors.push(0x9b9Bd897fdCbBAdA3EF755Da642Ed6711f2f4171);
    investors.push(0xdE3012c05a93226a82517Cc73DF33324946cA8F7);
    investors.push(0xd9aE272a6a34546504317995Dd337b189704D94f);
    investors.push(0x7071F121C038A98F8A7d485648a27FCD48891Ba8);
    investors.push(0x09871639c2D59E81B4eA16dc24b46Bc1e7321601);
    investors.push(0x257ECf53Bee1893Dc54262aAd29b9CF04520529F);
    investors.push(0xbAd06d566d296973176048dCa00A0581f2f9585C);
    investors.push(0x2835eBB9767B391c8b5e15Bbe4164E0a86d3d0B2);
    investors.push(0x3B2a085375193e9DfE004161eA3Ba0d282Aa0344);
    investors.push(0x1B88C415863e7CC830348d5BAAd13ea6730e45f1);

    // fill invested amount for every investor
    for(uint i = 0; i < investors.length; ++i) {
      address investor = investors[i];
      investedAmountOf[investor] = PrevPostDeliveryCrowdsale(oldCrowdsale).shares(investor);
    }

  }
}
