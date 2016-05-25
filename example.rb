require_relative 'wikidata_parse.rb'
require 'pp'

WikiData::Parser.parse($stdin) do |o|
  PP.pp o
end
