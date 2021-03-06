
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyjs)
library(shinydashboard)
library(DT)
library(dygraphs)
library(shinyBS)

# read external js 
fileName <- "shinyjsSeg.js"
# readLines import file asynchronously and fails shinyjs
# jsCode <- paste(readLines("./shinyjsSeg.js"), collapse=" ")
jsCode <- readChar(fileName, file.info(fileName)$size)
fileName2 <- "shinyjsBi.js"
jsCode2 <- readChar(fileName2, file.info(fileName2)$size)

dashboardPage(
  dashboardHeader(title = "Analysis Dashboard"),
  dashboardSidebar(
    # change dashboard sidebar appearance
    shinyjs::inlineCSS(list(
      ".sidebar-menu>li" = "font-size: 18px",
      ".sidebar-menu>li>a>.fa" = "width: 30px"
    )),
    sidebarMenu(
      menuItem("Import", tabName = "import", icon = icon("file-o")),
      menuItem("Plotting", tabName = "plotting", icon = icon("bar-chart")),
      menuItem("Pre-processing", tabName = "preprocessing", icon = icon("cogs")),
      menuItem("Segmentation", tabName = "segmentation", icon = icon("columns")),
      menuItem("Biclustering", tabName = "biclustering", icon = icon("th")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  dashboardBody(
    # import js
    tags$head(includeScript("html2canvas.js")),
    # tags$head(includeScript("download.js")),
    useShinyjs(),
    # extend js
    extendShinyjs(text = jsCode, functions = c("updateSeg", "prevSeg", "nextSeg", "showSeg", "saveSeg")),
    extendShinyjs(text = jsCode2, functions = c("updateBi", "prevBi", "nextBi", "showBi", "saveBi")),
    
    # import global css
    shinyjs::inlineCSS(list(
      ".shiny-progress .progress" = "height:10px !important;"
    )),
    
    
    tabItems(

      ######################################################
      ###################### import  ######################
      #####################################################
      tabItem(

        tabName = "import",
        fluidRow(
        
          box(
            width = 12,
            title = "Upload",
            fluidRow(
              box(
                width = 3,
                radioButtons('sep', 'Separator',
                             c(Comma=',',
                               Semicolon=';',
                               Tab='\t'),
                             ',')
              ),
              box(
                width = 3,
                radioButtons('quote', 'Quote',
                             c(None='',
                               'Double Quote'='"',
                               'Single Quote'="'"),
                             '"')
              ),
              box(
                width = 3,
                checkboxInput('header', 'Header', TRUE)
                
              )
              
            ),
            
            fluidRow(
              box(
                width = 12,
                uiOutput('fileImport')
                # fileInput('file1', 'Choose CSV File',
                #           accept=c('text/csv',
                #                    'text/comma-separated-values,text/plain',
                #                    '.csv'))
              )
            )
          ),
          
          
          
          # allow x-flow for DT:dataTable
          shinyjs::inlineCSS(list(
            ".dataTables_wrapper" = "overflow-x: scroll; overflow-y: hidden"
          )),
          
          
          tabBox(
            width = 12,
            tabPanel("Raw Data", uiOutput("rawTable")),
            tabPanel("Summary", verbatimTextOutput("rawSummary"))
          )
        
         
        )
      ),
      # </import>


      ######################################################
      ###################### plotting ######################
      ######################################################
      tabItem(
        tabName = 'plotting',
        fluidRow(
          box(
            width = 8,
            title = "Options",
            selectInput('plotX', 'X Varaible', choices = c('Please select a dataset'), multiple = F),
            selectInput('plotY', 'Y Varaible(s)', choices = c('Please select a dataset'), multiple = T)
            
          ),
          
          tabBox(
            width = 12,
            tabPanel("Plot", dygraphOutput("plot"))
            ,tabPanel("Multi-plot", uiOutput("mulplot"))
            ,tabPanel("Correlation", uiOutput("corplot"))
            
          )
          
        )
        
      ),
      #</plotting>
      

      ######################################################
      ###################### preprocessing ######################
      ######################################################
      tabItem(
        tabName = 'preprocessing',
        fluidRow(
          shinyjs::inlineCSS(list(
            "#shiny-tab-preprocessing .goButton" = "position: absolute; right:10px; bottom: 20px"
          )),
          
          box(
            width = 4,
            height = "200px",
            title = "Excludes",
            # selectInput('excludings', 'Value Range', choices = c('Please select a dataset'), multiple = T)
            selectInput('excludingVar', 'Exclude variable(s)', choices = c('Please select a dataset'), multiple = T),
            actionButton('goExcludingVar', 'Go', class="goButton", icon = icon("arrow-circle-right")),
            bsModal("popExcludingVar", "Excludes", "goExcludingVar", size = "small", uiOutput("uiExcludingVar"))
            
          ),

          
          box(
            width = 4,
            height = "200px",
            title = "Outlier Removal",
            selectInput('outlierRemoval', 'Select a variable', choices = c('Please select a dataset'), multiple = F),
            actionButton('goOutlierRemoval', 'Go', class="goButton", icon = icon("arrow-circle-right")),
            bsModal("popOutlierRemoval", "Outlier Removal", "goOutlierRemoval", size = "large",uiOutput("uiOutlierRemoval"))
          ),
          
          
          
          box(
            width = 4,
            height = "200px",
            title = "Normalization",
            # checkboxInput('normalizing', 'Normalizing', FALSE),
            radioButtons('normalizing', 'Normalization',c('ON'=T,'OFF'=F),T)
            ,
            actionButton('goNormalizing', 'Go', class="goButton", icon = icon("arrow-circle-right"))
          ),
          
          box(
            width = 8,
            height = "210px",
            title = "Conditions",
            fluidRow(
              column(4,selectInput('variableCon', 'If', choices = c('.'), multiple = F)),
              column(4,selectInput('equalCon', '.', choices = c('==','>=','<=','>','<'), multiple = F)),
              column(4,numericInput('numberCon', label='.', value=0))
            ),
            fluidRow(
              column(4,selectInput('actionCon', 'Then', choices = c('Remove line','Replace with'), multiple = F)),
              
              conditionalPanel("input.actionCon == 'Replace with'",
                               column(4,numericInput('replaceCon', label='.', value=0))
              ),
              column(3, 
                style="padding-top:30px; font-weight: bold",
                textOutput('rowSelected'))
            ),

            actionButton('goConditions', 'Go', class="goButton", icon = icon("arrow-circle-right"))
          ),
          
          tabBox(
            width = 12,
            # tabPanel("Data Table", tableOutput("table"))
            tabPanel("Pre-processed Data", DT::dataTableOutput('inputTable')),
            tabPanel("Summary", verbatimTextOutput("inputSummary")),
            tabPanel(tagList(shiny::icon("download"), "Save"), 
                      div(
                        style="text-align:center; padding:30px",
                        downloadButton("processedDataset", label = "Download pre-processed data table (.CSV)")
                      )
                    )
          )
          
          
        )
      ),
      # </preprocessing>
      

      ######################################################
      ###################### segmentation ###################
      #####################################################
      tabItem(
        tabName = 'segmentation',
        
        fluidRow(  
          uiOutput('segIndTabs'),
          
          box(
            width = 4,
            column(6,
              style="padding-left:0",
              numericInput('segMinWindowSize', label="Minimum Window Size", value=2, min = 2)
            ),
            column(6,
              numericInput('segMaxWindowSize', label="Maximum Window Size", value=500, min = 2)
              )
            ),

          box(
            width = 4,
            selectInput('segIndVars', 'Individual Setting', choices = c('Please select a dataset'), multiple = T)
            ,
            icon("info-circle"),"Create an individual setting tab for each variable selected."
          ),
          box(
            width = 4,
            numericInput('segThrottle', label="Minimum Segment Size", value=2)
            ,
            icon("info-circle"),"Shorter segments will be merged."
          ),
              
          
          box(
            width = 4,
            # tableOutput("segpars2")
            # ,
            
            bsButton('segButton', label = 'Start', style="primary")
            ,

            div(
              style="float:right",
              downloadButton("segresultSave", label = "Save Segments"),
              bsButton('segresultImport', label = 'Using Saved Segments', icon = icon("upload"), type="toggle")

            )
            ,
            conditionalPanel("input.segresultImport",
              div(
                style="margin-top:2em",

                fileInput('segresultImportFile', 'Choose CSV File', accept=c('text/csv','text/comma-separated-values,text/plain','.csv')),
                tags$script('$( "#segresultImportFile" ).on( "click", function() { this.value = null; });')
              )
            )
          ),

          # Plot
          box(
            width = 12,
            
            div(
              class="box-header",
              h3(
                class="box-title", 
                style="padding-right: 10px",
                'Plots'
              ),
              bsButton("segPrev", label = "", icon = icon("arrow-left")),
              bsButton("segNext", label = "", icon = icon("arrow-right")),
              actionButton("segSave", label = "Save", icon = icon("download"))
            ),
            
            # tabPanel('Now',
            shinyjs::inlineCSS(list(
              "#segHistory .segPiece" = "background: #fff"
            )),
            
            # div(
            #   id = "segProgress",
            #   width = 12
            #   
            # ),
            
            div(
              id = "segHistory",
              width = 12,
              div(
                id="segLatest",
                tableOutput("segpars"),
                uiOutput("segplot")
                
              )
            )
          )
        )
      ),
      #</segmentation>
      
      
      ######################################################
      ###################### biclustering ##################
      ######################################################
      tabItem(
        tabName = 'biclustering',
        
        fluidRow(  
          tabBox(
            id = "biFunctions",
            width = 8,
            tabPanel(
              "Baseline",
              fluidRow(
                box(
                  width = 12,
                  column(12,
                    checkboxInput('baselineBiSeg', 'Segmentation', FALSE)
                  ),
                  column(12,
                    selectInput('baselineBiMethod', 'Method', choices = c('BCCC','BCBimax'
                      # , 'BCrepBimax'
                      ), multiple = F)
                  ),
                  conditionalPanel(
                    'input.baselineBiMethod == "BCCC"',
                    column(4,
                      numericInput('baselineBiBCCCDelta', label="Delta", value=0.0001)
                    ),
                    column(4,
                      numericInput('baselineBiBCCCAlpha', label="Alpha", value=1)
                    ),
                    column(4,
                      numericInput('baselineBiBCCCK', label="K", value=1)
                    )
                  ),
                  conditionalPanel(
                    'input.baselineBiMethod == "BCBimax"',
                    column(4,
                      numericInput('baselineBiBCBimaxMinr', label="Minr", value=2)
                    ),
                    column(4,
                      numericInput('baselineBiBCBimaxMinc', label="Minc", value=2)
                    ),
                    column(4,
                      numericInput('baselineBiBCBimaxK', label="K", value=100)
                    )
                  )
                  # ,
                  # conditionalPanel(
                  #   'input.baselineBiMethod == "BCrepBimax"',
                  #   column(3,
                  #     numericInput('baselineBiMinr', label="Minr", value=2)
                  #   ),
                  #   column(3,
                  #     numericInput('baselineBiMinc', label="Minc", value=2)
                  #   ),
                  #   column(3,
                  #     numericInput('baselineBiMaxc', label="Maxc", value=12)
                  #   ),
                  #   column(3,
                  #     numericInput('baselineBiK', label="K", value=100)
                  #   )
                  # )
                  
                  
                )
              )
            )
            
            # ,
            # tabPanel(
            #   "PDF",
            #   fluidRow(
            #     box(
            #       width = 12,
            #       column(12,
            #         checkboxInput('PDFBiSeg', 'Segmentation', TRUE),
            #         tags$script(
            #           '$("#PDFBiSeg").attr("disabled", true)'
            #         )
            #       ),
            #       column(6,
            #         # sliderInput('PDFBiDelta', "Delta",
            #                    # min = 0, max = 1, value = 0.01)
            #         numericInput('PDFBiDelta', label="Delta", value=0.01),
            #         bsTooltip("PDFBiDelta", "Delta should be between (0,1).",
            #                   "bottom")
            #       ),
            #       column(6,
            #         numericInput('PDFBiK', label="K", value=10)
            #       )
            #     )
            #   )
            # )

            ,
            tabPanel(
              "BiclusTS",
              fluidRow(
                box(
                  width = 12,
                  column(12,
                    checkboxInput('LSDDBiSeg', 'Segmentation', TRUE),
                    tags$script(
                      '$("#LSDDBiSeg").attr("disabled", true)'
                    )
                  ),
                  column(6,
                    numericInput('LSDDBiDelta', label="Delta", value=0.001),
                    bsTooltip("LSDDBiDelta", "Delta should be between (0,1).",
                              "bottom", options = list(container = "body"))
                  ),
                  column(6,
                    numericInput('LSDDBiK', label="K", value=1)
                  )
                )
              )
            )
          ),

          box(
            width = 4,
            bsButton('biButton', label = 'Start', style="primary")
          ),
          
          # Plot
          box(
            width = 12,
            
            div(
              class="box-header",
              h3(
                class="box-title", 
                style="padding-right: 10px",
                'Plots'
              ),
              actionButton("biPrev", label = "", icon = icon("arrow-left")),
              actionButton("biNext", label = "", icon = icon("arrow-right")),
              # the popup is defined in shinyjsBi.js
              actionButton("biSave", label = "Save", icon = icon("download")),
                    
              column(4,
                    style="float:right",
                    selectInput('biclusterSelector', 'Select bicluster(s)', choices = c("Please biclustering"), multiple = T)
              )
            ),
            
            # tabPanel('Now',
            div(
              
              shinyjs::inlineCSS(list(
                "#biHistory" = "background: #fff",
                "#biHistory .biPiece" = "background: #fff",
                "#biHistory .biPiece>img" = "float: right; ",
                "#biHistory #biDensity" = "float: right;"
              )),
              
              id = "biHistory",
              width = 12,
              div(
                id="biLatest",
                tableOutput("bipars"),
                # uiOutput("biplot"),
                uiOutput("biGraph")
              )
            )
          )
        )
      ),
      #</biclustering>
      
      tabItem(
        tabName = 'about',
        
        fluidRow(  
          box(
            title = "About",
            width = 12,
            HTML('<p>Analysis Dashboard aims to provide toolkits to explore datasets in a visualized way, especially for time-series datasets. It includes dataset uploading, plotting, pre-processing, segmentation and biclustering, which offer handy access of different methods and parameters applied to your data.</p>'),
            HTML('<p>Author: Ricardo Cachucho <a href="mailto:r.cachucho@liacs.leidenuniv.nl">r.cachucho@liacs.leidenuniv.nl</a>, Kaihua liu <a href="mailto:k.liu.5@umail.leidenuniv.nl">k.liu.5@umail.leidenuniv.nl</a></p>')
          )
        )
      )
      #</about>
      
    )
  )
)
