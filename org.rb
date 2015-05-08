class HttpResponse
  attr_accessor :request, :headers, :body
  
  def initialize(request, headers = {}, body = "")
    @request = request
    @headers = headers
    @body = body
  end
  
  def to_a
    [@request, @headers, @body]
  end
  
  def status
    @status ||= '200 OK'
  end
end

class HttpRequest
end

class Session
  def login(request)
    # only GET
  end

  def logged_in(request)
    # only POST
    body = File.open('/home/todd/projects/http/login.html')
    
    response = HttpResponse.new(request, {}, body)
    db = SqliteDb.new
    if u = db.user_for_username_and_password # {id: ..., name: ..., }
      response.headers['Set-Cookie'] = "__user_id=#{u.id}; expires=0"
    else
      response.status = '403 Forbidden'
    end
    # if failed, return 403 status
    
    response
  end
  
  def tweet(request)
    user_id = request.cookie['__user_id']

    db = SqliteDb.new
    db.user...
    
  end
  
  def logout(request)
    body = File.open('/home/todd/projects/http/logged_out.html')
    
    response.headers['Set-Cookie'] = '__user_id=-1'
    
    response
  end
end

  def start_server
    # start a TCP server
    server = TCPServer.new('localhost', 2345)
    
    loop do
      socket = server.accept
      
      req = HttpRequest.new(socket.gets) # does header processing
      
      response = action_for_request(req) # map the request's path to a on-disk file path 
      response.headers['Content-Type'] = '...'
      response.headers['Content-Length'] = '...'
      # any other default headers
      
      send_response response, socket
    end
    socket.close
  end
  
  def send_response(response, socket)
    socket.print "HTTP/1.1 200 OK\r\n"
    response.headers.each do |k, v|
      socket.print "#{k}: #{v}\r\n"
    end
    socket.print "Connection: close"
    socket.print response.body
  end
  
  def run_server
    server = TCPServer.new('localhost', 2345)

    loop do 
      socket = server.accept

      request_line = socket.gets
      # STDERR.puts request_line
      # puts "hi"

      # line_array = []

      # while(line = socket.gets) != "\r\n"
      #   line_array << line
      # end

      # first_line = line_array.shift
      # http_method = first_line.split(' ')[0]
      # request_path = first_line.split(' ')[1]

      # headers = line_array.inject({}) do |h, line|
      #   key, val = line.split(": ")
      #   h.merge(key => val.strip)
      # end

      path = requested_file(request_line)

      path = File.join(path, 'index.html') if File.directory?(path)

      # open index page
      if File.exist?(path) && !File.directory?(path)
        File.open(path, "r+") do |file|
          @token = SecureRandom.base64
          
          socket.print "HTTP/1.1 200 OK\r\n" +
                       "Content-Type: #{content_type(file)}\r\n" +
                       "Content-Length: #{file.size}\r\n" +
                       "Set-Cookie: _kwipper_session=#{@token}; expires=0; username=#{@user}\r\n" +
                       "Connection: close\r\n"

          socket.print "\r\n"

          IO.copy_stream(file, socket)
          @login_user = CGI.parse(socket.read)
          @user = @login_user["username"]
          p @user

          send_data()
           
          file.write("#{@user} logged in")
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