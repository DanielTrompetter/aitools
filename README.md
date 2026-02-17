# AI Tools Setup

This repository provides a universal setup script (`setup.sh`) that automatically installs a complete working environment for:

- **ComfyUI**
- **OpenWebUI**
- **SDXL workflows**
- **ai_control.py** (graphical control panel)
- **Python virtual environments**

The script does **not** include models or large repositories inside the Git repo.  
All required components are downloaded from their official sources during installation.

---

## Requirements

### General
- A working **Ollama** installation with at least one model installed

### Linux (Ubuntu/Mint/Debian/Nobara/Fedora)
- bash
- apt or dnf (depending on the distribution)
- Internet connection

### macOS
- bash
- Homebrew (automatically installed if missing)

---

## Features

- Automatic OS detection (Linux / macOS)
- Installation of all required system packages
- Creation of a clean directory structure under `~/aitools`
- Automatic cloning of:
  - **ComfyUI**
  - **OpenWebUI**
- Creation of isolated Python virtual environments
- Installation of all Python dependencies
- Deployment of the graphical control panel `ai_control.py`
- **Optional download of SDXL Base + Refiner models**
- Fully portable and reproducible setup

---

## Directory Structure After Installation

After running `setup.sh`, your system will look like this:

~/aitools/
│
├── ai_control.py
├── workflows/
│   └── mini_workflow.json
│
├── venvs/
│   └── ai_env/
│
├── ComfyUI/        (cloned automatically)
└── openwebui/      (cloned automatically)

---

## Usage

### Linux
Start the control panel:
python3 ~/aitools/ai_control.py

It provides an easy-to-use interface to start/stop ComfyUI, OpenWebUI, and Ollama.

### macOS
Run:
bash ~/aitools/start_mac.sh

Then open in your browser:
http://localhost:8080/


---

## Additional Setup Notes

After installation, a few settings must be configured inside OpenWebUI to enable image generation.

1. Open the Admin Panel  
2. Go to **Settings → Images**  
3. Apply the values shown in `settings_example.png`  
4. Upload the workflow file `mini_workflow.json` from the `workflows/` directory

This completes the image generation setup.

---

## License

This setup is free to use.  
ComfyUI and OpenWebUI are subject to their respective licenses.


