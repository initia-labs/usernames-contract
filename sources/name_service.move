module usernames::usernames {
    use std::error;
    use std::event::Self;
    use std::string::{Self, String};
    use std::signer;
    use std::vector;

    use initia_std::block;
    use initia_std::coin;
    use initia_std::bigdecimal;
    use initia_std::object::{Self, ExtendRef, Object};
    use initia_std::option::{Self, Option};
    use initia_std::table::{Self, Table};
    use initia_std::nft::Nft;
    use initia_std::initia_nft;
    use initia_std::primary_fungible_store;
    use initia_std::fungible_asset::{Metadata as CoinMetadata};

    use usernames::metadata::{Self, Metadata};

    /// Only chain can execute.
    const EUNAUTHORIZED: u64 = 0;

    /// module store already exist.
    const EMODULE_STORE_ALREADY_PUBLISHED: u64 = 1;

    /// expiration must be smaller than current timestamp + MAX_EXPIRATION
    const EMAX_EXPIRATION: u64 = 2;

    /// duration must be bigger than min_duration
    const EMIN_DURATION: u64 = 3;

    /// name already taken
    const EDOMAIN_NAME_ALREADY_EXISTS: u64 = 4;

    /// name length must be more bigger than or equal to 3
    const EMIN_NAME_LENGTH: u64 = 5;

    /// name length must be smaller than max length
    const EMAX_NAME_LENGTH: u64 = 6;

    /// invalid character
    const EINVALID_CHARACTER: u64 = 7;

    /// not an owner of the token
    const ENOT_OWNER: u64 = 8;

    /// token is expired
    const ETOKEN_EXPIRED: u64 = 9;

    /// constants
    const YEAR_TO_SECOND: u64 = 31557600; // 365.25 * 24 * 60 * 60

    const MAX_EXPIRATION: u64 = 315576000; // 10 years

    const TLD: vector<u8> = b".init";

    const MAX_LENGTH: u64 = 64;

    struct ModuleStore has key {
        name_to_token: Table<String, address>,
        name_to_addr: Table<String, address>,
        addr_to_name: Table<address, String>,
        creator_extend_ref: ExtendRef,
        pool: address,
        config: Config
    }

    #[event]
    struct RegisterEvent has drop, store {
        addr: address,
        domain_name: String,
        token: address,
        expiration_date: u64
    }

    #[event]
    struct UnsetEvent has drop, store {
        addr: address,
        domain_name: String
    }

    #[event]
    struct SetEvent has drop, store {
        addr: address,
        domain_name: String
    }

    #[event]
    struct ExtendEvent has drop, store {
        addr: address,
        domain_name: String,
        expiration_date: u64
    }

    #[event]
    struct UpdateRecordsEvent has drop, store {
        addr: address,
        domain_name: String,
        keys: vector<String>,
        values: vector<String>
    }

    #[event]
    struct DeleteRecordsEvent has drop, store {
        addr: address,
        domain_name: String,
        keys: vector<String>
    }

    struct Config has store {
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,
        min_duration: u64,
        grace_period: u64,
        base_uri: String
    }

    struct ConfigResponse has drop {
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,
        min_duration: u64,
        grace_period: u64,
        base_uri: String
    }

    // View Functions

    #[view]
    /// Returns the address of NFT associated with the given domain name, if it exists.
    ///
    /// @param domain_name: The domain name to look up.
    /// @return An NFT address if the domain is valid and registered; otherwise, `None`.
    public fun get_valid_token(domain_name: String): Option<address> acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@usernames);

        if (module_store.name_to_token.contains(domain_name)) {
            return option::some(*module_store.name_to_token.borrow(domain_name))
        };

        return option::none()
    }

    #[view]
    /// Retrieves the name associated with a given address, if available.
    ///
    /// @param addr: The address to look up.
    /// @return An `Option<String>` containing the domain name if one is associated with the address; otherwise, `None`.
    public fun get_name_from_address(addr: address): Option<String> acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@usernames);

        // If not registered, return None
        if (!module_store.addr_to_name.contains(addr)) {
            return option::none()
        };

        // Get name
        let name = *module_store.addr_to_name.borrow(addr);

        // If expired, return none
        if (is_expired(name)) {
            return option::none();
        };

        return option::some(name)
    }

    #[view]
    /// Retrieves the address associated with a given name, if it exists.
    ///
    /// @param name: The domain name to look up.
    /// @return An user address if the name is registered and valid; otherwise, `None`.
    public fun get_address_from_name(name: String): Option<address> acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@usernames);

        // If not registered, return None
        if (!module_store.name_to_addr.contains(name)) {
            return option::none()
        };

        // Get address
        let addr = option::some(*module_store.name_to_addr.borrow(name));

        // If domain name is expired, return None
        if (is_expired(name)) {
            return option::none()
        };

        return addr
    }

    #[view]
    /// Returns the current configuration settings for the username module.
    ///
    /// @return A `ConfigResponse` struct containing:
    ///         - `price_per_year_3char`: Registration price per year for 3-character names.
    ///         - `price_per_year_4char`: Registration price per year for 4-character names.
    ///         - `price_per_year_default`: Default registration price per year for names longer than 4 characters.
    ///         - `min_duration`: Minimum duration (in seconds) for which a name can be registered.
    ///         - `grace_period`: Grace period (in seconds) after expiration before a name becomes available again.
    ///         - `base_uri`: Base URI used for off-chain metadata resolution.
    public fun get_config(): ConfigResponse acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@usernames);

        ConfigResponse {
            price_per_year_3char: module_store.config.price_per_year_3char,
            price_per_year_4char: module_store.config.price_per_year_4char,
            price_per_year_default: module_store.config.price_per_year_default,
            min_duration: module_store.config.min_duration,
            grace_period: module_store.config.grace_period,
            base_uri: module_store.config.base_uri
        }
    }

    #[view]
    /// Calculates the cost (in INIT) to register a domain name for a given duration.
    ///
    /// @param domain_name: The domain name to be registered.
    /// @param duration: The desired registration duration in seconds.
    /// @return The total cost in INIT tokens to register the domain.
    public fun get_init_cost(domain_name: String, duration: u64): u64 acquires ModuleStore {
        get_cost_amount(domain_name, duration)
    }

    // Public Functions

    /// Returns the raw configuration parameters for username registration.
    ///
    /// @return A tuple containing:
    ///         - `price_per_year_3char`: Registration price per year for 3-character names.
    ///         - `price_per_year_4char`: Registration price per year for 4-character names.
    ///         - `price_per_year_default`: Default registration price per year for names longer than 4 characters.
    ///         - `min_duration`: Minimum registration duration in seconds.
    ///         - `grace_period`: Duration in seconds after expiration before the name becomes available again.
    ///         - `base_uri`: The base URI for metadata resolution.
    public fun get_config_params(): (u64, u64, u64, u64, u64, String) acquires ModuleStore {
        let module_store = borrow_global<ModuleStore>(@usernames);

        (
            module_store.config.price_per_year_3char,
            module_store.config.price_per_year_4char,
            module_store.config.price_per_year_default,
            module_store.config.min_duration,
            module_store.config.grace_period,
            module_store.config.base_uri
        )
    }

    // Admin Entry Functions

    /// Initializes the global username module store with configuration parameters.
    /// This function should be called only once by the publisher.
    ///
    /// @param publisher: The signer account initializing the module.
    /// @param price_per_year_3char: Registration price per year for 3-character names.
    /// @param price_per_year_4char: Registration price per year for 4-character names.
    /// @param price_per_year_default: Default registration price per year for names longer than 4 characters.
    /// @param min_duration: Minimum duration (in seconds) a name can be registered for.
    /// @param grace_period: Time (in seconds) after expiration before the name becomes available again.
    /// @param base_uri: The base URI used for resolving off-chain metadata.
    /// @param collection_uri: URI for the NFT collection metadata.
    public entry fun initialize(
        publisher: &signer,
        price_per_year_3char: u64,
        price_per_year_4char: u64,
        price_per_year_default: u64,
        min_duration: u64,
        grace_period: u64,
        base_uri: String,
        collection_uri: String
    ) {
        // Check signer
        assert!(
            signer::address_of(publisher) == @usernames,
            error::invalid_argument(EUNAUTHORIZED)
        );

        // Check already initialized
        assert!(
            !exists<ModuleStore>(@usernames),
            error::already_exists(EMODULE_STORE_ALREADY_PUBLISHED)
        );

        // Create object account
        let constructor_ref = object::create_named_object(publisher, b"usernames");
        let creator = object::generate_signer(&constructor_ref);
        let creator_extend_ref = object::generate_extend_ref(&constructor_ref);

        // Create NFT collection
        initia_nft::create_collection_object(
            &creator,
            string::utf8(b"Initia Usernames"),
            option::none(),
            string::utf8(b"Initia Usernames"),
            collection_uri,
            false,
            false,
            false,
            true,
            true,
            bigdecimal::zero()
        );

        // Create object account for collectiong cost. Only @0x1 can withdraw this
        let constructor_ref = object::create_object(@initia_std, false);
        let pool = object::address_from_constructor_ref(&constructor_ref);

        // Check min_duration is smaller than `MAX_EXPIRATION`
        assert!(min_duration < MAX_EXPIRATION, error::invalid_argument(EMIN_DURATION));

        // Store ModuleStore
        move_to(
            publisher,
            ModuleStore {
                name_to_token: table::new(),
                name_to_addr: table::new(),
                addr_to_name: table::new(),
                creator_extend_ref,
                pool,
                config: Config {
                    price_per_year_3char,
                    price_per_year_4char,
                    price_per_year_default,
                    min_duration,
                    grace_period,
                    base_uri
                }
            }
        );
    }

    /// Updates the configuration parameters for username registration.
    /// Each parameter is optional; only the provided values will be updated.
    ///
    /// @param publisher: The signer account authorized to update the configuration.
    /// @param price_per_year_3char: Optional, new price per year for 3-character names.
    /// @param price_per_year_4char: Optional, new price per year for 4-character names.
    /// @param price_per_year_default: Optional, new price per year for names longer than 4 characters.
    /// @param min_duration: Optional, new minimum registration duration (in seconds).
    /// @param grace_period: Optional, new grace period duration after expiration (in seconds).
    /// @param base_uri: Optional, new base URI for resolving off-chain metadata.
    public entry fun update_config(
        publisher: &signer,
        price_per_year_3char: Option<u64>,
        price_per_year_4char: Option<u64>,
        price_per_year_default: Option<u64>,
        min_duration: Option<u64>,
        grace_period: Option<u64>,
        base_uri: Option<String>
    ) acquires ModuleStore {
        // Check signer
        assert!(
            signer::address_of(publisher) == @usernames,
            error::invalid_argument(EUNAUTHORIZED)
        );

        // Load ModuleStore
        let module_store = borrow_global_mut<ModuleStore>(@usernames);

        // Update configs

        if (price_per_year_3char.is_some()) {
            module_store.config.price_per_year_3char = price_per_year_3char.extract();
        };

        if (price_per_year_4char.is_some()) {
            module_store.config.price_per_year_4char = price_per_year_4char.extract();
        };

        if (price_per_year_default.is_some()) {
            module_store.config.price_per_year_default = price_per_year_default.extract();
        };

        if (min_duration.is_some()) {
            module_store.config.min_duration = min_duration.extract();

            // Check min_duration is smaller than `MAX_EXPIRATION`
            assert!(
                module_store.config.min_duration < MAX_EXPIRATION,
                error::invalid_argument(EMIN_DURATION)
            );
        };

        if (grace_period.is_some()) {
            module_store.config.grace_period = grace_period.extract();
        };

        if (base_uri.is_some()) {
            module_store.config.base_uri = base_uri.extract();
        };
    }

    // User Entry Functions

    /// Registers a new domain name for the caller's address with a specified duration.
    ///
    /// @param account: The signer account that will own the registered domain.
    /// @param domain_name: The domain name to register.
    /// @param duration: The number of seconds the domain will remain active before expiration.
    public entry fun register_domain(
        account: &signer, domain_name: String, duration: u64
    ) acquires ModuleStore {
        let addr = signer::address_of(account);

        let module_store = borrow_global_mut<ModuleStore>(@usernames);
        let (_height, timestamp) = block::get_block_info();

        // Convert upper case to lower case
        domain_name = to_lower_case(&domain_name);

        // Check expiration
        assert!(
            duration >= module_store.config.min_duration,
            error::invalid_argument(EMIN_DURATION)
        );
        assert!(
            duration <= MAX_EXPIRATION,
            error::invalid_argument(EMAX_EXPIRATION)
        );

        // Get collection creator signer
        let creator =
            &object::generate_signer_for_extending(&module_store.creator_extend_ref);

        // If domain is already registered, check the expiration.
        if (module_store.name_to_token.contains(domain_name)) {
            // Get token addr
            let token = *module_store.name_to_token.borrow(domain_name);

            // Get expiration date
            let expiration_date = metadata::get_expiration_date(token);

            // Check grace period is passed
            assert!(
                expiration_date + module_store.config.grace_period < timestamp,
                error::already_exists(EDOMAIN_NAME_ALREADY_EXISTS)
            );

            // Remove name_to_token
            module_store.name_to_token.remove(domain_name);

            // Update token uri to expired
            let token_uri = module_store.config.base_uri;
            token_uri.append(string::utf8(b"expired"));
            initia_nft::set_uri(
                creator, object::address_to_object<Nft>(token), token_uri
            );

            // Remove record
            if (module_store.name_to_addr.contains(domain_name)) {
                let former_addr = module_store.name_to_addr.remove(domain_name);
                module_store.addr_to_name.remove(former_addr);
            }
        };

        // Check name is vaild string
        let name = domain_name;
        check_name(name);

        // Add TLD and timestamp
        name.append_utf8(TLD);
        name.append_utf8(b".");
        name.append(u64_to_string(timestamp));

        // Generate token_uri
        let token_uri = module_store.config.base_uri;
        token_uri.append(domain_name);

        // Mint NFT
        let (_, extend_ref) =
            initia_nft::mint_nft_object(
                creator,
                string::utf8(b"Initia Usernames"),
                string::utf8(b"Initia Usernames"),
                name,
                token_uri,
                false
            );

        // Transfer NFT to caller
        let token_addr = object::address_from_extend_ref(&extend_ref);
        object::transfer_raw(creator, token_addr, addr);

        // Add record
        module_store.name_to_token.add(domain_name, token_addr);

        // Create metadata
        let token = object::generate_signer_for_extending(&extend_ref);
        metadata::create(
            &token,
            timestamp + duration,
            name,
            vector[],
            vector[]
        );

        // Pay cost
        let pool_address = module_store.pool;
        let cost_amount = get_cost_amount(domain_name, duration);
        let cost =
            primary_fungible_store::withdraw(account, get_init_metadata(), cost_amount);
        primary_fungible_store::deposit(pool_address, cost);

        // Emit event
        event::emit(
            RegisterEvent {
                addr,
                domain_name,
                token: token_addr,
                expiration_date: timestamp + duration
            }
        );
    }

    /// Sets the default domain name for the caller's account.
    ///
    /// @param account: The signer account setting the domain name.
    /// @param domain_name: The domain name to associate as the default for the account.
    public entry fun set_name(account: &signer, domain_name: String) acquires ModuleStore {
        let addr = signer::address_of(account);
        let (_height, timestamp) = block::get_block_info();
        let module_store = borrow_global_mut<ModuleStore>(@usernames);

        // Convert upper case to lower case
        domain_name = to_lower_case(&domain_name);

        // Check user owns domain.
        let token_addr = *module_store.name_to_token.borrow(domain_name);
        let token_object = object::address_to_object<Metadata>(token_addr);
        assert!(
            object::is_owner(token_object, addr), error::permission_denied(ENOT_OWNER)
        );

        // Check token expired
        assert!(
            metadata::get_expiration_date(token_addr) > timestamp,
            error::permission_denied(ETOKEN_EXPIRED)
        );

        // If domain is registered, remove mapping
        if (module_store.name_to_addr.contains(domain_name)) {
            let removed_addr = module_store.name_to_addr.remove(domain_name);
            module_store.addr_to_name.remove(removed_addr);
        };

        // If account is registered, remove mapping
        if (module_store.addr_to_name.contains(addr)) {
            let removed_name = module_store.addr_to_name.remove(addr);
            module_store.name_to_addr.remove(removed_name);
        };

        // Add mapping
        module_store.name_to_addr.add(domain_name, addr);
        module_store.addr_to_name.add(addr, domain_name);

        // Emit event
        event::emit(SetEvent { addr, domain_name });
    }

    /// Unsets the default domain name for the caller's account.
    ///
    /// @param account: The signer account removing the associated default domain name.
    public entry fun unset_name(account: &signer) acquires ModuleStore {
        let addr = signer::address_of(account);
        let module_store = borrow_global_mut<ModuleStore>(@usernames);

        // Remove mapping
        if (module_store.addr_to_name.contains(addr)) {
            let removed_name = module_store.addr_to_name.remove(addr);
            module_store.name_to_addr.remove(removed_name);

            // Emit event
            event::emit(UnsetEvent { addr, domain_name: removed_name });
        };
    }

    /// Extends the expiration date of a registered domain name.
    ///
    /// @param account: The signer account.
    /// @param domain_name: The domain name whose registration is being extended.
    /// @param duration: The additional duration (in seconds) to extend the domain registration by.
    public entry fun extend_expiration(
        account: &signer, domain_name: String, duration: u64
    ) acquires ModuleStore {
        let addr = signer::address_of(account);

        let module_store = borrow_global_mut<ModuleStore>(@usernames);
        let (_height, timestamp) = block::get_block_info();

        // Convert upper case to lower case
        domain_name = to_lower_case(&domain_name);

        // Check min duration
        assert!(
            duration >= module_store.config.min_duration,
            error::invalid_argument(EMIN_DURATION)
        );

        // Get current expiration date
        let token = *module_store.name_to_token.borrow(domain_name);
        let expiration_date = metadata::get_expiration_date(token);

        // Not allow extend for expired one. Reregister indstead.
        assert!(
            expiration_date + module_store.config.grace_period >= timestamp,
            error::invalid_state(ETOKEN_EXPIRED)
        );

        // Calculate new expiration date
        let new_expiration_date =
            if (expiration_date > timestamp) {
                expiration_date + duration
            } else {
                timestamp + duration
            };

        // Check max expiration
        assert!(
            new_expiration_date - timestamp <= MAX_EXPIRATION,
            error::invalid_argument(EMAX_EXPIRATION)
        );

        // Update expiration date
        metadata::update_expiration_date(token, new_expiration_date);

        // Pay cost
        let pool_address = module_store.pool;
        let cost_amount = get_cost_amount(domain_name, duration);
        let cost =
            primary_fungible_store::withdraw(account, get_init_metadata(), cost_amount);
        primary_fungible_store::deposit(pool_address, cost);

        // Emit event
        event::emit<ExtendEvent>(
            ExtendEvent { addr, domain_name, expiration_date: new_expiration_date }
        );
    }

    /// Updates metadata records associated with a domain name.
    ///
    /// @param account: The signer account that owns the domain.
    /// @param domain_name: The domain name for which records are being updated.
    /// @param record_keys: A vector of record keys.
    /// @param record_values: A vector of record values corresponding to each key.
    public entry fun update_records(
        account: &signer,
        domain_name: String,
        record_keys: vector<String>,
        record_values: vector<String>
    ) acquires ModuleStore {
        let addr = signer::address_of(account);

        let module_store = borrow_global_mut<ModuleStore>(@usernames);
        let (_height, timestamp) = block::get_block_info();

        // Convert upper case to lower case
        domain_name = to_lower_case(&domain_name);

        // Check expirtion
        let token = *module_store.name_to_token.borrow(domain_name);
        let token_object = object::address_to_object<Metadata>(token);
        assert!(
            metadata::get_expiration_date(token) > timestamp,
            error::permission_denied(ETOKEN_EXPIRED)
        );

        // Check domain owner
        assert!(
            object::is_owner(token_object, addr), error::permission_denied(ENOT_OWNER)
        );

        // Update records
        metadata::update_records(token, record_keys, record_values);

        // Emit event
        event::emit(
            UpdateRecordsEvent {
                addr,
                domain_name,
                keys: record_keys,
                values: record_values
            }
        );
    }

    /// Deletes specific metadata records associated with a domain name.
    ///
    /// @param account: The signer account that owns the domain.
    /// @param domain_name: The domain name from which records are to be deleted.
    /// @param record_keys: A vector of keys identifying the records to delete.
    public entry fun delete_records(
        account: &signer, domain_name: String, record_keys: vector<String>
    ) acquires ModuleStore {
        let addr = signer::address_of(account);

        let module_store = borrow_global_mut<ModuleStore>(@usernames);
        let (_height, timestamp) = block::get_block_info();

        // Convert upper case to lower case
        domain_name = to_lower_case(&domain_name);

        // Check expirtion
        let token = *module_store.name_to_token.borrow(domain_name);
        let token_object = object::address_to_object<Metadata>(token);
        assert!(
            metadata::get_expiration_date(token) > timestamp,
            error::permission_denied(ETOKEN_EXPIRED)
        );

        // Check domain owner
        assert!(
            object::is_owner(token_object, addr), error::permission_denied(ENOT_OWNER)
        );

        // Delete records
        metadata::delete_records(token, record_keys);

        // Emit event
        event::emit(DeleteRecordsEvent { addr, domain_name, keys: record_keys });
    }

    // Internal Functions

    fun check_name(name: String) {
        let bytes = name.bytes();

        // Check length
        let len = bytes.length();
        assert!(len >= 3, error::invalid_argument(EMIN_NAME_LENGTH));
        assert!(len <= MAX_LENGTH, error::invalid_argument(EMAX_NAME_LENGTH));

        bytes.enumerate_ref(
            |index, char| {
                let char = *char;
                if (index == 0 || index == len - 1) {
                    assert!(char != 45, error::invalid_argument(EINVALID_CHARACTER))
                };

                assert!(
                    char == 45
                        || // -
                        (char >= 48
                            && char <= 57)
                        || // 0 ~ 9
                        (char >= 97
                            && char <= 122), // a ~ z
                    error::invalid_argument(EINVALID_CHARACTER)
                );
            }
        );
    }

    fun u64_to_string(num: u64): String {
        if (num == 0) {
            return string::utf8(b"0");
        };

        let bytes: vector<u8> = vector[];

        while (num > 0) {
            let remain = (num % 10 as u8);
            num = num / 10;
            bytes.push_back(48 + remain);
        };

        bytes.reverse();

        string::utf8(bytes)
    }

    fun get_cost_amount(domain_name: String, duration: u64): u64 acquires ModuleStore {
        let module_store = borrow_global_mut<ModuleStore>(@usernames);
        let len = string::length(&domain_name);
        let price_per_year =
            if (len == 3) {
                module_store.config.price_per_year_3char
            } else if (len == 4) {
                module_store.config.price_per_year_4char
            } else {
                module_store.config.price_per_year_default
            };

        // will update this to slinky oracle price after INIT/USD list
        let spot_price = bigdecimal::one(); //dex::get_spot_price(object::address_to_object<PairConfig>(@pair), get_init_metadata());

        let usd_value =
            bigdecimal::from_ratio_u128(
                (price_per_year as u128) * (duration as u128),
                (YEAR_TO_SECOND as u128)
            );

        let bigdecimal_price = bigdecimal::div(usd_value, spot_price);

        bigdecimal::truncate_u64(bigdecimal_price)
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
        let token = *option::borrow(&get_valid_token(name));
        let expiration_date = metadata::get_expiration_date(token);
        let (_height, timestamp) = block::get_block_info();
        timestamp > expiration_date
    }

    fun get_init_metadata(): Object<CoinMetadata> {
        let init_symbol = string::utf8(b"uinit");
        coin::metadata(@initia_std, init_symbol)
    }

    // Test

    #[test]
    fun test_to_lower_case() {
        let name = string::utf8(b"AbCd");
        assert!(to_lower_case(&name) == string::utf8(b"abcd"), 0);
    }

    #[test]
    #[expected_failure(abort_code = 0x10007, location = Self)]
    fun check_name_starts_with_hyphen_fails() {
        let name = string::utf8(b"-abc");
        check_name(name)
    }

    #[test]
    #[expected_failure(abort_code = 0x10007, location = Self)]
    fun check_name_ends_with_hyphen_fails() {
        let name = string::utf8(b"abc-");
        check_name(name)
    }

    #[test]
    #[expected_failure(abort_code = 0x10006, location = Self)]
    fun check_name_too_long_hyphen_fails() {
        let name =
            string::utf8(
                b"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
            );
        check_name(name)
    }

    #[test]
    #[expected_failure(abort_code = 0x10005, location = Self)]
    fun check_name_too_short_fails() {
        let name = string::utf8(b"aa");
        check_name(name)
    }
}
