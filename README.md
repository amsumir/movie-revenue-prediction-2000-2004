#  Movie Revenue Prediction (2000–2024) – All-in-One R Script

This project explores and predicts box office revenue using movie metadata and financial data spanning 2000–2024. Built entirely in **R**, the project is self-contained in a single script that covers:

- Data loading & cleaning  
- Feature engineering  
- Exploratory data analysis (EDA)  
- Multiple predictive models  
- Evaluation metrics and visualizations  

It provides a hands-on look into how data science techniques can be applied to real-world entertainment data.

---

##  Project Goals

1. Which genres are most profitable at the box office?  
2. How do directors, cast, or IMDb ratings influence revenue?  
3. Can we estimate a movie’s revenue before it’s released?  
4. Does a higher IMDb rating correlate with greater financial success?

---

##  Packages Used

The script automatically installs required libraries:

- `readxl`, `ggplot2`, `rpart`, `rpart.plot`  
- `randomForest`, `pROC`, `caret`

---

##  Key Components

###  Data Cleaning & Feature Engineering
- Handling missing values and data types
- Removing extreme outliers (1st & 99th percentile)
- Creating features: `mainGenre`, `starPower`, `recent`, `blockbusterDirector`

###  Exploratory Data Analysis
- Revenue histograms (log10 & billions)
- Genre-wise median revenue bar chart
- IMDb rating vs revenue scatter plot

###  Modeling
- **Linear Regression** (Full & Reduced)
- **Decision Tree** (Full & Reduced)
- **Random Forest** (Full & Reduced)
- **Logistic Regression** for Hit Classification (> $100M)

###  Evaluation Metrics
- RMSE & R² for regression
- Accuracy & AUC for classification
- Confusion matrices, ROC curves
- Variable importance plots for Random Forest

---

##  Sample Results

| Model                        | Metric     | Result         |
|-----------------------------|------------|----------------|
| Linear Regression (Full)    | RMSE       | ~$130M         |
| Random Forest (Full)        | R²         | 0.439          |
| Logistic Regression (Full)  | Accuracy   | 71.1%          |
|                             | AUC        | 0.73           |

Even reduced models (without ratings) gave reasonable accuracy—useful for pre-release forecasting.

---

##  Data Sources

- 📁 [Kaggle – Box Office Data (2000–2024)](https://www.kaggle.com/datasets/parthdande/movies-box-office-collection-data-2000-2024)  
- 🎬 [IMDb Datasets](https://datasets.imdbws.com/)

---

##  Authors

**Sumir Sharma Acharya**  
**Hannah Smith, Cristopher Isada, Craig Schafer**  
Course: *CMIS 566 – Introduction to Business Analytics*  
Instructor: Dr. Prajakta Kolte

---

##  Notes

- Script output charts are saved in the `outputs/` folder.  
- Modify or extend the script to include budget, release month, or franchise data for deeper analysis.  
- Ideal for data science portfolios, analytics case studies, and movie industry research.

---

 **"Data doesn’t make a great movie — but it helps you bet on one."**



