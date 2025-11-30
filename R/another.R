# ======================================================
# Scratch Chi-Square Test + simple human explanations
# ======================================================

chi_square_report <- function(feature_name, feature_vector, target_vector) {
  
  # Create contingency table
  tbl <- table(feature_vector, target_vector)
  
  # Convert to numeric matrix
  observed <- as.matrix(tbl)
  
  # Row & column totals
  row_totals <- rowSums(observed)
  col_totals <- colSums(observed)
  grand_total <- sum(observed)
  
  # Expected counts
  expected <- outer(row_totals, col_totals) / grand_total
  
  # Chi-square statistic
  chi_square_value <- sum((observed - expected)**2 / expected)
  
  # Degrees of freedom
  df <- (nrow(observed) - 1) * (ncol(observed) - 1)
  
  # p-value
  p_value <- 1 - pchisq(chi_square_value, df)
  
  # ======================================================
  # PRINT REPORT
  # ======================================================
  
  cat("\n=====================================================\n")
  cat("Feature:", feature_name, "\n\n")
  
  # Hypotheses
  cat("H0 (Null Hypothesis):\n")
  cat("  This feature is NOT related to heart disease.\n")
  cat("  (both groups have similar proportions)\n\n")
  
  cat("H1 (Alternative Hypothesis):\n")
  cat("  This feature IS related to heart disease.\n")
  cat("  (the proportions are different)\n\n")
  
  # Print results
  cat("Chi-Square Results:\n")
  cat("  chi-square value:", round(chi_square_value, 4), "\n")
  cat("  p-value:", format(p_value, scientific = TRUE), "\n")
  cat("  degrees of freedom:", df, "\n\n")
  
  cat("Observed Counts:\n")
  print(observed)
  cat("\nExpected Counts:\n")
  print(round(expected, 2))
  cat("\n")
  
  # Decision + simple explanation
  if (p_value < 0.05) {
    cat("Decision:\n")
    cat("  The test is significant, so I reject the null hypothesis.\n\n")
    
    cat("Conclusion (Simple Words):\n")
    cat("  The distribution of", feature_name, "is different for people with and without heart disease.\n")
    cat("  This means", feature_name, "is related to heart disease.\n")
    
  } else {
    cat("Decision:\n")
    cat("  The test is not significant, so I do NOT reject the null hypothesis.\n\n")
    
    cat("Conclusion (Simple Words):\n")
    cat("  People with and without heart disease show similar patterns for", feature_name, ".\n")
    cat("  This feature does not seem related to heart disease.\n")
  }
  
  cat("=====================================================\n")
}


# ======================================================
# Apply to all categorical features
# ======================================================

categorical_cols <- c("Sex", "ChestPainType", "RestingECG",
                      "ExerciseAngina", "ST_Slope")

for (col in categorical_cols) {
  chi_square_report(
    feature_name = col,
    feature_vector = train[[col]],
    target_vector = train$HeartDisease
  )
}
