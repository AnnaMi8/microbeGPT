# Specific library
library(UpSetR)

# Data is taken from excel file used for pipeline performance analysis.
input <- c(
  Reformulated_questions = 13,
  Redefined_joins = 10,
  Fewshots_prompting = 9,
  "Reformulated_questions&Fewshots_prompting" = 16,
  "Fewshots_prompting&Redefined_joins" = 10,
  "Reformulated_questions&Redefined_joins" = 14,
  "Reformulated_questions&Redefined_joins&Fewshots_prompting" = 16
)

bar_colors <- c( "#66B3FF", "#FF6347", "#8A2BE2")


pdf(file="upset_p.pdf", onefile=FALSE,width= 10 , height=6.5) # or other device
upset(fromExpression(input), 
      nintersects = 7, 
      nsets = 3,
      order.by = "freq", 
      decreasing = T, 
      mb.ratio = c(0.6, 0.4),
      number.angles = 0, 
      text.scale = 1.5, 
      point.size = 2.8, 
      line.size = 1,
      sets.bar.color = bar_colors,
      queries = list(list(query = intersects, params = list("Reformulated_questions"), color= "#66B3FF"),
                     list(query = intersects, params = list("Fewshots_prompting"), color= "#FF6347"),
                     list(query = intersects, params = list("Redefined_joins"), color= "#8A2BE2")))
dev.off()