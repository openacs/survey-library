-- 
-- 
-- 
-- @author Dave Bauer (dave@thedesignexperience.org)
-- @creation-date 2004-09-21
-- @arch-tag: f86b56c1-358c-490d-adf4-eedf47495f21
-- @cvs-id $Id$
--


drop view survey_objects;
create function inline_0 () returns integer as '
declare v_row record;
declare survey_row record;
begin

for v_row in select distinct package_id from survey_library_default_objects
loop
        for survey_row in select survey_id from surveys where packge_id=v_row(package_id)
                loop
                        perform survey__remove(survey_row.survey_id);
                end loop;
end loop;
return null;
end;' language 'plpgsql';

select inline_0();

drop function inline_0();

drop table survey_library_default_objects;
drop table survey_library;