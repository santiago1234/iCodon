## quiets concerns of R CMD check re: the .'s that appear in pipelines
utils::globalVariables(c(".", ".data"))

## data global variables
## the description of each of these datasets is in the documentation
global_vars_data <- c(
  "codones", "sampling_optimization", "sampling_deoptimization",
  "preprocessing_recipe", "human_optimality", "mrna_stability_model"
)
utils::globalVariables(global_vars_data)
