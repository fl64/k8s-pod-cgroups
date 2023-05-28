#!/usr/bin/env bash

# $1 - ns
# $2 - podname

PROBER_NS="cgroup-prober"
PROBER_LABELS="app=cgroup-prober"
CGROUP_PATTERN="cpu"

PROCSYS_PATH="/host"
#PROCSYS_PATH=""

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

proberExec() {
  # $1 - prober-pod-name
  # $@ - params
  #echo "running: ${@:2}"
  kubectl -n "${PROBER_NS}" exec "${1}" 2>/dev/null  -- bash -c "${@:2}"
}

pod_info() {
  # create dict[cgroup-prober-node] = cgroup-prober-pod-name
  echo -e "${GREEN}Prober pods:${NC}"
  declare -A cgroupProber
  while IFS=' ' read -r podName nodeName; do
      echo -e "  ${GREEN}pod:${NC} ${podName} ${GREEN}node:${NC} ${nodeName}"
      cgroupProber[$nodeName]="${podName}"
  done < <(kubectl -n "${PROBER_NS}" get pods -l "${PROBER_LABELS}" -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName --no-headers)
  echo

  podNodeName=$(kubectl -n "${1}" get pod "${2}" -o json | jq -r '.spec.nodeName')
  # echo $podNodeName
  proberPod=${cgroupProber[${podNodeName}]}

  echo -e "${GREEN}Discover containers cgroups for pod:${NC} ${2} ${GREEN}in namespace:${NC} ${1} ${GREEN}on node:${NC} ${podNodeName} ${GREEN}via pod:${NC} ${proberPod}"
  while read container; do

    containerName=$(echo "${container}" | jq -r '.name')
    containerID=$(echo "${container}" | jq -r '.containerID')
    echo -e "${GREEN}  Container:${NC} ${containerName}${GREEN}, containerd ID:${NC} ${containerID}"

    processPID=$(proberExec "${proberPod}" "crictl inspect ${containerID} | jq -r .info.pid")
    echo -e "${GREEN}    Process PID:${NC} ${processPID}"

    cgroupPath=$(proberExec "${proberPod}" "crictl inspect ${containerID} | jq -r .info.runtimeSpec.linux.cgroupsPath")
    echo -e "${GREEN}    Process cgroupPath:${NC} ${cgroupPath}"

    processCgroups=$(proberExec "${proberPod}" "cat ${PROCSYS_PATH}/proc/${processPID}/cgroup ")
    echo "${processCgroups}" | sed 's/^/    - /'

    echo -e "    ${GREEN}Process CGroups:${NC}"
    while IFS=':' read -r _ cgroup path; do
      # little hack to remove /../../.. in some cases
      echo $path | grep -q '/../../..' && path="${cgroupPath}"

      echo -e "${GREEN}      cgroup:${NC} ${cgroup} ${GREEN}path:${NC} ${path}"
      # cut path from cgroup than add 4 spaces before
      proberExec "${proberPod}" "grep '' ${PROCSYS_PATH}/sys/fs/cgroup/${cgroup}${path}/* | rev | cut -d'/' -f1 | rev" | sed 's/^/        /' | grep "${CGROUP_PATTERN}"
      #proberExec "${proberPod}" "grep '' ${PROCSYS_PATH}/sys/fs/cgroup/${cgroup}${path}/*" | sed 's/^/        /'
    done < <(echo "${processCgroups}")

  done < <(kubectl -n "${1}" get pods "${2}" -o json | jq '.status.containerStatuses[] | {name, containerID: .containerID | split("://")[1] }' | jq -sc .[])
}

# Define default values
NAMESPACE="default"
POD_LABELS=""
POD_NAME=""

# Parse arguments
while getopts ":n:l:" opt; do
  case ${opt} in
    n )
      NAMESPACE=$OPTARG
      ;;
    l )
      POD_LABELS=$OPTARG
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done

# Get the last argument, which should be the pod name
shift $((OPTIND -1))
POD_NAME=$1

# Check if both pod name and labels were provided
if [[ -n "$POD_NAME" && -n "$POD_LABELS" ]]; then
  echo "Error: Please provide either a pod name or labels, but not both."
  exit 1
fi

# Check if neither pod name nor labels were provided
if [[ -z "$POD_NAME" && -z "$POD_LABELS" ]]; then
  echo "Error: Please provide either a pod name or labels."
  exit 1
fi

echo -e "${GREEN}Namespace:${NC} $NAMESPACE"
echo -e "${GREEN}Labels:${NC} $POD_LABELS"
echo -e "${GREEN}Pod Name:${NC} $POD_NAME"

if [[ -z "$POD_LABELS" ]]; then
  pod_info "${NAMESPACE}" "${POD_NAME}"
else
  for pod in $(kubectl -n "${NAMESPACE}" get pods -l "${POD_LABELS}" -o custom-columns=NAME:.metadata.name --no-headers); do
    pod_info "${NAMESPACE}" "${pod}"
  done
fi
