/// Module: drops
module drops::drops {

    use sui::object::{Self, UID};
    use std::string::String;
    use sui::url::Url;
    use sui::dynamic_field;
    use sui::vec_map::{Self, VecMap};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /*
    Collection Flags (u16 bits):
    0:      SOULBOUND               - NFTs cannot be transferred
    1-15:                           - Reserved for future use
    */

    /// Error codes for various failure conditions
    const E_NOT_AUTHORIZED: u64 = 0;
    const E_COLLECTION_EXISTS: u64 = 1;
    const E_COLLECTION_NOT_FOUND: u64 = 2;
    const E_MAX_SUPPLY_REACHED: u64 = 3;
    const E_INVALID_MINT_TIME: u64 = 4;
    const E_TRANSFER_LOCKED: u64 = 5;

    /// Global registry of all collections - shared object
    public struct CollectionsRegistry has key {
        id: UID,
        collection_count: u64,
        /// Maps collection names to their Collection objects
        collections: Table<u64, UID>,  // sequence_number -> collection_id
    }

    /// Registry for drops - shared object
    public struct DropsRegistry has key {
        id: UID,
        collection_id: UID,
        drops: Table<u64, UID>,  // sequence_number -> drop_id
    }

    /// Collection struct - represents a set of drops (NFTs)
    public struct Collection has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
        image_url: Url,
        project_url: Url,
        flags: u8,
        max_supply: Option<u32>,
        mint_start_time: u64,
        mint_stop_time: Option<u64>,
        current_supply: u32
    }

    /// Individual drop struct - represents a single NFT token
    public struct Drop has key, store {
        id: UID,
        collection_id: UID,
        sequence_number: u64,
        mint_timestamp: u64,
        attributes: VecMap<String, vector<u8>>
    }

    // === Functions ===

    /// Initialize the module - create the collections registry
    fun init(ctx: &mut TxContext) {
        // Create and share the collections registry
        let collections_registry = CollectionsRegistry {
            id: object::new(ctx),
            collections: table::new(ctx)
        };
        transfer::share_object(collections_registry);
    }
}