# 

ad_page_contract {
    
    Index page of survey library 
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2004-09-18
    @arch-tag: 4e74f151-51ac-4a60-b97c-1a24eabfb543
    @cvs-id $Id$
} {
    return_url:optional
    clear:optional
    {q ""}
    {search "0"}
    {orderby "name"}
    {type "all"}
    {pa ""}
    {qtype ""}
    {browse "0"}
    {purpose ""}
    ok:optional
    refer_survey_id:optional
    refer_package_id:optional
} -properties {
} -validate {
} -errors {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]

permission::require_permission \
    -object_id $package_id \
    -party_id $user_id \
    -privilege "read"

if {[exists_and_not_null refer_survey_id]} {
    ad_set_client_property survey_library refer_survey_id $refer_survey_id
}

if {[exists_and_not_null refer_package_id]} {
    ad_set_client_property survey_library refer_package_id $refer_package_id
}

set create_p [permission::permission_p \
                  -object_id $package_id \
                  -party_id $user_id \
                  -privilege "create"]

# setup filters for object type Survey, Section, Question

# setup category filter

# setup full text search filter

# if clear is passed in, clear the query 
if {[info exists clear]} {
    ad_returnredirect .
    ad_script_abort
}

if {!$create_p} {
    set library ""
}
set library ""
set llibrary $library
set ltype $type
# FIXME DB this is a mess, need a inline formtemplate
if {[string equal "" $library]} {
    set bulk_actions ""
} else {
    set bulk_actions [list "Add to library" [export_vars -base add {object_id}] "Add to library"]        
}

# used in the if statement in the filter block to set the where clause

# FIXME use category trees assigned to this package

# TODO allow different trees for survey/section/question


#set qtype_options {{"-Select Question Type-" ""}     { "Closed Ended (dropdown, single response allowed)" "select" } { "Closed Ended (radio butons, single response allowed)" "radio" } { "Closed Ended (checkboxes, multiple responses allowed)" "checkbox" } { "Open Ended Text (short)" "textbox" } { "Open Ended Text (long)" "textarea" } {"Number" "number"} { "Date and Time" "date" }}

ad_form -name criteria -method GET -form {
    {search_info:text(inform) {label "Search"}}
    {search:text(hidden) {value 1}}
    {type:text(select),multiple,optional
        {label "Library Asset Type"}
        {options {{"All Types" "all"} {Survey Survey} {"Section" "Survey Section"} {"Question" "Survey Question"}} }
        {value "$ltype"} }

    {q:text,optional {label "Keyword"} {html {size 30}} {value $q}}
    {ok:text(submit) {label "Search"}}
    {clear:text(submit) {label "Clear"}}
}

set filters [list search [list label "Search" values { 0 1 } where_clause_eval { if {$search}  { if {$q ne ""} {array set result [acs_sc_call FtsEngineDriver search [list [string tolower $q] 0 0 -1 "" ""] "tsearch2-driver"]
    if {![info exists result(ids)]} {
	# search is not working, ignore search terms
	set where " 1=1 "
    } elseif {[llength $result(ids)] >0} {
	set result_ids $result(ids)
        set where " object_id in ([template::util::tcl_to_sql_list $result_ids])"
    } else {
        subst { 1=0 }
    }
} else { subst { 1=1 }}
} elseif {$browse} {subst {1=1}} else {subst { 1=0 }}}]]

# just search library

# DEDS: Dave, saving this for any use it might be.
lappend filters library [list label "Package_Id" values {"" "all"}  where_clause_eval { if {[string equal "" $library]} {set where " package_id=:package_id "} else {set where " package_id <> :package_id"}}]

lappend filters type [list label "Type" values {{"All Types" {all}} {"Survey" survey} {"Section" "Survey Section"} {"Question" "Survey Question"}} where_clause_eval { if {[string equal "all" $type]} { set where " 1=1 " } else {set where " type = :type "}}]

if {$qtype ne ""} {
    set pa ""
    set purpose ""
}

# FIXME let this work for all category mappings
#lappend filters qtype [list label "Question Type" values qtype_options where_clause_eval {
 #   if {$browse || $qtype eq ""} {
#	set where "1=1"
#    }	else {
	
#	set where "object_id in (select object_id from category_object_map c where c.category_id=:qtype)"
 #   }}]

lappend filters browse {}
template::list::create \
    -name items \
    -multirow items \
    -bulk_actions $bulk_actions \
    -no_data "No items match your search." \
    -key object_id \
    -elements {
        type {label "Type"}
        name {link_url_col view_url label "Name"}
        group_name {label "From"}
        last_modified {label "Last Modified"}
        description {label "Excerpt"}
        author_contact {label "Author Contact"}
    } \
    -filters $filters \
    -orderby {
        type {orderby type}
        name {orderby upper(name)}
        last_modified {orderby last_modified}
        package_name {orderby package_name}
    }

db_multirow -unclobber -extend {view_url} items get_items "select *, group_name || creation_party as group_name  from survey_objects left join groups on creation_party=group_id where default_object_p = 'f' and active_p='t' [template::list::filter_where_clauses -name "items" -and] [template::list::orderby_clause -name "items" -orderby]" {
    set view_type [string map {"Survey Question" "question" "Survey Section" "section" "Survey" "survey" "Predefined Survey Question" "question"} $type]
    set view_url [export_vars -base $view_type/one -no_empty {object_id}]
    set last_modified [lc_time_fmt $creation_date "%x %X"]
}

set page_title "Browse Survey Library"
set context [list $page_title]
set header_stuff ""
set focus ""

set refer_package_id [ad_get_client_property survey_library refer_package_id]
if {$refer_package_id eq ""} {
    set refer_package_url ""
    set community_id ""
} {
    set refer_package_url "[apm_package_url_from_id $refer_package_id]admin/"
    set community_id [dotlrn_community::get_community_id -package_id $refer_package_id]
}
ad_set_client_property survey_library last_search [ad_return_url]
ad_return_template




