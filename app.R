library(shiny)
library(readr)
library(caret)

##############################################
#           Load final SVM model 
##############################################
svm_model <- readRDS("../checkpoints/model_svm.rds")

##############################################
#   Load scaler used during preprocessing 
##############################################
scaler <- readRDS("../checkpoints/scaler.rds")

##############################################
#     Numeric columns used during scaling
##############################################
num_cols <- c("Age", "RestingBP", "Cholesterol",
              "FastingBS", "MaxHR", "Oldpeak")

#################################################################
#               User Interface
#           ---------------------
#           1. Create the dataframe from user's input
#           2. Apply same scaling used during training
#           3. Predict probability + Predict class(0/1)
#           4. Finally display the output
#################################################################
ui <- fluidPage(
  titlePanel("Heart Disease Prediction"),
  
  numericInput("Age", "Age", value = 50),
  numericInput("RestingBP", "Resting BP", value = 120),
  numericInput("Cholesterol", "Cholesterol", value = 200),
  numericInput("FastingBS", "Fasting Blood Sugar", value = 0),
  numericInput("MaxHR", "Max Heart Rate", value = 150),
  numericInput("Oldpeak", "Oldpeak", value = 1.0),
  
  selectInput("Sex", "Sex", c("M", "F")),
  selectInput("ChestPainType", "Chest Pain Type", 
              c("ATA", "NAP", "ASY", "TA")),
  selectInput("RestingECG", "Resting ECG", 
              c("Normal", "ST", "LVH")),
  selectInput("ExerciseAngina", "Exercise Angina", 
              c("N", "Y")),
  selectInput("ST_Slope", "ST Slope", 
              c("Up", "Flat", "Down")),
  
  actionButton("predict_btn", "Predict"),
  
  hr(),
  h3("Prediction:"),
  textOutput("pred_class"),
  textOutput("pred_prob")
)

# SERVER
server <- function(input, output) {
  
  observeEvent(input$predict_btn, {
    
    # Build one-row dataframe from user input
    newdata <- data.frame(
      Age = input$Age,
      RestingBP = input$RestingBP,
      Cholesterol = input$Cholesterol,
      FastingBS = input$FastingBS,
      MaxHR = input$MaxHR,
      Oldpeak = input$Oldpeak,
      Sex = factor(input$Sex),
      ChestPainType = factor(input$ChestPainType),
      RestingECG = factor(input$RestingECG),
      ExerciseAngina = factor(input$ExerciseAngina),
      ST_Slope = factor(input$ST_Slope)
    )
    
    # Apply same scaling used during training
    newdata[, num_cols] <- predict(scaler, newdata[, num_cols])
    
    # Predict probability
    pred_prob <- predict(svm_model, newdata, type = "prob")[, "Yes"]
    
    # Predict class
    pred_class <- ifelse(pred_prob > 0.5, "Yes", "No")
    
    # Display outputs
    output$pred_class <- renderText(
      paste("Heart Disease:", pred_class)
    )
    output$pred_prob <- renderText(
      paste("Probability of Yes:", round(pred_prob, 3))
    )
  })
}

shinyApp(ui, server)
