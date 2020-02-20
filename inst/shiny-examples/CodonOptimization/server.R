library(shiny)
library(optimalcodonR)
library(magrittr)

# Define server logic ----
server <- function(input, output) {

  dataInput <- reactive({
    # This part runs the optimization algorithm
    # control of parameters for optimization

    optimalcodonR::optimizer(
      sequence_to_optimize = input$open_readin_frame,
      # if other vertebrate is choosen then use human
      specie = ifelse(input$specie == "other specie (vertebrate)", "human", input$specie),
      n_iterations = 5,
      n_Daughters = 7,
      make_more_optimal = ifelse(input$direction == "increased", T, F)
    )
  })


  output$codon_optimization <- renderPlot({

    visualize_evolution(dataInput())

  }, width = 1000, height = 200)


  output$optimized_sequence <- renderText({
    # get the best sequence
    # the best sequence is the sequence at the last iteration
    datos <- dataInput()
    best_seq <- datos$synonymous_seq[nrow(datos)]
    # TODO: write a functio to pretty print the sequence
    # add a line breake avery 100 characters
    best_seq
  })

  output$trajectory_optimization <- renderPlot({

    plot_optimization(dataInput())

  }, width = 1000, height = 400)
}
