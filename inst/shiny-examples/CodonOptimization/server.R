# Define server logic ----
server <- function(input, output) {

  dataInput <- reactive({

    req(input$open_readin_frame) # require use input to start
    # *******************************************
    ## NOTE: all this code enclosed in ** is to provide the
    ## feed-back to the user. If this code is  deleted the
    ## with no problem app should work
    ## provide user feeback for the squence
    # format the sequence, remove spaces,tabs, etc.
    secuencia <- input$open_readin_frame %>%
      stringr::str_to_upper() %>%
      stringr::str_replace_all("[\r\n ]", "")

    # -> -> Case 1: Divisible by 3
    event_1 <- nchar(secuencia) %% 3 == 0 # this is the test to pass
    message_1 <- "The sequence length must be divisible by 3. Make sure your sequence is in the correct frame."
    shinyFeedback::feedbackDanger("open_readin_frame", !event_1, message_1)
    req(event_1)

    # -> -> Case 2: Invalid characters
    nucs_in_seq <-
      stringr::str_split(secuencia, "") %>%
      unlist() %>%
      unique()
    invalid <- nucs_in_seq[!nucs_in_seq %in% c("A", "G", "T", "C")]
    event_2 <- length(invalid) == 0
    message_2 <- paste0("Invalid charcter(s) found: ", invalid[1])
    shinyFeedback::feedbackDanger("open_readin_frame", !event_2, message_2)
    req(event_2)

    # -> -> Case 3: Invalid Sequence Length
    min_value <- 70
    max_value <- 43524
    seq_len <- nchar(secuencia)
    event_3 <- (min_value < seq_len) & (seq_len < max_value)
    shinyFeedback::feedbackDanger("open_readin_frame", !event_3, "Invalid sequence length. Sequence too short/long.")
    req(event_3)

    # -> -> Case 4/5: Warning: Starts with ATG
    event_4 <- stringr::str_sub(secuencia, 1, 3) == "ATG"
    shinyFeedback::feedbackWarning("open_readin_frame", !event_4, "The sequence does not start with ATG")

    event_5 <- stringr::str_sub(secuencia, -3) %in% c("TAG", "TAA", "TGA")
    shinyFeedback::feedbackWarning("open_readin_frame", !event_5, "The sequence does not end in a stop codon")


    # *******************************************


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

  output$table <- renderTable({
    # make the output plot nicer
    # add the half-life for the user
    dataInput() %>%
      dplyr::select(iteration, half_life, synonymous_seq)
  }, striped = TRUE)

  output$downloadData <- downloadHandler(

    filename = function() {
      paste("optimization-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      readr::write_csv(dataInput(), file)
    }
  )
}
