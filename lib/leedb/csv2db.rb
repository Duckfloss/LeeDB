# Load commandline files to import
$files = []
ARGV.each do |a|
	$files << a
end


# Validate field data
def validate(string, format)
	# validation patterns
	formats = {
		"file" => /\A[\S]+\.csv\Z/,
		"alpha16" => /\A[a-zA-Z]{16}\Z/,
		"char3" => /\A[\w\d\ \+\.\&]{2,3}\Z/,
		"int4" => /\A\d{4}\Z/,
		"price" => /\A[\d\.]+\Z/,
		"bool" => /\A(0|1|no|yes|true|false)\Z/,
		"url" => /\A[\d\w]+\.+[\w]{1,4}\Z/,
		"date" => /\A\d{2}\/\d{2}\/\d{2}\Z/,
		"time" => /\A\d{2}\:\d{2}\:\d{2}\ (A|P)M\Z/,
		"phone" => /\A[\d\-\(\)\.]+\Z/,
		"email" => /\A[\w\d\.\#-\_\~\$\&\'\(\)\*\+\,\;\=\:\%]+\@[\w\d]+\.\w{1,4}\Z/
	}
	if string == " " || string == nil
		return false
	else
		format = formats["#{format}"]
		return !string.to_s[format].nil?
	end
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

# Check if UID exists
def uid_exists?(uid)
	uid_exists = false
	values = []
	q = "SELECT * FROM #{$db_table} WHERE"
	uid.each do |k,v|
		q << " #{k}=?,"
		values << v
	end
	q.chomp!(",")
	q.gsub!(","," AND ")
	query = $db.prepare "#{q}"
	query.bind_params(values)
	uid_exists = true if query.execute.count > 0
	return uid_exists
end

# Interacts with SQlite database
def send_to_db(record)
	# Check if record exists in db
	# If not, insert it
	if !uid_exists?(record.getUID)
		keys = ""
		values = []
		record.getAttributes.each do |k,v|
			keys << "#{k},"
			values << v
		end
		keys.chomp!(",")
		q = "INSERT INTO #{$db_table} (#{keys}) VALUES ("
		values.each { q << "?," }
		q.chomp!(",")
		q << ")"
		query = $db.prepare "#{q}"
		query.bind_params(values)
	else # If it does exist, then we are updating it
		keys = []
		values = []
		where = ""
		wherev = []
		record.getUID.each do |k,v|
			record.getAttributes.delete(:"#{k}")
			where << " #{k}=?,"
			wherev << v
		end
		where.chomp!(",")
		where.gsub!(","," AND ")
		record.getAttributes.each do |k,v|
			keys << k.to_s
			values << v
		end
		q = "UPDATE #{$db_table} SET"
		keys.each { |key| q << " #{key}=?," }
		q.chomp!(",")
		q << " WHERE #{where}"
		wherev.map { |v| values << v }
		query = $db.prepare "#{q}"
		query.bind_params(values)
	end
	query.execute
end

# Specifically updates product_meta table
def send_cat_to_db(cat)
	# Check if it exists already
	find = $db.prepare "SELECT * FROM product_meta WHERE category_id=? AND pf_id=?"
	find.bind_params(cat)
	# And if it doesn't exist, insert it
	if find.execute.count < 1
		query = $db.prepare "INSERT INTO product_meta (category_id, pf_id) VALUES (?,?)"
		query.bind_params(cat)
		query.execute
	end
end

# Builds map
def build_map(table)
  this_map = Hash.new
	$map[:"#{table}"][:fields].each { |k,v| this_map["#{k}"] = "#{v}" unless v==nil }
	return this_map
end

# Chooses and creates Record
def create_record(table,data)
	record = case table
		when "product_items" then ProductItem.new(data)
		when "product_groups" then ProductGroup.new(data)
		when "orders" then Order.new(data)
		when "order_items" then OrderItem.new(data)
		when "customers" then Customer.new(data)
		when "categories" then Category.new(data)
		else "unknown"
	end
end


def parse_csv(file)
	puts "file" # REMOVE THIS <<<<<<<<
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

	# Open database
	$db = SQLite3::Database.new "#{$db_file}"

	# To count rows
	rowno = 1
	rows.each do |row|
		# Variable switch will tell us if this row is trash
#		trash = false
		rowno += 1 # Iterate row
		puts "#{rowno}..." # REMOVE THIS <<<<<<<<
		# Creates record object
		record = create_record($db_table,row)
		# Gets record attributes
#		fields = record.getAttributes unless record == "unknown"
#		fields.each do |k,v|
			# Validate each field
#			format = $this_schema[:FIELDS][:"#{k}"][:format]
#			if format!=nil && validate(v, format)!=true
#				error="#{file}::#{rowno}::#{k}/#{v}"
#				write_log(error,"30")
#			end
#		end

		# This just splits out "product_groups" so we can categorize
		# in another table
		if $db_table!="product_groups"
			send_to_db(record)
		else
			send_to_db(record)
			if !record.getCat[0].nil?
				send_cat_to_db(record.getCat)
			end
		end
	end

#ensure
#	$db.close if $db
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


# Run the main function
#doit($files)
