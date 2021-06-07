#!/bin/bash

set -eu -o pipefail
shopt -s failglob

source .gitlab-ci/env

if [ -z "${REPO_SERVER_URL:-}" ] || [ -z "${CI_JOB_TOKEN:-}" ]; then
  echo "Skipping setting private repo credentials for golang as REPO_SERVER_URL or CI_JOB_TOKEN variables are not set"
else
  git config --global url."https://gitlab-ci-token:${CI_JOB_TOKEN}@${REPO_SERVER_URL}".insteadOf "https://${REPO_SERVER_URL}"
fi


mkdir -p bin
./configure
make -j $(nproc)
cp sercd "./bin/${APP_BINARY_NAME}"

echo Built: $(ls -1 "bin/${APP_BINARY_NAME}")
