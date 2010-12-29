
require 'polyglot'
require 'treetop'

Treetop.load "europa.tt"

filename = ARGV.last

parser = EuropaParser.new
result = parser.parse(File.open(filename).read)

if !result
  puts parser.failure_reason
else
  puts "Success!"
  p result
end

