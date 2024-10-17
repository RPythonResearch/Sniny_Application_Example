library(shiny)

# Define UI for application
ui <- fluidPage(
      textInput("user_input", "문자열을 입력하세요:", ""),
      textOutput("output_text")
)

# Define server logic 
server <- function(input, output) {
  
  # Render the concatenated text
  output$output_text <- renderText({
    paste("사용자가 아래의 문자열을 입력하셨습니다:", input$user_input)  # Concatenate using paste()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

