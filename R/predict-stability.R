#' Predict mRNA stability functional factory
#'
#' This function will generate a function that predicts the mRNA stability of the
#' given species in the input sequences The prediction is generated with the model:
#' \code{mrna_stability_model}. The output function will take as input a set of
#' dna sequences (vector) these sequences should not contain repeated elements
#' @param specie character: one of human, mouse, fish, or xenopus
#'
#' @return numeric vector with predicted decay rate
#' @export
#'
#' @examples
#' predictor_fish <- predict_stability("fish")
#' some_seqs <- testing$coding[1:3]
#' predicted_stability <- predictor_fish(some_seqs)
predict_stability <- function(specie) {
  if (!specie %in% c("human", "mouse", "fish", "xenopus")) {
    stop("Invalid specie")
  }

  function(secuencias) {
    x_predict <- preprocess_secuences(secuencias, specie_ = specie) %>%
      as.matrix()

    glmnet::predict.glmnet(mrna_stability_model, newx = x_predict) %>%
      as.numeric()
  }
}
