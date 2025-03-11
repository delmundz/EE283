library(qqman)
library(patchwork)
library(nycflights13)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(grid)

getwd()
setwd("/Users/zenadelmundo/Desktop/HW8")

####Problem 1 ####

View(flights)

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(gridExtra)
library(grid)

# Scatter plot with smoothing line
P1 <- flights %>%
  filter(!is.na(distance) & !is.na(arr_delay)) %>%
  ggplot(aes(x = distance, y = arr_delay)) +
  geom_point(alpha = 0.5, color = "blue") +  # Transparency for better visualization
  geom_smooth(method = "lm", color = "red") +  # Linear regression for better trend detection
  labs(title = "Arrival Delay vs. Distance", x = "Distance (miles)", y = "Arrival Delay (minutes)")

print(P1)

# temp_flights: Compute mean arrival delay by carrier
temp_flights <- flights %>%
  group_by(carrier) %>%
  summarize(m_arr_delay = mean(arr_delay, na.rm = TRUE))

View(temp_flights)

#Bar plot of mean arrival delay per carrier
P2 <- ggplot(temp_flights, aes(x = reorder(carrier, -m_arr_delay), y = m_arr_delay)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Mean Arrival Delay by Carrier", x = "Carrier", y = "Mean Arrival Delay (minutes)") +
  theme_minimal()

print(P2)

#Boxplot of arrival delay by carrier
P3 <- flights %>%
  filter(!is.na(arr_delay)) %>%
  ggplot(aes(x = carrier, y = arr_delay)) + 
  geom_boxplot(outlier.color = "red", outlier.shape = 16) +
  labs(title = "Arrival Delay Distribution by Carrier", x = "Carrier", y = "Arrival Delay (minutes)") +
  theme_minimal()

print(P3)

#Histogram of arrival delay
P4 <- flights %>%
  filter(!is.na(arr_delay)) %>%
  ggplot(aes(x = arr_delay)) +
  geom_histogram(bins = 50, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Arrival Delays", x = "Arrival Delay (minutes)", y = "Count") +
  theme_minimal()

print(P4)

# Arrange all plots in a grid


# Arrange all plots in a grid with 2 columns
grid.arrange(P1, P2, P3, P4, ncol = 2)

# Define a custom layout for arranging the plots
lay <- rbind(
  c(1,1,1,2),  # P1 spans 3 columns, P2 takes 1 column
  c(1,1,1,3),  # P1 spans 3 columns, P3 takes 1 column
  c(1,1,1,4)   # P1 spans 3 columns, P4 takes 1 column
)

# Save the arranged plot as a high-resolution TIFF image
tiff("figure1.tiff", width = 7, height = 6, units = "in", res = 600)

# Arrange and display the plots using the custom layout
grid.arrange(P1, P2, P3, P4, layout_matrix = lay)

# Close the graphics device to save the file properly
dev.off()
