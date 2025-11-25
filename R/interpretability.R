library(iml)
library(dplyr)
library(ggplot2)
source("R/utils.R")

set_global_seed()


# Load Data
train <- read.csv("data/processed/train_scaled.csv", stringsAsFactors = TRUE)
val   <- read.csv("data/processed/val_scaled.csv",   stringsAsFactors = TRUE)

full_train <- rbind(train, val)
full_train$HeartDisease <- factor(full_train$HeartDisease)
full_train$HeartDisease <- relevel(full_train$HeartDisease, ref = "Yes")

X <- dplyr::select(full_train, -HeartDisease)
y <- full_train$HeartDisease

# Load Final Models
rf_model  <- readRDS("checkpoints/model_random_forest.rds")
svm_model <- readRDS("checkpoints/model_svm.rds")

# Create Output Folder
if (!dir.exists("artifacts/interpret")) {
  dir.create("artifacts/interpret", recursive = TRUE)
}

# Random Forest – Feature Importance
pred_rf <- Predictor$new(
  model = rf_model,
  data  = X,
  y     = y,
  type  = "prob"
)

imp_rf <- FeatureImp$new(pred_rf, loss = "ce")
imp_df <- imp_rf$results

p_bar <- ggplot(imp_df,
                aes(x = reorder(feature, importance), y = importance)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "RF Feature Importance (Barplot)",
    x = "Feature",
    y = "Importance"
  )

ggsave("artifacts/interpret/rf_feature_importance_bar.png",
       p_bar, width = 6, height = 4)

# SVM – Feature Importance
pred_svm <- Predictor$new(
  model = svm_model,
  data  = X,
  y     = y,
  type  = "prob"
)

imp_svm <- FeatureImp$new(pred_svm, loss = "ce")
imp_svm_df <- imp_svm$results

p_svm_bar <- ggplot(imp_svm_df,
                    aes(x = reorder(feature, importance),
                        y = importance)) +
  geom_col(fill = "darkred") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "SVM Feature Importance (Permutation Importance)",
    x = "Feature",
    y = "Importance"
  )

ggsave("artifacts/interpret/svm_feature_importance_bar.png",
       p_svm_bar, width = 6, height = 4)

cat("Interpretability barplots created and saved successfully.\n")
