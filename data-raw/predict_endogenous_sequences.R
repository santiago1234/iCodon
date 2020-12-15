library(tidyverse)
library(iCodon)


# script to generate predictions for endogenous genes ---------------------
# this data is used to plot the histogram that is part of the visualization
# in the shinny app
# -- ----------------------------------------------------------------------


endo_optipred <- bind_rows(training, testing) %>%
  select(gene_id, specie, coding)


add_optimality_prediction <- function(specie, data_s) {
  stab_predictor <- predict_stability(specie)

  # remove duplicated sequences (due to gene id)
  data_s <-
    data_s %>%
    unique() %>%
    filter(!duplicated(coding))

  data_s$optimality <- stab_predictor(data_s$coding)

  # table with column that includes the predictions
  data_s %>%
    select(-coding)

}

endo_optipred <-
  endo_optipred %>%
  unique() %>%
  group_by(specie) %>%
  nest() %>%
  mutate(
    result = map2(specie, data, add_optimality_prediction)
  )

optipred <-
  endo_optipred %>%
  select(-data) %>%
  unnest(result) %>%
  ungroup()

usethis::use_data(optipred, overwrite = TRUE)
