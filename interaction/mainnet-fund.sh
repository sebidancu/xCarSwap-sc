MYWALLET="erd15w9l8n5z2zltmgwdpdwf5ythc66st9nkwv33mhvxl4k078t63k9qa8wauy" #my wallet
PEM_FILE="/Users/Sebi/Bunny/lkmex-wallet.pem" #pem

declare -a TRANSACTIONS=(
  "erd1qqqqqqqqqqqqqpgqzvvvh5f6ycv8h69p06q80mawk8rzzw2a3k9qhck3xk" #my wallet
)

#LKMEX-3b7d9a-6a

#Snapshot
declare -a wallet_distribution=(
  'erd1qqqqqqqqqqqqqpgqzvvvh5f6ycv8h69p06q80mawk8rzzw2a3k9qhck3xk'
)

declare -a CONTRACT=(
  'erd1qqqqqqqqqqqqqpgqzvvvh5f6ycv8h69p06q80mawk8rzzw2a3k9qhck3xk'
)
# DO NOT MODIFY ANYTHING FROM HERE ON 

PROXY="https://api.multiversx.com"
DENOMINATION="000000000000000000"



# We recall the nonce of the wallet
NONCE=$(erdpy account get --nonce --address="$MYWALLET" --proxy="$PROXY")

function send-nft {
  for transaction in "${TRANSACTIONS[@]}"; do
    n=0
    while [ $n -le 0 ] #nr de adrese in snapshot
      do
      erdpy data store --key=address-devnet --value=$(erdpy wallet bech32 --decode ${wallet_distribution[n]} ) #transforma adresa din snapshot in hex
      echo ADDRESS=$(erdpy data load --key=address-devnet)
    
      set -- $transaction
      erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=15550000 --proxy=$PROXY --chain 1 --data ESDTNFTTransfer@4c4b4d45582d336237643961@6a@8ac7230489e80000@0000000000000000050033c78e1977b7049301b6f186db620765cb51d09093dc@6275795f7469636b6574@0a
      echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
      (( NONCE++ ))
      n=$(( n+1 ))
      
      #sleep 20
    done
  done
}

# ESDTNFTTransfer
function fund-esdt {
  for transaction in "${TRANSACTIONS[@]}"; do
    n=0
    while [ $n -le 0 ] #nr de adrese in snapshot
      do
      erdpy data store --key=address-devnet --value=$(erdpy wallet bech32 --decode ${wallet_distribution[n]} ) #transforma adresa din snapshot in hex
      echo ADDRESS=$(erdpy data load --key=address-devnet)
    
      set -- $transaction
      erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=15550000 --proxy=$PROXY --chain 1 --data ESDTTransfer@5645474c442d326239333139@56bc75e2d6310000@66756e64
      echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
      (( NONCE++ ))
      n=$(( n+1 ))
      
      #sleep 20
    done
  done
}

function buy-ticket {
  for transaction in "${wallet_distribution[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain 1 --data ESDTTransfer@4152542d636563353264@015af1d78b58c40000@6275795f7469636b657473@01
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function claim-reward {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain 1 --data claim_rewards@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function calculate-reward {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain 1 --data calculate_reward@6290B890
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function withdraw-request {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain 1 --data withdraw_request@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function claim-nft {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain 1 --data calim_nft@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}