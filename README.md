# RFC 2136 DNS Container

A containerized authoritative DNS server with support for dynamic DNS updates using [RFC 2136](https://datatracker.ietf.org/doc/html/rfc2136).

Useful for:

- **Dynamic DNS:** Update DNS records for hosts with changing IP addresses, such as home internet connections.
- **ACME DNS-01 challenges:** Allow ACME clients to create and remove TXT records for certificate validation.

The container runs BIND 9 and generates its configuration from a simple YAML file. DNS updates are authenticated using TSIG (HMAC-SHA512), with permissions restricted to individual DNS record names.

## Configuration

Create a file named `config.yml`:

```yaml
soa_mname: ns-dyn.example.com
soa_rname: hostmaster.example.com

keys:
  dyndns: "BASE64_ENCODED_TSIG_SECRET"
  acme: "ANOTHER_BASE64_ENCODED_TSIG_SECRET"

zones:
  dyn.example.com:
    home: dyndns
  acme.example.com:
    _acme-challenge: acme
```

This configuration:

- Creates authoritative DNS zones for `dyn.example.com` and `acme.example.com`.
- Allows the `dyndns` key to update `home.dyn.example.com`.
- Allows the `acme` key to update `_acme-challenge.acme.example.com`.

The `soa_mname` and `soa_rname` settings specify the primary authoritative nameserver (= the server this is running on) and responsible party for the SOA record. For `soa_rname`, use the DNS representation of an email address (`hostmaster.example.com` corresponds to `hostmaster@example.com`).

## Docker Compose

Create a `docker-compose.yml`:

```yaml
services:
  dns:
    image: ghcr.io/mikegerber/rfc2136-dns-container:main
    restart: unless-stopped

    ports:
      - "53:53/udp"
      - "53:53/tcp"

    volumes:
      - ./config.yml:/etc/bind/rfc2136-dns-container.yml:ro
      - dns-data:/var/bind/rfc2136-dns-container

volumes:
  dns-data:
```

Start the server:

```sh
docker compose up -d
```

Check the logs:

```sh
docker compose logs -f dns
```

Port 53 must be available on the host for both UDP and TCP.

The `dns-data` volume stores zone files and dynamic updates, preserving DNS records across container restarts and upgrades.


## Notes

- The server is **authoritative only**. Recursive DNS queries are disabled.
- DNS zone transfers are disabled.
- Dynamic update permissions are restricted to the configured record names.
- A separate TSIG key can be assigned to each record name.
- Zone files are initialized automatically if they do not exist.
- Existing zone files are preserved on restart.
- The image includes a health check that queries the local DNS server without depending on any configured zone.
