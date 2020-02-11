
# train and test data (machine learning) ----------------------------------

training <- readr::read_csv("/Volumes/projects/smedina/projectos/190108-mzt-rna-stability/paper-analysis/data/191004-TrainAndTestSets/training_set.csv")
testing <- readr::read_csv("/Volumes/projects/smedina/projectos/190108-mzt-rna-stability/paper-analysis/data/191004-TrainAndTestSets/validation_set.csv")

usethis::use_data(training)
usethis::use_data(testing)
