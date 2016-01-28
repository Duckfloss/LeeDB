require 'sqlite3'
require 'leedb/schema'

module LeeDB

class Record

	attr_reader :type, :fields, :details, :uid, :schema

	# Defines data types in singular and plural
	TYPES = {
		"category"=>"categories",
		"product_group"=>"product_groups",
		"product_item"=>"product_items",
		"product_meta"=>"product_meta",
		"customer"=>"customers",
		"order"=>"orders",
		"order_item"=>"order_items"
	}
	TABLES = TYPES.values

	def initialize(type, data = {})
		@type = type
		@table = TYPES[type]
		@schema = Schema.new("db",@table)
		@data = data
		@details = create_record(@table)
		@uid = get_uid(@schema.get_key(@table))
	end

	# Creates a record object
	def create_record(type)
		details = {}
		if TABLES.find_index(type).nil? # check if type is valid
			raise ArgumentError.new("Must indicate valid Record type")
		else
			@fields = @schema.get_fields
			if @data.empty? # Create blank record
				@fields.each do |field|
					details[field] = ""
				end
			else
				@fields.each do |field|
					details[field] = @data[field]
				end
			end
		end
		details
	end

	def get_uid(key)
		uid = {}
		key.each do |k|
			uid[k] = @details[k]
		end
		uid
	end

	def inspect
		if @type.length > 0
			return @details
		else
			return "<blank record>\n"
		end
	end

	def valid?(data,field)
		@schema.valid?(data,field)
	end

	def send_to_db
		# Validate first
		@details.each do |k,v|
			if !valid?(v,k)
				return 0
			end
		end

		begin
			@db = SQLite3::Database.new "#{$database}"
			if self.uid_exists?(@table,@uid)
				self.update(@table, @details, @uid)
			else
				self.insert(@table, @details)
			end
		rescue
			puts "Exception occurred"
			puts e
		ensure
			@db.close if @db
#			return 1
		end
	end

	# Insert record into database
	# table is the name of the table in the database
	# hash is a hash of field names and values to insert
	def insert(table, hash)
		keys = ""
		values = []
		q = ""
		hash.each do |k,v|
			keys << "#{k},"
			values << v
			q << "?,"
		end
		keys.chomp!(",")
		q.chomp!(",")
		begin
			query = @db.prepare "INSERT INTO #{table} (#{keys}) VALUES (#{q})"
			query.bind_params(values)
			query.execute
		rescue SQLite3::Exception => e
			puts "Exception occurred"
			puts e
			puts "INSERT INTO #{table} (#{keys}) VALUES (#{q})"
		ensure
			query.close if query
		end
	end

	# Update existing record
	# table is the name of the table in the database
	# hash is a hash of field names and values to insert
	# uid is a hash of the field names and values of the key data fields
	def update(table, hash, uid)
		keys = ""
		values = []
		conditions = ""
		hash.each do |k,v|
			if !v.nil?
				keys << "#{k}=?,"
				values << v
			end
		end
		keys.chomp!(",")
		uid.each do |k,v|
			conditions << "#{k}=\"#{v}\","
		end
		conditions.chomp!(",")
		conditions.gsub!(","," AND ")
		begin
			query = @db.prepare "UPDATE #{table} SET #{keys} WHERE #{conditions}"
			query.bind_params(values)
			query.execute
		rescue SQLite3::Exception => e
			puts "Exception occurred"
			puts e
		ensure
			query.close if query
		end
	end

	# Check if UID exists
	# table is the name of the table in the database
	# uid is a hash of the field names and values of the key data fields
	def uid_exists?(table, uid)
		uid_exists = false
		conditions = ""
		values = []
		uid.each do |k,v|
			conditions << " #{k}=?,"
			values << v
		end
		conditions.chomp!(",")
		conditions.gsub!(","," AND ")
		begin
			query = @db.prepare "SELECT * FROM #{table} WHERE #{conditions}"
			query.bind_params(values)
			uid_exists = true if query.execute.count > 0
		rescue SQLite3::Exception => e
			puts "Exception occurred"
			puts e
			puts "uid_exists? - SELECT * FROM #{table} WHERE #{conditions}"
		ensure
			query.close if query
		end
		uid_exists
	end

	# Lists the tables in the database
	def listtables
		thesetables = []
		tables = @db.execute "SELECT name FROM sqlite_master WHERE type='table'"
		tables.each { |table| thesetables << table[0] }
		thesetables
	end


end
end
