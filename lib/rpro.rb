class RProRecord
	@@type = [ "product","customer","salesorder","category" ]

	attr_reader :Products

	def initialize(xml)
		fromxml(xml)
	end

	def toUTF(file)
	  file = File.open(file)
		file = file.read
	  file.force_encoding(Encoding::Windows_1252)
	  file = file.encode!(Encoding::UTF_8, :universal_newline => true)
	end

	def fromxml(xml, type="product")

		# Convert XML
	  thisxml = XmlSimple.xml_in(toUTF(xml))

		if type == "product"
			@Products = { "product_groups"=>[],"product_items"=>[] }

			# Cycle through Hash
			if !thisxml["Style"].nil?
				thisxml["Style"].each do |style|
					thisgroup = {
						"pf_id" => "#{style["fldStyleSID"]}",
						"name" => "#{style["fldStyleName"]}",
						"description" => "#{style["fldStyleLongDesc"]}",
						"msrp_price" => "#{style["Item"][0]["Price"][0]["Value"]}",
						"list_price" => "#{style["Item"][0]["Price"][0]["Value"]}",
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
					@Products["product_groups"] << thisgroup

					style["Item"].each do |item|
						thisitem = {
							"sku" => "#{item["fldItemNum"]}",
							"pf_id" => "#{item["fldItemSID"]}",
							"attr_value1" => "#{item["fldAttr"]}",
							"attr_value2" => "#{item["fldSize"]}",
							"price" => "#{item["Price"][0]["Value"]}",
							"cost" => "#{item["fldCost"]}",
							"inventory_level" => "#{item["AvailQuantity"]}",
							"order_code" => "#{item["fldALU"]}",
							"img_large" => "#{item["fldItemSID"]}_lg.jpg",
						}
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
		end
	end
end
