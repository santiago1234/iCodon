#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(magrittr)

ui <- fluidPage(

  titlePanel("optimalcodonR"),

  sidebarLayout(
    sidebarPanel(
      h2("Installation"),
      a('optimalcodonR',
        href="https://github.com/santiago1234/optimalcodonR",
        'is available on github, so you can install it in the usual way from your R console:'),
      code('devtools::install_github(\n"santiago1234/optimalcodonR\n")'),
      br(),
      br(),
      br(),
      br(),
      img(src = "algorithDraw.png", height = 150, width = 350),
      br(),
      "Here I will put a link to the journal article ",
      span("RStudio", style = "color:blue")
    ),
    mainPanel(
      h1("Manipulating gene expression by optimal codon choice"),
      img(src = "genetic-code.png", height = 180, width = 500),
      p("Shiny is a new package from RStudio that makes it ",
        em("incredibly easy "),
        "to build interactive web applications with R."),
      br(),
      p("For an introduction and live examples, visit the ",
        a("Bazzini-lab homepage.",
          href = "https://research.stowers.org/bazzinilab/index.html")),
      br(),
      h2("Features"),
      p("- Generate a synonymous sequence with increased or decreased gene expression level"),
      p("- Evaluate the effect of synonymous codon variants on ",
        strong("gene expression"))
    )
  ),


  # done layaout ------------------------------------------------------------

  fluidRow(

    selectInput("specie",
                label = "Choose a species",
                choices = list("human",
                               "mouse",
                               "xenopus",
                               "fish",
                               "other specie (vertebrate)"),
                selected = "fish"),

    selectInput("direction",
                label = "increased or decreased gene expression?",
                choices = list("increased",
                               "decreased"
                ),
                selected = "increased"),

    textAreaInput(
      "open_readin_frame", width = '400', height = '200',
      p("Enter a DNA coding sequence in frame from start codon to stop codon"),
      value = "ATGTGGAGCGGCGGAGCTGAGCAACAACACCCTAAAACCGACAAATCTCACCGATGCAATGGCGTCGACAGCTCAAGAAGAAAGAACAGATCGCAGCGGTGGCGATATGAAGTCAAGAAAACTGGATGA")
  ),

  submitButton(text = "Apply Changes"),

  mainPanel(
    plotOutput("codon_optimization"),
    textOutput("optimized_sequence"),
    plotOutput("trajectory_optimization")

  )
)
