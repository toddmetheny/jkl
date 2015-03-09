require 'cgi'

cgi = CGI.new

value = cgi['tweet']

puts value