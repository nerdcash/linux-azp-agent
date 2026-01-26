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

docker build --tag "github-runner:linux" --file "./github-runner.dockerfile" .
docker run --restart unless-stopped \
    -e GITHUB_ACCOUNT_URL="https://github.com/nerdcash" \
    -e TOKEN="$ACCESS_TOKEN" \
    -e RUNNER_NAME="ryzen9-ubuntuvm-$AGENT_NAME_SUFFIX" \
    --name "github-runner-$AGENT_NAME_SUFFIX" \
    --runtime=sysbox-runc \
    -d \
    github-runner:linux
