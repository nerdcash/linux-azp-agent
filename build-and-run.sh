#!/bin/bash
 
if [ -z "$1" ]
then
    echo "Error: No access token provided. Please provide your Azure Pipelines access token with permissions to manage agent queues as a script parameter."
    exit 1
fi
 
# Use the provided token
ACCESS_TOKEN=$1
 
# Use the provided agent name suffix or default to '00'
AGENT_NAME_SUFFIX=${2:-00}
 
docker build --tag "azp-agent:linux" --file "./azp-agent-linux.dockerfile" .
docker run --rm \
    -e AZP_URL="https://dev.azure.com/andrewarnott" \
    -e AZP_TOKEN="$ACCESS_TOKEN" \
    -e AZP_POOL="CustomAgents" \
    -e AZP_AGENT_NAME="ryzen9-linuxagent-$AGENT_NAME_SUFFIX" \
    --name "azp-agent-linux-$AGENT_NAME_SUFFIX" \
    --restart unless-stopped \
    --runtime=sysbox-runc \
    -d \
    azp-agent:linux

