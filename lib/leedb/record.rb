# Shared record methods
class Record

  attr_reader :type, :fields, :details

  # Defines data types in singular and plural
  TYPES = {
    "category"=>"categories",
    "product_group"=>"product_groups",
    "product_item"=>"product_items",
    "product_meta"=>"product_meta",
    "customer"=>"customers",
    "order"=>"orders",
    "order_item"=>"order_items"
  }
  TABLES = ["categories", "product_groups", "product_items", "product_meta", "customers", "orders", "order_items" ]

  def initialize(type, data = {})
    @type = type
    @data = data
    @details = create_record(TYPES[type])
  end

  # Creates a record object
  def create_record(type)

    details = {}

    if TABLES.find_index(type).nil? # check if type is valid
      raise ArgumentError.new("Must indicate valid Record type")
    else
      if @data.empty? # Create blank record
        schema = Schema.new("db")
        @fields = schema.get_fields(type)
        @fields.each do |field|
          details[field] = ""
        end
      else
        puts "TODO"
      end
    end

    return details

  end



  def inspect
    output = ""
    if @type.length > 0
      output << "@type = #{@type}\n"
      output << "@details = #{@details}\n"
    else
      output << "blank record\n"
    end
    return puts output
  end

end



=begin
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
=end
