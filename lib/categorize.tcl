# packages/survey-library/www/categorize.tcl

# ad_page_contract {

#     Categorize a library object

# } -query {
#     object_id:integer,notnull
#     return_url:notnull
#     mode
# } -properties {
#     page_title
#     context
#     header_stuff
#     focus
#     object_id
# }

#set user_id [ad_conn user_id]
#permission::require_permission \
    -object_id $object_id \
    -party_id $user_id \
    -privilege "admin"

db_1row get_survey_object "select * from survey_objects where object_id=:object_id" -column_array survey_object

if {![info exists admin_p] || !$admin_p} {
    set mode "display"
}

# FIXME get category trees mapped to the library for each
# object type
set package_id [ad_conn package_id]

set package_category_trees [category_tree::get_mapped_trees $package_id]
set survey_category_trees [category_tree::get_mapped_trees [survey_library::default_object_id $package_id survey]]
set section_category_trees [category_tree::get_mapped_trees [survey_library::default_object_id $package_id survey_section]]
set question_category_trees [category_tree::get_mapped_trees [survey_library::default_object_id $package_id survey_question]]

switch $survey_object(object_type) {
    survey {
	set category_trees $survey_category_trees
    }
    survey_section {
	set category_trees $section_category_trees
    }
    survey_question {
	set category_trees $question_category_trees
    }
}

set cat_tree_ids [list]
set form_elements [list]

foreach tree_data $category_trees {
    foreach {tree_id d1 d2} $tree_data {break}
    set name [category_tree::get_name $tree_id]
    # FIXME use required/multiple flags from mapping
    lappend form_elements [list category_${tree_id}:integer(category),optional [list label $name] [list category_tree_id $tree_id] [list category_object_id $object_id]]
	lappend cat_tree_ids $tree_id
}

if {[llength $form_elements]} {
    ad_form -name categorize -mode $mode -cancel_url [export_vars -base "./one" {object_id}] -form {
	{object_id:text(hidden) {value $object_id}}
    }
    set form_p 1
    foreach element $form_elements {
	ad_form -extend -name categorize -form [list $element]
    }

    ad_form -extend -name categorize -on_request {
	foreach tree_id $cat_tree_ids {
	    #	set ids [db_list get_mapped_categories "select category_id from category_object_map_tree where object_id=:object_id and tree_id=:tree_id"]
	    #	element set_values categorize "category_${tree_id}" [db_list get_mapped_categories "select category_id from category_object_map_tree where object_id=:object_id and tree_id=:tree_id"]
	}
    } -on_submit {
	set all_categories [list]
	foreach tree_id $cat_tree_ids {
	    set all_categories [concat $all_categories [set category_${tree_id}]]
	}
	category::map_object -remove_old -object_id $object_id $all_categories
    } -after_submit {
	ad_returnredirect [export_vars -base one {object_id}]
    }
} else {
    set form_p 0
}