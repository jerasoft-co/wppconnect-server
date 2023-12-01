#!/bin/sh

# check if net-tools is installed, if not install it
if ! [ -x "$(command -v netstat)" ]; then
  echo 'Error: net-tools is not installed.' >&2
  sudo apt-get install net-tools >> /dev/null
fi

# Starting port
current_port=21465
generated_secret=$(openssl rand -hex 32)
# transform generated_secret to uppercase
secret_key=$(echo $generated_secret | tr '[:lower:]' '[:upper:]')

sed -i "s/THISISMYSECURETOKEN/${secret_key}/g" src/config.ts

# Function to check if a port is available
is_port_available() {
  netstat -atun | grep $1 > /dev/null
  [ $? -eq 0 ] && return 1 || return 0
}

# Find the next available port
while ! is_port_available "$current_port"; do
  echo "Port $current_port is not available, trying next port..."
  current_port=$((current_port + 1))
done

# Set the environment variable for the port
export PORT=$current_port

# Run Docker Compose
docker compose up -d

sed -i "s/${secret_key}/THISISMYSECURETOKEN/g" src/config.ts

# Get the host IP address
host_ip=$(hostname -I | cut -d' ' -f1)

# Display the deployment message
echo "wppconnect-server deployed successfully!"
echo "Access the service at: http://${host_ip}:${PORT}"
echo "Host IP: ${host_ip}"
echo "Port: ${PORT}"
echo "Secret Key: ${secret_key}"
