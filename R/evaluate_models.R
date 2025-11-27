library(caret)
library(pROC)
library(ggplot2)
library(jsonlite)
source("R/utils.R")

set_global_seed()

# Create folders -> To save all the important metrics
if (!dir.exists("artifacts")) {
  dir.create("artifacts")
}

if (!dir.exists("artifacts/final_results")) {
  dir.create("artifacts/final_results", recursive = TRUE)
}


# Load train + test data

train <- read.csv("data/processed/train_scaled.csv", stringsAsFactors = TRUE)
test  <- read.csv("data/processed/test_scaled.csv",  stringsAsFactors = TRUE)

train$HeartDisease <- factor(train$HeartDisease)
test$HeartDisease  <- factor(test$HeartDisease)

train$HeartDisease <- relevel(train$HeartDisease, ref = "Yes")
test$HeartDisease  <- relevel(test$HeartDisease,  ref = "Yes")

# Load final models + tuned CV models
rf_model  <- readRDS("checkpoints/model_random_forest.rds")
svm_model <- readRDS("checkpoints/model_svm.rds")

rf_tuned  <- readRDS("checkpoints/rf_tuned.rds")
svm_tuned <- readRDS("checkpoints/svm_tuned.rds")

##############################################################################################
#                       Threshold Tuning Using Youden’s J
#                     -------------------------------------
#               When a model gives a probability, like 0.20, 0.60, 0.85
#         we must pick a threshold to decide when to say Yes, the person has heart disease.
#                Most people use 0.5, but this is not always the best choice.
#                Since this is a medical problem, we want a threshold that:
#               1. It catches people who really HAVE heart disease -> high Sensitivity
#               2. It still avoids too many false alarms -> good Specificity
#                     To find the best balance, we use Youden’s J:
#                 ----------------------------------------------------
#                           J = Sensitivity + Specificity − 1
##############################################################################################

tune_threshold_youden <- function(model) {
  
  preds <- model$pred
  folds <- unique(preds$Resample)
  best_thresholds <- c()
  
  for (f in folds) {
    fold_data <- preds[preds$Resample == f, ]
    
    best_value <- -Inf
    best_t <- 0.5
    
    for (t in seq(0.001, 0.999, by = 0.001)) {
      
      predicted_class <- ifelse(fold_data$Yes >= t, "Yes", "No")
      
      cm <- confusionMatrix(
        factor(predicted_class, levels = c("No", "Yes")),
        factor(fold_data$obs,      levels = c("No", "Yes")),
        positive = "Yes"
      )
      
      sens <- cm$byClass["Sensitivity"]
      spec <- cm$byClass["Specificity"]
      
      J <- sens + spec - 1
      
      if (!is.na(J) && J > best_value) {
        best_value <- J
        best_t <- t
      }
    }
    
    best_thresholds <- c(best_thresholds, best_t)
  }
  
  return(mean(best_thresholds))
}


# Compute best thresholds using Youden J

best_t_rf  <- tune_threshold_youden(rf_tuned)
best_t_svm <- tune_threshold_youden(svm_tuned)

write_json(list(threshold = best_t_rf),
           "artifacts/final_results/threshold_rf.json",
           pretty = TRUE)

write_json(list(threshold = best_t_svm),
           "artifacts/final_results/threshold_svm.json",
           pretty = TRUE)


# Function for calculating the metrics

compute_metrics <- function(prob, pred_class, data) {
  
  cm <- confusionMatrix(
    factor(pred_class, levels = c("No", "Yes")),
    data$HeartDisease,
    positive = "Yes"
  )
  
  roc_obj <- roc(data$HeartDisease, prob, levels = c("No", "Yes"))
  
  data.frame(
    Accuracy    = cm$overall["Accuracy"],
    Sensitivity = cm$byClass["Sensitivity"],
    Specificity = cm$byClass["Specificity"],
    Precision   = cm$byClass["Precision"],
    F1          = cm$byClass["F1"],
    AUC         = auc(roc_obj)
  )
}


# APPLY THRESHOLDS -> TRAIN SET

rf_prob_train  <- predict(rf_model, train, type = "prob")[, "Yes"]
rf_pred_train  <- ifelse(rf_prob_train >= best_t_rf, "Yes", "No")

svm_prob_train <- predict(svm_model, train, type = "prob")[, "Yes"]
svm_pred_train <- ifelse(svm_prob_train >= best_t_svm, "Yes", "No")

metrics_train <- rbind(
  cbind(Model = "Random Forest", compute_metrics(rf_prob_train,  rf_pred_train,  train)),
  cbind(Model = "SVM",           compute_metrics(svm_prob_train, svm_pred_train, train))
)

write_json(metrics_train,
           "artifacts/final_results/train_metrics.json",
           pretty = TRUE)

write.csv(metrics_train,
          "artifacts/final_results/train_metrics.csv",
          row.names = FALSE)

# Save TRAIN confusion matrices
plot_confusion <- function(cm, title) {
  df <- as.data.frame(cm$table)
  ggplot(df, aes(Prediction, Reference, fill = Freq)) +
    geom_tile() +
    geom_text(aes(label = Freq), color = "white", size = 5) +
    scale_fill_gradient(low = "blue", high = "red") +
    theme_minimal() +
    labs(title = title)
}

cm_rf_train  <- confusionMatrix(factor(rf_pred_train, levels=c("No","Yes")), train$HeartDisease, positive="Yes")
cm_svm_train <- confusionMatrix(factor(svm_pred_train, levels=c("No","Yes")), train$HeartDisease, positive="Yes")

ggsave("artifacts/final_results/confusion_rf_train.png",
       plot_confusion(cm_rf_train, "RF Confusion Matrix (Train)"),
       width = 5, height = 4)

ggsave("artifacts/final_results/confusion_svm_train.png",
       plot_confusion(cm_svm_train, "SVM Confusion Matrix (Train)"),
       width = 5, height = 4)


# APPLY THRESHOLDS -> TEST SET 

rf_prob_test <- predict(rf_model, test, type = "prob")[, "Yes"]
rf_pred_test <- ifelse(rf_prob_test >= best_t_rf, "Yes", "No")

svm_prob_test <- predict(svm_model, test, type = "prob")[, "Yes"]
svm_pred_test <- ifelse(svm_prob_test >= best_t_svm, "Yes", "No")

metrics_test <- rbind(
  cbind(Model = "Random Forest", compute_metrics(rf_prob_test,  rf_pred_test,  test)),
  cbind(Model = "SVM",           compute_metrics(svm_prob_test, svm_pred_test, test))
)

write_json(metrics_test,
           "artifacts/final_results/test_metrics.json",
           pretty = TRUE)

write.csv(metrics_test,
          "artifacts/final_results/test_metrics.csv",
          row.names = FALSE)

# Save TEST confusion matrices
cm_rf_test  <- confusionMatrix(factor(rf_pred_test, levels=c("No","Yes")), test$HeartDisease, positive="Yes")
cm_svm_test <- confusionMatrix(factor(svm_pred_test, levels=c("No","Yes")), test$HeartDisease, positive="Yes")

ggsave("artifacts/final_results/confusion_rf_test.png",
       plot_confusion(cm_rf_test, "RF Confusion Matrix (Test)"),
       width = 5, height = 4)

ggsave("artifacts/final_results/confusion_svm_test.png",
       plot_confusion(cm_svm_test, "SVM Confusion Matrix (Test)"),
       width = 5, height = 4)


# SAVE ROC CURVE -> Test

roc_rf <- roc(test$HeartDisease, rf_prob_test, levels = c("No","Yes"))
roc_svm <- roc(test$HeartDisease, svm_prob_test, levels = c("No","Yes"))

png("artifacts/final_results/roc_curve_rf_svm.png",
    width = 700, height = 600)
plot(roc_rf, col = "blue", main = "ROC Curve: RF vs SVM")
plot(roc_svm, col = "red", add = TRUE)
legend("bottomright",
       legend = c("Random Forest", "SVM"),
       col = c("blue", "red"), lwd = 2)
dev.off()

cat("Train + Test evaluation with threshold tuning completed\n")

################################################################################################
#                           METRIC COMPARISON PLOT 
################################################################################################

library(reshape2)

metric_long <- melt(metrics_test,
                    id.vars = "Model",
                    measure.vars = c("Accuracy", "Sensitivity",
                                     "Specificity", "Precision",
                                     "F1", "AUC"),
                    variable.name = "Metric",
                    value.name = "Value")

p <- ggplot(metric_long, aes(x = Metric, y = Value, fill = Model)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  theme_minimal(base_size = 13) +
  labs(
    title = "Performance Metrics Comparison: Random Forest vs SVM",
    x = "Metric",
    y = "Score"
  ) +
  scale_fill_manual(values = c("Random Forest" = "steelblue",
                               "SVM" = "firebrick")) +
  ylim(0, 1)

ggsave("artifacts/final_results/metric_comparison.png",
       p, width = 8, height = 5)

cat("Metric comparison plot saved.\n")
