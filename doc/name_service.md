
<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames"></a>

# Module `0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef::usernames`



-  [Resource `ModuleStore`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore)
-  [Struct `RegisterEvent`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_RegisterEvent)
-  [Struct `UnsetEvent`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UnsetEvent)
-  [Struct `SetEvent`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_SetEvent)
-  [Struct `ExtendEvent`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ExtendEvent)
-  [Struct `UpdateRecordsEvent`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UpdateRecordsEvent)
-  [Struct `DeleteRecordsEvent`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_DeleteRecordsEvent)
-  [Struct `Config`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_Config)
-  [Struct `ConfigResponse`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ConfigResponse)
-  [Constants](#@Constants_0)
-  [Function `get_valid_token`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_valid_token)
-  [Function `get_name_from_address`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_name_from_address)
-  [Function `get_address_from_name`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_address_from_name)
-  [Function `get_config`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config)
-  [Function `get_init_cost`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_init_cost)
-  [Function `get_config_params`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config_params)
-  [Function `initialize`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_initialize)
-  [Function `update_config`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_config)
-  [Function `register_domain`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_register_domain)
-  [Function `unset_name`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_unset_name)
-  [Function `set_name`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_set_name)
-  [Function `extend_expiration`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_extend_expiration)
-  [Function `update_records`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_records)
-  [Function `delete_records`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_delete_records)


<pre><code><b>use</b> <a href="">0x1::bigdecimal</a>;
<b>use</b> <a href="">0x1::block</a>;
<b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::error</a>;
<b>use</b> <a href="">0x1::event</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::initia_nft</a>;
<b>use</b> <a href="">0x1::nft</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::table</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef::metadata</a>;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore"></a>

## Resource `ModuleStore`



<pre><code><b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> <b>has</b> key
</code></pre>



##### Fields


<dl>
<dt>
<code>name_to_token: <a href="_Table">table::Table</a>&lt;<a href="_String">string::String</a>, <b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>name_to_addr: <a href="_Table">table::Table</a>&lt;<a href="_String">string::String</a>, <b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>addr_to_name: <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>creator_extend_ref: <a href="_ExtendRef">object::ExtendRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>pool: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>config: <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_Config">usernames::Config</a></code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_RegisterEvent"></a>

## Struct `RegisterEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_RegisterEvent">RegisterEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>addr: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>domain_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>token: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>expiration_date: u64</code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UnsetEvent"></a>

## Struct `UnsetEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UnsetEvent">UnsetEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>addr: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>domain_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_SetEvent"></a>

## Struct `SetEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_SetEvent">SetEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>addr: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>domain_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ExtendEvent"></a>

## Struct `ExtendEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ExtendEvent">ExtendEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>addr: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>domain_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>expiration_date: u64</code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UpdateRecordsEvent"></a>

## Struct `UpdateRecordsEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UpdateRecordsEvent">UpdateRecordsEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>addr: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>domain_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>values: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_DeleteRecordsEvent"></a>

## Struct `DeleteRecordsEvent`



<pre><code>#[<a href="">event</a>]
<b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_DeleteRecordsEvent">DeleteRecordsEvent</a> <b>has</b> drop, store
</code></pre>



##### Fields


<dl>
<dt>
<code>addr: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>domain_name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_Config"></a>

## Struct `Config`



<pre><code><b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_Config">Config</a> <b>has</b> store
</code></pre>



##### Fields


<dl>
<dt>
<code>price_per_year_3char: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>price_per_year_4char: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>price_per_year_default: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>min_duration: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>grace_period: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>base_uri: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ConfigResponse"></a>

## Struct `ConfigResponse`



<pre><code><b>struct</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ConfigResponse">ConfigResponse</a> <b>has</b> drop
</code></pre>



##### Fields


<dl>
<dt>
<code>price_per_year_3char: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>price_per_year_4char: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>price_per_year_default: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>min_duration: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>grace_period: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>base_uri: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


<a id="@Constants_0"></a>

## Constants


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EUNAUTHORIZED"></a>

Only chain can execute.


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EUNAUTHORIZED">EUNAUTHORIZED</a>: u64 = 0;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ENOT_OWNER"></a>

not an owner of the token


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ENOT_OWNER">ENOT_OWNER</a>: u64 = 8;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EDOMAIN_NAME_ALREADY_EXISTS"></a>

name already taken


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EDOMAIN_NAME_ALREADY_EXISTS">EDOMAIN_NAME_ALREADY_EXISTS</a>: u64 = 4;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EINVALID_CHARACTER"></a>

invalid character


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EINVALID_CHARACTER">EINVALID_CHARACTER</a>: u64 = 7;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMAX_EXPIRATION"></a>

expiration must be smaller than current timestamp + MAX_EXPIRATION


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMAX_EXPIRATION">EMAX_EXPIRATION</a>: u64 = 3;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMAX_NAME_LENGTH"></a>

name length must be smaller than max length


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMAX_NAME_LENGTH">EMAX_NAME_LENGTH</a>: u64 = 6;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_DURATION"></a>

duration must be bigger than min_duration


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_DURATION">EMIN_DURATION</a>: u64 = 3;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_NAME_LENGTH"></a>

name length must be more bigger than or equal to 3


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_NAME_LENGTH">EMIN_NAME_LENGTH</a>: u64 = 5;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMODULE_STORE_ALREADY_PUBLISHED"></a>

module store already exist.


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMODULE_STORE_ALREADY_PUBLISHED">EMODULE_STORE_ALREADY_PUBLISHED</a>: u64 = 1;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ETOKEN_EXPIRED"></a>

token is expired


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ETOKEN_EXPIRED">ETOKEN_EXPIRED</a>: u64 = 9;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_EXPIRATION"></a>



<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_EXPIRATION">MAX_EXPIRATION</a>: u64 = 315576000;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_LENGTH"></a>



<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_LENGTH">MAX_LENGTH</a>: u64 = 64;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_TLD"></a>



<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_TLD">TLD</a>: <a href="">vector</a>&lt;u8&gt; = [46, 105, 110, 105, 116];
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_YEAR_TO_SECOND"></a>

constants


<pre><code><b>const</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_YEAR_TO_SECOND">YEAR_TO_SECOND</a>: u64 = 31557600;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_valid_token"></a>

## Function `get_valid_token`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_valid_token">get_valid_token</a>(domain_name: <a href="_String">string::String</a>): <a href="_Option">option::Option</a>&lt;<b>address</b>&gt;
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_valid_token">get_valid_token</a>(domain_name: String): Option&lt;<b>address</b>&gt; <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> module_store = <b>borrow_global</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    <b>let</b> id = <b>if</b> (<a href="_contains">table::contains</a>(&module_store.name_to_token, domain_name)) {
        <a href="_some">option::some</a>(*<a href="_borrow">table::borrow</a>(&module_store.name_to_token, domain_name))
    } <b>else</b> {
        <a href="_none">option::none</a>()
    };

    id
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_name_from_address"></a>

## Function `get_name_from_address`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_name_from_address">get_name_from_address</a>(addr: <b>address</b>): <a href="_Option">option::Option</a>&lt;<a href="_String">string::String</a>&gt;
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_name_from_address">get_name_from_address</a>(addr: <b>address</b>): Option&lt;String&gt; <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> module_store = <b>borrow_global</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    <b>let</b> name = <b>if</b> (<a href="_contains">table::contains</a>(&module_store.addr_to_name, addr)) {
        <b>let</b> name = *<a href="_borrow">table::borrow</a>(&module_store.addr_to_name, addr);
        <b>if</b> (<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_is_expired">is_expired</a>(name)) {
            <a href="_none">option::none</a>()
        } <b>else</b> {
            <a href="_some">option::some</a>(name)
        }
    } <b>else</b> {
        <a href="_none">option::none</a>()
    };

    name
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_address_from_name"></a>

## Function `get_address_from_name`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_address_from_name">get_address_from_name</a>(name: <a href="_String">string::String</a>): <a href="_Option">option::Option</a>&lt;<b>address</b>&gt;
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_address_from_name">get_address_from_name</a>(name: String): Option&lt;<b>address</b>&gt; <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> module_store = <b>borrow_global</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    <b>let</b> addr = <b>if</b> (<a href="_contains">table::contains</a>(&module_store.name_to_addr, name)) {
        <b>if</b> (<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_is_expired">is_expired</a>(name)) {
            <a href="_none">option::none</a>()
        } <b>else</b> {
            <b>let</b> module_store = <b>borrow_global</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
            <a href="_some">option::some</a>(*<a href="_borrow">table::borrow</a>(&module_store.name_to_addr, name))
        }
    } <b>else</b> {
        <a href="_none">option::none</a>()
    };

    addr
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config"></a>

## Function `get_config`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config">get_config</a>(): <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ConfigResponse">usernames::ConfigResponse</a>
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config">get_config</a>(): <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ConfigResponse">ConfigResponse</a> <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> module_store = <b>borrow_global</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);

    <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ConfigResponse">ConfigResponse</a> {
        price_per_year_3char: module_store.config.price_per_year_3char,
        price_per_year_4char: module_store.config.price_per_year_4char,
        price_per_year_default: module_store.config.price_per_year_default,
        min_duration: module_store.config.min_duration,
        grace_period: module_store.config.grace_period,
        base_uri: module_store.config.base_uri,
    }
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_init_cost"></a>

## Function `get_init_cost`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_init_cost">get_init_cost</a>(domain_name: <a href="_String">string::String</a>, duration: u64): u64
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_init_cost">get_init_cost</a>(domain_name: String, duration: u64): u64 <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_cost_amount">get_cost_amount</a>(domain_name, duration)
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config_params"></a>

## Function `get_config_params`

return (price_per_year_3char, price_per_year_4char, price_per_year_default, min_duration, grace_period, base_uri)


<pre><code><b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config_params">get_config_params</a>(): (u64, u64, u64, u64, u64, <a href="_String">string::String</a>)
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_config_params">get_config_params</a>(): (u64, u64, u64, u64, u64, String) <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> module_store = <b>borrow_global</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);

    (
        module_store.config.price_per_year_3char,
        module_store.config.price_per_year_4char,
        module_store.config.price_per_year_default,
        module_store.config.min_duration,
        module_store.config.grace_period,
        module_store.config.base_uri,
    )
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_initialize"></a>

## Function `initialize`

Initialize, Make global store


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_initialize">initialize</a>(<a href="">account</a>: &<a href="">signer</a>, price_per_year_3char: u64, price_per_year_4char: u64, price_per_year_default: u64, min_duration: u64, grace_period: u64, base_uri: <a href="_String">string::String</a>, collection_uri: <a href="_String">string::String</a>)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_initialize">initialize</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    price_per_year_3char: u64,
    price_per_year_4char: u64,
    price_per_year_default: u64,
    min_duration: u64,
    grace_period: u64,
    base_uri: String,
    collection_uri: String,
) {
    <b>assert</b>!(<a href="_address_of">signer::address_of</a>(<a href="">account</a>) == @<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>, <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EUNAUTHORIZED">EUNAUTHORIZED</a>));
    <b>assert</b>!(!<b>exists</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>), <a href="_already_exists">error::already_exists</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMODULE_STORE_ALREADY_PUBLISHED">EMODULE_STORE_ALREADY_PUBLISHED</a>));
    <b>let</b> constructor_ref = <a href="_create_named_object">object::create_named_object</a>(<a href="">account</a>, b"<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>");
    <b>let</b> creator = <a href="_generate_signer">object::generate_signer</a>(&constructor_ref);
    <b>let</b> creator_extend_ref = <a href="_generate_extend_ref">object::generate_extend_ref</a>(&constructor_ref);

    <a href="_create_collection_object">initia_nft::create_collection_object</a>(
        &creator,
        <a href="_utf8">string::utf8</a>(b"Initia Usernames"),
        <a href="_none">option::none</a>(),
        <a href="_utf8">string::utf8</a>(b"Initia Usernames"),
        collection_uri,
        <b>false</b>,
        <b>false</b>,
        <b>false</b>,
        <b>true</b>,
        <b>true</b>,
        <a href="_zero">bigdecimal::zero</a>(),
    );

    <b>let</b> constructor_ref = <a href="_create_object">object::create_object</a>(@initia_std, <b>false</b>);
    <b>let</b> pool = <a href="_address_from_constructor_ref">object::address_from_constructor_ref</a>(&constructor_ref);

    <b>assert</b>!(min_duration &lt; <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_EXPIRATION">MAX_EXPIRATION</a>, <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_DURATION">EMIN_DURATION</a>));

    <b>move_to</b>(
        <a href="">account</a>,
        <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
            name_to_token: <a href="_new">table::new</a>(),
            name_to_addr: <a href="_new">table::new</a>(),
            addr_to_name: <a href="_new">table::new</a>(),
            creator_extend_ref,
            pool,
            config: <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_Config">Config</a> {
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
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_config"></a>

## Function `update_config`



<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_config">update_config</a>(chain: &<a href="">signer</a>, price_per_year_3char: <a href="_Option">option::Option</a>&lt;u64&gt;, price_per_year_4char: <a href="_Option">option::Option</a>&lt;u64&gt;, price_per_year_default: <a href="_Option">option::Option</a>&lt;u64&gt;, min_duration: <a href="_Option">option::Option</a>&lt;u64&gt;, grace_period: <a href="_Option">option::Option</a>&lt;u64&gt;, base_uri: <a href="_Option">option::Option</a>&lt;<a href="_String">string::String</a>&gt;)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_config">update_config</a>(
    chain: &<a href="">signer</a>,
    price_per_year_3char: Option&lt;u64&gt;,
    price_per_year_4char: Option&lt;u64&gt;,
    price_per_year_default: Option&lt;u64&gt;,
    min_duration: Option&lt;u64&gt;,
    grace_period: Option&lt;u64&gt;,
    base_uri: Option&lt;String&gt;,
) <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>assert</b>!(<a href="_address_of">signer::address_of</a>(chain) == @<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>, <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EUNAUTHORIZED">EUNAUTHORIZED</a>));

    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);

    <b>if</b> (<a href="_is_some">option::is_some</a>(&price_per_year_3char)) {
        module_store.config.price_per_year_3char = <a href="_extract">option::extract</a>(&<b>mut</b> price_per_year_3char);
    };

    <b>if</b> (<a href="_is_some">option::is_some</a>(&price_per_year_4char)) {
        module_store.config.price_per_year_4char = <a href="_extract">option::extract</a>(&<b>mut</b> price_per_year_4char);
    };

    <b>if</b> (<a href="_is_some">option::is_some</a>(&price_per_year_default)) {
        module_store.config.price_per_year_default = <a href="_extract">option::extract</a>(&<b>mut</b> price_per_year_default);
    };

    <b>if</b> (<a href="_is_some">option::is_some</a>(&min_duration)) {
        <b>let</b> min_duration = <a href="_extract">option::extract</a>(&<b>mut</b> min_duration);
        <b>assert</b>!(min_duration &lt; <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_EXPIRATION">MAX_EXPIRATION</a>, <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_DURATION">EMIN_DURATION</a>));
        module_store.config.min_duration = min_duration;
    };

    <b>if</b> (<a href="_is_some">option::is_some</a>(&grace_period)) {
        module_store.config.grace_period = <a href="_extract">option::extract</a>(&<b>mut</b> grace_period);
    };

    <b>if</b> (<a href="_is_some">option::is_some</a>(&base_uri)) {
        module_store.config.base_uri = <a href="_extract">option::extract</a>(&<b>mut</b> base_uri);
    };
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_register_domain"></a>

## Function `register_domain`



<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_register_domain">register_domain</a>(<a href="">account</a>: &<a href="">signer</a>, domain_name: <a href="_String">string::String</a>, duration: u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_register_domain">register_domain</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    domain_name: String,
    duration: u64,
) <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> addr = <a href="_address_of">signer::address_of</a>(<a href="">account</a>);

    // check expiration
    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    <b>let</b> (_height, <a href="">timestamp</a>) = <a href="_get_block_info">block::get_block_info</a>();

    domain_name = <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_to_lower_case">to_lower_case</a>(&domain_name);

    <b>assert</b>!(
        duration &gt;= module_store.config.min_duration,
        <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_DURATION">EMIN_DURATION</a>),
    );

    <b>assert</b>!(
        duration &lt;= <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_EXPIRATION">MAX_EXPIRATION</a>,
        <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMAX_EXPIRATION">EMAX_EXPIRATION</a>),
    );

    <b>let</b> creator = &<a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&module_store.creator_extend_ref);

    <b>if</b> (<a href="_contains">table::contains</a>(&module_store.name_to_token, domain_name)) {
        <b>let</b> token = *<a href="_borrow">table::borrow</a>(&module_store.name_to_token, domain_name);
        <b>let</b> expiration_date = <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date">metadata::get_expiration_date</a>(token);

        <b>assert</b>!(
            expiration_date + module_store.config.grace_period &lt; <a href="">timestamp</a>,
            <a href="_already_exists">error::already_exists</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EDOMAIN_NAME_ALREADY_EXISTS">EDOMAIN_NAME_ALREADY_EXISTS</a>),
        );

        // remove name_to_token
        <a href="_remove">table::remove</a>(&<b>mut</b> module_store.name_to_token, domain_name);
        <b>let</b> token_uri = module_store.config.base_uri;
        <a href="_append">string::append</a>(&<b>mut</b> token_uri, <a href="_utf8">string::utf8</a>(b"expired"));
        <a href="_set_uri">initia_nft::set_uri</a>(creator, <a href="_address_to_object">object::address_to_object</a>&lt;Nft&gt;(token), token_uri);

        // remove record
        <b>if</b> (<a href="_contains">table::contains</a>(&module_store.name_to_addr, domain_name)) {
            <b>let</b> former_addr = <a href="_remove">table::remove</a>(&<b>mut</b> module_store.name_to_addr, domain_name);
            <a href="_remove">table::remove</a>(&<b>mut</b> module_store.addr_to_name, former_addr);
        }
    };

    <b>let</b> name = domain_name;
    <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_check_name">check_name</a>(name);
    <a href="_append_utf8">string::append_utf8</a>(&<b>mut</b> name, <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_TLD">TLD</a>);
    <a href="_append_utf8">string::append_utf8</a>(&<b>mut</b> name, b".");
    <a href="_append">string::append</a>(&<b>mut</b> name, <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_u64_to_string">u64_to_string</a>(<a href="">timestamp</a>));

    <b>let</b> token_uri = module_store.config.base_uri;
    <a href="_append">string::append</a>(&<b>mut</b> token_uri, domain_name);
    <b>let</b> (_, extend_ref) = <a href="_mint_nft_object">initia_nft::mint_nft_object</a>(
        creator,
        <a href="_utf8">string::utf8</a>(b"Initia Usernames"),
        <a href="_utf8">string::utf8</a>(b"Initia Usernames"),
        name,
        token_uri,
        <b>false</b>,
    );
    <b>let</b> token = <a href="_generate_signer_for_extending">object::generate_signer_for_extending</a>(&extend_ref);
    <b>let</b> token_addr = <a href="_address_from_extend_ref">object::address_from_extend_ref</a>(&extend_ref);
    <a href="_transfer_raw">object::transfer_raw</a>(creator, token_addr, addr);

    <a href="_add">table::add</a>(&<b>mut</b> module_store.name_to_token, domain_name, token_addr);
    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_create">metadata::create</a>(
        &token,
        <a href="">timestamp</a> + duration,
        name,
        <a href="">vector</a>[],
        <a href="">vector</a>[],
    );

    <b>let</b> cost_amount = <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_cost_amount">get_cost_amount</a>(domain_name, duration);
    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    <b>let</b> cost = <a href="_withdraw">primary_fungible_store::withdraw</a>(<a href="">account</a>, <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_init_metadata">get_init_metadata</a>(), cost_amount);
    <a href="_deposit">primary_fungible_store::deposit</a>(module_store.pool, cost);

    <a href="_emit">event::emit</a>(
        <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_RegisterEvent">RegisterEvent</a> {
            addr,
            domain_name,
            token: token_addr,
            expiration_date: <a href="">timestamp</a> + duration,
        },
    );
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_unset_name"></a>

## Function `unset_name`



<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_unset_name">unset_name</a>(<a href="">account</a>: &<a href="">signer</a>)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_unset_name">unset_name</a>(
    <a href="">account</a>: &<a href="">signer</a>,
) <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> addr = <a href="_address_of">signer::address_of</a>(<a href="">account</a>);
    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);

    <b>if</b> (<a href="_contains">table::contains</a>(&module_store.addr_to_name, addr)) {
        <b>let</b> removed_name = <a href="_remove">table::remove</a>(&<b>mut</b> module_store.addr_to_name, addr);
        <a href="_remove">table::remove</a>(&<b>mut</b> module_store.name_to_addr, removed_name);

        <a href="_emit">event::emit</a>(
            <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UnsetEvent">UnsetEvent</a> {
                addr,
                domain_name: removed_name,
            },
        );
    };
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_set_name"></a>

## Function `set_name`



<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_set_name">set_name</a>(<a href="">account</a>: &<a href="">signer</a>, domain_name: <a href="_String">string::String</a>)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_set_name">set_name</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    domain_name: String,
) <b>acquires</b>  <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> addr = <a href="_address_of">signer::address_of</a>(<a href="">account</a>);
    <b>let</b> (_height, <a href="">timestamp</a>) = <a href="_get_block_info">block::get_block_info</a>();
    domain_name = <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_to_lower_case">to_lower_case</a>(&domain_name);

    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    <b>let</b> token_addr = *<a href="_borrow">table::borrow</a>(&module_store.name_to_token, domain_name);
    <b>let</b> token_object = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(token_addr);
    <b>assert</b>!(<a href="_is_owner">object::is_owner</a>(token_object, addr), <a href="_permission_denied">error::permission_denied</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ENOT_OWNER">ENOT_OWNER</a>));

    <b>assert</b>!(
        <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date">metadata::get_expiration_date</a>(token_addr) &gt; <a href="">timestamp</a>,
        <a href="_permission_denied">error::permission_denied</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ETOKEN_EXPIRED">ETOKEN_EXPIRED</a>),
    );

    <b>if</b> (<a href="_contains">table::contains</a>(&module_store.name_to_addr, domain_name)) {
        <b>let</b> removed_addr = <a href="_remove">table::remove</a>(&<b>mut</b> module_store.name_to_addr, domain_name);
        <a href="_remove">table::remove</a>(&<b>mut</b> module_store.addr_to_name, removed_addr);
    };

    <b>if</b> (<a href="_contains">table::contains</a>(&module_store.addr_to_name, addr)) {
        <b>let</b> removed_name = <a href="_remove">table::remove</a>(&<b>mut</b> module_store.addr_to_name, addr);
        <a href="_remove">table::remove</a>(&<b>mut</b> module_store.name_to_addr, removed_name);
    };

    <a href="_add">table::add</a>(&<b>mut</b> module_store.name_to_addr, domain_name, addr);
    <a href="_add">table::add</a>(&<b>mut</b> module_store.addr_to_name, addr, domain_name);

    <a href="_emit">event::emit</a>(
        <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_SetEvent">SetEvent</a> {
            addr,
            domain_name,
        },
    );
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_extend_expiration"></a>

## Function `extend_expiration`



<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_extend_expiration">extend_expiration</a>(<a href="">account</a>: &<a href="">signer</a>, domain_name: <a href="_String">string::String</a>, duration: u64)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_extend_expiration">extend_expiration</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    domain_name: String,
    duration: u64,
) <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> addr = <a href="_address_of">signer::address_of</a>(<a href="">account</a>);

    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    domain_name = <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_to_lower_case">to_lower_case</a>(&domain_name);
    <b>let</b> token = *<a href="_borrow">table::borrow</a>(&module_store.name_to_token, domain_name);

    <b>assert</b>!(
        duration &gt;= module_store.config.min_duration,
        <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMIN_DURATION">EMIN_DURATION</a>),
    );

    <b>let</b> (_height, <a href="">timestamp</a>) = <a href="_get_block_info">block::get_block_info</a>();
    <b>let</b> expiration_date = <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date">metadata::get_expiration_date</a>(token);

    // Not allow extend for expired one. Reregister indstead.
    <b>assert</b>!(expiration_date + module_store.config.grace_period &gt;= <a href="">timestamp</a>, <a href="_invalid_state">error::invalid_state</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ETOKEN_EXPIRED">ETOKEN_EXPIRED</a>));

    <b>let</b> new_expiration_date = <b>if</b> (expiration_date &gt; <a href="">timestamp</a>) {
        expiration_date + duration
    } <b>else</b> {
        <a href="">timestamp</a> + duration
    };

    <b>assert</b>!(
        new_expiration_date - <a href="">timestamp</a> &lt;= <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_MAX_EXPIRATION">MAX_EXPIRATION</a>,
        <a href="_invalid_argument">error::invalid_argument</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_EMAX_EXPIRATION">EMAX_EXPIRATION</a>),
    );

    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_expiration_date">metadata::update_expiration_date</a>(token, new_expiration_date);
    <b>let</b> cost_amount = <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_cost_amount">get_cost_amount</a>(domain_name, duration);
    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    <b>let</b> cost = <a href="_withdraw">primary_fungible_store::withdraw</a>(<a href="">account</a>, <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_get_init_metadata">get_init_metadata</a>(), (cost_amount <b>as</b> u64));
    <a href="_deposit">primary_fungible_store::deposit</a>(module_store.pool, cost);

    <a href="_emit">event::emit</a>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ExtendEvent">ExtendEvent</a>&gt;(
        <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ExtendEvent">ExtendEvent</a> {
            addr,
            domain_name,
            expiration_date: new_expiration_date,
        },
    );
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_records"></a>

## Function `update_records`



<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_records">update_records</a>(<a href="">account</a>: &<a href="">signer</a>, domain_name: <a href="_String">string::String</a>, record_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, record_values: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_update_records">update_records</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    domain_name: String,
    record_keys: <a href="">vector</a>&lt;String&gt;,
    record_values: <a href="">vector</a>&lt;String&gt;,
) <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> addr = <a href="_address_of">signer::address_of</a>(<a href="">account</a>);

    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    domain_name = <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_to_lower_case">to_lower_case</a>(&domain_name);

    <b>let</b> token = *<a href="_borrow">table::borrow</a>(&module_store.name_to_token, domain_name);
    <b>let</b> token_object = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(token);

    <b>let</b> (_height, <a href="">timestamp</a>) = <a href="_get_block_info">block::get_block_info</a>();
    <b>assert</b>!(
        <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date">metadata::get_expiration_date</a>(token) &gt; <a href="">timestamp</a>,
        <a href="_permission_denied">error::permission_denied</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ETOKEN_EXPIRED">ETOKEN_EXPIRED</a>),
    );

    <b>assert</b>!(<a href="_is_owner">object::is_owner</a>(token_object, addr), <a href="_permission_denied">error::permission_denied</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ENOT_OWNER">ENOT_OWNER</a>));

    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_records">metadata::update_records</a>(token, record_keys, record_values);
    <a href="_emit">event::emit</a>(
        <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_UpdateRecordsEvent">UpdateRecordsEvent</a> {
            addr,
            domain_name,
            keys: record_keys,
            values: record_values,
        },
    );
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_delete_records"></a>

## Function `delete_records`



<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_delete_records">delete_records</a>(<a href="">account</a>: &<a href="">signer</a>, domain_name: <a href="_String">string::String</a>, record_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;)
</code></pre>



##### Implementation


<pre><code><b>public</b> entry <b>fun</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_delete_records">delete_records</a>(
    <a href="">account</a>: &<a href="">signer</a>,
    domain_name: String,
    record_keys: <a href="">vector</a>&lt;String&gt;,
) <b>acquires</b> <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a> {
    <b>let</b> addr = <a href="_address_of">signer::address_of</a>(<a href="">account</a>);

    <b>let</b> module_store = <b>borrow_global_mut</b>&lt;<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ModuleStore">ModuleStore</a>&gt;(@<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames">usernames</a>);
    domain_name = <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_to_lower_case">to_lower_case</a>(&domain_name);

    <b>let</b> token = *<a href="_borrow">table::borrow</a>(&module_store.name_to_token, domain_name);
    <b>let</b> token_object = <a href="_address_to_object">object::address_to_object</a>&lt;Metadata&gt;(token);

    <b>let</b> (_height, <a href="">timestamp</a>) = <a href="_get_block_info">block::get_block_info</a>();
    <b>assert</b>!(
        <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date">metadata::get_expiration_date</a>(token) &gt; <a href="">timestamp</a>,
        <a href="_permission_denied">error::permission_denied</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ETOKEN_EXPIRED">ETOKEN_EXPIRED</a>),
    )
    ;
    <b>assert</b>!(<a href="_is_owner">object::is_owner</a>(token_object, addr), <a href="_permission_denied">error::permission_denied</a>(<a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_ENOT_OWNER">ENOT_OWNER</a>));

    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_delete_records">metadata::delete_records</a>(token, record_keys);
    <a href="_emit">event::emit</a>(
        <a href="name_service.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_usernames_DeleteRecordsEvent">DeleteRecordsEvent</a> {
            addr,
            domain_name,
            keys: record_keys,
        },
    );
}
</code></pre>
