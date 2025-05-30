import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { ENV } from "../env";
import { getAddress } from "./getAddress";
import { suiClient } from "../suiClient";
import { getSigner } from "./getSigner";

/**
 * Builds, signs, and executes a transaction for creating a collection.
 */
export const createCollection = async (
  params: {
    name: string;
    description: string;
    attributes: Record<string, string[]>;
    flags: number;
    maxSupply: number;
    mintStartTime: number;
    mintStopTime: number;
    coordsLat?: number;
    coordsLon?: number;
  }
): Promise<SuiTransactionBlockResponse> => {
  const tx = new Transaction();

  // Add the collection creation operation to the transaction
  tx.moveCall({
    target: `${ENV.DROPS_PACKAGE_ID}::collection::create`,
    arguments: [
      tx.object(ENV.COLLECTIONS_REGISTRY_ID),
      tx.pure.string(params.name),
      tx.pure.string(params.description),
      tx.pure.u32(params.coordsLat || 0),
      tx.pure.u32(params.coordsLon || 0),
      tx.pure.u16(params.flags),
      tx.pure.u64(params.maxSupply),
      tx.pure.u64(params.mintStartTime),
      tx.pure.u64(params.mintStopTime),
    ],
    typeArguments: [],
  });

  // Sign and execute the transaction
  return suiClient.signAndExecuteTransaction({
    transaction: tx,
    signer: getSigner({ secretKey: ENV.USER_PRIVATE_KEY }),
    options: {
      showEffects: true,
      showObjectChanges: true,
    },
  });
};