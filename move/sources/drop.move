module drops::drop {

    use std::string::String;
    use sui::vec_map::{VecMap};
    use sui::display;
    use sui::package;
    use sui::event;
    use drops::helpers::{with_base_url};
    use sui::table::{Self, Table};

    // === Registry Structs ===
    
    /// Registry to track drops owned by an address, grouped by collection
    /// address → (collection_id → vector<ID>)
    public struct AddressDropsRegistry has key {
        id: UID,
        drops: Table<address, Table<ID, vector<ID>>>
    }

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
        receiver: address,
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
        // Create and share the address drops registry
        let address_drops_registry = AddressDropsRegistry {
            id: object::new(ctx),
            drops: table::new<address, Table<ID, vector<ID>>>(ctx),
        };
        transfer::share_object(address_drops_registry);

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
        address_drops_registry: &mut AddressDropsRegistry,
        collection_id: ID,
        receiver: address,
        sequence_number: u64,
        randomness: Option<u16>,
        attributes: VecMap<String, vector<u8>>,
        ctx: &mut TxContext
    ): Drop {
        // 1. Create the drop
        let drop = Drop {
            id: object::new(ctx),
            collection_id,
            sequence_number,
            mint_timestamp: tx_context::epoch(ctx),
            randomness: randomness,
            attributes,
        };

        // 2. Add the drop to the AddressDrops registry

        // Get the table of <collection_id, vector<ID>> for the address
        let drops_of_address = &mut address_drops_registry.drops;

        // If address has no drops for this collection, create a new table
        if (!table::contains(drops_of_address, receiver)) {
            table::add(drops_of_address, receiver, table::new<ID, vector<ID>>(ctx));
        };

        // Add the drop to the receiver's drops vector for the collection
        let drops_of_address_by_collection = table::borrow_mut(drops_of_address, receiver);
        let drops_vector = table::borrow_mut(drops_of_address_by_collection, collection_id);
        drops_vector.push_back(object::id(&drop));

        // 3. Emit mint event
        event::emit(DropMintedEvent {
            drop_id: object::id(&drop),
            collection_id,
            minter: tx_context::sender(ctx),
            receiver: receiver,
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