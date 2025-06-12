import React from 'react';
import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { LotteryHistory, LotteryRound } from './LotteryHistory';
import { JSDOM } from 'jsdom';

// Setup JSDOM
const dom = new JSDOM('<!doctype html><html><body></body></html>');
global.document = dom.window.document;
global.window = dom.window as unknown as Window & typeof globalThis;

const mockRounds: LotteryRound[] = [
  {
    id: 1,
    date: new Date('2023-06-01'),
    potSize: 10000,
    winners: ['0x123', '0x456']
  },
  {
    id: 2,
    date: new Date('2023-06-15'),
    potSize: 15000,
    winners: []
  }
];

describe('LotteryHistory Component', () => {
  beforeEach(() => {
    // Clean up the document body before each test
    document.body.innerHTML = '';
  });

  it('renders without crashing', () => {
    render(<LotteryHistory />);
    const historyElement = screen.getByTestId('lottery-history');
    expect(historyElement).toBeTruthy();
  });

  it('shows no history message when no rounds provided', () => {
    render(<LotteryHistory />);
    const noHistoryMessage = screen.getByText('No lottery history available');
    expect(noHistoryMessage).toBeTruthy();
  });

  it('renders lottery rounds when provided', () => {
    render(<LotteryHistory rounds={mockRounds} />);
    const roundElements = screen.getAllByTestId(/round-\d+/);
    expect(roundElements).toHaveLength(2);
  });

  it('can select a round and show details', () => {
    render(<LotteryHistory rounds={mockRounds} />);
    const firstRoundElement = screen.getByTestId('round-1');
    
    fireEvent.click(firstRoundElement);
    
    const roundDetails = screen.getByTestId('round-details');
    expect(roundDetails).toBeTruthy();
    expect(screen.getByText('Round 1 Details')).toBeTruthy();
  });

  it('handles rounds with no winners', () => {
    render(<LotteryHistory rounds={mockRounds} />);
    const secondRoundElement = screen.getByTestId('round-2');
    
    fireEvent.click(secondRoundElement);
    
    const noWinnersText = screen.getByText('Winners: No winners');
    expect(noWinnersText).toBeTruthy();
  });
});