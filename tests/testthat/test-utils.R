testthat::test_that("test utils", {
  # validate sequence
  expect_equal(is.null(validate_sequence(test_seq)), TRUE)
  # not divisible by 3
  expect_error(validate_sequence(paste0(test_seq, "a")))
  expect_error(validate_sequence(paste0(test_seq, "aA")))

  expect_error(validate_sequence(paste0(test_seq, "%^&")))

  # sequence too short
  expect_error(validate_sequence("AAACCC"))

  # premature stop codon
  expect_error(validate_sequence(paste0(test_seq, "TAA", test_seq)))



  # test codon split_by_codons

  spliter_seq <- split_by_codons(test_seq) %>%
    stringr::str_c(collapse = "")
  expect_equal(spliter_seq, test_seq)

  # test translte function
  sequencia <- "ATGTGGAGCGGCGGAGCTGAGCAACAACACCCTAAAACCGACAAATCTCACCGATGCAATGGCGTCGACAGCTCAAGAAGAAAGAACAGATCGCAGCGGTGGCGATATGAAGTCAAGAAAACTGGATGA"
  aa_seq <- "MWSGGAEQQHPKTDKSHRCNGVDSSRRKNRSQRWRYEVKKTG*"
  expect_true(translate(sequencia) == aa_seq)
})


# count codons ------------------------------------------------------------


context("count codons")

dna <- "ATGGCAAGGCCCAAAGTGTTTTTCGATCTGACCGCCGGCGGCAGTCCTGTTGGAAGGGTGGTAATGGAG"
output <- count_codons(dna)

test_that("number of counts equals number of codons", {
  expect_equal(sum(output$n), nchar(dna) / 3)
})

test_that("correct number of counts", {
  dna1 <- "ACGacgACGtttACG"
  outpu1 <- count_codons(dna1)
  expect_equal(dplyr::filter(outpu1, codon == "ACG")$n, 4)
  expect_false("CGA" %in% outpu1$codon)
  expect_error(count_codons("A"))
})
