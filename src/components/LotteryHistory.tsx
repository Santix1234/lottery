import React, { useState, useEffect } from 'react';

// Define interface for lottery round
export interface LotteryRound {
  id: number;
  date: Date;
  potSize: number;
  winners: string[];
}

interface LotteryHistoryProps {
  rounds?: LotteryRound[];
}

export const LotteryHistory: React.FC<LotteryHistoryProps> = ({ rounds = [] }) => {
  const [selectedRound, setSelectedRound] = useState<LotteryRound | null>(null);

  // Validate rounds data
  const validRounds = rounds.filter(round => 
    round.id && round.date && round.potSize !== undefined
  );

  const handleRoundSelect = (round: LotteryRound) => {
    setSelectedRound(round);
  };

  return (
    <div className="lottery-history" data-testid="lottery-history">
      <h2>Lottery History</h2>
      {validRounds.length === 0 ? (
        <p>No lottery history available</p>
      ) : (
        <div className="history-list">
          {validRounds.map(round => (
            <div 
              key={round.id} 
              className="history-item"
              onClick={() => handleRoundSelect(round)}
              data-testid={`round-${round.id}`}
            >
              <span>Round {round.id}</span>
              <span>Date: {round.date.toLocaleDateString()}</span>
              <span>Pot Size: ${round.potSize.toLocaleString()}</span>
            </div>
          ))}
        </div>
      )}

      {selectedRound && (
        <div className="round-details" data-testid="round-details">
          <h3>Round {selectedRound.id} Details</h3>
          <p>Date: {selectedRound.date.toLocaleDateString()}</p>
          <p>Pot Size: ${selectedRound.potSize.toLocaleString()}</p>
          <p>Winners: {selectedRound.winners.length > 0 
            ? selectedRound.winners.join(', ') 
            : 'No winners'}</p>
        </div>
      )}
    </div>
  );
};

export default LotteryHistory;