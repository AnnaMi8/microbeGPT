# define functions and calculate score from 'answers_Tx' files
compare_with_correct_answers <- function(df_T0) {
  correct_answers <- c(
    "(5.146803216038514,)",
    "(4.749735057239966,)",
    "(171,)",
    "(14389,)",
    "(96, 3)",
    "(Decimal('75.7743072598277632'),)",
    "(0.057196901764991016,)",
    "(0.0, 0.69456)",
    "('Bacteroides vulgatus', 63250.54)",
    "(0.10249751144261383,)",
    "('Escherichia coli', 37212.05)",
    "(0.44065684167540625,)",
    "(1023,)",
    "(1,)",
    "('Firmicutes', 535922.6)",
    "(0.11537600260030743,)",
    "(8022, 54)",
    "(2967,)",
    "(0.005528159512230005,)",
    "('Bacteroidaceae', 282596.5)"
  )
  
  result_df <- data.frame(matrix(NA, nrow(df_T0), ncol(df_T0)))
  colnames(result_df) <- colnames(df_T0)
  
  # Copy the first column directly from df_T0 to result_df
  result_df[, 1] <- df_T0[, 1]
  
  # Loop through the remaining columns (starting from the second column)
  for (i in 2:ncol(df_T0)) {
    temp_col <- df_T0[, i]
    result_list <- ifelse(as.character(correct_answers) == as.character(temp_col), 1, 0)
    result_df[, i] <- result_list
  }
  
  # Transpose the data frame
  result_df <- t(result_df)
  # Set the first row as column names
  colnames(result_df) <- result_df[1, ]
  # Remove the first row (which now contains column names)
  result_df <- result_df[-1, ] 
  return(result_df)
}


calculate_score <- function(dataframe) {
  count_ones <- numeric(ncol(dataframe))
  # Loop through each column
  for (i in 1:ncol(dataframe)) {
    temp_col <- dataframe[, i]
    count_ones[i] <- sum(temp_col == 1)
  }
  # Divide each count by 10
  count_divided <- count_ones / 10
  # Calculate the percentage
  percentage <- count_divided * 100
  return(percentage)  # Return percentages for each column
}


### Load T0
df_T0 <- read.delim('../GPT_pipeline/3T_variance_postgres/answers_T0.txt', header = FALSE, stringsAsFactors = FALSE, quote = "", sep = "\t")
T0_df <- compare_with_correct_answers(df_T0)
T0_score <- calculate_score(T0_df)

### Load T05
df_T05 <- read.delim('../GPT_pipeline/3T_variance_postgres//answers_T05.txt', header = FALSE, stringsAsFactors = FALSE, quote = "", sep = "\t")
T05_df <- compare_with_correct_answers(df_T05)
T05_score <- calculate_score(T05_df)

### Load T07
df_T07 <- read.delim('../GPT_pipeline/3T_variance_postgres//answers_T07.txt', header = FALSE, stringsAsFactors = FALSE, quote = "", sep = "\t")
T07_df <- compare_with_correct_answers(df_T07)
T07_score <- calculate_score(T07_df)

### Load T1
df_T1 <- read.delim('../GPT_pipeline/3T_variance_postgres//answers_T1.txt', header = FALSE, stringsAsFactors = FALSE, quote = "", sep = "\t")
T1_df <- compare_with_correct_answers(df_T1)
T1_score <- calculate_score(T1_df)


#--------------------------------------------------------------------------------------------
# Create dataframe with calculated scores and produce heatmap plot

library(ComplexHeatmap) 

df <- data.frame(
  question_id = as.factor(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)),
  "T 0.0" = T0_score,
  "T 0.5" = T05_score,
  "T 0.7" = T07_score,
  "T 1.0" = T1_score
)

rownames(df) <- df$question_id
df <- df[, -1] 
data <- as.matrix(df)
rownames(data) = paste("Question ", 1:20, sep = "")
colnames(data) = c("T 0.0","T 0.5", "T 0.7","T 1.0")
data <- as.matrix(data)


question_id_complexity <- data.frame(complexity = c("Simple", "Simple", "Simple", "Simple", "Simple", "Difficult", "Difficult", "Difficult", "Difficult", "Difficult", "Difficult", "Difficult", "Difficult", "Simple", "Simple", "Difficult", "Simple", "Simple", "Difficult", "Simple"))
rownames(question_id_complexity) = paste("Question ", 1:20, sep = "")
my_colors <- colorRampPalette(c("#440154", "#3b528b","#21918c","#5ec962", "#fde725"))(10)

category_colour = list(
  Complexity = c("Difficult" ="#575A5E", "Simple" = "#A7A2A9" )
)

row_ha <-  rowAnnotation(Complexity = question_id_complexity$complexity,
                         col = category_colour,
                         gp = gpar(col = "white")
)

postgres_heatmap <- Heatmap(data, name = "Correct answers (%)",
                            cluster_rows = FALSE,
                            cluster_columns = FALSE,
                            right_annotation = row_ha,
                            col = my_colors,
                            rect_gp = gpar(col = "white", lwd = 1),
                            width = unit(8, "cm"),
                            height = unit(12, "cm"),
                            column_title_rot = 90,
                            cell_fun = function(j, i, x, y, width, height, fill)
                            {
                              grid.text(sprintf("%.0f", data[i, j]),
                                        x, y, gp = gpar(fontsize = 10, col = "white"))
                            })
postgres_heatmap

# save picture
pdf(file="./postgres_3t.pdf", width=6.5, height=6)
draw(postgres_heatmap)
dev.off()


#--------------------------------------------------------------------------------------------------------------------------
#calculate statistics
# Melt the dataframe into three columns: question, condition, and value
library(reshape2)
melted_df <- melt(data, id.vars = "row.names", variable.name = "condition", value.name = "value")
colnames(melted_df) <- c("question", "condition", "value")

# Apply the Wilcoxon signed-rank test for T 0.0 vs T 0.5
#result_t_0_0_vs_t_0_5 <- wilcox.test(melted_df$value[melted_df$condition == "T 0.0"],
#                                     melted_df$value[melted_df$condition == "T 0.5"],
#                                     paired = TRUE)



# Create a subset of the data with only T0.0, T0.5, T0.7, and T1.0 columns
subset_data <- melted_df[melted_df$condition %in% c("T 0.0", "T 0.5", "T 0.7", "T 1.0"), ]

# Get unique conditions
unique_conditions <- unique(subset_data$condition)

# Initialize an empty list to store results
results_list <- list()

# Perform Wilcoxon signed-rank test for all pairs of conditions
for (i in 1:(length(unique_conditions) - 1)) {
  for (j in (i + 1):length(unique_conditions)) {
    condition1 <- unique_conditions[i]
    condition2 <- unique_conditions[j]
    subset1 <- subset_data[subset_data$condition == condition1, 'value']
    subset2 <- subset_data[subset_data$condition == condition2, 'value']
    result <- wilcox.test(subset1, subset2, paired = TRUE)
    results_list[[paste(condition1, "vs", condition2)]] <- result
  }
}

# Print the results
for (pair in names(results_list)) {
  cat(pair, ":\n")
  cat("Statistic:", results_list[[pair]]$statistic, "\n")
  cat("P-value:", results_list[[pair]]$p.value, "\n\n")
}


# Create a dataframe to store pairs and p-values
p_value_df <- data.frame(
  Pair = names(results_list),
  P_Value = sapply(results_list, function(x) x$p.value)
)
# Create a bar plot to visualize p-values
stat_plot <- ggplot(p_value_df) +
  geom_bar( aes(x=Pair, y=P_Value), stat= 'identity', alpha=0.7 , fill = "#9778A5") +
  geom_hline(yintercept = 0.05,color = "black", linetype = "dashed")+
  annotate("text", x = "T 0.7 vs T 1.0", y = 0.09, label = "α = 0.05", color = 'black')+
  theme_minimal()+
  theme(axis.text.x=element_text(angle=90, size = 9), axis.title.x = element_blank())+
  xlab("Condition pairs") + 
  ylab("p-value")

# calculate mean and std dev per column - plot A

avg_score <- data.frame(avg = colMeans(data),
                        stdev = apply(data, 2, sd))
avg_score$names <- rownames(avg_score)

avg_score_plot <- ggplot(avg_score) +
  geom_bar( aes(x= names , y=avg), stat= 'identity',alpha = 0.7, fill = "#9778A5")+
  geom_errorbar(aes(x = names, ymin = avg - stdev, ymax = avg + stdev), width = 0.2, alpha = 0.5) +
  theme_minimal()+
  xlab("Model Temperature") + 
  ylab("Average score")

# Calculate the total score per column - plot B
total_score <- data.frame(total = colSums(data))
total_score$names <- rownames(total_score)

highest_score <- ggplot(total_score) +
  geom_bar( aes(x= names , y=total), stat= 'identity',alpha = 0.7, fill = "#9778A5")+
  geom_text(aes(x=names, y=total, label=total), vjust=-0.2, alpha = 0.7) +
  theme_minimal()+
  xlab("Model Temperature") + 
  ylab("Total score")


# Boxplot-plot C
p <- ggplot(melted_df, aes(x= condition, y=value), fill = grey) + 
  geom_boxplot(color = "#9778A5", fill = "#C8C6D7")+
  xlab("Model Temperature") + 
  ylab("Correct answers score (%)")+
  ylim(-1, 105)+
  theme_minimal()


library(ggpubr)
score_analysis_postgres <- ggarrange(avg_score_plot, highest_score, p,
                    labels = c("A", "B", "C"),
                    ncol = 3, nrow = 1 ) #,widths = c(0.8, 0.6 , 0.6))

ggsave("score_analysis_postgres.png", width = 11, height = 3.5)