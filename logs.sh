#!/bin/sh

# Read number param
if [ -z "$1" ]
then
  echo "Error: Deployment number not provided. Usage: ./logs.sh <deployment_number>"
  exit 1
fi

deployment_number=$1
export DEPLOYMENT_NUMBER=$deployment_number

secret_key=$(docker exec wppconnect-server-${deployment_number}-wppconnect-1 cat /usr/src/wpp-server/src/config.ts | grep "secretKey" | awk -F\' '{ print $2 }')
secret_key=$(echo $secret_key | tr -d '[:space:]')
# Get the port from the container
port=$(docker exec wppconnect-server-${deployment_number}-wppconnect-1 cat /usr/src/wpp-server/src/config.ts | grep "port" | awk -F\' '{ print $2 }')
port=$(echo $port | tr -d '[:space:]')
export PORT=$port
export COMPOSE_PROJECT_NAME=wppconnect-server-${deployment_number}

echo $COMPOSE_PROJECT_NAME
echo $PORT

docker compose logs --follow
