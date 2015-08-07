
class category
  # Constructor
  def initialize()
    @db_table = "categories"
    @uniteu_table = "departments"
    @db_data = {
      "id" => "",
	    "name" => "",
	    "parent" => "",
	    "description" => "",
	    "img" => "",
	    "rpro_id" => "",
	    "google_shopping_map" => ""
    }
    @uniteu_data => {
			"parent_id" => "",
			"dept_id" => "",
			"dept_name" => "",
			"dept_description" => "",
			"dept_image_1_file" => "",
			"rpro_dept_id" => ""
    }
  end
			parent_id: parent,
			dept_id: id,
			dept_name: name,
			dept_description: description,
			dept_image_1_file: img,
			rpro_dept_id: rpro_id

  # Accessors
  def getDBTable
    @db_table
  end

  def getUniteUTable
    @uniteu_table
  end

  # Methods
  # Puts a row of UniteU data into a hash with database columns as keys
  def getUniteUData(row)
    @db_data = {
      "id" => row["dept_id"],
	    "name" => row["dept_name"],
	    "parent" => row["parent_id"],
	    "description" => row["dept_description"],
	    "img" => row["dept_image_1_file"],
	    "rpro_id" => row["rpro_dept_id"]
    }
  end

  # Creates a hash of data from UniteU with sqlite columns as keys
  def translateUUtoDB

  end

  # Creates a hash of data from the sqlite database with UniteU columns as keys
  def translateDBtoUU

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
