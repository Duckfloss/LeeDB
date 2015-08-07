
class category
  # Constants
  KEY="id"

  # Constructor
  def initialize()
    @db_table_name = "categories"
    @uniteu_table_name = "departments"
    @db_column_names = [
      "id", "name", "parent", "description", "img", "rpro_id", "google_shopping_map"
    ]
    @uniteu_column_names => [
			"parent_id", "dept_id", "dept_name", "dept_description", "dept_image_1_file", "rpro_dept_id"
    ]
  end

  # Accessors
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

class product
  # Constructor
  def initialize()

  end


end

class shopper
  # Constructor
  def initialize()

  end


end

class order
  # Constructor
  def initialize()

  end


end
