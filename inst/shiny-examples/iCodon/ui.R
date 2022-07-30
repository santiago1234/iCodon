#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyFeedback)
library(iCodon)
library(magrittr)


ui <- fluidPage(
  theme = shinythemes::shinytheme("flatly"),
  shinyFeedback::useShinyFeedback(), # include ShinyFeedback
  titlePanel('iCodon customizes gene expression based on the codon composition'),

  p(
    "iCodon predicts the mRNA stability of any coding sequence based on its codon composition ",
    "and then subsequently generates a ",
    em("more stable (optimization) or more unstable (de-optimization) " ),
    "variant that will encode for the same protein. The model is optimized for several vertebrate genomes, that can be selected below."),
  p("\nFor a description of the method check our paper: ",
    a("DOI: 10.1038/s41598-022-15526-7",
      href = "https://doi.org/10.1038/s41598-022-15526-7"), "."),
  p("iCodon is also available as an",
    a("R package",
      href = "https://github.com/santiago1234/iCodon"), "."),

  p("For more information about our research visit the",
    a("Bazzini lab webpage",
      href = "https://research.stowers.org/bazzinilab/index.html"), "."),
  p("If you choose to use this application please cite: Diez M, Medina-Muñoz SG, Castellano LA, da Silva Pescador G, Wu Q, & Bazzini AA. iCodon customizes gene expression based on the codon composition, Scientific Reports 2022 12:12126.
"),
  fluidPage(

    selectInput("specie",
                label = "Choose a species (if your species is not present choose the closest relative).",
                choices = list("human",
                               "mouse",
                               "xenopus",
                               "zebrafish"),
                selected = "human"),
    textAreaInput(
      "open_readin_frame", width = '700', height = '100',
      p("Enter a DNA coding sequence in frame from start codon to stop codon"))
  ),
  "\nExample sequence (copy and paste above):",
  "ATGGATCGTGGTCAGCATCCTCCTGGGTGGGCCTGGCAGTGGCTTTCCTCGCATCCAGCAACTCTTCACCAGCTGGAGTGCAGTGGTGCAATCTCGGTTCACTGCAACCTCTACCTCCTGGGTTCAAGCGATTCTAGTGCCCCAGCCTCCCGAGTAGCTGAGACTACAGGTCCAGAGAGCTCGGTGACTGCAGCGCCACGGGCCAGGAAGTACAAGTGTGGCCTGCCCCAGCCGTGTCCTGAGGAGCACCTGGCCTTCCGCGTGGTCAGCGGGGCCGCCAACGTCATTGGGCCCAAGATCTGCCTCGAGGACAAGATGCTGATGAGCAGCGTCAAGGACAACGTGGGCCGCGGGCTGAACATCGCCCTGGTGAACGGGGTCAGCGGCGAGCTCATCGAGGCCCGGGCCTTTGACATGTGGGCCGGAGATGTCAACGACCTGTTGAAGTTTATTCGGCCACTGCACGAAGGCACCCTGGTGTTCGTGGCATCCTACGACGACCCAGCCACCAAGATGAATGAAGAGACCAGAAAGCTCTTCAGTGAGCTGGGCAGCAGGAACGCCAAGGAGCTGGCCTTCCGGGACAGCTGGGTGTTTGTCGGGGCCAAGGGTGTGCAGAACAAGAGCCCCTTTGAGCAGCACGTGAAGAACAGTAAGCACAGCAACAAGTACGAAGGCTGGCCCGAGGCGCTGGAGATGGAAGGCTGTATCCCGCGGAGAAGCACGGCCAGCTAG",

  submitButton(text = "Run iCodon"),

  mainPanel(
    plotOutput("trajectory_optimization"),
    h3("Predicted stability (input sequence):"),
    textOutput("predicte_stability"),
    h3("Optimized Sequence:"),
    textOutput("optimized_sequence"),
    h3("Deoptimized Sequence:"),
    textOutput("deoptimized_sequence"),
    h3(""),
    downloadLink("downloadData", "download optimization results")

  )
)
