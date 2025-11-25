library(readr)
library(dplyr)
source("R/utils.R")

set_global_seed()

# load the data, which is stored in the data
df <- read_csv("data/raw/heart.csv")

cat("Raw data dimensions (rows, cols):\n")
print(dim(df))
cat("Column names:\n")
print(names(df))

n <- nrow(df)
idx <- sample(n)

train_idx <- idx[1:floor(0.6 * n)]
val_idx   <- idx[(floor(0.6 * n) + 1):floor(0.8 * n)]
test_idx  <- idx[(floor(0.8 * n) + 1):n]

train <- df[train_idx, ]
val   <- df[val_idx, ]
test  <- df[test_idx, ]

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
write_csv(train, "data/processed/train.csv")
write_csv(val,   "data/processed/val.csv")
write_csv(test,  "data/processed/test.csv")

cat("Data split into train, val, and test with 60, 20, 20\n")
