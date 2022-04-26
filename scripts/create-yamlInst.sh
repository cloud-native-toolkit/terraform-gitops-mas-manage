#!/usr/bin/env bash

CHARTNAME="$1"
DEST_DIR="$2"
VALUES_FILE="$3"
APPID="$4"

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART_DIR=$(cd "${MODULE_DIR}/charts/${CHARTNAME}"; pwd -P)

mkdir -p "${DEST_DIR}"

## put the yaml resource content in DEST_DIR
cp -R "${CHART_DIR}"/* "${DEST_DIR}"

## add values content to values file
if [[ -n "${VALUES_FILE}" ]] && [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}${VALUES_FILE}"
fi

## need to set the app name id to enabled
cat >> "${DEST_DIR}${VALUES_FILE}" << EOL
"${APPID}":
  "enabled": true
EOL
