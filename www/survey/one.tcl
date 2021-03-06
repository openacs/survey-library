# 

ad_page_contract {
    
    Show a survey in the library
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-10-06
    @arch-tag: fbab664e-ee55-4d08-868b-f80bda3ffd60
    @cvs-id $Id$
} {
    object_id:integer,optional
    survey_id:integer,optional
    {show ""}
} -properties {
} -validate {
} -errors {
}
if {[exists_and_not_null survey_id]} {
    ad_returnredirect [export_vars -base "./one" {{object_id $survey_id}}]
    ad_script_abort
} 

ns_log notice "\nDAVEB survey-library/survey/one.tcl begins\n"
set user_id [ad_conn user_id]
permission::require_permission \
		 -object_id $object_id \
		 -privilege "read" \
		 -party_id $user_id

# check for admin
set admin_p [permission::permission_p \
                 -object_id $object_id \
                 -privilege "admin" \
                 -party_id $user_id]


db_1row survey_info "select s.*, so.*, sl.original_object_id from surveys s, survey_objects so, survey_library sl where so.object_id=:object_id and s.survey_id=:object_id and sl.object_id=:object_id" -column_array survey_info

template::multirow create survey label value link_url

foreach {label var} {"Name" name "Description" description "Originator" creation_party "Author Contact" author_contact} {
    template::multirow append survey $label $survey_info($var)
}

# original survey info
if {$survey_info(original_object_id) ne ""} {
    get_survey_info -survey_id $survey_info(original_object_id) -arrayname original_survey_info 
    set original_survey_id $original_survey_info(survey_id)
    set original_survey_node_id [site_node::get_node_id_from_object_id -object_id $original_survey_info(package_id)]
    set orig_subsite_id [site_node::closest_ancestor_package -node_id [ad_conn node_id]]
    set orig_id [application_group::group_id_from_package_id -package_id $orig_subsite_id]
    set community_name [group::get_element -group_id $orig_id -element group_name]
        template::multirow append survey $label "${community_name}: $original_survey_info(name)" ""
}

set actions [list "Create Survey Based on This One" [export_vars -base create {{orig_object_id $object_id}}] "Create Survey Based on This One"]
if {$admin_p} {
    lappend actions "Deactivate Survey from library" [export_vars -base "../deactivate" {object_id}] "Deactive This Survey so it is no longer available from the library"
}
template::list::create \
    -name survey \
    -multirow survey \
    -actions $actions \
    -elements {
        label {label ""}
        value {label {} link_url_col {link_url}}
    }

set show_return_url [export_vars -base "one" {object_id}]
set return_url [ad_return_url]
set show_url [export_vars -base "one" {object_id {show t}}]
set search_results_url [ad_get_client_property survey_library last_search]

set title "View Survey"
set context [list $title]
set header_stuff ""
set focus ""

ad_return_template