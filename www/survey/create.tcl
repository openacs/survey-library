# 

ad_page_contract {
    
    Create a new survey based on library survey
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-10-06
    @arch-tag: b9316eb9-338b-4cac-8388-9522fd456e7b
    @cvs-id $Id$
} {
    orig_object_id:integer,notnull
    new_survey_id:integer,optional
} -properties {
} -validate {
} -errors {
}

set refer_package_id [ad_get_client_property survey-library refer_package_id]

set user_id [ad_conn user_id]
permission::require_permission \
    -object_id $orig_object_id \
    -party_id $user_id \
    -privilege "read"

# FIXME just INFORM widget if there is only one (i think this is most
# likely for regular users

get_survey_info -survey_id $orig_object_id

if {![info exists refer_package_id] || $refer_package_id eq ""} {
    set survey_options [db_list_of_lists get_survey_packages "select p.instance_name || ':' || s.instance_name,s.package_id from apm_packages s, apm_packages p, site_nodes sn1, site_nodes sn2, all_object_party_privilege_map a where sn1.object_id=s.package_id and sn2.node_id=sn1.parent_id and p.package_id=sn2.object_id and s.package_id = a.object_id and a.party_id=:user_id and s.package_key='survey-builder-ui' and a.privilege='admin'"]
} else {
    set refer_package_name [site_node::get_from_object_id -object_id $refer_package_id -element name]
    set survey_options [list $refer_package_name $refer_package_id]
    set target_package_id $refer_package_id
}

set cancel_url [export_vars -base "./one" {{object_id $orig_object_id}}]
ad_form -export {orig_object_id} -cancel_url $cancel_url -form {
    new_survey_id:key
    {orig_name:text(inform) {label "Copy survey '$survey_info(name)'"}}
    {new_name:text(text) {label "New Name"} {value $survey_info(name)}}
}
if {[llength $survey_options] > 1} {
    ad_form -extend -form {
	{target_package_id:text(select) {label "Copy to"} {options $survey_options}}
    }
} else {
    set target_package_id [lindex [lindex $survey_options 0] 1]
    ad_form -extend -form {
	{target_package_id_info:text(inform) {label "Copy to [lindex [lindex $survey_options 0] 0]"}}
	{target_package_id:text(hidden) {value $target_package_id}}
    }
}

ad_form -extend -on_request {

} -new_data {
    
    permission::require_permission \
        -object_id $target_package_id \
        -party_id $user_id \
        -privilege "admin"

    set new_survey_id [survey_copy \
                           -survey_id $orig_object_id \
                           -package_id $target_package_id \
                           -new_name $new_name \
                           -new_survey_id $new_survey_id]

    array set survey_site_node [site_node::get_from_object_id -object_id $target_package_id]

    survey_library::map_object_use \
        -library_object_id $orig_object_id \
        -use_object_id $new_survey_id
    
    ad_returnredirect -message "Created from library" [export_vars -base ${survey_site_node(url)}admin/one { { survey_id $new_survey_id }}]
}

set title "Create custom survey"
set context [list $title]
set header_stuff ""
set focus ""

ad_return_template
