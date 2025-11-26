library(ggplot2)
library(GGally)
library(dplyr)
library(corrplot)
source("R/utils.R")

set_global_seed()

# Create folder for saving figures
dir.create("figured")

train <- read.csv("data/processed/train_scaled.csv", stringsAsFactors = TRUE)

##############################################################################################
#                               Dataset Summary - Train Set
#                             ---------------------------------
#                            550 observations and 12 variables
#            6 numeric predictors(Age, RestingBP, Cholesterol, FastingBS, MaxHR, Oldpeak)
#         5 categorical predictors (Sex, ChestPainType, RestingECG, ExerciseAngina, ST_Slope)
#                 target variable HeartDisease has two classes: No and Yes
#
#                                    After preprocessing:
#                                   -----------------------
#                   All numeric variables have been standard scaled
#     scaled value = (original value − mean of the feature) / standard deviation of the feature
#                   the numeric summary shows means ≈ 0 and standard deviations ≈ 1.
#                         No missing values were found in any column.
#
#                                      Class balance:
#                                    -------------------
#                                        No  = 248
#                                        Yes = 302
#                                  The dataset is balanced class.
##############################################################################################

print_basic_info <- function(df, target_col) {
  cat("\ndata overview\n")
  print(dim(df))
  str(df)
  
  cat("\nsummary:\n")
  print(summary(df))
  
  cat("\nmissing values:\n")
  print(check_missing(df))
  
  cat("\ntarget class balanced or not:\n")
  print(class_balance(df))
}

print_basic_info(train, "HeartDisease")

# Numeric and categorical columns
numeric_cols <- c("Age", "RestingBP", "Cholesterol",
                  "FastingBS", "MaxHR", "Oldpeak")

cat_cols <- c("Sex", "ChestPainType", "RestingECG",
              "ExerciseAngina", "ST_Slope")


##############################################################################################
#                                   Pie Chart of Class Balance
#                             ---------------------------------------
##############################################################################################

pie_data <- train %>%
  count(HeartDisease) %>%
  mutate(prop = n / sum(n),
         lbl = paste0(HeartDisease, " (", scales::percent(prop), ")"))

p <- ggplot(pie_data, aes(x = "", y = prop, fill = HeartDisease)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  theme_void() +
  labs(title = "HeartDisease Class Distribution (Pie Chart)") +
  geom_text(aes(label = lbl), position = position_stack(vjust = 0.5))

print(p)
ggsave("figured/heartdisease_pie_chart.png", plot = p, width = 6, height = 6)

##############################################################################################
#                                 Summary of Numeric Features
#                             ---------------------------------
#                       Age and MaxHR look fairly normal shape with no big outliers
#                 Cholesterol, Oldpeak, and RestingBP are skewed and may contain outliers.
#         FastingBS acts more like a binary variable rather than a continuous numeric feature.
##############################################################################################

for (col in numeric_cols) {
  p <- ggplot(train, aes_string(x = col)) +
    geom_histogram(bins = 30, fill = "skyblue", color = "black") +
    theme_minimal() +
    labs(title = paste("Distribution of", col))
  
  print(p)
  ggsave(filename = paste0("figured/", col, "_hist.png"),
         plot = p, width = 6, height = 4)
}

##############################################################################################
#                            Summary of Categorical Features
#                         -------------------------------------
#                  ASY = Asymptomatic (chest pain type where the person has no symptoms)
#                                    -> ATA = Atypical Angina
#                                    -> NAP = Non-Anginal Pain
#                                    -> TA = Typical Angina
#                                    -> LVH = Left Ventricular Hypertrophy
#     ChestPainType: Most people have the ASY type. ATA and NAP show up sometimes. 
#                                  TA is very rare.
#     ExerciseAngina: Most people do not have exercise angina. N is much bigger than Y.
#     RestingECG: The Normal ECG type is the biggest group. LVH and ST are smaller.
#     Sex: There are many more males than females in the dataset.
#     ST_Slope: Flat is the most common slope. Up comes next. Down is the least common.
##############################################################################################

for (col in cat_cols) {
  p <- ggplot(train, aes_string(x = col)) +
    geom_bar(fill = "orange", color = "black") +
    theme_minimal() +
    labs(title = paste("Distribution of", col))
  
  print(p)
  ggsave(filename = paste0("figured/", col, "_bar.png"),
         plot = p, width = 6, height = 4)
}


##############################################################################################
#                     Simple Summary of Numeric Features vs Heart Disease
#                   -------------------------------------------------------
#                       Age:People with heart disease are usually older.
#                       RestingBP:Both groups look almost the same.
#                       Cholesterol:No big difference, but a few outliers exist.
#                       FastingBS: Higher values appear more in the heart-disease group.
#                       MaxHR: People without heart disease have higher MaxHR.
#                       Oldpeak: People with heart disease have much higher Oldpeak values.
##############################################################################################

for (col in numeric_cols) {
  p <- ggplot(train, aes_string(x = "HeartDisease", y = col, fill = "HeartDisease")) +
    geom_boxplot() +
    theme_minimal() +
    labs(title = paste(col, "by HeartDisease"))
  
  print(p)
  ggsave(filename = paste0("figured/", col, "_boxplot.png"),
         plot = p, width = 6, height = 4)
}

##############################################################################################
#                        Summary of Categorical Features vs Heart Disease
#                     ------------------------------------------------------
#                                      ChestPainType:
#                                  ----------------------
#                                     ASY -> mostly Yes
#                                     ATA -> mostly No
#                                     NAP -> mixed
#                                     TA -> mixed
#
#                                     ExerciseAngina:
#                                  ---------------------
#                                     Y -> mostly Yes
#                                     N -> mostly No
#
#                                      RestingECG:
#                                 ----------------------
#                                    All types are mixed
#
#                                        Sex:
#                                     ----------
#                                     Men -> more Yes
#                                     Women -> more No
#
#                                     ST_Slope:
#                                   --------------
#                                  Down & Flat -> more Yes
#                                  Up -> more No
#
##############################################################################################

for (col in cat_cols) {
  p <- ggplot(train, aes_string(x = col, fill = "HeartDisease")) +
    geom_bar(position = "fill") +
    theme_minimal() +
    labs(title = paste(col, "vs HeartDisease (proportion)"),
         y = "Proportion")
  
  print(p)
  ggsave(filename = paste0("figured/", col, "_prop.png"),
         plot = p, width = 6, height = 4)
}

##############################################################################################
#                                  Summary of Correlation Matrix
#                              --------------------------------------
#                   Most features have weak correlations with each other.
#              Age & MaxHR have a negative link : older people -> lower MaxHR)
#                      Age & RestingBP have a small positive link.
#                Cholesterol & FastingBS show a small negative link.
#                  Oldpeak has small positive links with Age and RestingBP.
#          Overall: No strong correlations, so multicollinearity is not a problem.
##############################################################################################

numeric_data <- train[, numeric_cols]
cor_mat <- cor(numeric_data)

# Save correlation heatmap
png("figured/correlation_matrix.png", width = 800, height = 600)
corrplot(cor_mat,
         method = "color",
         type = "upper",
         addCoef.col = "black",
         number.cex = 0.7,
         tl.cex = 0.8,
         tl.col = "black")
dev.off()


##############################################################################################
#                    Scatter Plots: Age vs Key Numeric Features
#                 -------------------------------------------------
#     Shows how Age relates to RestingBP, Cholesterol, MaxHR, Oldpeak
#              for the two groups (HeartDisease: Yes/No).
##############################################################################################


key_pairs <- c("RestingBP", "Cholesterol", "MaxHR", "Oldpeak")

for (col in key_pairs) {
  p <- ggplot(train, aes_string(x = "Age", y = col, color = "HeartDisease")) +
    geom_point(alpha = 0.6, size = 2) +
    theme_minimal() +
    labs(title = paste("Scatter Plot: Age vs", col),
         x = "Age", y = col)
  
  print(p)
  ggsave(filename = paste0("figured/age_vs_", col, "_scatter.png"),
         plot = p, width = 6, height = 4)
}


##############################################################################################
#                   Scatter Plot with LOESS Smooth Line: Age vs MaxHR
#                 -------------------------------------------------------
#   Adds a smooth trend line to see how MaxHR changes with Age for both
#                             HeartDisease groups.
##############################################################################################


p <- ggplot(train, aes(Age, MaxHR, color = HeartDisease)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess", se = TRUE) +
  theme_minimal() +
  labs(title = "Age vs MaxHR with LOESS Trend")

print(p)
ggsave("figured/age_vs_maxhr_smooth.png", plot = p, width = 6, height = 4)


##############################################################################################
#                      Faceted Scatter Plot: MaxHR vs Oldpeak by Sex
#                 --------------------------------------------------------
#      Shows MaxHR–Oldpeak relationship separately for males and females
#                 with HeartDisease groups highlighted by color.
##############################################################################################


p <- ggplot(train, aes(MaxHR, Oldpeak, color = HeartDisease)) +
  geom_point(alpha = 0.6) +
  facet_wrap(~ Sex) +
  theme_minimal() +
  labs(title = "MaxHR vs Oldpeak (Faceted by Sex)")

print(p)
ggsave("figured/maxhr_oldpeak_facet_sex.png", plot = p, width = 7, height = 5)


##############################################################################################
#                      Pairplot of All Numeric Features (GGally)
#                 ------------------------------------------------------
#   Shows scatterplots, distributions, and correlations between all
#      numeric features, colored by HeartDisease groups.
##############################################################################################


p <- ggpairs(
  train[, c(numeric_cols, "HeartDisease")],
  aes(color = HeartDisease, alpha = 0.5)
)

print(p)
ggsave("figured/numeric_pairplot.png", plot = p, width = 12, height = 12)