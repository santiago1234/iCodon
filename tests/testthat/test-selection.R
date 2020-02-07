test_that("selection", {
  # initialize optimization function
  sampling_function <- sample_synonimous_codon(sampling_codon_distribution = sampling_optimization)
  evolutor <- evolution(test_seq, sampling_function)
  selector <- selection(predict_stability, optimization = F)

  # test that picks the fittest sequence
  daughters_1 <- evolutor(test_seq)
  # the seed is just because the random function but needs to be romoved from here

  # fitness <- purrr::map_dbl(daughters_1, predict_stability)
  # fitest_seq <- daughters_1[which(fitness == max(fitness))]

  # expect_equal(selector(daughters_1, 1)$synonymous_seq, fitest_seq)

  # test the same for deoptimization
  # selector <- selection(predict_stability, optimization = T)

  # test that picks the fittest sequence
  # daughters_1 <- evolutor(fitest_seq)
  # the seed is just because the random function but needs to be romoved from here

  # fitness <- purrr::map_dbl(daughters_1, predict_stability)

  # fitest_seq <- daughters_1[which(fitness == max(fitness))]
  # expect_equal(selector(daughters_1, 1)$synonymous_seq, fitest_seq)
})
