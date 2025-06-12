// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Lottery {
    // Struct to represent a lottery round
    struct LotteryRound {
        uint256 roundId;
        uint256 potAmount;
        address winner;
        uint256 timestamp;
        address[] participants;
    }

    // Mapping to store lottery rounds
    mapping(uint256 => LotteryRound) public lotteryRounds;
    
    // Counter to track the number of rounds
    uint256 public roundCounter;

    // Event to log round creation
    event RoundCreated(uint256 indexed roundId, uint256 potAmount);

    // Function to record a new lottery round
    function recordLotteryRound(
        uint256 _potAmount, 
        address _winner, 
        address[] memory _participants
    ) public {
        roundCounter++;
        
        lotteryRounds[roundCounter] = LotteryRound({
            roundId: roundCounter,
            potAmount: _potAmount,
            winner: _winner,
            timestamp: block.timestamp,
            participants: _participants
        });

        emit RoundCreated(roundCounter, _potAmount);
    }

    // Retrieve round information by round ID
    function getLotteryRound(uint256 _roundId) public view returns (LotteryRound memory) {
        require(_roundId > 0 && _roundId <= roundCounter, "Invalid round ID");
        return lotteryRounds[_roundId];
    }

    // Get total number of rounds
    function getTotalRounds() public view returns (uint256) {
        return roundCounter;
    }

    // Retrieve participants for a specific round
    function getRoundParticipants(uint256 _roundId) public view returns (address[] memory) {
        require(_roundId > 0 && _roundId <= roundCounter, "Invalid round ID");
        return lotteryRounds[_roundId].participants;
    }

    // Get recent rounds (useful for history view)
    function getRecentRounds(uint256 _count) public view returns (LotteryRound[] memory) {
        require(_count > 0, "Count must be positive");
        
        // Determine the actual number of rounds to return
        uint256 actualCount = _count > roundCounter ? roundCounter : _count;
        
        LotteryRound[] memory recentRounds = new LotteryRound[](actualCount);
        
        // Fill the array with most recent rounds (in descending order)
        for (uint256 i = 0; i < actualCount; i++) {
            recentRounds[i] = lotteryRounds[roundCounter - i];
        }
        
        return recentRounds;
    }
}