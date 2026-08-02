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
PyInstaller spec file for LLaMA Factory Web UI.

Build instructions:
  # macOS  →  ./build-mac.sh    (produces dist/LLaMA Factory.app)
  # Windows → .\\build-windows.bat  (produces dist/LLaMAFactory\\LLaMAFactory.exe)

macOS uses the standard onedir layout (EXE -> COLLECT -> BUNDLE) so the
resulting .app is a real application bundle and starts fast.  The same layout
is used on Windows (a folder containing the executable and its libraries).
console=True keeps the error output visible instead of silently showing a
"Failed to execute script" dialog and hanging.
"""

import os
import platform
import sys

from PyInstaller.utils.hooks import collect_data_files, collect_submodules

spec_dir = os.getcwd()
src_dir = os.path.join(spec_dir, "src")

sys.path.insert(0, src_dir)

# ---------------------------------------------------------------------------
# Data-file discovery.
#
# The llamafactory source tree and the dataset registry are bundled explicitly.
# Everything else (transformers, gradio, tokenizers, ...) relies on PyInstaller
# hooks plus collect_data_files() for the packages that ship runtime resources.
# ---------------------------------------------------------------------------
datas: list[tuple[str, str]] = [
    (os.path.join("src", "llamafactory"), "llamafactory"),
    (os.path.join("data", "dataset_info.json"), "data"),
]

# gradio generates type stubs at import time and must ship its Python sources.
try:
    datas += collect_data_files("gradio", include_py_files=True)
except Exception:
    pass

for _pkg in [
    "gradio_client",
    "safehttpx",
    "groovy",
    "transformers",
    "tokenizers",
    "datasets",
    "tiktoken",
    "sentencepiece",
    "matplotlib",
    "huggingface_hub",
    "accelerate",
    "peft",
    "trl",
    "modelscope",
    "modelscope_hub",
]:
    try:
        datas += collect_data_files(_pkg)
    except Exception:
        pass

hiddenimports = [
    # Core ML stack
    "torch", "torch.nn", "torch.optim", "torch.utils.data",
    "torch.distributed", "torch.multiprocessing",
    "torchvision", "torchvision.ops", "torchaudio",
    # Transformers & related
    "transformers", "transformers.models", "transformers.models.auto",
    "transformers.models.llama", "transformers.models.llama3",
    "transformers.models.mistral", "transformers.models.qwen2",
    "transformers.models.gemma", "transformers.models.phi",
    "transformers.models.glm", "transformers.models.bert",
    "transformers.models.roberta",
    "transformers.utils", "transformers.utils.import_utils",
    # Accelerate / PEFT / TRL
    "accelerate", "accelerate.commands",
    "peft", "peft.tuners", "peft.tuners.lora",
    "trl", "trl.models", "trl.core",
    # Datasets / tokenizers
    "datasets", "datasets.arrow_dataset",
    "datasets.packaged_modules", "datasets.fingerprint",
    "tokenizers", "tiktoken", "sentencepiece",
    # Gradio / web
    "gradio", "gradio.blocks", "gradio.components",
    "gradio.layouts", "gradio.templates", "gradio.routes",
    "gradio_client",
    "matplotlib",
    # API / server
    "uvicorn", "uvicorn.config", "uvicorn.loops", "uvicorn.protocols",
    "fastapi", "fastapi.middleware", "fastapi.routing",
    "sse_starlette",
    # Utilities
    "pyyaml", "omegaconf", "pydantic",
    "numpy", "pandas", "scipy", "einops",
    "safetensors", "hf_transfer", "modelscope",
    "packaging", "protobuf", "fire", "tyro", "psutil",
    # LLaMA Factory sub-modules
    "llamafactory.webui.chatter",
    "llamafactory.webui.common",
    "llamafactory.webui.control",
    "llamafactory.webui.engine",
    "llamafactory.webui.interface",
    "llamafactory.webui.runner",
    "llamafactory.webui.css",
    "llamafactory.webui.manager",
    "llamafactory.chat.chat_model",
    "llamafactory.train.tuner",
    "llamafactory.model.loader",
    "llamafactory.model.adapter",
    "llamafactory.model.patcher",
    "llamafactory.data.loader",
    "llamafactory.data.template",
    "llamafactory.data.formatter",
    "llamafactory.data.collator",
    "llamafactory.hparams.parser",
    "llamafactory.hparams.model_args",
    "llamafactory.hparams.data_args",
    "llamafactory.hparams.finetuning_args",
    "llamafactory.hparams.training_args",
    "llamafactory.hparams.generating_args",
    "llamafactory.hparams.evaluation_args",
    "llamafactory.extras.logging",
    "llamafactory.extras.misc",
    "llamafactory.extras.env",
    "llamafactory.extras.constants",
    "llamafactory.extras.packages",
    "llamafactory.api.app",
]

# The dynamic importers / web frameworks are safer fully enumerated.
for _pkg in ["gradio", "gradio_client", "uvicorn", "fastapi", "sse_starlette"]:
    try:
        hiddenimports += collect_submodules(_pkg)
    except Exception:
        pass

# ---------------------------------------------------------------------------
# Analysis
# ---------------------------------------------------------------------------
a = Analysis(
    ["src/webui.py"],
    pathex=[src_dir],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookdirs=[],
    runtime_hooks=["runtime_hooks.py"],
    excludes=[
        "pytest", "ruff", "deepspeed", "bitsandbytes",
        "flash_attn", "PyQt5", "tensorboard",
        "matplotlib.backends.backend_webagg",
        "matplotlib.backends.backend_webagg_core",
        "torch.utils.tensorboard",
    ],
)

pyz = PYZ(a.pure)

if platform.system() == "Darwin":
    # macOS: proper .app bundle (onedir). console=True so startup errors are
    # visible in a terminal instead of an invisible "Failed to execute script"
    # dialog that hangs forever.
    exe = EXE(
        pyz,
        a.scripts,
        exclude_binaries=True,
        strip=False,
        upx=False,
        console=True,
        disable_windowed_traceback=False,
        argv_emulation=False,
        name="LLaMAFactory",
    )
    coll = COLLECT(
        exe,
        a.binaries,
        a.datas,
        strip=False,
        upx=False,
        name="LLaMAFactory",
    )
    app = BUNDLE(
        coll,
        name="LLaMA Factory.app",
        version="0.9.6",
        icon=None,
        info_plist={
            "CFBundleName": "LLaMA Factory",
            "CFBundleDisplayName": "LLaMA Factory",
            "CFBundleIdentifier": "net.llamafactory.app",
            "CFBundleVersion": "0.9.6",
            "CFBundleShortVersionString": "0.9.6",
            "CFBundlePackageType": "APPL",
            "CFBundleExecutable": "LLaMAFactory",
            "LSMinimumSystemVersion": "10.15.0",
            "NSHighResolutionCapable": True,
            "CFBundleDocumentTypes": [],
        },
    )
else:
    # Windows / Linux: onedir folder with the executable inside.
    exe = EXE(
        pyz,
        a.scripts,
        exclude_binaries=True,
        strip=False,
        upx=False,
        console=True,
        disable_windowed_traceback=False,
        argv_emulation=False,
        name="LLaMAFactory",
    )
    coll = COLLECT(
        exe,
        a.binaries,
        a.datas,
        strip=False,
        upx=False,
        name="LLaMAFactory",
    )
