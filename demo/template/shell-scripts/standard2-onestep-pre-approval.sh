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

encryptedPayload=$(../../utils/curve25519_from_file $myPriv $remotePub ../ivms/pre_ivms_kyc.json)

resp=$(curl --no-progress-meter --location --request POST "https://uat-platform.globaltravelrule.com/api/verify/v2/one_step" \
    -k --cert ../../certificate.pem --key ../../privateKey.pem \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $d" \
    --header "Connection: keep-alive" \
    --data-raw "{
    \"requestId\": \"$randomRequestId\",
    \"ticker\": \"ETH\",
    \"address\": \"0xD97C807a359391A62BCF7D3356B4D8AEF1Be6efb\",
    \"tag\": \"\",
    \"verifyType\": 4,
    \"secretType\": 2,
    \"verifyDirection\":2,
    \"network\": \"ETH\",
    \"targetVaspCode\": \"$targetVaspCode\",
    \"encryptedPayload\": \"$encryptedPayload\",
    \"emptyPiiSchema\": \"\",
    \"initiatorPublicKey\": \"$myPub\",
    \"targetVaspPublicKey\": \"$remotePub\",
    \"fiatName\": \"USD\",
    \"amount\": \"1000\",
    \"fiatPrice\": \"6.66\",
    \"expectVerifyFields\": [\"110026\", \"110025\"]
    }")
echo $resp

travelruleId=$(echo $resp | jq -r '.data.travelruleId')
tx_id=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length")

echo "Update Tx Id ..."

sleep 1

curl --no-progress-meter --location --request POST "https://uat-platform.globaltravelrule.com/api/verify/v2/notify_tx_id" \
    -k --cert-type P12 --cert $basename/certificate.p12:'[p12pass]' \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $d" \
    --header "Connection: keep-alive" \
    --data-raw "{
    \"requestId\": \"$randomRequestId\",
    \"travelruleId\":\"$travelruleId\",
    \"txId\": \"$tx_id\"
}" 

echo "RequestId: $randomRequestId"
echo "Travel Rule Id: $travelruleId"