#!/bin/bash

set -ex

ls

# Source env.sh to read all the vars
source env.sh

export KUBECONFIG=$KRKN_KUBE_CONFIG

# cluster version
echo "Printing cluster version"
oc version

source network-chaos/env.sh

krn_loc=/home/krkn/kraken

# Substitute config with environment vars defined
if [[ $TRAFFIC_TYPE == "egress" ]]; then
  envsubst < network-chaos/network_chaos_egress.yaml.template > /tmp/network_chaos.yaml
elif [[ $TRAFFIC_TYPE == "ingress" ]]; then
  envsubst < network-chaos/network_chaos_ingress.yaml.template > /tmp/network_chaos.yaml
  export SCENARIO_TYPE="plugin_scenarios"
else
  echo "Supported TRAFFIC_TYPE options are egress or ingress, please check"
  exit 1
fi

export SCENARIO_FILE="/tmp/network_chaos.yaml"
envsubst < config.yaml.template > /tmp/network_chaos_config.yaml

cat /tmp/network_chaos_config.yaml
cat /tmp/network_chaos.yaml

python3.9 $krn_loc/run_kraken.py --config=/tmp/network_chaos_config.yaml -o /tmp/report.out

