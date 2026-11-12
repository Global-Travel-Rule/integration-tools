#
# Copyright (c) 2025 Global Travel Rule • globaltravelrule.com
# License that can be found in the LICENSE file.
#
# Author: Global Travel Rule developer
# Created on: 2025/12/22 17:30
#

set -e

read -p "Create new password for .p12 file lock: " usersetpass
openssl pkcs12 -export -out server.p12 -inkey privateKey.pem -in certificate.pem -passout pass:$usersetpass