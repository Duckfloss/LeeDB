$LOAD_PATH << "./lib"

require 'sqlite3'
require 'csv'
require 'json'
require 'date'
require 'records'
require 'test_data'
#require 'yaml'

# Load presets
$db_file = "lee.db"
$log = "logs/"+DateTime.now.strftime('%Y%m%d%H%M%S')+".txt"
#settings = YAML::load_file "settings.yml"
#os = settings["os"]

# Load commandline files to import
$files = []
ARGV.each do |a|
	$files << a
end

# Database field options
$db_type = [ 'TEXT','REAL','INTEGER' ]
$db_format = [ 'alpha16','char3','price','bool','url','int4','date','time','phone','email' ]
$db_rule = [ 'KEY','NOTNULL','UNIQUE' ]

# Load db schema
$db_schema = JSON.parse(File.read('./lib/leedb.json'), :symbolize_names=>true)
# Load db map
$map = JSON.parse(File.read('./lib/uniteu_leedb_map.json'), :symbolize_names=>true)

# Validate field data
def validate(string, format)
	# validation patterns
	formats = {
		:file => /\A[\S]+\.csv\Z/,
		:alpha16 => /\A[a-zA-Z]{16}\Z/,
		:char3 => /\A[\w\d\ \+\.\&]{2,3}\Z/,
		:int4 => /\A\d{4}\Z/,
		:price => /\A[\d\.]+\Z/,
		:bool => /\A(0|1|no|yes|true|false)\Z/,
		:url => /\A[\d\w]+\.+[\w]{1,4}\Z/,
		:date => /\A\d{2}\/\d{2}\/\d{2}\Z/,
		:time => /\A\d{2}\:\d{2}\:\d{2}\ (A|P)M\Z/,
		:phone => /\A[\d\-\(\)\.]+\Z/,
		:email => /\A[\w\d\.\#-\_\~\$\&\'\(\)\*\+\,\;\=\:\%]+\@[\w\d]+\.\w{1,4}\Z/
	}
	format = formats[:"#{format}"]
	!string[format].nil?
end

# Try to guess which table we're working on here
def guess_table(file)
	file.downcase!
	$map[:tables].each do |t|
		if file.match(t)
			table = t
			return table
		end
	end
	puts "What table does #{file} map to:\n"
	$map[:tables].each do |t|
		puts "\t#{t}\n"
	end
	table = gets.chomp
	return table
end

# Write to log
def write_log(string, code)
	# 10-19 = file errors
	# 20-29 = csv errors
	# 30-39 = data errors
	# 40-49 = sql input errors
	errors = {
		10=> "#{string} is not a valid file name",
		11=> "File name #{string} does not exist in this location",
		30=> "#{string} isn't the valid data type"
	}
	error_msg = errors[code]
	File.open($log, 'a') do |log|
		log.puts "#{error_msg}\n"
	end
end

# Update category
def update_category(data)
	query = "UPDATE #{$db_table} "
	keys = $this_schema[:FIELDS].keys
	revmap = $this_map.invert
	keys.each do |k|
		p = revmap["#{k}"]
		type = $this_schema[:FIELDS][:"#{k}"][:type]
		unless data[:"#{p}"].nil?
			case type
			when "INTEGER", "REAL"
					query << "#{k}="+data[:"#{p}"]+", "
				else
					query << "#{k}='"+data[:"#{p}"]+"', "
			end
		end
	end
	query.slice!(0, query.length-2)
	query << "WHERE #{keys[0].to_s}=#{values[0]}"
end

# Insert new category
def new_category(data)
	values = Array.new
	keys = $this_schema[:FIELDS].keys
	revmap = $this_map.invert
	keys.each do |k|
		p = revmap["#{k}"]
		type = $this_schema[:FIELDS][:"#{k}"][:type]
		case type
			when "INTEGER"
				values << data[:"#{p}"].to_i
			when "REAL"
				values << data[:"#{p}"].to_f
			else
				values << data[:"#{p}"]
		end
	end
	columns = keys.join(",")
	values = values.join(",")
	query = "INSERT INTO #{$db_table} (#{columns}) VALUES (#{values})"
end

# Splits variables from json files
def split_json_variables(string)
	string.split("-")
end

# Check UID
def uid_exists?(uid)
	query = ""
	uid_exists = false
	if uid.length<2
		uid.each do |k,v|
			query << "#{k}=#{v}"
		end
	else
		uid.each do |k,v|
			query << "#{k}=#{v} "
		end
		query.gsub!(" "," AND ")
	end
	uid_exists = true if $db.query("SELECT * FROM #{$db_table} WHERE #{query}").count > 0
	return uid_exists
end

# Interacts with SQlite database
def send_to_db(data, key)
	$db = SQLite3::Database.new "#{$db_file}"
	# Figure out the uid(s)
	uid = Hash.new
	if key.is_a?(Array)
		key.each do |k|
			skey = $this_map.key("#{k}")
			uid["#{k}"] = data[:"#{skey}"]
		end
	elsif key.is_a?(String)
		skey = $this_map.key("#{key}")
		uid["#{key}"] = data[:"#{skey}"]
	end
	uid_exists?(uid)
end

# Builds map
def build_map(table)
  this_map = Hash.new
	$map[:"#{table}"][:fields].each { |k,v| this_map["#{k}"] = "#{v}" unless v==nil }
	return this_map
end


def parse_csv(file)
	# Guess what kind of file it is
	$csv_table = guess_table(file)
	# Load corresponding schema
	$db_table = $map[:"#{$csv_table}"][:table]
	$this_map = build_map($csv_table)
	$this_schema = $db_schema[:"#{$db_table}"]
	key = $this_schema[:KEY]
	key = key.split("-") if key.match("-")

	# Break it open and go through rows
	rows = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol)
	rows.each do |row|
		# Variable switch will tell us if this row is trash
		trash = false
		# Create hash for holding this row's data intended for db
		sqlite_hash = Hash.new
		# Go through each row's fields
		row.each do |head, field|
			break if trash==true
			# What format should this field be?
			this_format = $this_schema[:"#{head}"][:format]
			# If there's no format, skip validation and put it in hash
			# If it validates, put it in the hash
			if this_format==nil || validate(field, :"#{this_format}") == true
				sqlite_hash["#{head}"] = "#{field}"
			else
				# If it's not valid, put it in the log and trash this row
				write_log(field,"30")
				trash = true
				break
			end
			# Put data in the db
			send_to_db(sqlite_hash, key)

		end
	end
end


# main function
def doit(files)
	# For each file
	files.each do |file|
		# Check if it's a csv
		if !validate(file,:file)
			write_log(file, 10)
			break
		else
			parse_csv(file)
		end
	end
end






=begin

def something()
	table = guess_table(file)

	# Open CSV file
	data = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol)

	data.each do |row|
		uid = db_schema[:"#{table}"]["KEY"]
		if check_uid(table, uid)
	end

	# open a new file
	File.open(csv_target, 'a') do |file|
		data.each do |row|
			if row[:desc] != nil
				row.each do |head,field|
					if head == :desc
						row[:desc] = formatify(field)
					end
				end
				file.puts row
			else
				file.puts row
			end
		end
	end
end


db = SQLite3::Database.new ":memory:"

# Create a database
rows = db.execute <<-SQL
  create table users (
    name varchar(30),
    age int
  );
SQL

csv = <<CSV
name,age
ben,12
sally,39
CSV

CSV.parse(csv, headers: true) do |row|
  db.execute "insert into users values ( ?, ? )", row.fields # equivalent to: [row['name'], row['age']]
end

db.execute( "select * from users" ) # => [["ben", 12], ["sally", 39]]
=end

# Run the main function
#doit($files)
