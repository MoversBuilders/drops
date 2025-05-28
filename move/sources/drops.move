/// Module: drops
module drops::drops {

    use sui::object::{Self, UID};
    use std::string::String;
    use sui::url::Url;
    use sui::vec_map::{Self, VecMap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /*
    Collection Flags (u16 bits):
    0:      SOULBOUND                   - Drops cannot be transferred
    1:      REUQUIRES_MERKLE_PROOF      - Drop minting requires a merkle proof
    2:      REQUIRES_SECRET             - Drop minting requires zk proof of a secret
    3:      DROP_WITH_RANDOMNESS        - Drops include on-chain random attribute
    4-15:   RESERVED                    - Reserved for future use
    */

    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 0;
    const E_COLLECTION_EXISTS: u64 = 1;
    const E_COLLECTION_NOT_FOUND: u64 = 2;
    const E_MAX_SUPPLY_REACHED: u64 = 3;
    const E_INVALID_MINT_TIME: u64 = 4;
    const E_TRANSFER_LOCKED: u64 = 5;
    const E_INVALID_ZK_PROOF: u64 = 6;
    const E_INVALID_ZK_VERIFICATION_KEY: u64 = 7;
    const E_INVALID_ZK_PUBLIC_INPUTS: u64 = 8;

    /// Geographic coordinates scaled by 1e6 (unsigned fixed-point)
    /// Example: (40.7128° N, 74.0060° W) = (40_712_800, 180_000_000 - 74_006_000)
    public struct Coordinates has store, copy, drop {
        lat: u32,  // Latitude scaled by 1e6 (0 to 180_000_000)
        lon: u32,  // Longitude scaled by 1e6 (0 to 360_000_000)
    }

    /// Global registry of all collections (shared object)
    public struct CollectionsRegistry has key {
        id: UID,                                // Unique object ID
        collections: vector<ID>,                // All collection IDs; index = sequence_number
    }

    /// Registry for drops in a collection (shared object)
    public struct DropsRegistry has key {
        id: UID,                                // Unique object ID
        drops: vector<ID>,                      // All drop IDs; index = sequence_number
    }

    /// Base Groth16 config
    public struct Groth16Config has store {
        curve: u8,                              // Curve type (0: BN128, 1: BLS12_381)
        verification_key: vector<u8>,           // Raw verification key
        prepared_verification_key: vector<u8>,  // Pre-processed for efficiency
        expected_public_inputs: u64,            // Number of expected public inputs
    }

    /// Groth16 config for Merkle tree membership proofs
    public struct Groth16MerkleConfig has store {
        config: Groth16Config,                  // Base Groth16 config
        merkle_root: vector<u8>,                // Merkle root for membership proofs
    }

    /// Collection struct - represents a set of drops (NFTs)
    public struct Collection has key, store {
        id: UID,                                // Unique object ID
        version: u8,                            // Version for upgradeability
        name: String,                           // Collection name
        description: String,                    // Collection description
        url: Url,                               // Main URL
        image_url: Url,                         // Image URL
        project_url: Url,                       // Project URL
        coords: Option<Coordinates>,            // Optional geographic coordinates
        flags: u16,                             // Bit flags (see above)
        max_supply: u32,                        // Max supply, defaults to u32::MAX
        mint_start_time: u32,                   // Minting start time (unix timestamp), defaults to creation time
        mint_stop_time: u32,                    // Optional minting stop time, defaults to u32::MAX
        current_supply: u32,                    // Counter of current minted drops
        groth16_secret: Option<Groth16Config>,  // Optional Groth16 config for secret proofs
        groth16_merkle: Option<Groth16MerkleConfig>,// Optional Groth16 config for Merkle proofs
    }

    /// Individual drop struct - represents a single drop NFT token
    public struct Drop has key, store {
        id: UID,                                // Unique object ID
        collection_id: ID,                      // Parent collection ID
        sequence_number: u32,                   // Drop's sequence number in collection
        mint_timestamp: u32,                    // Minting timestamp (unix)
        randomness: Option<u16>,                // Optional on-chain randomness
        attributes: VecMap<String, vector<u8>>, // Arbitrary attributes (key-value)
    }

    // === Functions ===

    /// Initialize the module
    fun init(ctx: &mut TxContext) {
        // Create and share the collections registry
        let collections_registry = CollectionsRegistry {
            id: object::new(ctx),
            collections: vector::empty<ID>()
        };
        transfer::share_object(collections_registry);
    }
}