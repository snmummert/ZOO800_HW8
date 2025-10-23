
library(gbifdb)
library(dplyr)    # for using dplyr style

gbif_conn <- gbif_remote()

gbif_conn <- gbif_remote(backend = "duckdb", bucket = "gbif-open-data-us-east-1")

tbl <- gbif_conn %>%
  filter(datasetkey == "fe7fa086-1b67-4c90-abe1-123048ead530")
head(1000)   # just pull first 1000

df <- collect(tbl)  # bring into R

monkeydf = df %>%
  select(
    species, locality, individualcount, decimallatitude, decimallongitude, month, year
  )
