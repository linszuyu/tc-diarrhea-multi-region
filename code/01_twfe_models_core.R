# Aim 2: Multi-country TWFE models (core specification)
# Code only for model clarity and reproducibility (no data included)

source(here::here("packages/packages-to-load.R"))
library(fixest)
library(splines)

# Data paths (data not included in this repository)
df_list <- list(
  bgd_morb = readRDS("data/analysis_data/Bangladesh_morbidity.rds"),
  chn_morb = readRDS("data/analysis_data/China_morbidity.rds"),
  ind_mort = readRDS("data/analysis_data/India_mortality.rds"),
  jpn_morb = readRDS("data/analysis_data/Japan_morbidity.rds"),
  kor_morb = readRDS("data/analysis_data/South_Korea_morbidity.rds"),
  mys_mort = readRDS("data/analysis_data/Malaysia_mortality.rds"),
  phl_mort = readRDS("data/analysis_data/Philippines_mortality.rds"),
  phl_morb = readRDS("data/analysis_data/Philippines_morbidity.rds"),
  tha_mort = readRDS("data/analysis_data/Thailand_mortality.rds"),
  tha_morb = readRDS("data/analysis_data/Thailand_morbidity.rds"),
  twn_morb = readRDS("data/analysis_data/Taiwan_morbidity.rds"),
  vnm_morb = readRDS("data/analysis_data/Vietnam_morbidity.rds")
)

# Exposure definitions
categories <- c(
  "wind.int", "R85", "R90", "R95", "R99",
  "Wtd_R85", "Wtd_R90", "Wtd_R95", "Wtd_R99",
  "Wts_R85", "Wts_R90", "Wts_R95", "Wts_R99",
  "Wty_R85", "Wty_R90", "Wty_R95", "Wty_R99"
)

# Country-specific covariate and fixed-effect structure
# fixest syntax: covariates | fixed effects
mod <- list(
  bgd = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month",
  chn = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month",
  ind = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month",
  jpn = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month",
  kor = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month",
  mys = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month",
  phl = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month",
  tha = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month",
  twn = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month",
  vnm = "ns(t2m, knots = quantile(t2m, c(0.33, 0.66))) + ns(tp, knots = quantile(tp, c(0.33, 0.66))) | subnat + year^month + subnat^year + subnat^month"
)

# Example estimation (not run here):
# fml <- paste0("cases ~ R95 + ", mod$twn)
# feglm(as.formula(fml), data = df_list$twn_morb,
#       family = "quasipoisson", vcov = "iid")
