module name_service::name_service {
    use std::error;
    use std::event::{Self, EventHandle};
    use std::string::{Self, String};
    use std::signer;
    use std::vector;

    use initia_std::block;    
    use initia_std::coin::{Self, Coin};
    use initia_std::decimal128;
    use initia_std::dex;
    use initia_std::native_uinit;
    use initia_std::nft;
    use initia_std::option::{Self, Option};
    use initia_std::table::{Self, Table};

    use name_service::metadata::{Self, Metadata};

    /// Only chain can execute.
    const EUNAUTHORIZED: u64 = 0;

    /// module store already exist.
    const EMODULE_STORE_ALREADY_PUBLISHED: u64 = 1;

    /// duration must be bigger than min_duration
    const EMIN_DURATION: u64 = 3;

    /// name already taken
    const EDOMAIN_NAME_ALREADY_EXISTS: u64 = 4;

    /// name length must be more bigger than or equal to 3
    const EMIN_NAME_LENGTH: u64 = 5;

    /// name length must be more bigger than or equal to 3
    const EMAX_NAME_LENGTH: u64 = 6;

    /// invalid charactor
    const EINVALID_CHARACTOR: u64 = 7;

    /// not an owner of the token
    const ENOT_OWNER: u64 = 8;

    /// token is expired
    const ETOKEN_EXPIRED: u64 = 9;

    /// token id not found
    const ETOKEN_ID_NOT_FOUND: u64 = 10;

    /// name not found
    const ENAME_NOT_FOUND: u64 = 11;

    ///  address not found
    const EADDRESS_NOT_FOUND: u64 = 12;

    const EEVENT_STORE_ALREADY_PUBLISHED: u64 = 13;
    const EEVENT_STORE_NOT_PUBLISHED: u64 = 14;

    /// constants
    const YEAR_TO_SECOND: u64 = 31557600; // 365.25 * 24 * 60 * 60

    const TLD: vector<u8> =b".init";

    const MAX_LENGTH: u64 = 1000;

    struct ModuleStore has key {
        name_to_id: Table<String, String>,

        name_to_addr: Table<String, address>,

        addr_to_name: Table<address, String>,

        mint_cap: nft::Capability<Metadata>,

        pool: Coin<native_uinit::Coin>,

        config: Config,
    }

    struct Events has key {
        register_events: EventHandle<RegisterEvent>,
        unset_events: EventHandle<UnsetEvent>,
        set_events: EventHandle<SetEvent>,
        extend_events: EventHandle<ExtendEvent>,
        update_records_events: EventHandle<UpdateRecordsEvent>,
        delete_records_events: EventHandle<DeleteRecordsEvent>,
    }

    struct RegisterEvent has drop, store {
        domain_name: String,
        token_id: String,
        expiration_date: u64,
    }

    struct UnsetEvent has drop, store {
        domain_name: String,
    }

    struct SetEvent has drop, store {
        domain_name: String,
    }

    struct ExtendEvent has drop, store {
        domain_name: String,
        expiration_date: u64,
    }

    struct UpdateRecordsEvent has drop, store {
        domain_name: String,
        keys: vector<String>,
        values: vector<String>,
    }

    struct DeleteRecordsEvent has drop, store {
        domain_name: String,
        keys: vector<String>,
    }

    struct Config has store {
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,
        min_duration: u64,
        grace_period: u64,
        base_uri: String,
    }

    struct ConfigResponse has drop {
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,
        min_duration: u64,
        grace_period: u64,
        base_uri: String,
    }

    #[view]
    public fun get_valid_token_id(domain_name: String): Option<String> acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);
        let id = if (table::contains(&module_store.name_to_id, domain_name)) {
            option::some(*table::borrow(&module_store.name_to_id, domain_name))
        } else {
            option::none()
        };

        id
    }

    #[view]
    public fun get_name_from_address(addr: address): Option<String> acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);
        let name = if (table::contains(&module_store.addr_to_name, addr)) {
            let name = *table::borrow(&module_store.addr_to_name, addr);
            if (is_expired(name)) {
                option::none()
            } else {
                option::some(name)
            }
        } else {
            option::none()
        };

        name
    }

    #[view]
    public fun get_address_from_name(name: String): Option<address> acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);
        let addr = if (table::contains(&module_store.name_to_addr, name)) {
            if (is_expired(name)) {
                option::none()
            } else {
                let module_store = borrow_global<ModuleStore>(@name_service);
                option::some(*table::borrow(&module_store.name_to_addr, name))
            }
        } else {
            option::none()
        };

        addr
    }

    #[view]
    public fun get_config(): ConfigResponse acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);

        ConfigResponse {
            price_per_year_3char: module_store.config.price_per_year_3char,
            price_per_year_4char: module_store.config.price_per_year_4char,
            price_per_year_default: module_store.config.price_per_year_default,
            min_duration: module_store.config.min_duration,
            grace_period: module_store.config.grace_period,
            base_uri: module_store.config.base_uri,
        }
    }

    #[view]
    public fun get_init_cost(domain_name: String, duration: u64): u64 acquires ModuleStore {
        get_cost_amount(domain_name, duration)
    }

    /// return (price_per_year_3char, price_per_year_4char, price_per_year_default, min_duration, grace_period, base_uri)
    public fun get_config_params(): (u64, u64, u64, u64, u64, String) acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);

        (
            module_store.config.price_per_year_3char,
            module_store.config.price_per_year_4char,
            module_store.config.price_per_year_default,
            module_store.config.min_duration,
            module_store.config.grace_period,
            module_store.config.base_uri,
        )
    }

    public entry fun is_event_store_published(account_addr: address): bool {
        exists<Events>(account_addr)
    }

    /// Initialize, Make global store
    public entry fun initialize(
        chain: &signer,
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,
        min_duration: u64,
        grace_period: u64,
        base_uri: String,
        collection_uri: String,
    ) {
        assert!(signer::address_of(chain) == @name_service, error::invalid_argument(EUNAUTHORIZED));
        assert!(!exists<ModuleStore>(@name_service), error::already_exists(EMODULE_STORE_ALREADY_PUBLISHED));

        let mint_cap = nft::make_collection<Metadata>(
            chain,
            string::utf8(b"Initia Name Service"),
            string::utf8(b"INS"),
            collection_uri,
            true,
        );

        move_to(
            chain,
            ModuleStore {
                name_to_id: table::new(),
                name_to_addr: table::new(),
                addr_to_name: table::new(),
                mint_cap,
                pool: coin::zero(),
                config: Config {
                    price_per_year_3char,
                    price_per_year_4char,
                    price_per_year_default,
                    min_duration,
                    grace_period,
                    base_uri,
                },
            },
        );
    }

    public entry fun update_config(
        chain: &signer,
        price_per_year_3char: Option<u64>,
        price_per_year_4char: Option<u64>,
        price_per_year_default: Option<u64>,
        min_duration: Option<u64>,
        grace_period: Option<u64>,
        base_uri: Option<String>,
    ) acquires ModuleStore {
        assert!(signer::address_of(chain) == @name_service, error::invalid_argument(EUNAUTHORIZED));

        let module_store = borrow_global_mut<ModuleStore>(@name_service);

        if (option::is_some(&price_per_year_3char)) {
            module_store.config.price_per_year_3char = option::extract(&mut price_per_year_3char);
        };

        if (option::is_some(&price_per_year_4char)) {
            module_store.config.price_per_year_4char = option::extract(&mut price_per_year_4char);
        };

        if (option::is_some(&price_per_year_default)) {
            module_store.config.price_per_year_default = option::extract(&mut price_per_year_default);
        };

        if (option::is_some(&min_duration)) {
            module_store.config.min_duration = option::extract(&mut min_duration);
        };

        if (option::is_some(&grace_period)) {
            module_store.config.grace_period = option::extract(&mut grace_period);
        };

        if (option::is_some(&base_uri)) {
            module_store.config.base_uri = option::extract(&mut base_uri);
        };
    }

    public entry fun publish_event_store(
        account: &signer,
    ) {
        let account_addr = signer::address_of(account);
        assert!(
            !is_event_store_published(account_addr),
            error::already_exists(EEVENT_STORE_ALREADY_PUBLISHED),
        );

        let evnet_store = Events {
            register_events: event::new_event_handle<RegisterEvent>(account),
            unset_events: event::new_event_handle<UnsetEvent>(account),
            set_events: event::new_event_handle<SetEvent>(account),
            extend_events: event::new_event_handle<ExtendEvent>(account),
            update_records_events: event::new_event_handle<UpdateRecordsEvent>(account),
            delete_records_events: event::new_event_handle<DeleteRecordsEvent>(account),
        };
        move_to(account, evnet_store);
    }

    public entry fun register_domain(
        account: &signer,
        domain_name: String,
        duration: u64,
    ) acquires Events, ModuleStore {
        let addr = signer::address_of(account);
        assert!(
            is_event_store_published(addr),
            error::not_found(EEVENT_STORE_NOT_PUBLISHED),
        );

        if (!nft::is_account_registered<Metadata>(addr)) {
            nft::register<Metadata>(account);
        };

        let event_store = borrow_global_mut<Events>(addr);

        // check expiration
        let module_store = borrow_global_mut<ModuleStore>(@name_service);

        let (_height, timestamp) = block::get_block_info();

        domain_name = to_lower_case(&domain_name);

        if (table::contains(&module_store.name_to_id, domain_name)) {
            let token_id = *table::borrow(&module_store.name_to_id, domain_name);
            let nft_info = nft::get_nft_info<Metadata>(token_id);
            let extension = nft::get_extension_from_nft_info_response<Metadata>(&nft_info);
            let expiration_date = metadata::get_expiration_date(&extension);

            assert!(
                duration >= module_store.config.min_duration,
                error::invalid_argument(EMIN_DURATION),
            );

            assert!(
                expiration_date + module_store.config.grace_period < timestamp,
                error::already_exists(EDOMAIN_NAME_ALREADY_EXISTS),
            );

            table::remove(&mut module_store.name_to_id, domain_name);
            
            nft::update_nft(
                token_id,
                option::none(),
                option::some(
                    metadata::new(
                        expiration_date,
                        string::utf8(b"INVALID"),
                        vector[],
                        vector[],
                    ),
                ),
                &module_store.mint_cap,
            )
        };

        let name = domain_name;
        check_name(name);
        string::append_utf8(&mut name, TLD);

        let extension = metadata::new(
            timestamp + duration,
            name,
            vector[],
            vector[],
        );

        let token_uri = module_store.config.base_uri;
        string::append(&mut token_uri, domain_name);
        let token_id = domain_name;
        string::append(&mut token_id, string::utf8(b":"));
        string::append(&mut token_id, u64_to_string(timestamp));
        let nft = nft::mint(account, token_id, token_uri, extension, &module_store.mint_cap);
        nft::deposit(addr, nft);
        table::add(&mut module_store.name_to_id, domain_name, token_id);

        let cost_amount = get_cost_amount(domain_name, duration);

        let module_store = borrow_global_mut<ModuleStore>(@name_service);

        let cost = coin::withdraw<native_uinit::Coin>(account, (cost_amount as u64));

        coin::merge(&mut module_store.pool, cost);

        event::emit_event<RegisterEvent>(
            &mut event_store.register_events,
            RegisterEvent {
                domain_name,
                token_id,
                expiration_date: timestamp + duration,
            },
        );
    }

    public entry fun unset_name(
        account: &signer,
    ) acquires Events, ModuleStore {
        let addr = signer::address_of(account);
        assert!(
            is_event_store_published(addr),
            error::not_found(EEVENT_STORE_NOT_PUBLISHED),
        );

        let event_store = borrow_global_mut<Events>(addr);

        let module_store = borrow_global_mut<ModuleStore>(@name_service);

        if (table::contains(&module_store.addr_to_name, addr)) {
            let removed_name = table::remove(&mut module_store.addr_to_name, addr);
            table::remove(&mut module_store.name_to_addr, removed_name);

            event::emit_event<UnsetEvent>(
                &mut event_store.unset_events,
                UnsetEvent {
                    domain_name: removed_name,
                },
            );
        };
    }

    public entry fun set_name(
        account: &signer,
        domain_name: String,
    ) acquires Events, ModuleStore {
        let addr = signer::address_of(account);
        assert!(
            is_event_store_published(addr),
            error::not_found(EEVENT_STORE_NOT_PUBLISHED),
        );

        let event_store = borrow_global_mut<Events>(addr);

        let (_height, timestamp) = block::get_block_info();
        domain_name = to_lower_case(&domain_name);

        let module_store = borrow_global_mut<ModuleStore>(@name_service);
        let token_id = *table::borrow(&module_store.name_to_id, domain_name);
        assert!(nft::contains<Metadata>(addr, token_id), error::permission_denied(ENOT_OWNER));

        let nft_info = nft::get_nft_info<Metadata>(token_id);
        let extension = nft::get_extension_from_nft_info_response<Metadata>(&nft_info);
        assert!(
            metadata::get_expiration_date(&extension) > timestamp,
            error::permission_denied(ETOKEN_EXPIRED),
        );

        if (table::contains(&module_store.name_to_addr, domain_name)) {
            let removed_addr = table::remove(&mut module_store.name_to_addr, domain_name);
            table::remove(&mut module_store.addr_to_name, removed_addr);
        };

        if (table::contains(&module_store.addr_to_name, addr)) {
            let removed_name = table::remove(&mut module_store.addr_to_name, addr);
            table::remove(&mut module_store.name_to_addr, removed_name);
        };

        table::add(&mut module_store.name_to_addr, domain_name, addr);
        table::add(&mut module_store.addr_to_name, addr, domain_name);

        event::emit_event<SetEvent>(
            &mut event_store.set_events,
            SetEvent {
                domain_name,
            },
        );
    }

    public entry fun extend_expiration(
        account: &signer,
        domain_name: String,
        duration: u64,
    ) acquires Events, ModuleStore {
        let addr = signer::address_of(account);
        assert!(
            is_event_store_published(addr),
            error::not_found(EEVENT_STORE_NOT_PUBLISHED),
        );

        let event_store = borrow_global_mut<Events>(addr);

        let module_store = borrow_global_mut<ModuleStore>(@name_service);
        domain_name = to_lower_case(&domain_name);
        let token_id = *table::borrow(&module_store.name_to_id, domain_name);
        let nft_info = nft::get_nft_info<Metadata>(token_id);
        let extension = nft::get_extension_from_nft_info_response<Metadata>(&nft_info);

        let (_height, timestamp) = block::get_block_info();
        let expiration_date = metadata::get_expiration_date(&extension);
        let new_expiration_date = if (expiration_date > timestamp) {
            expiration_date + duration
        } else {
            timestamp + duration
        };

        metadata::update_expiration_date(&mut extension, new_expiration_date);

        nft::update_nft<Metadata>(token_id, option::none(), option::some(extension), &module_store.mint_cap);

        let cost_amount = get_cost_amount(domain_name, duration);

        let module_store = borrow_global_mut<ModuleStore>(@name_service);

        let cost = coin::withdraw<native_uinit::Coin>(account, (cost_amount as u64));

        coin::merge(&mut module_store.pool, cost);

        event::emit_event<ExtendEvent>(
            &mut event_store.extend_events,
            ExtendEvent {
                domain_name,
                expiration_date: new_expiration_date,
            },
        );
    }

    public entry fun update_records(
        account: &signer,
        domain_name: String,
        record_keys: vector<String>,
        record_values: vector<String>,
    ) acquires Events, ModuleStore {
        let addr = signer::address_of(account);
        assert!(
            is_event_store_published(addr),
            error::not_found(EEVENT_STORE_NOT_PUBLISHED),
        );

        let event_store = borrow_global_mut<Events>(addr);
        let module_store = borrow_global_mut<ModuleStore>(@name_service);
        domain_name = to_lower_case(&domain_name);
        let token_id = *table::borrow(&module_store.name_to_id, domain_name);
        assert!(nft::contains<Metadata>(addr, token_id), error::permission_denied(ENOT_OWNER));

        let nft_info = nft::get_nft_info<Metadata>(token_id);
        let extension = nft::get_extension_from_nft_info_response<Metadata>(&nft_info);
        metadata::update_records(&mut extension, record_keys, record_values);

        nft::update_nft<Metadata>(token_id, option::none(), option::some(extension), &module_store.mint_cap);

        event::emit_event<UpdateRecordsEvent>(
            &mut event_store.update_records_events,
            UpdateRecordsEvent {
                domain_name,
                keys: record_keys,
                values: record_values,
            },
        );
    }

    public entry fun delete_records(
        account: &signer,
        domain_name: String,
        record_keys: vector<String>,
    ) acquires Events, ModuleStore {
        let addr = signer::address_of(account);
        assert!(
            is_event_store_published(addr),
            error::not_found(EEVENT_STORE_NOT_PUBLISHED),
        );

        let event_store = borrow_global_mut<Events>(addr);
        let module_store = borrow_global_mut<ModuleStore>(@name_service);
        domain_name = to_lower_case(&domain_name);
        let token_id = *table::borrow(&module_store.name_to_id, domain_name);
        assert!(nft::contains<Metadata>(addr, token_id), error::permission_denied(ENOT_OWNER));

        let nft_info = nft::get_nft_info<Metadata>(token_id);
        let extension = nft::get_extension_from_nft_info_response<Metadata>(&nft_info);

        metadata::delete_records(&mut extension, record_keys);

        nft::update_nft<Metadata>(token_id, option::none(), option::some(extension), &module_store.mint_cap);
        event::emit_event<DeleteRecordsEvent>(
            &mut event_store.delete_records_events,
            DeleteRecordsEvent {
                domain_name,
                keys: record_keys,
            },
        );
    }

    fun check_name(name: String) {
        let bytes = string::bytes(&name);
        let len = vector::length(bytes);
        assert!(len >= 3, error::invalid_argument(EMIN_NAME_LENGTH));
        assert!(len <= MAX_LENGTH, error::invalid_argument(EMIN_NAME_LENGTH));
        let index = 0;
        while (index < len) {
            let char = *vector::borrow(bytes, index);
            assert!(
                char == 45 || // -
                (char >= 48 && char <= 57) || // 0 ~ 9
                (char >= 65 && char <= 90) || // A ~ Z
                (char >= 97 && char <= 122), // a ~ z
                error::invalid_argument(EINVALID_CHARACTOR),
            );

            index = index + 1;
        }
    }

    fun u64_to_string(num: u64): String {
        let num = num;
        let bytes: vector<u8> = vector[];

        while (num > 0) {
            let remain = (num % 10 as u8);
            num = num / 10;
            vector::push_back(&mut bytes, 48 + remain);
        };

        vector::reverse(&mut bytes);

        string::utf8(bytes)
    }

    fun get_cost_amount(domain_name: String, duration: u64): u64 acquires ModuleStore {
        let module_store = borrow_global_mut<ModuleStore>(@name_service);
        let len = string::length(&domain_name);
        let price_per_year = if (len == 3) {
            module_store.config.price_per_year_3char
        } else if (len == 4) {
            module_store.config.price_per_year_4char
        } else {
            module_store.config.price_per_year_default
        };

        let spot_price = dex::get_spot_price<initia_std::native_uusdc::Coin>();

        let usd_value = (decimal128::mul(
            &decimal128::from_ratio((duration as u128), (YEAR_TO_SECOND as u128)),
            (price_per_year as u128),
        ) as u64);

        let decimal128_price = decimal128::from_ratio(
            (usd_value as u128),
            decimal128::val(&spot_price),
        );

        (decimal128::mul(&decimal128_price, decimal128::val(&decimal128::one())) as u64)
    }

    fun to_lower_case(str: &String): String {
        let bytes = *string::bytes(str);
        let len = vector::length(&bytes);
        let index = 0;
        while (index < len) {
            let char = vector::borrow_mut(&mut bytes, index);
            if (*char >= 65 && *char <= 90) {
                *char = *char + 32
            };
            index = index + 1;
        };

        return string::utf8(bytes)
    }

    fun is_expired(name: String): bool acquires ModuleStore {
        let token_id = get_valid_token_id(name);
        let nft_info = nft::get_nft_info<Metadata>(option::extract(&mut token_id));
        let extension = nft::get_extension_from_nft_info_response<Metadata>(&nft_info);
        let expiration_date = metadata::get_expiration_date(&extension);
        let (_height, timestamp) = block::get_block_info();
        timestamp > expiration_date
    }

//     // TODO fix test (tip. create pool, provide liquidity)
//     #[test(chain = @0x1, source = @name_service, user1 = @0x2, user2 = @0x3)]
//     fun end_to_end(
//         chain: signer,
//         source: signer,
//         user1: signer,
//         user2: signer,
//     ) acquires Events, ModuleStore {
//         coin::initialize_for_chain<native_uinit::Coin>(
//             &chain,
//             std::string::utf8(b"name"),
//             std::string::utf8(b"SYMBOL"),
//             6
//         );

//         let addr1 = signer::address_of(&user1);
//         let addr2 = signer::address_of(&user2);
//         coin::mint_to_for_chain<native_uinit::Coin>(&chain, addr1, 100);
//         coin::mint_to_for_chain<native_uinit::Coin>(&chain, addr2, 100);

//         initialize(
//             &source,
//             10,
//             5,
//             1,
//             1209600,
//             1209600,
//             string::utf8(b"https://test.com/"),
//         );

//         nft::register<Metadata>(&user1);
//         nft::register<Metadata>(&user2);

//         publish_event_store(&user1);
//         publish_event_store(&user2);

//         std::unit_test::set_block_info_for_testing(100, 100);

//         register_domain(&user1, string::utf8(b"abc"), 31557600);
//         assert!(coin::balance<native_uinit::Coin>(addr1) == 90, 0);

//         register_domain(&user1, string::utf8(b"abcd"), 31557600);
//         assert!(coin::balance<native_uinit::Coin>(addr1) == 85, 0);

//         register_domain(&user1, string::utf8(b"abcde"), 31557600);
//         assert!(coin::balance<native_uinit::Coin>(addr1) == 84, 0);

//         register_domain(&user1, string::utf8(b"abcdefghijk"), 31557600);
//         assert!(coin::balance<native_uinit::Coin>(addr1) == 83, 0);

//         assert!(
//             get_valid_token_id(string::utf8(b"abc")) 
//                 == string::utf8(b"abc:100"),
//             0,
//         );

//         set_name(&user1, string::utf8(b"abcd"));
//         assert!(get_name_from_address(addr1) == string::utf8(b"abcd"), 0);
//         assert!(get_address_from_name(string::utf8(b"abcd")) == addr1, 0);

//         set_name(&user1, string::utf8(b"abc"));
//         assert!(get_name_from_address(addr1) == string::utf8(b"abc"), 0);
//         assert!(get_address_from_name(string::utf8(b"abc")) == addr1, 0);

//         extend_expiration(&user1, string::utf8(b"abcd"), 31557600);
//         assert!(coin::balance<native_uinit::Coin>(addr1) == 78, 0);

//         std::unit_test::set_block_info_for_testing(200, 100 + 31557600 + 1209600 + 1);
//         register_domain(&user2, string::utf8(b"abc"), 31557600);

//         set_name(&user2, string::utf8(b"abc"));
//         assert!(get_name_from_address(addr2) == string::utf8(b"abc"), 0);
//         assert!(get_address_from_name(string::utf8(b"abc")) == addr2, 0);

//         set_name(&user1, string::utf8(b"abcd"));
//         assert!(get_name_from_address(addr1) == string::utf8(b"abcd"), 0);
//         assert!(get_address_from_name(string::utf8(b"abcd")) == addr1, 0);

//         update_records(
//             &user1,
//             string::utf8(b"abcd"),
//             vector[string::utf8(b"height"), string::utf8(b"weight")],
//             vector[string::utf8(b"190cm"), string::utf8(b"80kg")]
//         );

//         delete_records(
//              &user1,
//             string::utf8(b"abcd"),
//             vector[string::utf8(b"weight")],
//         )
//     }

//     #[test]
//     fun test_to_lower_case() {
//         let name = string::utf8(b"AbCd");
//         assert!(to_lower_case(&name) == string::utf8(b"abcd"), 0);
//     }
}

module initia_std::native_uusdc {
    struct Coin {}
}
