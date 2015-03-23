require 'socket'
require 'uri'
require 'httparty'
require 'sqlite3'
require 'cgi'
require 'webrick'
require 'stringio'
require 'pry'

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

  def run_server
    server = TCPServer.new('localhost', 2345)

    loop do 
      socket = server.accept

      request_line = socket.gets
      # STDERR.puts request_line
      # puts "hi"

      line_array = []

      while(line = socket.gets) != "\r\n"
        line_array << line
      end

      first_line = line_array.shift
      http_method = first_line.split(' ')[0]
      request_path = first_line.split(' ')[1]

      headers = line_array.inject({}) do |h, line|
        key, val = line.split(": ")
        h.merge(key => val.strip)
      end

      path = requested_file(request_line)

      path = File.join(path, 'index.html') if File.directory?(path)
      # puts path

      if File.exist?(path) && !File.directory?(path)
        File.open(path, "r+") do |file|
          socket.print "HTTP/1.1 200 OK\r\n" +
                       "Content-Type: #{content_type(file)}\r\n" +
                       "Content-Length: #{file.size}\r\n" +
                       "Connection: close\r\n"

          socket.print "\r\n"

          IO.copy_stream(file, socket)
          @login_user = CGI.parse(socket.read)

          # puts @login_user["username"]
          # puts headers["Cookie"] 

          begin
            db = SQLite3::Database.open("test.sqlite")
            # db.execute "DROP TABLE IF EXISTS Tweets"
            db.execute "CREATE TABLE IF NOT EXISTS Tweets(Id INTEGER PRIMARY KEY, Description TEXT)"
            # # db.execute "INSERT INTO Tweets VALUES(1,'This is a tweet')"
            db.execute("INSERT INTO Tweets (Description) VALUES(?)", @login_user["username"])
            puts @login_user["username"]
          rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e  
          ensure
            db.close if db
          end  
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







