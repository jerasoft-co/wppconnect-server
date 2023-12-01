#!/bin/sh

# Generate a secret
generated_secret=$(openssl rand -hex 32)

# Update config.ts with the generated secret
sed -i "s/THISISMYSECURETOKEN/${generated_secret}/" /usr/src/wpp-server/src/config.ts

# Display the generated secret
echo "Secret Key: ${generated_secret}"
