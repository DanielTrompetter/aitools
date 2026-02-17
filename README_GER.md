# AI Tools Setup

Dieses Repository enthält ein universelles Setup-Script (`setup.sh`), das unter **Linux (Debian, Mint, Nobara, Fedora)** sowie **macOS** automatisch eine vollständige Arbeitsumgebung für folgende Komponenten einrichtet:

- **ComfyUI**
- **OpenWebUI**
- **SDXL-Workflows**
- **ai_control.py** (grafisches Control Panel)
- **Python Virtual Environments (venvs)**

Das Script installiert **keine Modelle oder Repositories direkt im Git**, sondern lädt alle benötigten Komponenten automatisch aus offiziellen Quellen.

---

## Voraussetzungen

### Allgemein
- Installiertes **Ollama** mit mindestens einem Modell  
  (z. B. `llama3`, `mistral`, `qwen2`, etc.)

### Linux (Ubuntu/Mint/Debian/Nobara/Fedora)
- bash
- apt oder dnf (je nach Distribution)
- Internetverbindung

### macOS
- bash
- Homebrew (wird automatisch installiert, falls nicht vorhanden)

---

## Features

- Automatische Betriebssystem-Erkennung (Linux / macOS)
- Installation aller benötigten Systempakete
- Erstellung einer sauberen Ordnerstruktur unter `~/aitools`
- Automatisches Klonen von:
  - **ComfyUI**
  - **OpenWebUI**
- Erstellung isolierter Python-Umgebungen (`venv`)
- Installation aller Python-Abhängigkeiten
- Kopieren des grafischen Control Panels `ai_control.py`
- **Optionaler Download der SDXL Base + Refiner Modelle**
- Vollständig portabel, reproduzierbar und leicht zu aktualisieren

---

## Ordnerstruktur nach Installation

Nach dem Ausführen von `setup.sh` sieht die Struktur wie folgt aus:

~/aitools/
│
├── ai_control.py
├── workflows/
│   └── mini_workflow.json
│
├── venvs/
│   └── ai_env/
│
├── ComfyUI/        (automatisch geklont)
└── openwebui/      (automatisch geklont)


---

## Nutzung

### Linux
Einfach im Terminal starten:

python3 ~/aitools/ai_control.py

Das Control Panel ist selbsterklärend und startet ComfyUI, OpenWebUI und Ollama automatisch.

### macOS
Im Terminal:

bash ~/aitools/start_mac.sh

Danach im Browser:


Weitere Hinweise siehe unten.

---

## Weitere Setup-Hinweise

Nach der Installation müssen in OpenWebUI noch einige Einstellungen vorgenommen werden, um die Bildgenerierung zu aktivieren.

1. Admin-Bereich öffnen  
2. **Einstellungen → Bilder**  
3. Werte entsprechend dem Screenshot `settings_example.png` setzen  
4. Unter *ComfyUI Workflow* die Datei `mini_workflow.json` aus dem Ordner `workflows/` hochladen

Damit ist die Bildgenerierung vollständig eingerichtet.

---

## Lizenz

Dieses Setup ist frei nutzbar.  
ComfyUI und OpenWebUI unterliegen ihren jeweiligen Lizenzen.
