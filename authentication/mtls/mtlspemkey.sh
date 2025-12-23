#
# Copyright (c) 2025 Global Travel Rule • globaltravelrule.com
# License that can be found in the LICENSE file.
#
# Author: Global Travel Rule developer
# Created on: 2025/12/22 17:30
#

set -e

curl --no-progress-meter --location --request GET "https://uat-platform.globaltravelrule.com/version" \
    -k --cert ./certificate.pem --key ./privateKey.pem \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer [Your bearer token!!!!!]" \
    --header "Connection: keep-alive"