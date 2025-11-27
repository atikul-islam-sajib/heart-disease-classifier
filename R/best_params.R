print_best_tune <- function(model, name = "Model") {
  if (!is.null(model$bestTune)) {
    cat("\nBest tuning parameters for", name, ":\n")
    print(model$bestTune)
  } else {
    cat("\nNo tuning parameters found for", name, "\n")
  }
}

print_best_tune(rf_model, "Random Forest")
print_best_tune(svm_model, "SVM")

