#' Genetic code codons -> amino acid
#'
#' The genetic code
#'
#' @format named character vector
"gc_codons_to_amino"

#' Genetic code amino -> codons
#'
#' The genetic code
#'
#' @format list mapping amino acid to codons
"gc_amino_to_codons_l"


#' Codon optimality code for human
#'
#' The codon optimality code of human, figure 1G
#' and supplemental figure 2D from Medina et al 2020
#' \describe{
#'   \item{codon}{codon, DNA}
#'   \item{amino_acid}{amino acid, one letter amino acid code}
#'   \item{optimality}{optimality score values}
#'   ...
#' }
#'
#' @format  A data frame with 64 rows and 3 variables:
"human_optimality"


#' Sampling probabilities (deoptimization)
#'
#' The genetic code
#'
#' @format list mapping amino acid to synonimous codon sampling probabilities
"sampling_deoptimization"

#' Sampling probabilities (optimization)
#'
#' The genetic code
#'
#' @format list mapping amino acid to synonimous codon sampling probabilities
"sampling_optimization"


#' DNA sequence
#'
#' a character dna sequence that i used for testing/development
#' @format character
"test_seq"


#' Training data
#'
#' This is the data used to train the predictive model
#'
#' The decay rate measurements were obtained from the following papers:

#' \enumerate{
#' \item Bazzini, Ariel A., et al. "Codon identity regulates mRNA stability and translation efficiency during the maternal‐to‐zygotic transition."
#' \item Wu, Qiushuang, et al. "Translation affects mRNA stability in a codon-dependent manner in human cells." Elife 8 (2019): e45396.
#' \item Herzog, Veronika A., et al. "Thiol-linked alkylation of RNA to assess expression dynamics." Nature methods 14.12 (2017): 1198.
#' }
#'
##' @format  A data frame with 67,775 rows and 8 variables:
#' \describe{
#'   \item{gene_id}{Ensembl gene id}
#'   \item{specie}{The specie one of: human, fish, mouse, or xenopus}
#'   \item{cell_type}{The cell type: 293t, embryo mz, hela, mES cells, k562, or RPE}
#'   \item{datatype}{experimental technique used to obtain the mRNA stability measurements (decay rate)}
#'   \item{decay_rate}{The decay rate (variable to predict), scaled with respect to each experiment}
#'   \item{utrlenlog}{ size in log scale of the 5' UTR}
#'   \item{coding}{coding dna sequence in frame}
#'   \item{cdslenlog}{size in log scale of the coding sequence}
#' }
"training"


#' Testing data
#'
#' This is the data used to test the predictive model
#'
#' The decay rate measurements were obtained from the following papers:

#' \enumerate{
#' \item Bazzini, Ariel A., et al. "Codon identity regulates mRNA stability and translation efficiency during the maternal‐to‐zygotic transition."
#' \item Wu, Qiushuang, et al. "Translation affects mRNA stability in a codon-dependent manner in human cells." Elife 8 (2019): e45396.
#' \item Herzog, Veronika A., et al. "Thiol-linked alkylation of RNA to assess expression dynamics." Nature methods 14.12 (2017): 1198.
#' }
#'
##' @format  A data frame with 67,775 rows and 8 variables:
#' \describe{
#'   \item{gene_id}{Ensembl gene id}
#'   \item{specie}{The specie one of: human, fish, mouse, or xenopus}
#'   \item{cell_type}{The cell type: 293t, embryo mz, hela, mES cells, k562, or RPE}
#'   \item{datatype}{experimental technique used to obtain the mRNA stability measurements (decay rate)}
#'   \item{decay_rate}{The decay rate (variable to predict), scaled with respect to each experiment}
#'   \item{utrlenlog}{ size in log scale of the 5' UTR}
#'   \item{coding}{coding dna sequence in frame}
#'   \item{cdslenlog}{size in log scale of the coding sequence}
#' }
"testing"


#' The genetic code
#' #' \describe{
#'   \item{codon}{three letter nucleotide codon}
#' }
#' @format  A tibble with 64 rows and 1 variable
"codones"


#' Data pre-processing pipeline
#'
#' The pipeline to pre-process the data for predicting the mRNA stability
#' NOTE: see the file: data-raw/modeling.R where I generated this
"preprocessing_recipe"

#' Predictive model of mRNA stability
#'
#' lasso (glmnet) model to predic the mRNA stability bassed on coding
#' sequence information
#' NOTE: see the file: data-raw/modeling.R where this model is trained
"mrna_stability_model"
