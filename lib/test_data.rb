#Test data
$file = "data/UniteU_Departments_20150710132002.csv"
$uid = { "id" =>  "1234" }
$csv_table = "departments"
$db_table = "categories"
$data = {
  parent_id:"3011",
  dept_id:"3041",
  dept_name:"Women's Skis",
  dept_hyperlink:" ",
  dept_dept_target:"dept.asp, ",
  dept_prod_target:"product.asp, ",
  dept_disable_name:"1",
  dept_list_2_levels:nil,
  dept_list_product_levels:"1",
  dept_display_type:"4",
  dept_sort_type:"1",
  dept_sort_order:"2",
  dept_quick_dept_enable:nil,
  dept_quick_dept_level:nil,
  dept_short_description:" ",
  dept_description_top_1:" ",
  dept_description_top_2:" ",
  dept_description:" ",
  dept_description_2:" ",
  dept_image_1_file_scr:"PRODUCT",
  dept_image_1_file:"GDADAAAABJAMMFBHt.jpg",
  dept_image_1_width:nil,
  dept_image_1_height:"3",
  dept_image_1_h_align:"CENTER",
  dept_image_1_file_target_scr:"NONE",
  dept_image_1_file_target:nil,
  dept_image_1_file_target_alt:nil,
  dept_image_2_file_scr:"NONE",
  dept_image_2_file:nil,
  dept_image_2_width:nil,
  dept_image_2_height:nil,
  dept_image_2_h_align:"CENTER",
  dept_image_2_file_target_scr:"NONE",
  dept_image_2_file_target:nil,
  dept_image_2_file_target_alt:nil,
  rpro_dept_id:"OJACAAAAKPHBMGBH",
  dept_spanner_elements_per_page:nil,
  dept_meta:"<meta name =\"description\" content=\"Shop Women's Skis equipment and gear at Lee's Adventure Sports.\">",
  dept_rpro_dcs:nil
}

#$this_map = build_map($csv_table)
#$this_schema = $db_schema[:"#{$db_table}"]
#$key = $this_schema[:KEY]
#$key = $key.split("-") if $key.match("-")
#$db = SQLite3::Database.new "#{$db_file}"
