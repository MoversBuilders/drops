import { suiClient } from '../suiClient';
import { Transaction } from '@mysten/sui/transactions';

export const createCollection = async (
    tx: Transaction,
    params: {
      name: string;
      description: string;
      image: string;
      attributes: Record<string, string[]>;
      flags: number;
      maxSupply: number;
      mintStartTime: number;
      mintStopTime: number;
    }
  ) => {
    const txb = new Transaction();
  };