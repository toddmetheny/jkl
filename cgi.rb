require 'uri'
require 'net/http'
require 'httparty'

uri = URI('http://localhost:2345')
# res = Net::HTTP.get_response(uri)
# res['Set-Cookie']
# res.get_fields('set-cookie')
# puts "Headers: #{res.to_hash.inspect}"

# res = Net::HTTP.post_form(uri, 'q' => 'ruby', 'max' => '100')
# puts res.body

# Net::HTTP.start(uri.host, uri.port) do |http|
#   request = Net::HTTP::Get.new uri
#   response = http.request request

#   puts response.body["tweet"]
# end

response = HTTParty.get('http://localhost:2345')

p response.body
p response.code 
p response.message
p response.headers.inspect