% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/selection.R
\name{selection}
\alias{selection}
\title{Selection (functional factory)}
\usage{
selection(stability_predictor, optimization = TRUE)
}
\arguments{
\item{stability_predictor}{mRNA stability preditor: takes as input a dna sequence
and produces a predicted stability (decay rate)}

\item{optimization}{logical: True for optimization (more stable sequence) and False
for deoptimization (more unstable sequence)}
}
\value{
function, selector function that take as input:
This function contains the following arguments:
\code{syn_daughters} character: synonymous sequences to evaluate (only for output function)
\code{current_iteration} integer: current iteration (only for output function)
}
\description{
produces a function for the selection. This function performs the following"
1. for a set of synonymous sequences predicts the mRNA stability with  @param stability_predictor
2. Using the selection criterion @param optimization selects the fittest individual
}
