MYWALLET="erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96" #my wallet
PEM_FILE="/Users/Sebi/ElrondSC/Sc-CrowdFunding/walletTest.pem" #pem

declare -a TRANSACTIONS=(
  "erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96" #my wallet
)

#LKMEX-3b7d9a-6a

#Snapshot
declare -a wallet_distribution=(
  'erd1qqqqqqqqqqqqqpgqx0rcuxthkuzfxqdk7xrdkcs8vh94r5ysj0wqsa8m7k'
)

declare -a CONTRACT=(
  'erd1qqqqqqqqqqqqqpgqx0rcuxthkuzfxqdk7xrdkcs8vh94r5ysj0wqsa8m7k'
)
# DO NOT MODIFY ANYTHING FROM HERE ON 

PROXY="https://devnet-gateway.elrond.com"
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
      erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=15550000 --proxy=$PROXY --chain D --data ESDTNFTTransfer@4c4b4d45582d336237643961@6a@8ac7230489e80000@0000000000000000050033c78e1977b7049301b6f186db620765cb51d09093dc@6275795f7469636b6574@0a
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
      erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=15550000 --proxy=$PROXY --chain D --data ESDTNFTTransfer@5645474c442d326239333139@00@000000000000000005001318cbd13a26187be8a17e8077efaeb1c621395d8d8a@66756e64
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
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data ESDTTransfer@4152542d636563353264@015af1d78b58c40000@6275795f7469636b657473@01
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function claim-reward {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data claim_rewards@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function calculate-reward {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data calculate_reward@6290B890
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function withdraw-request {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data withdraw_request@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}

function claim-nft {
  for transaction in "${CONTRACT[@]}"; do
    set -- $transaction
    erdpy --verbose tx new --send --pem=$PEM_FILE --nonce=$NONCE --receiver=$1 --gas-limit=5550000 --proxy=$PROXY --chain D --data calim_nft@5450432d623165353562@04
    echo "Transaction sent with nonce $NONCE and backed up to bon-mission-tx-$NONCE.json."
    (( NONCE++ ))
  done
}