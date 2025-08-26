#!/bin/bash
set -e

echo "[aws_instances]" > inventory.ini

for ip in $(echo $SPACELIFT_OUTPUT_aws_instances | jq -r '.[]'); do
  echo "$ip" >> inventory.ini
done
