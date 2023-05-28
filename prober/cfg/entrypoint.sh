#!/usr/bin/env bash

curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.27.0/crictl-v1.27.0-linux-amd64.tar.gz | tar -xz -C /usr/local/bin/

tail -f /dev/null
