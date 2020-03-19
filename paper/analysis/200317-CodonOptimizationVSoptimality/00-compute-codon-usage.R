library(tidyverse)
library(optimalcodonR)

# compute the codon usage for the species ---------------------------------
# the draw-back of these analysis 
orfs_species <- 
  bind_rows(training, testing) %>% 
  select(gene_id, specie, coding) %>% 
  unique() %>% 
  filter(!duplicated(gene_id))


orfs_species <- 
  orfs_species %>% 
  mutate(
    codon_counts = map(coding, count_codons)
  ) %>% 
  select(-coding) %>% 
  unnest(codon_counts)

orfs_species <- 
  orfs_species %>% 
  group_by(specie, gene_id) %>% 
  mutate(
    usage_by_gene = n / sum(n)
  )

## to compute the usage by specie i will use the median

usage_by_specie <- 
  orfs_species %>% 
  ungroup() %>% 
  group_by(specie, codon) %>% 
  summarise(
    usage = median(usage_by_gene)
  ) %>% 
  ungroup()


usage_by_specie %>% 
  write_csv("results_data/codon_usage.csv")


# obtain the optimality effects from previous analysis --------------------

lasso_coefs <- "/Volumes/projects/smedina/projectos/190108-mzt-rna-stability/paper-analysis/191105-FeatureSelectionLasso/results-data/lasso-coefficients.csv"

lasso_coefs %>% 
  read_csv() %>% 
  filter(nchar(predictor) == 3) %>% 
  rename(codon = predictor) %>% 
  select(-data) %>% 
  group_by(specie, codon) %>% 
  summarise(lasso_coef = median(coef)) %>% 
  write_csv("results_data/optimality_lasso.csv")



