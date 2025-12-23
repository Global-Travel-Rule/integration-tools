set -e

export CURL_SSL_BACKEND="openssl"

d=$(cat shared_passphrase.txt)

curl --silent --no-progress-meter --location --request POST "https://uat-platform.globaltravelrule.com/api/verify/v2/auto_address_vasp_detection" \
    -k --cert ../../certificate.pem --key ../../privateKey.pem \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $d" \
    --header "Connection: keep-alive" \
    --data-raw "{
        \"vaspCode\":\"gdummy\",
        \"address\":\"0x07d47979596158f50BCCcc68f4179A3e3Ef1B1739\",
        \"tag\":\"ETH\",
        \"network\":\"ETH\",
        \"txId\":\"0x2cdba6a8b39af8ab40624edf753c03372ef4fb613092c9b26fe1f84fc672151062968f\"
    }"