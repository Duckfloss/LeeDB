require 'json'
require 'xmlsimple'
require 'csv'

module LeeDB

class Import


	attr_reader :file, :data_source, :source_type, :records, :map, :data, :record_type

	def initialize(file)
		@file = file
		@data_source = guess_source
		@json = JSON.parse(File.read("leedb/maps/#{@data_source}.json"), :symbolize_names=>true)
		@source_type = guess_source_type
		@map = @json[@source_type.to_sym]
		if @data_source == "uniteu"
			@data = parse_csv(@file)
		elsif @data_source == "rpro"
			@data = parse_xml(@file)
#binding.pry
		else
			raise "error"
		end
#		@records = convert(@data)

	end

	def inspect
		return @records
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
		elsif @data_source == "rpro"
			type = case File.basename(@file)
				when /^SO/ then table << "SO"
				when /^ECStyle/ then table << "ECStyle"
				when /^ECCustomer/ then table << "ECCustomer"
				when /^CUST/ then table << "CUST"
				when /^CatTree/ then table << "CatTree"
				else table << "unknown"
			end
		end
		table
	end

	# Creates an Array of CSV Rows
	def parse_csv(file)
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

	# Creates an Array of XML Rows
	def parse_xml(file)
		data = []
		# Break open CSV and go through rows
		begin
			data = XmlSimple.xml_in(file)
		rescue Exception => e
			puts e
		end
		data
	end


	# Creates an Array of Records
	def convert(data)
		records = []
		data.each do |row|
			begin
				record = {}
				@map.each do |i|
					i.each do |k,v|
						field = k.to_s
						v = v.split(":")
						type = v[0]
						col = v[1]
						if !record.has_key?(type.to_sym)
							record[type.to_sym] = {}
						end
						record[type.to_sym][col] = row[k]
					end
				end
				# Make Records
				record.each do |k,v|
					records << Record.new(k.to_s,v)
				end
			rescue Exception => e
				puts e
			end
		end
		records
	end

=begin
	# guesstype(filename)
	#
	# What type of data is this? This method will tell you
	# based on what the filename is.
	def guesstype(filename)
		type = case filename
			when /^A/ then "salesorders"
			when /^G/ then "images"
			when /^N/ then "products"
			when /^S/ then "customer"
			when /^X/ then "prefs"
			else "unknown"
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
=end
end
end
