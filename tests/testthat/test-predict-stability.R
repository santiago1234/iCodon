test_that("correct predictions", {
  # I test that the correlation in the test data of the predicted stability
  # and the observed should be at least .3
  # get a sample of the data

  human_data <- testing %>%
    dplyr::filter(specie == "human", datatype == "slam-seq") %>%
    dplyr::slice(1:50)

  # drop duplicate sequences in case there is
  human_data <- human_data[!duplicated(human_data$coding), ]
  predictor_human <- predict_stability("human")
  human_data$prediction <- predictor_human(human_data$coding)

  f_corr <- cor(human_data$prediction, human_data$decay_rate)**2

  expect_true(f_corr > .1)
})
