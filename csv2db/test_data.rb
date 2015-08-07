#Test data
$file = "data/UniteU_Departments_20150710132002.csv"
$uid = { "id" => "1234" }
$csv_table = "departments"
$db_table = "categories"
$this_map = build_map($csv_table)
$this_schema = $db_schema[:"#{$db_table}"]
$key = $this_schema[:KEY]
$key = $key.split("-") if $key.match("-")
$db = SQLite3::Database.new "#{$db_file}"
