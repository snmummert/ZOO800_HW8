####################################
########## HW Week 8 ###########
# Sophia Mummert and Maddie Thall ##
#####################################

# library section #
library(gbifdb)
library(dplyr) 
library(ggplot2)

## import data from gbif ##

gbif_conn <- gbif_remote()

gbif_conn <- gbif_remote(backend = "duckdb", bucket = "gbif-open-data-us-east-1")

tbl <- gbif_conn %>%
  filter(datasetkey == "fe7fa086-1b67-4c90-abe1-123048ead530")

df <- collect(tbl)

## cutting down our data to information we can graph ##

monkeydf = df %>%
  select(
    species, locality, individualcount, decimallatitude, decimallongitude, month, year
  )

###### plot 1 ######

ggplot(monkeydf, aes(y = individualcount, fill = species)) +
  geom_boxplot(alpha = 0.7) +
  facet_wrap(~ year) +
  theme_minimal() +
  labs(title = "Distribution of individual counts per species per year",
       y = "Individual count", x = "Species")

# The boxplot shows the distribution of individual counts for different monkey species across various years.
# Colobus guereza was sampled very few times which may be due to small population size
# There are many outliers for Cercopithecus ascanisus which may indicate
# a highly fluctuating population or sampling bias.
# Chlorocebus pygerythruss and Cercopithecus ascanisus seem to increase
# in individual counts from 2011 to 2012, which could indicate population growth


###### plot 2 #####

library(ggplot2)
library(maps)


ggplot(monkeydf, aes(x = decimallongitude, y = decimallatitude, color = species)) +
  borders("world", colour = "gray80", fill = "gray95") +
  geom_point(alpha = 0.5, size = 2) +
  coord_quickmap(
    xlim = c(32.25, 32.6),   # Uganda’s longitude range
    ylim = c(0, .4)   # Uganda’s latitude range
  ) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Observations by Species",
    x = "Longitude", y = "Latitude",
    color = "Species"
  ) +
  theme(
    panel.background = element_rect(fill = "aliceblue"),
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold", size = 11)
  )

#something we noticed with this map is that most of the monkeys are grouped 
#in one area with a few outliers, and there is another group of 
#Cercopithecus ascanius off to the other side, and given how few Colobus monkeys 
#there are, they hardly even register on the map.

##### plot 3 #####

monkey_mutated = monkeydf %>%
  filter(!(year == 2011 & month == 1))
# removed January 2011 data point as it is a temporal outlier

monkey_mutated %>%
  group_by(locality, month, year) %>%
  summarise(total_count = sum(individualcount), .groups = "drop") %>%
  ggplot(aes(x = month, y = locality, fill = total_count)) +
  geom_tile() +
  facet_wrap(~ year, scales = "free_x") +
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Heatmap of monkey abundance by month and locality",
       x = "Month", y = "Locality", fill = "Total count")

# The heatmap shows the total monkey counts across different localities and months for each year.
# There are clear seasonal patterns in certain localities, for example,
# Kituuza seems to have higher counts December and January.
# Some localities appear to have more consistent monkey populations throughout the year,
# and some were not sampled every month, leaving a hole in the data.
