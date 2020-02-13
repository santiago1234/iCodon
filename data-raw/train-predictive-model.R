library(optimalcodonR)
library(recipes)
library(glmnet)

# data pre-processing -----------------------------------------------------
# NOTE: for training the preprocessing data I only use a very small fraction
# of the training data, this reduces the size of the save R object a LOT!!!

X_train <- dplyr::select(add_codon_counts(training), -decay_rate)

## sub-sample for training
## take 50 observations from each experiment

set.seed(123)

dat_for_preproc <-
  X_train %>%
  dplyr::group_by(specie, cell_type, datatype) %>%
  tidyr::nest() %>%
  mutate(sub_sample = purrr::map(data, ~dplyr::sample_n(., 50))) %>%
  dplyr::select(-data) %>%
  tidyr::unnest(sub_sample) %>%
  ungroup()


preprocessing_recipe <- recipes::recipe(dat_for_preproc) %>%
  recipes::step_rm(gene_id) %>%
  recipes::step_rm(coding) %>%
  recipes::step_medianimpute(utrlenlog) %>%
  recipes::step_spatialsign(matches("c_")) %>%
  recipes::step_dummy(specie, cell_type, datatype, one_hot = FALSE) %>%
  # this are the top codon affecting mRNA stability
  recipes::step_interact(terms =  ~ (c_CAC + c_TGT + c_TAA + c_CAT + c_GAT +
                                       c_GGA + c_AGT + c_AGC + c_TAG + c_TGA +
                                       c_TTA + c_AAG + c_AAA + c_ATC + c_AGG +
                                       c_GCT + c_TCG + c_ACT + c_CGG + c_TCA +
                                       cdslenlog + utrlenlog +
                                       matches("specie") + matches("data"))^2) %>%
  recipes::step_nzv(recipes::all_numeric()) %>%
  recipes::step_center(recipes::all_numeric()) %>%
  recipes::step_scale(recipes::all_numeric())



# The next step is to prepare or prep() this recipe, which estimates any
# parameters necessary for the preprocessing steps from the training set to
# be later applied to other datasets.

preprocessing_recipe <- recipes::prep(preprocessing_recipe, training = dat_for_preproc, verbose = TRUE)

# Now we can “juice” the prepared recipes, which gives us our preprocessed training set
X_preproc <- bake(preprocessing_recipe, X_train)
usethis::use_data(preprocessing_recipe, overwrite = T) # ************SAVE OBJECT

# train lasso model -------------------------------------------------------
## the following code will create 10 folds using grouped cross validation
## the idea is that the same sequence (gene id) is never in train and test sets
## at the same time (this reduces overfitting considerably)

fold_id <-
  factor(training$gene_id) %>%
  as.integer() %>%
  (function(x) x %% 10 + 1)

lasso_fit <- glmnet(as.matrix(X_preproc), training$decay_rate, alpha = 1)
lasso_cv <- cv.glmnet(as.matrix(X_preproc), training$decay_rate, alpha = 1, nfolds = 10, foldid = fold_id)
# the best hyperameter
bestlam <- lasso_cv$lambda.min



# re-train model with best hyper-parameter --------------------------------

mrna_stability_model <- glmnet(as.matrix(X_preproc), training$decay_rate, alpha = 1, lambda = bestlam)
usethis::use_data(mrna_stability_model, overwrite = T) # ************SAVE OBJECT
# check the model in the test data ----------------------------------------

X_test <- add_codon_counts(testing) %>%
  bake(preprocessing_recipe, .)

testing$predicted <- as.numeric(predict(mrna_stability_model, as.matrix(X_test)))

cor(testing$decay_rate, testing$predicted)**2
