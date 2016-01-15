require 'optparse'
require 'ostruct'

module LeeDB
  class Parser

  	def self.parse(args)
  		options = OpenStruct.new
  		options.file = nil
  		options.db = "../lee.db"
  		options.practice = false
  		options.verbose = false
  		options.log = false

  		opt_parser = OptionParser.new do |opt|
  			opt.banner = "Usage: leedb.rb [options]"
  			opt.separator ""
  			opt.separator "Options:"

  			opt.on("-fFILE", "--file FILE", "Source file (csv,xml, or zip)") do |file|
  				if file.nil?
  					puts "We need a file to pull data from."
  				end
  				# Validate source
  				if !file =~ /\.(csv|xml|zip){1}$/
  					puts "We need a csv, xml, or zip file. Try again."
  				end
  				if File.exist?(file)
  					options.file = file
  				else
  					puts "We can't find that file. Try pasting the full file path here."
  				end
  			end

  			opt.separator ""

  			opt.on("-dDB", "--db DB", "Set alternative sqlite database") do |db|
  				if !db =~ /\.db$/
  					puts "Database should be a valid SQLite file. The filename should end in \".db\""
  				end
  				if File.exist?(db)
  					options.db = db
  				else
  					puts "We can't find that database. Try pasting the full file path here."
  				end
  			end

  			opt.separator ""

  			opt.on("-p", "--practice", "Run without sending to db") do |practice|
  				options.practice = practice
  			end

  			opt.separator ""

  			opt.on("-v", "--verbose", "Run chattily (or not)") do |verbose|
  				options.verbose = verbose
  			end

  			opt.separator ""

  			opt.on("-l", "--log", "Log results to a file") do |log|
  				options.log = log
  			end

  			opt.separator ""

  			opt.on_tail("-h","--help","Prints this help") do
  				puts opt
  				exit
  			end
  		end

  		opt_parser.parse!(args)
  		options
  	end
  end
end
