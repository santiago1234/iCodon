testthat::test_that("evolution", {
  test_seq <- "ATGTGGAGCGGCGGAGCTGAGCAACAACACCCTAAAACCGACAAATCTCACCGATGCAATGGCGTCGACAGCTCAAGAAGAAAGAACAGATCGCAGCGGTGGCGATATGAAGTCAAGAAAACTGGATGA"

  # get the variant generator function
  sampling_function <- sample_synonimous_codon(sampling_codon_distribution = sampling_optimization)
  variant_generator <- evolution(test_seq, sampling_function, mutation_rate = .7, n_daughters = 1)


  # check that mutations are added it
  # using 100% percent should guarantee at least mutation
  set.seed(123)
  variante <- variant_generator(test_seq)
  expect_true(variante != test_seq)

  # same protein sequence
  expect_equal(translate(variante), translate(test_seq))

  # the last and firt codons are not changed
  expect_equal(substring(variante, 1, 3), substring(test_seq, 1, 3))
  expect_equal(stringr::str_sub(variante, -3, -1), stringr::str_sub(test_seq, -3, -1))

  # test that the correct proportion of mutations are introduced
  # the number of mutations should not exceed 10%
  variant_generator2 <- evolution(test_seq, sampling_function, mutation_rate = .1, n_daughters = 10)
  distances <-
    variant_generator2(variante) %>%
    purrr::map_dbl(~codon_distance(., variante, proportion = T))
  expect_true(all(distances < .1))

  # this result is stochastic but at least 10% difference when we mutate
  # each position

  variant_generator2 <- evolution(test_seq, sampling_function, mutation_rate = 1, n_daughters = 10)
  distances <-
    variant_generator2(variante) %>%
    purrr::map_dbl(~codon_distance(., test_seq, proportion = T))
  expect_true(all(distances > .1))


})
