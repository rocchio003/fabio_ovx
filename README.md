---
title: OmniVix
emoji: 🤌
colorFrom: indigo
colorTo: purple
sdk: docker
app_port: 7860
pinned: false
---

# OmniVix on Hugging Face Spaces & self-hosted VPS

This repo is the deploy companion for [**OmniVix**](https://github.com/enrico9034/omnivix) — a Stremio addon for VixSrc and AnimeUnity.

> 🇮🇹 Italian version: [README.ita.md](README.ita.md)

It contains:

- a one-line **`Dockerfile`** that pulls the pre-built [`ghcr.io/enrico9034/omnivix:warp`](https://github.com/enrico9034/omnivix/pkgs/container/omnivix) image (OmniVix + Cloudflare WARP bundled, no privileges required) — used by Hugging Face Spaces;
- two ready-made **`docker-compose-*.yml`** files for self-hosting on a VPS.

---

## 🤗 Deploy on Hugging Face Spaces (free, ~5 min)

### 1. Create the Space

1. Go to <https://huggingface.co/new-space>.
2. Fill in:
   - **Space name** — e.g. `omnivix` (becomes part of the URL)
   - **License** — your choice (MIT works)
   - **SDK** — **Docker** → **Blank**
   - **Hardware** — `CPU basic · 2 vCPU · 16 GB · FREE`
   - **Visibility** — **Public** (Stremio needs to reach it without login)
3. Click **Create Space**.

### 2. Upload the two files

The Space is now an empty git repo. Add `Dockerfile` and `README.md` from this repo.

**Easiest way (UI):**

- On the Space page, open the **Files** tab.
- Click **+ Add file → Upload files**.
- Drag `Dockerfile` and `README.md` from this repo, then **Commit changes to main**.

**Alternative (git CLI):**

```bash
git clone https://huggingface.co/spaces/<YOUR_HF_USERNAME>/omnivix
cp <path-to-this-repo>/{Dockerfile,README.md} omnivix/
cd omnivix
git add . && git commit -m "init" && git push
```

(The first push asks for HF username + a write token from <https://huggingface.co/settings/tokens>.)

### 3. Wait for the build

Open the **Logs** tab. You'll see the image pull, then:

```
[warp] First-time WARP registration...
[warp] Generating WireGuard profile...
[warp] Starting wireproxy → SOCKS5 on 127.0.0.1:1080
[warp] Probing tunnel...
[warp] ✅ Tunnel UP, WARP active
OmniVix running at http://127.0.0.1:7860
```

Total time ~3–5 min. The `✅ Tunnel UP` line means it's ready.

### 4. Open the Space

Your Space lives at:

```
https://<YOUR_HF_USERNAME>-<spacename>.hf.space/
```

(replace dashes — e.g. `omnivix-test` → `<user>-omnivix-test.hf.space`).

The landing page shows:

- a **WARP status badge** (should be green: `WARP active · <country> · <colo>`),
- two **Test buttons** — one for an anime (`kitsu:244:1` Bleach), one for a movie (`tt27543632`),
- a **Debug** form to query any `type/id` manually.

If the badge is green and the Test buttons return ✅, you're done.

### 5. Add to Stremio

Stremio → Addons → Community → paste the manifest URL:

```
https://<YOUR_HF_USERNAME>-<spacename>.hf.space/manifest.json
```

(or just click **Installa Addon** on the landing page if your browser is on a device with Stremio installed).

### Pinning a specific version

By default the `Dockerfile` tracks `:warp`, which moves with `main`. To freeze on a release, edit the first line:

```dockerfile
FROM ghcr.io/enrico9034/omnivix:warp-1.0.0
```

Then commit. HF rebuilds in ~30 s (image already cached).

### Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Space stuck on **Building** > 10 min | rare HF outage | refresh; if still stuck → **Settings → Factory reboot** |
| Logs show `Tunnel did not come up in 30s` | Cloudflare blocked `wgcf` from this region | **Settings → Factory reboot** (gets a new HF egress IP); usually retries succeed |
| `Stream not found` in Stremio | Space sleeping | first request wakes it up (~30 s), retry |
| Manifest 404 | build still running, or build failed | check **Logs** tab |
| Want to free CPU | HF free tier sleeps after ~48 h idle | nothing to do; auto-resumes on next request |

---

## 🖥 Self-hosting on a VPS

Two compose files, both route outbound traffic through WARP to bypass Cloudflare 1005 ASN bans on cloud IPs (Oracle / Hetzner / OVH / …).

| File | Containers | Capabilities | When to use |
|---|---|---|---|
| [`docker-compose-vps-aio.yml`](docker-compose-vps-aio.yml) | 1 (`omnivix:warp`) | none | minimal setup, restricted hosts, simplicity |
| [`docker-compose-vps.yml`](docker-compose-vps.yml) | 2 (`omnivix:latest` + `caomingjun/warp` sidecar) | `NET_ADMIN`, `/dev/net/tun` on the warp container | full WARP feature set (UDP), more robust reconnects |

```bash
# All-in-one (single container, no privileges)
docker compose -f docker-compose-vps-aio.yml up -d

# Sidecar (two containers, official WARP)
docker compose -f docker-compose-vps.yml up -d
```

Then add to Stremio:

```
http://<your-host>:7000/manifest.json
```

Pin a release in either compose by replacing `:warp` / `:latest` with `:warp-1.0.0` / `:1.0.0`.

---

## Updates

When a new OmniVix version ships, the `:warp` and `:latest` images on ghcr.io are rebuilt automatically by GitHub Actions (multi-arch, ~3 min). To pull the new image:

- **HF Space** — **Settings → Factory reboot** (clears layer cache, re-pulls)
- **VPS** — `docker compose pull && docker compose up -d`

---

## Credits

This project is based on:

- [qwertyuiop8899/streamvix](https://github.com/qwertyuiop8899/streamvix)
- [qwertyuiop8899/SelfStream](https://github.com/qwertyuiop8899/SelfStream)

Thanks to the original authors for the reverse engineering work and for making the code available.
