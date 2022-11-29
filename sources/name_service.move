module name_service::metadata {
    use std::string::String;

    friend name_service::name_service_v0_3;

    struct Metadata has drop, store, copy {
        expiration_date: u64,
        name: String,
        record_keys: vector<String>,
        record_values: vector<String>,
    }

    public(friend) fun new(
        expiration_date: u64,
        name: String,
        record_keys: vector<String>,
        record_values: vector<String>,
    ): Metadata {
        Metadata {
            expiration_date,
            name,
            record_keys,
            record_values,
        }
    }

    public(friend) fun update_expiration_date(
        metadata: &mut Metadata,
        new_expiration_date: u64,
    ) {
        metadata.expiration_date = new_expiration_date;
    }

    public fun get_expiration_date(metadata: &Metadata): u64 {
        metadata.expiration_date
    }
}

module name_service::name_service {
    use std::error;
    use std::string::{Self, String};
    use std::signer;
    use std::vector;

    use initia_std::block;
    use initia_std::coin::{Self, Coin};
    use initia_std::decimal;
    use initia_std::native_uinit;
    use initia_std::option::{Self, Option};
    use initia_std::table::{Self, Table};

    use name_service::metadata::{Self, Metadata};
    use name_service::nft;

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

    /// invalid charactor
    const EINVALID_CHARACTOR: u64 = 6;

    /// not an owner of the token
    const ENOT_OWNER: u64 = 7;

    /// token is expired
    const ETOKEN_EXPIRED: u64 = 8;

    /// token id not found
    const ETOKEN_ID_NOT_FOUND: u64 = 9;

    /// name not found
    const ENAME_NOT_FOUND: u64 = 10;

    ///  address not found
    const EADDRESS_NOT_FOUND: u64 = 11;

    /// constants
    const YEAR_TO_SECOND: u64 = 31557600; // 365.25 * 24 * 60 * 60

    const TLD: vector<u8> =b".init";

    struct ModuleStore has key {
        name_to_id: Table<String, String>,

        name_to_addr: Table<String, address>,

        addr_to_name: Table<address, String>,

        mint_cap: nft::MintCapability<Metadata>,

        pool: Coin<native_uinit::Coin>,

        config: Config,
    }

    struct Config has store {
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,

        min_duration: u64,

        grace_period: u64,

        base_uri: String,
    }

    public entry fun get_valid_token_id(domain_name: String): String acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);
        assert!(table::contains(&module_store.name_to_id, domain_name), error::not_found(ETOKEN_ID_NOT_FOUND));
        let token_id = *table::borrow(&module_store.name_to_id, domain_name);

        token_id
    }

    public entry fun get_name_from_address(addr: address): String acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);
        assert!(table::contains(&module_store.addr_to_name, addr), error::not_found(ENAME_NOT_FOUND));
        let domain_name = *table::borrow(&module_store.addr_to_name, addr);

        domain_name
    }

    public entry fun get_address_from_name(name: String): address acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@name_service);
        assert!(table::contains(&module_store.name_to_addr, name), error::not_found(EADDRESS_NOT_FOUND));
        let addr = *table::borrow(&module_store.name_to_addr, name);

        addr
    }

    /// return (price_per_year_3char, price_per_year_4char, price_per_year_default, min_duration, grace_period, base_uri)
    public entry fun get_config(): (u64, u64, u64, u64, u64, String) acquires ModuleStore {
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

    /// Initialize, Make global store
    public entry fun initialize(
        chain: &signer,
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,
        min_duration: u64,
        grace_period: u64,
        base_uri: String,
    ) {
        assert!(signer::address_of(chain) == @name_service, error::invalid_argument(EUNAUTHORIZED));
        assert!(!exists<ModuleStore>(@name_service), error::already_exists(EMODULE_STORE_ALREADY_PUBLISHED));

        let mint_cap = nft::make_collection<Metadata>(
            chain,
            string::utf8(b"Initia Name Service"),
            string::utf8(b"INS"),
            true,
        );

        move_to(
            chain,
            ModuleStore {
                name_to_id: table::new(chain),
                name_to_addr: table::new(chain),
                addr_to_name: table::new(chain),
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

    public entry fun register_domain(
        account: &signer,
        domain_name: String,
        duration: u64,
    ) acquires ModuleStore {
        let addr = signer::address_of(account);
        // check expiration
        let module_store = borrow_global_mut<ModuleStore>(@name_service);

        let (_height, timestamp) = block::get_block_info();

        if (table::contains(&module_store.name_to_id, domain_name)) {
            let token_id = *table::borrow(&module_store.name_to_id, domain_name);
            let nft_info = nft::get_token_info<Metadata>(token_id);
            let extension = nft::get_extension_from_token_info_response<Metadata>(&nft_info);
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
        nft::mint(account, addr, token_id, token_uri, extension, &module_store.mint_cap,);
        table::add(&mut module_store.name_to_id, domain_name, token_id);

        let cost_amount = get_cost_amount(domain_name, duration);

        let module_store = borrow_global_mut<ModuleStore>(@name_service);

        let cost = coin::withdraw<native_uinit::Coin>(account, (cost_amount as u64));

        coin::merge(&mut module_store.pool, cost);
    }

    public entry fun set_name(
        account: &signer,
        domain_name: String,
    ) acquires ModuleStore {
        let addr = signer::address_of(account);
        let (_height, timestamp) = block::get_block_info();

        let module_store = borrow_global_mut<ModuleStore>(@name_service);
        let token_id = *table::borrow(&module_store.name_to_id, domain_name);
        assert!(nft::contains<Metadata>(addr, token_id), error::permission_denied(ENOT_OWNER));

        let nft_info = nft::get_token_info<Metadata>(token_id);
        let extension = nft::get_extension_from_token_info_response<Metadata>(&nft_info);
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
    }

    public entry fun extend_expiration(
        account: &signer,
        domain_name: String,
        duration: u64,
    ) acquires ModuleStore {
        let module_store = borrow_global_mut<ModuleStore>(@name_service);
        let token_id = *table::borrow(&module_store.name_to_id, domain_name);
        let nft_info = nft::get_token_info<Metadata>(token_id);
        let extension = nft::get_extension_from_token_info_response<Metadata>(&nft_info);

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
    }

    fun check_name(name: String) {
        let bytes = string::bytes(&name);
        let len = vector::length(bytes);
        assert!(len >= 3, error::invalid_argument(EMIN_NAME_LENGTH));
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

        (decimal::mul(
            &decimal::from_ratio((duration as u128), (YEAR_TO_SECOND as u128)),
            (price_per_year as u128),
        ) as u64)
    }

    #[test(chain = @0x1, source = @name_service, user1 = @0x2, user2 = @0x3)]
    fun end_to_end(
        chain: signer,
        source: signer,
        user1: signer,
        user2: signer,
    ) acquires ModuleStore {
        coin::initialize_for_chain<native_uinit::Coin>(
            &chain,
            std::string::utf8(b"name"),
            std::string::utf8(b"SYMBOL"),
            6
        );

        let addr1 = signer::address_of(&user1);
        let addr2 = signer::address_of(&user2);
        coin::mint_to_for_chain<native_uinit::Coin>(&chain, addr1, 100);
        coin::mint_to_for_chain<native_uinit::Coin>(&chain, addr2, 100);

        initialize(
            &source,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
        );

        nft::register<Metadata>(&user1);
        nft::register<Metadata>(&user2);

        std::unit_test::set_block_info_for_testing(100, 100);

        register_domain(&user1, string::utf8(b"abc"), 31557600);
        assert!(coin::balance<native_uinit::Coin>(addr1) == 90, 0);

        register_domain(&user1, string::utf8(b"abcd"), 31557600);
        assert!(coin::balance<native_uinit::Coin>(addr1) == 85, 0);

        register_domain(&user1, string::utf8(b"abcde"), 31557600);
        assert!(coin::balance<native_uinit::Coin>(addr1) == 84, 0);

        register_domain(&user1, string::utf8(b"abcdefghijk"), 31557600);
        assert!(coin::balance<native_uinit::Coin>(addr1) == 83, 0);

        assert!(
            get_valid_token_id(string::utf8(b"abc")) 
                == string::utf8(b"abc:100"),
            0,
        );

        set_name(&user1, string::utf8(b"abcd"));
        assert!(get_name_from_address(addr1) == string::utf8(b"abcd"), 0);
        assert!(get_address_from_name(string::utf8(b"abcd")) == addr1, 0);

        set_name(&user1, string::utf8(b"abc"));
        assert!(get_name_from_address(addr1) == string::utf8(b"abc"), 0);
        assert!(get_address_from_name(string::utf8(b"abc")) == addr1, 0);

        extend_expiration(&user1, string::utf8(b"abcd"), 31557600);
        assert!(coin::balance<native_uinit::Coin>(addr1) == 78, 0);

        std::unit_test::set_block_info_for_testing(200, 100 + 31557600 + 1209600 + 1);
        register_domain(&user2, string::utf8(b"abc"), 31557600);

        set_name(&user2, string::utf8(b"abc"));
        assert!(get_name_from_address(addr2) == string::utf8(b"abc"), 0);
        assert!(get_address_from_name(string::utf8(b"abc")) == addr2, 0);

        set_name(&user1, string::utf8(b"abcd"));
        assert!(get_name_from_address(addr1) == string::utf8(b"abcd"), 0);
        assert!(get_address_from_name(string::utf8(b"abcd")) == addr1, 0);
    }
}
