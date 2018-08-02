import ether from './helpers/ether';
import { advanceBlock } from './helpers/advanceToBlock';
import increaseTime, { increaseTimeTo, duration } from './helpers/increaseTime';
import latestTime from './helpers/latestTime';
import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const TimedStagesCrowdsaleImpl = artifacts.require('TimedStagesCrowdsaleImpl');
const MediarToken = artifacts.require('MediarToken');

contract('TimedStagesCrowdsaleImpl', function ([_, owner, investor, wallet]) {
  const rate = new BigNumber(100000000);
  const value = ether(1);
  const minInvest = new BigNumber('5e17');
  const tokenSupply = new BigNumber('4e26');
  const expectedTokenAmount = rate.mul(value);

  before(async function () {
    // Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
    await advanceBlock();
  });

  beforeEach(async function () {
    this.openingTime = latestTime() + duration.weeks(1);
    this.closingTime = this.openingTime + duration.weeks(1);
    this.afterClosingTime = this.closingTime + duration.seconds(1);
    
    this.token = await MediarToken.new({ from: owner });
    this.crowdsale = await TimedStagesCrowdsaleImpl.new(wallet, this.token.address, 
      rate, minInvest, this.openingTime, this.closingTime
    );

    await this.token.setTransferAgent(owner, true, { from: owner });
    await this.token.setTransferAgent(this.crowdsale.address, true, { from: owner });
    await this.token.transfer(this.crowdsale.address, tokenSupply, { from: owner });
  });

  describe('general crowdsale test', function () {
    it('should have all token supply', async function () {
      const balance = await this.token.balanceOf(this.crowdsale.address);
      balance.should.be.bignumber.equal(tokenSupply);
    });
  
    it('should be ended after last stage', async function () {
      let ended = await this.crowdsale.hasClosed();
      ended.should.equal(false);
      await increaseTimeTo(this.afterClosingTime);
      ended = await this.crowdsale.hasClosed();
      ended.should.equal(true);
    });
  
    it('should be ended when no tokens left', async function () {
      await increaseTimeTo(this.openingTime);
      let ended = await this.crowdsale.hasClosed();
      ended.should.equal(false);
      await this.crowdsale.buyTokens({ value: value*4, from: investor });
      const balance = await this.token.balanceOf(this.crowdsale.address);
      balance.should.be.bignumber.equal(0);
      ended = await this.crowdsale.hasClosed();
      ended.should.equal(true);
    });

    it('should reject other tokens', async function () {
      let newToken = await MediarToken.new();
      await newToken.transfer(this.crowdsale.address, tokenSupply).should.be.rejectedWith(EVMRevert);
    });
  });

  describe('accepting payments', function () {
    it('should reject payments before start', async function () {
      await this.crowdsale.send(value).should.be.rejectedWith(EVMRevert);
      await this.crowdsale.buyTokens({ from: investor, value: value }).should.be.rejectedWith(EVMRevert);
    });

    it('should accept payments after start stage', async function () {
      await increaseTimeTo(this.openingTime);
      await this.crowdsale.send(value).should.be.fulfilled;
      await this.crowdsale.buyTokens({ value: value, from: investor }).should.be.fulfilled;
    });

    it('should reject payments after end of stage', async function () {
      await increaseTimeTo(this.afterClosingTime);
      await this.crowdsale.send(value).should.be.rejectedWith(EVMRevert);
      await this.crowdsale.buyTokens({ value: value, from: investor }).should.be.rejectedWith(EVMRevert);
    });

    it('should reject payments when invest less than minimum after start first stage', async function () {
      await increaseTimeTo(this.openingTime);
      const tooLowInvest = minInvest - 100;
      await this.crowdsale.send(tooLowInvest).should.be.rejectedWith(EVMRevert);
      await this.crowdsale.buyTokens({ value: tooLowInvest, from: investor }).should.be.rejectedWith(EVMRevert);
    });
  });

  describe('token purchases', function () {
    it('should log purchase', async function () {
      await increaseTimeTo(this.openingTime);
      const { logs } = await this.crowdsale.buyTokens({ value: value, from: investor });
      const event = logs.find(e => e.event === 'TokenPurchase');
      event.args.investor.should.equal(investor);
      event.args.value.should.be.bignumber.equal(value);
      event.args.amountOfTokens.should.be.bignumber.equal(expectedTokenAmount);
    });

    it('should assign tokens to beneficiary in stage', async function () {
      await increaseTimeTo(this.openingTime);
      await this.crowdsale.buyTokens({ value, from: investor });
      const balance = await this.token.balanceOf(investor);
      balance.should.be.bignumber.equal(expectedTokenAmount);
    });

    it('should forward funds to wallet in stage after purchase', async function () {
      await increaseTimeTo(this.openingTime);
      const pre = web3.eth.getBalance(wallet);
      await this.crowdsale.buyTokens({ value, from: investor });
      const post = web3.eth.getBalance(wallet);
      post.minus(pre).should.be.bignumber.equal(value);
    });

    it('should store investor and invested amount', async function () {
      await increaseTimeTo(this.openingTime);
      await this.crowdsale.buyTokens({ value, from: investor });
      const invesor1 = await this.crowdsale.investors(0);
      invesor1.should.be.equal(investor);
      const investedAmount = await this.crowdsale.investedAmountOf(investor);
      investedAmount.should.be.bignumber.equal(value);
    });
  });
});
