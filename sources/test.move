#[test_only]
module usernames::test {
    use std::string::{Self, String};
    use std::signer;

    use initia_std::block;
    use initia_std::coin;
    use initia_std::option;
    use initia_std::primary_fungible_store;
    use initia_std::object::{Self, Object};
    use initia_std::fungible_asset::{Metadata as CoinMetadata};

    use usernames::metadata::Metadata;

    const MAX_EXPIRATION: u64 = 315576000; // 10 years

    use usernames::usernames::{
        initialize,
        register_domain,
        get_valid_token,
        set_name,
        get_name_from_address,
        get_address_from_name,
        extend_expiration,
        update_records,
        delete_records,
        update_config,
        get_config_params
    };

    fun get_init_metadata(): Object<CoinMetadata> {
        let init_symbol = string::utf8(b"uinit");
        coin::metadata(@initia_std, init_symbol)
    }

    struct CoinCaps has key {
        burn_cap: coin::BurnCapability,
        freeze_cap: coin::FreezeCapability,
        mint_cap: coin::MintCapability
    }

    fun initialized_coin(
        account: &signer, symbol: String
    ): (coin::MintCapability, coin::BurnCapability, coin::FreezeCapability) {
        coin::initialize(
            account,
            option::none(),
            std::string::utf8(b"name"),
            symbol,
            6,
            string::utf8(b""),
            string::utf8(b"")
        )
    }

    fun test_setup(chain: &signer) {
        primary_fungible_store::init_module_for_test();
        let (initia_mint_cap, initia_burn_cap, initia_freeze_cap) =
            initialized_coin(chain, string::utf8(b"uinit"));

        move_to(
            chain,
            CoinCaps {
                burn_cap: initia_burn_cap,
                freeze_cap: initia_freeze_cap,
                mint_cap: initia_mint_cap
            }
        );
    }

    fun init_mint_to(chain_addr: address, account: &signer, amount: u64) acquires CoinCaps {
        let caps = borrow_global<CoinCaps>(chain_addr);
        primary_fungible_store::deposit(
            signer::address_of(account), coin::mint(&caps.mint_cap, amount)
        );
    }

    #[test(
        chain = @0x1, publisher = @usernames, user1 = @0x2, user2 = @0x3
    )]
    fun end_to_end(
        chain: signer,
        publisher: signer,
        user1: signer,
        user2: signer
    ) acquires CoinCaps {
        test_setup(&chain);
        let chain_addr = signer::address_of(&chain);
        let addr1 = signer::address_of(&user1);
        let addr2 = signer::address_of(&user2);
        init_mint_to(chain_addr, &user1, 100);
        init_mint_to(chain_addr, &user2, 100);

        initialize(
            &publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        std::block::set_block_info(100, 100);

        register_domain(&user1, string::utf8(b"abc"), 31557600);
        assert!(primary_fungible_store::balance(addr1, get_init_metadata()) == 90, 0);

        register_domain(&user1, string::utf8(b"abcd"), 31557600);
        assert!(primary_fungible_store::balance(addr1, get_init_metadata()) == 85, 0);

        register_domain(&user1, string::utf8(b"abcde"), 31557600);
        assert!(primary_fungible_store::balance(addr1, get_init_metadata()) == 84, 0);

        let token = *option::borrow(&get_valid_token(string::utf8(b"abc")));
        let token_object = object::address_to_object<Metadata>(token);
        assert!(
            initia_std::nft::token_id(token_object) == string::utf8(b"abc.init.100"), 0
        );

        set_name(&user1, string::utf8(b"abcd"));
        assert!(
            get_name_from_address(addr1) == option::some(string::utf8(b"abcd")),
            0
        );
        assert!(
            get_address_from_name(string::utf8(b"abcd")) == option::some(addr1),
            0
        );

        set_name(&user1, string::utf8(b"abc"));
        assert!(
            get_name_from_address(addr1) == option::some(string::utf8(b"abc")),
            0
        );
        assert!(
            get_address_from_name(string::utf8(b"abc")) == option::some(addr1),
            0
        );

        extend_expiration(&user1, string::utf8(b"abcd"), 31557600);
        assert!(primary_fungible_store::balance(addr1, get_init_metadata()) == 79, 0);

        // expired
        std::block::set_block_info(200, 100 + 31557600 + 1209600 + 1);
        register_domain(&user2, string::utf8(b"abc"), 31557600);

        // check record removed
        assert!(get_name_from_address(addr1) == option::none(), 0);
        assert!(
            get_address_from_name(string::utf8(b"abc")) == option::none(),
            0
        );

        set_name(&user2, string::utf8(b"abc"));
        assert!(
            get_name_from_address(addr2) == option::some(string::utf8(b"abc")),
            0
        );
        assert!(
            get_address_from_name(string::utf8(b"abc")) == option::some(addr2),
            0
        );

        set_name(&user1, string::utf8(b"abcd"));
        assert!(
            get_name_from_address(addr1) == option::some(string::utf8(b"abcd")),
            0
        );
        assert!(
            get_address_from_name(string::utf8(b"abcd")) == option::some(addr1),
            0
        );

        update_records(
            &user1,
            string::utf8(b"abcd"),
            vector[string::utf8(b"height"), string::utf8(b"weight")],
            vector[string::utf8(b"190cm"), string::utf8(b"80kg")]
        );

        delete_records(
            &user1,
            string::utf8(b"abcd"),
            vector[string::utf8(b"weight")]
        )
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    fun query_test(chain: signer, publisher: signer, user: signer) acquires CoinCaps {
        test_setup(&chain);
        let addr = signer::address_of(&user);
        init_mint_to(signer::address_of(&chain), &user, 100);

        initialize(
            &publisher,
            10,
            5,
            1,
            1000,
            1000,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        std::block::set_block_info(100, 100);

        // before register
        assert!(get_name_from_address(addr) == option::none(), 0);
        assert!(
            get_address_from_name(string::utf8(b"abcd")) == option::none(),
            1
        );
        assert!(
            get_valid_token(string::utf8(b"abcd")) == option::none(),
            2
        );

        register_domain(&user, string::utf8(b"abcd"), 1000);
        let token = *option::borrow(&get_valid_token(string::utf8(b"abcd")));
        let token_object = object::address_to_object<Metadata>(token);
        assert!(
            initia_std::nft::token_id(token_object) == string::utf8(b"abcd.init.100"),
            3
        );
        set_name(&user, string::utf8(b"abcd"));
        assert!(
            get_name_from_address(addr) == option::some(string::utf8(b"abcd")),
            4
        );
        assert!(
            get_address_from_name(string::utf8(b"abcd")) == option::some(addr),
            5
        );

        // after expired
        std::block::set_block_info(110, 1110);
        let token = *option::borrow(&get_valid_token(string::utf8(b"abcd")));
        let token_object = object::address_to_object<Metadata>(token);
        assert!(
            initia_std::nft::token_id(token_object) == string::utf8(b"abcd.init.100"),
            6
        );
        assert!(get_name_from_address(addr) == option::none(), 7);
        assert!(
            get_address_from_name(string::utf8(b"abcd")) == option::none(),
            8
        );

        // after extend
        extend_expiration(&user, string::utf8(b"abcd"), 1000);
        let token = *option::borrow(&get_valid_token(string::utf8(b"abcd")));
        let token_object = object::address_to_object<Metadata>(token);
        assert!(
            initia_std::nft::token_id(token_object) == string::utf8(b"abcd.init.100"),
            9
        );
        assert!(
            get_name_from_address(addr) == option::some(string::utf8(b"abcd")),
            10
        );
        assert!(
            get_address_from_name(string::utf8(b"abcd")) == option::some(addr),
            11
        );
    }

    #[test(chain = @0x1, publisher = @usernames)]
    #[expected_failure(abort_code = 0x10000, location = usernames::usernames)]
    fun test_initailze_unauthorized_fails(chain: &signer) {
        test_setup(chain);

        initialize(
            chain,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );
    }

    #[test(chain = @0x1, publisher = @usernames)]
    #[expected_failure(abort_code = 0x80001, location = usernames::usernames)]
    fun test_initailze_min_already_published_fails(
        chain: &signer, publisher: &signer
    ) {
        test_setup(chain);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );
    }

    #[test(chain = @0x1, publisher = @usernames)]
    #[expected_failure(abort_code = 0x10003, location = usernames::usernames)]
    fun test_initailze_min_duration_condition_fails(
        chain: &signer, publisher: &signer
    ) {
        test_setup(chain);

        initialize(
            publisher,
            10,
            5,
            1,
            MAX_EXPIRATION + 1, // MAX_EXPIRATION + 1
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );
    }

    #[test(chain = @0x1, publisher = @usernames)]
    fun test_update_config(chain: &signer, publisher: &signer) {
        test_setup(chain);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        // update config

        update_config(
            publisher,
            option::some(100),
            option::some(50),
            option::some(10),
            option::some(12096000),
            option::some(12096000),
            option::some(string::utf8(b"https://test2.com/"))
        );

        // check configs
        let (price_3, price_4, price_default, min_duration, grace_period, base_uri) =
            get_config_params();

        assert!(
            price_3 == 100
                && price_4 == 50
                && price_default == 10
                && min_duration == 12096000
                && grace_period == 12096000
                && base_uri == string::utf8(b"https://test2.com/"),
            1
        )
    }

    #[test(chain = @0x1, publisher = @usernames)]
    #[expected_failure(abort_code = 0x10003, location = usernames::usernames)]
    fun test_update_config_min_duration_condition_fails(
        chain: &signer, publisher: &signer
    ) {
        test_setup(chain);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        // update config

        update_config(
            publisher,
            option::none(),
            option::none(),
            option::none(),
            option::some(MAX_EXPIRATION + 1), // MAX_EXPIRATION + 1
            option::none(),
            option::none()

        );
    }

    #[test(chain = @0x1, publisher = @usernames)]
    #[expected_failure(abort_code = 0x10000, location = usernames::usernames)]
    fun test_update_config_unauthorized_fails(
        chain: &signer, publisher: &signer
    ) {
        test_setup(chain);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        // update config

        update_config(
            chain,
            option::none(),
            option::none(),
            option::none(),
            option::none(),
            option::none(),
            option::none()
        );
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    #[expected_failure(abort_code = 0x10003, location = usernames::usernames)]
    fun register_domain_min_duration_condition_fails(
        chain: &signer, publisher: &signer, user: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        register_domain(user, string::utf8(b"name"), 1209600 - 1);
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    #[expected_failure(abort_code = 0x10002, location = usernames::usernames)]
    fun register_domain_max_expiration_condition_fails(
        chain: &signer, publisher: &signer, user: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        register_domain(user, string::utf8(b"name"), MAX_EXPIRATION + 1);
    }

    #[test(
        chain = @0x1, publisher = @usernames, user1 = @0x2, user2 = @0x3
    )]
    #[expected_failure(abort_code = 0x80004, location = usernames::usernames)]
    fun register_domain_already_registered_fails(
        chain: &signer,
        publisher: &signer,
        user1: &signer,
        user2: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user1, 100);
        init_mint_to(chain_addr, user2, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        register_domain(user1, string::utf8(b"name"), 1209600);
        register_domain(user2, string::utf8(b"name"), 1209600);
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    #[expected_failure(abort_code = 0x10003, location = usernames::usernames)]
    fun extend_expiration_min_duration_condition_fails(
        chain: &signer, publisher: &signer, user: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        register_domain(user, string::utf8(b"name"), 1209600);
        extend_expiration(user, string::utf8(b"name"), 1209600 - 1);
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    #[expected_failure(abort_code = 0x30009, location = usernames::usernames)]
    fun extend_expiration_token_expired_fails(
        chain: &signer, publisher: &signer, user: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        block::set_block_info(0, 0);
        register_domain(user, string::utf8(b"name"), 1209600);
        block::set_block_info(0, 1209600 + 1209600 + 1);
        extend_expiration(user, string::utf8(b"name"), 1209600);
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    #[expected_failure(abort_code = 0x10002, location = usernames::usernames)]
    fun extend_expiration_max_expiration_fails(
        chain: &signer, publisher: &signer, user: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        register_domain(user, string::utf8(b"name"), 1209600);
        extend_expiration(
            user,
            string::utf8(b"name"),
            MAX_EXPIRATION - 1209600 + 1
        );
    }

    #[test(
        chain = @0x1, publisher = @usernames, user1 = @0x2, user2 = @0x3
    )]
    #[expected_failure(abort_code = 0x50008, location = usernames::usernames)]
    fun set_name_not_owner_fails(
        chain: &signer,
        publisher: &signer,
        user1: &signer,
        user2: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user1, 100);
        init_mint_to(chain_addr, user2, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        register_domain(user1, string::utf8(b"name"), 1209600);
        set_name(user2, string::utf8(b"name"));
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    #[expected_failure(abort_code = 0x50009, location = usernames::usernames)]
    fun set_name_token_expired_fails(
        chain: &signer, publisher: &signer, user: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        block::set_block_info(0, 0);
        register_domain(user, string::utf8(b"name"), 1209600);
        block::set_block_info(0, 1209600 + 1209600 + 1);
        set_name(user, string::utf8(b"name"));
    }

    #[test(
        chain = @0x1, publisher = @usernames, user1 = @0x2, user2 = @0x3
    )]
    #[expected_failure(abort_code = 0x50008, location = usernames::usernames)]
    fun update_records_not_owner_fails(
        chain: &signer,
        publisher: &signer,
        user1: &signer,
        user2: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user1, 100);
        init_mint_to(chain_addr, user2, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        register_domain(user1, string::utf8(b"name"), 1209600);
        update_records(
            user2,
            string::utf8(b"name"),
            vector[],
            vector[]
        );
    }

    #[test(chain = @0x1, publisher = @usernames, user = @0x2)]
    #[expected_failure(abort_code = 0x50009, location = usernames::usernames)]
    fun update_records_token_expired_fails(
        chain: &signer, publisher: &signer, user: &signer
    ) acquires CoinCaps {
        test_setup(chain);
        let chain_addr = signer::address_of(chain);
        init_mint_to(chain_addr, user, 100);

        initialize(
            publisher,
            10,
            5,
            1,
            1209600,
            1209600,
            string::utf8(b"https://test.com/"),
            string::utf8(b"https://test.com/")
        );

        block::set_block_info(0, 0);
        register_domain(user, string::utf8(b"name"), 1209600);
        block::set_block_info(0, 1209600 + 1209600 + 1);
        update_records(
            user,
            string::utf8(b"name"),
            vector[],
            vector[]
        );
    }
}
