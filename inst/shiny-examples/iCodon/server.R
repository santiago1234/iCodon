# Define server logic ----
server <- function(input, output) {

  dataInput <- reactive({

    req(input$open_readin_frame) # require use input to start
    # *******************************************
    ## NOTE: all this code enclosed in ** is to provide the
    ## feed-back to the user. If this code is  deleted
    ## without problem app should work normally
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
    message_2 <- paste0("Invalid character(s) found: ", invalid[1])
    shinyFeedback::feedbackDanger("open_readin_frame", !event_2, message_2)
    req(event_2)

    # -> -> Case 3: Invalid Sequence Length
    min_value <- 70
    max_value <- 43524
    seq_len <- nchar(secuencia)
    event_3 <- (min_value < seq_len) & (seq_len < max_value)
    shinyFeedback::feedbackDanger("open_readin_frame", !event_3, "Invalid sequence length. Sequence too short/long.")
    req(event_3)

    # -> -> Case 5: Premature Stop codon
    stop_codons <- c("TAG", "TAA", "TGA")
    found_stop <-
      gsub("(.{3})", "\\1 ", secuencia) %>%
      stringr::str_split(" ") %>%
      unlist() %>%
      .[-length(.)] %>%
      utils::head(-1) %>%
      .[. %in% stop_codons]
    event_5 <- length(found_stop) == 0
    message_5 <- "Your sequence contains a premature stop codon. Maybe is not in the correct frame?."
    shinyFeedback::feedbackDanger("open_readin_frame", !event_5, message_5)
    req(event_5)

    # -> -> Case 6: Does not ends with ATG

    event_6 <- stringr::str_sub(secuencia, -3) %in% stop_codons
    shinyFeedback::feedbackWarning("open_readin_frame", !event_6, "The sequence does not end in a stop codon")

    # *******************************************


    # This part runs the optimization algorithm
    # control of parameters for optimization

    showNotification("Running optimization (It may take a minute)...", type = "message", duration = 30)

    specie_animal <- input$specie
    specie_animal <- ifelse(specie_animal == "zebrafish", yes = "fish", no = specie_animal)


    results <- iCodon::run_optimization_shinny(input$open_readin_frame, specie_animal)

    # this section is just a message in case the input sequence is too optimal or
    # non-optimal
    initial_opt <-
      results %>%
      dplyr::filter(iteration == 0) %>%
      dplyr::slice(1:1) %>%
      dplyr::pull(.data$predicted_stability)

    if (abs(initial_opt) > 1) showNotification("The input sequence is too optimal/non-optimal (unable to optimize)", duration = 60, type = "error", closeButton = T)



    # output the main results table
    results

  })


  output$predicte_stability <- renderText({
    # get the best sequence
    # the best sequence is the sequence at the last iteration
    datos <- dataInput()
    prediction <- datos %>%
      dplyr::filter(optimization == "optimized", iteration == 0) %>%
      dplyr::pull(predicted_stability) %>%
      round(5)

    prediction
  })


  output$optimized_sequence <- renderText({
    # get the best sequence
    # the best sequence is the sequence at the last iteration
    datos <- dataInput()
    best_seq <- datos %>%
      dplyr::filter(optimization == "optimized", iteration == 10) %>%
      dplyr::pull(synonymous_seq)

    best_seq
  })

  output$deoptimized_sequence <- renderText({
    # get the best sequence
    # the best sequence is the sequence at the last iteration
    datos <- dataInput()
    best_seq <- datos %>%
      dplyr::filter(optimization == "deoptimized", iteration == 10) %>%
      dplyr::pull(synonymous_seq)

    best_seq
  })

  output$trajectory_optimization <- renderPlot({

    specie_animal <- input$specie
    specie_animal <- ifelse(specie_animal == "zebrafish", yes = "fish", no = specie_animal)
    viz_result_shiny(dataInput(), specie_animal)

  }, width = 800, height = 400)

  output$downloadData <- downloadHandler(

    filename = function() {
      paste("optimization-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      datos <- dataInput()
      # change the optimization value for iteration 0 to show input sequence
      seqs_iter <- datos %>%
        dplyr::filter(iteration > 0)

      in_seq <- datos %>%
        dplyr::filter(iteration == 0) %>%
        dplyr::slice(1:1) # pick 1

      in_seq$optimization <- "input sequence"
      datos <- dplyr::bind_rows(in_seq, seqs_iter)

      readr::write_csv(datos, file)
    }
  )
}
