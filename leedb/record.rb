require 'xmlsimple'
require 'zip'
#require 'date'
require 'csv'
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

	def send_to_db
		db = DB.new
		if db.uid_exists?(@table,@uid)
			db.update(@table, @details, @uid)
		else
			db.insert(@table, @details)
		end
#		db.close
	end

end
end
