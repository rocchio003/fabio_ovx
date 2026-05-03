# HF Spaces sandbox doesn't allow NET_ADMIN / /dev/net/tun, so we use the
# :warp image variant which bundles wgcf + wireproxy (userspace WireGuard).
FROM ghcr.io/enrico9034/omnivix:warp-extended-2.0
ENV PORT=7860
EXPOSE 7860
