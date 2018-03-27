# 

ad_library {
    
    Tcl procedures to support survey-library
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-18
    @arch-tag: d713c679-5876-4f97-95fa-49286625db0e
    @cvs-id $Id$
}

namespace eval ::survey_library {}

ad_proc -public ::survey_library::orig_group_id {
    -package_id
} {
    Find the application group associated with the subsite
    or dotlrn package instance where the survey originated
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-12-22
    
    @param package_id

    @return 
    
    @error 
} {
    set survey_node_id [site_node::get_node_id_from_object_id -object_id $orig_package_id]
# grab the closest dotlrn or acs-subsite whichever comes first
# TODO add parameter to set dotlrn or subsite as default "parent" package
set orig_subsite_id [site_node::closest_ancestor_package -node_id $survey_node_id]
set orig_group_id [application_group::group_id_from_package_id -package_id $orig_subsite_id]
    
}

ad_proc -public ::survey_library::add_to_library {
    -object_id
    {-original_object_id ""}
    {-creation_party ""}
    {-active_p "f"}
    {-author_contact ""}
} {
    Add a existing survey object to the survey library
    and link to original item, if it was copied from
    another survey item
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-19
    
    @param object_id

    @param original_object_id

    @param active_p

    @return 
    
    @error 
} {
ns_log notice "
DB --------------------------------------------------------------------------------
DB DAVE debugging /var/lib/aolserver/evalengine/packages/survey-library/tcl/survey-library-procs.tcl
DB --------------------------------------------------------------------------------
DB creation_party = '${creation_party}'
DB --------------------------------------------------------------------------------"
    db_dml add_to_lib "insert into survey_library (object_id,original_object_id,active_p,creation_party,author_contact) values (:object_id,:original_object_id,:active_p,:creation_party,:author_contact)"    
}

ad_proc -public ::survey_library::copy_to_library {
    -object_id
    {-package_id ""}
    {-orig_package_id ""}
    {-author_contact ""}
    {-title ""}
    {-description ""}
} {
    Add a survey, section, or question to library
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-18
    
    @param object_id survey_id, section_id, or question_id

    @return 
    
    @error 
} {
    if {[string equal "" $package_id]} {
        if {[ad_conn -connected_p]} {
            set package_id [ad_conn package_id]
        } else {
            return ""
        }
    }
    if {![db_0or1row get_type "select object_type from survey_objects where object_id=:object_id"]} {
        # object is not a survey object
ns_log warning "
        DB --------------------------------------------------------------------------------
DB DAVE debugging /var/lib/aolserver/evalengine/packages/survey-library/tcl/survey-library-procs.tcl
DB --------------------------------------------------------------------------------
DB No survey object found for object_id = '${object_id}'
DB --------------------------------------------------------------------------------"
        return ""
    }
ns_log notice "
DB --------------------------------------------------------------------------------
DB DAVE debugging /var/lib/aolserver/evalengine/packages/survey-library/tcl/survey-library-procs.tcl
DB --------------------------------------------------------------------------------
DB object_id = '${object_id}'
DB object_type = '${object_type}'
DB package_id = '${orig_package_id}'
DB --------------------------------------------------------------------------------"

# get the community_id (argh! .LRN specific code, why couldn't it use
# subsites?)


    switch -- $object_type {
        survey {
            set new_object_id [survey_copy -survey_id $object_id -package_id $package_id -new_name $title -new_description $description]
        }
        survey_section {
            set default_survey_id [db_string get_default_survey "select survey_id from survey_library_default_objects where package_id=:package_id"]
            set new_object_id [survey_section_copy -section_id $object_id -new_survey_id $default_survey_id -new_name $title -new_description $description]
        }
        survey_question {
            set default_section_id [db_string get_default_survey "select section_id from survey_library_default_objects where package_id=:package_id"]
            set new_object_id [survey_question_copy -question_id $object_id -new_section_id $default_section_id]
        }
        survey_predefined_question {
            # FIXME
            # do we want to handle these?
        }
    }

    survey_library::add_to_library -object_id $new_object_id -original_object_id $object_id -creation_party $orig_group_id -author_contact $author_contact
    
    return new_object_id
}

ad_proc -private ::survey_library::map_object_use {
    -library_object_id
    -use_object_id
} {
    Keep track of objects that are created based on
    library objects
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-10-11
    
    @param library_object_id

    @param use_object_id

    @return 
    
    @error 
} {
    db_dml map_use "insert into survey_library_use_map (library_object_id,use_object_id) values (:library_object_id,:use_object_id)"
}

namespace eval ::survey::survey_library {}

ad_proc -public ::survey::survey_library::create_survey {
    -survey_id
} {
    Callback for survey library specific attributes
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-19
    
    @param survey_id

    @return 
    
    @error 
} {
    survey_library::add_to_library -object_id $survey_id
}

ad_proc -public ::survey::survey_library::create_section {
    -section_id
} {
    Callback for survey library specific attributes
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-19
    
    @param survey_id

    @return 
    
    @error 
} {
    survey_library::add_to_library -object_id $section_id
}

ad_proc -public ::survey_library::link {
    -link
    -object_id
    -package_id 
    {-return_url ""}
} {
    Generate a link into the survey library
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-20
    
    @param link

    @param object_id

    @return 
    
    @error 
} {
    set subsite_node_id [site_node::get_node_id_from_object_id -object_id [ad_conn subsite_id]]
    set node_id [site_node::get_children -package_key survey-library -node_id $subsite_node_id -element node_id]
    array set sn [site_node::get -node_id $node_id]
    if {![permission::permission_p -object_id $sn(package_id) -party_id [ad_conn user_id] -privilege "admin"]} {
        return ""
    }
    set link_text "Add to library"
    set url_base [site_node::get_url -node_id $subsite_node_id]
    set library_p ""
    set lib_object_id ""
    db_0or1row object_exists "select object_id as lib_object_id, case when object_id=:object_id then 1 else 0 end as library_p from survey_library where original_object_id=:object_id or object_id=:object_id"
    if {[string equal "1" $library_p]} {
        return [list "" ""]
    }
    if {![string equal "" $lib_object_id]} {
        # if object is already in library set action to view
        set link_text "View related library item"
        set link "one"
	set url [export_vars -no_empty -base ${url_base}$sn(name)/${link} {{survey_id $lib_object_id}}]
    } else {
	set url [export_vars -no_empty -base ${url_base}$sn(name)/${link} {object_id {orig_package_id $package_id} return_url}]
    }
    # see if the survey was created from a library object
    set response [list $url $link_text]
    if {[db_0or1row object_used "select library_object_id, use_object_id, s.name from survey_library_use_map, surveys s where use_object_id=:object_id and library_object_id=s.survey_id"]} {
	set orig_lib_url [export_vars -no_empty -base ${url_base}$sn(name)/survey/one {{object_id $library_object_id}}]        
        lappend response $orig_lib_url "Based on Library Object '${name}'"
    }
    return $response

}

ad_proc -public ::survey_library::default_object_id {
    package_id
    object_type
} {
    Return the default object_id for the package instance
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-12-21
    
    @param package_id

    @param object_type

    @return 
    
    @error 
} {
    if {[lsearch {survey survey_section survey_question} $object_type]} {
        return ""
    }
    if {![db_0or1row get_default_objects "select survey_id,section_id,question_proxy from survey_library_default_objects where package_id=:package_id"]} {
        return ""
    }
    switch $object_type {
        survey {
            return $survey_id
        }
        survey_section {
            return $section_id
        }
        survey_question {
            return $question_proxy
        }
    }
}
