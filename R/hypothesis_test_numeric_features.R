t_test_report <- function(feature_name, group_no, group_yes) {

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
  
  cat("\n----------------------------------------------------------------\n")
}


# Run the t-tests for each numeric feature

numeric_cols <- c("Age", "RestingBP", "Cholesterol",
                  "FastingBS", "MaxHR", "Oldpeak")

for (col in numeric_cols) {
  group_no  <- train[[col]][train$HeartDisease == "No"]
  group_yes <- train[[col]][train$HeartDisease == "Yes"]
  
  t_test_report(col, group_no, group_yes)
}
