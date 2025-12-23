set -e

export CURL_SSL_BACKEND="openssl"

curl -v --silent --location --request POST 'https://uat-platform.globaltravelrule.com/api/login' \
    -k --cert ../../certificate.pem --key ../../privateKey.pem \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "vaspCode": "[vaspCode]",
        "accessKey": "[accessKey]",
        "signedSecretKey": "[signedSecretKey]",
        "vaspPublicKey": "[curvePublicKey]"
    }' | jq -r '.data.jwt' > shared_passphrase.txt