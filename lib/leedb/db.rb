# Interfaces with the lee.db database

class DB

  # Open database on object creation
  # db is the name of the database
  def initialize(db)
    @db = SQLite3::Database.new "#{db}"
  end

  # Insert record into database
  # table is the name of the table in the database
  # hash is a hash of field names and values to insert
  def insert(table, hash)
    keys = ""
    values = []
    q = ""
    hash.each do |k,v|
      keys << "#{k},"
      values << v
      q << "?,"
    end
    keys.chomp!(",")
    q.chomp!(",")
    begin
      query = @db.prepare "INSERT INTO #{table} (#{keys}) VALUES (#{q})"
      query.bind_params(values)
      query.execute
    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
    end
  end

  # Update existing record
  # table is the name of the table in the database
  # hash is a hash of field names and values to insert
  # uid is a hash of the field names and values of the key data fields
  def update(table, hash, uid)
		keys = ""
		values = []
		conditions = ""
		hash.each do |k,v|
      keys << "#{k}=?,"
      values << v
		end
		keys.chomp!(",")
		uid.each do |k,v|
      conditions << "#{k}=#{v},"
		end
		conditions.chomp!(",")
		conditions.gsub!(","," AND ")
    begin
  		query = @db.prepare "UPDATE #{table} SET #{keys} WHERE #{conditions}"
  		query.bind_params(values)
  	  query.execute
    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
    end
  end

  # Check if UID exists
  # table is the name of the table in the database
  # uid is a hash of the field names and values of the key data fields
  def uid_exists?(table, uid)
  	uid_exists = false
    conditions = ""
  	values = []
  	uid.each do |k,v|
  		conditions << " #{k}=?,"
  		values << v
  	end
  	conditions.chomp!(",")
  	conditions.gsub!(","," AND ")
    begin
    	query = @db.prepare "SELECT * FROM #{table} WHERE #{conditions}"
    	query.bind_params(values)
  	  uid_exists = true if query.execute.count > 0
    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
    end
  	return uid_exists
  end

  # Lists the tables in the database
  def listtables
    thesetables = []
    tables = @db.execute "SELECT name FROM sqlite_master WHERE type='table'"
    tables.each { |table| thesetables << table[0] }
    return thesetables
  end


end
