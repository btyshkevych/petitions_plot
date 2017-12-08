
# What do Kyiv dwellers demand from Kyiv City Council?
# Shiny app for analysis of petitions applied to Kyiv City Council
# Build a user interface

library(shiny)
library(ggvis)
library(dplyr)

fluidPage(
  titlePanel("Що вимагають кияни в Київської міської ради?"),
  #theme = shinythemes::shinytheme("sandstone"),
  # Sidebar with plugins
  sidebarLayout(
    sidebarPanel(width = 3,
                 dateRangeInput("dates", label = h4("Оберіть період"), start = "2015-10-08", end = "2017-12-02"),
                 selectInput("ended", label = h4("Чи завершений збір підписів?"), choices = c("Всі", "Завершений", "Триває"), selected = "Всі"),
                 sliderInput("signatures", label = h4("Визначте поріг кількості \n підписів"), min = 1, max = 21000, value = 1, round = TRUE),
                 checkboxGroupInput("category", label = h4("Оберіть категорії"), 
                                    choices = c("Благоустрій, довкілля, тварини", "Дорожнє господарство та паркування",
                                                "Житлово-комунальна інфраструктура та відходи",
                                                "МАФи та стихійна торгівля", "Містобудування", "Перейменування вулиць", 
                                                "Соціальна сфера (освіта, охорона здоров’я, соц. захист та ін.)", "Транспорт",
                                                "Інше"),
                                    selected = c("Благоустрій, довкілля, тварини", "Дорожнє господарство та паркування",
                                                 "Житлово-комунальна інфраструктура та відходи",
                                                 "МАФи та стихійна торгівля", "Містобудування", "Перейменування вулиць", 
                                                 "Соціальна сфера (освіта, охорона здоров’я, соц. захист та ін.)", "Транспорт",
                                                 "Інше")
                 )
    ),
    
    # Show the plot and the text output
    mainPanel(width = 9,
              ggvisOutput("pet_plot_output"),
              wellPanel(
                strong("Наведіть курсор на позначення щоб переглянути назви петицій."),
                span(h5("Кількість відібраних петицій:", textOutput("n_pet"))),
                span(h5("Середня кількість підписів, що припадає на петицію:", textOutput("sig_mean"))),
                span(h5("Частка успішних, %:", textOutput("succ_mean")))
                ),
              h5("Дані актуальні на 2 грудня 2017 року. У базі 4479 петицій."),
              span("Дані: ", a("petition.kievcity.gov.ua", href = "https://petition.kievcity.gov.ua/petitions/", target="_blank"),
                   " | ", "Візуалізація: ",  a("Богдан Тишкевич", href = "https://www.facebook.com/b.tyshkevych", target="_blank"),
                   " | ", "Код: ", a("GitHub", href = "https://github.com", target="_blank")),
              h5(" "),
              align = "left")
  )
)
