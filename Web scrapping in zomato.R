library(rvest)

zom <- read_html("https://www.zomato.com/chennai/copper-kitchen-saligramam/order")

titles <- zom %>% 
  html_nodes(".result-title") %>% 
  html_text()

subzone <- zom %>% 
  html_nodes(".search_result_subzone") %>% 
  html_text()

cost <- zom %>% 
  html_nodes(".res-cost") %>% 
  html_text()

cost <- str_replace(cost,"Cost for two:\u20b9",""
)


bakeries <- as.data.frame(cbind(titles, subzone, cost))

hist(as.numeric(bakeries$cost))
