# 

ad_page_contract {
    
    show the user all the elements of this survey, or let them just add
    the entire survey to the library
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-18
    @arch-tag: 7a814ee9-572d-40cf-93f6-3cfb8c336c0e
    @cvs-id $Id$
} {
    object_id:integer,multiple,notnull,trim
    {orig_package_id ""}
    {add_type "survey"}
    {return_url ""}
} -properties {
} -validate {
    object_type {
        # this page needs to work with survey, section, or questions so find
        # out the object_type
        set object_type [acs_object_type $object_id]
        if {[lsearch {survey survey_section survey_question} $object_type]<0} {
            ad_complain "Object type must be survery, survey_section, or survey_question"
        }
    }
} -errors {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

permission::require_permission \
    -object_id $package_id \
    -party_id $user_id \
    -privilege "create"

set bulk_actions [list "Add to Library" add-2 "Add checked items to survey library"]
set actions [list "Add Entire Survey" [export_vars -base "add-2" {object_id return_url}] "Add entire survey to the library" "Add Sections" [export_vars -base add {object_id return_url {add_type section}}] "Choose sections to add to the library" "Add Questions" [export_vars -base add {object_id return_url {add_type question}}] "Choose individual questions to add the the library"]
template::list::create \
    -name survey_elements \
    -actions $actions \
    -multirow survey_elements \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars {return_url orig_package_id} \
    -has_checkboxes \
    -no_data "No items match your search." \
    -key object_id \
    -elements {
        checkbox {display_template {<if @survey_elements.checkbox@ eq 1><input type="checkbox" name="object_id" value="@survey_elements.object_id@" id="survey_elements,@survey_elements.object_id@" title="Check/uncheck this row, and select an action to perform below"></if>}}
        name {label "Name" display_template {@survey_elements.indent;noquote@ @survey_elements.name@}}
        description {label "Description"}
        section_name {label "Section"}
        type {label "Type"}
    } \
    -orderby {
        type {orderby type}
        name {orderby name}
    }

db_multirow -extend {indent checkbox} survey_elements get_${object_type}_elements "" {
    switch $type {
        "Survey" {
            set indent ""
            if {[string equal -nocase "survey" $add_type]} {
                set checkbox 1
            }
        }
        "Survey Section" {
            set indent [string repeat "&nbsp;" 2]
            if {[string equal -nocase "section" $add_type]} {
                set checkbox 1
            }
        }
        "Survey Question" {
            set indent [string repeat "&nbsp;" 4]
            if {[string equal -nocase "question" $add_type]} {
                set checkbox 1
            }
        }
    }
}

if {[string equal "question" $add_type] && ![string equal "" section_name]} {

}

set orig_id [survey_library::orig_group_id -package_id $orig_packge_id]
#    set dotlrn_package_id [site_node::closest_ancestor_package -node_id $survey_node_id -package_key "dotlrn"]
#    set org_id [dotlrn_community::get_community_id -package_id $dotlrn_package_id]

# get group name
set orig_name [group::get_element -group_id $orig_id -element group_name]

set page_title "Add to library"
set context [list $page_title]
set header_stuff ""
set focus ""

ad_return_template 

