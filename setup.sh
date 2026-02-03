#!/usr/bin/env bash
set -e

echo "=== AI Tools Setup ==="

# --- OS-Erkennung ---
OS="unknown"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
fi

echo "Erkanntes Betriebssystem: $OS"

# --- Zielordner ---
AITOOLS="$HOME/aitools"
mkdir -p "$AITOOLS/venvs"
mkdir -p "$AITOOLS/workflows"

echo "Ordnerstruktur erstellt."

# --- Linux Setup ---
if [[ "$OS" == "linux" ]]; then
    echo "Installiere Linux-Abhängigkeiten..."
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip git wget curl build-essential ca-certificates

    # --- ComfyUI ---
    echo "Installiere ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$AITOOLS/ComfyUI"

    python3 -m venv "$AITOOLS/venvs/comfyui"
    source "$AITOOLS/venvs/comfyui/bin/activate"
    pip install --upgrade pip
    pip install -r "$AITOOLS/ComfyUI/requirements.txt"
    deactivate

    # --- OpenWebUI (PyPI-Version) ---
    echo "Installiere OpenWebUI (PyPI-Version)..."
    python3 -m venv "$AITOOLS/venvs/openwebui"
    source "$AITOOLS/venvs/openwebui/bin/activate"
    pip install --upgrade pip
    pip install open_webui
    deactivate

    # --- SDXL Modelle ---
    echo ""
    echo "SDXL Base + Refiner herunterladen? (~13 GB) [Y/n]: "
    read DOWNLOAD_SDXL
    DOWNLOAD_SDXL=${DOWNLOAD_SDXL:-y}

    if [[ "$DOWNLOAD_SDXL" =~ ^[Yy]$ ]]; then
        MODEL_DIR="$AITOOLS/ComfyUI/models/checkpoints"
        mkdir -p "$MODEL_DIR"

        [[ ! -f "$MODEL_DIR/sd_xl_base_1.0.safetensors" ]] && \
            wget -O "$MODEL_DIR/sd_xl_base_1.0.safetensors" \
            https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

        [[ ! -f "$MODEL_DIR/sd_xl_refiner_1.0.safetensors" ]] && \
            wget -O "$MODEL_DIR/sd_xl_refiner_1.0.safetensors" \
            https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors

        echo "SDXL Modelle installiert."
    else
        echo "SDXL Download übersprungen."
    fi
fi

# --- macOS Setup ---
if [[ "$OS" == "mac" ]]; then
    echo "Installiere macOS-Abhängigkeiten..."
    brew install python3 git wget curl

    # --- ComfyUI ---
    echo "Installiere ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$AITOOLS/ComfyUI"

    python3 -m venv "$AITOOLS/venvs/comfyui"
    source "$AITOOLS/venvs/comfyui/bin/activate"
    pip install --upgrade pip
    pip install -r "$AITOOLS/ComfyUI/requirements.txt"
    deactivate

    # --- OpenWebUI (PyPI-Version) ---
    echo "Installiere OpenWebUI (PyPI-Version)..."
    python3 -m venv "$AITOOLS/venvs/openwebui"
    source "$AITOOLS/venvs/openwebui/bin/activate"
    pip install --upgrade pip
    pip install open-webui
    deactivate

    # --- SDXL Modelle ---
    echo ""
    echo "SDXL Base + Refiner herunterladen? (~13 GB) [Y/n]: "
    read DOWNLOAD_SDXL
    DOWNLOAD_SDXL=${DOWNLOAD_SDXL:-y}

    if [[ "$DOWNLOAD_SDXL" =~ ^[Yy]$ ]]; then
        MODEL_DIR="$AITOOLS/ComfyUI/models/checkpoints"
        mkdir -p "$MODEL_DIR"

        [[ ! -f "$MODEL_DIR/sd_xl_base_1.0.safetensors" ]] && \
            wget -O "$MODEL_DIR/sd_xl_base_1.0.safetensors" \
            https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

        [[ ! -f "$MODEL_DIR/sd_xl_refiner_1.0.safetensors" ]] && \
            wget -O "$MODEL_DIR/sd_xl_refiner_1.0.safetensors" \
            https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors

        echo "SDXL Modelle installiert."
    else
        echo "SDXL Download übersprungen."
    fi
fi

echo "=== Setup abgeschlossen ==="
