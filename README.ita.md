# OmniVix su Hugging Face Spaces & VPS self-hosted

Questo repo è il companion di deploy per [**OmniVix**](https://github.com/enrico9034/omnivix) — addon Stremio per VixSrc e AnimeUnity.

> 🇬🇧 English version: [README.md](README.md)

Contiene:

- un **`Dockerfile`** di una riga che pulla l'immagine pre-buildata [`ghcr.io/enrico9034/omnivix:warp`](https://github.com/enrico9034/omnivix/pkgs/container/omnivix) (OmniVix + Cloudflare WARP integrati, niente privilegi richiesti) — usato da Hugging Face Spaces;
- due **`docker-compose-*.yml`** pronti per self-hostare su VPS.

---

## 🤗 Deploy su Hugging Face Spaces (gratis, ~5 min)

### 1. Crea lo Space

1. Vai su <https://huggingface.co/new-space>.
2. Compila:
   - **Space name** — scegli un **nome neutro** (es. `my-stream-helper`, `tv-bridge-1`, le tue iniziali + qualcosa di generico). ⚠️ **NON usare `omnivix`, `vix`, `stream`, `iptv` o parole che richiamano lo streaming** — HF rimuove attivamente gli Space con questi nomi indipendentemente dal codice.
   - **SDK** — **Docker** → **Blank**
   - **Hardware** — `CPU basic · 2 vCPU · 16 GB · FREE`
   - **Visibility** — **Public** (Stremio deve raggiungerlo senza login)
3. Clicca **Create Space**.

> Salta il campo License — non è necessario per la build.

### 2. Carica il Dockerfile

Lo Space è ora un repo git vuoto. Ti serve solo il `Dockerfile` da questo repo (il `README.md` è opzionale — personalizza solo titolo/emoji della card dello Space).

**Modo più semplice (UI):**

- Sulla pagina dello Space clicca **Contribute → Upload file**.
- Trascina il `Dockerfile` da questo repo, poi **Commit changes to main**.

**Alternativa (git CLI):**

```bash
git clone https://huggingface.co/spaces/<TUO_HF_USERNAME>/<nome-del-tuo-space>
cp <path-a-questo-repo>/Dockerfile <nome-del-tuo-space>/
cd <nome-del-tuo-space>
git add . && git commit -m "init" && git push
```

(la prima volta git chiede username HF + un write token da <https://huggingface.co/settings/tokens>.)

### 3. Aspetta la build

Apri il tab **Logs**. Vedrai il pull dell'immagine, poi:

```
[warp] First-time WARP registration...
[warp] Generating WireGuard profile...
[warp] Starting wireproxy → SOCKS5 on 127.0.0.1:1080
[warp] Probing tunnel...
[warp] ✅ Tunnel UP, WARP active
OmniVix running at http://127.0.0.1:7860
```

Tempo totale ~3–5 min. La riga `✅ Tunnel UP` significa che è pronto.

### 4. Apri lo Space

Lo Space risiede su:

```
https://<TUO_HF_USERNAME>-<spacename>.hf.space/
```

(es. se il tuo username è `alice` e lo space è `my-stream-helper`, l'URL è `https://alice-my-stream-helper.hf.space/`).

La landing page mostra:

- un **badge stato WARP** (dovrebbe essere verde: `WARP active · <paese> · <colo>`),
- due **bottoni Test** — uno per un anime (`kitsu:244:1` Bleach), uno per un film (`tt27543632`),
- un form **Debug** per interrogare manualmente qualsiasi `type/id`.

Se il badge è verde e i bottoni Test rispondono ✅, sei a posto.

### 5. Aggiungi a Stremio

Stremio → Addons → Community → incolla l'URL del manifest:

```
https://<TUO_HF_USERNAME>-<spacename>.hf.space/manifest.json
```

(oppure clicca **Installa Addon** sulla landing se il tuo browser è su un device con Stremio installato).

### Pin di una versione specifica

Di default il `Dockerfile` segue `:warp`, che si muove con `main`. Per congelare su una release, modifica la prima riga:

```dockerfile
FROM ghcr.io/enrico9034/omnivix:warp-1.0.0
```

Poi committa. HF ricostruisce in ~30 s (immagine già in cache).

### Troubleshooting

| Sintomo | Causa | Fix |
|---|---|---|
| Space bloccato su **Building** > 10 min | raro outage HF | refresha; se ancora bloccato → **Settings → Factory reboot** |
| Logs mostrano `Tunnel did not come up in 30s` | Cloudflare ha bloccato `wgcf` da questa region | **Settings → Factory reboot** (ottiene un IP egress HF nuovo); di solito riparte |
| `Stream not found` in Stremio | Space addormentato | la prima richiesta lo sveglia (~30 s), riprova |
| Manifest 404 | build ancora in corso o build fallita | guarda il tab **Logs** |
| Voglio liberare CPU | il free tier HF dorme dopo ~48 h idle | niente da fare; si rialza alla prossima richiesta |

---

## 🖥 Self-hosting su VPS

Due file compose, entrambi instradano il traffico outbound attraverso WARP per bypassare i ban ASN Cloudflare 1005 sugli IP cloud (Oracle / Hetzner / OVH / …).

| File | Container | Capabilities | Quando usarlo |
|---|---|---|---|
| [`docker-compose-vps-aio.yml`](docker-compose-vps-aio.yml) | 1 (`omnivix:warp`) | nessuna | setup minimale, host con restrizioni, semplicità |
| [`docker-compose-vps.yml`](docker-compose-vps.yml) | 2 (`omnivix:latest` + sidecar `caomingjun/warp`) | `NET_ADMIN`, `/dev/net/tun` sul container warp | feature WARP complete (UDP), riconnessioni più robuste |

```bash
# All-in-one (un container, nessun privilegio)
docker compose -f docker-compose-vps-aio.yml up -d

# Sidecar (due container, WARP ufficiale)
docker compose -f docker-compose-vps.yml up -d
```

Aggiungi a Stremio:

```
http://<tuo-host>:7000/manifest.json
```

Per fissare una release in entrambi i compose sostituisci `:warp` / `:latest` con `:warp-1.0.0` / `:1.0.0`.

---

## Aggiornamenti

Quando esce una nuova versione di OmniVix, le immagini `:warp` e `:latest` su ghcr.io vengono ricostruite automaticamente da GitHub Actions (multi-arch, ~3 min). Per pullare la nuova immagine:

- **HF Space** — **Settings → Factory reboot** (svuota la cache dei layer e ripulla)
- **VPS** — `docker compose pull && docker compose up -d`

---

## Crediti

Progetto basato su:

- [qwertyuiop8899/streamvix](https://github.com/qwertyuiop8899/streamvix)
- [qwertyuiop8899/SelfStream](https://github.com/qwertyuiop8899/SelfStream)

Grazie agli autori originali per il lavoro di reverse engineering e per aver reso il codice disponibile.
