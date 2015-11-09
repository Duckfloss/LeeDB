# # Converts exports from UniteU to LeeDB format
#
# UniteU outputs data as csv files. This parses the files into
# a format we can use to import data into our LeeDB.

class UniteU
	include Map
	include Record


	attr_reader :record_type


	def initialize(file)
		@file = file
		@record_type = guess_record_type(file)
#		parse_csv(file)

	end

	# Validate field data
	def validate(string, format)
		# validation patterns
		formats = {
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

	# Try to guess which type of record we're importing
	def guess_record_type(file)
		file.downcase!
		MAP[:tables].each do |t|
			if file.match(t)
				table = t
				return table
			end
		end
		puts "What type of record is #{file}?\n"
		MAP[:tables].each do |t|
			puts "\t#{t}\n"
		end
		table = gets.chomp
		return table
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
		$csv_table = guess_record_type(file)
		# Load corresponding schema
		$db_table = $map[:"#{$csv_table}"][:table]
		$this_map = build_map($csv_table)
		$this_schema = $db_schema[:"#{$db_table}"]
		key = $this_schema[:KEY]
		key = key.split("-") if key.match("-")

		# Break it open and go through rows
		rows = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol)

		# To count rows
		rowno = 1
		rows.each do |row|
			# Variable switch will tell us if this row is trash
	#		trash = false
			rowno += 1 # Iterate row
			puts "#{rowno}..." # REMOVE THIS <<<<<<<<
			# Creates record object
			record = create_record($db_table,row)

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

	end
end
