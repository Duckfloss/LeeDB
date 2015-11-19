# Shared record methods
class Record

  attr_reader :type, :fields

  def initialize(data = {})
    create_record(data)
  end

  # Defines data types in singular and plural
  TYPES = [
    "category",
    "product_group",
    "product_item",
    "product_meta",
    "customer",
    "order",
    "order_item"
  ]

  TABLES = [
    "categories",
    "product_groups",
    "product_items",
    "product_meta",
    "customers",
    "orders",
    "order_items"
  ]

  # Creates the record object
  def create_record(data={}, type="")
    if data.empty?
      # Create blank record
      if type!="" AND !TYPES.find_index(type).nil?

      else
        @fields={}
      end
    elsif TYPES.find_index(type).nil?
      raise ArgumentError.new("Must indicate valid Record type")
    else

    end

    @type=type

  end







  class Category

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
end
