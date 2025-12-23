set -e

# Set your desired length for the random string
length=12

# Generate the random string
randomRequestId="test-"$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length")
combined_datetime=$(date '+%Y%m%d%H%M%S')
random_request_id="$randomRequestId-$combined_datetime"

myPriv="+aIO2lX7wZn4Qh+SQUFKfjyR5snd6AkTqeKKmDIplzY0tCgDQPELNZKsMWBXbHcZTdW9Gb4BCKsBFpIH7SoQLQ=="
myPub="NLQoA0DxCzWSrDFgV2x3GU3VvRm+AQirARaSB+0qEC0="

encryptedPayload=$(curve25519_from_file $myPriv $LOCAL_CALLBACK_SERVER_PUBLIC_KEY $basedir/../ivms/pre_ivms_kyb.json)

resp=$(curl --no-progress-meter --location --request POST "http://localhost:8080/callback" \
    -k \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Connection: keep-alive" \
    --data-raw "{
    \"requestId\": \"$randomRequestId\",
    \"invokeVaspCode\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"originatorVasp\": \"$TESTER_VASP_CODE\",
    \"beneficiaryVasp\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"callbackType\": 6,
    \"callbackData\": {
        \"requestId\": \"$randomRequestId\",
        \"originatorVasp\": \"$TESTER_VASP_CODE\",
        \"originatorVaspName\": \"$TESTER_VASP_NAME\",
        \"ticker\": \"--YOU SHOULD NOT REFER THIS TICKER TO SEARCH YOUR USER--\",
        \"address\": \"$TESTER_KYC_ADDRESS\",
        \"tag\": \"$TESTER_KYC_ADDRESS_TAG\",
        \"network\": \"$TESTER_KYC_NETWORK_SYMBOL\",
        \"initiatorVasp\": \"$TESTER_VASP_CODE\"
    }
}")

echo $resp

sleep 1

curl --no-progress-meter --location --request POST "http://localhost:8080/callback" \
    -k \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $d" \
    --header "Connection: keep-alive" \
    --data-raw "{
    \"requestId\": \"$randomRequestId\",
    \"invokeVaspCode\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"originatorVasp\": \"$TESTER_VASP_CODE\",
    \"beneficiaryVasp\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"callbackType\": 4,
    \"callbackData\": {
        \"requestId\": \"$randomRequestId\",
        \"amount\": \"1000\",
        \"fiatPrice\": \"6.66\",
        \"fiatName\": \"USDT\",
        \"network\": \"$TESTER_KYC_NETWORK_SYMBOL\",
        \"ticker\": \"--YOU SHOULD NOT REFER TO THIS TICKER--\",
        \"tag\": \"$TESTER_KYC_ADDRESS_TAG\",
        \"address\": \"$TESTER_KYC_ADDRESS\",
        \"secretType\": 1,
        \"originatorVasp\": \"$TESTER_VASP_CODE\", // save it, don't use it
        \"beneficiaryVasp\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\", // save it, don't use it
        \"initiatorVasp\": \"$TESTER_VASP_CODE\", 
        \"receiverVasp\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
        \"verificationDirection\": 2,
        \"piiSecuredInfo\": {
            \"initiatorKeyInfo\": {
                \"publicKey\": \"$myPub\"
            },
            \"receiverKeyInfo\": {
                \"publicKey\": \"$LOCAL_CALLBACK_SERVER_PUBLIC_KEY\"
            },
            \"piiSecretFormatType\": \"FULL_JSON_OBJECT_ENCRYPT\",
            \"piiSpecVersion\": \"ivms101-2020\",
            \"secretAlgorithm\": \"ed25519_curve25519\",
            \"securedPayload\": \"$encryptedPayload\"
        }
    }
}" 

sleep 1

echo "Update Tx Id ..."

curl --no-progress-meter --location --request POST "http://localhost:8080/callback" \
    -k \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $d" \
    --header "Connection: keep-alive" \
    --data-raw "{
    \"requestId\": \"$randomRequestId\",
    \"invokeVaspCode\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"originatorVasp\": \"$TESTER_VASP_CODE\",
    \"beneficiaryVasp\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"callbackType\": 7,
    \"callbackData\": {
        \"txId\": \"$TESTER_KYC_TX_ID\",
        \"requestId\": \"$randomRequestId\"
    }
}" 

echo "RequestId: $randomRequestId"