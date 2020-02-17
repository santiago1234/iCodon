
<!-- README.md is generated from README.Rmd. Please edit that file -->
optimalcodonR
=============

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/santiago1234/optimalcodonR.svg?branch=master)](https://travis-ci.org/santiago1234/optimalcodonR) [![Codecov test coverage](https://codecov.io/gh/santiago1234/optimalcodonR/branch/master/graph/badge.svg)](https://codecov.io/gh/santiago1234/optimalcodonR?branch=master) <!-- badges: end -->

The goal of optimalcodonR is to ...

Installation
------------

You can install the released version of optimalcodonR from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("optimalcodonR")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("santiago1234/optimalcodonR")
```

Example
-------

This is a basic example which shows you how to optimize the gene expression of the following gene:

``` r
library(optimalcodonR)
cat(test_seq)
#> ATGTGGAGCGGCGGAGCTGAGCAACAACACCCTAAAACCGACAAATCTCACCGATGCAATGGCGTCGACAGCTCAAGAAGAAAGAACAGATCGCAGCGGTGGCGATATGAAGTCAAGAAAACTGGATGA
```

What is special about using `README.Rmd` instead of just `README.md`? You can include R chunks like so:

``` r
sequence <- test_seq
result <- optimizer(sequence, specie = "mouse", n_iterations = 30, make_more_optimal = T)
#> optimizing sequence (more optimal)
#> starting genetic algorithm ...
#> 2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.
```

Visualizing the results
-----------------------

``` r
visualize_evolution(result)
```

<img src="man/figures/README-viz-1.png" width="100%" />

``` r
visualize_evolution(result, draw_heatmap = F)
```

<img src="man/figures/README-viz2-1.png" width="100%" />
