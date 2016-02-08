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
		else
			raise "error"
		end
		@records = convert(@data)

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
		rescue
			# Convert to UTF-8 if necessary
			data = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol, :encoding => 'Windows-1252:UTF-8')
		end
		data
	end

	# Creates an Array of XML Rows
	def parse_xml(file)
		data = []
		# Break open XML and go through nodes
		begin
			file = file_sanitizer(file)
			data = XmlSimple.xml_in(file, {'ForceArray' => false })
		rescue Exception => e
			raise e
		end
		data
	end


	# Creates an Array of Records
	def convert(data)
		records = []
		if @data_source == "uniteu"
			begin
				data.each do |row|
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
				end
			rescue Exception => e
					puts e
			end
		elsif @data_source == "rpro"
			begin
				record = {}
				mappy(data).each do |type, fields|
					fields.each do |item|
						col = item.keys[0][/[A-Za-z0-9_]+/].to_sym
						colvalue = item.values[0]
						thisitem = []
						flags = item.keys[0][/[!+\-#]/]
						if flags != nil
							flags = flags.split(//)
						else
							flags = []
						end

						# Special Instructions
						# We need to process this stuff for the flags present
						# and then make it into records
						if !record.has_key?(type)
							record[type] = {}
						end
						if flags.empty?
							record[type][col] = colvalue
						else
							if flags.include? "!"
								raise "write filter for !"
							end
							if flags.include? "#"
								if record[type].has_key?(col)
									records << Record.new(type,record[type])
									record[type] = {}
								end
								record[type][col] = colvalue
							end
							if flags.include? "+"
								if record[type].has_key?(col)
									colvalue = record[type][col]+colvalue
								end
								record[type][col] = colvalue
							end
							if flags.include? "-"
								raise "I didn't think we'd actually have one of these \"-\""
							end
						end
					end
				end
			rescue Exception => e
				raise e
			end
		end
		records
	end

	# replace \r\n line endings with \n line endings
	# check encoding, if not UTF-8, transcode
	def file_sanitizer(file)
	  file = File.open(file, mode="r+")
	  content = File.read(file)
		content.force_encoding(Encoding::Windows_1252)
		content = content.encode!(Encoding::UTF_8, :universal_newline => true)
	  content.gsub!("\r\n","\n")
		content
	end


	def mappy(data,q=[],level=0,temp={})

		## ARRAY
		if data.is_a? Array
			data.each do |array|
				mappy(array,q,level,temp)
			end

		## HASH
		elsif data.is_a? Hash
			level += 1
#puts "Level #{level}>"
			data.each do |k,v|
				q << k

				# If the value is another hash or array, move on recursively
				if [Hash,Array].include? v.class
					mappy(v,q,level,temp)
				# Otherwise
				else

					# Dig into the map for a translation
					field = dig(@map,q)
					# If the field is anything but nil
					if !field.nil?
#puts "\t#{q.to_s}> #{v.slice(0,20)}"
						# get the different types and fields
						fieldhead = fieldhead(field)
						fieldhead.each do |item|
							if !temp.has_key?(item.keys[0])
								temp[item.keys[0]] = []
							end
							temp[item.keys[0]] << { item[item.keys[0]] => v }
						end
					end
				end
				q.pop
			end

		## OTHER
		else
			puts "not an Array or a Hash"
		end
		temp
	end

	def fieldhead(field)
		fieldhead = []
		if field.include? "/"
			field = field.split('/')
		else
			field = [field]
		end

		field.each do |item|
			thisitem = item.split(':')
			fieldhead << { thisitem[0].to_sym => thisitem[1] }
		end
		fieldhead
	end

	def dig(hash,array)
		array.each do |i|
			i = i.to_sym unless i.is_a? Symbol
			hash = hash[i]
		end
		if hash.nil? || hash == ""
			return nil
		else
			hash
		end
	end



end
end
