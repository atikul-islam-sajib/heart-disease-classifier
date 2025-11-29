library(plotly)

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

plot_parallel("checkpoints/rf_results.csv")
plot_parallel("checkpoints/svm_results.csv")

