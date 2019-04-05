library(htmltools)
library(shiny)
library(rvest)

shinyServer(function(input, output, session) {
  #### Common Format Explorer ####
  output$choice_ui <- renderUI({
    if(input$format == "Facebook Returns"){
      fluidRow(
        fileInput("in_common", "Choose a file:", accept = c(".html"))
      )
    }
  })
  # Reactive download UI:
  output$choice_download_ui <- renderUI({
    if(input$format != ""){
      fluidRow(
        column(width = 12,
               title = "Download",
               collapsible = TRUE,
               collapsed = TRUE,
               column(4,
                      HTML("<b>"),
                      p("Instructions:"),
                      HTML("</b>"),
                      HTML("<small>"),
                      p("First, provide a name for the edge list (e.g., if you are investigating John Doe, label it 'JohnDoe'). Note that the particle '_el' will be added to the download file. Then, download the file."),
                      HTML("</small>")),
               column(8,
                      fluidRow(
                        textInput("name_common", "Export identifier:", value="", placeholder = "Identifier without extension...")
                      ),
                      column(12, align= "center",
                             fluidRow(
                               downloadButton("download_common", label="Download Edgelist")
                             )
                      )
               ))
      )
    }
  })

  # Get data:
  get_common_data <- eventReactive(input$in_common, {
    if(input$format == "Facebook Returns"){
      gethtml <- reactive({
        in_html <- input$in_common
        out <- htmltools::HTML(in_html$datapath)
      })
      raw <- xml2::read_html(gethtml())
      combo_raw_tables <- raw %>%
        rvest::html_nodes("table") %>%
        rvest::html_nodes("table") %>%
        rvest::html_table(fill=TRUE) %>%
        lapply(., dplyr::mutate_if, is.numeric, as.character) %>%
        dplyr::bind_rows() %>%
        rlang::set_names( c("var", "val"))
      tagged_groups_df <- combo_raw_tables %>%
        dplyr::mutate( group_id = if_else(var == "Id", row_number(), NA_integer_) ) %>%
        #dplyr::mutate(group_id = dplyr::if_else(var == "id", dplyr::row_number(), NA_integer_) ) %>%
        tidyr::fill(group_id)
      tagged_groups_df %>%
        dplyr::group_split(group_id) %>%
        purrr::map(tidyr::spread, var, val) %>%
        purrr::map_dfr(tidyr::gather, "sent_to_key", "sent_to_val", tidyselect::starts_with("Recipients") ) %>%
        dplyr::mutate(sent_to_val = strsplit(sent_to_val, ")")) %>%
        tidyr::unnest(sent_to_val) %>%
        dplyr::mutate(sent_to_val = paste(sent_to_val, ")", sep="")) %>%
        dplyr::distinct() -> clean_table
      return(clean_table)
    }
    else{}
  })

  # Reactive download edgelist:
  output$download_common <- downloadHandler(
    filename = function() {
      paste(input$name_common, "_el.csv", sep="")
    },
    content = function(file){
      if(input$format == "Facebook Returns"){
        # Set up data table:
        clean_html <- get_common_data()
        clean_html %>%
          dplyr::select(Author, sent_to_val, everything()) %>%
          dplyr::rename(from=Author, to=sent_to_val) -> el_common_out
      }
      write.csv(el_common_out, file, row.names = FALSE)
    }
  )

  # Reactive table render:
  output$out_format <- renderDataTable({
    if(input$format == "Facebook Returns"){
      clean_html <- get_common_data()
      clean_html %>%
        dplyr::select(Author, sent_to_val, everything()) %>%
        dplyr::rename(from=Author, to=sent_to_val) %>%
        datatable(rownames=FALSE,
                  options=list(
                    scrollX = TRUE,
                    pageLength = 5,
                    #autoWidth=TRUE,
                    lengthChange = TRUE,
                    searching = FALSE,
                    bInfo=FALSE,
                    bPaginate=TRUE,
                    bFilter=TRUE
                  )) -> out_html
      return(out_html)
    }
  })
})
