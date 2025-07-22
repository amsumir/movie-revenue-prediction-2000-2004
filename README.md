#  Movie Revenue Prediction (2000–2024)

A business analytics project that explores and models movie revenue trends from 2000 to 2024 using IMDb metadata and global box office data. Built using **R**, the project demonstrates exploratory data analysis, regression, classification, and ensemble modeling.

##  Objective

Predict whether a movie will become a box office hit **before release**, based on metadata such as genre, cast, director, and IMDb rating.

##  Research Questions

1. Which genres tend to be the most profitable?
2. Do directors, cast, or IMDb ratings impact revenue?
3. Can we build a model to predict revenue before release?
4. Do higher IMDb ratings correlate with higher revenue?

##  Project Structure

- **01_Data_Preparation**: Merging and cleaning IMDb and revenue data
- **02_Exploratory_Analysis**: Visual and statistical insights into genre, rating, director impact
- **03_Modeling**:
  - Logistic Regression (Hit or Not)
  - Decision Trees
  - Random Forests
- **04_Report**: Includes full academic-style PDF and summary results

##  Tools & Tech

- R programming (dplyr, ggplot2, caret, randomForest)
- IMDb .tsv datasets + Kaggle box office data
- Classification & Regression Modeling
- Evaluation metrics (Accuracy, ROC AUC, RMSE, R²)

##  Key Findings

- **Top genres**: Action, Adventure, Fantasy
- **Ratings & directors** are highly predictive
- Even without ratings, **pre-release models** work reasonably well
- Best models:  
  -  Logistic Regression for hit prediction: **Accuracy ~71%**, AUC **0.73**  
  -  Random Forest (full): **R² = 0.44**, RMSE ≈ **$176M**

##  Data Sources

- IMDb datasets: https://datasets.imdbws.com/
- Kaggle: https://www.kaggle.com/datasets/parthdande/movies-box-office-collection-data-2000-2024

##  Authors

Team project for CMIS 566 – Business Analytics  
 Sumir Acharya, Hannah Smith, Cristopher Isada, Craig Schafer  
 Guided by: Dr. Prajakta Kolte

##  License

For academic and learning use only. Cite sources where applicable.

Ideal for: data science portfolios, business analytics case studies, or movie data enthusiasts.
