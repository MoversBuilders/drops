import { SuiTransactionBlockResponse } from "@mysten/sui/client";
import { createCollection } from "../helpers/createCollection";
import { parseCreatedObjectsIds } from "../helpers/parseCreatedObjectIds";
import { suiClient } from "../suiClient";


describe("Create a collection", () => {
  let txResponse: SuiTransactionBlockResponse;
  let collectionId: string | undefined;
  //let dropId: string | undefined;
  //let dropIds: string[] = [];

  beforeAll(async () => {
    txResponse = await createCollection({
      name: "Test Collection",
      description: "Test Collection Description",
      attributes: {},
      coordsLat: 0,
      coordsLon: 0,
      flags: 0,
      maxSupply: 100,
      mintStartTime: Date.now(),
      mintStopTime: Number.MAX_SAFE_INTEGER,
    });
    await suiClient.waitForTransaction({ digest: txResponse.digest, timeout: 5_000 });
    console.log("Executed transaction with txDigest:", txResponse.digest);
  });

  test("Transaction Status", () => {
    expect(txResponse.effects).toBeDefined();
    expect(txResponse.effects!.status.status).toBe("success");
  });

  test("Created Collection", async () => {
    expect(txResponse.objectChanges).toBeDefined();
    const { objectIds } = parseCreatedObjectsIds({
      objectChanges: txResponse.objectChanges!,
    });
    expect(objectIds.length).toBe(1);
    collectionId = objectIds[0];
  });

  // test("Collections registry", async () => {
  //   const { ids, counter } = await getCollectionsRegistry();
  //   collectionIds = ids;
  //   expect(ids.length).toBeGreaterThan(0);
  //   expect(ids).toContain(collectionId);
  //   expect(counter).toBeGreaterThan(0);
  // });
});