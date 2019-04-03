library(shinydashboard)
library(shiny)
library(dplyr)
library(DT)
library(visNetwork)
library(igraph)

header <- dashboardHeader(
  title = "HTML Table Structurer"
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    id="tabs",
    menuItem( "Common Format Explorer",
              tabName = "formats",
              icon = icon("wpexplorer")),
    menuItem( "Support",
              tabName = "support",
              icon = icon("info-circle"))
  )
)

body <- dashboardBody(
  shinyjs::useShinyjs(),
  tabItems(
    tabItem(
      tabName = "formats",
      fluidRow(
        box(width = 12,
            selectInput("format", "Data source:",
                        choices=c("","Facebook Returns"),
                        selected = ""
            ),
            fluidRow(
              column(12, align="left", column(12, uiOutput("choice_ui"))),
              br(),
              column(12, align="left", column(12, uiOutput("choice_download_ui")))
            )
        )
      ),
      mainPanel(dataTableOutput("out_format"), width = "100%")
    )
  ))

dashboardPage(
  header,
  sidebar,
  body
)
