# Note: Requires config.R and packages-to-load.R to run.
#       Data not included - request at https://paulcarlos.quarto.pub/climed/

# Load packages
source(here::here("packages/packages-to-load.R"))

# Load shared settings
source(here::here("scripts/config.R"))

# Load analysis data
analysis_data <- readRDS(path_analysis_agg)

# -----------------------------------------------------------------------------
# 1. Define country-outcome combinations
# -----------------------------------------------------------------------------
analysis_combos <- bind_rows(
  tibble(country = mortality_countries, outcome_type = "mortality"),
  tibble(country = morbidity_countries, outcome_type = "morbidity")
)

# -----------------------------------------------------------------------------
# 2. Functions to extract cumulative lag 0+1 effect
# -----------------------------------------------------------------------------

# For binary TC variables (R85, Wtd_R85 etc.)
extract_cumulative <- function(model, cat) {
  lag1_name <- paste0(cat, "_lag1")
  b0 <- model$coefficients[cat]
  b1 <- model$coefficients[lag1_name]
  cum_coef <- b0 + b1
  vcov_mat <- model$cov.iid
  var_cum  <- vcov_mat[cat, cat] +
    vcov_mat[lag1_name, lag1_name] +
    2 * vcov_mat[cat, lag1_name]
  se_cum <- sqrt(var_cum)
  tibble(
    irr     = exp(cum_coef),
    ci_low  = exp(cum_coef - 1.96 * se_cum),
    ci_high = exp(cum_coef + 1.96 * se_cum)
  )
}

# For wind.int factor variable (TD/TS/TY)
extract_wind <- function(model, level, label) {
  lag0_name  <- paste0("factor(wind.int)", level)
  lag1_name  <- paste0("factor(wind.int_lag1)", level)
  coef_names <- names(model$coefficients)
  
  if (lag0_name %in% coef_names & lag1_name %in% coef_names) {
    b0 <- model$coefficients[lag0_name]
    b1 <- model$coefficients[lag1_name]
    cum_coef <- b0 + b1
    vcov_mat <- model$cov.iid
    var_cum  <- vcov_mat[lag0_name, lag0_name] +
      vcov_mat[lag1_name, lag1_name] +
      2 * vcov_mat[lag0_name, lag1_name]
    se_cum <- sqrt(var_cum)
    tibble(
      tc_var  = label,
      irr     = exp(cum_coef),
      ci_low  = exp(cum_coef - 1.96 * se_cum),
      ci_high = exp(cum_coef + 1.96 * se_cum)
    )
  } else {
    tibble(tc_var = label, irr = NA_real_, ci_low = NA_real_, ci_high = NA_real_)
  }
}

# -----------------------------------------------------------------------------
# 3. Run main analysis
# -----------------------------------------------------------------------------
all_results <- data.frame()

for (i in seq_len(nrow(analysis_combos))) {
  
  country      <- analysis_combos$country[i]
  outcome_type <- analysis_combos$outcome_type[i]
  
  message("Running: ", country, " - ", outcome_type)
  
  df <- analysis_data %>%
    filter(name == country, mortality_morbidity == outcome_type)
  
  fe_spec <- mod[[country]]
  
  df$year   <- factor(df$year)
  df$week   <- factor(df$week)
  df$month  <- factor(df$month)
  df$subnat <- factor(df$subnat)
  
  for (cat in tc_variables) {
    
    message("  Model: ", cat)
    
    if (cat == "wind.int") {
      
      formula_str <- paste0(
        "cases ~ factor(wind.int) + factor(wind.int_lag1) + ",
        t2m_term, " + ", tp_term, " + offset(log(popden)) | ", fe_spec
      )
      
      result <- feglm(
        as.formula(formula_str),
        data   = df,
        vcov   = "iid",
        family = "quasipoisson"
      )
      
      wind_levels <- list(c("1", "TD"), c("2", "TS"), c("3", "TY"))
      
      for (lv in wind_levels) {
        res <- extract_wind(result, lv[1], lv[2])
        all_results <- rbind(all_results, data.frame(
          country      = country,
          outcome_type = outcome_type,
          tc_var       = res$tc_var,
          lag          = "lag0+1",
          irr          = res$irr,
          ci_low       = res$ci_low,
          ci_high      = res$ci_high
        ))
      }
      
    } else {
      
      formula_str <- paste0(
        "cases ~ ", cat, " + ", cat, "_lag1 + ",
        t2m_term, " + ", tp_term, " + offset(log(popden)) | ", fe_spec
      )
      
      result <- feglm(
        as.formula(formula_str),
        data   = df,
        vcov   = "iid",
        family = "quasipoisson"
      )
      
      lag1_name  <- paste0(cat, "_lag1")
      coef_names <- names(result$coefficients)
      
      if (cat %in% coef_names & lag1_name %in% coef_names) {
        res <- extract_cumulative(result, cat)
        all_results <- rbind(all_results, data.frame(
          country      = country,
          outcome_type = outcome_type,
          tc_var       = cat,
          lag          = "lag0+1",
          irr          = res$irr,
          ci_low       = res$ci_low,
          ci_high      = res$ci_high
        ))
      } else {
        all_results <- rbind(all_results, data.frame(
          country      = country,
          outcome_type = outcome_type,
          tc_var       = cat,
          lag          = "lag0+1",
          irr          = NA_real_,
          ci_low       = NA_real_,
          ci_high      = NA_real_
        ))
      }
    }
  }
  
  message("Done: ", country, " - ", outcome_type)
}
