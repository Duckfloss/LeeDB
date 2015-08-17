# Shared record methods
module Record
  # Builds map
  def Record.build_map(table)
    mapfile = JSON.parse(File.read('lib/uniteu_leedb_map.json'), :symbolize_names=>true)
    map = Hash.new
  	mapfile[:"#{table}"][:fields].each { |h,k| map["#{h}"] = "#{k}" unless k==nil }
  	return map
  end
end

class Category
  include Record

  # Constants
  KEY="id"
  UNITEUTABLE="departments"

  # Constructor
  def initialize
    @map = Record.build_map(UNITEUTABLE)
  end

  # Accessors
  def getMap
    @map
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
