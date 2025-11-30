##############################################################
#                           T-TEST                         
##############################################################
t_test <- function(feature_name, group_no, group_yes) {

  n_no  <- length(group_no)
  n_yes <- length(group_yes)
  
  mean_no  <- mean(group_no)
  mean_yes <- mean(group_yes)
  
  variance_no  <- var(group_no)
  variance_yes <- var(group_yes)
  
  # t-value
  t_value <- (mean_no - mean_yes) / sqrt(variance_no/n_no + variance_yes/n_yes)
  
  # formula -> from Stat Course
  df <- (variance_no/n_no + variance_yes/n_yes)**2 /
    ((variance_no**2)/(n_no**2 * (n_no - 1)) +
       (variance_yes**2)/(n_yes**2 * (n_yes - 1)))
  
  # p-value
  p_value <- 2 * (1 - pt(abs(t_value), df))
  
  # print all the conclusion
  
  cat("\n----------------------------------------------------------------\n")
  cat("Feature:", feature_name, "\n\n")
  
  # Hypotheses
  cat("H0(Null Hypothesis): ")
  cat("People with and without heart disease have similar", feature_name, ".\n\n")
  
  cat("Ha(Alternative Hypothesis): ")
  cat("The two groups do NOT have similar", feature_name, ".\n\n")
  
  # Test values
  cat("Test Results:\n")
  cat("  t-value:", round(t_value, 4), "\n")
  cat("  p-value:", format(p_value, scientific = TRUE), "\n\n")
  
  cat("Group Averages:\n")
  cat("  No heart disease:", round(mean_no, 4), "\n")
  cat("  Yes heart disease:", round(mean_yes, 4), "\n\n")
  
  # Decision
  if (p_value < 0.05) {
    cat("Decision:")
    cat("  The test is significant, so We reject the null hypothesis.\n\n")
    
    if (mean_yes > mean_no) {
      cat("Conclusion:")
      cat("  People with heart disease tend to have higher", feature_name, ".\n")
      cat("  This feature seems related to heart disease.\n")
    } else {
      cat("Conclusion:")
      cat("  People without heart disease tend to have higher", feature_name, ".\n")
      cat("  The feature still differs between groups.\n")
    }
    
  } else {
    cat("Decision:")
    cat("  The test is not significant, so We do not reject the null hypothesis.\n\n")
    
    cat("Conclusion:")
    cat("  This feature does not show a meaningful difference between the groups.\n")
  }
}


##############################################################
#                        CHI-SQUARE TEST                     #
##############################################################
chi_square <- function(feature_name, feature_vector, target_vector) {
  
  # Create contingency table - Stat Course
  tbl <- table(feature_vector, target_vector)
  observed <- as.matrix(tbl)
  
  # Row totals, column totals, grand total
  row_totals <- rowSums(observed)
  col_totals <- colSums(observed)
  grand_total <- sum(observed)
  
  # Expected counts (row total * col total / grand total)
  expected <- outer(row_totals, col_totals) / grand_total
  
  # Chi-square statistic
  chi_square_value <- sum((observed - expected)**2 / expected)
  
  # Degrees of freedom
  df <- (nrow(observed) - 1) * (ncol(observed) - 1)
  
  # p-value
  p_value <- 1 - pchisq(chi_square_value, df)
  
  # Print all conclusions
  cat("\n----------------------------------------------------------------\n")
  cat("Feature:", feature_name, "\n\n")
  
  # Hypotheses
  cat("H0(Null Hypothesis): ")
  cat("People with and without heart disease have similar", feature_name, "distribution.\n\n")
  
  cat("Ha(Alternative Hypothesis): ")
  cat("The two groups do NOT have similar", feature_name, "distribution.\n\n")
  
  # Test values
  cat("Test Results:\n")
  cat("  Chi-square value:", round(chi_square_value, 4), "\n")
  cat("  p-value:", format(p_value, scientific = TRUE), "\n")
  cat("  Degrees of freedom:", df, "\n\n")
  
  # Decision
  if (p_value < 0.05) {
    cat("Decision:")
    cat("  The test is significant, so we reject the null hypothesis.\n\n")
    
    cat("Conclusion:")
    cat(" This feature seems related to heart disease.\n")
    
  } else {
    cat("Decision:")
    cat(" The test is not significant, so we do not reject the null hypothesis.\n\n")
    
    cat("Conclusion:")
    cat(" This feature does not show a meaningful difference between the groups.\n")
  }
}

############################################################
#       Run the t-tests for each numeric feature
#                  Features name
#                ------------------
#             Age, RestingBP, Cholesterol
#             FastingBS, MaxHR, Oldpeak
############################################################

numeric_cols <- c("Age", "RestingBP", "Cholesterol",
                  "FastingBS", "MaxHR", "Oldpeak")

for (col in numeric_cols) {
  group_no  <- train[[col]][train$HeartDisease == "No"]
  group_yes <- train[[col]][train$HeartDisease == "Yes"]
  
  t_test(col, group_no, group_yes)
}

cat("\n*******Chi-Square Tests for Each Categorical Features*******\n")

############################################################
# Run Chi-Square Tests for Each Categorical Feature
#                  Features name
#                ------------------
#             Sex, ChestPainType, RestingECG
#                  ExerciseAngina, ST_Slope
############################################################

categorical_cols <- c("Sex", "ChestPainType", "RestingECG",
                      "ExerciseAngina", "ST_Slope")

for (col in categorical_cols) {
  chi_square(
    feature_name = col,
    feature_vector = train[[col]],
    target_vector = train$HeartDisease
  )
}
