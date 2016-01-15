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
require 'pry'

# Subclasses
require 'record'
require 'import'
require 'db'

load './test_data.rb'

module LeeDB
	class Logger

		attr_reader :iterator, :message, :insert, :update, :fail

		def initialize(options)
			@iterator = 0
			@message = []
			@insert ||= []
			@update ||= []
			@fail ||= []
			if options.log
				t = Time.now.strftime("%Y%m%d%H%M%S")
				@log = File.new("logs/log#{t}.txt", mode="w+")
			end
		end

		def message!(msg)
			@message << msg
		end

		def insert!(table,item)
			@insert << [table,item]
		end

		def update!(table,item)
			@update << [table,item]
		end

		def fail!(table,item)
			@fail << [table,item]
		end

		def increment
			@iterator += 1
		end

		def write_interstitial
			output = ""
			@message.each do |message|
				output << "#{message}\n"
			end
			if options.verbose
				puts output
			end
			if options.log
				@log.write(output)
			end
		end

		def write_end
			output = ""
			insert_number = @insert.length
			update_number = @update.length
			output << "Records inserted: #{insert_number}\n"
			output << "Records updated: #{update_number}\n"
			if @fail.length > 0
				output << "The following items couldn't be put in the database:\n"
				@fail.each do |item|
					output << "\t#{item[1]} - #{item[0]}\n"
				end
			end

		end
	end
end

class Parser

	def self.parse(args)
		options = OpenStruct.new
		options.file = nil
		options.db = "../lee.db"
		options.practice = false
		options.verbose = false
		options.log = false

		opt_parser = OptionParser.new do |opt|
			opt.banner = "Usage: leedb.rb [options]"
			opt.separator ""
			opt.separator "Options:"

			opt.on("-fFILE", "--file FILE", "Source file (csv,xml, or zip)") do |file|
				if file.nil?
					puts "We need a file to pull data from."
				end
				# Validate source
				if !file =~ /\.(csv|xml|zip){1}$/
					puts "We need a csv, xml, or zip file. Try again."
				end
				if File.exist?(file)
					options.file = file
				else
					puts "We can't find that file. Try pasting the full file path here."
				end
			end

			opt.separator ""

			opt.on("-dDB", "--db DB", "Set alternative sqlite database") do |db|
				if !db =~ /\.db$/
					puts "Database should be a valid SQLite file. The filename should end in \".db\""
				end
				if File.exist?(db)
					options.db = db
				else
					puts "We can't find that database. Try pasting the full file path here."
				end
			end

			opt.separator ""

			opt.on("-p", "--practice", "Run without sending to db") do |practice|
				options.practice = practice
			end

			opt.separator ""

			opt.on("-v", "--verbose", "Run chattily (or not)") do |verbose|
				options.verbose = verbose
			end

			opt.separator ""

			opt.on("-l", "--log", "Log results to a file") do |log|
				options.log = log
			end

			opt.separator ""

			opt.on_tail("-h","--help","Prints this help") do
				puts opt
				exit
			end
		end

		opt_parser.parse!(args)
		options
	end
end



# >>> TEMP STUFF
binding.pry
options = Parser.parse($args)
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

def unzip(file)
	Zip::File.open(file) do |zip_file|
		# Handle entries one by one
		zip_file.each do |entry|
			# Extract to file/directory/symlink
			puts "Extracting #{entry.name}"
		end
	end
end
=end

# guesstype(filename)
#
# What type of data is this? This method will tell you
# based on what the filename is.
def guesstype(filename)
	type = case filename
		when /^A/ then "salesorders"
		when /^G/ then "images"
		when /^N/ then "products"
		when /^S/ then "customer"
		when /^X/ then "prefs"
		else "unknown"
	end
end


# extractZip(zip)
#
#
def extractZip(zip)
	temp_dir = "#{File.dirname(zip)}/tmp"
	type = guesstype(zip)

	# if temp directory doesn't exist, make it
	if !Dir.exist?(temp_dir)
		Dir.mkdir(temp_dir)
	end

	Zip::File.open(zip) do |zip_file|
		zip_file.glob("*.xml").each do |xml_file|
			destination = "#{temp_dir}/#{xml_file}"
			xml_file.extract(destination)
		end
	end

	#then parse files
	Dir.foreach(temp_dir) do |xml_file|
		fromxml(xml_file,type)
	end
	#then delete tempdirectory
#	Dir.rmdir(tempdir)
end


def dothething
	# Open the database
	db = DB.new($db)

	zipdir = "/Users/benjones/Documents/Projects/Lees/LeeDB/data/zips"
	# get a list of files from $dir
	zips = Dir.entries(zipdir).keep_if{|v| v=~/zip/}

	# We're only bringing in items right now
	# Each zip file
	zips.each do |zip|
		# Full file path
		thiszip = zipdir+"/"+zip
		# Unzip
		Zip::File.open(thiszip) do |unzipped|
			# Make a temporary directory
			tempdir = thiszip.slice(0,thiszip.index("."))
			Dir.mkdir(tempdir)
			# Find just the xmls
			unzipped.glob("*.xml").each do |file|
				# Find just the product data
				if file.name.include?("ECStyle")
					# Extract product data file to the temp directory
					thisfile = tempdir+"/"+file.name
					file.extract(thisfile)
					# Make an RProRecord with this product data
					records = RProRecord.new(thisfile)
					records.Products.each do |table,record_group|
						if !record_group[0].nil?
							record_group.each do |record|

								# Check if the UID exists
								uid = {}
								keys = $db_schema[:"#{table}"][:KEY]
								keys.each { |key| uid["#{key}"] = record["#{key}"] }
								if db.uid_exists?(table,uid)
									db.update(table,record,uid)
								else
									db.insert(table,record)
								end
							end
						end
					end
					File.delete(thisfile)
				end
			end
			Dir.rmdir(tempdir)
		end
	end
end
