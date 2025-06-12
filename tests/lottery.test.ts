import { expect, describe, it, beforeEach } from 'vitest';
import { ethers } from 'hardhat';
import { Lottery } from '../src/contracts/Lottery.sol';

describe('Lottery Contract', () => {
    let lottery: Lottery;
    let owner: any;
    let participants: any[];

    beforeEach(async () => {
        const [deployer, ...addrs] = await ethers.getSigners();
        owner = deployer;
        participants = addrs;

        const LotteryFactory = await ethers.getContractFactory('Lottery');
        lottery = await LotteryFactory.deploy();
    });

    it('should start a new lottery round', async () => {
        await lottery.startNewRound();
        const roundId = await lottery.currentRoundId();
        expect(roundId).toBe(2);
    });

    it('should add participants to the current round', async () => {
        await lottery.startNewRound();
        
        for (const participant of participants.slice(0, 3)) {
            await lottery.addParticipant(participant.address);
        }

        const roundParticipants = await lottery.getRoundParticipants(1);
        expect(roundParticipants.length).toBe(3);
    });

    it('should complete a lottery round', async () => {
        await lottery.startNewRound();
        
        const winner = participants[0].address;
        const totalPot = ethers.parseEther('10');

        await lottery.completeRound(winner, totalPot);
        const roundId = await lottery.currentRoundId();
        expect(roundId).toBe(2);

        const completedRound = await lottery.getLotteryRound(1);
        expect(completedRound.winner).toBe(winner);
        expect(completedRound.totalPot).toBe(totalPot);
        expect(completedRound.isCompleted).toBe(true);
    });

    it('should prevent adding participants to a completed round', async () => {
        await lottery.startNewRound();
        const winner = participants[0].address;
        const totalPot = ethers.parseEther('10');

        await lottery.completeRound(winner, totalPot);

        await expect(lottery.addParticipant(participants[1].address))
            .rejects.toThrow('Lottery round is already completed');
    });
});