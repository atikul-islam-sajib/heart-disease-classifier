
# **Heart Disease Prediction using Random Forest and SVM (R Project)**

This repository contains a complete, end-to-end **machine-learning pipeline in R** for predicting **Heart Disease (Yes/No)** using two supervised learning models:

* **Random Forest (ML1)**
* **Support Vector Machine – RBF Kernel (ML2)**

The dataset used is the **Heart Failure Prediction Dataset** by *fedesoriano* (Kaggle).
The objective is **binary classification** using 11 predictors.

The project strictly follows all requirements defined in the course instructions, including proper data splitting, cross-validation, threshold tuning, diagnostics, and final model evaluation.

---

## ** Project Workflow**

```
RAW DATA
   │
   ▼
DATA SPLITTING (60/20/20)
   │
   ▼
PREPROCESSING (Encoding + Scaling)
   │
   ▼
EXPLORATORY DATA ANALYSIS (EDA)
   │
   ▼
HYPOTHESIS TESTING (t-tests, χ²)
   │
   ▼
MODEL TRAINING (Train-only cross-validation)
   │
   ▼
FINAL MODELS (Train + Validation)
   │
   ▼
THRESHOLD TUNING (Youden’s J)
   │
   ▼
TEST-SET EVALUATION
   │
   ▼
INTERPRETABILITY (PDP, ICE, Feature Importance)
```

---

## ** Directory Structure**

```
project/
│
├── data/
│   ├── raw/
│   │   └── heart.csv
│   └── processed/
│       ├── train_scaled.csv
│       ├── val_scaled.csv
│       └── test_scaled.csv
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
├── checkpoints/        # Tuned models, intermediate results
├── artifacts/          # Metrics, evaluation results
│   └── final_results/
├── figures/            # EDA and diagnostic plots
└── README.md
```

---

# ** Scripts Overview**

Below is a clear description of all R scripts and their role in the pipeline.

---

## **1 `load_data.R`**

* Loads the raw `heart.csv` dataset.
* Performs an **initial split:**

  * 60% Training
  * 20% Validation
  * 20% Test
* Saves partitioned datasets to `data/processed/`.

---

## **2 `preprocessing.R`**

* Converts categorical variables into factors.
* Converts target to factor: `"No"`, `"Yes"`.
* Performs:

  * Missing-value check
  * Class imbalance check
  * Standard scaling on numerical features
* Saves:

  * `train_scaled.csv`
  * `val_scaled.csv`
  * `test_scaled.csv`

---

## **3 `descriptive_analysis.R`**

Full exploratory data analysis:

* Histograms
* Barplots
* Boxplots
* Proportion (pie) charts
* Correlation matrix
* Scatter plots
* Summary statistics

All generated figures are saved in:
**`figures/`**

---

## **4 `model_random_forest.R`**

Trains the **Random Forest (ranger)** classifier using:

* **5-fold cross-validation on training set only**
* Tuned hyperparameters:

  * `mtry`
  * `splitrule`
  * `min.node.size`

Outputs saved in:

* `checkpoints/rf_results.csv` (CV results)
* `checkpoints/rf_tuned.rds` (best tuned model)
* `checkpoints/model_random_forest.rds` (final RF model)

---

## **5 `model_svm.R`**

Trains the **SVM (Radial Kernel)** classifier with 5-fold CV.

Hyperparameters tuned:

* `C`
* `sigma`

Outputs saved in:

* `checkpoints/svm_results.csv`
* `checkpoints/svm_tuned.rds`
* `checkpoints/model_svm.rds`

---

## **6  `diagnostics.R`**

Performs overfitting/underfitting checks:

* Compares **Train vs Validation** metrics:

  * Accuracy
  * Sensitivity
  * Specificity
  * Precision
  * F1
  * AUC
* Generates plots and stores results in `artifacts/`.

---

## **7  `evaluate_models.R`**

Final model evaluation following strict course requirements.

* Loads models trained on **train + validation**
* Computes **optimal threshold (Youden’s J)** using CV predictions
* Applies tuned thresholds to **test set**
* Generates:

  * Confusion matrices
  * ROC curves
  * Final test metrics (JSON + CSV)

Saved under:

```
artifacts/final_results/
```

---

## **8 `interpretability.R`**

(Work in progress)

Will compute:

* Feature importance
* Partial Dependence Plots (PDP)
* Individual Conditional Expectation (ICE)
* Global surrogate explanations

Uses the **iml** package.

---

# **Notebooks (To Be Completed)**

* **`notebooks/eda.Rmd`** → Full exploratory data analysis report
* **`notebooks/modeling.Rmd`** → Modeling workflow, diagnostics, and final evaluation

---

# **Models Used**

| Model             | Package             | Purpose                      |
| ----------------- | ------------------- | ---------------------------- |
| **Random Forest** | `ranger`            | Baseline tree-based ensemble |
| **SVM (RBF)**     | `kernlab` / `caret` | Non-linear margin classifier |

Both models undergo:

* 5-fold CV
* Hyperparameter tuning
* Threshold tuning
* Final evaluation on untouched test data

---

# **Results Summary (High-Level)**

* Proper 60/20/20 data splitting
* Strict separation of train/validation/test
* Final models trained only after hyperparameter tuning
* Threshold tuned using Youden’s J (not default 0.5)
* Metrics saved in standardized formats (CSV/JSON)
* Full EDA and diagnostics included

---

# **Citation**

Dataset source:
**Heart Failure Prediction Dataset** by *fedesoriano* (Kaggle)

