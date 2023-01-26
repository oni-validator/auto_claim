#!/bin/bash

#vars
DAEMON=gaiad
DENOM=uatom
NODE=http://localhost:26656
CHAINID=cosmoshub-4
VALOPER=cosmosvaloper16s96n9k9zztdgjy8q4qcxp4hn7ww98qkrka4zk
ADDRESS=cosmos16s96n9k9zztdgjy8q4qcxp4hn7ww98qkxzfqw9
RELAYER_ADDRESS=cosmos1ajevnf3wa5y884ajnfk292mcqyth6qeexck03l
PASSWORD=supersecretpassword
KEYRING=mykeyring # gaiad keys list > name:

#query balance and set vars
BALANCE=$(echo "$($DAEMON q bank balances ${ADDRESS} --denom ${DENOM} --node ${NODE} -o json | jq -r '.amount') / 1000000" | bc -l | awk '{printf "%d", $1}')
#query commission and set var
COMMISSION="$($DAEMON q distribution commission ${VALOPER} --node ${NODE} -o json | jq -r ".commission[] | select(.denom==\"$DENOM\") | .amount")"
#query rewards and set var
REWARDS="$($DAEMON q distribution rewards ${ADDRESS} ${VALOPER} --node ${NODE} -o json | jq -r ".rewards[] | select(.denom==\"$DENOM\") | .amount")"
#wallets
WALLET=$(echo "$($DAEMON q bank balances ${ADDRESS} --denom ${DENOM} --node ${NODE} --output json | jq -r .amount)")
RELAYER_WALLET=$(echo "$($DAEMON q bank balances ${RELAYER_ADDRESS} --denom ${DENOM} --node ${NODE} --output json | jq -r .amount)")
#totals
REWARDS_TOTAL=$(echo "(${COMMISSION:-0} + ${REWARDS:-0})/1000000" | bc | awk '{print int($1)}')
RELAYER_TOTAL=$(echo "(${RELAYER_WALLET:-0})/1000000" | bc | awk '{print int($1)}')
#split the difference
VALIDATOR=$(echo "($WALLET * 0.95)/1" | bc)
RELAYER=$(echo "($WALLET * 0.05)/1" | bc)



#check if worth claiming, claim, and delegate if so
if [ "$REWARDS_TOTAL" -gt 10 ]
then
    #claim
    echo "${PASSWORD}" | ${DAEMON} tx distribution withdraw-rewards ${VALOPER} --commission --node ${NODE} --from ${KEYRING} --chain-id ${CHAINID}  --gas-prices 0.0025${DENOM} -y  >>  $HOME/claim.log
    echo "Total is greater than 10 is claiming. Keep the change you filthy animal"
    echo "Sleeping for 90 seconds, just to make sure....."
    sleep 90
if [ "$RELAYER_TOTAL" -gt 5 ]
then
    #delegate all to validator
    echo "${PASSWORD}" | ${DAEMON} tx staking delegate ${VALOPER} ${WALLET}${DENOM} --from ${KEYRING} --node ${NODE} --chain-id ${CHAINID} --gas auto --gas-adjustment 1.25 --gas-prices 0.0025${DENOM} -y >>  $HOME/claim.log
else
    #delegate and send rest to relayer
    echo "${PASSWORD}" | ${DAEMON} tx staking delegate ${VALOPER} ${VALIDATOR}${DENOM} --from ${KEYRING} --node ${NODE} --chain-id ${CHAINID} --gas auto --gas-adjustment 1.25 --gas-prices 0.0025${DENOM} -y >>  $HOME/claim.log
    echo "${PASSWORD}" | ${DAEMON} tx bank send ${KEYRING} ${RELAYER_ADDRESS} ${RELAYER}${DENOM} --node ${NODE} --chain-id ${CHAINID} --gas auto --gas-adjustment 1.25 --gas-prices 0.0025${DENOM} -y >>  $HOME/claim.log
fi
else
    #not claiming
    echo "Total is less than or equal to 10 not claiming. You're Poor!!"    
fi
