library(tidyverse)
library(recipes)
library(glmnet)

# training <- add_codon_counts(training)

X_train <- select(training, -decay_rate)

preproc_rec <- recipe(X_train) %>%
  recipes::step_rm(gene_id) %>%
  recipes::step_rm(coding) %>%
  recipes::step_medianimpute(utrlenlog) %>%
  recipes::step_spatialsign(dplyr::matches("c_")) %>%
  recipes::step_dummy(specie, cell_type, datatype, one_hot = FALSE) %>%
  # this are the top codon affecting mRNA stability
  recipes::step_interact(terms = ~ (c_CAC + c_TGT + c_TAA + c_CAT + c_GAT +
    c_GGA + c_AGT + c_AGC + c_TAG + c_TGA +
    c_TTA + c_AAG + c_AAA + c_ATC + c_AGG +
    c_GCT + c_TCG + c_ACT + c_CGG + c_TCA +
    cdslenlog + utrlenlog +
    matches("specie") + matches("data"))^2) %>%
  recipes::step_nzv(recipes::all_numeric()) %>%
  recipes::step_poly(matches("c_"), degree = 2) %>%
  recipes::step_center(recipes::all_numeric()) %>%
  recipes::step_scale(recipes::all_numeric())



# The next step is to prepare or prep() this recipe, which estimates any
# parameters necessary for the preprocessing steps from the training set to
# be later applied to other datasets.

preproc_rec <- prep(preproc_rec, training = X_train, verbose = TRUE)

# Now we can “juice” the prepared recipes, which gives us our preprocessed training set
X_preproc <- juice(preproc_rec)


# shorter interaction formula to increase the computations ----------------



# above code should be a function -----------------------------------------
# train lasso model -------------------------------------------------------

## the following code will create a folds using grouped fold validation

fold_id <-
  factor(training$gene_id) %>%
  as.integer() %>%
  (function(x) x %% 10 + 1)

lasso_fit <- glmnet(as.matrix(X_preproc), training$decay_rate, alpha = 1)
lasso_cv <- cv.glmnet(as.matrix(X_preproc), training$decay_rate, alpha = 1, nfolds = 10, foldid = fold_id)
bestlam <- lasso_cv$lambda.min


predictions <- predict(lasso_fit, s = bestlam, newx = as.matrix(X_preproc)) %>%
  as.numeric()

plot(predictions, training$decay_rate)
cor(predictions, training$decay_rate)

# investigate in test data ------------------------------------------------
# this will help to desing the predict function

X_test <- testing %>%
  add_codon_counts() %>%
  bake(preproc_rec, .)


testing$prediction <- as.numeric(predict(lasso_fit, s = bestlam, newx = as.matrix(X_test)))

testing %>%
  ggplot(aes(x = prediction, y = decay_rate)) +
  geom_point(alpha = 1 / 2)

# good there is no overfitting
cor(testing$decay_rate, testing$prediction)
