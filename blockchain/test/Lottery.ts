import { expect } from "chai";
import { ethers } from "hardhat";
import { Lottery, Lottery__factory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("Lottery Contract", function () {
  let lottery: Lottery;
  let owner: SignerWithAddress;
  let player1: SignerWithAddress;
  let player2: SignerWithAddress;

  beforeEach(async function () {
    [owner, player1, player2] = await ethers.getSigners();
    const LotteryFactory: Lottery__factory = await ethers.getContractFactory("Lottery");
    lottery = await LotteryFactory.deploy();
  });

  describe("Lottery Round Details", function () {
    it("should initialize first lottery round correctly", async function () {
      const round = await lottery.getLotteryRoundDetails(1);
      expect(round.id).to.equal(1);
      expect(round.participants.length).to.equal(0);
      expect(round.totalPot).to.equal(0);
      expect(round.ticketPrice).to.equal(ethers.utils.parseEther("0.01"));
    });

    it("should track participants and total pot when players enter", async function () {
      await lottery.connect(player1).enter({ value: ethers.utils.parseEther("0.01") });
      await lottery.connect(player2).enter({ value: ethers.utils.parseEther("0.02") });

      const round = await lottery.getLotteryRoundDetails(1);
      expect(round.participants.length).to.equal(2);
      expect(round.totalPot).to.equal(ethers.utils.parseEther("0.03"));
    });
  });

  describe("Lottery Round History", function () {
    it("should update round details when a winner is picked", async function () {
      // Simulating lottery round with participants
      await lottery.connect(player1).enter({ value: ethers.utils.parseEther("0.01") });
      await lottery.connect(player2).enter({ value: ethers.utils.parseEther("0.02") });

      // Mock fulfilling random words
      // Note: In a real test, you'd need to mock VRF
      await lottery.connect(owner).startPickingWinner();

      const round = await lottery.getLotteryRoundDetails(1);
      expect(round.endTime).to.not.equal(0);
      expect(round.winner).to.not.equal(ethers.constants.AddressZero);
    });

    it("should increment lottery ID after each round", async function () {
      const initialId = await lottery.getLotteryId();
      
      // Simulate lottery round
      await lottery.connect(player1).enter({ value: ethers.utils.parseEther("0.01") });
      await lottery.connect(owner).startPickingWinner();

      const newId = await lottery.getLotteryId();
      expect(newId).to.equal(initialId.add(1));
    });
  });

  describe("Error Handling", function () {
    it("should prevent entering lottery before withdrawal period", async function () {
      await lottery.connect(player1).enter({ value: ethers.utils.parseEther("0.01") });
      await lottery.connect(owner).startPickingWinner();

      // Try to enter during withdrawal period
      await expect(
        lottery.connect(player2).enter({ value: ethers.utils.parseEther("0.01") })
      ).to.be.revertedWith("Next lottery not started yet");
    });
  });
});