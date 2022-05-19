#!/usr/bin/env bash

CHARTNAME="$1"
DEST_DIR="$2"
ADDONS="$3"

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART_DIR=$(cd "${MODULE_DIR}/chart/${CHARTNAME}"; pwd -P)

mkdir -p "${DEST_DIR}"

## put the yaml resource content in DEST_DIR
cp -R "${CHART_DIR}"/* "${DEST_DIR}"

if [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"
fi

## addons as needed to deploy with manage
cat >> ${DEST_DIR}/values.yaml << EOL
addons:
EOL

    if [[ "${ADDONS}" =~ health ]]; then
      echo "adding health ..."
      cat >> ${DEST_DIR}/values.yaml << EOL
  - health
EOL
    fi

    if [[ "${ADDONS}" =~ civil ]]; then
      echo "adding civil infrastructure ..."
      cat >> ${DEST_DIR}/values.yaml << EOL
  - civil
EOL
    fi
