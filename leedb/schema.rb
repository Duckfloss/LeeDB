require 'json'

module LeeDB

# Grabs the relevant schema from JSON to hash or array
class Schema

	attr_reader :schema

	# Load db schema
	# defaults to db schema
	def initialize(type,table)
		@json_file = which_schema?(type)
		schema = JSON.parse(File.read(@json_file), :symbolize_names=>true)
		@schema = schema[table.to_sym]
	end

	def inspect
		"#{@schema.to_s.slice(0,35)} . . ."
	end

	def get_fields
		fields = []
		@schema[:FIELDS].each_key do |field_name|
			fields << field_name.to_s
		end
		fields
	end

	def get_key(table)
		@schema[:KEY]
	end

	# Pick schema [db, uniteu, rpro, or google_shopping]
	def which_schema?(type)
		json_file = case type
			when "db" then "leedb/schemas/leedb.json"
			when "uniteu" then nil
			when "rpro" then nil
			when "google_shopping" then nil
			else nil
		end
	end

	# Is data valid?
	#
	# Returns:
	#   0 on false
	#   1 on true
	#  -1 if everything else passes but it needs a uniqueness check
	#
	def valid?(data,field)
		valid = 1

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

		its = @schema[:FIELDS][field.to_sym]
		type = its[:type]
		rules = its[:rules].split("-") unless its[:rules].nil?
		format = its[:format]
		default = its[:default]

		if data.nil? || data == ""
			if !default.nil?
				data = default
				return 1
			else
				if !rules.nil? && rules.include?("NOTNULL")
					return 0
				end
			end
			return 1
		end

		if !format.nil?
			if (data =~ formats[format]) == nil
				return 0
			end
		end

		case type
		when "INTEGER"
			if (data =~ /\d*/) == nil
				return 0
			end
		when "REAL"
			if (data =~ /[\d\.]*/) == nil
				return 0
			end
		end

		if !rules.nil? && rules.include?("UNIQUE")
			return -1
		end

		valid
	end

	# Builds object attributes
	def build_attributes(table,data,map)
		attributes = Hash.new
		DB_SCHEMA[:"#{table}"][:FIELDS].each_key do |k|
			this_map = map.invert["#{k}"]
			type = DB_SCHEMA[:"#{table}"][:FIELDS][:"#{k}"][:type]
			if data[:"#{this_map}"]==" " || data[:"#{this_map}"]==nil
				attributes[:"#{k}"] = nil
			else
				case type
					when "REAL" then attributes[:"#{k}"] = data[:"#{this_map}"].to_f
					when "INTEGER" then attributes[:"#{k}"] = data[:"#{this_map}"].to_i
					when "TEXT" then attributes[:"#{k}"] = data[:"#{this_map}"].to_s
				end
			end
		end
		return attributes
	end
end
end
