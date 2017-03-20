
#Sample for using RMySQL and R when mysql-server is hosted locally
#Used 'https://www.r-bloggers.com/accessing-mysql-through-r/' as a guide

library(RMySQL)
library(streamR)


# Make connection from R to MySQL:
# To find the socket location, type ""netstat -ln | awk '/mysql(.*)?\.sock/ { print $9 }'"" in terminal
dbconn = dbConnect(MySQL(), user='root', password='tsutweets', dbname='sample_tweets', 
		host='localhost', unix.socket="/var/run/mysqld/mysqld.sock")



a = Sys.time()
# Query for counting rows in Tweets table: (Saves the query on the server)
res=dbSendQuery(dbconn, "SELECT COUNT(*) FROM Tweets")
dbFetch(res)
dbClearResult(res)
# prints "[1] TRUE" if successful
print(Sys.time()-a)



a = Sys.time()
# Query for fetching 100 rows from Tweets table and displaying it in R data frame:
res = dbSendQuery(dbconn, "SELECT * FROM Tweets")
dbFetch(res, n = 10)  #This prints 10 results
tweet_table=fetch(res, n=10) 
dim(tweet_table) #Check dimension of data frame
print(Sys.time()-a)



a = Sys.time()
res = dbSendQuery(dbconn, "SELECT * FROM Tweets WHERE user_id_str = 4160637198")
dbFetch(res, n = 100)
tweet_table = fetch(res, n = 10)
dim(tweet_table)
print(Sys.time()-a)


# Query for fetching all data from Tweets table and putting it into an R data frame:
# res = dbSendQuery(dbconn, "SELECT * FROM Tweets")
# dbFetch(res, n = -1)
# tweet_table=fetch(res, n=-1) 
# dim(tweet_table) #Check dimension of data frame



# Close all connections:
dbDisconnectAll <- function(){
  ile <- length(dbListConnections(MySQL())  )
  lapply( dbListConnections(MySQL()), function(x) dbDisconnect(x) )
  cat(sprintf("%s connection(s) closed.\n", ile))
}
dbDisconnectAll()
