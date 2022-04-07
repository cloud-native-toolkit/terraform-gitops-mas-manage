#!/usr/bin/env bash

DEST_DIR="$1"
NAMESP="$2"

mkdir -p "${DEST_DIR}"

# Install MAS-Manage operator

echo "adding mas-manage subscription chart..."

cat > "${DEST_DIR}/ibm-mas-man-op.yaml" << EOL
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
    operators.coreos.com/ibm-mas-manage.${NAMESP}: ''
  name: ibm-mas-manage
  namespace: ${NAMESP}
spec:
  name: ibm-mas-manage
  source: ibm-operator-catalog
  sourceNamespace: openshift-marketplace
EOL


