# 

ad_page_contract {
    
    Set category trees
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-12-21
    @arch-tag: b24373b3-fab4-472f-855c-94ec4769bc8c
    @cvs-id $Id$
} {
    
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

permission::require_permission \
    -party_id $user_id \
    -object_id $package_id \
    -privilege "admin"

db_1row get_default_objects "select survey_id, section_id, question_proxy from survey_library_default_objects where package_id=:package_id"
set node_id [ad_conn node_id]
set subsite_node_id [site_node::closest_ancestor_package -node_id $node_id -element node_id]
set categories_url [site_node::get_children -node_id $subsite_node_id -package_key "categories"]
set survey_url [export_vars -base ${categories_url}cadmin/one-object {{object_id $survey_id}}]
set section_url [export_vars -base ${categories_url}cadmin/one-object {{object_id $section_id}}]
set question_url [export_vars -base ${categories_url}cadmin/one-object {{object_id $question_proxy}}]
set page_title "Admininster Categories"
set context [list $page_title]
set header_stuff ""
set focus ""

ad_return_template
