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

  # Constructor
  def initialize(data)
    @map = Record.build_map("departments")
    @attributes = Record.build_attributes("categories",data,@map)
  end

  # Accessors
  def getMap
    @map
  end

  def getAttributes
    @attributes
  end

end

class Product
  include Record

  # Constants
  KEY="id"
  UNITEUTABLE="departments"

  # Constructor
  def initialize()
    @map = Record.build_map(UNITEUTABLE)
  end

  # Accessors
  def getMap
    @map
  end


end

class Shopper
  include Record

  # Constants
  KEY="id"
  UNITEUTABLE="departments"

  # Constructor
  def initialize()
    @map = Record.build_map(UNITEUTABLE)
  end

  # Accessors
  def getMap
    @map
  end

end

class Order
  include Record

  # Constants
  KEY="id"
  UNITEUTABLE="departments"

  # Constructor
  def initialize()
    @map = Record.build_map(UNITEUTABLE)
  end

  # Accessors
  def getMap
    @map
  end

end
