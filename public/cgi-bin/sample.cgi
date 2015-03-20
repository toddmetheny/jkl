#!/usr/bin/ruby

puts "Content-type: text/html" #text/plain
puts #mandatory blank line

puts <<END

# <h1>Sample Script</h1>
# This is a sample of a CGI script.
# END

# require 'cgi'
# cgi = CGI.new
# value = cgi['name']        # => "Zara"
# puts value
# names = cgi.params['name'] # => ["Zara", "Huma", "Nuha"]
# puts names

# p cgi.keys           # => ["name"]
# p cgi.params         # => {"name"=>["Zara", "Huma", "Nuha"]}
print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Hello Word - First CGI Program</title>';
print '</head>';
print '<body>';
print '<h2>Hello Word! This is my first CGI program</h2>';
print '</body>';
print '</html>';
END