# David Ebert
# Make a set of sample tweets for creating database

# Working directory ----

setwd("/home/david/Desktop/Documents/GitRepos/RMySQL_tweets")


# Authenticate streamR ----

library(streamR)
# library(ROAuth)
# requestURL <- "https://api.twitter.com/oauth/request_token"
# accessURL <- "https://api.twitter.com/oauth/access_token"
# authURL <- "https://api.twitter.com/oauth/authorize"
# consumerKey <- "xxxyyyzzz"
# consumerSecret <- "xxxyyyzzz"
# my_oauth <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
#                              requestURL = requestURL, accessURL = accessURL, authURL = authURL)
# my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
# save(my_oauth, file = "my_oauth.Rdata")





# Collect a few tweets and save them.
library(feather)
load("my_oauth.Rdata")
sampleStream(file.name = "sample_tweets.json", oauth = my_oauth, timeout = 5)
sample_tweets_df = parseTweets(tweets = "sample_tweets.json")
write_feather(x = sample_tweets_df, path = "sample_tweets.feather")
write.csv(x = sample_tweets_df, file = "sample_tweets.csv")



# Load a few tweets back into R from json file
sample_tweets_df = parseTweets(tweets = "sample_tweets.json")
colnames(sample_tweets_df)

sample_tweets_df = sample_tweets_df[,c("text", "id_str", "id_str", "in_reply_to_screen_name", "source", "created_at", 
                                       "in_reply_to_status_id_str", "in_reply_to_user_id_str", "location", "user_id_str", 
                                       "followers_count", "favourites_count", "user_url", "name", "time_zone", "friends_count", 
                                       "screen_name", "country_code", "place_type", "full_name", "place_name", "place_lat", 
                                       "place_lon", "expanded_url")]

#sample_tweets_df$id_str #check id_str is really a string



# Write a few tweets to a database
library(RMySQL)
dbcon = dbConnect(MySQL(), user = 'dangle',
                  password = 'dongle',
                  dbname = 'tweet_db',
                  host = '127.0.0.1')

dbListTables(dbcon)
dbListFields(dbcon, 'mini_tweets')


dbWriteTable(dbcon, value = sample_tweets_df, name = "new_tweets", append = FALSE, overwrite = TRUE)
res = dbSendQuery(dbcon, "SELECT COUNT(*) FROM new_tweets;")
dbFetch(res)
dbClearResult(res)


dbWriteTable(dbcon, value = sample_tweets_df, name = "new_tweets", append = TRUE, overwrite = FALSE)
res = dbSendQuery(dbcon, "SELECT COUNT(*) FROM new_tweets;")
dbFetch(res)
dbClearResult(res)

# Table has doubled in size
dbListConnections(MySQL())
