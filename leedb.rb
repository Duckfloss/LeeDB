#!/usr/bin/env ruby

# This is the Lee's record import and export script.
#			-fFILE, --file FILE, Source file (csv,xml, or zip)
#			-dDB, --db DB, Set alternative sqlite database
#			-p, --practice, Run without sending to db
#			-v, --verbose, Verbose
#			-l, --log, Log output response
#			-h, --help, Prints help text

# Add leedb to load path
$LOAD_PATH << "./leedb"

# Gems
require 'optparse'
require 'ostruct'

# Subclasses
require 'record'
require 'import'
require 'db'
require 'parser'

load './test_data.rb'

module LeeDB

end


# >>> TEMP STUFF
options = Lee::Parser.parse($args)
puts options.to_h
$options = options
$log = LeeDB::Logger.new(options)

$x = LeeDB::Import.new(options.file)


#$w = LeeDB::Record.new("product_group")

#$x.records.each do |record|
#	record.send_to_db
#end

#>>>> END OF TEMP STUFF


# Run script
=begin
if __FILE__ == $0
	# Parse arguments
	options = Parser.parse(ARGV)

	# Initialize logging
	$log = LeeDB::Logger.new(options)
end

=end
