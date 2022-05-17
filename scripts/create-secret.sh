#!/usr/bin/env bash

NAMESPACE="$1"
CRYPTO_KEY="$2"
CRYPTOX_KEY="$3"
SECRET_NAME="$4"
DEST_DIR="$5"
PWD_SECRET_NAME="$6"

mkdir -p "${DEST_DIR}"

kubectl create secret generic "${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --from-literal="MXE_SECURITY_CRYPTO_KEY=${CRYPTO_KEY}" \
  --from-literal="MXE_SECURITY_CRYPTOX_KEY=${CRYPTOX_KEY}" \
  --dry-run=client \
  --output=yaml > "${DEST_DIR}/${PWD_SECRET_NAME}.yaml"
