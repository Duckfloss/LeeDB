module LeeDB
	class Logger

		attr_reader :iterator, :message, :insert, :update, :fail

		def initialize(options)
			@iterator = 0
			@message = []
			@insert ||= []
			@update ||= []
			@fail ||= []
			if options.log
				t = Time.now.strftime("%Y%m%d%H%M%S")
				@log = File.new("logs/log#{t}.txt", mode="w+")
			end
		end

		def message!(msg)
			@message << msg
		end

		def insert!(table,item)
			@insert << [table,item]
		end

		def update!(table,item)
			@update << [table,item]
		end

		def fail!(table,item)
			@fail << [table,item]
		end

		def increment
			@iterator += 1
		end

		def write_interstitial
			output = ""
			@message.each do |message|
				output << "#{message}\n"
			end
			if options.verbose
				puts output
			end
			if options.log
				@log.write(output)
			end
		end

		def write_end
			output = ""
			insert_number = @insert.length
			update_number = @update.length
			output << "Records inserted: #{insert_number}\n"
			output << "Records updated: #{update_number}\n"
			if @fail.length > 0
				output << "The following items couldn't be put in the database:\n"
				@fail.each do |item|
					output << "\t#{item[1]} - #{item[0]}\n"
				end
			end

		end
	end
end
