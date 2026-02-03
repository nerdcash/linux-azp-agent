#!/bin/bash
set -e
 
if [ -z "${GITHUB_ACCOUNT_URL}" ]; then
  echo 1>&2 "error: missing GITHUB_ACCOUNT_URL environment variable"
  exit 1
fi
 
if [ -z "${TOKEN}" ]; then
  echo 1>&2 "error: missing TOKEN environment variable"
  exit 1
fi
 
if [ -z "${RUNNER_NAME}" ]; then
  echo 1>&2 "error: missing RUNNER_NAME environment variable"
  exit 1
fi
 
# Only download and configure if not already configured
if [ ! -f ".runner" ]; then
  echo "First run detected - downloading and configuring runner..."
  curl -o actions-runner-linux-x64-2.331.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.331.0/actions-runner-linux-x64-2.331.0.tar.gz
  tar xzf ./actions-runner-linux-x64-2.331.0.tar.gz
  ./config.sh --unattended --url ${GITHUB_ACCOUNT_URL} --token ${TOKEN} --name ${RUNNER_NAME} --labels docker-in-docker,sudo --replace
else
  echo "Runner already configured - skipping configuration..."
fi

./run.sh 

