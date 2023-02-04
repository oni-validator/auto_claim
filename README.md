## Get Script
`git clone https://github.com/oni-validator/auto_claim.git`
### Give Script Permissions
`cd auto_claim && chmod +x auto_claim.sh`
## Edit Variables 
```
#vars
DAEMON=gaiad
DENOM=uatom
DECIMALS=6
NODE=http://localhost:26657
CHAINID=cosmoshub-4
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
