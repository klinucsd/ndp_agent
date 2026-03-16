"""Apply NRP/DeepNDP patches to the installed deepagents-cli config.py.

Patches applied:
  1. detect_provider() — maps glm-* model names to the 'nrp' provider
  2. _UNICODE_BANNER   — replaces the splash banner with DeepNDP branding
"""

import os
import re
import sysconfig

site = sysconfig.get_path("purelib")
config_path = os.path.join(site, "deepagents_cli", "config.py")

print(f"Patching {config_path}")
with open(config_path) as f:
    content = f.read()

# ── 1. detect_provider: glm-* → nrp ──────────────────────────────────────────
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
    print("  ✓ Patched detect_provider: glm -> nrp")
else:
    print("  ⚠ WARNING: detect_provider patch failed (pattern not found)")
    print("    Bare 'glm-4.7' will not auto-detect; use 'nrp:glm-4.7' explicitly.")

# ── 2. _UNICODE_BANNER: DeepNDP branding ──────────────────────────────────────
deep_ndp_banner = (
    '_UNICODE_BANNER = f"""\n'
    "██████╗  ███████╗ ███████╗ ██████╗     ███╗   ██╗ ██████╗  ██████╗ \n"
    "██╔══██╗ ██╔════╝ ██╔════╝ ██╔══██╗    ████╗  ██║ ██╔══██╗ ██╔══██╗\n"
    "██║  ██║ █████╗   █████╗   ██████╔╝    ██╔██╗ ██║ ██║  ██║ ██████╔╝\n"
    "██║  ██║ ██╔══╝   ██╔══╝   ██╔═══╝     ██║╚██╗██║ ██║  ██║ ██╔═══╝ \n"
    "██████╔╝ ███████╗ ███████╗ ██║         ██║ ╚████║ ██████╔╝ ██║     \n"
    "╚═════╝  ╚══════╝ ╚══════╝ ╚═╝         ╚═╝  ╚═══╝ ╚═════╝  ╚═╝   \n"
    "                                                  v{__version__}\n"
    '"""'
)

patched = re.sub(
    r"_UNICODE_BANNER\s*=\s*f\"\"\".*?\"\"\"",
    deep_ndp_banner,
    content,
    flags=re.DOTALL,
)
if patched != content:
    content = patched
    print("  ✓ Patched _UNICODE_BANNER to DeepNDP branding")
else:
    print("  ⚠ WARNING: _UNICODE_BANNER patch failed (pattern not found)")

with open(config_path, "w") as f:
    f.write(content)

print("Done.")
