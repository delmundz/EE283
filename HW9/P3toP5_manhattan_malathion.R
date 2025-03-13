###Problem 3 #####
#manhattan plot from malathion dataset week 8

library(tidyverse)
library(qqman)
library(cowplot)
library(gridGraphics)
library(dplyr)
library(ggplot2)
library(patchwork)
library(gridExtra)
library(grid)
setwd("/Users/zenadelmundo/desktop/HW8")

#check levels 
model1 <- read.csv("HW8_P1_treatment_founder.csv")
View(model1)
levels(as.factor(model1$chr))
unique(model1$chr)

# Function to preprocess data for Manhattan plot
res1 <- read.csv("HW8_P1_treatment_founder.csv") %>%
    mutate(
      SNP = paste0(chr, "_", pos), #create uniquue SNP identifier (chr_position)
      CHR = case_when(              # Convert chromosome names to numeric values
        chr == "chrX"  ~ 1,
        chr == "chr2L" ~ 2,
        chr == "chr2R" ~ 3,
        chr == "chr3L" ~ 4,
        chr == "chr3R" ~ 5,
        TRUE ~ NA_real_  # Assign NA instead of coercing
      ),
      BP = pos,            #base pair position remains the same
      P = neg_log10p  # Dynamically select the significance column (neg log10 p-values)
    ) %>%
    drop_na(CHR) %>%  # Remove NAs safely
    select(CHR, BP, SNP, P) #keep only essential columns

unique(res1$CHR)
colnames(res1)

# Check for unexpected chromosome names
unexpected_chr <- setdiff(unique(model1$chr), c("chrX", "chr2L", "chr2R", "chr3L", "chr3R"))
print(unexpected_chr)  # This will show any values not accounted for in case_when()

res2 <- read.csv("HW8_P2_treatment_within_founder.csv") %>%
  mutate(
    SNP = paste0(chr, "_", pos), #create uniquue SNP identifier (chr_position)
    CHR = case_when(              # Convert chromosome names to numeric values
      chr == "chrX"  ~ 1,
      chr == "chr2L" ~ 2,
      chr == "chr2R" ~ 3,
      chr == "chr3L" ~ 4,
      chr == "chr3R" ~ 5,
      TRUE ~ NA_real_  # Assign NA instead of coercing
    ),
    BP = pos,            #base pair position remains the same
    P = neg_log10p  # Dynamically select the significance column (neg log10 p-values)
  ) %>%
  drop_na(CHR) %>%  # Remove NAs safely
  select(CHR, BP, SNP, P) #keep only essential columns

unique(res2$CHR)
colnames(res2)

View(res1)
View(res2)

# Set up the plotting parameters (increasing bottom margin for the top plot)
par(mfrow = c(1, 1))  # Reset plotting layout
par(mar = c(6, 4, 4, 2))  # Increase the bottom margin (first value) to give space for the x-axis labels

# Plot for Model 1
manhattan(res1, main = "Significant SNPs from Model 1",
          ylim = c(0, 10), cex = 0.6, cex.axis = 0.9,
          col = c("blue4", "orange3"),
          suggestiveline = -log10(1e-05),
          genomewideline = -log10(5e-08),
          logp = TRUE)

# Plot for Model 2
manhattan(res2, main = "Significant SNPs from Model 2",
          ylim = c(0, 10), cex = 0.6, cex.axis = 0.9,
          col = c("blue4", "orange3"),
          suggestiveline = -log10(1e-05),
          genomewideline = -log10(5e-08),
          logp = TRUE)


# Arrange both plots with better spacing
final_plot <- plot_grid(p1, p2, 
                        ncol = 1, 
                        align = "v",  # Align plots vertically
                        rel_heights = c(2, 1))  # Increase height of top plot

# Save the figure
ggsave("P3_manhattan_plots.pdf", plot = final_plot, height = 10, width = 9)


###Problem 4####
#use mymanhattan from alfonso

getwd()
setwd("/Users/zenadelmundo/Desktop/HW9")

source("myManhattanFunction.R")

# Generate Manhattan plot for Model 1
gg1 <- myManhattan(res1, 
                   chrom.lab = res1$CHR,  # Ensure the correct column for chromosome label
                   graph.title = "Significant SNPs from Model 1")

# Generate Manhattan plot for Model 2
gg2 <- myManhattan(res2, 
                   chrom.lab = res2$CHR,  # Ensure the correct column for chromosome label
                   graph.title = "Significant SNPs from Model 2")

# Display both plots
print(gg1)
print(gg2)

# Arrange the plots vertically or horizontally
final_plot <- plot_grid(gg1, gg2, ncol = 1, align = "v", rel_heights = c(1.1, 1))

# Save the combined plot as a PDF
ggsave("P4_manhattan_plots.pdf", plot = final_plot, height = 10, width = 9)

###Problem 5####
#create 3rd panel: -log10(p) comparison scatter plot to see where two models disagree

# Create a data frame with -log10(p) values from both models
comparison_df <- data.frame(
  SNP = res1$SNP,  # Assuming both data frames have a common SNP column
  p1 = res1$P,     # -log10(p) for Model 1
  p2 = res2$P      # -log10(p) for Model 2
)

# Scatter plot to compare -log10(p) values
gg3 <- ggplot(comparison_df, aes(x = p1, y = p2)) +
  geom_point(alpha = 0.5, color = "gray") +  # Gray points for general comparison
  geom_smooth(method = "lm", color = "blue") +  # Optional: linear regression line
  ggtitle("Comparison of -log10(p) from Model 1 and Model 2") +
  xlab("Model 1 -log10(p)") +
  ylab("Model 2 -log10(p)") +
  theme_minimal()

# Combine all three plots

lay <- rbind(
  c(1,1,1,3),  # P1 spans 3 columns, P2 takes 1 column
  c(2,2,2,3)  # P1 spans 3 columns, P3 takes 1 column
)

# Save the arranged plot as a high-resolution TIFF image
tiff("manhattanplot.tiff", width = 7, height = 6, units = "in", res = 600)

# Arrange and display the plots using the custom layout
grid.arrange(gg1, gg2, gg3, layout_matrix = lay)

# Close the TIFF device to save the image
dev.off()
