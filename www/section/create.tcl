# 

ad_page_contract {
    
    Create a new survey based on library survey
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-10-06
    @arch-tag: b9316eb9-338b-4cac-8388-9522fd456e7b
    @cvs-id $Id$
} {
    orig_object_id:integer,notnull
    new_section_id:integer,optional
    {target_package_id ""}
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
permission::require_permission \
    -object_id $orig_object_id \
    -party_id $user_id \
    -privilege "read"

set survey_options [db_list_of_lists get_survey_packages "select s.name, s.survey_id from surveys s, all_object_party_privilege_map p where p.object_id=s.survey_id and p.party_id=:user_id and p.privilege='admin'"]
set survey_options [linsert $survey_options 0 {"-Create New Survey-" "__none__"}]
get_section_info -section_id $orig_object_id

set cancel_url [export_vars -base "./one" {{object_id $orig_object_id}}]

ad_form -export {orig_object_id} -cancel_url $cancel_url -form {
    new_section_id:key
    {orig_name:text(inform) {label "Copy survey '$section_info(name)'"}}
    {new_name:text(text) {label "New Name"} {value $section_info(name)}}
}
if {[llength $survey_options] > 1} {
    ad_form -extend -form {
	{survey_id:text(select) {label "Copy to"} {options $survey_options}}
    }
} else {
    ad_form -extend -form {
	{survey_id:text(select) {label "Copy to [lindex $survey_options 0]"}}
    }
}

ad_form -extend -on_submit {
    if {$survey_id eq "__none__" && $target_package_id eq ""} {
	element set_properties create survey_id \
	    -widget hidden 
	
	set target_package_id_options [db_list_of_lists get_survey_packages "select p.instance_name || ':' || s.instance_name,s.package_id from apm_packages s, apm_packages p, site_nodes sn1, site_nodes sn2, all_object_party_privilege_map a where sn1.object_id=s.package_id and sn2.node_id=sn1.parent_id and p.package_id=sn2.object_id and s.package_id = a.object_id and a.party_id=:user_id and s.package_key='survey' and a.privilege='admin'"]
	if {[llength $target_package_id_options] == 1} {
	    set target_package_id [lindex [lindex $target_package_id_options 1] 0]
	} else {
	    element create create target_package_id \
		-label "Create in" \
		-options $target_package_id_options \
		-widget select
	    element create create survey_name \
		-label "New Survey Name" 
	}
    } 
    if {$survey_id ne "__none__" || $target_package_id ne ""} {
	if {$survey_id ne "__none__"} {
	    permission::require_permission \
		-object_id $survey_id \
		-party_id $user_id \
		-privilege "admin"
	} elseif {$target_package_id ne ""} {
	    permission::require_permission \
		-object_id $target_package_id \
		-party_id $user_id \
		-privilege "admin"
	    element create create survey_name
	    set survey_name [element get_value create survey_name]
	    set survey_id [survey_new \
			       -name $survey_name \
			       -package_id $target_package_id \
			      -description "-Enter Description-" \
			      -creation_user $user_id]
	}
    set new_section_id [survey_section_copy \
			    -section_id $orig_object_id \
			    -new_survey_id $survey_id \
			    -new_name $new_name \
			    -new_section_id $new_section_id]
    set target_package_id [db_string get_package_id "select package_id from surveys where survey_id=:survey_id"]
    array set survey_site_node [site_node::get_from_object_id -object_id $target_package_id]

    survey_library::map_object_use \
        -library_object_id $orig_object_id \
        -use_object_id $new_section_id
    
    ad_returnredirect -message "Created from library" [export_vars -base ${survey_site_node(url)}admin/one { survey_id }]
    }
}

set title "Create custom survey"
set context [list $title]
set header_stuff ""
set focus ""

ad_return_template
