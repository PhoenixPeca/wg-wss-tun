# WireGuard over WSS Compose Setup

Two Docker Compose projects:
- `server`: WireGuard plus WSS tunnel server; only WSS is exposed.
- `client`: WSS unwrap that re-broadcasts UDP/51820 to a local network.

## How it works
- WireGuard listens on UDP/51820 inside the server network (not published).
- `wstunnel` (image `ghcr.io/erebe/wstunnel:latest`) serves `wss://<domain>:443` and forwards UDP traffic to WireGuard.
- On the client, `wstunnel` dials `wss://<domain>` and exposes local UDP/51820. Devices near the client point their WireGuard configs to the client host and port.

## Server setup
1. TLS: a self-signed cert is generated automatically on first `docker compose up` using `WSS_DOMAIN` and `WSS_SELF_SIGNED_DAYS` from your env. To supply your own cert instead, drop `fullchain.pem` and `privkey.pem` in [server/certs](server/certs).
2. Copy [server/.env.example](server/.env.example) to `server/.env` and adjust values:
   - `WG_SERVER_URL` is only used to pre-fill peer configs; peers will later be pointed at the client rebroadcast endpoint.
   - `WSS_DOMAIN` sets the CN/SNI used for the generated cert (or must match the cert you provide).
   - `WSS_PORT` set to 443 (or another external port you map).
3. Bring up the server stack:
   ```bash
   cd server
   docker compose up -d
   ```

### Adding VPN profiles (peers)
- Helper scripts (run from the `server` dir):
   - Add: `./bin/add-peer.sh alice`
   - List: `./bin/list-peers.sh`
   - Show config: `./bin/get-peer-config.sh alice`
- Peer configs live under [server/config](server/config) (with QR codes). Edit the `Endpoint =` line to the client rebroadcast address (e.g., `Endpoint = 192.168.1.10:51820`) before distributing.

## Client setup
1. Copy `client/.env.example` to `client/.env` and set:
   - `WSS_DOMAIN` to the server’s TLS/SNI domain (must match cert).
   - `LOCAL_WG_PORT` if you need a different rebroadcast port.
2. Bring up the client stack:
   ```bash
   cd client
   docker compose up -d
   ```
3. Devices on the client LAN should use the peer config from the server, but replace `Endpoint` with the client host/IP and `LOCAL_WG_PORT`.

## Notes
- Only the WSS port is published on the server. WireGuard UDP stays private to the internal bridge.
- `WSS_INSECURE_SKIP_VERIFY` can be set to `true` on the client for testing with self-signed certs, but use proper certs for evading filtering.
- Adjust MTU in peer configs if fragmentation occurs (e.g., `MTU = 1280`).
- If you want health checks, add a simple `curl https://<domain>` check against the WSS port.
