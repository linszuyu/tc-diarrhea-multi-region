# =============================================================================     
# Description: Defines shared settings used in 02_main_analysis.R, including
#              country lists, TC exposure variables, model specifications,
#              spline terms, and file paths.
# =============================================================================

# -----------------------------------------------------------------------------
# Section 1: Country lists
# -----------------------------------------------------------------------------
asian_countries <- c(
  "Bangladesh", "China", "India", "Japan", "South Korea",
  "Malaysia", "Philippines", "Thailand", "Taiwan", "Vietnam"
)

mortality_countries <- c("India", "Malaysia", "Philippines", "Thailand")

morbidity_countries <- c(
  "Bangladesh", "China", "Japan", "South Korea",
  "Philippines", "Thailand", "Taiwan", "Vietnam"
)

# -----------------------------------------------------------------------------
# Section 2: File paths
# Note: Data files are not included in this repository.
# Request access at https://paulcarlos.quarto.pub/climed/
# -----------------------------------------------------------------------------
path_analysis_agg <- here::here("data/analysis_data/analysis_data_agg.rds")
path_figures      <- here::here("figures")
path_output       <- here::here("output")

# -----------------------------------------------------------------------------
# Section 3: Figure settings
# -----------------------------------------------------------------------------
fig_dpi    <- 600
fig_device <- "pdf"

# -----------------------------------------------------------------------------
# Section 4: TC exposure variables
# -----------------------------------------------------------------------------
tc_variables <- c(
  "wind.int",
  "R85",  "R90",  "R95",  "R99",
  "Wtd_R85", "Wtd_R90", "Wtd_R95", "Wtd_R99",
  "Wts_R85", "Wts_R90", "Wts_R95", "Wts_R99",
  "Wty_R85", "Wty_R90", "Wty_R95", "Wty_R99"
)

# -----------------------------------------------------------------------------
# Section 5: Spline terms for temperature and precipitation covariates
# Knots placed at 33rd and 66th percentiles following Chua et al. (2024)
# -----------------------------------------------------------------------------
t2m_term <- "ns(t2m, knots = quantile(t2m, c(0.33, 0.66)))"
tp_term  <- "ns(tp, knots = quantile(tp, c(0.33, 0.66)))"

# -----------------------------------------------------------------------------
# Section 6: Best-fit fixed effects specifications per region
# Selected based on lowest qAIC using Wtd_R85 as the a priori exposure
# Bangladesh and Malaysia have one subnational unit so no subnat interactions
# -----------------------------------------------------------------------------
mod <- list(
  "Bangladesh"  = "subnat + year^month",
  "China"       = "subnat + year^month + subnat^year + subnat^month",
  "India"       = "subnat + year^month + subnat^year + subnat^month",
  "Japan"       = "subnat + year^month + subnat^year + subnat^month",
  "South Korea" = "subnat + year^month + subnat^year + subnat^month",
  "Malaysia"    = "subnat + year^month",
  "Philippines" = "subnat + year^month + subnat^year + subnat^month",
  "Thailand"    = "subnat + year^month + subnat^year + subnat^month",
  "Taiwan"      = "subnat + year^month + subnat^year + subnat^month",
  "Vietnam"     = "subnat + year^month + subnat^year + subnat^month"
)
