#!/bin/bash

set -eu -o pipefail
shopt -s failglob

source .gitlab-ci/env
export TEMPLATE_VARS="${TEMPLATE_VATS:-$(sed -E 's/(export +)?([a-zA-Z0-9_]+)=.*/${\2}/g' .gitlab-ci/env | tr '\n' ' ')}"

for nfpm_file in nfpm.yaml.template; do
   [ -f "${nfpm_file}" ] && envsubst < "${nfpm_file}" > "${nfpm_file%.*}"
done

if [ -d "${TEMPLATE_DIR_IN:-}" ]; then
  if [ -z "${TEMPLATE_DIR_OUT:-}" ]; then
    echo "TEMPLATE_DIR_OUT is empty when TEMPLATE_DIR_IN is defined, exiting with error"
    exit 1
  fi

  WDIR=$(pwd)
  rm -rf "${WDIR}/${TEMPLATE_DIR_OUT}"
  mkdir -p "${TEMPLATE_DIR_OUT}"

  echo "Copying directory structure from '${TEMPLATE_DIR_IN}' to '${TEMPLATE_DIR_OUT}'"
  cd "${TEMPLATE_DIR_IN}"
  find . -type d -print0 | xargs -0 -I'{}' mkdir -p "${WDIR}/${TEMPLATE_DIR_OUT}/{}"
  echo "Copying not ending with .template files"
  find . ! -type d ! -name '*.template' -print0 | xargs -0 -I'{}' cp "{}" "${WDIR}/${TEMPLATE_DIR_OUT}/{}"
  echo "Templating .template files"
  find . -type f -name '*.template' | while read f; do
    envsubst "${TEMPLATE_VARS}" < "${f}" > "${WDIR}/${TEMPLATE_DIR_OUT}/${f%.*}"
  done
  cd ..
else
  echo "Value in variable 'TEMPLATE_DIR_IN' is not a valid directory, skipping dir templating"
fi
