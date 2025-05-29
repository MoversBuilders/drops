module drops::drop {

    use std::string::String;
    use sui::vec_map::{VecMap};
    use sui::display;
    use sui::package;
    use sui::event;
    use drops::helpers::{with_base_url};

    // === Object Structs ===

    /// Individual drop struct - represents a single drop NFT token
    public struct Drop has key, store {
        id: UID,                                // Unique object ID
        collection_id: ID,                      // Parent collection
        sequence_number: u64,                   // Drop's sequence number in collection
        mint_timestamp: u64,                    // Minting timestamp (unix)
        randomness: Option<u16>,                // Optional on-chain randomness
        attributes: VecMap<String, vector<u8>>, // Arbitrary attributes (key-value)
    }

    /// One-Time-Witness for the module
    public struct DROP has drop {}

    /// Event emitted when a new drop is minted
    public struct DropMintedEvent has copy, drop {
        drop_id: ID,
        collection_id: ID,
        minter: address,
        timestamp: u64
    }

    /// Event emitted when a drop is transferred
    public struct DropTransferredEvent has copy, drop {
        drop_id: ID,
        from: address,
        to: address,
        timestamp: u64
    }

    // === Functions ===

    /// Initialize the drop module
    fun init(otw: DROP, ctx: &mut TxContext) {
        // Create display for Drop type
        let publisher = package::claim(otw, ctx);
        let keys = vector[
            b"id".to_string(),
            b"collection_id".to_string(),
            b"sequence_number".to_string(),
            b"mint_timestamp".to_string(),
            b"randomness".to_string(),
            b"attributes".to_string(),
            b"url".to_string(),
            b"image_url".to_string(),
            b"project_url".to_string(),
            b"creator".to_string(),
        ];

        let values = vector[
            b"{id}".to_string(),
            b"{collection_id}".to_string(),
            b"{sequence_number}".to_string(),
            b"{mint_timestamp}".to_string(),
            b"{randomness}".to_string(),
            b"{attributes}".to_string(),
            with_base_url(b"/drop/{id}".to_string()),
            with_base_url(b"/drop/img/{id}".to_string()),
            with_base_url(b"/collection/{collection_id}".to_string()),
            b"{collection_id}".to_string(),
        ];

        let mut display = display::new_with_fields<Drop>(
            &publisher, keys, values, ctx
        );

        // Commit first version of Display to apply changes.
        display::update_version(&mut display);

        // Transfer publisher and display to deployer
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    /// Mint a new drop
    public(package) fun mint(
        collection_id: ID,
        sequence_number: u64,
        randomness: Option<u16>,
        attributes: VecMap<String, vector<u8>>,
        ctx: &mut TxContext
    ): Drop {
        let drop = Drop {
            id: object::new(ctx),
            collection_id,
            sequence_number,
            mint_timestamp: tx_context::epoch(ctx),
            randomness: randomness,
            attributes,
        };

        // Emit mint event
        event::emit(DropMintedEvent {
            drop_id: object::id(&drop),
            collection_id,
            minter: tx_context::sender(ctx),
            timestamp: tx_context::epoch(ctx)
        });

        drop
    }

    /// Transfer a drop to a new owner
    /// Checks are done in the collection module
    public(package) fun transfer(
        drop: Drop,
        new_owner: address,
        ctx: &mut TxContext
    ) {
        let old_owner = object::uid_to_address(&drop.id);

        // Emit transfer event
        event::emit(DropTransferredEvent {
            drop_id: object::id(&drop),
            from: old_owner,
            to: new_owner,
            timestamp: tx_context::epoch(ctx)
        });

        // Transfer the drop
        transfer::public_transfer(drop, new_owner);
    }
}