<?xml version="1.0"?>
<queryset>

<fullquery name="survey_exists">      
    <querytext>
	select 1 from surveys where survey_id = :survey_id
    </querytext>
</fullquery>

<fullquery name="question_ids_select">      
    <querytext>
	select question_id
	from survey_questions  
	where section_id = :section_id
	and active_p = 't'
	order by sort_order
    </querytext>
</fullquery>

<fullquery name="survey_sections">
    <querytext>
	select section_id,block_section_p from survey_sections
	where survey_id=:survey_id order by sort_key
    </querytext>
</fullquery>

<fullquery name="questions">
    <querytext>
select question_text, presentation_type, abstract_data_type,
    question_id, required_p from survey_questions where
    section_id=:section_id and active_p='t' order by sort_order
    </querytext>
</fullquery>

<fullquery name="get_style"> 
      <querytext>
      select 'survey/'||template_file as style from survey_templates t, surveys s
      where s.survey_id=:survey_id
      and s.template=t.template_id
      </querytext>
</fullquery>

</queryset>
