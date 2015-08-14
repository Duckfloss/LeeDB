
class Category
  # Constants
  KEY="id"
  UNITEUTABLE="departments"

  # Constructor
  def initialize
    @map = build_map
  end



  # Accessors
  def getMap
    @map
  end

  def getDBTableName
    @db_table_name
  end

  def getUniteUTableName
    @uniteu_table_name
  end

  def getDBColumnNames
    @db_column_names
  end

  def getUniteUColumnNames
    @uniteu_column_names
  end

  # Methods
  # Builds map
  def build_map
    mapfile = JSON.parse(File.read('lib/uniteu_leedb_map.json'), :symbolize_names=>true)
    map = Hash.new
  	mapfile[:"#{UNITEUTABLE}"][:fields].each { |h,k| map["#{h}"] = "#{k}" unless k==nil }
  	return map
  end

  # Puts a row of UniteU data into a hash with database columns as keys
  def getUUData(row)
    data = {
      "id" => row["dept_id"],
	    "name" => row["dept_name"],
	    "parent" => row["parent_id"],
	    "description" => row["dept_description"],
	    "img" => row["dept_image_1_file"],
	    "rpro_id" => row["rpro_dept_id"]
    }
  end

  # Puts a row of database data into a hash with UniteU columns as keys
  def getDBData(row)
    data = {
      "dept_id" => row["id"],
	    "dept_name" => row["name"],
	    "parent_id" => row["parent"],
	    "dept_description" => row["description"],
	    "dept_image_1_file" => row["img"],
	    "rpro_dept_id" => row["rpro_id"]
    }
  end

end

class Product
  # Constructor
  def initialize()

  end


end

class Shopper
  # Constructor
  def initialize()

  end


end

class Order
  # Constructor
  def initialize()

  end


end
