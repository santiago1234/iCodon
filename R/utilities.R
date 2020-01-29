#' Check correct input DNA sequence
#'
#' @param secuencia coding dna string (must be in frame)
#'
#' @return throws an error if the sucuence contains invalid characters or is not a
#' multiple of 3
#' @export
#'
#' @examples
validate_sequence <- function(secuencia) {
  secuencia <- stringr::str_to_upper(secuencia)
  stopifnot(nchar(secuencia) %% 3 == 0)

  nucs_in_seq <-
    stringr::str_split(secuencia, "") %>%
    unlist() %>%
    unique()

  stopifnot(all(nucs_in_seq %in% c("A", "C", "G", "T")))
}
