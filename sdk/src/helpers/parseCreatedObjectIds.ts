import { SuiObjectChange } from "@mysten/sui/client";

interface Args {
  objectChanges: SuiObjectChange[];
}

interface Response {
  objectIds: string[];
}

/**
 * Parses the provided SuiObjectChange[].
 * Extracts the IDs of the created objects, filtering by objectType.
 */
export const parseCreatedObjectsIds = ({ objectChanges }: Args): Response => {
  const objectIds: string[] = [];
  objectChanges.forEach((change) => {
    if (change.type === "created") {
      objectIds.push(change.objectId);
    }
  });
  return { objectIds };
};
