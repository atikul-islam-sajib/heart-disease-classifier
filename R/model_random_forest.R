library(caret)
library(ranger)
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

##############################################################################################
#                                      CV Settings
#                           5-fold cross-validation with AUC
##############################################################################################

ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

##############################################################################################
#                                       Hyperparameter Grid
#                                   ---------------------------
#             mtry: How many features the model looks at when splitting
#             splitrule: How the tree chooses a split -> test gini only
#             min.node.size: Smallest number of samples allowed in a leaf
##############################################################################################

grid <- expand.grid(
  mtry = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11),
  splitrule = c("gini", "extratrees", "hellinger"),
  min.node.size = c(5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)
)

##############################################################################################
#                           Train & Tune RF -> Train dataset ONLY
#                     ----------------------------------------------------
#                We use only the training set for cross-validation.
#                The goal here is: Find the best hyperparameters
#                using AUC (ROC) as the main evaluation metric.
##############################################################################################

rf_tuned <- caret::train(
  HeartDisease ~ .,
  data = train,
  method = "ranger",
  metric = "ROC",
  trControl = ctrl,
  tuneGrid = grid,
  importance = "impurity",
  num.trees = 300,
  sample.fraction = 0.1,
  replace = TRUE,
  regularization.factor = 0.01,
  regularization.use = TRUE
)

cat("Best RF hyperparameters CV on train:\n")
print(rf_tuned$bestTune)

##############################################################################################
#                       Save Tuning Results -> ROC + Sens + Spec
##############################################################################################

results_small <- rf_tuned$results[, c("mtry",
                                      "splitrule",
                                      "min.node.size",
                                      "ROC",
                                      "Sens",
                                      "Spec")]

print(results_small)

write.csv(results_small,
          "checkpoints/rf_results.csv",
          row.names = FALSE)

saveRDS(rf_tuned, "checkpoints/rf_tuned.rds")
saveRDS(rf_tuned$bestTune, "checkpoints/best_rf_params.rds")

##############################################################################################
#                             Final RF Model -> Train + Validation
#                       ------------------------------------------------
#       After selecting the best hyperparameters from CV on TRAIN only,
#       we now retrain the final RF model using TRAIN + VAL combined.
##############################################################################################

full_train <- rbind(train, val)
full_train$HeartDisease <- relevel(full_train$HeartDisease, ref = "Yes")

best_rf <- readRDS("checkpoints/best_rf_params.rds")

ctrl_final <- trainControl(method = "none", classProbs = TRUE)

rf_final <- caret::train(
  HeartDisease ~ .,
  data = full_train,
  method = "ranger",
  trControl = ctrl_final,
  tuneGrid = best_rf,
  importance = "impurity",
  num.trees = 300,
  sample.fraction = 0.01,
  replace = TRUE
)

##############################################################################################
#                                        Save Final Model
##############################################################################################

saveRDS(rf_final, "checkpoints/model_random_forest.rds")

cat("Final RF model trained on train+val\n")