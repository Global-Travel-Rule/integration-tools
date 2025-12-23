set -e

# Set your desired length for the random string
length=12

# Generate the random string
randomRequestId="test-"$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length")
combined_datetime=$(date '+%Y%m%d%H%M%S')
random_request_id="$randomRequestId-$combined_datetime"

resp=$(curl --no-progress-meter --location --request POST "http://localhost:8080/callback" \
    -k \
    --insecure \
    --header 'Content-Type: application/json' \
    --header "Connection: keep-alive" \
    --data-raw "{
    \"requestId\": \"$randomRequestId\",
    \"invokeVaspCode\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"originatorVasp\": \"$LOCAL_CALLBACK_SERVER_VASP_CODE\",
    \"beneficiaryVasp\": \"$TESTER_VASP_CODE\",
    \"callbackType\": 10,
    \"callbackData\": {
        \"requestId\": \"$randomRequestId\",
        \"verifyTargetType\": 2,
        \"transactionInfo\": {
            \"network\": \"$TESTER_KYC_NETWORK_SYMBOL\",
            \"txId\": \"$TESTER_KYC_TX_ID\"
        },
        \"beneficiaryAddress\": {
            \"address\": \"$TESTER_KYC_ADDRESS\",
            \"tag\": \"$TESTER_KYC_ADDRESS_TAG\"
        },
        \"initiatorVasp\": \"$TESTER_VASP_CODE\"
    }
}")

echo $resp
