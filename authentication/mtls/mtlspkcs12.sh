#
# Copyright (c) 2025 Global Travel Rule • globaltravelrule.com
# License that can be found in the LICENSE file.
#
# Author: Global Travel Rule developer
# Created on: 2025/12/22 17:30
#

set -e

read -p "Please enter your server.p12 file lock password: " p12filepass

curl --silent --location --request GET 'https://uat-platform.globaltravelrule.com/version' \
    -k --cert-type P12 --cert ./server.p12:"$p12filepass" \
    --header 'Content-Type: application/json'