#!/usr/bin/env bash
set -e

# ============================================================
#   AI Tools Setup & Update Script
#   Unterstützt: install | update | help
# ============================================================

MODE="${1:-help}"

echo "=== AI Tools Script gestartet (Modus: $MODE) ==="

# --- OS-Erkennung ---
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
fi

AITOOLS="$HOME/aitools"

# ============================================================
#   HILFE
# ============================================================
show_help() {
    echo ""
    echo "Verwendung:"
    echo "  ./setup.sh install     Installiert ComfyUI, OpenWebUI, SDXL"
    echo "  ./setup.sh update      Aktualisiert ComfyUI + OpenWebUI"
    echo "  ./setup.sh help        Zeigt diese Hilfe an"
    echo ""
    exit 0
}

# ============================================================
#   INSTALLATION
# ============================================================

install_linux_deps() {
    if command -v apt >/dev/null 2>&1; then
        echo "Installiere Abhängigkeiten (APT)…"
        sudo apt update
        sudo apt install -y python3 python3-venv python3-pip git wget curl build-essential ca-certificates
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installiere Abhängigkeiten (DNF)…"
        sudo dnf install -y python3 python3-pip python3-virtualenv git wget curl gcc gcc-c++ make ca-certificates
    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
}

install_comfyui() {
    echo "Installiere ComfyUI…"
    git clone https://github.com/comfyanonymous/ComfyUI.git "$AITOOLS/ComfyUI"

    python3 -m venv "$AITOOLS/venvs/comfyui"
    source "$AITOOLS/venvs/comfyui/bin/activate"
    pip install --upgrade pip
    pip install -r "$AITOOLS/ComfyUI/requirements.txt"
    deactivate
}

install_openwebui() {
    echo "Installiere OpenWebUI…"

    PYTHON_BIN="python3"

    if command -v dnf >/dev/null 2>&1; then
        if ! command -v python3.11 >/dev/null 2>&1; then
            echo "Installiere Python 3.11 für OpenWebUI…"
            sudo dnf install -y python3.11 python3.11-devel
        fi
        PYTHON_BIN="python3.11"
    fi

    $PYTHON_BIN -m venv "$AITOOLS/venvs/openwebui"
    source "$AITOOLS/venvs/openwebui/bin/activate"

    pip install --upgrade pip
    pip install open-webui

    deactivate
}

install_sdxl() {
    echo ""
    read -p "SDXL Base + Refiner herunterladen? (~13 GB) [Y/n]: " DOWNLOAD_SDXL
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
}

run_install() {
    echo "=== Starte Installation ==="

    mkdir -p "$AITOOLS/venvs"
    mkdir -p "$AITOOLS/workflows"

    if [[ "$OS" == "linux" ]]; then
        install_linux_deps
        install_comfyui
        install_openwebui
        install_sdxl
    elif [[ "$OS" == "mac" ]]; then
        echo "Installiere macOS-Abhängigkeiten…"
        brew install python3 git wget curl
        install_comfyui
        install_openwebui
        install_sdxl
    else
        echo "Unsupported OS."
        exit 1
    fi

    echo "=== Installation abgeschlossen ==="
}

# ============================================================
#   UPDATE
# ============================================================

update_all() {
    echo "=== Aktualisiere AI Tools ==="

    # --- ComfyUI Update ---
    if [[ -d "$AITOOLS/ComfyUI" ]]; then
        echo "Aktualisiere ComfyUI…"
        cd "$AITOOLS/ComfyUI"
        git pull

        source "$AITOOLS/venvs/comfyui/bin/activate"
        pip install --upgrade pip
        pip install --upgrade -r requirements.txt
        deactivate
    else
        echo "ComfyUI nicht gefunden – überspringe."
    fi

    # --- OpenWebUI Update ---
    if [[ -d "$AITOOLS/venvs/openwebui" ]]; then
        echo "Aktualisiere OpenWebUI…"
        source "$AITOOLS/venvs/openwebui/bin/activate"
        pip install --upgrade pip
        pip install --upgrade open-webui
        deactivate
    else
        echo "OpenWebUI nicht gefunden – überspringe."
    fi

    echo "=== Update abgeschlossen ==="
}

# ============================================================
#   MODUS AUSWERTEN
# ============================================================

case "$MODE" in
    install)
        run_install
        ;;
    update)
        update_all
        ;;
    help|*)
        show_help
        ;;
esac
