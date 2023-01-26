#!/bin/bash

#vars
DAEMON=gaiad
DENOM=uatom
DECIMALS=6
NODE=http://localhost:26657
CHAINID=cosmoshub-4
PASSWORD=supersecretpassword
KEYRING=mykeyring # gaiad keys list > name:

#lookup address, and fetch valoper
ADDRESS="$(echo "${PASSWORD}" |  ${DAEMON} keys list --output json | jq -r ".[] | select(.name == \"${KEYRING}\") | .address")"
BECHBYTES="$(${DAEMON} keys parse ${ADDRESS} --output json | jq -r '.bytes')"
VALOPER="$(${DAEMON} keys parse ${BECHBYTES} --output json | jq -r '.formats[2]')"

#query commission
COMMISSION="$($DAEMON q distribution commission ${VALOPER} --node ${NODE} -o json | jq -r ".commission[] | select(.denom==\"$DENOM\") | .amount | tonumber / pow(10;$DECIMALS)")"
#query rewards
REWARDS="$($DAEMON q distribution rewards ${ADDRESS} ${VALOPER} --node ${NODE} -o json | jq -r ".rewards[] | select(.denom==\"$DENOM\") | .amount | tonumber / pow(10;$DECIMALS)")"
#set total and wallet
TOTAL="$(echo "scale=0; (${COMMISSION:-0} + ${REWARDS:-0}) / 1" | bc -l)"
#check if worth claiming, claim, and delegate if so
if [ "$TOTAL" -gt 10 ]
then
    DELEGATING="$(echo "scale=0; $TOTAL * ( 10 ^ ${DECIMALS} ) / 1" | bc -l)"
    #log what we're trying to do and when
    echo "$(date -u), claiming $TOTAL" >> $HOME/claim.log
    #claim
    echo "${PASSWORD}" | ${DAEMON} tx distribution withdraw-rewards ${VALOPER} --commission --node ${NODE} --from ${KEYRING} --chain-id ${CHAINID}  --gas-prices 0.0025${DENOM} -y --broadcast-mode block >>  $HOME/claim.log
    #delegate
    echo "${PASSWORD}" | ${DAEMON} tx staking delegate ${VALOPER} ${DELEGATING}${DENOM} --from ${KEYRING} --node ${NODE} --chain-id ${CHAINID} --gas auto --gas-adjustment 1.25 --gas-prices 0.0025${DENOM} -y --broadcast-mode block >>  $HOME/claim.log
else
    #not claiming
    echo "Total is less than or equal to 10 not claiming. NGMI!"    
fi
