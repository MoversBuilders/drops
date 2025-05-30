import { SuiClient } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';

export class DropsClient {
  constructor(public client: SuiClient) {}

  /**
   * Creates a new Drop
   */
  async createDrop(
    tx: Transaction,
    params: {
      name: string;
      description: string;
    }
  ) {
    throw new Error('Not implemented');
  }

}