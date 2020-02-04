# generates a sampling distribution for synonimous codon choice -----------
# bassed on the optimality level of each codon ----------------------------

library(dplyr)
library(tibble)

# I rank the codon bassed on optimlaity (optimization or deoptimization)
# then with the softmax function I generate the sampling distributions

softmax <- function(x) exp(x) / sum(exp(x))

sampling_optimization <-
  optimalcodonR::human_optimality %>%
  arrange(optimality) %>%
  group_by(amino_acid) %>%
  mutate(
    rank_optimality = rank(optimality),
    sampling_probility = softmax(rank_optimality)
  ) %>%
  select(-rank_optimality) %>%
  split(.$amino_acid)

sampling_deoptimization <-
  optimalcodonR::human_optimality %>%
  arrange(optimality) %>%
  group_by(amino_acid) %>%
  mutate(
    rank_optimality = rank(-optimality), # negative to sample more non-optimal
    sampling_probility = softmax(rank_optimality)
  ) %>%
  select(-rank_optimality) %>%
  split(.$amino_acid)


usethis::use_data(sampling_deoptimization, overwrite = TRUE)
usethis::use_data(sampling_optimization, overwrite = TRUE)
