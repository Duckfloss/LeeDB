
class DB::Schema
  # Load db schema
  DB_SCHEMA = JSON.parse(File.read('leedb/schemas/leedb.json'), :symbolize_names=>true)

  def initialize

  # Builds object attributes
  def Record.build_attributes(table,data,map)
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
