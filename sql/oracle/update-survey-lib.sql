
drop view survey_objects;

alter table survey_library rename object_id to old_object_id;
alter table survey_library add object_id integer references acs_objects on delete cascade;
update survey_library set object_id=old_object_id;

alter table survey_library drop old_object_id;

alter table survey_library rename original_object_id to old_original_object_id;
alter table survey_library add original_object_id integer references acs_objects on delete set null;
update survey_library set original_object_id=old_original_object_id;
alter table survey_library drop old_original_object_id;

create or replace view survey_objects as

select  s.survey_id as object_id,
        s.package_id,
        apm_package__name(s.package_id) as package_name,
        s.survey_id,
        null as section_id,
        o.creation_date,
        o.last_modified,
        o.object_type,
        s.name,
        s.description,
        ot.pretty_name as type,
        case when sd.survey_id=s.survey_id then 't' else 'f' end as default_object_p,
        sl.original_object_id,
        sl.active_p,
        sl.creation_party,
        sl.author_contact
from    
        acs_objects o,
        acs_object_types ot,
        surveys s
        left join survey_library_default_objects sd
        on sd.package_id=s.package_id
        left join survey_library sl
        on s.survey_id=sl.object_id
where   o.object_id=s.survey_id
and     o.object_type=ot.object_type

union

select  ss.section_id as object_id,
        s.package_id,
        apm_package__name(s.package_id) as package_name,
        ss.survey_id as survey_id,
        ss.section_id as section_id,
        o.creation_date,
        o.last_modified,
        o.object_type,
        ss.name,
        ss.description,
        ot.pretty_name as type,
        case when sd.section_id=ss.section_id then 't' else 'f' end as default_object_p,
        sl.original_object_id,
        sl.active_p,
        sl.creation_party,
        sl.author_contact
from    survey_sections ss
        left join survey_library sl
        on ss.section_id=sl.object_id,
        acs_objects o,
        acs_object_types ot,
        surveys s
        left join survey_library_default_objects sd
        on sd.package_id=s.package_id
        where ss.section_id=o.object_id
and     ss.survey_id=s.survey_id
and     o.object_type=ot.object_type

union

select  sq.question_id as object_id,
        s.package_id,
        apm_package__name(s.package_id) as package_name,
        ss.survey_id as survey_id,
        sq.section_id as section_id,
        o.creation_date,
        o.last_modified,
        o.object_type,
        sq.question_text as name,
        null as description,
        ot.pretty_name as type,
        'f' as default_object_p,
        sl.original_object_id,
        sl.active_p,
        sl.creation_party,
        sl.author_contact
from    survey_questions sq
        left join survey_library sl
        on sq.question_id=sl.object_id,
        survey_sections ss,
        acs_objects o,
        acs_object_types ot,
        surveys s
        left join survey_library_default_objects sd
        on sd.package_id=s.package_id
where  sq.section_id=ss.section_id
and    s.survey_id=ss.survey_id
and    sq.question_id=o.object_id
and     o.object_type=ot.object_type;
