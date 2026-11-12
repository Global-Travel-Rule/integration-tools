#
# Copyright (c) 2025 Global Travel Rule • globaltravelrule.com
# License that can be found in the LICENSE file.
#
# Author: Global Travel Rule developer
# Created on: 2025/12/22 17:30
#

set -e

read -p "Enter your payload to hash(sha512): " payload

hashed=$(printf '%s' "$payload" | openssl sha512)
echo $hashed