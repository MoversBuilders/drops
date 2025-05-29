module drops::collection {

    use std::string::String;
    use sui::table::{Self, Table};
    use sui::package;
    use sui::display;

    // Error codes
    const EInvalidFlags: u64 = 0;
    const EInvalidMaxSupply: u64 = 1;
    const EInvalidMintTimes: u64 = 2;

    // Base URL for all collection-related links
    const BASE_URL: vector<u8> = b"https://drops.movers.builders/";

    /*
    Collection Flags (u16 bits):
    0:      ONE_PER_ADDRESS             - Only one drop per address
    1:      SOULBOUND                   - Drops cannot be transferred
    2:      REQUIRES_SECRET             - Drop minting requires zk proof of a secret
    3:      REUQUIRES_MERKLE_PROOF      - Drop minting requires a merkle proof
    4:      DROP_WITH_RANDOMNESS        - Drops include on-chain random attribute
    5-15:   RESERVED                    - Reserved for future use
    */

    /// Collection struct - represents a set of drops (NFTs)
    public struct Collection has key, store {
        id: UID,                                // Unique object ID
        name: String,                           // Collection name
        description: String,                    // Collection description
        creator: address,                       // Collection creator
        coords: Option<Coordinates>,            // Optional geographic coordinates
        flags: u16,                             // Bit flags (see above)
        max_supply: u64,                        // Max supply, defaults to u32::MAX
        mint_start_time: u64,                   // Minting start time (unix timestamp), defaults to creation time
        mint_stop_time: u64,                    // Optional minting stop time, defaults to u32::MAX
        groth16_secret: Option<Groth16Config>,  // Optional Groth16 config for secret proofs
        groth16_merkle: Option<Groth16MerkleConfig>,// Optional Groth16 config for Merkle proofs
    }
    
    /// Global registry of all collections (shared object)
    public struct CollectionsRegistry has key {
        id: UID,                                // Unique object ID
        collections: Table<u64, ID>,            // All collection IDs; index = sequence_number
    }

    /// Geographic coordinates scaled by 1e6 (unsigned fixed-point)
    /// Example: (40.7128° N, 74.0060° W) = (40_712_800, 180_000_000 - 74_006_000)
    public struct Coordinates has store, copy, drop {
        lat: u32,  // Latitude scaled by 1e6 (0 to 180_000_000)
        lon: u32,  // Longitude scaled by 1e6 (0 to 360_000_000)
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

    /// One-Time-Witness for the module
    public struct COLLECTION has drop {}

    // === Functions ===

    public(package) fun with_base_url(suffix: String): String {
        let mut base = std::string::utf8(BASE_URL);
        std::string::append(&mut base, suffix);
        base
    }

    /// Initialize the module
    fun init(otw: COLLECTION, ctx: &mut TxContext) {
        // Create and share the collections registry
        let collections_registry = CollectionsRegistry {
            id: object::new(ctx),
            collections: table::new<u64, ID>(ctx)
        };
        transfer::share_object(collections_registry);

        // Create Display for Collection type
        let publisher = package::claim(otw, ctx);
        let keys = vector[
            b"name".to_string(),
            b"description".to_string(),
            b"url".to_string(),
            b"image_url".to_string(),
            b"project_url".to_string(),
            b"creator".to_string(),
            b"flags".to_string(),
            b"coords".to_string(),
            b"max_supply".to_string(),
            b"mint_start_time".to_string(),
            b"mint_stop_time".to_string(),
            b"groth16_secret".to_string(),
            b"groth16_merkle".to_string()
        ];

        let values = vector[
            b"{name}".to_string(),
            b"{description}".to_string(),
            with_base_url(b"/collection/{id}".to_string()),
            with_base_url(b"/collection/img/{id}".to_string()),
            BASE_URL.to_string(),
            b"{creator}".to_string(),
            b"{flags}".to_string(),
            b"{coords}".to_string(),
            b"{max_supply}".to_string(),
            b"{mint_start_time}".to_string(),
            b"{mint_stop_time}".to_string(),
            b"{groth16_secret}".to_string(),
            b"{groth16_merkle}".to_string()
        ];

        let mut display = display::new_with_fields<Collection>(
            &publisher, keys, values, ctx
        );

        // Commit first version of Display to apply changes.
        display::update_version(&mut display);

        // Transfer publisher and display to deployer
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    public entry fun create(
        registry: &mut CollectionsRegistry,
        name: String,
        description: String,
        coords_lat: u32,
        coords_lon: u32,
        flags: u16,
        max_supply: u64,
        mint_start_time: u64,
        mint_stop_time: u64,
        ctx: &mut TxContext
    ) {
        // Check if either REQUIRES_SECRET (bit 2) or REQUIRES_MERKLE_PROOF (bit 3) is set
        // In that case, use the appropriate constructors
        assert!(flags & 0x000C == 0, EInvalidFlags);

        // Validate max supply and mint time window inputs
        assert!(max_supply > 0, EInvalidMaxSupply);
        assert!(mint_start_time <= mint_stop_time, EInvalidMintTimes);
        assert!(mint_start_time >= (tx_context::epoch(ctx)), EInvalidMintTimes);

        let groth16_secret = option::none();
        let groth16_merkle = option::none();

        let coords = Coordinates {
            lat: coords_lat,
            lon: coords_lon,
        };

        // Create the collection
        let collection = Collection {
            id: object::new(ctx),
            name,
            description,
            creator: tx_context::sender(ctx),
            coords: option::some(coords),
            flags,
            max_supply,
            mint_start_time,
            mint_stop_time,
            groth16_secret,
            groth16_merkle,
        };

        // Add to registry and transfer
        let sequence_number = (table::length(&registry.collections));
        table::add(&mut registry.collections, sequence_number, object::id(&collection));
        transfer::transfer(collection, tx_context::sender(ctx));
    }
}
