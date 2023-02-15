use elrond_wasm::{
    api::ManagedTypeApi,
    types::{TokenIdentifier},
};

elrond_wasm::derive_imports!();

#[derive(NestedEncode, NestedDecode, TopEncode, TopDecode, TypeAbi)]

pub struct NftInfo<M: ManagedTypeApi> {
    pub token_identifier: TokenIdentifier<M>,
    pub nft_nonce: u64
}
