ad_page_contract {
    allow user to mark questions/sections/surveys and save for later
} {

}

# need to know who is clipping items, so make sure they are logged in
set user_id [auth::require_login]

# users only get one clipboard, so we just save all the items in one table
# keyed on user_id

# FIXME make this an include so we can show it on any page in the library
# and the user can see where they are.

# FIXME add an include to generate link to clipboard

db_multirow clips get_clips "select s.* from survey_objects, survey_library_clips slc where slc.user_id=:user_id and slc.object_id=s.object_id"

template::list::create \
    -name clips \
    -multirow clips \
    -elements {
	name
    }

ad_return_template
