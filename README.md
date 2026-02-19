# UMSP Scripts

This repository contains one production script: `prepare_csv.R`.

## What the script does

`prepare_csv.R`:

1. Reads the latest UMSP Stata dataset (`.dta`) from the local project folder.
2. Creates/cleans time fields (`monthyear`, `quarter`, `year`).
3. Extracts `district` and `Site` from `NEWsiteID`.
4. Renames key malaria metrics and computes `prop_visit_CA`.
5. Selects and standardizes dashboard columns (lowercase names).
6. Exports `final_umsp_dashboard_df.csv`.

The output CSV (`final_umsp_dashboard_df.csv`) is the dataset used by the UMSP dashboard.

## Required input

- The latest `.dta` file from the UMSP Box folder.
- Place it in this repository directory before running the script.

Set the input filename in `prepare_csv.R` under:

`# User Configuration`

Edit:

`INPUT_DTA_FILE <- "Monthly data for all sites through December 2025.dta"`

The default value is:

`Monthly data for all sites through December 2025.dta`

If the newest Box file has a different name, update `INPUT_DTA_FILE` to match.

If the file is missing or the name is incorrect, the script stops with a clear error message.

## How to run

Run from this repository folder (current working directory):

```bash
Rscript prepare_csv.R
```

On success, the script prints:

`Successfully processed data and saved to final_umsp_dashboard_df.csv`

## R packages used

- `readstata13`
- `tidyverse`
- `anytime`
