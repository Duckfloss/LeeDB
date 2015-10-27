# Add lib to load path
$LOAD_PATH << "./leedb"

# Require Gems
require 'sqlite3'
require 'json'
require 'xmlsimple'
require 'zip'
require 'date'

# Require Classes
require 'csv2db'
require 'records'
require 'rpro'
require 'db'

# Load presets
$db = "../lee.db"
$log = "../logs/"+DateTime.now.strftime('%Y%m%d%H%M%S')+".txt"

# Database field options
$db_type = [ 'TEXT','REAL','INTEGER' ]
$db_format = [ 'alpha16','char3','price','bool','url','int4','date','time','phone','email' ]
$db_rule = [ 'KEY','NOTNULL','UNIQUE' ]

# Load db schema
$db_schema = JSON.parse(File.read('./leedb/schemas/leedb.json'), :symbolize_names=>true)
# Load db map
$map = JSON.parse(File.read('./leedb/maps/uniteu.json'), :symbolize_names=>true)
