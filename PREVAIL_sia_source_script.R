###########################################################
# LAUNCH
#
# Main launch function for WHO EPI50 analysis.
#
# Note that this software requires an internet connection.
#
# Authors: A.J.Shattock & H.C.Johnson
###########################################################

# Set working directory to sourced file
# if (interactive()) setwd(getSrcDirectory(function() {}))

# Load all required packages and functions
source("dependencies.R")

message("Running EPI50 pipeline")

# Define modules to be run
run_modules = 1 : 8

# Set global options (see options.R)
o = set_options(run_module = run_modules)

# Module 1) Prepare all inputs (only needs to be done once)
run_prepare()  # See prepare.R

# Extract coverage for VIMC pathogens
vimc_dt = coverage_vimc()

# However not every country is covered by VIMC for these pathogens
vimc_countries_dt = vimc_dt %>%
  select(d_v_a_id, country, year, source) %>%
  arrange(d_v_a_id, country, year) %>%
  unique()

# Incorporate non-routine SIA data (from WIISE)
sia_dt = coverage_sia(vimc_countries_dt)  # See sia.R

#Add in extra information
tab1 <- import("output/0_tables/d_v_a_table.rds")
tab2 <- import("output/0_tables/d_v_a_extern_table.rds")

translate_vacc <- tab1 %>%
  select(names(tab2)) %>% 
  rbind(tab2)

#Combine with sia
sia_vimc <- sia_dt %>%
  left_join(
    translate_vacc, by = "d_v_a_id"
  ) %>%
  select(area = country,
         year,
         age,
         coverage,
         disease,
         vaccine)

export(sia_vimc, "output/sia_vimc.rds")






