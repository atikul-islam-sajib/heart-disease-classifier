# Heart Disease Prediction (Random Forest + SVM in R)**

## Project Overview

This project predicts **Heart Disease (Yes/No)** using two machine-learning methods:

* **Random Forest (ML1)**
* **Support Vector Machine (ML2)**

The dataset used is the **Heart Failure Prediction Dataset** from Kaggle (original author: *fedesoriano*).
This is a **binary classification** problem with 11 predictors and 1 outcome variable.

The work follows all requirements described in the course instructions.

---

## **Course Requirements Satisfied**

* Environment: **R**
* Dataset properly split into:

  * **60% Training**
  * **20% Validation**
  * **20% Test**
* Hyperparameter tuning done using **5-fold cross-validation** on the **training set**
* Final models trained on **train + validation**
* **Test set used only once** at the very end for final comparison
* **Two ML methods** selected:

  * Random Forest (ML1)
  * SVM (ML2)
* Additional diagnostics:

  * Overfitting check (train vs validation)
  * Threshold tuning using **Youden’s J statistic**
* Final results saved in JSON/CSV for clear reporting
* Model interpretability performed (feature importance, PDP plots)

---

## **Full Pipeline**

### **1. `R/load_data.R`**

Loads the raw CSV file and creates the **train/validation/test split** (60/20/20).
Saves the partitions into `data/processed/`.

---

### **2. `R/preprocessing.R`**

* Converts categorical variables to factors
* Converts target to factor with labels ("No", "Yes")
* Checks missing values and class balance
* Applies **standard scaling** to numeric features
* Saves `train_scaled.csv`, `val_scaled.csv`, `test_scaled.csv`

---

### **3. `R/descriptive_analysis.R`**

Performs full EDA including:

* Numeric distributions
* Categorical frequency plots
* Boxplots vs HeartDisease
* Proportion plots
* Correlation matrix
* Saves all plots into `figures/`

---

### **4. `R/model_random_forest.R`**

* Tunes RF hyperparameters on **training-only** using 5-fold CV
* Hyperparameters tuned:

  * `mtry`
  * `splitrule`
  * `min.node.size`
* Saves:

  * Tuning results → `checkpoints/rf_results.csv`
  * Tuned model → `checkpoints/rf_tuned.rds`
  * Final RF model → `checkpoints/model_random_forest.rds`

---

### **5. `R/model_svm.R`**

* Tunes SVM (radial kernel) hyperparameters:

  * `C`
  * `sigma`
* Uses 5-fold CV on **training-only**
* Saves:

  * Tuning results → `checkpoints/svm_results.csv`
  * Tuned model → `checkpoints/svm_tuned.rds`
  * Final SVM model → `checkpoints/model_svm.rds`

---

### **6. `R/diagnostics.R`**

* Computes metrics on **train vs validation** for RF and SVM:

  * Accuracy
  * Sensitivity
  * Specificity
  * Precision
  * F1
  * AUC
* Generates a **Train vs Validation** accuracy comparison plot
* Helps detect **overfitting**
* Saves results in `artifacts/`

---

### **7. `R/evaluate_models.R`**

This script performs the **final evaluation following professor’s rules**:

* Loads final RF and SVM (trained on train+val)
* Tunes threshold using **Youden’s J**, using **training CV predictions only**
* Applies tuned thresholds to **test set**
* Computes and saves final metrics:

  * `test_metrics.json`
  * `test_metrics.csv`
* Saves:

  * RF/SVM confusion matrices
  * RF vs SVM ROC curve plot
* Stores everything in `artifacts/final_results/`

---

### **8. `R/interpretability.R` : Yet to be completed**

* Feature importance
* Partial Dependence Plots (PDP)
* ICE plots
* Uses the **iml** package
* Helps explain model behavior

---

### **9. Notebooks -> Yet to be completed**

* `notebooks/eda.Rmd` – Report-style exploratory analysis
* `notebooks/modeling.Rmd` – Final modeling report with plots and interpretation

---

## 📂 **Project Structure**

```
project/
│
├── data/
│   ├── raw/heart.csv
│   └── processed/
│
├── R/
│   ├── load_data.R
│   ├── preprocessing.R
│   ├── descriptive_analysis.R
│   ├── model_random_forest.R
│   ├── model_svm.R
│   ├── diagnostics.R
│   ├── evaluate_models.R
│   └── interpretability.R
│
├── checkpoints/
├── artifacts/
│   └── final_results/
├── figures/
└── README.md
```
