library(tidyverse)
library(rvest)
library(stringr)
library(lubridate)

# Reading "Blockchair Database Dumps" historic bitcoin transactions table:
blockchair <- read_html("https://gz.blockchair.com/bitcoin/transactions/")

# Selecting xpath of the transactions table:
txs_list <- blockchair %>%
  html_element(xpath = "/html/body/pre") %>%
  html_text()%>%
  strsplit("\n")

# Creating the data frame:
df <- tibble(a = txs_list) %>%
  unnest(a)


## OJO ACÁ: hay números que dicen 23M en vez del millón en número... reemplazar la M por los ceros
# Separating columns by whitespace or gap:
df <- df %>%
  slice(-1) %>%
  separate(a, into = c("filename", "date", "time", "value"), sep = "\\s+")

# Transforming some data:
df <- df %>%
  transmute(
    date = dmy(date),
    txs = as.numeric(value)
  )

# Grouping by month:
df_m <- df %>%
  group_by(date) %>%
  summarise(txs = sum(txs))

df_m <- df %>%
  mutate(month = format_ISO8601(date, precision = "ym")) %>%
  group_by(month) %>%
  summarize(txs = sum(txs))
