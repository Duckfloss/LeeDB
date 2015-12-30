#!/usr/bin/env ruby

# This is the Lee's record import and export script.
#			-h, --help, Prints help text
#			-v, --verbose, Verbose
#			-l, --log, Log output response
#			-p, --practice, Run without sending to db
#			-fFILE, --file FILE, Source file (csv,xml, or zip)
#			-dDB, --db DB, Set alternative sqlite database

# Add leedb to load path
$LOAD_PATH << "./leedb"

# Require Gems
require 'optparse'
require 'ostruct'
require 'pry'

	# Requirements
	require 'record'
#	require 'db'

module LeeDB

	def IOMessage
		IOMessage = {
			:vmessage => "",
			:dbcounter => { :import => 0, :update => 0 }
		}
	end
end

load './test_data.rb'

$database = "../lee.db"

#$w = Lee.new.IOMessage
$x = Lee::Record::Import.new($ufile)

#puts Lee.IOMessage

#$x.records.each do |record|
#	record.send_to_db
#end



class Parser

	FORMATS = ["all","t","med","lg","sw"]

	def self.parse(args)
		options = OpenStruct.new
		options.format = ["all"]
		options.eci = false
		options.source = nil
		options.dest = nil
		options.verbose = false

		opt_parser = OptionParser.new do |opt|
			opt.banner = "Usage: limg.rb [options]"
			opt.separator ""
			opt.separator "Options:"

			opt.on("--source SOURCE", "Sets source file or directory", "  default is Downloads/WebAssets") do |source|
				# Validate source
				if !File.directory?(source)
					if File.exist?(source)
						options.source = { "file"=>source }
					end
				else
					options.source = { "dir"=>source }
				end

				if options.source.nil?
					puts "error" #error
				end
			end

			opt.separator ""

			opt.on("--dest DEST", "Sets destination directory", "  defaults are R:/RETAIL/IMAGES/4Web", "  and R:/RETAIL/RPRO/Images/Inven") do |dest|
				if !Dir.exist?(dest)
					puts "error" #error
				else
					options.dest = dest
				end
			end

			opt.separator ""

			opt.on("-e", "--eci", "Parses pic(s) to ECI's directory", "  as well as to default or selected destination") do
				options.eci = true
			end

			opt.separator ""

			opt.on("-fFORMAT", "--format FORMAT", Array, "Select output formats", "  accepts comma-separated string", "  output sizes are t,sw,med,lg", "  default is \"all\"") do |formats|
				formats.each do |format|
					if FORMATS.index(format.downcase).nil?
						puts "error" #error
						exit
					end
					options.format = formats
				end
			end

			opt.separator ""

			opt.on("-v", "--verbose", "Run chattily (or not)", "  default runs not verbosely") do |v|
				options.verbose = true
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

def unzip(file)
	Zip::File.open(file) do |zip_file|
		# Handle entries one by one
		zip_file.each do |entry|
			# Extract to file/directory/symlink
			puts "Extracting #{entry.name}"
		end
	end
end


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

# Run Program
if __FILE__ == $0

	options = Parser.parse(ARGV)
	#puts options.to_h
	#Image_Chopper.new(options)

end
