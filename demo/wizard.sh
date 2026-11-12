set -e

read -p "1. Please enter path to your certificate.pem (default: ./certificate.pem):
" cert_file_name

if [ "$cert_file_name" = "" ] 
then 
    cert_file_name="./certificate.pem"
fi;

read -p "2. Please enter path to your privateKey.pem (default: ./privateKey.pem):
" priv_file_name

if [ "$priv_file_name" = "" ] 
then 
    priv_file_name="./privateKey.pem"
fi;

read -p "3. Please enter new password for .p12 format lock (default: 123456)
" p12pass

if [ "$p12pass" = "" ] 
then 
    p12pass="123456"
fi;

read -p "4. Please enter path to your api_key.csv (default: ./api_key.csv): 
" api_key_file

if [ "$api_key_file" = "" ] 
then 
    api_key_file="./api_key.csv"
fi;

openssl pkcs12 -export -out "$(pwd)/certificate.p12" -inkey $priv_file_name -in $cert_file_name -passout pass:$p12pass

line=$(tail -n +2 $api_key_file)
line="$(echo $line| sed 's/\//\\\//g')"
# line=$(tail -n +2 ./api_key.csv)
row=(${line//,/ })
# echo ${row[1]}

vaspCode="$(echo ${row[0]} | awk '{print $1}')"
echo "vaspCode:" $vaspCode
accessKey="$(echo ${row[1]} | awk '{print $1}')"
echo "accessKey:" $accessKey
secretKey="$(echo ${row[2]} | awk '{print $1}')"
echo "secretKey:" $secretKey
curvePublicKey="$(echo ${row[3]} | awk '{print $1}')"
echo "curvePublicKey:" $curvePublicKey
curvePrivateKey="$(echo ${row[4]} | awk '{print $1}')"
echo "curvePrivateKey:" $curvePrivateKey

# printf can help with remove \r\n (echo -n "" | tr -dc '[:print:]' | od -c) not work
hashed=$(printf '%s' "$secretKey" | openssl sha512)
signedSecretKey=${hashed#*= }
echo "signed secret key: " $signedSecretKey

find "$(pwd)/template" -type f | while IFS= read -r entry
do
    echo "-----> replace, grant to: $entry"

    # replace file
    sed -i '' "s/\[vaspCode\]/$vaspCode/g" "$entry"
    sed -i '' "s/\[accessKey\]/$accessKey/g" "$entry"
    sed -i '' "s/\[secretKey\]/$secretKey/g" "$entry"
    sed -i '' "s/\[signedSecretKey\]/$signedSecretKey/g" "$entry"
    sed -i '' "s/\[curvePublicKey\]/$curvePublicKey/g" "$entry"
    sed -i '' "s/\[curvePrivateKey\]/$curvePrivateKey/g" "$entry"
    sed -i '' "s/\[p12pass\]/$p12pass/g" "$entry"

    # grant execute permission
    chmod +x "$entry"
done


for entry in "$(pwd)"/utils/*
do
    echo "-----> grant permission to: $entry"
    # grant execute permission
    chmod +x "$entry"
done