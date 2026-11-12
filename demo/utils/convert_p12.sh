set -e

pass=""

read -p "Please enter p12 password: " pass

if [ "$pass" = "" ] 
then 
    pass="123456"
fi;

openssl pkcs12 -export -out certificate.p12 -inkey privateKey.pem -in certificate.pem -passout pass:$pass