#IMAGE=rfc2136-dns-container:test
IMAGE=ghcr.io/mikegerber/rfc2136-dns-container:main
podman pull $IMAGE

test_dir="$(dirname $0)"
test_config="$test_dir/rfc2136-dns-container.yml"

docker run --volume $test_config:/etc/bind/rfc2136-dns-container.yml:ro -p 15353:53 -p 15353:53/udp $IMAGE
