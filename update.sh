#!/bin/sh

# check if net-tools is installed, if not install it
if ! [ -x "$(command -v netstat)" ]; then
  echo 'Error: net-tools is not installed.' >&2
  sudo apt-get install net-tools >> /dev/null
fi

# Detect how many wppconnect-server containers are running
containers=$(docker ps -a | grep wppconnect-server | wc -l)
deployment_number=$((containers + 1))
export DEPLOYMENT_NUMBER=$deployment_number

# Iterate over all containers and extract SecretKey from /usr/src/wpp-server/src/config.ts
for i in $(seq 1 $containers)
do
  if ! docker ps -a | grep wppconnect-server-${i}-wppconnect-1 > /dev/null
  then
    continue
  fi
  # Get the SecretKey from the container
  secret_key=$(docker exec wppconnect-server-${i}-wppconnect-1 cat /usr/src/wpp-server/src/config.ts | grep "secretKey" | awk -F\' '{ print $2 }')
  secret_key=$(echo $secret_key | tr -d '[:space:]')
  # Get the port from the container
  port=$(docker exec wppconnect-server-${i}-wppconnect-1 cat /usr/src/wpp-server/src/config.ts | grep "port" | awk -F\' '{ print $2 }')
  port=$(echo $port | tr -d '[:space:]')
  echo "wppconnect-server-${i}-wppconnect-1 $port"
  if ! grep -q "THISISMYSECURETOKEN" src/config.ts
  then
    echo "Error: THISISMYSECURETOKEN not found in src/config.ts"
    exit 1
  fi
  sed -i "s/THISISMYSECURETOKEN/${secret_key}/g" src/config.ts
  sed -i "s/21465/${port}/g" src/config.ts
  # Set the environment variable for the port
  export DEPLOYMENT_NUMBER=$i
  export PORT=$port
  export COMPOSE_PROJECT_NAME=wppconnect-server-${i}
  printf "PORT: $PORT\n"
  printf "COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME\n"
  docker compose up --build -d
  sed -i "s/${secret_key}/THISISMYSECURETOKEN/g" src/config.ts
  sed -i "s/${port}/21465/g" src/config.ts
  # Get the host IP address
  host_ip=$(hostname -I | cut -d' ' -f1)

  # Display the deployment message
  echo "WppConnectServer update successfully!"
  echo "Deployment Number: ${deployment_number}"
  echo "Access the service at: http://${host_ip}:${port}"
done



