Santiago G. Medina-Muñoz, Michay Diez, Luciana A Castellano, Gabriel da
Silva Pescador, Qiushuang Wu, & Ariel Bazzini

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

<img src="https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41598-022-15526-7/MediaObjects/41598_2022_15526_Fig7_HTML.png?as=webp" title="iCodon predicts gene expression based on the codon composition and designs new variants based on synonymous mutations." alt="iCodon predicts gene expression based on the codon composition and designs new variants based on synonymous mutations." width="100%" />

Messenger RNA (mRNA) stability substantially impacts steady-state gene
expression levels in a cell. mRNA stability is strongly affected by
codon composition in a translation-dependent manner across species,
through a mechanism termed codon optimality. We have developed
[iCodon](www.iCodon.org), an algorithm for customizing mRNA expression
through the introduction of synonymous codon substitutions into the
coding sequence. iCodon is optimized for four vertebrate transcriptomes:
mouse, human, frog, and fish. Users can predict the mRNA stability of
any coding sequence based on its codon composition and subsequently
generate more stable (optimized) or unstable (deoptimized) variants
encoding for the same protein. Further, we show that codon optimality
predictions correlate with both mRNA stability using a massive reporter
library and expression levels using fluorescent reporters and analysis
of endogenous gene expression in zebrafish embryos and/or human cells.
Therefore, iCodon will benefit basic biological research, as well as a
wide range of applications for biotechnology and biomedicine.

### [iCodon web-application!](https://bazzinilab.shinyapps.io/icodon/)

[Check the iCodon
paper](https://www.nature.com/articles/s41598-022-15526-7).

## :arrow_double_down: Installation

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
#> 2.3.4.5.6.7.8.9.10.11.
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
