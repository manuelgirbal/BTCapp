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


