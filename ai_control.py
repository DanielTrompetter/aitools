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


# --- ComfyUI Cache Reset ---
def reset_comfyui_cache():
    cache_path = os.path.expanduser("~/.cache/comfyui")
    if os.path.exists(cache_path):
        try:
            shutil.rmtree(cache_path)
            print("ComfyUI Cache gelöscht.")
        except Exception as e:
            print(f"Fehler beim Löschen des ComfyUI Caches: {e}")
    else:
        print("ComfyUI Cache war bereits leer.")

reset_comfyui_cache()


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


# --- Ollama: Alle Modelle entladen ---
def unload_all_ollama_models():
    try:
        requests.delete("http://127.0.0.1:11434/api/ps", timeout=0.5)
    except:
        pass


# --- Ollama: Runner-Zombies killen ---
def kill_ollama_runners():
    subprocess.call(["pkill", "-f", "ollama runner"])


class AIControl(Gtk.Window):
    def __init__(self):
        super().__init__(title="AI Control Panel")
        self.set_default_size(700, 500)
        self.set_size_request(700, 500)

        # getrennte Prozess-Handles
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

        # ComfyUI Buttons
        self.start_comfy = Gtk.Button(label="Start ComfyUI")
        self.start_comfy.connect("clicked", self.start_comfyui)
        hbox.pack_start(self.start_comfy, True, True, 0)

        self.stop_comfy = Gtk.Button(label="Stop ComfyUI")
        self.stop_comfy.connect("clicked", self.stop_comfyui)
        hbox.pack_start(self.stop_comfy, True, True, 0)

        # OpenWebUI Buttons
        self.start_webui = Gtk.Button(label="Start OpenWebUI")
        self.start_webui.connect("clicked", self.start_openwebui)
        hbox.pack_start(self.start_webui, True, True, 0)

        self.stop_webui = Gtk.Button(label="Stop OpenWebUI")
        self.stop_webui.connect("clicked", self.stop_openwebui)
        hbox.pack_start(self.stop_webui, True, True, 0)

        # --- Terminal Output ---
        self.output = Gtk.TextView()
        self.output.set_editable(False)
        self.output.set_cursor_visible(False)

        scroller = Gtk.ScrolledWindow()
        scroller.add(self.output)
        vbox.pack_start(scroller, True, True, 0)

        self.buffer = self.output.get_buffer()

        # --- Status alle 2 Sekunden ---
        GLib.timeout_add_seconds(2, self.update_status)
        self.update_status()

    # --- Log ---
    def log(self, text):
        self.buffer.insert(self.buffer.get_end_iter(), text + "\n")
        mark = self.buffer.create_mark(None, self.buffer.get_end_iter(), False)
        self.output.scroll_to_mark(mark, 0.0, True, 0.0, 1.0)

    # --- Output-Thread ---
    def stream_output(self, process):
        for line in iter(process.stdout.readline, b''):
            GLib.idle_add(self.log, line.decode().rstrip())

    # --- LED-Update ---
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

    # --- Start ComfyUI ---
    def start_comfyui(self, widget):
        if self.comfy_process:
            self.log("ComfyUI läuft bereits.")
            return

        self.log("Starte ComfyUI...")
        self.comfy_process = subprocess.Popen(
            ["bash", "-c",
             "source ~/aitools/venvs/comfyui/bin/activate && python3 -u ~/aitools/ComfyUI/main.py --listen --enable-cors-header --verbose DEBUG --log-stdout"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        threading.Thread(target=self.stream_output, args=(self.comfy_process,), daemon=True).start()

    # --- Stop ComfyUI ---
    def stop_comfyui(self, widget):
        self.log("Stoppe ComfyUI...")

        if self.comfy_process:
            self.comfy_process.terminate()
            self.comfy_process = None

        subprocess.call(["pkill", "-f", "ComfyUI/main.py"])
        self.log("ComfyUI gestoppt.")

    # --- Start OpenWebUI ---
    def start_openwebui(self, widget):
        if self.webui_process:
            self.log("OpenWebUI läuft bereits.")
            return

        self.log("Starte OpenWebUI...")
        self.webui_process = subprocess.Popen(
            ["bash", "-c",
             "~/aitools/venvs/openwebui/bin/open-webui serve"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        threading.Thread(target=self.stream_output, args=(self.webui_process,), daemon=True).start()

    # --- Stop OpenWebUI ---
    def stop_openwebui(self, widget):
        self.log("Stoppe OpenWebUI...")

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


win = AIControl()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
