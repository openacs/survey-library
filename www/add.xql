<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN"
"http://www.thecodemill.biz/repository/xql.dtd">
<!--  -->
<!-- @author Dave Bauer (dave@thedesignexperience.org) -->
<!-- @creation-date 2004-09-21 -->
<!-- @arch-tag: f2567bee-2386-423c-b54d-e27b9507d5a6 -->
<!-- @cvs-id $Id$ -->

<queryset>
  <fullquery name="get_survey_elements">
    <querytext>
      select so.*,
        case when s.single_section_p then '' else ss.name
        end as section_name        
        from
        survey_objects so left join survey_sections ss on
        so.section_id=ss.section_id and ss.section_id <> so.object_id,
        surveys s
        where s.survey_id=:object_id and so.survey_id=s.survey_id
        order by so.object_id
        
    </querytext>
  </fullquery>
  <fullquery name="get_section_elements">
    <querytext>
      select * from survey_objects where section_id=:object_id
    </querytext>
  </fullquery>
  <fullquery name="get_question_elements">
    <querytext>
      select * from survey_objects where object_id=:object_id
    </querytext>
  </fullquery>
  
  
</queryset>