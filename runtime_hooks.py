# Copyright 2025 the LlamaFactory team.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
PyInstaller runtime hook for the frozen LLaMA Factory desktop app.

The hook executes inside the frozen binary before ``src/webui.py`` runs.  It
redirects stdout/stderr to a log file in the user's home directory so startup
errors are visible even when the app is launched by double-clicking, and it
pre-sets environment defaults that make the desktop app behave well (UTF-8
output and localhost binding to avoid OS firewall prompts).
"""

import os
import sys

_LOG_NAME = "llamafactory.log"


def _install_logging():
    if not getattr(sys, "frozen", False):
        return

    log_path = os.path.join(os.path.expanduser("~"), _LOG_NAME)
    try:
        stream = open(log_path, "a", buffering=1, encoding="utf-8")
        sys.stdout = stream
        sys.stderr = stream
        print("=== LLaMA Factory runtime hook: logging to %s ===" % log_path)
    except OSError:
        pass


def _env_defaults():
    os.environ.setdefault("PYTHONUTF8", "1")
    os.environ.setdefault("PYTHONIOENCODING", "utf-8")
    os.environ.setdefault("GRADIO_SERVER_NAME", "127.0.0.1")


_install_logging()
_env_defaults()
del _install_logging, _env_defaults, _LOG_NAME
