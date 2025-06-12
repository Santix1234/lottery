// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./VRFv2DirectFundingConsumer.sol";

contract Lottery is ConfirmedOwner, VRFv2DirectFundingConsumer {
    using SafeMath for uint256;

    struct LotteryRound {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint256 totalPot;
        address winner;
        address payable[] participants;
        uint256 ticketPrice;
    }

    address payable[] public players;
    address[] public winners;
    uint256 public lotteryId;
    uint256 public potWidthdrawalEndTime;

    mapping(uint256 => LotteryRound) public lotteryRounds;

    event PlayerEntered(address indexed player, uint256 amount, uint256 indexed lotteryId);
    event WinnerPicked(address indexed winner, uint256 amount, uint256 indexed lotteryId);
    event LotteryReset(uint256 indexed lotteryId);
    event Received(address, uint);

    constructor() VRFv2DirectFundingConsumer() {
        lotteryId = 1;
        potWidthdrawalEndTime = block.timestamp;
        
        // Initialize first lottery round
        lotteryRounds[lotteryId] = LotteryRound({
            id: lotteryId,
            startTime: block.timestamp,
            endTime: 0,
            totalPot: 0,
            winner: address(0),
            participants: new address payable[](0),
            ticketPrice: 0.01 ether
        });
    }

    function enter() public payable {
        require(
            block.timestamp > potWidthdrawalEndTime,
            "Next lottery not started yet"
        );
        require(msg.value >= 0.01 ether, "Ticket costs 0.01 ether");
        
        players.push(payable(msg.sender));
        lotteryRounds[lotteryId].participants.push(payable(msg.sender));
        lotteryRounds[lotteryId].totalPot += msg.value;
        
        emit PlayerEntered(msg.sender, msg.value, lotteryId);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getLotteryId() public view returns (uint256) {
        return lotteryId;
    }

    function getLotteryRoundDetails(uint256 _lotteryId) public view returns (LotteryRound memory) {
        return lotteryRounds[_lotteryId];
    }

    function startPickingWinner() public onlyOwner {
        requestRandomWords();
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );

        finishPickingWinner(_randomWords[0]);
    }

    function finishPickingWinner(uint256 _randomNumber) internal {
        uint256 randomPlayerIndex = _randomNumber % players.length;
        address payable winner = players[randomPlayerIndex];
        uint256 pot = address(this).balance;
        winners.push(winner);

        // Update current lottery round details
        lotteryRounds[lotteryId].endTime = block.timestamp;
        lotteryRounds[lotteryId].winner = winner;

        emit WinnerPicked(winner, pot, lotteryId);
        emit LotteryReset(lotteryId);

        lotteryId = lotteryId + 1;
        
        // Reset players and update withdrawal time
        players = new address payable[](0);
        potWidthdrawalEndTime = block.timestamp + 10 minutes;

        // Initialize next lottery round
        lotteryRounds[lotteryId] = LotteryRound({
            id: lotteryId,
            startTime: block.timestamp,
            endTime: 0,
            totalPot: 0,
            winner: address(0),
            participants: new address payable[](0),
            ticketPrice: 0.01 ether
        });
    }

    function withdrawPot() public payable {
        address payable lastWinner = payable(winners[winners.length - 1]);
        require(msg.sender == lastWinner, "Only winner can withdraw pot");
        require(
            block.timestamp < potWidthdrawalEndTime,
            "Too late, next lottery started"
        );
        uint256 pot = address(this).balance;
        payable(lastWinner).transfer(pot);
    }

    function getWinners() public view returns (address[] memory) {
        return winners;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}