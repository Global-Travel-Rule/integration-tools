# Integration Tools

This directory contains tools and utilities for integrating with the Global Travel Rule(GTR), including authentication, certificate management, cryptography tools, and demo programs.

## Directory Structure

```
integration-tools/
├── authentication/         # Authentication and token generation
├── certificates/          # Certificate management tools
├── cryptography/          # Encryption/decryption tools
├── utilities/            # General-purpose utility scripts
└── demo/                 # Demo scripts and templates
```

## Tools Overview

### Authentication (`authentication/`)

Tools for generating authentication tokens and managing mTLS authentication.

- **`apitokengen.sh`** - Generate API access tokens using HMAC-SHA512 algorithm
  - Creates AppToken for API authentication
  - Requires: secretKey, vaspCode, accessKey

- **`logintoken.sh`** - Generate login JWT token using mTLS authentication
  - Requires: certificate.pem, privateKey.pem, and API credentials
  - Returns JWT token saved to `shared_passphrase.txt`

#### mTLS Authentication (`authentication/mtls/`)

- **`mtlspemkey.sh`** - Perform mTLS authentication using PEM format certificates
- **`mtlspkcs12.sh`** - Perform mTLS authentication using PKCS12 (.p12) format certificates
- **`pem2p12converter.sh`** - Convert PEM format certificates to PKCS12 (.p12) format
  - Useful for Java applications or Windows systems

### Certificates (`certificates/`)

Certificate management and CSR generation tools.

- **`csr_generator.sh`** - Generate Certificate Signing Request (CSR) file
  - Creates: `privateKey.pem` (private key) and `CSR.csr` (certificate request)
  - Use the CSR to request certificates from Certificate Authority (CA)

### Cryptography (`cryptography/`)

Curve25519 encryption tools for multiple platforms. Each tool is available for:
- Darwin (macOS): ARM and x64
- Linux: x64 and x86
- Windows: ARM, x64, and x86

#### Directories

- **`curve25519-decryption/`** - Decrypt data using Curve25519 algorithm
  - Binary executables: `ed25519_decryption_*`

- **`curve25519-encryption/`** - Encrypt data using Curve25519 algorithm
  - Binary executables: `ed25519_encryption_*`

- **`curve25519-generator/`** - Generate Curve25519 key pairs
  - Binary executables: `ed25519_generator_*`

### Utilities (`utilities/`)

General-purpose utility scripts.

- **`sha512.sh`** - Calculate SHA-512 hash of input data
  - Interactive script for hashing payloads

### Demo (`demo/`)

Demo scripts, templates, and setup wizard for quick integration.

- **`wizard.sh`** - Interactive setup wizard
  - Converts PEM to P12 format
  - Reads API credentials from `api_key.csv`
  - Auto-configures all template files with your credentials

- **`template/`** - Code templates and examples
  - `golang/` - Go language examples (HTTP requests, callbacks)
  - `java/` - Java examples (HTTP requests, callbacks)
  - `ivms/` - IVMS101 JSON templates (KYC/KYB)
  - `sh-local-callback/` - Shell scripts for testing callbacks locally
  - `shell-scripts/` - Shell scripts for standard API operations

- **`utils/`** - Demo utility tools
  - Curve25519 tools
  - Certificate conversion scripts


## License

Copyright (c) 2025 Global Travel Rule • globaltravelrule.com