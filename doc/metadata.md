
<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata"></a>

# Module `0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef::metadata`



-  [Resource `Metadata`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata)
-  [Struct `TokenInfoResponse`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_TokenInfoResponse)
-  [Struct `MetadataResponse`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse)
-  [Constants](#@Constants_0)
-  [Function `get_metadata`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_metadata)
-  [Function `get_token_info`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_token_info)
-  [Function `create`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_create)
-  [Function `update_expiration_date`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_expiration_date)
-  [Function `update_records`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_records)
-  [Function `delete_records`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_delete_records)
-  [Function `get_expiration_date`](#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date)


<pre><code><b>use</b> <a href="">0x1::error</a>;
<b>use</b> <a href="">0x1::nft</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::vector</a>;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata"></a>

## Resource `Metadata`



<pre><code><b>struct</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> <b>has</b> key
</code></pre>



##### Fields


<dl>
<dt>
<code>expiration_date: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>record_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>record_values: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_TokenInfoResponse"></a>

## Struct `TokenInfoResponse`



<pre><code><b>struct</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_TokenInfoResponse">TokenInfoResponse</a>
</code></pre>



##### Fields


<dl>
<dt>
<code>token_id: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>token_uri: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>extension: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse">metadata::MetadataResponse</a></code>
</dt>
<dd>

</dd>
</dl>


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse"></a>

## Struct `MetadataResponse`



<pre><code><b>struct</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse">MetadataResponse</a> <b>has</b> drop
</code></pre>



##### Fields


<dl>
<dt>
<code>expiration_date: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>record_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>record_values: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


<a id="@Constants_0"></a>

## Constants


<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_EKEY_NOT_FOUND"></a>



<pre><code><b>const</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_EKEY_NOT_FOUND">EKEY_NOT_FOUND</a>: u64 = 2;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_ELENGTH_MISMATCH"></a>



<pre><code><b>const</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_ELENGTH_MISMATCH">ELENGTH_MISMATCH</a>: u64 = 0;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_EMAX_RECORD_EXCEED"></a>



<pre><code><b>const</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_EMAX_RECORD_EXCEED">EMAX_RECORD_EXCEED</a>: u64 = 1;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MAX_RECORD"></a>



<pre><code><b>const</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MAX_RECORD">MAX_RECORD</a>: u64 = 10;
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_metadata"></a>

## Function `get_metadata`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_metadata">get_metadata</a>(addr: <b>address</b>): <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse">metadata::MetadataResponse</a>
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_metadata">get_metadata</a>(addr: <b>address</b>): <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse">MetadataResponse</a> <b>acquires</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> {
    <b>let</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a> = <b>borrow_global</b>&lt;<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a>&gt;(addr);
    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse">MetadataResponse</a> {
        expiration_date: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.expiration_date,
        name: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.name,
        record_keys: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_keys,
        record_values: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_values,
    }
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_token_info"></a>

## Function `get_token_info`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_token_info">get_token_info</a>(addr: <b>address</b>): <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_TokenInfoResponse">metadata::TokenInfoResponse</a>
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_token_info">get_token_info</a>(addr: <b>address</b>): <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_TokenInfoResponse">TokenInfoResponse</a> <b>acquires</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> {
    <b>let</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a> = <b>borrow_global</b>&lt;<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a>&gt;(addr);
    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_TokenInfoResponse">TokenInfoResponse</a> {
        token_id: addr,
        token_uri: <a href="_uri">nft::uri</a>(<a href="_address_to_object">object::address_to_object</a>&lt;Nft&gt;(addr)),
        extension: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MetadataResponse">MetadataResponse</a> {
            expiration_date: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.expiration_date,
            name: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.name,
            record_keys: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_keys,
            record_values: <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_values,
        }
    }
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_create"></a>

## Function `create`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_create">create</a>(token: &<a href="">signer</a>, expiration_date: u64, name: <a href="_String">string::String</a>, record_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, record_values: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;)
</code></pre>



##### Implementation


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_create">create</a>(
    token: &<a href="">signer</a>,
    expiration_date: u64,
    name: String,
    record_keys: <a href="">vector</a>&lt;String&gt;,
    record_values: <a href="">vector</a>&lt;String&gt;,
) {
    <b>move_to</b>(
        token,
        <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> {
            expiration_date,
            name,
            record_keys,
            record_values,
        },
    )

}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_expiration_date"></a>

## Function `update_expiration_date`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_expiration_date">update_expiration_date</a>(token: <b>address</b>, new_expiration_date: u64)
</code></pre>



##### Implementation


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_expiration_date">update_expiration_date</a>(
    token: <b>address</b>,
    new_expiration_date: u64,
) <b>acquires</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> {
    <b>let</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a> = <b>borrow_global_mut</b>&lt;<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a>&gt;(token);
    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.expiration_date = new_expiration_date;
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_records"></a>

## Function `update_records`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_records">update_records</a>(token: <b>address</b>, record_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;, record_values: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;)
</code></pre>



##### Implementation


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_update_records">update_records</a>(
    token: <b>address</b>,
    record_keys: <a href="">vector</a>&lt;String&gt;,
    record_values: <a href="">vector</a>&lt;String&gt;,
) <b>acquires</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> {
    <b>let</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a> = <b>borrow_global_mut</b>&lt;<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a>&gt;(token);
    <b>let</b> key_length = <a href="_length">vector::length</a>(&record_keys);
    <b>let</b> value_length = <a href="_length">vector::length</a>(&record_values);
    <b>assert</b>!(key_length == value_length, <a href="_invalid_argument">error::invalid_argument</a>(<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_ELENGTH_MISMATCH">ELENGTH_MISMATCH</a>));
    <b>let</b> index = 0;
    <b>while</b>(index &lt; key_length) {
        <b>let</b> (e, i) = <a href="_index_of">vector::index_of</a>(&<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_keys, <a href="_borrow">vector::borrow</a>(&record_keys, index));
        <b>if</b> (e) {
            <b>let</b> value = <a href="_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_values, i);
            *value = *<a href="_borrow">vector::borrow</a>(&record_values, index);
        } <b>else</b> {
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_keys, *<a href="_borrow">vector::borrow</a>(&record_keys, index));
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_values, *<a href="_borrow">vector::borrow</a>(&record_values, index));
        };
        index = index + 1;
    };

    <b>assert</b>!(<a href="_length">vector::length</a>(&<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_keys) &lt;= <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_MAX_RECORD">MAX_RECORD</a>, <a href="_invalid_state">error::invalid_state</a>(<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_EMAX_RECORD_EXCEED">EMAX_RECORD_EXCEED</a>));
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_delete_records"></a>

## Function `delete_records`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_delete_records">delete_records</a>(token: <b>address</b>, record_keys: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;)
</code></pre>



##### Implementation


<pre><code><b>public</b> (<b>friend</b>) <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_delete_records">delete_records</a>(
    token: <b>address</b>,
    record_keys: <a href="">vector</a>&lt;String&gt;,
) <b>acquires</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> {
    <b>let</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a> = <b>borrow_global_mut</b>&lt;<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a>&gt;(token);
    <b>let</b> length = <a href="_length">vector::length</a>(&record_keys);
    <b>let</b> index = 0;
    <b>while</b>(index &lt; length) {
        <b>let</b> (e, i) = <a href="_index_of">vector::index_of</a>(&<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_keys, <a href="_borrow">vector::borrow</a>(&record_keys, index));
        <b>assert</b>!(e, <a href="_not_found">error::not_found</a>(<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_EKEY_NOT_FOUND">EKEY_NOT_FOUND</a>));
        <a href="_remove">vector::remove</a>(&<b>mut</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_keys, i);
        <a href="_remove">vector::remove</a>(&<b>mut</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.record_values, i);
        index = index + 1;
    };
}
</code></pre>



<a id="0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date"></a>

## Function `get_expiration_date`



<pre><code><b>public</b> <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date">get_expiration_date</a>(token: <b>address</b>): u64
</code></pre>



##### Implementation


<pre><code><b>public</b> <b>fun</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_get_expiration_date">get_expiration_date</a>(token: <b>address</b>): u64 <b>acquires</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a> {
    <b>let</b> <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a> = <b>borrow_global</b>&lt;<a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata_Metadata">Metadata</a>&gt;(token);
    <a href="metadata.md#0x72ed9b26ecdcd6a21d304df50f19abfdbe31d2c02f60c84627844620a45940ef_metadata">metadata</a>.expiration_date
}
</code></pre>
