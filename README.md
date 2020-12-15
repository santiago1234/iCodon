Santiago G. Medina-Muñoz, Michay Diez, Luciana A Castellano, Qiushuang
Wu, Ariel Bazzini

<!-- README.md is generated from README.Rmd. Please edit that file -->

# iCodon: <img src='man/figures/logo.png' align="right" height="139" /> designing “ideal” coding (iCodon) sequences for customized expression level

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/238309734.svg)](https://zenodo.org/badge/latestdoi/238309734)
[![Travis build
status](https://travis-ci.org/santiago1234/iCodon.svg?branch=master)](https://travis-ci.org/santiago1234/optimalcodonR)
[![Codecov test
coverage](https://codecov.io/gh/santiago1234/iCodon/branch/master/graph/badge.svg)](https://codecov.io/gh/santiago1234/optimalcodonR?branch=master)
[![](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
<!-- badges: end -->

The regulation of messenger RNA (mRNA) stability substantially
contributes to steady-state gene expression levels in all organisms.
Codon composition is the most pervasive and impactful determinant of
mRNA stability in vertebrates. We have developed iCodon, an algorithm
for the *in silico* design of coding sequences customized to achieve
desired target expression levels based on synonymous codon
substitutions. Users can predict the mRNA stability of any coding
sequence based on its codon composition and subsequently generate more
stable (optimized) or unstable (de-optimized) variants encoding for the
same protein. This tool will benefit basic biological research, as well
as a wide range of biotechnology applications.

### [iCodon web-application\!](https://bazzinilab.shinyapps.io/icodon/)

in production [Medina et al 2020](https://www.biorxiv.org/)

## :arrow\_double\_down: Installation

You can install the released version of iCodon from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("santiago1234/iCodon")
```

## :book: Example

This is a basic example which shows you how to optimize the gene
expression of the following gene:

``` r
library(iCodon)
cat(test_seq)
#> ATGTGGAGCGGCGGAGCTGAGCAACAACACCCTAAAACCGACAAATCTCACCGATGCAATGGCGTCGACAGCTCAAGAAGAAAGAACAGATCGCAGCGGTGGCGATATGAAGTCAAGAAAACTGGATGA
```

``` r
sequence <- test_seq
result <- optimizer(sequence, specie = "mouse", n_iterations = 10, make_more_optimal = T)
#> optimizing sequence (more optimal)
#> starting genetic algorithm ...
#> 2.3.4.5.6.7.8.9.10.
```

## Visualizing the results

``` r
visualize_evolution(result)
```

<img src="man/figures/README-viz-1.png" width="100%" />

To see what else can be accomplished with this package see the help
with:

``` r
browseVignettes("iCodon")
```
