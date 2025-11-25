GLOBAL_SEED <- 123

set_global_seed <- function() {
  set.seed(GLOBAL_SEED)
}

check_missing <- function(df) {
  colSums(is.na(df))
}

class_balance <- function(df, target_col = "HeartDisease") {
  table(df[[target_col]])
}
