ui <- fluidPage(
  # App title ----
  titlePanel("Structuring SM Data"),
  # Sidebar layout ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # First select the type of return to unpack:
      selectInput(inputId = "return_type",
                  label   = "Select type of return to unpack:",
                  choices = c("",
                              "Direct Shares",
                              "Direct Stories",
                              "Followship"),
                  selected = ""
                  ),
      # Second ingest file to unpack:
      fileInput(inputId     = "in_file",
                label       = "Upload a file for unpacking:",
                multiple    = FALSE,
                accept      = c(".html"),
                button      = "Browse...",
                placeholder = "No file selected"),
      # Third submit options:
      column(width = 12,
             align = "center",
             actionButton(inputId = "go_button",
                          icon    = icon("play-circle"),
                          label   = "Go!")
             ),
      br()
      # ,
      # br(),
      # column(width = 12,
      #        align = "left",
      #        column(
      #          width = 12,
      #          uiOutput("download_ui")
      #        )
      #        )
    ), # End sidebarPanel()
    # Main panel for displaying outputs ----
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Table", dataTableOutput("table"))
                  )
    ) # End mainPanel()
  ) # End sidebarLayout()
) # End fluidPage()
