# Setup

## Approach 1
Reuse `gcloud` from the host and setup `claude` in the container.

Build the image
```sh
podman build -t claude-box -f ./Containerfile .
```

Prepare Claude Code
```sh
podman run -v "$HOME/.config/gcloud:/root/.config/gcloud:z" --rm -it localhost/claude-box:latest

# -k is needed here because the container doesn't have to root cert to trust the red.hat domain
curl -kfsSL "https://red.ht/claude-vertex-linux-setup" | bash -s -- itpc-ca-1d508332bc
# Ignore the errors
```

Follow these instruction (from the email `Your AI environment is ready`)
```
You can now start Claude and choose Vertex AI. Run the /login command and follow the wizard prompts. Select the following information and select Save.
Login method: 3rd-party platform
Provider: Google Vertex AI
Authentication method: Application Default Credentials (gcloud auth)
Project: itpc-ca-1d508332bc
Region: global
Models: Pin the working models
```

Commit the image
```sh
container_id="$(podman ps --noheading | grep -F 'localhost/claude-box:latest' | awk '{print $1}')"
podman commit -pqs $container_id claude-box:ready
podman image rm localhost/claude-box:latest
```

Run
```sh
podman run -v "$HOME/.config/gcloud:/root/.config/gcloud:z" --rm -it localhost/claude-box:ready
```

## Approach 2
Reuse `gcloud` and `claude` from the host.


```sh
podman build -t claude-box -f ./Containerfile .
podman run --rm -it \
  --security-opt label=disable \
  -v "$HOME/.config/gcloud:/root/.config/gcloud" \
  -v "$HOME/.claude:/root/.claude" \
  -v "$HOME/.claude.json:/root/.claude.json" \
  -v "$HOME/dev/src/github.com/:/src/github.com/" \
  localhost/claude-box:latest
```
