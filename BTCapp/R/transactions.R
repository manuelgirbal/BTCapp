library(shroomDK)
library(tidyverse)
library(lubridate)

# https://docs.flipsidecrypto.com/flipside-api/getting-started

api_key = readLines("api_key.txt") # always gitignore your API keys!

query <- {
  "
  select date(date_trunc('Month', block_timestamp)) as month,
       count(*) as txs
  from bitcoin.core.fact_transactions
  group by 1
  order by 1 desc
  "
}

pull_data <- auto_paginate_query(
  query = query,
  api_key = api_key
)


# Constructing the table:
df_txs <- as_tibble(
  pull_data %>%
    transmute(date = as_date(ymd_hms(month)),
              txs)
)


# Creating plot:
btctxs_plot <- df_txs %>%
  ggplot(aes(date, txs)) +
  geom_line() +
  ylab("Transactions") +
  xlab("Date") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme(plot.background = element_rect(fill = "#A6A6A6"),
        panel.background = element_rect(fill = "#A6A6A6"),
        panel.grid.major = element_line(colour = "#7A7A7A"))

