#!/usr/bin/env python3

import os
import shutil
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib

import subprocess
import threading
import socket
import requests

# --- Portprüfung ---
def port_open(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.2)
    try:
        s.connect(("127.0.0.1", port))
        s.close()
        return True
    except:
        return False


# --- ComfyUI API Check ---
def comfy_api_ok():
    try:
        r = requests.get("http://127.0.0.1:8188/object_info", timeout=0.2)
        return r.status_code == 200
    except:
        return False


# --- Prozessprüfung ---
def process_running(keyword):
    try:
        out = subprocess.check_output(["ps", "aux"], text=True)
        return any(keyword in line for line in out.splitlines())
    except:
        return False


# --- Ollama: Modelle entladen ---
def unload_all_ollama_models():
    try:
        out = subprocess.check_output(["ollama", "ps"], text=True)
        lines = out.splitlines()[1:]
        models = [line.split()[0] for line in lines if line.strip()]

        for model in models:
            print(f"Entlade Modell: {model}")
            subprocess.call(["ollama", "stop", model])

    except Exception as e:
        print(f"Fehler beim Unload: {e}")


# --- Ollama Runner killen ---
def kill_ollama_runners():
    subprocess.call(["pkill", "-f", "ollama runner"])



class AIControl(Gtk.Window):
    def __init__(self):
        super().__init__(title="AI Control Panel")
        self.set_default_size(700, 500)
        self.set_size_request(700, 500)

        self.comfy_process = None
        self.webui_process = None

        vbox = Gtk.VBox(spacing=6)
        self.add(vbox)

        # --- Status-LEDs ---
        status_hbox = Gtk.HBox(spacing=20)

        self.status_comfy = Gtk.Label()
        self.status_webui = Gtk.Label()
        self.status_ollama = Gtk.Label()

        status_hbox.pack_start(self.status_comfy, False, False, 0)
        status_hbox.pack_start(self.status_webui, False, False, 0)
        status_hbox.pack_start(self.status_ollama, False, False, 0)

        vbox.pack_start(status_hbox, False, False, 0)

        # --- Buttons ---
        hbox = Gtk.HBox(spacing=6)
        vbox.pack_start(hbox, False, False, 0)

        self.start_services = Gtk.Button(label="Start Services")
        self.start_services.connect("clicked", self.start_services_all)
        hbox.pack_start(self.start_services, True, True, 0)

        self.stop_all = Gtk.Button(label="Stop All")
        self.stop_all.connect("clicked", self.stop_all_services)
        hbox.pack_start(self.stop_all, True, True, 0)

        # --- NEW BUTTON: Clean Cache ---
        self.clean_cache_btn = Gtk.Button(label="Clean Cache")
        self.clean_cache_btn.connect("clicked", self.clean_cache)
        hbox.pack_start(self.clean_cache_btn, True, True, 0)

        # --- Terminal Output ---
        self.output = Gtk.TextView()
        self.output.set_editable(False)
        self.output.set_cursor_visible(False)

        scroller = Gtk.ScrolledWindow()
        scroller.add(self.output)
        vbox.pack_start(scroller, True, True, 0)

        self.buffer = self.output.get_buffer()

        GLib.timeout_add_seconds(2, self.update_status)
        self.update_status()


    def log(self, text):
        self.buffer.insert(self.buffer.get_end_iter(), text + "\n")
        mark = self.buffer.create_mark(None, self.buffer.get_end_iter(), False)
        self.output.scroll_to_mark(mark, 0.0, True, 0.0, 1.0)


    def stream_output(self, process):
        for line in iter(process.stdout.readline, b''):
            GLib.idle_add(self.log, line.decode().rstrip())


    def update_status(self):
        comfy_running = comfy_api_ok()
        webui_running = (
            port_open(8080) or
            process_running("open-webui") or
            process_running("open_webui")
        )
        ollama_running = port_open(11434) or process_running("ollama serve")

        self.status_comfy.set_text(f"ComfyUI:   {'🟢 läuft' if comfy_running else '🔴 gestoppt'}")
        self.status_webui.set_text(f"OpenWebUI: {'🟢 läuft' if webui_running else '🔴 gestoppt'}")
        self.status_ollama.set_text(f"Ollama:    {'🟢 läuft' if ollama_running else '🔴 gestoppt'}")

        return True


    # --- Start Services ---
    def start_services_all(self, widget):
        self.log("Starte alle Services...")

        # ComfyUI
        if not self.comfy_process:
            self.log("Starte ComfyUI...")
            self.comfy_process = subprocess.Popen(
                ["bash", "-c",
                 "source ~/aitools/venvs/comfyui/bin/activate && python3 -u ~/aitools/ComfyUI/main.py --listen --enable-cors-header --verbose DEBUG --log-stdout"],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT
            )
            threading.Thread(target=self.stream_output, args=(self.comfy_process,), daemon=True).start()
        else:
            self.log("ComfyUI läuft bereits.")

        # OpenWebUI
        if not self.webui_process:
            self.log("Starte OpenWebUI (Validation OFF)...")
            self.webui_process = subprocess.Popen(
                ["bash", "-c",
                 "export WEBUI_DISABLE_RESOLUTION_CHECK=1 && "
                 "source ~/aitools/venvs/openwebui/bin/activate && "
                 "open-webui serve"],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT
            )
            threading.Thread(target=self.stream_output, args=(self.webui_process,), daemon=True).start()
        else:
            self.log("OpenWebUI läuft bereits.")

        self.log("Alle Services gestartet.")


    # --- Stop All ---
    def stop_all_services(self, widget):
        self.log("Stoppe alle Services...")

        if self.comfy_process:
            self.comfy_process.terminate()
            self.comfy_process = None
        subprocess.call(["pkill", "-f", "ComfyUI/main.py"])
        self.log("ComfyUI gestoppt.")

        if self.webui_process:
            self.webui_process.terminate()
            self.webui_process = None
        subprocess.call(["pkill", "-f", "open_webui"])
        subprocess.call(["pkill", "-f", "open-webui"])
        self.log("OpenWebUI gestoppt.")

        self.log("Entlade alle Ollama-Modelle...")
        unload_all_ollama_models()

        self.log("Entferne hängende Ollama-Runner...")
        kill_ollama_runners()

        self.log("Alle Services gestoppt.")


    # --- NEW: Safe Clean Cache ---
    def clean_cache(self, widget):
        self.log("🧹 Leere OpenWebUI Cache (SAFE MODE)...")

        data_dir = os.path.expanduser(
            "~/aitools/venvs/openwebui/lib/python3.11/site-packages/open_webui/data"
        )

        # Nur Ordner, die KEINE User-Daten enthalten
        safe_targets = [
            "cache",
            "uploads"
        ]

        for folder in safe_targets:
            path = os.path.join(data_dir, folder)
            if os.path.exists(path):
                try:
                    for item in os.listdir(path):
                        item_path = os.path.join(path, item)
                        if os.path.isfile(item_path):
                            os.remove(item_path)
                        else:
                            shutil.rmtree(item_path)
                    self.log(f"✔ {folder} geleert.")
                except Exception as e:
                    self.log(f"Fehler beim Löschen von {folder}: {e}")
            else:
                self.log(f"{folder} existiert nicht, übersprungen.")

        self.log("🧹 SAFE Cleanup abgeschlossen (keine Accounts gelöscht).")


win = AIControl()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
