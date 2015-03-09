begin
  db = SQLite3::Database.open("test.sqlite")
  db.execute "CREATE TABLE IF NOT EXISTS Tweets(Id INTEGER PRIMARY KEY, 
        Description TEXT)"
  # db.execute "INSERT INTO Tweets VALUES(1,'This is a tweet')"
rescue SQLite3::Exception => e 
  puts "Exception occurred"
  puts e  
ensure
  db.close if db
end