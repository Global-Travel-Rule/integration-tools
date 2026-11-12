#
# Copyright (c) 2025 Global Travel Rule • globaltravelrule.com
# License that can be found in the LICENSE file.
#
# Author: Global Travel Rule developer
# Created on: 2025/12/22 17:30
#

set -e

openssl req -new -newkey rsa:4096 -nodes -keyout privateKey.pem -out CSR.csr