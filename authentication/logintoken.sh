#
# Copyright (c) 2025 Global Travel Rule • globaltravelrule.com
# License that can be found in the LICENSE file.
#
# Author: Global Travel Rule developer
# Created on: 2025/12/22 17:30
#

set -e

vaspCode="[vaspCode]"
accessKey="[accessKey]"
secretKey="[secretKey]"


signedSecretKey=$(printf '%s' "$secretKey" | openssl sha512)
curl -v --silent --location --request POST 'https://uat-platform.globaltravelrule.com/api/login' \
    -k --cert ./certificate.pem --key ./privateKey.pem \
    --header 'Content-Type: application/json' \
    --data-raw "{
        \"vaspCode\": \"$vaspCode\",
        \"accessKey\": \"$accessKey\",
        \"signedSecretKey\": \"$signedSecretKey\"
    }" | jq -r '.data.jwt' > shared_passphrase.txt