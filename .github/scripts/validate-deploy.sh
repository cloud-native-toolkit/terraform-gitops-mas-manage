#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

source "${SCRIPT_DIR}/validation-functions.sh"

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

BIN_DIR=$(cat .bin_dir)

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

APPNAME=$(jq -r '.appname // "manage"' gitops-output.json)
WSNAME=$(jq -r '.ws_name // "demo"' gitops-output.json)
INSTNAME=$(jq -r '.inst_name // "masdemo"' gitops-output.json)


mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "values.yaml"

check_k8s_namespace "${NAMESPACE}"

check_k8s_resource "${NAMESPACE}" deployment ibm-mas-manage-operator
check_k8s_resource "${NAMESPACE}" deployment "${INSTNAME}-entitymgr-ws"
check_k8s_resource "${NAMESPACE}" deployment "${INSTNAME}-${WSNAME}-manage-maxinst"

count=0
until kubectl get deployment ibm-mas-manage-operator -n ${NAMESPACE} || [[ $count -eq 30 ]]; do
  echo "Waiting for deployment/ibm-mas-manage-operator in ${NAMESPACE}"
  count=$((count + 1))
  sleep 60
done

if [[ $count -eq 30 ]]; then
  echo "Timed out waiting for deployment/ibm-mas-manage-operator in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

## workspace rollout 
count=0
until kubectl get deployment ${INSTNAME}-entitymgr-ws -n ${NAMESPACE} || [[ $count -eq 50 ]]; do
  echo "Waiting for deployment/${INSTNAME}-entitymgr-ws in ${NAMESPACE}"
  count=$((count + 1))
  sleep 60
done

if [[ $count -eq 50 ]]; then
  echo "Timed out waiting for deployment/${APPNAME}-entitymgr-ws in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

kubectl get deployments -n ${NAMESPACE}

## maxinst deployment must succeed or nothing will work - this can take up to 4.5hrs if demo data is deployed too
count=0
until kubectl get deployment ${WSNAME}-manage-maxinst -n ${NAMESPACE} || [[ $count -eq 200 ]]; do
  echo "Waiting for deployment/${WSNAME}-manage-maxinst in ${NAMESPACE}"
  count=$((count + 1))
  sleep 1m
done

if [[ $count -eq 200 ]]; then
  echo "Timed out waiting for deployment/${WSNAME}-manage-maxinst in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi


kubectl get deployments -n ${NAMESPACE}

## last test for all deploy
count=0
until kubectl get deployment ${WSNAME}-all -n ${NAMESPACE} || [[ $count -eq 200 ]]; do
  echo "Waiting for deployment/${WSNAME}-all in ${NAMESPACE}"
  count=$((count + 1))
  sleep 1m
done

if [[ $count -eq 200 ]]; then
  echo "Timed out waiting for deployment/${WSNAME}-all in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi


kubectl get deployments -n ${NAMESPACE}




cd ..
rm -rf .testrepo
