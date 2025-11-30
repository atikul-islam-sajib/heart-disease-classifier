library(plotly)
library(htmlwidgets)

plot_parallel <- function(csv_path) {
  
  df <- read.csv(csv_path)
  
  df_numeric <- df[, sapply(df, is.numeric)]
  
  plot_ly(
    type = 'parcoords',
    line = list(color = df_numeric$ROC),
    dimensions = lapply(names(df_numeric), function(name) {
      list(label = name, values = df_numeric[[name]])
    })
  )
}

p_rf  <- plot_parallel("checkpoints/rf_results.csv")
p_svm <- plot_parallel("checkpoints/svm_results.csv")

saveWidget(p_rf,  "checkpoints/RF_parameter_tuning.html",  selfcontained = FALSE)
saveWidget(p_svm, "checkpoints/SVM_parameter_tuning.html", selfcontained = FALSE)


