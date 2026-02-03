# AI Tools Setup

Dieses Repository enthält ein universelles Setup-Script (`setup.sh`), das unter **Linux** und **macOS** automatisch eine vollständige Arbeitsumgebung für:

- **ComfyUI**
- **OpenWebUI**
- **SDXL-Workflows**
- **ai_control.py** (Control Panel)
- **Python venvs**

einrichtet.

Das Script installiert **keine Modelle oder Repos direkt im Git**, sondern lädt sie automatisch aus offiziellen Quellen.


---

## Voraussetzungen

### Linux (Ubuntu/Mint/Debian)
- bash
- apt
- Internetverbindung

### macOS
- bash
- Homebrew (wird automatisch installiert, falls nicht vorhanden)

---

## Features

- Automatische OS-Erkennung (Linux / macOS)
- Installation aller benötigten Systempakete
- Erstellung einer sauberen Ordnerstruktur unter `~/aitools`
- Klonen von:
  - **ComfyUI**
  - **OpenWebUI**
- Erstellung einer Python-Umgebung (`venv`)
- Installation der passenden Python-Requirements
- Kopieren der Workflows (z. B. `sd_xl_workflow.json`)
- Kopieren von `ai_control.py`
- **Optionaler Download der SDXL Base + Refiner Modelle**
- Vollständig portabel und reproduzierbar

---

## Ordnerstruktur nach Installation

Nach dem Ausführen von `setup.sh` sieht dein System so aus:
~/aitools/
│
├── ai_control.py
├── workflows/
│   └── sd_xl_workflow.json
│
├── venvs/
│   └── ai_env/
│
├── ComfyUI/        (automatisch geklont)
└── openwebui/      (automatisch geklont)

---

## Lizenz
Dieses Setup ist frei nutzbar.
ComfyUI und OpenWebUI unterliegen ihren jeweiligen Lizenzen.

