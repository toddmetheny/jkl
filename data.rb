require 'cgi'
require './http'
# cgi = CGI.new
# cgi = CGI.new
# puts cgi.header
# h = cgi.params
# puts h
# h['tweet']

puts "hello"

class Database < SimpleServer
  def run
    puts "something"
    puts "else"
    begin
      db = SQLite3::Database.open("test.sqlite")
      db.execute "CREATE TABLE IF NOT EXISTS Tweets(Id INTEGER PRIMARY KEY, 
            Description TEXT)"
      db.execute "INSERT INTO Tweets VALUES(1,'This is a tweet')"
      db.execute "INSERT INTO Tweets VALUES(2, #{@login_user})"
      puts @login_user["username"]
    rescue SQLite3::Exception => e 
      puts "Exception occurred"
      puts e  
    ensure
      db.close if db
    end
  end
end

d = Database.new
d.run()
