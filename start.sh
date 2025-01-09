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
 
curl -o actions-runner-linux-x64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.321.0.tar.gz

./config.sh --unattended --url ${GITHUB_ACCOUNT_URL} --token ${TOKEN} --name ${RUNNER_NAME} --replace
./run.sh 

