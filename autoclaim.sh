#!/bin/bash

#vars
DAEMON=gaiad
DENOM=uatom
NODE=http://localhost:26656
CHAINID=cosmoshub-4
VALOPER=cosmosvaloper16s96n9k9zztdgjy8q4qcxp4hn7ww98qkrka4zk
ADDRESS=cosmos16s96n9k9zztdgjy8q4qcxp4hn7ww98qkxzfqw9
PASSWORD=supersecretpassword
KEYRING=mykeyring # gaiad keys list > name:

#query balance and set vars
BALANCE=$(echo "$($DAEMON q bank balances ${ADDRESS} --denom ${DENOM} --node ${NODE} -o json | jq -r '.amount') / 1000000" | bc -l | awk '{printf "%d", $1}')
#query commission and set var
COMMISSION="$($DAEMON q distribution commission ${VALOPER} --node ${NODE} -o json | jq -r ".commission[] | select(.denom==\"$DENOM\") | .amount")"
#query rewards and set var
REWARDS="$($DAEMON q distribution rewards ${ADDRESS} ${VALOPER} --node ${NODE} -o json | jq -r ".rewards[] | select(.denom==\"$DENOM\") | .amount")"
#set total and wallet
TOTAL=$(echo "(${COMMISSION:-0} + ${REWARDS:-0})/1000000" | bc | awk '{print int($1)}')
WALLET=$(echo "$($DAEMON q bank balances ${ADDRESS} --denom ${DENOM} --node ${NODE} --output json | jq -r .amount)")

#check if worth claiming, claim, and delegate if so
if [ "$TOTAL" -gt 10 ]
then
    #claim
    echo "${PASSWORD}" | ${DAEMON} tx distribution withdraw-rewards ${VALOPER} --commission --node ${NODE} --from ${KEYRING} --chain-id ${CHAINID}  --gas-prices 0.0025${DENOM} -y  >>  $HOME/claim.log
    echo "Total is greater than 10 is claiming. Keep the change you filthy animal"
    echo "Sleeping for 60 seconds."
    sleep 60
    #delegate
    echo "${PASSWORD}" | ${DAEMON} tx staking delegate ${VALOPER} ${WALLET}${DENOM} --from ${KEYRING} --node ${NODE} --chain-id ${CHAINID} --gas auto --gas-adjustment 1.25 --gas-prices 0.0025${DENOM} -y >>  $HOME/claim.log
else
    #not claiming
    echo "Total is less than or equal to 10 not claiming. You're Poor!!"    
fi
