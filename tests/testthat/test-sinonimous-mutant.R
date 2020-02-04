testthat::test_that("variante_sinonima", {
  secuencia <- "ATGTGGAGCGGCGGAGCTGAGCAACAACACCCTAAAACCGACAAATCTCACCGATGCAATGGCGTCGACAGCTCAAGAAGAAAGAACAGATCGCAGCGGTGGCGATATGAAGTCAAGAAAACTGGATGA"

  # get the variant generator function
  sampling_function <- sample_synonimous_codon(sampling_codon_distribution = sampling_optimization)
  variant_generator <- variante_sinonima(secuencia, sampling_function, percentage = .7)


  # check that mutations are added it
  # using 100% percent should guarantee at least mutation
  set.seed(123)
  variante <- variant_generator(secuencia)
  expect_true(variante != secuencia)

  # same protein sequence
  expect_equal(translate(variante), translate(secuencia))

  # the last and firt codons are not changed
  expect_equal(substring(variante, 1, 3), substring(secuencia, 1, 3))
  expect_equal(stringr::str_sub(variante, -3, -1), stringr::str_sub(secuencia, -3, -1))


})
