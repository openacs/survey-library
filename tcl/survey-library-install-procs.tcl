# 

ad_library {
    
    APM Install callback procedures
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-18
    @arch-tag: 608c4b8e-5de5-4526-a294-2bf3b9d06cdf
    @cvs-id $Id$
}

namespace eval ::survey_library::install {}

ad_proc -public ::survey_library::install::package_install {
} {
    Setup survey library package
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-18
    
    @return 
    
    @error 
} {
    # placeholder, everything happens per instance
}

ad_proc -public ::survey_library::install::after_mount {
    -package_id
    -node_id
} {
    
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-19
    
    @param package_id

    @param node_id

    @return 
    
    @error 
} {

    set instance_name [site_node::get_element -node_id $node_id -element instance_name]
    # setup application group
    set app_group_id [application_group::new \
                          -package_id $package_id \
                          -group_name "${instance_name} users"]

    # setup a relational segment for admins
    set admin_rel_id [rel_segments_new $app_group_id "admin_rel" "${instance_name} administrators"]

    # grant admin over the whole package
    permission::grant \
        -object_id $package_id \
        -party_id $admin_rel_id \
        -privilege "admin"
    
    # setup master survey and section to hold library items with no
    # parent
    set survey_id [survey_new \
                       -survey_id "" \
                       -name $package_id \
                       -description "Default Survey for package_id $package_id" \
                       -package_id $package_id \
                       -context_id $package_id] 

    set section_id [survey_section_new \
        -section_id "" \
        -name $package_id \
        -description "Default Section for package_id $package_id" \
        -survey_id $survey_id \
                        -context_id $package_id]

    db_dml set_default_objects "insert into survey_library_default_objects (survey_id, section_id, package_id) values (:survey_id, :section_id, :package_id)"
    
    
}


