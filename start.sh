#!/bin/bash

echo "=== AI Tools werden gestartet ==="

# Cleanup on exit
cleanup() {
    echo ""
    echo "=== Stoppe AI Tools ==="
    echo "Stoppe ComfyUI..."
    pkill -f ComfyUI || true

    echo "Stoppe OpenWebUI..."
    pkill -f open-webui || true

    echo "Stoppe Ollama..."
    brew services stop ollama >/dev/null 2>&1

    echo "=== Alles gestoppt ==="
    exit 0
}

trap cleanup INT TERM

echo "Starte Ollama..."
brew services start ollama

echo "Starte ComfyUI..."
cd /Users/dante/aitools/ComfyUI
/Users/dante/aitools/venvs/comfyui/bin/python3 main.py --listen --enable-cors-header &
COMFY_PID=$!

echo "Starte OpenWebUI..."
cd /Users/dante/aitools
/Users/dante/aitools/venvs/openwebui/bin/open-webui serve &
WEBUI_PID=$!

echo ""
echo "=== AI Tools laufen ==="
echo "ComfyUI PID: $COMFY_PID"
echo "OpenWebUI PID: $WEBUI_PID"
echo ""
echo "Drücke STRG+C zum Beenden."

# Keep script alive
while true; do
    sleep 1
done
