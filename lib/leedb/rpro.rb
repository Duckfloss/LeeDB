# Converts RPro XML files to LeeDB format
#
# This takes the XML files output by RPro and converts them into
# a format we can use to insert in the LeeDB database.

class RProRecord
	@@type = [ "product","customer","salesorder","category" ]

	attr_reader :Products

	def initialize(xml)
		fromxml(xml)
	end

	def toUTF(string)
	  string.force_encoding(Encoding::Windows_1252) #Set encoding
		string.gsub!(/\u001F/,"") #Get rid of obnoxious character
	  string = string.encode!(Encoding::UTF_8, :universal_newline => true) #Convert encoding
	end

	def fromxml(xml, type="product")

		# Convert XML
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
