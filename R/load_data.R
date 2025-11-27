library(readr)
library(dplyr)
library(caret)
source("R/utils.R")

set_global_seed()

##############################################################################################
#                       Load Raw Data
#                     -----------------
#   We want to split the dataset into Train/Validation/Test sets.
#   BUT: Instead of splitting completely randomly, we want a STRATIFIED split.
#   Why? Because we want to make sure the target variable (HeartDisease)
#   has the SAME proportion of classes (Yes / No) in each split.
#
#   This prevents accidental class imbalance between Train, Val, and Test.
##############################################################################################

df <- read_csv("data/raw/heart.csv")

cat("Raw data dimensions (rows, cols):\n")
print(dim(df))
cat("Column names:\n")
print(names(df))

# Convert target to factor for stratification
df$HeartDisease <- factor(df$HeartDisease)

##############################################################################################
#                       Stratified Split (60 / 20 / 20)
#                     ----------------------------------
#           We use caret::createDataPartition() to ensure each split
#             has the SAME class distribution as the original dataset.
##############################################################################################

# 60% TRAIN
train_idx <- createDataPartition(df$HeartDisease, p = 0.60, list = FALSE)
train <- df[train_idx, ]

# Remaining 40%
remaining <- df[-train_idx, ]

# 20% VALIDATION (from remaining 40%)
# 20 / 40 = 0.50 --> half of remaining goes to validation
val_idx <- createDataPartition(remaining$HeartDisease, p = 0.50, list = FALSE)
val <- remaining[val_idx, ]

# 20% TEST (rest of remaining)
test <- remaining[-val_idx, ]

##############################################################################################
#                       Save the Stratified Splits
#                     ---------------------------------
##############################################################################################

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
write_csv(train, "data/processed/train.csv")
write_csv(val,   "data/processed/val.csv")
write_csv(test,  "data/processed/test.csv")

cat("Stratified Train/Val/Test split completed (60%, 20%, 20%).\n")

##############################################################################################
#                       Check Class Balance (Optional)
#                     ---------------------------------
#       This ensures the stratification worked and all splits
#       have similar class proportions.
##############################################################################################

cat("\nClass Proportions:\n")
cat("Original:\n")
print(prop.table(table(df$HeartDisease)))

cat("Train:\n")
print(prop.table(table(train$HeartDisease)))

cat("Validation:\n")
print(prop.table(table(val$HeartDisease)))

cat("Test:\n")
print(prop.table(table(test$HeartDisease)))
