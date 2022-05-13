#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

#BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  exit 1
fi

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
COMPONENT_NAME=$(jq -r '.name // "my-module"' gitops-output.json)
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)

APPNAME=$(jq -r '.appname // "masdemo"' gitops-output.json)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"

echo "Printing payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
cat "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi

count=0
until kubectl get deployment ibm-mas-manage-operator -n ${NAMESPACE} || [[ $count -eq 20 ]]; do
  echo "Waiting for deployment/ibm-mas-manage-operator in ${NAMESPACE}"
  count=$((count + 1))
  sleep 60
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for deployment/ibm-mas-manage-operator in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

## workspace rollout
kubectl rollout status "deployment/${APPNAME}-entitymgr-ws" -n "${NAMESPACE}" || exit 1

count=0
until kubectl get deployment ${APPNAME}-entitymgr-ws -n ${NAMESPACE} || [[ $count -eq 20 ]]; do
  echo "Waiting for deployment/${APPNAME}-entitymgr-ws in ${NAMESPACE}"
  count=$((count + 1))
  sleep 60
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for deployment/${APPNAME}-entitymgr-ws in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

kubectl rollout status "deployment/${APPNAME}-entitymgr-ws" -n "${NAMESPACE}" || exit 1

## temporary pause in deployment if successful for additional checks
## REMOVE THIS BEFORE MERGE
sleep 15m

cd ..
rm -rf .testrepo
