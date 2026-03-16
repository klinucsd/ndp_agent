# DeepNDP

DeepNDP is an AI agent for the [National Data Platform (NDP)](https://nationaldataplatform.org). It wraps [`deepagents-cli`](https://pypi.org/project/deepagents-cli/) with NDP-specific skills that enable the agent to search the NDP dataset catalog, retrieve geospatial data, fetch earthquake events, and interact with NDP JupyterHub workspaces.

## Features

- Natural language dataset discovery across the NDP catalog
- Spatial and temporal filtering (county/state boundaries, date ranges)
- Automatic geometry verification (not just bounding boxes)
- Direct dataset download and analysis in Jupyter notebooks
- Runs on NRP JupyterHub or locally

## Quick Start

### Local Installation

```bash
git clone https://github.com/your-org/ndp_agent.git
cd ndp_agent
bash deepndp_install.sh
```

Set your API key (NRP recommended):
```bash
echo "NRP_API_KEY=your-api-key-here" > .env
```

Run:
```bash
source .venv/bin/activate && deepndp
```

### NRP JupyterHub

Pull the pre-built image:
```
kaiucsd/deepndp:v1.2
```

`NRP_API_KEY` is injected at runtime via JupyterHub environment variable settings or a `.env` file in the working directory.

## API Key Priority

The agent picks up the first key it finds:

| Priority | Environment Variable | Provider |
|----------|---------------------|----------|
| 1 | `NRP_API_KEY` | NRP GLM-4.7 (default) |
| 2 | `OPENAI_API_KEY` | OpenAI |
| 3 | `ANTHROPIC_API_KEY` | Anthropic Claude |
| 4 | `GOOGLE_API_KEY` / `GOOGLE_CLOUD_PROJECT` | Google Gemini / VertexAI |

Keys can be set in a `.env` file or as environment variables.

## Skills

| Skill | Data Source | Description |
|-------|-------------|-------------|
| `ndp-search` | NDP OpenSearch (via HFS proxy) | Search the NDP CKAN catalog by keyword, bounding box, and date range |
| `us-counties` | KnowWhereGraph / FRINK SPARQL | Get US county geometries as GeoDataFrames |
| `us-states` | KnowWhereGraph / FRINK SPARQL | Get US state geometries as GeoDataFrames |
| `usgs-earthquake-events` | USGS Earthquake Catalog API | Fetch seismic event data as GeoDataFrames |
| `ndp-workspaces` | NDP Workspace API | List and filter NRP JupyterHub workspace configurations |

Skills are installed to `~/.deepagents/agent/skills/` by the install script or Docker image.

## Repository Structure

```
ndp_agent/
├── Dockerfile               # NRP JupyterHub image (base: jupyter/base-notebook)
├── deepndp_install.sh       # Local install script
├── apply_ndp_patch.py       # Patches deepagents-cli config.py (used by Dockerfile)
├── deepndp_skills/          # Agent skills
│   ├── ndp-search/
│   ├── us-counties/
│   ├── us-states/
│   ├── usgs-earthquake-events/
│   └── ndp-workspaces/
└── examples/
    ├── ndp_search/          # Spatiotemporal dataset discovery tasks
    └── web_log_analysis/    # NDP Nginx log analysis
```

## Examples

### NDP Search

Tasks demonstrating spatiotemporal dataset discovery, event-based search, and data analysis. See [`examples/ndp_search/README.md`](examples/ndp_search/README.md).

**Task 1 outputs** (GPS stations in San Diego County since 2023):
- [`verified_gps_datasets.json`](examples/ndp_search/verified_gps_datasets.json) — search results
- [`gps_stations_map.pdf`](examples/ndp_search/gps_stations_map.pdf) — static map
- [`CLBD_Analysis.ipynb`](examples/ndp_search/CLBD_Analysis.ipynb) — data analysis notebook for station CLBD (Carlsbad)

### Web Log Analysis

Analysis of NDP Nginx access logs — unique users, dataset access counts, search activity. See [`examples/web_log_analysis/README.md`](examples/web_log_analysis/README.md).

## Docker Build

```bash
docker build -t deepndp:jupyterhub .
docker tag deepndp:jupyterhub kaiucsd/deepndp:vX.Y
docker push kaiucsd/deepndp:vX.Y
```

Always use a new version tag — NRP JupyterHub caches images by tag.

## Updating Skills

After editing a skill's `SKILL.md`, re-run the install script or copy manually:

```bash
cp -r deepndp_skills/* ~/.deepagents/agent/skills/
```
