module drops::drop {

    use sui::object::{Self, UID};
    use std::string::String;
    use sui::url::Url;
    use sui::vec_map::{Self, VecMap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// Registry for drops in a collection (shared object)
    public struct DropsRegistry has key {
        id: UID,                                // Unique object ID
        drops: vector<ID>,                      // All drop IDs; index = sequence_number
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
}