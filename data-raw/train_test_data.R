
# train and test data (machine learning) ----------------------------------
# this is how i generated the training and testing data
# training <- readr::read_csv("/Volumes/projects/smedina/projectos/190108-mzt-rna-stability/paper-analysis/data/191004-TrainAndTestSets/training_set.csv")
# testing <- readr::read_csv("/Volumes/projects/smedina/projectos/190108-mzt-rna-stability/paper-analysis/data/191004-TrainAndTestSets/validation_set.csv")
# usethis::use_data(training)
# usethis::use_data(testing)


# generate the codons -----------------------------------------------------

codones <-
  expand.grid(
    n1 = c("A", "C", "G", "T"),
    n2 = c("A", "C", "G", "T"),
    n3 = c("A", "C", "G", "T")
  ) %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    codon = paste0(n1, n2, n3)
  ) %>%
  dplyr::select(codon)

usethis::use_data(codones, overwrite = T)
