import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { ENV } from "../env";
import { getAddress } from "./getAddress";
import { suiClient } from "../suiClient";
import { getSigner } from "./getSigner";

/**
 * Builds, signs, and executes a transaction for minting a drop.
 */
export const mintDrop = async (
  params: {
  }
): Promise<SuiTransactionBlockResponse> => {
  const tx = new Transaction();

  // Add the drop minnt operation to the transaction
  tx.moveCall({
    target: `${ENV.DROPS_PACKAGE_ID}::collection::mint`,
    arguments: [

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