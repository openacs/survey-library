ad_page_contract {

    Display a questionnaire for one survey.

    @param  section_id   id of displayed survey

    @author philg@mit.edu
    @author nstrug@arsdigita.com
    @date   28th September 2000
    @cvs-id $Id$

} {
    {section_id:integer ""}
    return_url:optional

} -validate {
    survey_exists -requires {survey_id} {
	if ![db_0or1row survey_exists {}] {
	    ad_complain "[_ survey.lt_Survey_survey_id_does_1]"
	}
    }
} -properties {

    name:onerow
    section_id:onerow
    button_label:onerow
    questions:onerow
    description:onerow
    modification_allowed_p:onerow
    return_url:onerow
}
#     survey_id:integer,notnull
ad_require_permission $survey_id read

    get_survey_info -survey_id $survey_id
    set name $survey_info(name)
    set description $survey_info(description)
    set single_response_p $survey_info(single_response_p)
    set editable_p $survey_info(editable_p)
    set display_type $survey_info(display_type)

set context_bar [ad_context_bar "[_ survey.Preview_name]"]

set rownum 0
    
ad_form -name preview_survey -action one -form {
    {survey_id:text(hidden) {value $survey_id}}
}

db_foreach survey_sections {} {
    survey_section_add_to_form preview_survey $section_id
}

set style "survey/standard"
db_0or1row get_style ""

if {$return_url eq ""} {
    set return_url "one?[export_vars survey_id]"
}
set form_vars [export_form_vars section_id survey_id]
#ad_return_template

