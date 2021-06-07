#!/bin/bash

set -eu -o pipefail
shopt -s failglob

source .gitlab-ci/env

export PACKAGE_VERSION="${PACKAGE_VERSION:-$(git describe --tags)}"

if [ -x .gitlab-ci/pre-pack.sh ]; then
  .gitlab-ci/pre-pack.sh
fi

if [ ! -f nfpm.yaml ]; then
  echo "nfpm.yaml not found, exiting"
  exit 1
fi

NFPM_COMMAND=nfpm
if ! command -v "${NFPM_COMMAND}" >/dev/null 2>&1; then
  echo "Command '${NFPM_COMMAND}' not found in PATH, trying to use NFPM through docker"
  NFPM_COMMAND="docker run -it -u `id -u`:`id -g` -v $(pwd):/data -w /data --rm goreleaser/nfpm:v2.3.1"
fi

mkdir -p pkg
${NFPM_COMMAND} pkg --target "pkg/${APP_PACKAGE_NAME}-${PACKAGE_VERSION}.deb"
