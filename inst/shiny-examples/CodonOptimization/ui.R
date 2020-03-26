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

  useShinyFeedback(), # include ShinyFeedback
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
      a('Bazzini lab',
        href="https://research.stowers.org/bazzinilab/index.html")
    ),
    mainPanel(
      h1("Manipulating gene expression by optimal codon choice"),
      img(src = "genetic-code.png", height = 180, width = 500),
      p("optimalcodonR is a tool to design synonymous mRNA variants to",
         em("affect gene expression levels" ),
         "for vertebrates"),
      br(),
      p("For a description of the method check our paper: ",
        a("Medina et al. 2020 (in production)",
          href = "https://www.biorxiv.org/")),
      br(),
      h2("Possible use cases"),
      p("- Generate a synonymous sequence with increased or decreased mRNA half-life"),
      p("- Predict the mRNA stability bassed on the codon content"),
      p('- Generate sequences showing a gradient of gene expression to explore phenotypic effects'),
      p("- Evaluate the effect of synonymous codon variants on ",
        strong("gene expression"))
    )
  ),


  # done layaout ------------------------------------------------------------

  fluidPage(

    selectInput("specie",
                label = "Choose a species",
                choices = list("human",
                               "mouse",
                               "xenopus",
                               "fish",
                               "other species (vertebrate)"),
                selected = "mouse"),

    selectInput("direction",
                label = "increased or decreased gene expression?",
                choices = list("increased",
                               "decreased"
                ),
                selected = "increased"),

    textAreaInput(
      "open_readin_frame", width = '400', height = '200',
      p("Enter a DNA coding sequence in frame from start codon to stop codon"))
  ),

  submitButton(text = "Apply Changes"),

  mainPanel(
    plotOutput("codon_optimization"),
    plotOutput("trajectory_optimization"),
    h3("Optimized Sequence:"),
    textOutput("optimized_sequence"),
    h3(""),
    tableOutput("table"),
    downloadLink("downloadData", "download optimization")

  )
)
