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
