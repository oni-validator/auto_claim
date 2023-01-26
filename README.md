## Get Script
`git clone https://github.com/oni-validator/auto_claim.git`
### Give Script Permissions
`cd auto_claim && chmod +x auto_claim.sh`
## Edit Variables 
```
DAEMON=gaiad
DENOM=uatom
NODE=http://localhost:26656
CHAINID=cosmoshub-4
VALOPER=cosmosvaloper16s96n9k9zztdgjy8q4qcxp4hn7ww98qkrka4zk
ADDRESS=cosmos16s96n9k9zztdgjy8q4qcxp4hn7ww98qkxzfqw9
PASSWORD=supersecretpassword
KEYRING=mykeyring # gaiad keys list > name:
```
## Edit Claim Threshold 
`if [ "$TOTAL" -gt 10 ]` 

Edit value of 10 to desired integer, *whole value* not denom

## Run Script
`./auto_claim.sh`

## Run Script Every 12 Hours
`crontab -e`

`0 */12 * * * /path/to/autoclaim.sh`  <<< add to bottom of file and save

## Logs
Logs of successful tx's will be located in $HOME/claim.log
