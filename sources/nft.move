module name_service::nft {
    use std::error;
    use std::event::{Self, EventHandle};
    use std::option::{Self, Option};
    use std::signer;
    use std::string::String;
    use std::vector;

    use initia_std::table::{Self, Table};
    use initia_std::type_info;

    //
    // Errors.
    //

    /// signer must be extension publisher
    const ETOKEN_ADDRESS_MISMATCH: u64 = 0;

    /// collection already exists
    const ECOLLECTION_ALREADY_EXISTS: u64 = 1;

    /// collection not found
    const ECOLLECTION_NOT_FOUND: u64 = 2;

    /// token store already exists
    const ETOKEN_STORE_ALREADY_EXISTS: u64 = 3;

    /// token store not found
    const ETOKEN_STORE_NOT_FOUND: u64 = 4;

    /// token_id is taken
    const ETOKEN_ID_ALREADY_EXISTS: u64 = 5;
    
    /// token_id not found
    const ETOKEN_ID_NOT_FOUND: u64 = 6;

    /// can not update nft that is_mutable is false
    const ENOT_MUTABLE: u64 = 7;

    /// can not query more than `MAX_LIMIT`
    const EMAX_LIMIT: u64 = 8;

    // constant

    /// Max length of query response
    const MAX_LIMIT: u8 = 30;

    // Data structures

    /// Capability required to mint nfts.
    struct MintCapability<phantom Extension: store + drop + copy> has copy, store { }

    /// Collection information
    struct Collection<Extension: store + drop + copy> has key {
        /// Name of the collection
        name: String,
        /// Symbol of the collection
        symbol: String,
        /// Total supply of NFT
        token_count: u64,
        /// Mutability of extension And token_uri
        is_mutable: bool,
        /// All token information
        tokens: Table<String, TokenInfo<Extension>>,

        update_events: EventHandle<UpdateEvent>,
    }

    /// The holder storage for specific nft collection 
    struct TokenStore<phantom Extension> has key {
        tokens: Table<String, Token<Extension>>,
        deposit_events: EventHandle<DepositEvent>,
        withdraw_events: EventHandle<WithdrawEvent>,
        mint_events: EventHandle<MintEvent>,
        burn_events: EventHandle<BurnEvent>,
    }

    /// Token Information
    struct TokenInfo<Extension: store + drop + copy> has store {
        token_id: String,
        token_uri: String,
        extension: Extension,
    }

    struct Token<phantom Extension> has store {
        token_id: String,
    }

    struct DepositEvent has drop, store {
        extension_type: String,
        token_id: String,
    }

    struct WithdrawEvent has drop, store {
        extension_type: String,
        token_id: String,
    }

    struct MintEvent has drop, store {
        extension_type: String,
        token_id: String,
    }

    struct BurnEvent has drop, store {
        extension_type: String,
        token_id: String,
    }

    struct UpdateEvent has drop, store {
        extension_type: String,
        token_id: String,
    }

    /// response structure for TokenInfo
    struct TokenInfoResponse<Extension> has drop {
        token_id: String,
        token_uri: String,
        extension: Extension,
    }

    ///
    /// Query entry functions(TODO)
    /// 

    /// Return true if `TokenStore` is published
    public entry fun is_account_registered<Extension: store + drop + copy>(addr: address): bool {
        exists<TokenStore<Extension>>(addr)
    }

    /// Return `token_id` existence
    public entry fun is_exists<Extension: store + drop + copy>(
        token_id: String
    ): bool acquires Collection {
        let creator = token_address<Extension>();

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        let collection = borrow_global<Collection<Extension>>(creator);

        table::contains<String, TokenInfo<Extension>>(&collection.tokens, token_id)
    }

    /// Return token_info
    public entry fun get_token_info<Extension: store + drop + copy>(
        token_id: String,
    ): TokenInfoResponse<Extension> acquires Collection {
        let creator = token_address<Extension>();

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        let collection = borrow_global<Collection<Extension>>(creator);
        
        assert!(
            table::contains<String, TokenInfo<Extension>>(&collection.tokens, token_id),
            error::not_found(ETOKEN_ID_NOT_FOUND),
        );

        let token_info = table::borrow<String, TokenInfo<Extension>>(&collection.tokens, token_id);

        TokenInfoResponse {
            token_id: token_info.token_id,
            token_uri: token_info.token_uri,
            extension: token_info.extension,
        }
    }

    /// Return token_info
    public entry fun get_token_infos<Extension: store + drop + copy>(
        token_ids: vector<String>,
    ): vector<TokenInfoResponse<Extension>> acquires Collection {
        let creator = token_address<Extension>();

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        assert!(
            vector::length(&token_ids) <= (MAX_LIMIT as u64),
            error::invalid_argument(EMAX_LIMIT),
        );

        let collection = borrow_global<Collection<Extension>>(creator);

        let res: vector<TokenInfoResponse<Extension>> = vector[];

        let index = 0;

        while (index < vector::length(&token_ids)) {
            let token_id = *vector::borrow(&token_ids, index);

            assert!(
                table::contains<String, TokenInfo<Extension>>(&collection.tokens, token_id),
                error::not_found(ETOKEN_ID_NOT_FOUND),
            );

            let token_info = table::borrow<String, TokenInfo<Extension>>(&collection.tokens, token_id);

            vector::push_back(
                &mut res,
                TokenInfoResponse {
                    token_id: token_info.token_id,
                    token_uri: token_info.token_uri,
                    extension: token_info.extension,
                },
            );

            index = index + 1;
        };

        res
    }

    /// get all `token_id`
    public entry fun all_token_ids<Extension: store + drop + copy>(
        start_after: Option<String>,
        limit: u8,
    ): vector<String> acquires Collection {
        let creator = token_address<Extension>();

        if (limit > MAX_LIMIT) {
            limit = MAX_LIMIT;
        };

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        let collection = borrow_global<Collection<Extension>>(creator);

        let token_info_iter = table::iter(
            &collection.tokens,
            option::none(),
            start_after,
            2,
        );

        let prepare = table::prepare<String, TokenInfo<Extension>>(&mut token_info_iter);
        let res: vector<String> = vector[];

        while (vector::length(&res) < (limit as u64) && prepare) {
            let (token_id, _token_info) = table::next<String, TokenInfo<Extension>>(&mut token_info_iter);
        
            vector::push_back(&mut res, token_id);
            prepare = table::prepare<String, TokenInfo<Extension>>(&mut token_info_iter);
        };

        res
    }

    /// get all `token_id` from `TokenStore` of user
    public entry fun token_ids<Extension: store + drop + copy>(
        owner: address,
        start_after: Option<String>,
        limit: u8,
    ): vector<String> acquires TokenStore {
        let creator = token_address<Extension>();

        if (limit > MAX_LIMIT) {
            limit = MAX_LIMIT;
        };

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        assert!(
            exists<TokenStore<Extension>>(owner),
            error::not_found(ETOKEN_STORE_NOT_FOUND),
        );

        let token_store = borrow_global_mut<TokenStore<Extension>>(owner);

        let tokens_iter = table::iter(
            &token_store.tokens,
            option::none(),
            start_after,
            2,
        );

        let prepare = table::prepare<String, Token<Extension>>(&mut tokens_iter);
        let res: vector<String> = vector[];

        while (vector::length(&res) < (limit as u64) && prepare) {
            let (token_id, _token) = table::next<String, TokenInfo<Extension>>(&mut tokens_iter);
        
            vector::push_back(&mut res, token_id);
            prepare = table::prepare<String, TokenInfo<Extension>>(&mut tokens_iter);
        };

        res
    }

    /// query helpers
    
    /// get `token_id` from `TokenInfoResponse`
    public fun get_token_id_from_token_info_response<Extension: store + drop + copy>(
        token_info_res: &TokenInfoResponse<Extension>,
    ): String {
        token_info_res.token_id
    }

    /// get `token_uri` from `TokenInfoResponse`
    public fun get_token_uri_from_token_info_response<Extension: store + drop + copy>(
        token_info_res: &TokenInfoResponse<Extension>,
    ): String {
        token_info_res.token_uri
    }

    /// get `extension` from `TokenInfoResponse`
    public fun get_extension_from_token_info_response<Extension: store + drop + copy>(
        token_info_res: &TokenInfoResponse<Extension>,
    ): Extension {
        token_info_res.extension
    }

    ///
    /// Execute entry functions
    /// 

    /// publish token store
    public entry fun register<Extension: store + drop + copy>(account: &signer) {
        assert!(
            !exists<TokenStore<Extension>>(signer::address_of(account)),
            error::not_found(ETOKEN_STORE_ALREADY_EXISTS),
        );

        let token_store = TokenStore<Extension> {
            tokens: table::new<String, Token<Extension>>(account),
            deposit_events: event::new_event_handle<DepositEvent>(account),
            withdraw_events: event::new_event_handle<WithdrawEvent>(account),
            mint_events: event::new_event_handle<MintEvent>(account),
            burn_events: event::new_event_handle<BurnEvent>(account),
        };

        move_to(account, token_store);
    }

    /// Burn token from token store
    public entry fun burn_script<Extension: store + drop + copy>(
        account: &signer, 
        token_id: String,
    ) acquires Collection, TokenStore {
        let creator = token_address<Extension>();
        let addr = signer::address_of(account);

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        assert!(
            exists<TokenStore<Extension>>(addr),
            error::not_found(ETOKEN_STORE_NOT_FOUND),
        );

        let collection = borrow_global_mut<Collection<Extension>>(creator);

        assert!(
            table::contains<String, TokenInfo<Extension>>(&collection.tokens, token_id),
            error::not_found(ETOKEN_ID_NOT_FOUND),
        );

        let token_store = borrow_global_mut<TokenStore<Extension>>(addr);

        assert!(
            table::contains<String, Token<Extension>>(&token_store.tokens, token_id),
            error::not_found(ETOKEN_ID_NOT_FOUND),
        );

        let token = table::remove<String, Token<Extension>>(&mut token_store.tokens, token_id);

        burn(token);

        event::emit_event<BurnEvent>(
            &mut token_store.burn_events,
            BurnEvent { token_id, extension_type: type_info::type_name<Extension>() },
        );
    }

    /// Transfer token from token store to another token store
    public entry fun transfer<Extension: store + drop + copy>(
        account: &signer,
        to: address,
        token_id: String,
    ) acquires TokenStore {
        let token = withdraw<Extension>(account, token_id);
        deposit<Extension>(to, token);
    }

    ///
    /// Public functions
    /// 

    /// Make a new collection
    public fun make_collection<Extension: store + drop + copy>(
        account: &signer,
        name: String,
        symbol: String,
        is_mutable: bool
    ): MintCapability<Extension> {
        let creator = signer::address_of(account);

        assert!(
            token_address<Extension>() == creator,
            error::invalid_argument(ETOKEN_ADDRESS_MISMATCH),
        );

        assert!(
            !exists<Collection<Extension>>(creator),
            error::already_exists(ECOLLECTION_ALREADY_EXISTS),
        );

        let collection = Collection<Extension>{
            name,
            symbol,
            token_count: 0,
            is_mutable,
            tokens: table::new<String, TokenInfo<Extension>>(account),
            update_events: event::new_event_handle<UpdateEvent>(account),
        };

        move_to(account, collection);

        MintCapability<Extension>{ }
    }

    /// Mint new token
    public fun mint<Extension: store + drop + copy>(
        _account: &signer,
        to: address, 
        token_id: String,
        token_uri: String,
        extension: Extension,
        _mint_capability: &MintCapability<Extension>,
    ) acquires Collection, TokenStore {
        let creator = token_address<Extension>();

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        assert!(
            exists<TokenStore<Extension>>(to),
            error::not_found(ETOKEN_STORE_NOT_FOUND),
        );

        let collection = borrow_global_mut<Collection<Extension>>(creator);

        collection.token_count = collection.token_count + 1;

        assert!(
            !table::contains<String, TokenInfo<Extension>>(&collection.tokens, token_id),
            error::already_exists(ETOKEN_ID_ALREADY_EXISTS),
        );

        let token_info = TokenInfo<Extension> { token_id, token_uri, extension };

        let token = Token<Extension> { token_id };

        table::add<String, TokenInfo<Extension>>(&mut collection.tokens, token_id, token_info);

        let token_store = borrow_global_mut<TokenStore<Extension>>(to);

        table::add<String, Token<Extension>>(&mut token_store.tokens, token_id, token);

        event::emit_event<MintEvent>(
            &mut token_store.mint_events,
            MintEvent { token_id, extension_type: type_info::type_name<Extension>() },
        );
    }

    /// update token_uri/extension
    public fun update_nft<Extension: store + drop + copy>(
        token_id: String,
        token_uri: Option<String>,
        extension: Option<Extension>,
        _mint_capability: &MintCapability<Extension>,
    ) acquires Collection {
        let creator = token_address<Extension>();

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        let collection = borrow_global_mut<Collection<Extension>>(creator);

        assert!(
            table::contains<String, TokenInfo<Extension>>(&collection.tokens, token_id),
            error::not_found(ETOKEN_ID_NOT_FOUND),
        );

        assert!(
            collection.is_mutable,
            error::permission_denied(ENOT_MUTABLE),
        );

        let token_info = table::borrow_mut<String, TokenInfo<Extension>>(&mut collection.tokens, token_id);

        if (option::is_some<String>(&token_uri)) {
            let new_token_uri = option::extract<String>(&mut token_uri);
            token_info.token_uri = new_token_uri;
        };

        if (option::is_some<Extension>(&extension)) {
            let new_extension = option::extract<Extension>(&mut extension);
            token_info.extension = new_extension;
        };

        event::emit_event<UpdateEvent>(
            &mut collection.update_events,
            UpdateEvent { token_id, extension_type: type_info::type_name<Extension>() },
        );
    }

    /// withdraw token from token_store
    public fun withdraw<Extension: store + drop + copy>(
        account: &signer, 
        token_id: String,
    ): Token<Extension> acquires TokenStore {
        let addr = signer::address_of(account);

        assert!(
            contains<Extension>(addr, token_id),
            error::not_found(ETOKEN_ID_NOT_FOUND),
        );

        let token_store = borrow_global_mut<TokenStore<Extension>>(addr);

        event::emit_event<WithdrawEvent>(
            &mut token_store.withdraw_events,
            WithdrawEvent { token_id, extension_type: type_info::type_name<Extension>() },
        );
        
        table::remove<String, Token<Extension>>(&mut token_store.tokens, token_id)
    }

    /// deposit token to token_store
    public fun deposit<Extension: store + drop + copy>(
        addr: address,
        token: Token<Extension>
    ) acquires TokenStore {
        let creator = token_address<Extension>();

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        assert!(
            exists<TokenStore<Extension>>(addr),
            error::not_found(ETOKEN_STORE_NOT_FOUND),
        );

        let token_store = borrow_global_mut<TokenStore<Extension>>(addr);

        event::emit_event<DepositEvent>(
            &mut token_store.deposit_events,
            DepositEvent { token_id: token.token_id, extension_type: type_info::type_name<Extension>() },
        );

        table::add<String, Token<Extension>>(&mut token_store.tokens, token.token_id, token); 
    }

    /// burn token
    public fun burn<Extension: store + drop + copy>(token: Token<Extension>) acquires Collection {
        let creator = token_address<Extension>();

        let collection = borrow_global_mut<Collection<Extension>>(creator);

        let Token { token_id } = token;

        let TokenInfo { token_id: _, token_uri: _, extension: _ } 
            = table::remove<String, TokenInfo<Extension>>(&mut collection.tokens, token_id);

        collection.token_count = collection.token_count - 1;
    }

    /// check `TokenStore` has certain `token_id`
    public fun contains<Extension: store + drop + copy>(
        addr: address,
        token_id: String,
    ): bool acquires TokenStore {
        let creator = token_address<Extension>();

        assert!(
            exists<Collection<Extension>>(creator),
            error::not_found(ECOLLECTION_NOT_FOUND),
        );

        assert!(
            exists<TokenStore<Extension>>(addr),
            error::not_found(ETOKEN_STORE_NOT_FOUND),
        );

        let token_store = borrow_global_mut<TokenStore<Extension>>(addr);

        table::contains<String, Token<Extension>>(&token_store.tokens, token_id)
    }

    fun token_address<Extension: store + drop + copy>(): address {
        let type_info = type_info::type_of<Extension>();
        type_info::account_address(&type_info)
    }

    #[test_only]
    use std::string;

    #[test_only]
    struct Metadata has store, drop, copy { 
        power: u64,
    }

    #[test_only]
    struct CapabilityStore has key { 
        mint_cap: MintCapability<Metadata>
    }

    #[test_only]
    fun make_collection_for_test(account: &signer): MintCapability<Metadata> {
        // make collection
        let name = string::utf8(b"Collection");
        let symbol = string::utf8(b"COL");
        let is_mutable = true;
        make_collection<Metadata>(
            account,
            name,
            symbol,
            is_mutable,
        )
    }

    #[test(source = @0x1, destination = @0x2)]
    fun end_to_end(
        source: signer,
        destination: signer,
    ) acquires Collection, TokenStore {
        let cap = make_collection_for_test(&source);
        let source_addr = signer::address_of(&source);
        let destination_addr = signer::address_of(&destination);

        let name = string::utf8(b"Collection");
        let symbol = string::utf8(b"COL");
        let is_mutable = true;

        // check collection
        let collection = borrow_global<Collection<Metadata>>(source_addr);
        assert!(collection.name == name, 0);
        assert!(collection.symbol == symbol, 1);
        assert!(collection.is_mutable == is_mutable, 2);
        assert!(collection.token_count == 0, 3);
        
        // register
        register<Metadata>(&source);
        register<Metadata>(&destination);

        let token_id = string::utf8(b"id:1");
        let token_uri = string::utf8(b"https://url.com");
        let extension = Metadata { power: 1234 };

        mint<Metadata>(
            &source,
            source_addr,
            token_id,
            token_uri,
            extension,
            &cap,
        );

        // check minted token
        let token_store = borrow_global<TokenStore<Metadata>>(source_addr);
        let token = table::borrow(&token_store.tokens, string::utf8(b"id:1"));

        assert!(token.token_id == token_id, 4);

        // check token_count
        let collection = borrow_global<Collection<Metadata>>(source_addr);

        assert!(collection.token_count == 1, 5);

        transfer<Metadata>(
            &source,
            destination_addr,
            string::utf8(b"id:1"),
        );
        // check transfered
        let token_store = borrow_global<TokenStore<Metadata>>(destination_addr);
        assert!(table::contains(&token_store.tokens, string::utf8(b"id:1")), 6);
        let token_store = borrow_global<TokenStore<Metadata>>(source_addr);
        assert!(!table::contains(&token_store.tokens, string::utf8(b"id:1")), 7);

        let token = withdraw<Metadata>(&destination, string::utf8(b"id:1"));
        // check withdrawn
        let token_store = borrow_global<TokenStore<Metadata>>(destination_addr);
        assert!(!table::contains(&token_store.tokens, string::utf8(b"id:1")), 8);

        let new_uri = string::utf8(b"https://new_url.com");
        let new_metadata = Metadata { power: 4321 };

        update_nft<Metadata>(
            string::utf8(b"id:1"),
            option::some<String>(new_uri),
            option::some<Metadata>(new_metadata),
            &cap,
        );

        // check token info
        let collection = borrow_global<Collection<Metadata>>(source_addr);
        let token_info = table::borrow(&collection.tokens, string::utf8(b"id:1"));

        assert!(token_info.token_uri == new_uri, 9);
        assert!(token_info.extension == new_metadata, 10);

        deposit<Metadata>(destination_addr, token);

        // check deposit
        let token_store = borrow_global<TokenStore<Metadata>>(destination_addr);
        assert!(table::contains(&token_store.tokens, string::utf8(b"id:1")), 11);

        burn_script<Metadata>(&destination, string::utf8(b"id:1"));

        let token_store = borrow_global<TokenStore<Metadata>>(destination_addr);
        assert!(!table::contains(&token_store.tokens, string::utf8(b"id:1")), 12);

        // check burn

        move_to (
            &source,
            CapabilityStore { mint_cap: cap },
        )
    }

    #[test(not_source = @0x2)]
    #[expected_failure(abort_code = 0x10000)]
    fun fail_make_collection_address_mismatch(not_source: signer): MintCapability<Metadata> {
        make_collection_for_test(&not_source)
    }

    #[test(source = @0x1)]
    #[expected_failure(abort_code = 0x80001)]
    fun fail_make_collection_collection_already_exists(
        source: signer
    ) {
        let cap_1 = make_collection_for_test(&source);

        let cap_2 = make_collection_for_test(&source);

        move_to (
            &source,
            CapabilityStore { mint_cap: cap_1 },
        );

        move_to (
            &source,
            CapabilityStore { mint_cap: cap_2 },
        )
    }

    #[test(source = @0x1)]
    #[expected_failure(abort_code = 0x60003)]
    fun fail_register(source: signer){
        register<Metadata>(&source);
        register<Metadata>(&source);
    }

    #[test(source = @0x1)]
    #[expected_failure(abort_code = 0x60002)]
    fun fail_mint_collection_not_found(source: signer) acquires Collection, TokenStore {
        // It is impossible to get MintCapability without make_collection, but somehow..
        let cap = MintCapability<Metadata>{ };
        let token_id = string::utf8(b"id:1");
        let token_uri = string::utf8(b"https://url.com");
        let extension = Metadata { power: 1234 };

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        move_to (
            &source,
            CapabilityStore { mint_cap: cap },
        )
    }

    #[test(source = @0x1)]
    #[expected_failure(abort_code = 0x60004)]
    fun fail_mint_token_store_not_found(source: signer) acquires Collection, TokenStore {
        let cap = make_collection_for_test(&source);

        let token_id = string::utf8(b"id:1");
        let token_uri = string::utf8(b"https://url.com");
        let extension = Metadata { power: 1234 };

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        move_to (
            &source,
            CapabilityStore { mint_cap: cap },
        )
    }

    #[test(source = @0x1)]
    #[expected_failure(abort_code = 0x80005)]
    fun fail_mint_token_id_exists(source: signer) acquires Collection, TokenStore {
        let cap = make_collection_for_test(&source);

        let token_id = string::utf8(b"id:1");
        let token_uri = string::utf8(b"https://url.com");
        let extension = Metadata { power: 1234 };

        register<Metadata>(&source);

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        move_to (
            &source,
            CapabilityStore { mint_cap: cap },
        )
    }

    #[test(source = @0x1)]
    #[expected_failure(abort_code = 0x50007)]
    fun fail_mutate_not_mutable(source: signer) acquires Collection, TokenStore {
        // make collection
        let name = string::utf8(b"Collection");
        let symbol = string::utf8(b"COL");
        let is_mutable = false;

        let cap = make_collection<Metadata>(
            &source,
            name,
            symbol,
            is_mutable,
        );

        let token_id = string::utf8(b"id:1");
        let token_uri = string::utf8(b"https://url.com");
        let extension = Metadata { power: 1234 };

        register<Metadata>(&source);

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        let new_uri = string::utf8(b"https://new_url.com");
        let new_metadata = Metadata { power: 4321 };

        update_nft<Metadata>(
            string::utf8(b"id:1"),
            option::some<String>(new_uri),
            option::some<Metadata>(new_metadata),
            &cap,
        );

        move_to (
            &source,
            CapabilityStore { mint_cap: cap },
        )
    }

    #[test(source = @0x1)]
    #[expected_failure(abort_code = 0x60006)]
    fun fail_mutate_token_id_not_found(source: signer) acquires Collection, TokenStore {
        let cap = make_collection_for_test(&source);

        let token_id = string::utf8(b"id:1");
        let token_uri = string::utf8(b"https://url.com");
        let extension = Metadata { power: 1234 };

        register<Metadata>(&source);

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        let new_uri = string::utf8(b"https://new_url.com");
        let new_metadata = Metadata { power: 4321 };

        update_nft<Metadata>(
            string::utf8(b"id:2"),
            option::some<String>(new_uri),
            option::some<Metadata>(new_metadata),
            &cap,
        );

        move_to (
            &source,
            CapabilityStore { mint_cap: cap },
        )
    }

    #[test(source = @0x1)]
    fun test_query_functions(source: signer) acquires Collection, TokenStore {
        let cap = make_collection_for_test(&source);
        let source_addr = signer::address_of(&source);

        assert!(!is_account_registered<Metadata>(source_addr), 0);

        register<Metadata>(&source);

        assert!(is_account_registered<Metadata>(source_addr), 1);

        let token_id = string::utf8(b"id:1");
        let token_uri = string::utf8(b"https://url.com/1/");
        let extension = Metadata { power: 1 };

        assert!(!is_exists<Metadata>(token_id), 2);

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        assert!(is_exists<Metadata>(token_id), 3);

        let token_info = get_token_info<Metadata>(token_id);
        assert!(
            token_info == TokenInfoResponse {
                token_id,
                token_uri,
                extension,
            },
            4,
        );

        let token_id = string::utf8(b"id:2");
        let token_uri = string::utf8(b"https://url.com/2/");
        let extension = Metadata { power: 2 };

        mint<Metadata>(
            &source,
            signer::address_of(&source),
            token_id,
            token_uri,
            extension,
            &cap,
        );

        let token_infos = get_token_infos<Metadata>(vector[string::utf8(b"id:1"), string::utf8(b"id:2")]);

        let token_info1 = vector::borrow(&token_infos, 0);
        let token_info2 = vector::borrow(&token_infos, 1);

        assert!(
            token_info1 == &TokenInfoResponse {
                token_id: string::utf8(b"id:1"),
                token_uri: string::utf8(b"https://url.com/1/"),
                extension: Metadata { power: 1 },
            },
            5,
        );

        assert!(
            token_info2 == &TokenInfoResponse {
                token_id: string::utf8(b"id:2"),
                token_uri: string::utf8(b"https://url.com/2/"),
                extension: Metadata { power: 2 },
            },
            6,
        );

        let token_ids = all_token_ids<Metadata>(option::none(), 10);

        assert!(token_ids == vector[string::utf8(b"id:2"), string::utf8(b"id:1")], 7);

        let token_ids = all_token_ids<Metadata>(option::none(), 1);

        assert!(token_ids == vector[string::utf8(b"id:2")], 8);

        let token_ids = all_token_ids<Metadata>(option::some(string::utf8(b"id:2")), 10);

        assert!(token_ids == vector[string::utf8(b"id:1")], 9);

        let token_ids = token_ids<Metadata>(signer::address_of(&source), option::none(), 10);

        assert!(token_ids == vector[string::utf8(b"id:2"), string::utf8(b"id:1")], 7);

        let token_ids = token_ids<Metadata>(signer::address_of(&source), option::none(), 1);

        assert!(token_ids == vector[string::utf8(b"id:2")], 8);

        let token_ids = token_ids<Metadata>(signer::address_of(&source), option::some(string::utf8(b"id:2")), 10);

        assert!(token_ids == vector[string::utf8(b"id:1")], 9);

        move_to (
            &source,
            CapabilityStore { mint_cap: cap },
        )
    }
}