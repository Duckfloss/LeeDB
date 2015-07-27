

require 'sqlite3'
require 'csv'
require 'json'
require 'yaml'

# Load presets
db = "lee.db"
settings = YAML::load_file "settings.yml"
os = settings["os"]

# Load commandline files
files = []
ARGV.each do |a|
	files << a
end

# Database field options
db_type = [ 'TEXT','REAL','INTEGER' ]
db_format = [ 'alpha16','char3','price','bool','url','int4','date','time','phone','email' ]
db_rule = ['KEY','NOTNULL','UNIQUE' ]

# Parse db schema
db_schema = JSON.parse(File.read('leedb.json'), :symbolize_names=>true)

def validate(string, format)

	# validation patterns
	alpha16 = /\A[a-zA-Z]{16}\Z/
	char3 = /\A[\w\d\ \+\.\&]{2,3}\Z/
	int4 = /\A\d{4}\Z/
	price = /\A[\d\.]+\Z/
	bool = /\A(0|1|no|yes|true|false)\Z/
	url = /\A[\d\w]+\.+[\w]{1,4}\Z/
	date = /\A\d{2}\/\d{2}\/\d{2}\Z/
	time = /\A\d{2}\:\d{2}\:\d{2}\ (A|P)\Z/
	phone = /\A[\d\-\(\)\.]+\Z/
	email = /\A[\w\d\.\#-\_\~\$\&\'\(\)\*\+\,\;\=\:\%]+\@[\w\d]+\.\w{1,4}\Z/



end

class String
def validate reg
!self[reg].nil?
end
end


# main function
def doit(file)
  # open CSV file
  data = CSV.read(file, :headers => true,:skip_blanks => true,:header_converters => :symbol)

  # open a new file
  File.open(csv_target, 'a') do |file|
    data.each do |row|
      if row[:desc] != nil
        row.each do |head,field|
          if head == :desc
            row[:desc] = formatify(field)
          end
        end
        file.puts row
      else
        file.puts row
      end
    end
  end
end

# run the main function
files.each do |file|
	doit(file)
end






=begin
db = SQLite3::Database.new ":memory:"

# Create a database
rows = db.execute <<-SQL
  create table users (
    name varchar(30),
    age int
  );
SQL

csv = <<CSV
name,age
ben,12
sally,39
CSV

CSV.parse(csv, headers: true) do |row|
  db.execute "insert into users values ( ?, ? )", row.fields # equivalent to: [row['name'], row['age']]
end

db.execute( "select * from users" ) # => [["ben", 12], ["sally", 39]]
=end