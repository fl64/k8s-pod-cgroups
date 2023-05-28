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

main() {
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


main "${1}" "${2}"
