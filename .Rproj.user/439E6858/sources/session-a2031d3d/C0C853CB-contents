library(caret)
library(pROC)
library(ggplot2)
source("R/utils.R")

set_global_seed()

# -----------------------------
# Load Data
# -----------------------------
train <- read.csv("data/processed/train_scaled.csv", stringsAsFactors = TRUE)
val   <- read.csv("data/processed/val_scaled.csv",   stringsAsFactors = TRUE)

train$HeartDisease <- factor(train$HeartDisease)
val$HeartDisease   <- factor(val$HeartDisease)

train$HeartDisease <- relevel(train$HeartDisease, ref = "Yes")
val$HeartDisease   <- relevel(val$HeartDisease,   ref = "Yes")

# -----------------------------
# Create artifacts folder
# -----------------------------
if (!dir.exists("artifacts")) {
  dir.create("artifacts", recursive = TRUE)
}

# -----------------------------
# Load tuned models from checkpoints
# -----------------------------
rf_tuned  <- readRDS("checkpoints/rf_tuned.rds")
svm_tuned <- readRDS("checkpoints/svm_tuned.rds")

# -----------------------------
# Helper: Compute metrics
# -----------------------------
compute_metrics <- function(model, data, label = "train") {
  prob <- predict(model, data, type = "prob")[, "Yes"]
  pred <- predict(model, data)
  
  cm <- confusionMatrix(pred, data$HeartDisease, positive = "Yes")
  
  roc_obj <- roc(
    response = data$HeartDisease,
    predictor = prob,
    levels = c("No", "Yes")
  )
  
  data.frame(
    Dataset     = label,
    Accuracy    = cm$overall["Accuracy"],
    Sensitivity = cm$byClass["Sensitivity"],
    Specificity = cm$byClass["Specificity"],
    Precision   = cm$byClass["Precision"],
    F1          = cm$byClass["F1"],
    AUC         = auc(roc_obj)
  )
}

# -----------------------------
#  RF Train vs Validation
# -----------------------------
rf_train_metrics <- compute_metrics(rf_tuned, train, "Train_RF")
rf_val_metrics   <- compute_metrics(rf_tuned, val,   "Val_RF")

# -----------------------------
#  SVM Train vs Validation
# -----------------------------
svm_train_metrics <- compute_metrics(svm_tuned, train, "Train_SVM")
svm_val_metrics   <- compute_metrics(svm_tuned, val,   "Val_SVM")

# -----------------------------
# Combine diagnostic results
# -----------------------------
diag_metrics <- rbind(
  rf_train_metrics,
  rf_val_metrics,
  svm_train_metrics,
  svm_val_metrics
)

print(diag_metrics)

# Save metrics to artifacts folder
write.csv(diag_metrics,
          "artifacts/diagnostics_train_val_metrics.csv",
          row.names = FALSE)

# -----------------------------
# Plot: Train vs Validation Accuracy
# -----------------------------
plot_data <- diag_metrics %>%
  dplyr::mutate(
    Model = ifelse(grepl("RF", Dataset), "Random Forest", "SVM"),
    Split = ifelse(grepl("Train", Dataset), "Train", "Validation")
  )

p <- ggplot(plot_data, aes(x = Model, y = Accuracy, fill = Split)) +
  geom_bar(stat = "identity", position = "dodge") +
  ylim(0, 1) +
  theme_minimal() +
  labs(title = "Train vs Validation Accuracy for RF and SVM")

print(p)

ggsave("artifacts/diagnostics_accuracy_train_vs_val.png",
       plot = p, width = 6, height = 4)

cat("Diagnostics (train vs validation metrics + plot) saved in artifacts/ ✔\n")
