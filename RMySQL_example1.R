
#Sample for using RMySQL and R when mysql-server is hosted locally
#Used 'https://www.r-bloggers.com/accessing-mysql-through-r/' as a guide

library(RMySQL)
library(feather)
library(streamR)

#To find the socket location, type ""netstat -ln | awk '/mysql(.*)?\.sock/ { print $9 }'"" in terminal
mydb= dbConnect(MySQL(), user='root',password='tsutweets', dbname='sample_tweets', host='localhost', unix.socket="/var/run/mysqld/mysqld.sock")

my_data=read_feather("sample_tweets.feather")

#Creates a Table in mysql from my_data


#Looking at the tables in mysql


#Simple example Query (Saves the query on the server)
tweet_query=dbSendQuery(mydb, "SELECT * FROM Tweets")

#Turning the sql query from above into a dataframe
tweet_table=fetch(tweet_query, n=-1)

#Seeing if it worked
new=tweet_table


#There is one more row, but thats ok (since mysql counts the header as a row, but feather doesn't). Success!
