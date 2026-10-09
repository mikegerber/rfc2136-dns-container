#!/bin/sh
set -euo pipefail

test_dir="$(dirname $0)"
test_config="$test_dir/rfc2136-dns-container.yml"

CID=$(docker run \
  -d \
  --volume $test_config:/etc/bind/rfc2136-dns-container.yml:ro \
  rfc2136-dns-container:test)
trap 'docker rm -f "$CID" >/dev/null 2>&1 || true' EXIT

sleep 5

if [ "$(docker inspect -f '{{.State.Running}}' "$CID")" = "true" ]; then
    echo "Smoke test passed"
else
    echo "Smoke test failed"
    docker logs "$CID"
    exit 1
fi
