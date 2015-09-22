# Add lib to load path
$LOAD_PATH << "./lib"

# Require Gems
require 'sqlite3'
require 'xmlsimple'
require 'zip'
require 'date'

# Require Classes
#require 'csv2db'
require 'records'
require 'rpro'
require 'db'
require 'test_data'

# Load presets
$db = "lee.db"
$log = "logs/"+DateTime.now.strftime('%Y%m%d%H%M%S')+".txt"
