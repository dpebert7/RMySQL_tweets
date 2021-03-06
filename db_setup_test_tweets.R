# David Ebert
# 21 March 2017
# Script for setting up test tweets table, called testTweets, on Lab computer


#Sample for using RMySQL and R when mysql-server is hosted locally
#Used 'https://www.r-bloggers.com/accessing-mysql-through-r/' as a guide


library(RMySQL)
library(feather)
library(streamR)


# Make connection from R to MySQL:
# To find the socket location, type ""netstat -ln | awk '/mysql(.*)?\.sock/ { print $9 }'"" in terminal
dbconn = dbConnect(MySQL(), user='root', password='tsutweets', dbname='sample_tweets', 
		host='localhost', unix.socket="/var/run/mysqld/mysqld.sock")



# Initialize for loop
raw_storage_directory = "/media/tsutweets/fc247505-6db9-4add-86b4-4982857a8fd2/raw_data" 
max_imports = 5 # Max number of days' tweets to import. Current max is 369
files_to_import = list.files(path = paste(raw_storage_directory))
print(files_to_import[1:max_imports])

# This will reset the database if set at or below 0. 
# Otherwise it will append.
# Be careful!!!
count_imports = 0 

for(i in files_to_import[1:max_imports]){
	
	print(paste("Reading ", raw_storage_directory, "/", i, "...", sep = ""))
	
	# Dummy case: Just grab a 494 stored on file
	# new_tweets = parseTweets(tweets = "~/Desktop/RMySQL_tweets/sample_tweets.json")

	# Main case: Read a day's tweets into R from json file
	new_tweets = parseTweets(tweets = paste(raw_storage_directory, "/", i, sep = ""))

	new_tweets = new_tweets[,c("text", "id_str", "id_str", "in_reply_to_screen_name", 
		"source", "created_at", "in_reply_to_status_id_str", "in_reply_to_user_id_str", 
		"location", "user_id_str", "followers_count", "favourites_count", "user_url", 
		"name", "time_zone", "friends_count", "screen_name", "country_code", "place_type", 
		"full_name", "place_name", "place_lat", "place_lon", "expanded_url")]
	
	if(count_imports <= 0){	# Overwrite table
		dbWriteTable(dbconn, name="testTweets", value = new_tweets, append = FALSE, overwrite = TRUE)

	}

	else{	# Append table
		dbWriteTable(dbconn, name="testTweets", value = new_tweets, append = TRUE, overwrite = FALSE)
	}
	count_imports = count_imports + 1
}


# Query for counting rows in Tweets table: (Saves the query on the server)
res=dbSendQuery(dbconn, "SELECT COUNT(*) FROM testTweets")
dbFetch(res)
dbClearResult(res)
# prints "[1] TRUE" if successful


# Query for fetching all data from testTweets table and putting it into an R data frame:
# res = dbSendQuery(mydb, "SELECT * FROM testTweets")
# dbFetch(res, n = 10) This prints 10 results
# tweet_table=fetch(res, n=-1) 
# dim(tweet_table) #Check dimension of data frame


# Close all connections:
dbDisconnectAll <- function(){
  ile <- length(dbListConnections(MySQL())  )
  lapply( dbListConnections(MySQL()), function(x) dbDisconnect(x) )
  cat(sprintf("%s connection(s) closed.\n", ile))
}
dbDisconnectAll()
