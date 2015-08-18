# Shared record methods
module Record

  # Load db schema
  DB_SCHEMA = JSON.parse(File.read('lib/leedb.json'), :symbolize_names=>true)
  # Load db map
  MAP = JSON.parse(File.read('lib/uniteu_leedb_map.json'), :symbolize_names=>true)

  # Builds map
  def Record.build_map(table)
    this_map = Hash.new
  	MAP[:"#{table}"][:fields].each { |k,v| this_map["#{k}"] = "#{v}" unless v==nil }
  	return this_map
  end

  # Builds object attributes
  def Record.build_attributes(table,data,map)
    attributes = Hash.new
    DB_SCHEMA[:"#{table}"][:FIELDS].each_key do |k|
      this_map = map.invert["#{k}"]
      attributes[:"#{k}"] = data[:"#{this_map}"]
    end
    return attributes
  end

end

class Category
  include Record

  # Constants
  KEY="id"
  TABLE="categories"

  # Constructor
  def initialize(data)
    @map = Record.build_map("departments")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end

  # Accessors
  def getMap
    @map
  end

  def getAttributes
    @attributes
  end

  def getUID
    @uid
  end
end

class ProductGroup
  include Record

  # Constants
  KEY="pf_id"
  TABLE="product_groups"

  # Constructor
  def initialize(data)
    @map = Record.build_map("products")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end

  # Accessors
  def getMap
    @map
  end

  def getAttributes
    @attributes
  end

  def getUID
    @uid
  end
end

class ProductItem
  include Record

  # Constants
  KEY="sku"
  TABLE="product_items"

  # Constructor
  def initialize(data)
    @map = Record.build_map("variants")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end

  # Accessors
  def getMap
    @map
  end

  def getAttributes
    @attributes
  end

  def getUID
    @uid
  end
end

class Customer
  include Record

  # Constants
  KEY="id"
  TABLE="customers"

  # Constructor
  def initialize(data)
    @map = Record.build_map("shoppers")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end

  # Accessors
  def getMap
    @map
  end

  def getAttributes
    @attributes
  end

  def getUID
    @uid
  end
end

class Order
  include Record

  # Constants
  KEY="id"
  TABLE="orders"

  # Constructor
  def initialize(data)
    @map = Record.build_map("salesorders")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = { "#{KEY}" => @attributes[:"#{KEY}"] }
  end

  # Accessors
  def getMap
    @map
  end

  def getAttributes
    @attributes
  end

  def getUID
    @uid
  end
end

class OrderItem
  include Record

  # Constants
  KEY=["id","sku"]
  TABLE = "order_items"

  # Constructor
  def initialize(data)
    @map = Record.build_map("salesorderssubitems")
    @attributes = Record.build_attributes(TABLE,data,@map)
    @uid = Hash.new
    KEY.each do |i|
      @uid["#{i}"] = @attributes[:"#{i}"]
    end
  end

  # Accessors
  def getMap
    @map
  end

  def getAttributes
    @attributes
  end

  def getUID
    @uid
  end
end
