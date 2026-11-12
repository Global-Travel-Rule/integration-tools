#
# Copyright (c) 2025 Global Travel Rule • globaltravelrule.com
# License that can be found in the LICENSE file.
#
# Author: Global Travel Rule developer
# Created on: 2025/12/22 17:30
#

set -e

#!/bin/bash
set -e

# parameter setup
secretKey="[secretKey]"
vaspCode="[vaspCode]"
accessKey="[accessKey]"

# expire time from your local, please mind that the clock could have difference, suggest to be 120 second
# please be sure your server has configre the correct time with NTP
expires=120 

# fixed type
verifyType=1

# nonce (UUID)
nonce=$(uuidgen | tr '[:upper:]' '[:lower:]')

# generate timestamp (13 digits)
timestamp=$(($(date +%s%N)/1000000))

# compute vaspSecretKeyHash = sha512(secretKey + vaspCode)
vaspSecretKeyHash=$(echo -n "${secretKey}${vaspCode}" | openssl dgst -sha512 -binary | xxd -p -c 256)

# compute SecretToken = sha512(accessKey|vaspSecretKeyHash|nonce|timestamp|expires|verifyType)
stringToSign="${accessKey}|${vaspSecretKeyHash}|${nonce}|${timestamp}|${expires}|${verifyType}"
SecretToken=$(echo -n "${stringToSign}" | openssl dgst -sha512 -binary | xxd -p -c 256)

# combine JSON
json=$(cat <<EOF
{
  "secretToken": "${SecretToken}",
  "accessKey": "${accessKey}",
  "algorithm": "hmac-sha512",
  "nonce": "${nonce}",
  "timestamp": "${timestamp}",
  "expires": ${expires},
  "verifyType": ${verifyType}
}
EOF
)

# base64 encode JSON (remove new line)
AppToken=$(echo -n "${json}" | base64 | tr -d '\n')

# output
echo "${AppToken}"