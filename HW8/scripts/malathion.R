getwd()
setwd("/Users/zenadelmundo/Desktop/HW8")

library(tidyverse)
mal = read_tsv("allhaps.malathion.200kb.txt")
View(mal)

# select the first position in the genome
mal2 = mal %>% filter(chr=="chrX" & pos==316075)
View(mal2)

levels(as.factor(mal2$pool))
levels(as.factor(mal2$founder))

#mcF - control female
#mcM - control male
#msF - pesticide female
#msM - pesticide male

3#creat new column "treat"; extract substring from "pool" column specifically 2nd character
mal2 = mal2 %>% mutate(treat=str_sub(pool,2,2))
anova(lm(asin(sqrt(freq)) ~ treat + founder + treat:founder, data=mal2))

####Problem 1 ####
# fit this model and extract the -log10(p) at every location in the genome using group_by, nest, and map. Any function could have been fit. 

mal = read_tsv("allhaps.malathion.200kb.txt")
View(mal)

mal <- mal %>% mutate(treat=str_sub(pool,2,2))
View(mal)

str(mal)

mal <- mal %>%
  mutate(treat = as.factor(treat), founder = as.factor(founder))

# Define function to fit ANOVA model
fit_model <- function(df) {
  anova(lm(asin(sqrt(freq)) ~ treat + founder + treat:founder, data = df))
}

#define Function to extract p-value for interaction term (treat:founder)
extract_pval <- function(anova_table) {
  return(anova_table$`Pr(>F)`[3])  # Extracts p-value from 3rd row (interaction term)
}

# Main pipeline
results <- mal %>%
  filter(!is.na(freq)) %>%  # Remove rows with missing frequency values
  group_by(chr, pos) %>%    # Group by chromosome and position
  nest() %>%                # Nest data for each (chr, pos) group
  mutate(
    anova_table = map(data, fit_model),      # Apply ANOVA function
    p_value = map_dbl(anova_table, extract_pval), # Extract p-value
    neg_log10p = -log10(p_value)             # Convert p-value to -log10(p)
  ) %>%
  select(chr, pos, neg_log10p)  # Keep only relevant columns


print(results)

# Save results to CSV
write.csv(results, "HW8_P1_treatment_founder.csv")


####Problem 2 #####
#correct model 
#treatment effect within founder

# Define function to fit ANOVA model with alternative formula
fit_model2 <- function(df) {
  anova(lm(asin(sqrt(freq)) ~ founder + treat %in% founder, data = df))
}

# Function to extract p-value for treat %in% founder effect
extract_pval2 <- function(anova_table) {
  return(anova_table$`Pr(>F)`[2])  # Extracts p-value from 2nd row (treat within founder)
}

# Main pipeline
results2 <- mal %>%
  filter(!is.na(freq)) %>%  # Remove rows with missing frequency values
  group_by(chr, pos) %>%    # Group by chromosome and position
  nest() %>%                # Nest data for each (chr, pos) group
  mutate(
    anova_table = map(data, fit_model2),      # Apply ANOVA function
    p_value = map_dbl(anova_table, extract_pval2), # Extract p-value
    neg_log10p = -log10(p_value)             # Convert p-value to -log10(p)
  ) %>%
  select(chr, pos, neg_log10p)  # Keep only relevant columns

# Save results to CSV
write.csv(results2, "HW8_P2_treatment_within_founder.csv")

print(results2)


##### Problem 3####
#Merge the resulting two scans into a single tibble. (You could more easily just fit the two models as two different maps, but I want you to try using join).

library(dplyr)

model1_results <- read.csv("HW8_P1_treatment_founder.csv", check.names = FALSE) %>%
  select(-1) %>%  
  rename_with(~ "neg_log10p_model1", .cols = neg_log10p)  # Rename using rename_with()

model2_results <- read.csv("HW8_P2_treatment_within_founder.csv", check.names = FALSE) %>%
  select(-1) %>%
  rename_with(~ "neg_log10p_model2", .cols = neg_log10p)

# Merge datasets
merged_results <- left_join(model1_results, model2_results, by = c("chr", "pos"))

# View merged results
head(merged_results)
View(merged_results)

# Save the merged dataset
write.csv(merged_results, "merged_model_results.csv", row.names = FALSE)










