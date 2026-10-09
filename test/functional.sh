#!/usr/bin/env bash
set -euo pipefail

test_dir="$(realpath "$(dirname $0)")"
test_config="$test_dir/rfc2136-dns-container.yml"

CID=$(docker run \
  -d \
  --volume $test_config:/etc/bind/rfc2136-dns-container.yml:ro \
  -p 5353:53 \
  -p 5353:53/udp \
  rfc2136-dns-container:test)
trap 'docker rm -f "$CID" >/dev/null 2>&1 || true' EXIT

SERVER="${SERVER:-127.0.0.1}"
PORT="${PORT:-5353}"
ZONE="${ZONE:-dyn.example.com}"
KEY_FILE="${KEY_FILE:-$test_dir/test-tsig.key}"

ZONE="${ZONE%.}"
RECORD="test.$ZONE."
IP1="192.0.2.10"
IP2="192.0.2.20"

update() {
    nsupdate -v -k "$KEY_FILE" <<EOF
server $SERVER $PORT
zone $ZONE.
$1
send
EOF
}

query() {
    dig +short +time=2 +tries=1 \
        @"$SERVER" -p "$PORT" "$RECORD" A
}

assert_record() {
    local expected="$1"
    local actual

    actual="$(query)"

    if [[ "$actual" != "$expected" ]]; then
        echo "FAIL: expected '$expected', got '$actual'"
        exit 1
    fi
}

cleanup() {
    update "update delete $RECORD A" || true
}
trap cleanup EXIT

echo "Waiting for DNS server..."
for i in {1..30}; do
    if dig +time=1 +tries=1 \
        @"$SERVER" -p "$PORT" "$ZONE." SOA \
        +short | grep -q .; then
        break
    fi

    if (( i == 30 )); then
        echo "FAIL: DNS server not ready"
        exit 1
    fi
    sleep 1
done

echo "Testing CREATE..."
update "update add $RECORD 60 A $IP1"
assert_record "$IP1"

echo "Testing REPLACE..."
update "update delete $RECORD A
update add $RECORD 60 A $IP2"
assert_record "$IP2"

echo "Testing DELETE..."
update "update delete $RECORD A"
assert_record ""

echo "PASS: RFC 2136 functional tests"

