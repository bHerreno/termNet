# Cargar librerías necesarias
library(shiny)
library(DT)
library(FactoMineR)
library(factoextra)
library(plotly)
library(cluster)
library(shinyWidgets)

# Function to load bibliography data
load_biblio <- function(datapath) {
  # Print data path
  print(paste("datapath:", datapath))
  
  # Get file extension
  ext <- sub(".*\\.(.*)$", "\\1", datapath)
  print(paste("File extension", ext))
  
  tryCatch({
    if (ext == "csv") {
      return(read.csv(datapath))
    } else if (ext == "xml") {
      return(biblioMXL2DF(file = datapath))
    } else {
      stop("Unsupported file format")
    }
  }, error = function(e) {
    return(data.frame(Error = paste("Error processing file:", e$message)))
  })
}


#Function to load term data
load_terminos <- function(datapath) {
  if (file.exists(datapath)) {
    return(read.csv(datapath))
  } else {
    return(data.frame(Error = "File not found"))
  }
}


# Function to generate the bibliography table
render_biblio_table <- function(data) {
  return(DT::datatable(data))
}

# Function to generate the table of terms
render_terminos_table <- function(data) {
  return(DT::datatable(data))
}


# Path to .rda file
ruta_biblioMXL2DF <- "fun/biblioMXL2DF.rda"
ruta_absDummy <- "fun/absDummy.rda"

#  Check if the file exists
if (file.exists(ruta_absDummy)) {
  load(ruta_absDummy)
} else {
  stop("The absDummy.rda file is not in the specified path: ", 
       ruta_absDummy)
}


# Check if the file exists
if (file.exists(ruta_biblioMXL2DF)) {
  load(ruta_biblioMXL2DF)
} else {
  stop("The biblioMXL2DF.rda file is not in the specified path: ",
       ruta_biblioMXL2DF)
}




# Function to prepare data for analysis
## Removes the first two columns that are not needed
prepare_data_for_analysis <- function(data) {
  if (ncol(data) > 2) {
    data <- data[, -c(1, 2)]
    ## Convert remaining columns to factors
    data <- data.frame(lapply(data, factor))
    return(data)
  } else {
    stop("Los datos deben tener al menos 3 columnas")
  }
}


# User interface
ui <- fluidPage(
  tags$head(tags$link(rel = "stylesheet", 
                      type = "text/css",
                      href = "style.css")),
  setBackgroundColor(
    color = c("#f5f7eb", "#f6fae1"), 
    gradient = "linear",
    direction = "bottom"
  ),
  div(class = "container", 
      
  titlePanel("termNet"),
  
  ## Menu
  selectInput(
    inputId = "menu",
    label = "Menu",
    choices = c("Load Data",
                "Bibliography Table", 
                "Terms Table", 
                " Apply absDummy",
                "Apply MCA",
                "Apply K-Meeans"),
    selected = "Carga de datos"
  ),
  
  ## load data panel
  conditionalPanel(
    condition = "input.menu == 'Load Data'",
    div(class = "outer-container",
        div(class = "flex-row",
            div(class = "upload-section", 
                fileInput("biblio_set", 
                          "Load Bibliography CSV or XML", 
                          accept = c(".csv", ".xml")),
                fileInput("terminos_set",
                          "Load Terms CSV",
                          accept = c(".csv"))
            ),
            div(class = "image-text-container",
                tags$img(src = "images/expaling_results.svg",
                         class = "side-image"),
                tags$div("TRY YOUR OWN BIBLIOGRAPHY",
                         class = "meme-text")
        )
      )
     )
  ),
  
  ## Content for the bibliography table
  conditionalPanel(
    condition = "input.menu == 'Bibliography Table'",
    fluidRow(
      DTOutput("biblio_table")
    )
  ),
  
  ## Content for the terms table
  conditionalPanel(
    condition = "input.menu == 'Terms Table'",
    fluidRow(
      DTOutput("terminos_table")
    )
  ),
  

## Content for absDummy
  conditionalPanel(
    condition = "input.menu == ' Apply absDummy'",
    fluidRow(
      checkboxInput("rm_na_abs", "Remove NAs", TRUE),
      numericInput("min_obs", "Minimum Observations", value = 6, min = 1),
      actionButton("run_absDummy", "Run absDummy"),
      downloadButton("download_data", "Download Data")
    ),
    fluidRow(
      DTOutput("absDummy_table")
    )
  ),
  
  ## Content for MCA
  conditionalPanel(
    condition = "input.menu == 'Apply MCA'",
    actionButton("runMCA", "Run MCA Analysis"),
    checkboxInput("show_var_plot", "Show Variable Plot", value = TRUE),
    checkboxInput("show_ind_plot", "Show Observations Plot", value = TRUE),
    checkboxInput("show_only_presence", "Show  Presences Only", FALSE),
    DTOutput("mcaResultsTable"),
    plotlyOutput("mcaVarPlot"), 
    plotlyOutput("mcaIndPlot")  
  ),
  
  ## Content for the bibliography table
  conditionalPanel(
    condition = "input.menu == 'Apply K-Meeans'",
    numericInput("seed", "Set Seed", value = 37),
    numericInput("centers", "Number of Centers", value = 9, min = 2),
    actionButton("runKmeans", "Run K-Means"),
    
    ### Buttons for toggling the display
    actionButton("toggleTable", "Show K-Means Centers Table"),
    actionButton("toggleFvizCluster", "Show fviz_cluster Graph"),
    
    ### outputs
    uiOutput("kmeansResults"),
    uiOutput("fvizClusterUI")  # Salida para el gráfico de fviz_cluster
   )
  )  
)






# Server
server <- function(input, output) {
 
  ##  Initialising and observing variables
  biblio_set <- reactiveVal(NULL)
  terminos_set <- reactiveVal(NULL)
  absDummy_result <- reactiveVal(NULL)
  mca_result <- reactiveVal(NULL)
  showTable <- reactiveVal(TRUE)
  showFvizCluster <- reactiveVal(TRUE)
  
 ## Tables bibliography and terms output
  
  observeEvent(input$biblio_set, {
    biblio_set(input$biblio_set$datapath)
  })
  
  observeEvent(input$terminos_set, {
    terminos_set(input$terminos_set$datapath)
  })
  
  
  ### Render the bibliography table
  output$biblio_table <- renderDT({
    req(biblio_set())   ## Ensure biblio_set is available ##
    df_biblio <- load_biblio(biblio_set())
    if ("Error" %in% names(df_biblio)) {
      return(dataTableOutput("Bibliography file not uploaded or not found"))
    } else {
      return(render_biblio_table(df_biblio))
    }
  })
  
  
  ### Render the term table
  output$terminos_table <- renderDT({
    req(terminos_set()) 
    df_terminos <- load_terminos(terminos_set())
    if ("Error" %in% names(df_terminos)) {
      dataTableOutput("Term file not loaded or not found")
    } else {
      render_terminos_table(df_terminos)
    }
  })
  
  ## apply absDummy
  observeEvent(input$run_absDummy, {
    resultado <- tryCatch({
      absDummy(data = biblio_set(),
               terms = terminos_set(),
               rm.na.abs = input$rm_na_abs,
               min.obs = input$min_obs)
    }, error = function(e) {
      return(data.frame(Error = "Data could not be processed"))
    })
    absDummy_result(resultado)
  })
  
  ### Render absDummy results
  output$absDummy_table <- renderDT({
    req(absDummy_result()) 
    absDummy_result()
  })
  
  ### Download absDummy data
  output$download_data <- downloadHandler(
    filename = function() {
      paste("absDummy_data-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(absDummy_result(), file, row.names = FALSE) # Write csv file
    }
  )
  
  ## MCA Apply
  observeEvent(input$runMCA, {
    if (!is.null(absDummy_result())) {
      data_for_mca <- prepare_data_for_analysis(absDummy_result())
      
      ### Ensure that the data is appropriate for MCA
      if (ncol(data_for_mca) > 0 && nrow(data_for_mca) > 0) {
        ### Try  MCA
        tryCatch({
          mca_calc <- MCA(data_for_mca, 
                          ncp = min(5, ncol(data_for_mca)-1), 
                          graph = FALSE, method = "Burt")
          mca_result(mca_calc)
        }, error = function(e) {
          print("Error in MCA:")
          print(e)
        })
      } else {
        print("Data for MCA are not adequate.")
      }
    }
  })
  
 
  ### plot MCA variables
  plot_mca_variables <- function(mca_data) {
    if (!is.null(mca_data$var$coord)) {
      p <- plot_ly(x = mca_data$var$coord[,1], y = mca_data$var$coord[,2], 
                   type = 'scatter', mode = 'markers+text',
                   text = rownames(mca_data$var$coord),
                   textposition = 'top center',
                   marker = list(size = 10))
      p <- p %>% layout(title = "Plot MCA  Variables",
                        xaxis = list(title = "Dim 1"),
                        yaxis = list(title = "Dim 2"))
      p
    } else {
      print("MCA variable fields are empty")
    }
  }
  
  ### Render the MCA results table
  output$mcaResultsTable <- renderDT({
    req(mca_result()) 
    mca_data <- mca_result()
    datatable(mca_data$eig, options = list(pageLength = 5))
  })
  
  
  ###  Function to generate the MCA variable graph with plotly
  plot_mca_variables_plotly <- function(mca_data, only_presences = FALSE) {
    if (only_presences) {
      #### Filter by presence
      presences <- grepl(pattern = "_1", 
                         rownames(mca_data$var$coord),
                         fixed = TRUE)
      mca_data_filtered <- mca_data
      mca_data_filtered$var$coord <- mca_data_filtered$var$coord[presences, ]
      rownames(mca_data_filtered$var$coord) <-
        gsub(pattern = "_1",
             replacement = "", 
             rownames(mca_data_filtered$var$coord))
    } else {
      mca_data_filtered <- mca_data
    }
    
    plot_ly(x = mca_data_filtered$var$coord[,1], 
            y = mca_data_filtered$var$coord[,2], 
            type = 'scatter', mode = 'markers+text',
            text = rownames(mca_data_filtered$var$coord), textposition = 'top center',
            marker = list(size = 10)) %>%
      layout(title = "MCA variables Plot",
             xaxis = list(title = "Dim 1"),
             yaxis = list(title = "Dim 2"))
  }
  
  ###  Function to generate the MCA observations graph with plotly
  plot_mca_individuals_plotly <- function(mca_data) {
    plot_ly(x = mca_data$ind$coord[,1], y = mca_data$ind$coord[,2], 
            type = 'scatter', mode = 'markers+text',
            text = rownames(mca_data$ind$coord), 
            textposition = 'top center',
            marker = list(size = 10)) %>%
      layout(title = "MCA Observations Plot",
             xaxis = list(title = "Dim 1"),
             yaxis = list(title = "Dim 2"))
  }
  
  #### Observers on server to render MCA graphics
  output$mcaVarPlot <- renderPlotly({
    req(mca_result()) 
    
    if (input$show_var_plot) {
      plot_mca_variables_plotly(mca_result(), 
                                input$show_only_presence)
    }
  })
  
  output$mcaIndPlot <- renderPlotly({
    req(mca_result()) 
    
    if (input$show_ind_plot) {
      plot_mca_individuals_plotly(mca_result())
    }
  })
  
  ## K-means apply
  observeEvent(input$runKmeans, {
    set.seed(input$seed)
    mca_data <- mca_result()
    presencias <- grepl(pattern = "_1", 
                        rownames(mca_data$var$coord), fixed = TRUE)
    km.res <- kmeans(mca_data$var$coord[presencias, ], 
                     centers = input$centers)
    
    ### Show result table
    output$kmeansResults <- renderUI({
      if (showTable()) {
        renderDT({datatable(km.res$centers)})
      }
    })
    
    #### Show cluster plots
    output$fvizClusterUI <- renderUI({
      if (showFvizCluster()) {
        plotOutput("fvizClusterPlot")
      }
    })
    
    output$fvizClusterPlot <- renderPlot({
      if (input$runKmeans > 0) {  
        factoextra::fviz_cluster(km.res,
                                 data = mca_data$var$coord[presencias, ],
                                 asp = 1)
      }
    })
  })
  
  ###  Toggle visualisation
  observeEvent(input$toggleTable, 
               { showTable(!showTable()) })
  observeEvent(input$togglePlot,
               { showPlot(!showPlot()) })
  observeEvent(input$toggleFvizCluster,
               { showFvizCluster(!showFvizCluster()) })
}
      

# Running the application
shinyApp(ui, server)
