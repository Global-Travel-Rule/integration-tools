set -e

export CURL_SSL_BACKEND="openssl"

token=$(sh -c ./app-token.sh)

curl --no-progress-meter --location --request GET "https://uat-platform.globaltravelrule.com/api/common/v3/vasp/list?showVaspEntities=true" \
    -k --cert ../../certificate.pem --key ../../privateKey.pem \
    --header 'Content-Type: application/json' \
    --header "X-Authorization: $token" \
    --header "Connection: keep-alive"