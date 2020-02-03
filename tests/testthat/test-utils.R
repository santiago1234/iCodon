testthat::test_that("test utils", {
  # validate sequence
  expect_equal(is.null(validate_sequence("AAAccc")), TRUE)
  expect_error(validate_sequence("a"))
  expect_error(validate_sequence("AA"))
  expect_error(validate_sequence("AAN"))

  # test translte function
  sequencia <- "ATGTGGAGCGGCGGAGCTGAGCAACAACACCCTAAAACCGACAAATCTCACCGATGCAATGGCGTCGACAGCTCAAGAAGAAAGAACAGATCGCAGCGGTGGCGATATGAAGTCAAGAAAACTGGATGA"
  aa_seq <- "MWSGGAEQQHPKTDKSHRCNGVDSSRRKNRSQRWRYEVKKTG*"
  expect_true(translate(sequencia) == aa_seq)
})
