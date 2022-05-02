#!/usr/bin/env bash

NAMESPACE="$1"
USER="$2"
PASS="$3"
SECRET_NAME="$4"
DEST_DIR="$5"
PWD_SECRET_NAME="$6"

mkdir -p "${DEST_DIR}"

kubectl create secret generic "${SECRET_NAME}" \
  -n "${NAMESPACE}" \
  --from-literal="username=${USER}" \
  --from-literal="password=${PASS}" \
  --dry-run=client \
  --output=yaml > "${DEST_DIR}/${PWD_SECRET_NAME}.yaml"
