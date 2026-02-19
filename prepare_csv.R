# Libraries (Silenced) ----------------------------------------------------
suppressPackageStartupMessages({
  library(readstata13)
  library(tidyverse)
  library(anytime)
})

# Smart Working Directory -------------------------------------------------
if (interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  script_path <- sub(file_arg, "", args[grep(file_arg, args)])
  if (length(script_path) > 0) {
    setwd(dirname(normalizePath(script_path)))
  }
}

# Load Data ---------------------------------------------------------------
umsp_data <- read.dta13(
  "Monthly data for all sites through December 2025.dta",
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
