set -e

# export CURL_SSL_BACKEND="secure-transport"
export CURL_SSL_BACKEND="openssl"

# Set your desired length for the random string
length=12

# Generate the random string
randomRequestId="demo-test-id-"$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length")
combined_datetime=$(date '+%Y%m%d%H%M%S')
random_request_id=$randomRequestId+$combined_datetime

d=$(cat shared_passphrase.txt)

myPriv="[curvePrivateKey]"
myPub="[curvePublicKey]"

targetVaspCode="gdummy"

remotePub=$(sh ./vasp-detail.sh $targetVaspCode | jq -r '.data.standardInfo.publicKeyInfo.receiverKeyInfo.publicKey')

echo "Target VASP Code =====> $remotePub"

encryptedPayload=$(../../utils/curve25519_from_file $myPriv $remotePub ../ivms/post_ivms_kyc.json)

resp=$(curl --no-progress-meter --location --request POST "https://uat-platform.globaltravelrule.com/api/verify/v2/one_step" \
    -k --cert ../../certificate.pem --key ../../privateKey.pem \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $d" \
    --header "Connection: keep-alive" \
    --data-raw "{
    \"requestId\": \"$randomRequestId\",
    \"ticker\": \"PEPE\",
    \"address\": \"0x5141cf8a25c937ffba564da7562a124e9824ae9c\",
    \"txId\":\"0x69ea3b700b5469313f65eee8618167c8c67f23c01cfee755bfdc205777176787\",
    \"tag\": \"\",
    \"verifyType\": 4,
    \"secretType\": 2,
    \"verifyDirection\":1,
    \"network\": \"ETH\",
    \"targetVaspCode\": \"$targetVaspCode\",
    \"encryptedPayload\": \"$encryptedPayload\",
    \"emptyPiiSchema\": \"\",
    \"initiatorPublicKey\": \"$myPub\",
    \"targetVaspPublicKey\": \"$remotePub\",
    \"fiatName\": \"USD\",
    \"amount\": \"1000\",
    \"fiatPrice\": \"6.66\",
    \"expectVerifyFields\": [\"100026\", \"100025\"]
    }")
echo $resp

travelruleId=$(echo $resp | jq -r '.data.travelruleId')
tx_id=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length")

echo "RequestId: $randomRequestId"
echo "Travel Rule Id: $travelruleId"