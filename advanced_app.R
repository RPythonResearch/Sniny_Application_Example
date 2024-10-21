################################################################################
## API Data download function
################################################################################

library(rjson)
library(httr)

# API 데이터를 다운로드하는 함수
download_api_data <- function() {
  base_url <- "http://apis.data.go.kr/B551172/getDiagnosisRemoteCancerous"
  call_url <- "AllCancerRemoteOccurrenceTrend"
  method <- "GET"
  
  My_API_Key <- "wqdX2OnQY29zYQ7BXsGafDqVNaIbIYUoqAqS1bOeK6/yyqdukiVcRcj25wue+U8tqSaSXThVPwfaWDNpUc6cwQ=="  # 실제 API 키
  params <- list(
    serviceKey = My_API_Key,  # 실제 API 키로 변경
    pageNo = 1,
    numOfRows = 10,
    resultType = "json"
  )
  
  url <- paste0(base_url, "/", call_url)
  response <- GET(url, query = params)
  
  if (status_code(response) == 200) {
    json_text <- content(response, as = "text")
    data <- fromJSON(json_text)
    return(data)
  } else {
    print(paste("API 호출 실패:", status_code(response)))
    return(NULL)
  }
}

################################################################################
## ShinyApp
################################################################################

library(shiny)
library(ggplot2)

# Define UI for the application
ui <- fluidPage(
  
  # Application title
  titlePanel("API Data Visualization with ShinyApp"),
  
  # Sidebar layout
  sidebarLayout(
    sidebarPanel(
      # Dropdown to select Y axis variable
      selectInput("y_var", 
                  "Choose Y-axis Variable:", 
                  choices = c("TOTAL", "VALUE"),
                  selected = "TOTAL")  # Default to TOTAL
    ),
    
    # Main panel to display the plot
    mainPanel(
      plotOutput("yearPlot")
    )
  )
)

# Define server logic to create the plot based on user selection
server <- function(input, output, session) {
  
  # Timer to trigger API call every hour (3600000 milliseconds = 1 hour)
  autoInvalidate <- reactiveTimer(3600000)  # 1시간마다 갱신
  
  # Reactive expression to get the API data
  api_data <- reactive({
    # Trigger the reactiveTimer
    autoInvalidate()
    
    # Call the API and retrieve data
    data <- download_api_data()
    
    # If data is available, convert to a data frame
    if (!is.null(data)) {
      data_list <- data$items  # 적절한 필드로 접근 (예시)
      df <- as.data.frame(do.call(rbind, lapply(data_list, as.data.frame)))
      return(df)
    } else {
      return(NULL)  # API 호출 실패 시 NULL 반환
    }
  })
  
  # Render the plot based on user selection
  output$yearPlot <- renderPlot({
    df <- api_data()  # Reactive API 데이터 호출
    
    # df가 NULL이 아닐 경우에만 플롯을 그리도록 처리
    if (!is.null(df)) {
      ggplot(data = df, aes(x = YEAR, y = .data[[input$y_var]])) +
        geom_point() +
        labs(x = "Year", y = input$y_var)
    } else {
      # 데이터가 없을 경우, 메시지 출력
      plot(0, 0, type = "n", xlab = "", ylab = "", main = "API 데이터가 없습니다.")
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
