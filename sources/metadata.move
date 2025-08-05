module usernames::metadata {
    use std::string::String;
    use std::error;

    use initia_std::object;
    use initia_std::nft::{Self, Nft};

    const MAX_RECORD: u64 = 10;

    const EMAX_RECORD_EXCEED: u64 = 1;
    const EKEY_NOT_FOUND: u64 = 2;

    friend usernames::usernames;

    struct Metadata has key {
        expiration_date: u64,
        name: String,
        record_keys: vector<String>,
        record_values: vector<String>
    }

    struct TokenInfoResponse {
        token_id: address,
        token_uri: String,
        extension: MetadataResponse
    }

    struct MetadataResponse has drop {
        expiration_date: u64,
        name: String,
        record_keys: vector<String>,
        record_values: vector<String>
    }

    // View Functions

    #[view]
    /// Returns the metadata.
    ///
    /// @param addr: The address of token.
    /// @return A `MetadataResponse` struct containing:
    ///         - `expiration_date`: The UNIX timestamp (in seconds) indicating when the username expires.
    ///         - `name`: The name of the username.
    ///         - `record_keys`: A vector of metadata record keys.
    ///         - `record_values`: A vector of metadata record values corresponding to the keys.
    public fun get_metadata(addr: address): MetadataResponse acquires Metadata {
        let metadata = borrow_global<Metadata>(addr);
        MetadataResponse {
            expiration_date: metadata.expiration_date,
            name: metadata.name,
            record_keys: metadata.record_keys,
            record_values: metadata.record_values
        }
    }

    #[view]
    /// Returns token information associated with the given address.
    ///
    /// @param addr: The address of the token.
    /// @return A `TokenInfoResponse` struct containing:
    ///         - `token_id`: Token id.
    ///         - `token_uri`: A URI pointing to the token's off-chain metadata.
    ///         - `extension`: A `MetadataResponse` containing additional on-chain metadata such as name, expiration, and custom records.
    public fun get_token_info(addr: address): TokenInfoResponse acquires Metadata {
        TokenInfoResponse {
            token_id: addr,
            token_uri: nft::uri(object::address_to_object<Nft>(addr)),
            extension: get_metadata(addr)
        }
    }

    // Friend Functions

    /// Stores metadata to an NFT, including expiration, name, and custom key-value records.
    ///
    /// @param token: The NFT signer.
    /// @param expiration_date: The UNIX timestamp (in seconds) indicating when the metadata should expire.
    /// @param name: The name of the username.
    /// @param record_keys: A vector of metadata keys to store.
    /// @param record_values: A vector of metadata values corresponding to each key.
    public(friend) fun create(
        token: &signer,
        expiration_date: u64,
        name: String,
        record_keys: vector<String>,
        record_values: vector<String>
    ) {
        // Check record length
        assert!(
            record_keys.length() <= MAX_RECORD,
            error::invalid_state(EMAX_RECORD_EXCEED)
        );

        move_to(
            token,
            Metadata { expiration_date, name, record_keys, record_values }
        )
    }

    /// Updates the expiration date of the metadata associated with a given token.
    ///
    /// @param token: The address of the token whose metadata expiration is being updated.
    /// @param new_expiration_date: The new expiration timestamp (in seconds since UNIX epoch).
    public(friend) fun update_expiration_date(
        token: address, new_expiration_date: u64
    ) acquires Metadata {
        let metadata = borrow_global_mut<Metadata>(token);
        metadata.expiration_date = new_expiration_date;
    }

    /// Updates the metadata records associated with the given token.
    ///
    /// @param token: The address of the token whose metadata is being updated.
    /// @param record_keys: A vector of keys to update or insert.
    /// @param record_values: A vector of values corresponding to each key.
    public(friend) fun update_records(
        token: address, record_keys: vector<String>, record_values: vector<String>
    ) acquires Metadata {
        let metadata = borrow_global_mut<Metadata>(token);

        record_keys.zip_ref(
            &record_values,
            |key, value| {
                // Check key already exists
                let (found, index) = metadata.record_keys.index_of(key);

                // If found, update record
                if (found) {
                    let value_before = metadata.record_values.borrow_mut(index);
                    *value_before = *value;
                } else { // Else, add record
                    metadata.record_keys.push_back(*key);
                    metadata.record_values.push_back(*value);
                }
            }
        );

        // Check record length
        assert!(
            metadata.record_keys.length() <= MAX_RECORD,
            error::invalid_state(EMAX_RECORD_EXCEED)
        );
    }

    /// Deletes specific metadata records associated with the given token.
    ///
    /// @param token: The address of the token whose metadata records are to be deleted.
    /// @param record_keys: A vector of keys identifying which records to remove.
    public(friend) fun delete_records(
        token: address, record_keys: vector<String>
    ) acquires Metadata {
        let metadata = borrow_global_mut<Metadata>(token);

        record_keys.for_each_ref(|key| {
            let (found, index) = metadata.record_keys.index_of(key);
            assert!(found, error::not_found(EKEY_NOT_FOUND));

            metadata.record_keys.remove(index);
            metadata.record_values.remove(index);
        });
    }

    // Public Functions

    /// Returns the expiration date of the metadata associated with the given token.
    ///
    /// @param token The address of the token.
    /// @return The expiration timestamp as a UNIX time in seconds.
    public fun get_expiration_date(token: address): u64 acquires Metadata {
        let metadata = borrow_global<Metadata>(token);
        metadata.expiration_date
    }

    // Tests

    #[test(token = @0x1234)]
    fun test_create(token: &signer) acquires Metadata {
        use std::string;
        use std::signer;

        let expiration_date = 123;
        let name = string::utf8(b"name");
        let record_keys = vector[string::utf8(b"key")];
        let record_values = vector[string::utf8(b"value")];

        create(
            token,
            expiration_date,
            name,
            record_keys,
            record_values
        );

        assert!(
            MetadataResponse { expiration_date, name, record_keys, record_values }
                == get_metadata(signer::address_of(token)),
            1
        );
    }

    #[test(token = @0x1234)]
    fun test_update_expiration_date(token: &signer) acquires Metadata {
        use std::string;
        use std::signer;

        let token_addr = signer::address_of(token);
        let expiration_date = 123;
        let name = string::utf8(b"name");
        let record_keys = vector[string::utf8(b"key")];
        let record_values = vector[string::utf8(b"value")];

        create(
            token,
            expiration_date,
            name,
            record_keys,
            record_values
        );

        expiration_date = 1234;

        update_expiration_date(token_addr, expiration_date);

        assert!(
            MetadataResponse { expiration_date, name, record_keys, record_values }
                == get_metadata(token_addr),
            1
        );

        assert!(expiration_date == get_expiration_date(token_addr), 2);
    }

    #[test(token = @0x1234)]
    fun test_update_records(token: &signer) acquires Metadata {
        use std::string;
        use std::signer;

        let token_addr = signer::address_of(token);
        let expiration_date = 123;
        let name = string::utf8(b"name");
        let record_keys = vector[string::utf8(b"key1")];
        let record_values = vector[string::utf8(b"value1")];

        create(
            token,
            expiration_date,
            name,
            record_keys,
            record_values
        );

        // Test add new record
        update_records(
            token_addr,
            vector[string::utf8(b"key2")],
            vector[string::utf8(b"value2")]
        );

        record_keys = vector[string::utf8(b"key1"), string::utf8(b"key2")];
        record_values = vector[string::utf8(b"value1"), string::utf8(b"value2")];

        assert!(
            MetadataResponse { expiration_date, name, record_keys, record_values }
                == get_metadata(token_addr),
            1
        );

        // Test update record
        update_records(
            token_addr,
            vector[string::utf8(b"key1")],
            vector[string::utf8(b"value1_")]
        );

        record_keys = vector[string::utf8(b"key1"), string::utf8(b"key2")];
        record_values = vector[string::utf8(b"value1_"), string::utf8(b"value2")];

        assert!(
            MetadataResponse { expiration_date, name, record_keys, record_values }
                == get_metadata(token_addr),
            2
        );

        // Test update + add record
        // Test update record
        update_records(
            token_addr,
            vector[string::utf8(b"key2"), string::utf8(b"key3")],
            vector[string::utf8(b"value2_"), string::utf8(b"value3")]
        );

        record_keys = vector[
            string::utf8(b"key1"),
            string::utf8(b"key2"),
            string::utf8(b"key3")
        ];
        record_values = vector[
            string::utf8(b"value1_"),
            string::utf8(b"value2_"),
            string::utf8(b"value3")
        ];

        assert!(
            MetadataResponse { expiration_date, name, record_keys, record_values }
                == get_metadata(token_addr),
            2
        );
    }

    #[test(token = @0x1234)]
    fun test_delete_records(token: &signer) acquires Metadata {
        use std::string;
        use std::signer;

        let token_addr = signer::address_of(token);
        let expiration_date = 123;
        let name = string::utf8(b"name");
        let record_keys = vector[string::utf8(b"key1"), string::utf8(b"key2")];
        let record_values = vector[string::utf8(b"value1"), string::utf8(b"value2")];

        create(
            token,
            expiration_date,
            name,
            record_keys,
            record_values
        );

        delete_records(token_addr, vector[string::utf8(b"key2")]);

        record_keys = vector[string::utf8(b"key1")];
        record_values = vector[string::utf8(b"value1")];

        assert!(
            MetadataResponse { expiration_date, name, record_keys, record_values }
                == get_metadata(token_addr),
            1
        );
    }

    #[test(token = @0x1234)]
    #[expected_failure(abort_code = 0x30001, location = Self)]
    fun test_create_max_length_fails(token: &signer) {
        use std::string;

        let expiration_date = 123;
        let name = string::utf8(b"name");
        let record_keys = vector[
            string::utf8(b"1"), string::utf8(b"2"), string::utf8(b"3"), string::utf8(b"4"), string::utf8(
                b"5"
            ), string::utf8(b"6"), string::utf8(b"7"), string::utf8(b"8"), string::utf8(
                b"9"
            ), string::utf8(b"10"), string::utf8(b"11")
        ];
        let record_values = record_keys;

        create(
            token,
            expiration_date,
            name,
            record_keys,
            record_values
        );
    }

    #[test(token = @0x1234)]
    #[expected_failure(abort_code = 0x30001, location = Self)]
    fun test_update_record_max_length_fails(token: &signer) acquires Metadata {
        use std::string;
        use std::signer;

        let expiration_date = 123;
        let name = string::utf8(b"name");
        let record_keys = vector[
            string::utf8(b"1"), string::utf8(b"2"), string::utf8(b"3"), string::utf8(b"4"), string::utf8(
                b"5"
            ), string::utf8(b"6"), string::utf8(b"7"), string::utf8(b"8"), string::utf8(
                b"9"
            ), string::utf8(b"10")
        ];
        let record_values = record_keys;

        create(
            token,
            expiration_date,
            name,
            record_keys,
            record_values
        );

        update_records(
            signer::address_of(token),
            vector[string::utf8(b"11")],
            vector[string::utf8(b"11")]
        )
    }

    #[test(token = @0x1234)]
    #[expected_failure(abort_code = 0x60002, location = Self)]
    fun test_delete_records_key_not_found_fails(token: &signer) acquires Metadata {
        use std::string;
        use std::signer;

        let expiration_date = 123;
        let name = string::utf8(b"name");
        let record_keys = vector[string::utf8(b"1")];
        let record_values = record_keys;

        create(
            token,
            expiration_date,
            name,
            record_keys,
            record_values
        );

        delete_records(
            signer::address_of(token),
            vector[string::utf8(b"2")]
        )
    }
}
