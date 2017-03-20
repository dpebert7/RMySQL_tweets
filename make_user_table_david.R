

#Sample for using RMySQL and R when mysql-server is hosted locally
#Used 'https://www.r-bloggers.com/accessing-mysql-through-r/' as a guide

library(RMySQL)
library(feather)
library(streamR)



#To find the socket location, type ""netstat -ln | awk '/mysql(.*)?\.sock/ { print $9 }'"" in terminal
dbconn = dbConnect(MySQL(), user='dangle', password='dongle', dbname='tweet_db', host='localhost', unix.socket="/var/run/mysqld/mysqld.sock")

tweets_df = read_feather("sample_tweets.feather")

# Creates a Table in mysql from my_data
# Initialize for loop
max_imports = 10 # Max number of days' tweets to import. Current max is 369

# This will reset the database if set at or below 0.
# Otherwise append.
count_imports = 0

for(i in 1:max_imports){
  print(count_imports)
  
  # Grab a 494 stored on file
  new_tweets_df = read_feather("sample_tweets.feather")
  
  new_tweets_df = new_tweets_df[,c("text", "id_str", "in_reply_to_screen_name", 
                             "source", "created_at", "in_reply_to_status_id_str", "in_reply_to_user_id_str", 
                             "location", "user_id_str", "followers_count", "favourites_count", "user_url", 
                             "name", "time_zone", "friends_count", "screen_name", "country_code", "place_type", 
                             "full_name", "place_name", "place_lat", "place_lon", "expanded_url")]
  
  if(count_imports <= 0){	# Overwrite table
    dbWriteTable(dbconn, name="Tweets", value = new_tweets_df, append = FALSE, overwrite = TRUE)
  }
  
  else{	# Append table
    dbWriteTable(dbconn, name="Tweets", value = new_tweets_df, append = TRUE, overwrite = FALSE)
  }
  count_imports = count_imports + 1
}



# Query for extracting user info from Tweets table
res=dbSendQuery(dbconn, 
  "SELECT DISTINCT user_id_str, followers_count, favourites_count, name, user_url
  FROM Tweets
  ORDER BY followers_count DESC;")
  #LIMIT 10;")
users_df = dbFetch(res)
dbClearResult(res)
dim(users_df)



# Query for counting tweets per user_id_str in MySQL
res=dbSendQuery(dbconn, 
                "SELECT user_id_str, COUNT(user_id_str)
  FROM Tweets
  GROUP BY user_id_str
  ORDER BY COUNT(user_id_str) DESC;")
  #LIMIT 10;")
count_df = dbFetch(res)
dbClearResult(res)


# Combine users_df and count_df
users_df = merge(users_df, count_df, by = "user_id_str")


# Send user_df to new MySQL table called Users
dbWriteTable(dbconn, "Users", users_df, overwrite = TRUE, append = FALSE)



# This might be doing too much in R!! 
# Maybe it would be better to just write the smaller count_df and add to it later??


# Close all connections:
dbDisconnectAll <- function(){
  ile <- length(dbListConnections(MySQL())  )
  lapply( dbListConnections(MySQL()), function(x) dbDisconnect(x) )
  cat(sprintf("%s connection(s) closed.\n", ile))
}
dbDisconnectAll()