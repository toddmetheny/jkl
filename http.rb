require 'socket'
require 'uri'
require 'httparty'
require 'sqlite3'
require 'cgi'
require 'webrick'
require 'stringio'
require 'pry'
require 'securerandom'
require './session'


class SimpleServer

  WEB_ROOT = './public'

  CONTENT_TYPE_MAPPING = {
    'html' => 'text/html',
    'txt' => 'text/plain',
    'png' => 'image/png',
    'jpg' => 'image/jpeg',
    'erb' => 'text/erb'
  }

  DEFAULT_CONTENT_TYPE = 'application/octetstream'

  def content_type(path)
    ext = File.extname(path).split(".").last
    CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
  end

  def requested_file(request_line)
    request_uri = request_line.split(" ")[1]
  
    path = URI.unescape(URI(request_uri).path)
    
    clean = []

    # # Split the path into components
    parts = path.split("/")

    parts.each do |part|
      # skip any empty or current directory (".") path components
      next if part.empty? || part == '.'
      # If the path component goes up one directory level (".."),
      # remove the last clean component.
      # Otherwise, add the component to the Array of clean components
      part == '..' ? clean.pop : clean << part
    end

    # return the web root joined to the clean path
    File.join(WEB_ROOT, *clean)
  end

  def send_login_data
    begin
      db = SQLite3::Database.open("test.sqlite")
      # db.execute "DROP TABLE IF EXISTS Users"
      #added a unique constraint for username
      db.execute "CREATE TABLE IF NOT EXISTS Users(Id INTEGER PRIMARY KEY, Username TEXT UNIQUE, Password TEXT)"
      # db.execute "INSERT INTO Tweets VALUES(1,'This is a tweet')"
      unless @login_user["username"].length < 1
        db.execute("INSERT INTO Users (Username, Password) VALUES(?,?)", [@login_user["username"], @login_user["password"]])
        @user_id = db.execute "SELECT * FROM Users WHERE ID = (SELECT MAX(Id) FROM Users)"
        puts @user_id
        # @user_id = "SELECT * FROM Users WHERE Users.Username = #{@login_user['username']} LIMIT 1"
      end
    rescue SQLite3::Exception => e 
      puts "Exception occurred"
      puts e
    ensure
      db.close if db
    end 
  end

  def start_server
    #call and then invoke as many actions as we'd like
  end

  def response
    {
      headers: {},
      body: ""
    }
  end

  def empty_page_action
    #http response reflecting minimal http page
    #empty body
    #connection close
  end

  # def current_user(user, token)
  #   @current_user = { user: user, token: token }
  # end

  def set_cookie(user)
    socket.print "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: #{content_type(file)}\r\n" +
                 "Content-Length: #{file.size}\r\n" +
                 "Set-Cookie: __kwipper_user=#{@user}; expires=0; username=#{@user}\r\n" +
                 "Connection: close\r\n"
    socket.print "\r\n"
  end

  def without_set_cookie
    socket.print "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: #{content_type(file)}\r\n" +
                 "Content-Length: #{file.size}\r\n" +
                 "Connection: close\r\n"
    socket.print "\r\n"
  end

  def login
    # get the login page
    path = File.join(path, 'login.html')
  end

  def logout
    # reset the cookie and get the logout html page
    path = File.join(path, 'logout.html')
  end

  def index(request)
    # GET request on the index page
    path = File.join(path, 'index.html')
    File.open(path)
  end

  def logged_in?
    p @headers["__kwipper_user"]
  end

  def tweet
  end

  def run_server
    server = TCPServer.new('localhost', 2345)

    loop do 
      socket = server.accept

      request_line = socket.gets
      # STDERR.puts request_line
      p request_line

      line_array = []

      while(line = socket.gets) != "\r\n"
        line_array << line
      end

      first_line = line_array.shift
      http_method = first_line.split(' ')[0]
      request_path = first_line.split(' ')[1]

      @headers = line_array.inject({}) do |h, line|
        key, val = line.split(": ")
        h.merge(key => val.strip)
      end

      path = requested_file(request_line)

      path = File.join(path, 'login.html') if File.directory?(path)

      # open index page
      if File.exist?(path) && !File.directory?(path)
        File.open(path, "r+") do |file|
          @token = SecureRandom.base64
          
          socket.print "HTTP/1.1 200 OK\r\n" +
                       "Content-Type: #{content_type(file)}\r\n" +
                       "Content-Length: #{file.size}\r\n" +
                       "Set-Cookie: __kwipper_user=#{@user}; expires=0; username=#{@user}\r\n" +
                       "Connection: close\r\n"

          socket.print "\r\n"

          IO.copy_stream(file, socket)
          @login_user = CGI.parse(socket.read)
          @user = @login_user["username"]
          # p @user


          send_login_data()
          # puts @user_id
          s = Session.new(@user, @token)
          puts s.current_user
          
          
        end
      else
        message = "File not found\n"
        socket.print "HTTP/1.1 404 Not Found\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: #{message.size}\r\n" +
                     "Connection: close\r\n"

        socket.print "\r\n"

        socket.print message
      end
      socket.close
    end
  end
end

server1 = SimpleServer.new 
server1.run_server()



