require 'uri'
# require 'net/http'
require 'httparty'

require './http.rb'

class Test < SimpleServer
  def return_responses
    response = HTTParty.get('http://localhost:2345/index.html')
    p response.body
    p response.code 
    p response.message
    p response.headers.inspect
  end

  def return_username
    puts @login_user
  end
end

test = Test.new
test.return_username
# test.return_responses


# uri = URI.parse('http://localhost:2345')
# http = Net::HTTP.new(uri.host, uri.port)

# request = Net::HTTP::Get.new("/search?question=somequestion")
# response = http.request(request)

# response.code

# case response
# when HTTPSuccess
#   response.body
# when HTTPRedirect
#   follow_redirect(response) # you would need to implement this method
# else
#   raise StandardError, "Something went wrong :("
# end

# require 'net/http'                  # The library we need
# host = 'www.tutorialspoint.com'     # The web server
# path = '/index.htm'                 # The file we want 

# http = Net::HTTP.new(host)          # Create a connection
# headers, body = http.get(path)      # Request the file
# if headers.code == "200"            # Check the status code   
#   print body                        
# else                                
#   puts "#{headers.code} #{headers.message}" 
# end


# require 'uri'
# # # require 'net/http'
# require 'httparty'
# require 'cgi'
# require 'webrick'
# require 'stringio'

# uri = URI('http://localhost:2345')
# # cgi = CGI.new
# # p cgi['Tweet']

# # puts cgi.params
# # res = Net::HTTP.get_response(uri)
# # res['Set-Cookie']
# # res.get_fields('set-cookie')
# # puts "Headers: #{res.to_hash.inspect}"

# # # res = Net::HTTP.post_form(uri, 'q' => 'ruby', 'max' => '100')
# # # puts res.body

# # # Net::HTTP.start(uri.host, uri.port) do |http|
# # #   request = Net::HTTP::Get.new uri
# # #   response = http.request request

# # #   puts response.body["tweet"]
# # # end


# req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
# req.parse(StringIO.new(http://localhost:2345))

# puts req.path
# req.each { |head| puts "#{head}:  #{req[head]}" }
# puts req.body




# w = WEBrick::HTTPRequest.request_uri
# p w

# end

# # socket.write(return_responses)

# require "cgi"
# cgi = CGI.new
# value = cgi['tweet']   # <== value string for 'field_name'
#   # if not 'field_name' included, then return "".
# params = cgi.params
# p cgi.params
# fields = cgi.keys            # <== array of field names
# p fields

# # returns true if form has 'field_name'
# cgi.has_key?('tweet')
# cgi.has_key?('tweet')
# cgi.include?('tweet')

# 10001 % ruby19
# require 'cgi'
# cgi = CGI.new("html5") # add HTML generation methods
# cgi.out do
#  cgi.html do
#    cgi.head { "\n"+cgi.title { "This Is a Test"} } +
#    cgi.body do "\n"+
#      cgi.form do"\n"+
#      cgi.hr +
#      cgi.h1 { "A Form: " } + "\n"+
#      cgi.textarea("get_text") +"\n"+
#      cgi.br +
#      cgi.submit
#      end
#    end
#  end
# end

# require 'cgi'
# cgi = CGI.new
# cgi['name']        # => "Zara"
# cgi.params['name'] # => ["Zara", "Huma", "Nuha"]
# cgi.keys           # => ["name"]
# cgi.params         # => {"name"=>["Zara", "Huma", "Nuha"]}
