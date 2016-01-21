#!/usr/bin/env ruby

# This is the Lee's record import and export script.
#			-fFILE, --file FILE, Source file (csv,xml, or zip)
#			-dDB, --db DB, Set alternative sqlite database
#			-p, --practice, Run without sending to db
#			-v, --verbose, Verbose
#			-l, --log, Log output response
#			-h, --help, Prints help text

# Add leedb to load path
$LOAD_PATH << "./"

# Subclasses
require 'leedb/record'
require 'leedb/import'
require 'leedb/parser'
require 'leedb/logger'


module LeeDB

end




# Run script
=begin
if __FILE__ == $0
	# Parse arguments
	options = Parser.parse(ARGV)

	# Initialize logging
	$log = LeeDB::Logger.new(options)
end

=end
