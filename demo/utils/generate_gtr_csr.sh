set -e

openssl req -new -newkey rsa:4096 -nodes -keyout privateKey.pem -out CSR.csr