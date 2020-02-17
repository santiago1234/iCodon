#' Predict mRNA stability
#'
#' This function predicts the mRNA stability of the given sequences in the corresponding
#' specie. The prediction is generated with the model: \code{mrna_stability_model}
#'
#' @param secuencias character, a vector of dna sequences to predict. If
#' more than one sequence is supplied, then the sequences should be unique. (No
#' repeated sequences)
#' @param specie character: one of human, mouse, fish, or xenopus
#'
#' @return
#' @export
#'
#' @examples
#' # predict some sequences in fish
#' predict_stability("ATGCCCGGG", "fish")
predict_stability <- function(secuencias, specie) {
  x_predict <- preprocess_secuences(secuencias, specie_ = specie) %>%
    as.matrix()

  glmnet::predict.glmnet(mrna_stability_model, newx = x_predict) %>%
    as.numeric()
}
