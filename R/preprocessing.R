library(dplyr)
library(caret)
source("R/utils.R")

set_global_seed()

train <- read.csv("data/processed/train.csv", stringsAsFactors = FALSE)
val   <- read.csv("data/processed/val.csv",   stringsAsFactors = FALSE)
test  <- read.csv("data/processed/test.csv",  stringsAsFactors = FALSE)

######################################################################
#                Columns in this dataset is given below
#    Age, Sex, ChestPainType, RestingBP, Cholesterol, FastingBS,
#   RestingECG, MaxHR, ExerciseAngina, Oldpeak, ST_Slope, HeartDisease
######################################################################

# Convert categorical to factor
cat_cols <- c("Sex", "ChestPainType", "RestingECG",
              "ExerciseAngina", "ST_Slope")

for (col in cat_cols) {
  train[[col]] <- factor(train[[col]])
  val[[col]]   <- factor(val[[col]])
  test[[col]]  <- factor(test[[col]])
}

###############################################################
#     Convert HeartDisease to factor with labels No + Yes.    
#     It is a target column and binary class classification   
###############################################################

target <- function(x) {
  factor(x, levels = c(0, 1), labels = c("No", "Yes"))
}

train$HeartDisease <- target(train$HeartDisease)
val$HeartDisease   <- target(val$HeartDisease)
test$HeartDisease  <- target(test$HeartDisease)

###############################################################
#                        Simple EDA
#           Missing value check + Imbalanced or not
###############################################################

cat("Missing values in train:\n")
print(check_missing(train))

cat("Class balance (train):\n")
print(class_balance(train))

##############################################################################################
#                                   Scale numeric predictors
#                           It is used the standard scaling approach
# scaled value = (original value − mean of the feature) / standard deviation of the feature
#############################################################################################

num_cols <- c("Age", "RestingBP", "Cholesterol",
              "FastingBS", "MaxHR", "Oldpeak")

# Fit preprocessing object on TRAIN ONLY
preproc <- preProcess(train[, num_cols], method = c("center", "scale"))

# Apply scaling to train, val, and test
train[, num_cols] <- predict(preproc, train[, num_cols])
val[,   num_cols] <- predict(preproc, val[,   num_cols])
test[,  num_cols] <- predict(preproc, test[,  num_cols])

##################################################################################################
#                           Save processed data (scaled)
##################################################################################################

write.csv(train, "data/processed/train_scaled.csv", row.names = FALSE)
write.csv(val,   "data/processed/val_scaled.csv",   row.names = FALSE)
write.csv(test,  "data/processed/test_scaled.csv",  row.names = FALSE)

##################################################################################################
#                           Save SCALER used for numeric standardization
#       This scaler (preproc) will be used in the Shiny app so predictions match model training
##################################################################################################

if (!dir.exists("checkpoints")) {
  dir.create("checkpoints", recursive = TRUE)
}

saveRDS(preproc, "checkpoints/scaler.rds")
cat("Scaler saved as checkpoints/scaler.rds\n")

cat("Preprocessing is completed\n")
