#!/usr/bin/env bash

CHARTNAME="$1"
DEST_DIR="$2"
VALUES_FILE="$3"

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART_DIR=$(cd "${MODULE_DIR}/charts/${CHARTNAME}"; pwd -P)

#if [[ -z "${TMP_DIR}" ]]; then
#  TMP_DIR="./.tmp"
#fi
#mkdir -p "${TMP_DIR}"

mkdir -p "${DEST_DIR}"

## put the yaml resource content in DEST_DIR
cp -R "${CHART_DIR}"/* "${DEST_DIR}"

if [[ -n "${VALUES_FILE}" ]] && [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}${VALUES_FILE}"
fi

#find "${DEST_DIR}" -name "*"


