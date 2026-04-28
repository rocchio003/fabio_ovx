---
title: OmniVix
emoji: 🤌
colorFrom: indigo
colorTo: purple
sdk: docker
app_port: 7860
pinned: false
---

# OmniVix — Hugging Face Space

Minimal Docker wrapper to deploy [OmniVix](https://github.com/enrico9034/omnivix) on Hugging Face Spaces.

> 🇮🇹 Italian version: [README.ita.md](README.ita.md)

This repo contains **only** a one-line `Dockerfile` that pulls the pre-built multi-arch image from GitHub Container Registry:

```dockerfile
FROM ghcr.io/enrico9034/omnivix:latest
ENV PORT=7860
EXPOSE 7860
```

All source code, build workflows, and releases live in the main repo.

## Usage

1. Create a Space on [Hugging Face](https://huggingface.co/spaces) with SDK = **Docker**.
2. Point the Space at this repo (Settings → "Repository URL").
3. HF builds the `Dockerfile`, pulls the ghcr.io image, and starts it on port 7860.
4. Add to Stremio: `https://<your-space>.hf.space/manifest.json`.

## Updates

When a new OmniVix version is released, the `:latest` image on ghcr.io is updated automatically by the Actions workflow. To force a refresh:

- Manually restart the Space, or
- Pin to a specific version in the `Dockerfile` (e.g. `:v1.2.0` or `:sha-abc1234`).

## Self-hosting on a VPS (with WARP)

If you'd rather run OmniVix on your own server instead of on Hugging Face, see [`docker-compose-vps.yml`](docker-compose-vps.yml). It spins up two containers — `omnivix` and Cloudflare WARP — so all outbound HTTP is routed through WARP egress IPs (avoids Cloudflare 1005 ASN bans on Oracle / Hetzner / OVH / etc.).

```bash
docker compose -f docker-compose-vps.yml up -d
# → http://<your-host>:7000/manifest.json
```

---

## Credits

This project is based on:

- [qwertyuiop8899/streamvix](https://github.com/qwertyuiop8899/streamvix)
- [qwertyuiop8899/SelfStream](https://github.com/qwertyuiop8899/SelfStream)

Thanks to the original authors for the reverse engineering work and for making the code available.
