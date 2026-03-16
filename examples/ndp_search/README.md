# NDP Search Examples

Example tasks demonstrating DeepNDP's ability to discover, analyze, and download datasets from the [National Data Platform](https://nationaldataplatform.org) catalog using the `ndp-search`, `us-counties`, `us-states`, and `usgs-earthquake-events` skills.

---

## Task 1: Spatiotemporal Dataset Discovery and Analysis

Find all datasets collected from GPS stations in San Diego County since 2023.

Extract the locations of the datasets from the search results, create a static map with San Diego county in PDF.

From the search results, are there any datasets collected in Carlsbad?

Download `CLBD.CI.LY_.20` in a folder, preserving the original file names.

Create a notebook to analyze the raw data from this dataset, including a cell that installs required packages using `!pip -q install ...`.

### Outputs

| File | Description |
|------|-------------|
| `verified_gps_datasets.json` | Search results — GPS station datasets in San Diego County since 2023 |
| `verified_gps_datasets.geojson` | Same results as GeoJSON for spatial visualization |
| `gps_stations_map.png` / `.pdf` | Static map of GPS station locations within San Diego County |
| `CLBD/CLBD.CI.LY_.20.csv` | Downloaded raw data for the CLBD station (Carlsbad) |
| `CLBD/CLBD.CI.LY_.20.png` | Preview plot of the raw data |
| `CLBD/CLBD.geojson` | Station location as GeoJSON |
| `CLBD_Analysis.ipynb` | Jupyter notebook analyzing the CLBD dataset |
| `CLBD_time_series.png` | Time series plot |
| `CLBD_daily_means.png` | Daily mean values |
| `CLBD_hourly_patterns.png` | Hourly patterns |
| `CLBD_distributions.png` | Data distributions |
| `CLBD_scatter.png` | Scatter plot |
| `CLBD_correlation.png` | Correlation matrix |

---

## Task 2: Event-Based Dataset Search and Analysis

Find earthquake events with magnitude > 5 in the United States between 2024-12-03 and 2024-12-15.
Summarize the results and save them as a GeoJSON file.

Identify GPS station datasets located within 100 miles of this earthquake event, and report the distance between each GPS station and the corresponding earthquake.

Download the dataset `P127.PW.LY_.00` into a local folder, preserving the original file names.

Create a Jupyter notebook to analyze the raw data:
1. Include a cell that installs required packages using `!pip install -q ...`
2. Pay special attention to the data around the time of the earthquake events
3. Ensure the notebook runs end-to-end without errors

---

## Task 3: Advanced Dataset Search for Specialized Requirements

Find long-term statewide historical hourly California weather data in the NDP catalog suitable for building short-term frost risk forecasting models for California specialty crops.

---

## Task 4: Carbon Turnover Time Study

- What is the average carbon turnover time in San Diego County? How about Los Angeles County?
- List the top 10 counties in California with the greatest average carbon turnover times.
- What is the resolution of this dataset (pixel size)?
- Set up 10 bins for carbon turnover times in San Diego County and create a bar diagram in PDF.
- Create a bar diagram comparing carbon turnover time distributions in San Diego County and Sierra County.

---

## Task 5: Interagency Activity Report

Find the interagency activity report 2.0.

Based on this dataset, create a notebook for reporting activities in San Diego from 2021–2024 with visualizations. Include a cell with `pip -q install ...` and verify the notebook works properly.
