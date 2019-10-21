server <- function(input, output) {
  # Get reactive data ----
  get_data <- eventReactive(input$go_button, {
    # Validate both requirements:
    validate(
      need(
        input$return_type != "",
        message = "Select a type of return, then try again."
        )
    )
    print(input$in_file$datapath)
    # Get HTML data from input:
    temp <- COREmisc:::get_html(file_path = input$in_file$datapath)
    temp
  })
  # Generate table ----
  output$table <- renderDataTable({
    in_data <- get_data()
    # print(class(in_data))
    # Ensure that the unpacking is done by the right function:
    if (input$return_type == "Direct Shares") {
      out <- COREmisc::extract_shares(in_data)
    }
    if (input$return_type == "Direct Stories") {
      out <- COREmisc::extract_stories(in_data)
    }
    if (input$return_type == "Followship") {
      out <- COREmisc::extract_followship(in_data)
    }

    out %>%
      datatable(
        rownames   = FALSE,
        extensions = "Buttons",
        options    = list(buttons = c("copy",
                                      "csv",
                                      "excel"),
                          dom = "Bfrtip")
                )
  })
  # # Render download UI ----
  # output$download_ui <- renderUI({
  #   req(
  #     input$return_type,
  #     input$in_file,
  #     input$go_button
  #   )
  #   fluidRow(
  #     column(
  #       width = 12,
  #       title = "Download",
  #       column(
  #         width = 8,
  #         fluidRow(
  #           textInput(
  #             inputId     = "name_input",
  #             label       = "Export table:",
  #             value       = "",
  #             placeholder = "Identifier without extension..."
  #           )
  #         ),
  #         column(
  #           width = 12,
  #           align = "center",
  #           fluidRow(
  #             downloadButton(
  #               outputId = "download_order",
  #               label    = "Download table."
  #             )
  #           )
  #         )
  #       )
  #     )
  #   )
  # })
  # # Reactive download ----
  # output$download_order <- downloadHandler(
  #   filename = function() {
  #     paste(input$name_input, "_el.csv", sep="")
  #   },
  #   content = function(file) {
  #     if (input$return_type == "Direct Shares") {
  #       out <- COREmisc::extract_shares(in_data)
  #     }
  #     if (input$return_type == "Direct Stories") {
  #       out <- COREmisc::extract_stories(in_data)
  #     }
  #     if (input$return_type == "Followship") {
  #       out <- COREmisc::extract_followship(in_data)
  #     }
  #     write.csv(out, file, row.names = FALSE)
  #   }
  # )
}
