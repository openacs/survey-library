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

set refer_survey_id [ad_get_client_property -default "" survey_library refer_survey_id]
ns_log notice "\n DAVEB refer survey id '${refer_survey_id}'"
if {$refer_survey_id ne ""} {
    set survey_options [db_list_of_lists get_section "select name,section_id from survey_sections where survey_id=:refer_survey_id"]
} else {
    set survey_options [db_list_of_lists get_survey_packages "select case when s.object_type = 'survey' then name when s.object_type = 'survey_section' then (select name from surveys where survey_id=s.survey_id) || ':' || s.name end as name, s.object_id from survey_objects s, all_object_party_privilege_map p where (s.object_type='survey' or s.object_type='survey_section') and p.object_id=s.object_id and p.party_id=:user_id and p.privilege='admin'"]
set survey_options [linsert $survey_options 0 {"-Create New Survey-" "__none__"}]
}
ns_log notice "\n DAVEB survey_options = '${survey_options}'"
get_section_info -section_id  [db_string get_section "select section_id from survey_questions where question_id=:orig_object_id"]
db_1row get_question "select * from survey_questions where question_id=:orig_object_id" -column_array question

set cancel_url [export_vars -base "./one" {{object_id $orig_object_id}}]

ad_form -export {orig_object_id} -cancel_url $cancel_url -form {
    new_question_id:key
    {orig_name:text(inform) {label "Copy Question'$question(question_text)'"}}
#    {new_name:text(text) {label "New Name"} {value $section_info(name)}}
}
if {[llength $survey_options] > 1} {
    ad_form -extend -form {
	{section_id:text(select) {label "Copy to"} {options $survey_options}}
    }
} else {
    ad_form -extend -form {
	{section_id:text(select) {label "Copy to [lindex $survey_options 0]"} {options $survey_options}}
    }
}

ad_form -extend -on_submit {
    if {$section_id eq "__none__" && $target_package_id eq ""} {
	element set_properties create section_id \
	    -widget hidden 
	
	set target_package_id_options [db_list_of_lists get_survey_packages "select p.instance_name || ':' || s.instance_name,s.package_id from apm_packages s, apm_packages p, site_nodes sn1, site_nodes sn2, all_object_party_privilege_map a where sn1.object_id=s.package_id and sn2.node_id=sn1.parent_id and p.package_id=sn2.object_id and s.package_id = a.object_id and a.party_id=:user_id and s.package_key='survey-builder-ui' and a.privilege='admin'"]
	if {[llength $target_package_id_options] == 1} {
	    set target_package_id [lindex [lindex $target_package_id_options 0] 1]
	    element create create target_package_id_inform \
                -label "Create in [lindex [lindex $target_package_id_options 0] 0]" \
		-widget inform
            element create create target_package_id \
                -widget hidden \
                -value $target_package_id
	    element create create survey_name \
		-label "New Survey Name"             
	} else {
	    element create create target_package_id \
		-label "Create in" \
		-options $target_package_id_options \
		-widget select
	    element create create survey_name \
		-label "New Survey Name" 
	}
    } elseif {$section_id ne "__none__" || $target_package_id ne ""} {
	if {$section_id ne "__none__"} {
	    permission::require_permission \
		-object_id $section_id \
		-party_id $user_id \
		-privilege "admin"
            set survey_id [db_string get_survey_id "select survey_id from survey_sections where section_id=:section_id"]
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
            set section_id [survey_section_new \
            -survey_id $survey_id \
            -name "First Section" \
            -description "Enter Description" \
                                -sort_key 1]
	}
    set new_question_id [survey_question_copy \
			    -question_id $orig_object_id \
			    -new_section_id $section_id \
                             -new_question_id $new_question_id]
    set target_package_id [db_string get_package_id "select s.package_id from surveys s,survey_sections ss where s.survey_id=ss.survey_id and ss.section_id=:section_id"]
    array set survey_site_node [site_node::get_from_object_id -object_id $target_package_id]

    survey_library::map_object_use \
        -library_object_id $orig_object_id \
        -use_object_id $new_question_id
    
    ad_returnredirect -message "Created from library" [export_vars -base ${survey_site_node(url)}admin/one { survey_id }]
    }
}

set title "Create custom survey"
set context [list $title]
set header_stuff ""
set focus ""

ad_return_template
