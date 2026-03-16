#!/bin/bash
set -e

# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# add uv to PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# create a virtual environment
uv venv -p 3.11 .venv --clear

# activate the virtual environment
source .venv/bin/activate

# install latest deepagents-cli with openai extra (NRP uses an OpenAI-compatible API)
uv pip install "deepagents-cli[openai]"

# find site-packages directory
SITE_PACKAGES=$(.venv/bin/python -c "import sysconfig; print(sysconfig.get_path('purelib'))")

# patch detect_provider() in config.py to recognize glm models as the nrp provider
.venv/bin/python << PYEOF
import os

config_path = os.path.join("$SITE_PACKAGES", "deepagents_cli", "config.py")
with open(config_path) as f:
    content = f.read()

old = (
    '    if model_lower.startswith(("nemotron", "nvidia/")):\n'
    '        return "nvidia"\n\n'
    '    return None'
)
new = (
    '    if model_lower.startswith(("nemotron", "nvidia/")):\n'
    '        return "nvidia"\n\n'
    '    if model_lower.startswith("glm"):\n'
    '        return "nrp"\n\n'
    '    return None'
)

if old in content:
    content = content.replace(old, new)
    print("  ✓ Patched config.py: glm models now map to nrp provider")
else:
    print("  ⚠ WARNING: Could not patch detect_provider() in config.py")
    print("    The pattern has changed in this deepagents-cli version.")
    print("    Bare 'glm-4.7' will not auto-detect; use 'nrp:glm-4.7' explicitly.")

# patch _UNICODE_BANNER to DeepNDP branding
import re

deep_ndp_banner = '_UNICODE_BANNER = f"""\n' \
    '██████╗  ███████╗ ███████╗ ██████╗     ███╗   ██╗ ██████╗  ██████╗ \n' \
    '██╔══██╗ ██╔════╝ ██╔════╝ ██╔══██╗    ████╗  ██║ ██╔══██╗ ██╔══██╗\n' \
    '██║  ██║ █████╗   █████╗   ██████╔╝    ██╔██╗ ██║ ██║  ██║ ██████╔╝\n' \
    '██║  ██║ ██╔══╝   ██╔══╝   ██╔═══╝     ██║╚██╗██║ ██║  ██║ ██╔═══╝ \n' \
    '██████╔╝ ███████╗ ███████╗ ██║         ██║ ╚████║ ██████╔╝ ██║     \n' \
    '╚═════╝  ╚══════╝ ╚══════╝ ╚═╝         ╚═╝  ╚═══╝ ╚═════╝  ╚═╝   \n' \
    '                                                  v{__version__}\n' \
    '"""'

patched = re.sub(r'_UNICODE_BANNER\s*=\s*f""".*?"""', deep_ndp_banner, content, flags=re.DOTALL)
if patched != content:
    content = patched
    print("  ✓ Patched config.py: replaced banner with DeepNDP branding")
else:
    print("  ⚠ WARNING: Could not patch _UNICODE_BANNER in config.py")

with open(config_path, "w") as f:
    f.write(content)
PYEOF

# rename binary
mv .venv/bin/deepagents .venv/bin/deepndp

# add NRP provider to ~/.deepagents/config.toml (merges with existing config)
mkdir -p ~/.deepagents
.venv/bin/python << PYEOF
import tomllib, tomli_w
from pathlib import Path

config_path = Path.home() / ".deepagents" / "config.toml"

config = {}
if config_path.exists():
    with open(config_path, "rb") as f:
        config = tomllib.load(f)

config.setdefault("models", {})
config["models"].setdefault("providers", {})

changed = False

if "nrp" not in config["models"]["providers"]:
    config["models"]["providers"]["nrp"] = {
        "class_path": "langchain_openai:ChatOpenAI",
        "models": ["glm-4.7"],
        "api_key_env": "NRP_API_KEY",
        "base_url": "https://ellm.nrp-nautilus.io/v1",
        "params": {"temperature": 0},
    }
    changed = True
    print("  ✓ Added NRP provider to ~/.deepagents/config.toml")
else:
    print("  ✓ NRP provider already in ~/.deepagents/config.toml")

if not config["models"].get("default"):
    config["models"]["default"] = "nrp:glm-4.7"
    changed = True
    print("  ✓ Set default model to nrp:glm-4.7")

if changed:
    with open(config_path, "wb") as f:
        tomli_w.dump(config, f)
PYEOF

# copy skills
mkdir -p ~/.deepagents/agent/skills
cp -r deepndp_skills/* ~/.deepagents/agent/skills/

echo ""
echo "=========================================="
echo "✓ DeepNDP installed successfully!"
echo "=========================================="
echo ""
echo "To start using DeepNDP, set your NRP API key."
echo ""
echo "Recommended (GLM-4.7 from NRP, default):"
echo "  - NRP_API_KEY"
echo ""
echo "Other supported LLM API keys:"
echo "  - OPENAI_API_KEY"
echo "  - ANTHROPIC_API_KEY"
echo "  - GOOGLE_API_KEY"
echo ""
echo "You can set API keys in two ways:"
echo "  1. Add to .env file: NRP_API_KEY='your-api-key-here'"
echo "  2. Export as environment variable: export NRP_API_KEY='your-api-key-here'"
echo ""
echo "Then run: source .venv/bin/activate && deepndp"
echo "=========================================="
