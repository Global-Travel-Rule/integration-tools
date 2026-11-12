set -e

# export CURL_SSL_BACKEND="secure-transport"
export CURL_SSL_BACKEND="openssl"

export LOCAL_CALLBACK_SERVER="http://localhost:8080/callback"
export LOCAL_CALLBACK_SERVER_PUBLIC_KEY=""
export LOCAL_CALLBACK_SERVER_VASP_CODE="almdoamdasfadf"
export LOCAL_CALLBACK_SERVER_VASP_NAME="Hello World"


export TESTER_VASP_CODE="gdummy"
export TESTER_VASP_NAME="GDUMMY TESTER"
export TESTER_KYC_ADDRESS="0xjdaojdoajdoajsdojaojsodjas"
export TESTER_KYC_ADDRESS_TAG=""
export TESTER_KYC_NETWORK_SYMBOL="ETH"
export TESTER_KYC_NAME="Hello World"
export TESTER_KYC_TX_ID="test-tx-id-update-"$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length")


export TESTER_KYB_ADDRESS="0x39840938490238490283094823"
export TESTER_KYB_ADDRESS_TAG=""
export TESTER_KYB_NETWORK_SYMBOL="ETH"
export TESTER_KYB_NAME="CC INC."
export TESTER_KYB_TX_ID="test-tx-id-update"
