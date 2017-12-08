# What do Kyiv dwellers demand from Kyiv City Council?
# Shiny app for analysis of petitions applied to Kyiv City Council
# Build a server function

library(shiny)
library(ggvis)
library(dplyr)

# Upload data in the app
pet_df <- read.csv("Pet_data.csv", header = TRUE, stringsAsFactors = FALSE, encoding = "UTF-8")
pet_df$Дата <- as.Date(pet_df$Дата)
pet_df$id <- c(1:nrow(pet_df))

# Replicate a column for visualisation (factor) and analysis (logical)
pet_df$Успішна <- pet_df$Успішна_лог

# Due to ggvis issue #303 create factor for logical variable
pet_df$Успішна[pet_df$Успішна == TRUE] <- "Так"
pet_df$Успішна[pet_df$Успішна == FALSE] <- "Ні"
pet_df$Успішна <- as.factor(pet_df$Успішна)

# Rename values
pet_df$Завершена[pet_df$Завершена == TRUE] <- "Завершений"
pet_df$Завершена[pet_df$Завершена == FALSE] <- "Триває"

# Server function
server <- function(input, output, session) {
  
  
  # Define a reactive expression to filter data
  pet_filt_reactive <- reactive({
    
    # Assign temporary variables to inputs due dplyr issue #318
    signatures_temp <- input$signatures
    category_temp <- input$category
    mindate_temp <- input$dates[1]
    maxdate_temp <- input$dates[2]
    
    # Apply a dplyr's filter
    pet <- pet_df %>% filter(Підписів >= signatures_temp & Дата >= mindate_temp &
                                       Дата <= maxdate_temp & Категорія %in% category_temp)
    
    # Filter for select input
    if (input$ended != "Всі") {
      ended <- input$ended
      pet <- pet %>% filter(Завершена %in% ended)}
    
    pet <- as.data.frame(pet)
    
  })
  
  
  # Function for generating a tooltip text
  pet_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$id)) return(NULL)
    
    pet_df <- isolate(pet_filt_reactive())
    petition <- pet_df[pet_df$id == x$id, ]
    paste0("<b>", petition$Назва, "</b><br>",
           "Дата подачі: ", petition$Дата, "<br>",
           "Кількість підписів: ", petition$Підписів)
  }
  
  
  # Define a reactive expression to plot data
  pet_plot <- reactive({
    
    pet_filt_reactive %>% 
      ggvis(~Дата, ~Підписів) %>% 
      layer_points(size := 40, #size.hover := 100, 
                   opacity := 0.6, #opacity.hover := 1,
                   fill = ~Категорія, shape = ~Успішна, key := ~id) %>%
      add_tooltip(pet_tooltip, "hover") %>%
      add_axis("x", title = "Дата подачі") %>%
      add_axis("y", title = "Кількість підписів", title_offset = 60) %>%
      add_legend("fill", title = "Категорії петицій", properties = legend_props(legend = list(y = 50))) %>%
      set_options(width = 975, height = 494) %>%
      set_options(duration = 0)
    
  })
  
  # Connect with shiny
  bind_shiny(pet_plot, "pet_plot_output")
  
  # Get a number of petitions
  output$n_pet <- renderText({ nrow(pet_filt_reactive()) })
  output$sig_mean <- renderText({ format(mean(pet_filt_reactive()$Підписів), trim = TRUE, digits = 6) })
  output$succ_mean <- renderText({ format(mean(pet_filt_reactive()$Успішна_лог)*100, trim = TRUE, digits = 3) })
}
