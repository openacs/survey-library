# 

ad_page_contract {
    
    Add selected items to the library
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-21
    @arch-tag: eb44bbfa-5b9d-4a79-bc4e-9f11d98e6ab5
    @cvs-id $Id$
} {
    object_id
    {orig_package_id ""}
    {return_url ""}
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
set survey_lib_package_id [ad_conn package_id]

permission::require_permission \
    -object_id $survey_lib_package_id \
    -party_id $user_id \
    -privilege "create"

ad_form -export {object_id orig_package_id return_url} -form {
    {author:text(textarea) {label "Author Contact"} {html {cols 45 rows 8}}}
} 

# add title and description for survey and section
if {![db_0or1row get_type "select object_type from survey_objects where object_id=:object_id"]} {
    #error
}

# TODO programmatic area, purpose
if {$object_type eq "survey" || $object_type eq "survey_section"} {
    #get info 
    db_1row get_info "select name as title,description from survey_objects where object_id=:object_id"
    ad_form -extend -form {
	{title:text {label "Title"} {html {size 50}} {value $title}}
	{description:text(textarea) {label "Description"} {html {cols 45 rows 8}} {value $description}}
    }
} else {
    ad_form -extend -form {
	{title:text(hidden) {value ""}}
	{description:text(hidden) {value ""}}
    }
}

ad_form -extend -on_submit {
    # figure out if the ids are questions and if they all belong to the
    # same section, and they are all the questions in that section


    foreach id [lsort -increasing $object_id] {
        survey_library::copy_to_library -object_id $object_id -orig_package_id $orig_package_id -package_id $survey_lib_package_id -author_contact $author -title $title -description $description
    }

    if {[string equal "" $return_url]} {
        set return_url "./"
    }

    ad_returnredirect -message "$object_id added to survey library" $return_url

}

# show originating org info
if {$orig_package_id eq ""} {
    set orig_package_id [db_string get_pkg_id "select package_id from survey_objects where object_id=:object_id" -default ""]
}
    set orig_node_id [site_node::get_node_id_from_object_id -object_id $orig_package_id]
# grab the closest dotlrn or acs-subsite whichever comes first
# TODO add parameter to set dotlrn or subsite as default "parent" package
set orig_subsite_id [site_node::closest_ancestor_package -node_id [ad_conn node_id]]
set orig_id [application_group::group_id_from_package_id -package_id $orig_subsite_id]

#    set dotlrn_package_id [site_node::closest_ancestor_package -node_id $survey_node_id -package_key "dotlrn"]
#    set org_id [dotlrn_community::get_community_id -package_id $dotlrn_package_id]

# get group name
set orig_name [group::get_element -group_id $orig_id -element group_name]

set title "Add element to library"
set context [list $title]
set focus ""
set header_stuff ""

ad_return_template