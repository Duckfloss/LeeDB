# Shared record methods
module Record

  # Load db schema
  DB_SCHEMA = JSON.parse(File.read('leedb/schemas/leedb.json'), :symbolize_names=>true)

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

class Category
  include Record

  # Constants
  KEY="id"
  TABLE="categories"

  attr_reader :map, :attributes, :uid

  # Constructor
  def initialize(data)
    @map = Record.build_map("departments")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end
end

class ProductGroup
  include Record

  # Constants
  KEY="pf_id"
  TABLE="product_groups"

  attr_reader :map, :attributes, :uid

  # Constructor
  def initialize(data)
    @map = Record.build_map("products")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
    @cat = [ @attributes.delete(:dept_id), @attributes[:pf_id] ]
  end
end

class ProductItem
  include Record

  # Constants
  KEY="sku"
  TABLE="product_items"

  attr_reader :map, :attributes, :uid

  # Constructor
  def initialize(data)
    @map = Record.build_map("variants")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end
end

class Customer
  include Record

  # Constants
  KEY="id"
  TABLE="customers"

  attr_reader :map, :attributes, :uid

  # Constructor
  def initialize(data)
    @map = Record.build_map("shoppers")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end
end

class Order
  include Record

  # Constants
  KEY="id"
  TABLE="orders"

  attr_reader :map, :attributes, :uid

  # Constructor
  def initialize(data)
    @map = Record.build_map("salesorders")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end
end

class OrderItem
  include Record

  # Constants
  KEY=["id","sku"]
  TABLE = "order_items"

  attr_reader :map, :attributes, :uid

  # Constructor
  def initialize(data)
    @map = Record.build_map("salesorderssubitems")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = Hash.new
    KEY.each do |i|
      @uid["#{i}"] = @attributes[:"#{i}"]
    end
  end
end
