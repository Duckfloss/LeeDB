class Import

  attr_reader :file, :data_source, :source_type, :records, :map, :json, :data, :record_type

  def initialize(file)
    @file = file
    @data_source = guess_source
    @json = JSON.parse(File.read("leedb/maps/#{@data_source}.json"), :symbolize_names=>true)
    @source_type = guess_source_type
    @record_type = @json[:"#{@source_type}"][:type]
    @map = @json[:"#{@source_type}"][:fields]
    @data = parse_csv(@file)
    @records = convert(@data)

  end

  def inspect
    return "File=\"#{@file.to_s}\""
#    output = ""
#    @records.each do |i|
#      output << "#{i[:pf_id]}\n"
#    end
#    return output
  end

  # Guess where this data comes from
  def guess_source
    # Typically csv files come from UniteU
    if @file =~ /\.csv$/ then return source = "uniteu"
    # While xml files come from RPro
    elsif @file =~ /\.xml$/ then return source = "rpro"
    # Otherwise toss out an error
    else
      raise "Error: No map exists"
    end
  end

  # Guess the record type based on source and file name
  def guess_source_type
    table = ""
    if @data_source == "uniteu"
      @json[:tables].each do |t|
        if @file.downcase.match(t)
          table << t
        end
      end
    elsif @source == "rpro"
      ## TODO
    end
    table
  end

  # Validate field data
  def validate(string, format)
    # validation patterns
    formats = {
      "alpha16" => /\A[a-zA-Z]{16}\Z/,
      "char3" => /\A[\w\d\ \+\.\&]{2,3}\Z/,
      "int4" => /\A\d{4}\Z/,
      "price" => /\A[\d\.]+\Z/,
      "bool" => /\A(0|1|no|yes|true|false)\Z/,
      "url" => /\A[\d\w]+\.+[\w]{1,4}\Z/,
      "date" => /\A\d{2}\/\d{2}\/\d{2}\Z/,
      "time" => /\A\d{2}\:\d{2}\:\d{2}\ (A|P)M\Z/,
      "phone" => /\A[\d\-\(\)\.]+\Z/,
      "email" => /\A[\w\d\.\#-\_\~\$\&\'\(\)\*\+\,\;\=\:\%]+\@[\w\d]+\.\w{1,4}\Z/
    }
    if string == " " || string == nil
      return false
    else
      format = formats["#{format}"]
      return !string.to_s[format].nil?
    end
  end

def parse_csv(file)
  # Initialize array
  data = []
  # Break open CSV and go through rows
  begin
    data = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol, :encoding => 'UTF-8')
  rescue Exception => e
    # Convert to UTF-8 if necessary
    data = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol, :encoding => 'Windows-1252:UTF-8')
  end
  data
end

# Creates an Array of Records
def convert(data)
  records = []
  data.each do |row|
    record = {}
    @map.each do |k,v|
      record[v.to_sym] = row[k]
    end
    records << Record.new(@record_type,record)
  end
  records
end


  # UniteU data
  class UniteU

    # Chooses and creates Record
    def create_record(table,data)
      record = case table
        when "product_items" then ProductItem.new(data)
        when "product_groups" then ProductGroup.new(data)
        when "orders" then Order.new(data)
        when "order_items" then OrderItem.new(data)
        when "customers" then Customer.new(data)
        when "categories" then Category.new(data)
        else "unknown"
      end
    end


    def parse_csv(file)
      puts "file" # REMOVE THIS <<<<<<<<
      # Guess what kind of file it is
      $csv_table = guess_source_type(file)
      # Load corresponding schema
      $db_table = $map[:"#{$csv_table}"][:table]
      $this_map = build_map($csv_table)
      $this_schema = $db_schema[:"#{$db_table}"]
      key = $this_schema[:KEY]
      key = key.split("-") if key.match("-")

      # Break it open and go through rows
      rows = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol)

      # To count rows
      rowno = 1
      rows.each do |row|
        # Variable switch will tell us if this row is trash
    #    trash = false
        rowno += 1 # Iterate row
        puts "#{rowno}..." # REMOVE THIS <<<<<<<<
        # Creates record object
        record = create_record($db_table,row)

        # This just splits out "product_groups" so we can categorize
        # in another table
        if $db_table!="product_groups"
          send_to_db(record)
        else
          send_to_db(record)
          if !record.getCat[0].nil?
            send_cat_to_db(record.getCat)
          end
        end
      end
    end
  end


  # RPro data
  class RPro
    @@type = [ "product","customer","salesorder","category","prefs" ]

    attr_reader :Products

    # toUTF(string)
    #
    # Changes a string encoding from Windows encoding to UTF-8.
    # Also removes obnoxious characters.
    def toUTF(string)
      string.force_encoding(Encoding::Windows_1252) #Set encoding
      string.gsub!(/\u001F/,"") #Get rid of obnoxious character
      string = string.encode!(Encoding::UTF_8, :universal_newline => true) #Convert encoding
    end


    # FROMXML
    #
    # Converts RPro export to an object we can
    # translate to our own database
    def fromxml(xml, type="product")

      # Convert XML to UTF-8
      thisxml = XmlSimple.xml_in(toUTF(File.read(xml)))

  # >> PRODUCT loop
      if type == "product"
        @Products = { "product_groups"=>[],"product_items"=>[] }

        # Cycle through Hash
        if !thisxml["Style"].nil?
          thisxml["Style"].each do |style|
            thisgroup = {
              "pf_id" => "#{style["fldStyleSID"]}",
              "name" => "#{style["fldStyleName"]}",
              "description" => "#{style["fldStyleLongDesc"]}",
              "img_thumbnail" => "#{style["fldStylePicture"]}",
              "sale_price" => nil,
              "sale_start" => nil,
              "sale_end" => nil,
              "img_med" => "#{style["fldStyleThumbnail"]}",
              "attr_label1" => "#{style[""]}",
              "attr_label2" => "#{style[""]}",
              "attr_label3" => nil,
              "attr_label4" => nil,
              "google_shopping" => nil,
              "vendor_code" => "#{style["fldVendorCode"]}"
            }
            thisgroup["msrp_price"] = "#{style["Item"][0]["Price"][0]["Value"]}" unless style["Item"][0]["Price"].nil?
            thisgroup["list_price"] = "#{style["Item"][0]["Price"][0]["Value"]}" unless style["Item"][0]["Price"].nil?
            @Products["product_groups"] << thisgroup

            style["Item"].each do |item|
              thisitem = {
                "sku" => "#{item["fldItemNum"]}",
                "pf_id" => "#{item["fldItemSID"]}",
                "attr_value1" => "#{item["fldAttr"]}",
                "attr_value2" => "#{item["fldSize"]}",
                "cost" => "#{item["fldCost"]}",
                "inventory_level" => "#{item["AvailQuantity"]}",
                "order_code" => "#{item["fldALU"]}",
                "img_large" => "#{item["fldItemSID"]}_lg.jpg",
              }
              thisitem["price"] = "#{item["Price"][0]["Value"]}" unless item["Price"].nil?
              @Products["product_items"] << thisitem

            end
          end

        elsif !thisxml["Style_Avail"].nil?
          thisxml["Style_Avail"].each do |style|
            style["Item_Avail"].each do |item|
              thisitem = {
                "sku" => "#{item["fldItemNum"]}",
                "pf_id" => "#{item["fldItemSID"]}",
                "inventory_level" => "#{item["AvailQuantity"]}"
              }
              @Products["product_items"] << thisitem
            end
          end
        end

  # >>CATEGORY loop
      elsif type == "category"
        @Products = { "product_meta"=>[] }

        # Cycles through multidimensional array/hash
        def cyclethru(data, parent="",style=false)
          if data.is_a?(Array)
            data.each { |array| cyclethru(array,parent,style) }
          elsif data.is_a?(Hash)
            if style == true
              thisitem = {
                "pf_id" => "#{data['SID']}",
                "rpro_id" => "#{parent}"
              }
              $Products["product_meta"] << thisitem
            else
              if data.has_key? "Style"
                cyclethru(data["Style"],data["SID"],true)
                if data.has_key? "TreeNode"
                  cyclethru(data["TreeNode"],style=false)
                end
              elsif data.has_key? "TreeNode"
                cyclethru(data["TreeNode"],style=false)
              end
            end
          end
        end

        # Cycle through Array/Hash
        if !thisxml["TreeNode"].nil?
          cyclethru(thisxml)
        end

  # >> SALES ORDER loop
      elsif type == "salesorder"

  # >> CUSTOMER loop
      elsif type == "customer"



      end
    end
  end
end
