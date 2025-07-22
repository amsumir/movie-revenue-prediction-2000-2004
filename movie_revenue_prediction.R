# =============================================
# Movie Revenue Prediction Project
# =============================================

# --- Create Output Folder ---
dir.create("outputs", showWarnings = FALSE)

# --- Install & Load Packages ---
install.packages("readxl")
install.packages("ggplot2")
install.packages("rpart")
install.packages("rpart.plot")
install.packages("randomForest")
install.packages("pROC")
install.packages("caret")

library(readxl)
library(ggplot2)
library(rpart)
library(rpart.plot)
library(randomForest)
library(pROC)
library(caret)

# =============================================
# 1. Load and Clean the Dataset
# =============================================

# Load Excel File
movies <- read_excel("data/sample_movies.xlsx")

# Convert columns with commas to numeric
movies$Worldwide <- as.numeric(gsub(",", "", movies$Worldwide))
movies$Domestic <- as.numeric(gsub(",", "", movies$Domestic))
movies$Foreign <- as.numeric(gsub(",", "", movies$Foreign))

# Handle missing data
movies$directedBy[movies$directedBy == ""] <- NA
movies$directedBy[is.na(movies$directedBy)] <- "Unknown"
movies$avgRating[is.na(movies$avgRating)] <- median(movies$avgRating, na.rm = TRUE)

# Remove extreme outliers from revenue
q <- quantile(movies$Worldwide, probs = c(0.01, 0.99), na.rm = TRUE)
movies$Worldwide[movies$Worldwide < q[1] | movies$Worldwide > q[2]] <- NA
movies <- na.omit(movies)

# =============================================
# 2. Feature Engineering
# =============================================

# Get main genre
movies$mainGenre <- sapply(strsplit(movies$genres, ","), function(x) trimws(x[1]))

# Count top actors as star power
movies$starPower <- sapply(strsplit(movies$starring, ","), length)

# Filter rare genres
genre_counts <- table(movies$mainGenre)
valid_genres <- names(genre_counts[genre_counts >= 5])
movies <- movies[movies$mainGenre %in% valid_genres, ]
movies$mainGenre <- factor(movies$mainGenre)

# Add flags for recent and blockbuster directors
median_year <- median(movies$year)
movies$recent <- ifelse(movies$year > median_year, 1, 0)

top_directors <- names(sort(tapply(movies$Worldwide, movies$directedBy, median), decreasing = TRUE)[1:5])
movies$blockbusterDirector <- ifelse(movies$directedBy %in% top_directors, 1, 0)

# =============================================
# 3. Visualizations (Barplot, Histograms, etc.)
# =============================================

# Top 10 genres by revenue
genre_revenue <- aggregate(Worldwide ~ mainGenre, data = movies, FUN = median)
genre_revenue <- genre_revenue[order(-genre_revenue$Worldwide), ]
genre_revenue$millions <- genre_revenue$Worldwide / 1e6

png("outputs/genre_revenue.png", width = 1000, height = 600)
barplot(genre_revenue$millions[1:10],
        names.arg = genre_revenue$mainGenre[1:10],
        las = 2, col = terrain.colors(10),
        main = "Top 10 Genres by Median Revenue",
        ylab = "Revenue (Millions USD)")
dev.off()

# Revenue Distributions
png("outputs/revenue_dist_log10.png", width = 800, height = 600)
hist(log10(movies$Worldwide), breaks = 30, col = "skyblue",
     main = "Revenue Distribution (Log10)", xlab = "Log10 Revenue")
dev.off()

png("outputs/revenue_dist_billion.png", width = 800, height = 600)
hist(movies$Worldwide / 1e9, breaks = 30, col = "lightgreen",
     main = "Revenue Distribution (Billions)", xlab = "Revenue (Billion USD)")
dev.off()

# Rating vs Revenue
png("outputs/rating_vs_revenue.png", width = 800, height = 600)
plot(movies$avgRating, log10(movies$Worldwide), pch = 19,
     col = rgb(0, 0, 1, 0.3),
     main = "Average Rating vs Revenue",
     xlab = "IMDb Rating", ylab = "Log10 Revenue")
abline(lm(log10(Worldwide) ~ avgRating, data = movies), col = "red", lwd = 2)
dev.off()

# =============================================
# 4. Train/Test Split
# =============================================

set.seed(123)
n <- nrow(movies)
split <- sample(1:n, 0.7 * n)
train <- movies[split, ]
test <- movies[-split, ]

train$logRevenue <- log10(train$Worldwide)
test$logRevenue <- log10(test$Worldwide)

# Create binary column for classification
movies$hit <- ifelse(movies$Worldwide > 100000000, 1, 0)
train$hit <- ifelse(train$Worldwide > 100000000, 1, 0)
test$hit <- ifelse(test$Worldwide > 100000000, 1, 0)

# =============================================
# 5. Models
# =============================================

# ---------- LINEAR REGRESSION ----------
lm_full <- lm(logRevenue ~ avgRating + starPower + mainGenre + recent + blockbusterDirector, data = train)
summary(lm_full)
lm_reduced <- lm(logRevenue ~ starPower + mainGenre + blockbusterDirector, data = train)

test$lm_pred_full <- 10^predict(lm_full, test)
test$lm_pred_reduced <- 10^predict(lm_reduced, test)

rmse_lm_full <- sqrt(mean((test$Worldwide - test$lm_pred_full)^2))
rmse_lm_reduced <- sqrt(mean((test$Worldwide - test$lm_pred_reduced)^2))

# ---------- DECISION TREE ----------
tree_full <- rpart(logRevenue ~ avgRating + starPower + mainGenre + recent + blockbusterDirector, data = train)
tree_reduced <- rpart(logRevenue ~ starPower + mainGenre + blockbusterDirector, data = train)

test$tree_pred_full <- 10^predict(tree_full, test)
test$tree_pred_reduced <- 10^predict(tree_reduced, test)

rmse_tree_full <- sqrt(mean((test$Worldwide - test$tree_pred_full)^2))
rmse_tree_reduced <- sqrt(mean((test$Worldwide - test$tree_pred_reduced)^2))

png("outputs/decision_tree_plot_model_1.png")
rpart.plot(tree_full)
dev.off()

png("outputs/decision_tree_reduced_model_2.png")
rpart.plot(tree_reduced)
dev.off()

# ---------- RANDOM FOREST ----------
rf_full <- randomForest(logRevenue ~ avgRating + starPower + mainGenre + recent + blockbusterDirector, data = train, ntree = 500, importance = TRUE)
rf_reduced <- randomForest(logRevenue ~ starPower + mainGenre + blockbusterDirector, data = train, ntree = 500, importance = TRUE)

test$rf_pred_full <- 10^predict(rf_full, test)
test$rf_pred_reduced <- 10^predict(rf_reduced, test)

rmse_rf_full <- sqrt(mean((test$Worldwide - test$rf_pred_full)^2))
rmse_rf_reduced <- sqrt(mean((test$Worldwide - test$rf_pred_reduced)^2))

png("outputs/rf_error_plot_model1.png", width = 800, height = 600)
plot(rf_full, main = "Random Forest Error Plot - Model 1")
dev.off()

png("outputs/rf_varimp_plot_model1.png", width = 800, height = 600)
varImpPlot(rf_full, main = "Variable Importance - Random Forest Model 1")
dev.off()

png("outputs/rf_error_plot_model2.png", width = 800, height = 600)
plot(rf_reduced, main = "Random Forest Error Plot - Model 2")
dev.off()

png("outputs/rf_varimp_plot_model2.png", width = 800, height = 600)
varImpPlot(rf_reduced, main = "Variable Importance - Random Forest Model 2")
dev.off()

# Set up 2 rows and 2 columns for plotting
png("outputs/random_forest_4plots.png", width = 1000, height = 800)
par(mfrow = c(2, 2))

# 1. Error plot for Model 1
plot(rf_full, main = "Error Rate - Model 1")

# 2. Variable importance for Model 1
varImpPlot(rf_full, main = "Variable Importance - Model 1", type = 1)

# 3. Error plot for Model 2
plot(rf_reduced, main = "Error Rate - Model 2")

# 4. Variable importance for Model 2
varImpPlot(rf_reduced, main = "Variable Importance - Model 2", type = 1)

dev.off()
# ---------- LOGISTIC REGRESSION ----------
logit_full <- glm(hit ~ avgRating + starPower + mainGenre + recent + blockbusterDirector,
                  data = train, family = "binomial")
summary(logit_full)
logit_reduced <- glm(hit ~ starPower + mainGenre + blockbusterDirector,
                     data = train, family = "binomial")
summary(logit_reduced)

test$logit_prob_full <- predict(logit_full, test, type = "response")
test$logit_prob_reduced <- predict(logit_reduced, test, type = "response")

test$logit_class_full <- ifelse(test$logit_prob_full > 0.5, 1, 0)
test$logit_class_reduced <- ifelse(test$logit_prob_reduced > 0.5, 1, 0)

acc_logit_full <- mean(test$logit_class_full == test$hit)
acc_logit_reduced <- mean(test$logit_class_reduced == test$hit)

roc_full <- roc(test$hit, test$logit_prob_full)
roc_reduced <- roc(test$hit, test$logit_prob_reduced)

auc_full <- auc(roc_full)
auc_reduced <- auc(roc_reduced)

png("outputs/roc_curve_model_1.png")
plot(roc_full, main = "ROC Curve - Full Model")
dev.off()

png("outputs/roc_reduced_model_2.png")
plot(roc_reduced, main = "ROC Curve - Reduced Model")
dev.off()

# Confusion matrix for Model 1
pred_class_1 <- factor(test$logit_class_full, levels = c(0,1))
actual_class1 <- factor(test$hit, levels = c(0,1))

conf_matrix1 <- confusionMatrix(pred_class_1, actual_class1, positive = "1")
print("Confusion Matrix - Model 1:")
print(conf_matrix1)

# Confusion matrix for Model 2

pred_class_2 <- factor(test$logit_class_reduced, levels = c(0,1))
actual_class_2 <- factor(test$hit, levels = c(0,1))

conf_matrix2 <- confusionMatrix(pred_class_2, actual_class1, positive = "1")
print("Confusion Matrix - Model 2:")
print(conf_matrix2)

# =============================================
# 6. Final Evaluation Summary
# =============================================

cat("Model Evaluation Summary")
cat(sprintf("Linear Regression Full     - RMSE: %.2f\n", rmse_lm_full))
cat(sprintf("Linear Regression Reduced  - RMSE: %.2f\n", rmse_lm_reduced))
cat(sprintf("Decision Tree Full         - RMSE: %.2f\n", rmse_tree_full))
cat(sprintf("Decision Tree Reduced      - RMSE: %.2f\n", rmse_tree_reduced))
cat(sprintf("Random Forest Full         - RMSE: %.2f\n", rmse_rf_full))
cat(sprintf("Random Forest Reduced      - RMSE: %.2f\n", rmse_rf_reduced))
cat(sprintf("Logistic Regression Full   - Accuracy: %.2f, AUC: %.4f\n", acc_logit_full, auc_full))
cat(sprintf("Logistic Regression Reduced- Accuracy: %.2f, AUC: %.4f\n", acc_logit_reduced, auc_reduced))
