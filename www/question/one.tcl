# 

ad_page_contract {
    
    Show one question
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-18
    @arch-tag: ea0e1c27-1e78-4839-a590-38a411c97b51
    @cvs-id $Id$
} {
    object_id:integer,notnull,trim
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]

permission::require_permission \
    -object_id $object_id \
    -party_id $user_id \
    -privilege "read"

# FIXME what should be show? the whole question?

db_1row get_question "select sq.*, so.survey_id as original_survey_id from survey_questions sq, survey_library sl, survey_objects so where sq.question_id=:object_id and sl.object_id=:object_id and so.object_id=sl.original_object_id" -column_array question_info

template::multirow create question label value link_url

foreach {label var} {"Question ID" question_id "Variable" pretty_id "Required?" required_p} {
    template::multirow append question $label $question_info($var)
}

# original survey link
if {$original_survey_id ne ""} {
    get_survey_info -survey_id $question_info(original_survey_id) -arrayname original_survey_info 
    set original_survey_id $original_survey_info(survey_id)
    set original_survey_node_id [site_node::get_node_id_from_object_id -object_id $original_survey_info(package_id)]
    set dotlrn_package_id [site_node::closest_ancestor_package -node_id $original_survey_node_id -package_key "dotlrn"]
    set community_id [dotlrn_community::get_community_id -package_id $dotlrn_package_id]
    if {$community_id ne ""} {
        set community_name [dotlrn_community::get_community_name $community_id]
        set community_url [dotlrn_community::get_community_url $community_id]

        template::multirow append question "Original Survey" "${community_name}: $original_survey_info(name)" $community_url
    }
}

set actions [list "Use in survey" [export_vars -base "create" {{orig_object_id $object_id}}] "Use this question in a survey"]

template::list::create \
    -name question \
    -multirow question \
    -actions $actions \
    -elements {
        label {label ""}
        value {label {} link_url_col {link_url}}
    }


set return_url [ad_return_url]
set search_results_url [ad_get_client_property survey_library last_search]
set page_title "View Question $question_info(question_id)"
set context [list $page_title]
set header_stuff ""
set focus ""
ad_return_template

