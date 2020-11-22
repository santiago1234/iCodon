context("test optimization")

seq_to_test <- testing$coding[26]
results <- optimizer(seq_to_test, specie = "mouse", n_iterations = 3)
results2 <- optimizer(seq_to_test, specie = "mouse", n_iterations = 3)

test_that("optimized sequence is more stable than input sequence", {
  expect_true(results$predicted_stability[1] <= results$predicted_stability[3])
})

test_that("results are reproducible by using the seed", {
  expect_true(results$synonymous_seq[3] == results2$synonymous_seq[3])
})
