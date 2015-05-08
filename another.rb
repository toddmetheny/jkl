require 'socket'
require 'uri'
require 'cgi'
require 'sqlite3'

class Request
end

class Response
end

class Tweet
end

class User
  @@all_users = []
  def initialize(username, password)
    @username = username
    @password = password
    @@all_users << self
  end

  def self.all_users
    @@all_users
  end

  def create_user
    Database.user_table
    Database.login_data(@username, @password)
  end
end

class Database
  def initialize()
    @db = SQLite3::Database.open("test.sqlite")
  end

  def self.user_table
    @db.execute "CREATE TABLE IF NOT EXISTS Users(Id INTEGER PRIMARY KEY, Username TEXT UNIQUE, Password TEXT)"
  end

  def self.login_data(username, password)
    begin
      # db.execute "DROP TABLE IF EXISTS Users"
      #added a unique constraint for username
      Database.user_table()
      # @db.execute "CREATE TABLE IF NOT EXISTS Users(Id INTEGER PRIMARY KEY, Username TEXT UNIQUE, Password TEXT)"
      # db.execute "INSERT INTO Tweets VALUES(1,'This is a tweet')"
      unless @login_user["username"].length < 1
        @db.execute("INSERT INTO Users (Username, Password) VALUES(?,?)", [@login_user["username"], @login_user["password"]])
        @user_id = @db.execute "SELECT * FROM Users WHERE ID = (SELECT MAX(Id) FROM Users)"
        puts @user_id
        # @user_id = "SELECT * FROM Users WHERE Users.Username = #{@login_user['username']} LIMIT 1"
      end
    rescue SQLite3::Exception => e 
      puts "Exception occurred"
      puts e
    ensure
      @db.close if @db
    end
  end
end

class Server
  WEB_ROOT = './public'

  CONTENT_TYPE_MAPPING = {
    'html' => 'text/html',
    'txt' => 'text/plain',
    'png' => 'image/png',
    'jpg' => 'image/jpeg',
    'erb' => 'text/erb'
  }

  DEFAULT_CONTENT_TYPE = 'application/octetstream'

  def initialize
    @server = TCPServer.new('localhost', 2345)
  end

  def self.content_type(path)
    ext = File.extname(path).split(".").last
    CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
  end

  def requested_file(request_line)
    request_uri = request_line.split(" ")[1]
  
    path = URI.unescape(URI(request_uri).path)
    
    clean = []

    # split the path into components
    parts = path.split("/")

    parts.each do |part|
      # skip any empty or current directory (".") path components
      next if part.empty? || part == '.'
      # If the path component goes up one directory level (".."), remove the last clean component.
      # Otherwise, add the component to the Array of clean components
      part == '..' ? clean.pop : clean << part
    end
    # return the web root joined to the clean path
    File.join(WEB_ROOT, *clean)
  end

  def parse_headers(socket, line_array)
    first_line = line_array.shift
    http_method = first_line.split(' ')[0]
    request_path = first_line.split(' ')[1]

    @headers = line_array.inject({}) do |h, line|
      key, val = line.split(": ")
      h.merge(key => val.strip)
    end
  end

  def login_page
  end

  def start
    loop do
      @socket = @server.accept
      request_line = @socket.gets

      line_array = []

      while(line = @socket.gets) != "\r\n"
        line_array << line
      end

      parse_headers(@socket, line_array)

      path = requested_file(request_line)
      path = File.join(path, 'login.html') if File.directory?(path)

      # open index page
      if File.exist?(path) && !File.directory?(path)
        Session.set_cookie(@socket, path)
      else
        message = "File not found\n"
        @socket.print "HTTP/1.1 404 Not Found\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: #{message.size}\r\n" +
                     "Connection: close\r\n"

        @socket.print "\r\n"

        @socket.print message
      end
      @socket.close
    end
  end
end



class Session < Server

  def self.set_cookie(socket, path)
    File.open(path, "r+") do |file|
      
      socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: #{Server.content_type(file)}\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Set-Cookie: __kwipper_user=#{@user}; expires=0; username=#{@user}\r\n" +
                   "Connection: close\r\n"

      socket.print "\r\n"

      IO.copy_stream(file, socket)
      @login_user = CGI.parse(socket.read)
      @user = @login_user["username"]
      # p @user


      # send_login_data()
      # puts @user_id
      # s = Session.new(@user, @token)
      # puts s.current_user 
    end
  end

  def self.expire_cookie(socket, path)
    File.open(path, "r+") do |file|
      
      socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: #{Server.content_type(file)}\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Set-Cookie: __kwipper_user=nil; expires=#{Time.now}; username=nil\r\n" +
                   "Connection: close\r\n"

      socket.print "\r\n"

      IO.copy_stream(file, socket)
      # @login_user = CGI.parse(socket.read)
      # @user = @login_user["username"]
      # p @user

      # send_login_data()
      # puts @user_id
      # s = Session.new(@user, @token)
      # puts s.current_user 
    end
  end
end

s = Server.new
s.start