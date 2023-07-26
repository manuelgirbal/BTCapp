## Error: en este script estaba sumando los bytes de cada día y no las txs... que están dentro de cada TSV
## Abandonado porque implica descargar más de 50gb de data para bajar cada TSV file

library(tidyverse)
library(rvest)
library(stringr)
library(lubridate)

options(scipen=999)

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


# Separating columns by whitespace or gap:
df <- df %>%
  slice(-1) %>%
  separate(a, into = c("filename", "date", "time", "value"), sep = "\\s+")

# Transforming some data:
df <- df %>%
  mutate(value = str_replace_all(value, 'M', '000000')) %>%
  mutate(value = str_replace_all(value, 'K', '000')) %>%
  transmute(
    date = dmy(date),
    txs = as.numeric(value)
  )

# Grouping by month:
df_m <- df %>%
  mutate(month = format_ISO8601(date, precision = "ym")) %>%
  group_by(month) %>%
  summarize(txs = sum(txs))


