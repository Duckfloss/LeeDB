# Shared record methods
class Record < Lee

  attr_reader :type, :fields, :details, :uid

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
  TABLES = TYPES.values

  def initialize(type, data = {})
    @schema = Schema.new("db")
    @type = type
    @data = data
    @details = create_record(TYPES[type])
    @uid = get_uid(@schema.get_key(TYPES[type]))
  end

  # Creates a record object
  def create_record(type)
    details = {}
    if TABLES.find_index(type).nil? # check if type is valid
      raise ArgumentError.new("Must indicate valid Record type")
    else
      @fields = @schema.get_fields(type)
      if @data.empty? # Create blank record
        @fields.each do |field|
          details[field] = ""
        end
      else
        @fields.each do |field|
          details[field] = @data[field]
        end
      end
    end
    details
  end

  def get_uid(key)
    uid = []
    key.each do |k|
      i = { k => @details[k] }
      uid << i
    end
    uid
  end

  def inspect
    output = ""
    if @type.length > 0
      return @details
#      output << "<@type = #{@type} - "
#      output << "@details = #{@details.to_s.slice(0,60)}...>\n"
    else
#      output << "<blank record>\n"
#    end
    return output
    end
  end

  def send_to_db
    db = DB.new
    

  end

end
