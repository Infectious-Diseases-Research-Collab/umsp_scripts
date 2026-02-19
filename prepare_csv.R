# Libraries (Silenced) ----------------------------------------------------
suppressPackageStartupMessages({
  library(readstata13)
  library(tidyverse)
  library(anytime)
})

# User Configuration ------------------------------------------------------
# Update this value to match the latest UMSP .dta file from Box.
INPUT_DTA_FILE <- "Monthly data for all sites through December 2025.dta"

# Load Data ---------------------------------------------------------------
if (!file.exists(INPUT_DTA_FILE)) {
  stop(
    paste0(
      "Input file not found: ", INPUT_DTA_FILE, "\n",
      "Update INPUT_DTA_FILE at the top of prepare_csv.R to the latest .dta filename ",
      "from the UMSP Box folder, and ensure the file is in this directory."
    )
  )
}

umsp_data <- read.dta13(
  INPUT_DTA_FILE,
  convert.factors = TRUE,
  generate.factors = TRUE,
  encoding = "UTF-8",
  convert.underscore = FALSE,
  missing.type = TRUE,
  convert.dates = TRUE,
  replace.strl = TRUE,
  nonint.factors = TRUE
)

# Process Time Variables --------------------------------------------------
umsp_data <- umsp_data |>
  mutate(
    monthyear = as.Date(monthyear),
    quarter = paste(year(monthyear), "Q", quarter(monthyear), sep = " "),
    year = year(monthyear)
  )

# Extract Site and District -----------------------------------------------
umsp_data <- umsp_data |>
  mutate(
    district = str_extract(NEWsiteID, "\\((.*?)\\)"),
    district = str_replace_all(district, "\\(|District\\)", "") |> str_trim(),
    Site = str_trim(str_extract(NEWsiteID, "^[^(]+"))
  )

# Calculate and Rename Metrics --------------------------------------------
umsp_data <- umsp_data |>
  rename(
    malaria_incidence_per_1000_PY = MI1000,
    TPR_cases_all = TPR,
    TPR_cases_per_CA = TPRCA,
    propsuspected_per_total_visits = propsuspected
  ) |>
  mutate(
    prop_visit_CA = visitsCA / visits
  )

# Final Dataset Preparation -----------------------------------------------
final_umsp_dashboard_df <- umsp_data |>
  dplyr::select(
    Site, Region, district,
    monthyear, quarter, year,
    malaria_incidence_per_1000_PY, TPR_cases_all, TPR_cases_per_CA,
    visits, malariasuspected, propsuspected_per_total_visits,
    proptested, prop_visit_CA
  ) |>
  rename_with(tolower)

# Save to CSV (With NULL fix for Supabase) --------------------------------
write.csv(
  final_umsp_dashboard_df,
  "final_umsp_dashboard_df.csv",
  row.names = FALSE,
  na = "" # This ensures missing values are NULL in Supabase
)

cat("Successfully processed data and saved to final_umsp_dashboard_df.csv\n")
