<master>
  <property name="title">@title@</property>
  <property name="header_stuff">@header_stuff@</property>
  <property name="context">@context@</property>
  <property name="focus">@focus@</property>
  <listtemplate name="survey"></listtemplate>
<include src="/packages/survey-library/lib/categorize" object_id="@object_id@" return_url="@show_return_url@">
<if @admin_p@ eq 1><include src="/packages/survey-library/lib/survey-admin"
  object_id="@object_id@" return_url="@return_url@">
        </if><else>
<if @show@ eq "t">
          <include src="/packages/survey-library/lib/survey-preview" survey_id="@object_id@" return_url="@show_return_url@">
</if><else>
          <a href="@show_url@">Show full survey</a></else>
</else>