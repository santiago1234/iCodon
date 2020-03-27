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
library(optimalcodonR)
library(magrittr)


ui <- fluidPage(
  theme = shinythemes::shinytheme("flatly"),
  shinyFeedback::useShinyFeedback(), # include ShinyFeedback
  titlePanel("optimalcodonR"),

  p("optimalcodonR is a tool to design synonymous mRNA variants to",
    em("affect gene expression levels" ),
    "for vertebrates"),
  br(),
  p("For a description of the method check our paper: ",
    a("Medina et al. 2020 (in production)",
      href = "https://www.biorxiv.org/")),

  fluidPage(

    selectInput("specie",
                label = "Choose a species",
                choices = list("human",
                               "mouse",
                               "xenopus",
                               "zebrafish",
                               "other species (vertebrate)"),
                selected = "mouse"),

    selectInput("direction",
                label = "increased or decreased gene expression?",
                choices = list("increased",
                               "decreased"
                ),
                selected = "increased"),

    textAreaInput(
      "open_readin_frame", width = '400', height = '100',
      p("Enter a DNA coding sequence in frame from start codon to stop codon"))
  ),

  submitButton(text = "Apply Changes"),

  mainPanel(
    plotOutput("trajectory_optimization"),
    h3("Optimized Sequence:"),
    textOutput("optimized_sequence"),
    h3(""),
    downloadLink("downloadData", "download optimization results")

  )
)
