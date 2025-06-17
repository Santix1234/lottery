// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lottery {
    // Struct to track detailed lottery round information
    struct LotteryRound {
        uint256 roundId;
        uint256 startTime;
        uint256 endTime;
        uint256 totalPot;
        address[] participants;
        address winner;
        bool isCompleted;
    }

    // Mapping to store lottery rounds
    mapping(uint256 => LotteryRound) public lotteryRounds;
    uint256 public currentRoundId;

    // Events to track lottery round lifecycle
    event LotteryRoundStarted(uint256 indexed roundId, uint256 startTime);
    event ParticipantAdded(uint256 indexed roundId, address participant);
    event LotteryRoundCompleted(uint256 indexed roundId, address winner, uint256 totalPot);

    constructor() {
        currentRoundId = 1;
    }

    // Function to start a new lottery round
    function startNewRound() public {
        LotteryRound storage newRound = lotteryRounds[currentRoundId];
        newRound.roundId = currentRoundId;
        newRound.startTime = block.timestamp;
        newRound.isCompleted = false;

        emit LotteryRoundStarted(currentRoundId, block.timestamp);
    }

    // Function to add a participant to the current round
    function addParticipant(address participant) public {
        require(!lotteryRounds[currentRoundId].isCompleted, "Lottery round is already completed");
        
        LotteryRound storage currentRound = lotteryRounds[currentRoundId];
        currentRound.participants.push(participant);
        
        emit ParticipantAdded(currentRoundId, participant);
    }

    // Function to complete the current lottery round
    function completeRound(address winner, uint256 totalPot) public {
        require(!lotteryRounds[currentRoundId].isCompleted, "Lottery round is already completed");
        
        LotteryRound storage currentRound = lotteryRounds[currentRoundId];
        currentRound.endTime = block.timestamp;
        currentRound.winner = winner;
        currentRound.totalPot = totalPot;
        currentRound.isCompleted = true;

        emit LotteryRoundCompleted(currentRoundId, winner, totalPot);
        
        // Increment round ID for the next round
        currentRoundId++;
    }

    // Function to retrieve details of a specific lottery round
    function getLotteryRound(uint256 roundId) public view returns (LotteryRound memory) {
        require(roundId > 0 && roundId < currentRoundId, "Invalid round ID");
        return lotteryRounds[roundId];
    }

    // Function to get participants of a specific round
    function getRoundParticipants(uint256 roundId) public view returns (address[] memory) {
        require(roundId > 0 && roundId < currentRoundId, "Invalid round ID");
        return lotteryRounds[roundId].participants;
    }
}