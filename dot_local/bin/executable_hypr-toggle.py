#!/usr/bin/env python3
import json
import shlex
import shutil
import subprocess
import argparse
from collections import ChainMap
from pathlib import Path
from typing import Any, Callable


class Hypr:
    @staticmethod
    def dispatch(*args):
        subprocess.run(["hyprctl", "dispatch", *args], check=False)

    @staticmethod
    def message(msg):
        output = subprocess.check_output(["hyprctl", "-j", msg], text=True)
        return json.loads(output)


hypr = Hypr()


def is_subset(superset, subset):
    for key, value in subset.items():
        if key not in superset:
            return False
        if isinstance(value, dict):
            if not is_subset(superset[key], value):
                return False
        elif isinstance(value, str):
            if value not in superset[key]:
                return False
        elif isinstance(value, list):
            if not set(value) <= set(superset[key]):
                return False
        elif isinstance(value, set):
            if not value <= superset[key]:
                return False
        else:
            if not value == superset[key]:
                return False
    return True


class DeepChainMap(ChainMap):
    def __getitem__(self, key):
        values = (mapping[key] for mapping in self.maps if key in mapping)
        try:
            first = next(values)
        except StopIteration:
            return self.__missing__(key)
        if isinstance(first, dict):
            return self.__class__(first, *values)
        return first


class Command:
    def __init__(self, workspace: str) -> None:
        self.workspace = workspace
        self.clients = None

        self.cfg = {
            "sysmon": {
                "btop": {
                    "enable": True,
                    "match": [{"title": "btop"}],
                    "command": ["ghostty", "-e", "btop"],
                    "move": True,
                },
            },
            "music": {
                "players": {
                    "enable": True,
                    "match": [
                        {"class": "Spotify"},
                        {"class": "spotify"},
                        {"title": "Spotify"},
                        {"class": "feishin"},
                        {"class": "Supersonic"},
                        {"class": "Cider"},
                        {"class": "com.github.th_ch.youtube_music"},
                        {"class": "Plexamp"},
                    ],
                    "command": ["spotify"],  # Change to your preferred default player
                    "move": True,
                },
            },
            "communication": {
                "chat": {
                    "enable": True,
                    "match": [
                        {"class": "discord"},
                        {"class": "equibop"},
                        {"class": "vesktop"},
                        {"class": "org.telegram.desktop"},
                        {"class": "TelegramDesktop"},
                        {"class": "whatsapp"},
                        {"class": "Element"},
                    ],
                    "command": ["discord"],  # Change to your preferred default chat app
                    "move": True,
                },
            },
            "games": {
                "launchers": {
                    "enable": True,
                    "match": [
                        {"class": "steam"},
                        {"class": "lutris"},
                        {"class": "com.heroicgameslauncher.hgl"},
                        {"class": "heroic"},
                    ],
                    "command": ["steam"],  # Defaults to opening Steam
                    "move": True,
                },
            },
            "audio": {
                "easyeffects": {
                    "enable": True,
                    "match": [{"class": "com.github.wwmm.easyeffects"}],
                    "command": ["easyeffects"],
                    "move": True,
                },
            },
        }

        user_config_path = Path.home() / ".config" / "hypr-toggle" / "config.json"
        if user_config_path.exists():
            try:
                self.cfg = DeepChainMap(
                    json.loads(user_config_path.read_text()).get("toggles", {}),
                    self.cfg,
                )
            except Exception as e:
                print(f"Failed to load user config: {e}")

    def run(self) -> None:
        if self.workspace == "specialws":
            self.specialws()
            return

        if self.workspace in self.cfg:
            for client in self.cfg[self.workspace].values():
                if client.get("enable"):
                    self.handle_client_config(client)

        # BUG FIX: Always toggle the workspace so it drops down immediately!
        # Even if the app takes 2 seconds to load, the workspace will be waiting for it.
        hypr.dispatch("togglespecialworkspace", self.workspace)

    def get_clients(self) -> list[dict[str, Any]]:
        if self.clients is None:
            self.clients = hypr.message("clients")
        return self.clients

    def move_client(self, selector: Callable, workspace: str) -> None:
        for client in self.get_clients():
            if (
                selector(client)
                and client["workspace"]["name"] != f"special:{workspace}"
            ):
                hypr.dispatch(
                    "movetoworkspacesilent",
                    f"special:{workspace},address:{client['address']}",
                )

    def spawn_client(self, selector: Callable, spawn: list[str]) -> bool:
        if (spawn[0].endswith(".desktop") or shutil.which(spawn[0])) and not any(
            selector(client) for client in self.get_clients()
        ):
            cmd_str = shlex.join(spawn)
            hypr.dispatch("exec", f"{cmd_str}")
            return True
        return False

    def handle_client_config(self, client: dict[str, Any]) -> bool:
        def selector(c: dict[str, Any]) -> bool:
            for match in client["match"]:
                if is_subset(c, match):
                    return True
            return False

        spawned = False
        if client.get("command"):
            spawned = self.spawn_client(selector, client["command"])
        if client.get("move"):
            self.move_client(selector, self.workspace)

        return spawned

    def specialws(self) -> None:
        monitors = hypr.message("monitors")
        target = next((m for m in monitors if m.get("focused")), None)
        if target:
            special = (
                target.get("specialWorkspace", {}).get("name", "")[8:] or "special"
            )
            hypr.dispatch("togglespecialworkspace", special)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Toggle Hyprland special workspaces")
    parser.add_argument(
        "workspace", help="Name of the workspace to toggle (e.g., music, communication)"
    )
    args = parser.parse_args()

    Command(args.workspace).run()
