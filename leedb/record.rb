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
  TABLES = TYPES.values

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
      schema = Schema.new("db")
      @fields = schema.get_fields(type)
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
    return details
  end


  def inspect
    output = ""
    if @type.length > 0
      output << "<@type = #{@type} - "
      output << "@details = #{@details.to_s.slice(0,60)}...>\n"
    else
      output << "<blank record>\n"
    end
    return puts output
  end

end
