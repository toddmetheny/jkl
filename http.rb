require 'socket'
require 'uri'
require 'net/http'
require 'sqlite3'
require 'cgi'
require './data'
# require './insert'

# DB = SQLite3::Database.new ":memory:"

uri = URI('http://localhost:2345')
# res = Net::HTTP.get_response(uri)
# res['Set-Cookie']
# res.get_fields('set-cookie')
# puts "Headers: #{res.to_hash.inspect}"

# res = Net::HTTP.post_form(uri, 'q' => 'ruby', 'max' => '50')
# puts res.body

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
  # request_uri2 = request_line.split(" ")[2]
  # request_uri3 = request_line.split(" ")[3]
  path = URI.unescape(URI(request_uri).path)
  # path2 = URI.unescape(URI(request_uri2).path)
  # path3 = URI.unescape(URI(request_uri3).path)
  clean = []
  # path2 = "/index.htm"
  # request = "GET #{path} HTTP/1.0\r\n\r\n"

  # # Split the path into components
  parts = path.split("/")

  parts.each do |part|
  #   # skip any empty or current directory (".") path components
    next if part.empty? || part == '.'
  #   # If the path component goes up one directory level (".."),
  #   # remove the last clean component.
  #   # Otherwise, add the component to the Array of clean components
    part == '..' ? clean.pop : clean << part
  end

  # return the web root joined to the clean path
  File.join(WEB_ROOT, *clean)
end

server = TCPServer.new('localhost', 2345)

loop do 
  socket = server.accept
  request_line = socket.gets
  STDERR.puts request_line

  path = requested_file(request_line)

  path = File.join(path, 'index.html') if File.directory?(path)

  if File.exist?(path) && !File.directory?(path)
    File.open(path, "rb") do |file|
      socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: #{content_type(file)}\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Connection: close\r\n"

      socket.print "\r\n"
      IO.copy_stream(file, socket)
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

  # socket.print response
  socket.close
end





