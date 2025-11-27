library(caret)
library(e1071)
source("R/utils.R")

set_global_seed()

# Load Data

train <- read.csv("data/processed/train_scaled.csv", stringsAsFactors = TRUE)
val   <- read.csv("data/processed/val_scaled.csv",   stringsAsFactors = TRUE)

train$HeartDisease <- factor(train$HeartDisease)
val$HeartDisease   <- factor(val$HeartDisease)

# Make "Yes" the positive class for ROC
train$HeartDisease <- relevel(train$HeartDisease, ref = "Yes")

# Create checkpoints folder : To save the artifacts
if (!dir.exists("checkpoints")) {
  dir.create("checkpoints", recursive = TRUE)
}

# CV Settings

ctrl <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

###########################################################################################################
#                                   Hyperparameter Grid
#                               --------------------------
#           C: Controls how much the model tries to avoid misclassification -> we test values: 0.1, 1, 10
#           sigma: Controls the smoothness of the radial (RBF) kernel -> we test values: 0.01, 0.05, 0.1
###########################################################################################################

grid <- expand.grid(
  C = c(1, 5, 10, 20, 50, 100, 200, 500, 1000),
  sigma = c(0.0001, 0.001, 0.005, 0.01)
)

# Train & Tune RF -> Train dataset Only

svm_tuned <- caret::train(
  HeartDisease ~ .,
  data = train,
  method = "svmRadial",
  metric = "ROC",
  trControl = ctrl,
  tuneGrid = grid
)

cat("Best SVM hyperparameters (CV on train):\n")
print(svm_tuned$bestTune)

# Save Tuning Results -> ROC + Sens + Spec

results_small <- svm_tuned$results[, c("C",
                                       "sigma",
                                       "ROC",
                                       "Sens",
                                       "Spec")]

print(results_small)

write.csv(results_small,
          "checkpoints/svm_results.csv",
          row.names = FALSE)

saveRDS(svm_tuned, "checkpoints/svm_tuned.rds")
saveRDS(svm_tuned$bestTune, "checkpoints/best_svm_params.rds")

# Final SVM Model -> Train + Val

full_train <- rbind(train, val)
full_train$HeartDisease <- relevel(full_train$HeartDisease, ref = "Yes")

best_svm <- readRDS("checkpoints/best_svm_params.rds")

ctrl_final <- trainControl(method = "none", classProbs = TRUE)

svm_final <- caret::train(
  HeartDisease ~ .,
  data = full_train,
  method = "svmRadial",
  trControl = ctrl_final,
  tuneGrid = best_svm
)

saveRDS(svm_final, "checkpoints/model_svm.rds")

cat("Final SVM model trained on train+val\n")
