#!/usr/bin/env bash
set -e

# ============================================================
#   AI Tools Setup & Update Script (Bazzite-Optimiert)
#   Unterstützt: install | update | help
# ============================================================

MODE="${1:-help}"
echo "=== AI Tools Script gestartet (Modus: $MODE) ==="

AITOOLS="$HOME/aitools"
VENV_DIR="$AITOOLS/venvs"

# ============================================================
#   OS-ERKENNUNG
# ============================================================

detect_os() {
    if [[ -f /usr/bin/rpm-ostree ]]; then
        echo "bazzite"
    elif command -v dnf >/dev/null 2>&1; then
        echo "fedora"
    elif command -v apt >/dev/null 2>&1; then
        echo "debian"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo "Erkanntes OS: $OS"

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
#   DEPENDENCIES
# ============================================================

install_deps_bazzite() {
    echo "Bazzite erkannt – benutze Toolbox für Dependencies."

    if ! command -v toolbox >/dev/null 2>&1; then
        echo "Toolbox nicht gefunden – installiere toolbox..."
        sudo rpm-ostree install toolbox
        echo "Bitte neu starten und Script erneut ausführen."
        exit 1
    fi

    if ! toolbox list | grep -q "ai-tools"; then
        echo "Erstelle Toolbox 'ai-tools'..."
        toolbox create ai-tools
    fi

    echo "Installiere Dependencies in Toolbox..."
    toolbox run -c ai-tools sudo dnf install -y \
        python3 python3-pip python3-virtualenv git wget curl gcc gcc-c++ make
}

install_deps_fedora() {
    echo "Installiere Dependencies (DNF)…"
    sudo dnf install -y python3 python3-pip python3-virtualenv git wget curl gcc gcc-c++ make
}

install_deps_debian() {
    echo "Installiere Dependencies (APT)…"
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip git wget curl build-essential
}

install_deps_mac() {
    echo "Installiere macOS Dependencies…"
    brew install python3 git wget curl
}

install_dependencies() {
    case "$OS" in
        bazzite) install_deps_bazzite ;;
        fedora) install_deps_fedora ;;
        debian) install_deps_debian ;;
        mac) install_deps_mac ;;
        *) echo "Unsupported OS."; exit 1 ;;
    esac
}

# ============================================================
#   COMFYUI INSTALLATION
# ============================================================

install_comfyui() {
    echo "Installiere ComfyUI…"

    git clone https://github.com/comfyanonymous/ComfyUI.git "$AITOOLS/ComfyUI"

    python3 -m venv "$VENV_DIR/comfyui"
    source "$VENV_DIR/comfyui/bin/activate"
    pip install --upgrade pip
    pip install -r "$AITOOLS/ComfyUI/requirements.txt"
    deactivate
}

# ============================================================
#   OPENWEBUI INSTALLATION
# ============================================================

install_openwebui() {
    echo "Installiere OpenWebUI…"

    python3 -m venv "$VENV_DIR/openwebui"
    source "$VENV_DIR/openwebui/bin/activate"
    pip install --upgrade pip
    pip install open-webui
    deactivate
}

# ============================================================
#   SDXL INSTALLATION
# ============================================================

install_sdxl() {
    echo ""
    read -p "SDXL Base + Refiner herunterladen? (~13 GB) [Y/n]: " DOWNLOAD_SDXL
    DOWNLOAD_SDXL=${DOWNLOAD_SDXL:-y}

    if [[ "$DOWNLOAD_SDXL" =~ ^[Yy]$ ]]; then
        MODEL_DIR="$AITOOLS/ComfyUI/models/checkpoints"
        mkdir -p "$MODEL_DIR"

        wget -nc -O "$MODEL_DIR/sd_xl_base_1.0.safetensors" \
            https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

        wget -nc -O "$MODEL_DIR/sd_xl_refiner_1.0.safetensors" \
            https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors

        echo "SDXL Modelle installiert."
    else
        echo "SDXL Download übersprungen."
    fi
}

# ============================================================
#   INSTALLATION
# ============================================================

run_install() {
    echo "=== Starte Installation ==="

    mkdir -p "$AITOOLS"
    mkdir -p "$VENV_DIR"

    install_dependencies
    install_comfyui
    install_openwebui
    install_sdxl

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

        source "$VENV_DIR/comfyui/bin/activate"
        pip install --upgrade pip
        pip install --upgrade -r requirements.txt
        deactivate
    fi

    # --- OpenWebUI Update ---
    if [[ -d "$VENV_DIR/openwebui" ]]; then
        echo "Aktualisiere OpenWebUI…"
        source "$VENV_DIR/openwebui/bin/activate"
        pip install --upgrade pip
        pip install --upgrade open-webui
        deactivate
    fi

    echo "=== Update abgeschlossen ==="
}

# ============================================================
#   MODUS AUSWERTEN
# ============================================================

case "$MODE" in
    install) run_install ;;
    update) update_all ;;
    help|*) show_help ;;
esac
