elrond_wasm::derive_imports!();

#[derive(TopEncode, TopDecode, TypeAbi, PartialEq)]
pub enum LotteryStatus {
    Closed,
    Opened,
}