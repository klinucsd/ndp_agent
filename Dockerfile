# =============================================================================
# DeepNDP Docker Image - NRP JupyterHub Deployment
# =============================================================================
#
# Build:
#   docker build -t deepndp:jupyterhub .
#
# Tag and push:
#   docker tag deepndp:jupyterhub kaiucsd/deepndp:jupyterhub
#   docker push kaiucsd/deepndp:jupyterhub
#
# NRP_API_KEY is injected at runtime via NRP JupyterHub environment variable
# settings, or a .env file in the working directory.
#
# Image Details:
#   - Base: jupyter/base-notebook (Python 3, JupyterLab, jovyan user pre-configured)
#   - User: jovyan (UID 1000)
#   - Home: /home/jovyan/work
#   - Port: 8888
#   - Skills: ndp-search, us-states, us-counties, usgs-earthquake-events,
#             ndp-workspaces
# =============================================================================

FROM quay.io/jupyter/base-notebook:latest

# -----------------------------------------------------------------------------
# Step 0: Install Common System Tools
# -----------------------------------------------------------------------------
USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git curl wget zip unzip vim \
    openssh-client rsync ripgrep \
    less tree htop nano jq \
    build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Step 1: Install DeepAgents CLI
# -----------------------------------------------------------------------------
# [openai] extra provides langchain-openai (ChatOpenAI) for NRP's GLM endpoint
RUN pip install --no-cache-dir "deepagents-cli[openai]"

# -----------------------------------------------------------------------------
# Step 2: Copy Assets
# -----------------------------------------------------------------------------
COPY deepndp_skills /tmp/build/skills
COPY apply_ndp_patch.py /tmp/build/

# -----------------------------------------------------------------------------
# Step 3: Apply DeepNDP Patches to config.py
# -----------------------------------------------------------------------------
RUN python /tmp/build/apply_ndp_patch.py

# -----------------------------------------------------------------------------
# Step 4: Install Skills and Config for jovyan
# -----------------------------------------------------------------------------
RUN mkdir -p /home/jovyan/.deepagents/agent/skills && \
    cp -r /tmp/build/skills/* /home/jovyan/.deepagents/agent/skills/

# Write NRP provider config to jovyan's config.toml
RUN python -c "\
import tomli_w; \
from pathlib import Path; \
p = Path('/home/jovyan/.deepagents/config.toml'); \
tomli_w.dump({ \
    'models': { \
        'default': 'nrp:glm-4.7', \
        'providers': { \
            'nrp': { \
                'class_path': 'langchain_openai:ChatOpenAI', \
                'models': ['glm-4.7'], \
                'api_key_env': 'NRP_API_KEY', \
                'base_url': 'https://ellm.nrp-nautilus.io/v1', \
                'params': {'temperature': 0}, \
            } \
        } \
    } \
}, open(p, 'wb')); \
print('Written', p)"

RUN ln -s /opt/conda/bin/deepagents /usr/local/bin/deepndp

RUN chown -R jovyan:users /home/jovyan/.deepagents && \
    rm -rf /tmp/build

# -----------------------------------------------------------------------------
# Step 5: Switch to JupyterHub User
# -----------------------------------------------------------------------------
USER jovyan
WORKDIR /home/jovyan/work

EXPOSE 8888
CMD ["sleep", "infinity"]
