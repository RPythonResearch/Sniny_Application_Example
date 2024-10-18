################################################################################
## API Data download
################################################################################

library(rjson)
library(httr)

# API 호출 정보 설정
base_url <- "http://apis.data.go.kr/B551172/getDiagnosisRemoteCancerous"
call_url <- "AllCancerRemoteOccurrenceTrend"
method <- "GET"

My_API_Key <- "wqdX2OnQY29zYQ7BXsGafDqVNaIbIYUoqAqS1bOeK6/yyqdukiVcRcj25wue+U8tqSaSXThVPwfaWDNpUc6cwQ=="
# 요청 파라미터 설정
params <- list(
  serviceKey = My_API_Key,  # 실제 API 키로 변경
  pageNo = 1,
  numOfRows = 10,
  resultType = "json"
)

# API 호출
url <- paste0(base_url, "/", call_url)
response <- GET(url, query = params)

# 응답 상태 확인
# if (http_status(response) == 200)
if (status_code(response) == 200)  {
  # JSON 데이터 파싱
  print(response)
  str(response)
  
} else {
  print(paste("API 호출 실패:", status_code(response)))
}

json_text <- content(response, as = "text")
print(json_text)
print("------------------")

data <- fromJSON(json_text)
print(data)

# 예시: 리스트 내부에 있는 항목을 추출하여 데이터프레임으로 변환
data_list <- data$items  # 적절한 필드로 접근

# 데이터프레임으로 변환
df <- as.data.frame(do.call(rbind, lapply(data_list, as.data.frame)))


################################################################################
## ShinyApp
################################################################################

library(shiny)
library(ggplot2)

# Define UI for the application
ui <- fluidPage(

  # Application title
  titlePanel("API Data Vizualization with ShinyApp"),
  
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
server <- function(input, output) {
  
  # Render the plot
  output$yearPlot <- renderPlot({
    
    # Plot using the selected Y variable
    ggplot(data = df, aes(x = YEAR, y = .data[[input$y_var]])) +
      geom_point() +
      labs(x = "Year", y = input$y_var)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
