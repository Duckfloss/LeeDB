
require 'sqlite3'
require 'csv'
require 'json'
require 'date'
#require 'yaml'

# Load presets
$db = "lee.db"
$log = "/logs/"+DateTime.now.strftime('%Y%m%d%H%M%S')+".txt"
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
$db_schema = JSON.parse(File.read('leedb.json'), :symbolize_names=>true)
# Load db map
$map = JSON.parse(File.read('uniteu_leedb_map.json'), :symbolize_names=>true)

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

# Check UID
def check_uid(table, uid)

end

# Update product
def update_product(data)

end

# Insert new product
def new_product(data)

end

# Update customer
def update_customer(data)

end

# Insert new customer
def new_customer(data)

end

# Insert new order
def new_order(data)

end

# Update category
def update_category(data)

end

# Insert new category
def new_category(data)

end

# Splits variables from json files
def split_json_variables(string)
	string.split("-")
end

# Builds a hash to map source data for processing
def build_map(table)
	x = $map[:"#{table}"][:fields]
	map_hash = Hash.new
	x.each do |head,field|
		unless field==nil
			map_hash["#{head}"] = "#{field}"
		end
	end
end



def parse_csv(file)
	# Guess what kind of file it is
	csv_table = guess_table(file)
	# Load corresponding schema
	db_table = $map[:"#{csv_table}"][:table]
	this_map = build_map(csv_table)
	schema = $db_schema[:"#{db_table}"]
	uid = schema[:KEY]

	# Break it open and go through rows
	rows = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol)
	rows.each do |row|
		# Create hash for holding this row's data intended for db
		sqlite_hash = Hash.new
		# Go through each row's fields
		row.each do |head, field|
			# What format should this field be?
			this_format = schema[:"#{head}"][:format]
			# If there's no format, skip validation and put it in hash
			# If it validates, put it in the hash
			if this_format==nil || validate(field, :"#{this_format}") == true
				sqlite_hash["#{head}"] = "#{field}"
			else
				# If it's not valid, put it in the log and move on
				write_log(field,"30")
				break
			end
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
doit($files)
