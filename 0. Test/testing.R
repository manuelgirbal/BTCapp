library(httr)

# Get the API endpoint URL
url <- "https://api.blockchain.info/charts/total-transaction-count"

# Make the API request
response <- GET(url)

# Check the response status code
if (response$status_code == 200) {

  # Parse the JSON response body
  data <- jsonlite::fromJSON(content(response, "text"))

  # Get the total number of transactions for each year
  transactions_per_year <- data$values

  # Print the results
  print(transactions_per_year)

} else {

  # Print an error message
  print("Error: API request failed")

}
