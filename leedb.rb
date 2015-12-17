# Add leedb to load path
$LOAD_PATH << "./leedb"

# Require Gems
require 'sqlite3'
require 'json'
require 'xmlsimple'
require 'zip'
require 'date'
require 'csv'

# Require Classes
require 'db'
require 'record'
require 'import'
#require 'export'
require 'schema'


load './test_data.rb'

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
