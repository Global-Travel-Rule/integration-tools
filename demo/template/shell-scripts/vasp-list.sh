set -e

export CURL_SSL_BACKEND="openssl"

# Set your desired length for the random string
length=12

# Generate the random string
random_string=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length")
combined_datetime=$(date '+%Y%m%d%H%M%S')
random_request_id=$random_string+$combined_datetime

d=$(cat shared_passphrase.txt)

curl --no-progress-meter --location --request GET "https://uat-platform.globaltravelrule.com/api/common/v3/vasp/list?showVaspEntities=true" \
    -k --cert ../../certificate.pem --key ../../privateKey.pem \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $d" \
    --header "Connection: keep-alive"