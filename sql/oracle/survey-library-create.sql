-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-09-18
-- @arch-tag: c57e7c4a-3f9a-40c1-8a89-bfb0d3981c8f
-- @cvs-id $Id$
--
create table survey_library (
        object_id       integer
                        constraint survey_library_object_id_fk
                        references acs_objects
			on delete cascade,
        original_object_id integer
                        constraint survey_library_orig_object_id_fk
                        references acs_objects
			on delete set null,
        active_p        char(1) check (active_p in ('t','f')),
        creation_party  integer
                        constraint survey_library_creation_party_fk
                        references parties
			on delete set null,
        author_contact  varchar(4000)

);

create index survey_library_object_id_idx on survey_library(object_id);
create index survey_library_orig_object_id_idx on survey_library(original_object_id);

create table survey_library_default_objects (
        survey_id       integer
                        constraint survey_do_survey_id_fk
                        references surveys,
        section_id      integer
                        constraint survey_do_section_id_fk
                        references survey_sections,
        package_id      integer
                        constraint survey_do_package_id_fk
                        references apm_packages
);

create index survey_do_package_id_idx on survey_library_default_objects(package_id);


--drop view survey_objects;
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

create table survey_library_use_map (
        library_object_id       integer,
        use_object_id           integer
);

create table survey_library_clips (
	user_id integer,
	object_id integer
);

create table survey_library_category_trees (
        package_id      integer,
        survey_tree     integer,
        section_tree    integer,
        question_tree   integer
);
