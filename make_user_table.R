# David Ebert
# 20 March
# Make users table from tweets

setwd("~/Desktop/RMySQL_tweets")

#Sample for using RMySQL and R when mysql-server is hosted locally
#Used 'https://www.r-bloggers.com/accessing-mysql-through-r/' as a guide

library(RMySQL)
library(feather)
library(streamR)



#To find the socket location, type ""netstat -ln | awk '/mysql(.*)?\.sock/ { print $9 }'"" in terminal
dbconn= dbConnect(MySQL(), user='root',password='tsutweets', dbname='sample_tweets', host='localhost', unix.socket="/var/run/mysqld/mysqld.sock")


a = Sys.time()
# Query for counting number of tweets in Tweets table
res=dbSendQuery(dbconn, 
  "SELECT COUNT(*)
  FROM Tweets;")
dbFetch(res)
dbClearResult(res)
Sys.time()-a
# Currently 59993094 tweets as of 20 March


# Query for extracting user info from Tweets table (Still need followers_count, favourites_count)
a = Sys.time()
res=dbSendQuery(dbconn, 
  "SELECT DISTINCT user_id_str, name, user_url
  FROM Tweets;")
user_df = dbFetch(res, n=-1)
dbClearResult(res)
dim(user_df)
Sys.time()-a
#save(user_df, file = "user_df.RData")
#load("count_df.RData")


# Query for counting tweets per user_id_str in MySQL
a = Sys.time()
res=dbSendQuery(dbconn, 
  "SELECT user_id_str, COUNT(user_id_str)
  FROM Tweets
  GROUP BY user_id_str
  ORDER BY COUNT(user_id_str) DESC;")
count_df = dbFetch(res, n=-1)
dbClearResult(res)
dim(count_df)
Sys.time()-a # 1049836 distinct ids, found in 9.1 minutes
save(count_df, file = "count_df.RData")
#load("count_df.RData")


# Combine user_df and count_df
user_df = merge(user_df, count_df, by = "user_id_str")


# Send user_df to new MySQL table called Users
dbWriteTable(dbconn, "Users", user_df, overwrite = TRUE, append = FALSE)



# This might be doing too much in R!! 
# Maybe it would be better to just write the smaller count_df and add to it later??


# Close all connections:
dbDisconnectAll <- function(){
  ile <- length(dbListConnections(MySQL())  )
  lapply( dbListConnections(MySQL()), function(x) dbDisconnect(x) )
  cat(sprintf("%s connection(s) closed.\n", ile))
}
dbDisconnectAll()