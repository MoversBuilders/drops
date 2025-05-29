module drops::drop {

    use std::string::String;
    use sui::vec_map::{VecMap};
    use drops::collection::{Collection};

    /// Individual drop struct - represents a single drop NFT token
    public struct Drop has key, store {
        id: UID,                                // Unique object ID
        collection_id: ID,                      // Parent collection ID
        sequence_number: u32,                   // Drop's sequence number in collection
        mint_timestamp: u32,                    // Minting timestamp (unix)
        randomness: Option<u16>,                // Optional on-chain randomness
        attributes: VecMap<String, vector<u8>>, // Arbitrary attributes (key-value)
    }

    public(package) fun mint(
        collection: &Collection,
        sequence_number: u32,
        randomness: Option<u16>,
        attributes: VecMap<String, vector<u8>>,
        ctx: &mut TxContext
    ): Drop {
        Drop {
            id: object::new(ctx),
            collection_id: object::id(collection),
            sequence_number,
            mint_timestamp: (tx_context::epoch(ctx) as u32),
            randomness: randomness,
            attributes,
        }
    }
}