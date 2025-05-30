module drops::collection {

    use std::string::String;
    use sui::table::{Self, Table};
    use sui::vec_map::{Self};
    use sui::package;
    use sui::display;
    use drops::drop::{Drop, AddressDropsRegistry};
    use drops::helpers::{with_base_url, get_base_url};

    // === Error Codes ===

    // Collection creation errors
    const EInvalidFunctionForFlags: u64 = 1;
    const EInvalidMaxSupply: u64 = 2;
    const EInvalidMintTimes: u64 = 3;

    // Minting errors
    const EOnePerAddress: u64 = 4;
    const EMaxSupplyReached: u64 = 5;
    const EMintWindowClosed: u64 = 6;
    const EWrongDropsRegistry: u64 = 7;

    const ENotImplemented: u64 = 99;
    
    // === Registry Structs ===

    /// Global registry of all collections (shared object)
    public struct CollectionsRegistry has key {
        id: UID,                                // Unique object ID
        collections: Table<u64, ID>,            // All collection IDs; index = sequence_number
    }

    /// Registry to track drops per collection (shared object)
    public struct DropsRegistry has key {
        id: UID,
        collection_id: ID,
        drops: Table<u64, ID>,
    }

    // === Object Structs ===

    /// Collection struct - represents a set of drops (NFTs)
    public struct Collection has key, store {
        id: UID,                                // Unique object ID
        name: String,                           // Collection name
        description: String,                    // Collection description
        img: Option<String>,                    // Collection image
        creator: address,                       // Collection creator
        drops_registry: ID,                     // Drops registry
        coords: Option<Coordinates>,            // Optional geographic coordinates
        /*
        Collection Flags (u16 bits):
        0:      ONE_PER_ADDRESS             - Only one drop per address
        1:      SOULBOUND                   - Drops cannot be transferred
        2:      REQUIRES_SECRET             - Drop minting requires zk proof of a secret
        3:      REUQUIRES_MERKLE_PROOF      - Drop minting requires a merkle proof
        4:      DROP_WITH_RANDOMNESS        - Drops include on-chain random attribute
        5-15:   RESERVED                    - Reserved for future use
        */
        flags: u16,                             // Bit flags (see above)
        max_supply: u64,                        // Max supply, defaults to u64::MAX
        mint_start_time: u64,                   // Minting start time (unix timestamp), defaults to creation time
        mint_stop_time: u64,                    // Optional minting stop time, defaults to u64::MAX
        groth16_secret: Option<Groth16Config>,  // Optional Groth16 config for secret proofs
        groth16_merkle: Option<Groth16MerkleConfig>,// Optional Groth16 config for Merkle proofs
    }

    /// Geographic coordinates scaled by 1e6 (unsigned fixed-point)
    /// Example: (40.6387° N, 22.9435° E) = (40_638_700, 22_943_500)
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
            get_base_url(),
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

        // Transfer publisher and display to publisher
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    /// Create a new collection
    public entry fun create(
        collections_registry: &mut CollectionsRegistry,
        name: String,
        description: String,
        img: Option<String>,
        coords_lat: u32,
        coords_lon: u32,
        flags: u16,
        max_supply: u64,
        mint_start_time: u64,
        mint_stop_time: u64,
        ctx: &mut TxContext
    ) {
        // 1. Validate inputs
        // Check if either REQUIRES_SECRET (bit 2) or REQUIRES_MERKLE_PROOF (bit 3) is set
        // In that case, use the appropriate constructors
        assert!(flags & 0x000C == 0, EInvalidFunctionForFlags);

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

        // 2. Create the collection
        // Use a dummy drops_registry ID to bypass circular dependency
        let mut collection = Collection {
            id: object::new(ctx),
            drops_registry: object::id(collections_registry), // dummy, will update below
            name,
            description,
            img,
            creator: tx_context::sender(ctx),
            coords: option::some(coords),
            flags,
            max_supply,
            mint_start_time,
            mint_stop_time,
            groth16_secret,
            groth16_merkle,
        };

        // 3. Create the drops registry
        let drops_registry = DropsRegistry {
            id: object::new(ctx),
            collection_id: object::id(&collection),
            drops: table::new<u64, ID>(ctx),
        };

        // 4. Update the collection to reference the correct drops_registry ID
        collection.drops_registry = object::id(&drops_registry);

        // 5. Transfer the drops registry
        transfer::share_object(drops_registry);

        // 6. Add to CollectionsRegistry and transfer
        let sequence_number = table::length(&collections_registry.collections);
        table::add(&mut collections_registry.collections, sequence_number, object::id(&collection));
        transfer::transfer(collection, tx_context::sender(ctx));
    }

    /// Mint a drop
    public entry fun mint(
        collection: &Collection,
        drops_registry: &mut DropsRegistry,
        address_drops_registry: &mut AddressDropsRegistry,
        receiver: address,
        ctx: &mut TxContext
    ) {
        // Check if either REQUIRES_SECRET (bit 2) or REQUIRES_MERKLE_PROOF (bit 3) is set
        // If so, we need to use the appropriate mint function
        assert!(collection.flags & 0x000C == 0, EInvalidFunctionForFlags);

        // Check if collection requires a randomness
        assert!(collection.flags & 0x0008 == 0, ENotImplemented);

        // Check that the collection has enough supply and is in the minting window
        assert!(collection.max_supply > table::length(&drops_registry.drops), EMaxSupplyReached);
        let now = tx_context::epoch(ctx);
        assert!(collection.mint_start_time <= now && collection.mint_stop_time >= now, EMintWindowClosed);

        // Check that the collection and drops registry are correctly linked
        assert!(collection.drops_registry == object::id(drops_registry), EWrongDropsRegistry);
        assert!(drops_registry.collection_id == object::id(collection), EWrongDropsRegistry);

        // If ONE_PER_ADDRESS (bit 0) is set, check AddressDropsRegistry to see if the address already has a drop
        if(collection.flags & 0x0001 == 0) {
            let drops: vector<ID> = drops::drop::get_collection_drops_of_address(
                address_drops_registry, 
                object::id(collection),
                receiver
            );
            assert!(vector::length(&drops) == 0, EOnePerAddress);
        };

        let sequence_number = table::length(&drops_registry.drops);
        
        // Delegate to drop::mint
        let drop: Drop = drops::drop::mint(
            address_drops_registry,
            object::id(collection),
            receiver,
            sequence_number,
            option::none(),
            vec_map::empty(),
            ctx,
        );

        // Add the drop to the drops registry
        table::add(&mut drops_registry.drops, sequence_number, object::id(&drop));
        transfer::public_transfer(drop, tx_context::sender(ctx));
    }
}
