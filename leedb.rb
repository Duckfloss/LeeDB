# Add lib to load path
$LOAD_PATH << "./lib"

# Require Gems
require 'sqlite3'
require 'csv'
require 'json'
require 'date'

# Require Classes
require 'csv2db'
require 'google_shopping'
require 'records'
require 'test_data'

# Load presets
$db_file = "lee.db"
$log = "logs/"+DateTime.now.strftime('%Y%m%d%H%M%S')+".txt"
