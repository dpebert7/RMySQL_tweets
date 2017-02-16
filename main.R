# David Ebert
# Make a set of sample tweets for creating database

# Working directory ----

setwd("/home/david/Desktop/Documents/GitRepos/RMySQL_tweets")


# Authenticate streamR ----

# library(streamR)
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


