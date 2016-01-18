require 'json'

module LeeDB

# Grabs the relevant schema from JSON to hash or array
class Schema

	attr_reader :schema

	# Load db schema
	# defaults to db schema
	def initialize(type="db",table)
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
		return fields
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
