MYWALLET="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletTest.pem"
ALICE="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletTest.pem"
BOB="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletTest.pem"
WASM_PATH="/Users/Sebi/xCarSwap/xCarSwap-sc/output/mylotterynft.wasm"

ADDRESS=erd1qqqqqqqqqqqqqpgq0g33dj3355dfju46seksy5fx5dhm7mh8j0wqezud3x #$(mxpy data load --key=address-testnet)
DEPLOY_TRANSACTION=$(mxpy data load --key=deployTransaction-testnet)
PROXY=https://devnet-api.multiversx.com

# ✓ 5% - Elrond Bunny NFTs Rewards - erd14xkt5ey728ns3a080j5garvr3ysuy843gefh585x4qhd5jkfehfqh6xe52 
# ✓ 2% - Elrond Bunny Team - erd13qfgytath74hjda4d3qxywma5w6cl0hzzmuqy028e2zc3udp0mwsrthdt4
# ✓ 2% - Elrond Lottery Marketing - erd10w6hhwd5kdafzfg8t96skxha6suepnfcx54epfasykv3x5yfqtnqmy4vlr
# ✓ 1% - JEXchange Fees Wallet - erd1272et87h3sa7hlg5keuswh50guz2ngmd6lhmjxkwwu0ah6gdds5qhka964

# 10% -vegld erd1vj40fxw0yah34mmdxly7l28w097ju6hf8pczpcdxs05n2vyx8hcspyxm2c
# 5% -echipa erd13qfgytath74hjda4d3qxywma5w6cl0hzzmuqy028e2zc3udp0mwsrthdt4
# 5% -bunnys erd14xkt5ey728ns3a080j5garvr3ysuy843gefh585x4qhd5jkfehfqh6xe52

DEPLOY_GAS="80000000"
TARGET=500000000000000000
DEADLINE_UNIX_TIMESTAMP=1651066120  # Fri Jan 01 2021 00:00:00 GMT+0200 (Eastern European Standard Time)
EGLD_TOKEN_ID=0x45474c44 # "EGLD"

deploy() {
    local MAXTICKETPRICEPERWALLET=0x14 # 20
    local TICKETPRICE=0x2FAF080 # 50$ 
    local MAXTICKETSPERLOTTERY=0x07D0 # 2000
    local TOKEN_ID=0x555344432d386434303638 #USDC-8d4068

    mxpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${ALICE} \
          --gas-limit=${DEPLOY_GAS} \
          --outfile="/Users/Sebi/ElrondSC/lotterynft/deploy-testnet.interaction.json" --send --proxy=${PROXY} --chain=D --arguments ${MAXTICKETPRICEPERWALLET} ${TICKETPRICE} ${MAXTICKETSPERLOTTERY} ${TOKEN_ID} || return

    TRANSACTION=$(mxpy data parse --file="deploy-testnet.interaction.json" --expression="data['emittedTransactionHash']")
    ADDRESS=$(mxpy data parse --file="deploy-testnet.interaction.json" --expression="data['contractAddress']")

    mxpy data store --key=address-testnet --value=${ADDRESS}
    mxpy data store --key=deployTransaction-testnet --value=${TRANSACTION}

    echo ""
    echo "Smart contract address: ${ADDRESS}"
}

upgradeSC() {
    local MAXTICKETPRICEPERWALLET=0x14 # 20
    local TICKETPRICE=0x2FAF080 # 50$ 
    local MAXTICKETSPERLOTTERY=0x07D0 # 2000
    local TOKEN_ID=0x555344432d386434303638 #USDC-8d4068
    
    mxpy --verbose contract upgrade ${ADDRESS} --recall-nonce \
        --bytecode=${WASM_PATH} \
        --pem=${BOB} \
        --gas-limit=60000000 \
        --proxy=${PROXY} --chain=D \
         --arguments ${MAXTICKETPRICEPERWALLET} ${TICKETPRICE} ${MAXTICKETSPERLOTTERY} ${TOKEN_ID} \
        --send || return
}

checkDeployment() {
    mxpy tx get --hash=$DEPLOY_TRANSACTION --omit-fields="['data', 'signature']" --proxy=${PROXY}
    mxpy account get --address=$ADDRESS --omit-fields="['code']" --proxy=${PROXY}
}

withdraw_lkmex(){
        mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="withdraw_lkmex" \
        --proxy=${PROXY} --chain=D \
        --send
}
#ART-cec52d
change_tokenid(){
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="change_token_id" \
        --proxy=${PROXY} --chain=D \
        --arguments str:ART-cec52d \
        --send
}

getNoncesLkmex() {
    mxpy --verbose contract query ${ADDRESS} --function="getNoncesLkmex" --proxy=${PROXY} 
}

clear_lkmex(){
          mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="clear_lkmex" \
        --proxy=${PROXY} --chain=D \
        --send 
}

# ALICE claims
startlottery() {
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=100000000 \
        --function="start_lottery" \
        --proxy=${PROXY} --chain=D \
        --arguments 1675341916 2\
        --send
}

setMarketingWallet() {
    local BOB_ADDRESS_BECH32=erd1vj40fxw0yah34mmdxly7l28w097ju6hf8pczpcdxs05n2vyx8hcspyxm2c
    local BOB_ADDRESS_HEX=0x$(mxpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="setmarketingwallet" \
        --proxy=${PROXY} --chain=D \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setTeam() {
    local BOB_ADDRESS_BECH32=erd13qfgytath74hjda4d3qxywma5w6cl0hzzmuqy028e2zc3udp0mwsrthdt4
    local BOB_ADDRESS_HEX=0x$(mxpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="setteamwallet" \
        --proxy=${PROXY} --chain=D \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setNftHolders() {
    local BOB_ADDRESS_BECH32=erd14xkt5ey728ns3a080j5garvr3ysuy843gefh585x4qhd5jkfehfqh6xe52
    local BOB_ADDRESS_HEX=0x$(mxpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="setnftwallet" \
        --proxy=${PROXY} --chain=D \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setecfwallet() {
    local BOB_ADDRESS_BECH32=erd1qhymgtkzlp2ej74qspz4cxvpu5wcsljq6euawh4z42ur5anvdqps8qvgvk
    local BOB_ADDRESS_HEX=0x$(mxpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="setecfwallet" \
        --proxy=${PROXY} --chain=D \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setowner(){
    local BOB_ADDRESS_BECH32=erd1lz29ug45hy975wjjjey4aupwmzxycgx5kavajmray9ezh22uhtfs2a3gl0
    local BOB_ADDRESS_HEX=0x$(mxpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="setowner" \
        --proxy=${PROXY} --chain=D \
        --arguments ${BOB_ADDRESS_HEX} \
        --send
}

setMaxTicket() {
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="set_maxtickets_per_wallet" \
        --proxy=${PROXY} --chain=D \
        --arguments 1000 \
        --send
}

setPrice_nou() {
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="set_price" \
        --proxy=${PROXY} --chain=D \
        --arguments 50000000000000000000 \
        --send
}

change_Deadline() {
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=20000000 \
        --function="change_deadline" \
        --proxy=${PROXY} --chain=D \
        --arguments 259200 \
        --send
}

set_maxtickets_per_wallet(){
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=20000000 \
        --function="set_maxtickets_per_wallet" \
        --proxy=${PROXY} --chain=D \
        --arguments 100 \
        --send
}
setPrize() {
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="set_prizepool" \
        --proxy=${PROXY} --chain=D \
        --arguments 5000000000000000000 \
        --send
}

fund_sc() {
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="fund" --value=2000000000000000000\
        --proxy=${PROXY} --chain=D \
        --send
}

set_maxtickets_per_lottery() {
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="set_maxtickets_per_lottery" \
        --proxy=${PROXY} --chain=D \
        --arguments 100 \
        --send
}

# BOB sends funds
buyTicket_BOB() {
    mxpy --verbose contract call $ADDRESS --recall-nonce --pem=${BOB} --gas-limit=20000000 \
        --function="buy_ticket" --value=100000000000000000 \
        --proxy=${PROXY} --chain=D \
        --arguments 1 \
        --send
}

buyAlice() {
    mxpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=20000000 \
        --function="buy_ticket" --value=200000000000000000 \
        --proxy=${PROXY} --chain=D \
        --arguments 2 \
        --send
}

set_esdt_storage(){
    mxpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=20000000 \
        --function="set_esdt_storage" --value=0 \
        --proxy=${PROXY} --chain=D \
        --arguments 2 50000000000000000000 \
        --send
}
getCounterTickets() {
    mxpy --verbose contract query ${ADDRESS} --function="getCounterTickets" --proxy=${PROXY} 
}

getWinnersEsdt(){
    mxpy --verbose contract query ${ADDRESS} --function="getWinnersEsdt" --proxy=${PROXY} --arguments 1
}

getVolume() {
    mxpy --verbose contract query ${ADDRESS} --function="getVolume" --proxy=${PROXY} 
}

getAllWinners() {
    mxpy --verbose contract query ${ADDRESS} --function="getAllWinners" --proxy=${PROXY} 
}

getTicketHolderUnique() {
    mxpy --verbose contract query ${ADDRESS} --function="getTicketHolderUnique" --proxy=${PROXY} 
}


winner() {
    mxpy --verbose contract call $ADDRESS --recall-nonce --pem=${BOB} --gas-limit=100_000_000 \
        --function="draw_winner" --value=0 \
        --proxy=${PROXY} --chain=D \
        --send \
}

getTicketsPerAddress() {
    local BOB_ADDRESS_BECH32=erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96
    local BOB_ADDRESS_HEX=0x$(mxpy wallet bech32 --decode ${BOB_ADDRESS_BECH32})
    mxpy --verbose contract query ${ADDRESS} --function="getTicketsPerAddress" --proxy=${PROXY} --arguments ${BOB_ADDRESS_HEX} 1 \
}

getCurrentFunds() {
    mxpy --verbose contract query ${ADDRESS} --function="getCurrentFunds" --proxy=${PROXY} 
}

getTime() {
    mxpy --verbose contract query ${ADDRESS} --function="getTime" --proxy=${PROXY} 
}


getTicketPrice() {
    mxpy --verbose contract query ${ADDRESS} --function="getTicketPrice" --proxy=${PROXY} 
}

getDeadline() {
    mxpy --verbose contract query ${ADDRESS} --function="getDeadline" --proxy=${PROXY} 
}

getPrize() {
    mxpy --verbose contract query ${ADDRESS} --function="getPrize" --proxy=${PROXY}
}

getTicketHolder() {
    mxpy --verbose contract query ${ADDRESS} --function="getTicketHolder" --proxy=${PROXY}
}

getMaxTicketsPerAddress() {
    mxpy --verbose contract query ${ADDRESS} --function="getMaxTicketsPerAddress" --proxy=${PROXY}
}

getMaxTickersPerLottery(){
    mxpy --verbose contract query ${ADDRESS} --function="getMaxTickersPerLottery" --proxy=${PROXY}
}

claimFunds() {
    mxpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function="claimfunds" \
        --proxy=${PROXY} --chain=D \
        --send
}

ChangeOwner(){
    mxpy --verbose contract call $ADDRESS --recall-nonce --pem=${ALICE} --gas-limit=10000000 \
        --function=ChangeOwnerAddress \
        --proxy=${PROXY} --chain=D \
        --arguments erd1lz29ug45hy975wjjjey4aupwmzxycgx5kavajmray9ezh22uhtfs2a3gl0 \
        --send
}

getCounterTickets() {
    mxpy --verbose contract query ${ADDRESS} --function="getCounterTickets" --proxy=${PROXY} 
}

getCounterLottery() {
    mxpy --verbose contract query ${ADDRESS} --function="getCounterLottery" --proxy=${PROXY} 
}

getVolume() {
    mxpy --verbose contract query ${ADDRESS} --function="getVolume" --proxy=${PROXY} 
}

getWinners() {
    mxpy --verbose contract query ${ADDRESS} --function="getWinners" --proxy=${PROXY} 
}

getAllWinners() {
    mxpy --verbose contract query ${ADDRESS} --function="getAllWinners" --proxy=${PROXY} 
}

getTicketHolderUnique() {
    mxpy --verbose contract query ${ADDRESS} --function="getTicketHolderUnique" --proxy=${PROXY} 
}
#1654611120
get_Last_Winners() {
    mxpy --verbose contract query ${ADDRESS} --function="getLastWinners" --proxy=${PROXY} --arguments 1 \
}

getNftStorage(){
    mxpy --verbose contract query ${ADDRESS} --function="getNftStorage" --proxy=${PROXY} --arguments 0 \
}

getWinnersNb(){
    mxpy --verbose contract query ${ADDRESS} --function="getWinnersNb" --proxy=${PROXY} \
}


myPayableEndpoint() {
    method_name=str:buy_tickets
    my_token=str:$ART-cec52d
    token_amount=$25
    mxpy --verbose contract call ${ADDRESS} --recall-nonce \
        --pem=${ALICE} \
        --gas-limit=6000000 \
        --proxy=${PROXY} --chain=D \
        --function="ESDTTransfer" \
        --arguments $my_token $token_amount $method_name 0x01\
        --send || return
}

clean_winners(){
    mxpy --verbose contract call ${ADDRESS} --recall-nonce --pem=${BOB} --gas-limit=10000000 \
        --function="clean_counter" \
        --proxy=${PROXY} --chain=D \
        --send
}

FIRST_BIGUINT_ARGUMENT=2
SECOND_BIGUINT_ARGUMENT=10000

fund_nft() {
    user_address="$(mxpy wallet pem-address $MYWALLET)"
    method_name=str:fund_nft
    sft_token=str:FACES-dd0aec
    sft_token_nonce=52
    sft_token_amount=1
    destination_address=$ADDRESS
    mxpy --verbose contract call $user_address --recall-nonce \
        --pem=${MYWALLET} \
        --gas-limit=100000000 \
        --proxy=${PROXY} --chain=D \
        --function="ESDTNFTTransfer" \
        --arguments $sft_token  $sft_token_nonce \
                    $sft_token_amount \
                    $destination_address \
                    $method_name \
                    ${FIRST_BIGUINT_ARGUMENT} \
        --send || return
}

# fund_nft