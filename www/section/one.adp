<master>
  <property name="title">@page_title@</property>
  <property name="header_stuff">@header_stuff@</property>
  <property name="context">@context@</property>
  <property name="focus">@focus@</property>
  

<listtemplate name="section"></listtemplate>
<include src="/packages/survey-library/lib/categorize" object_id="@object_id@" return_url="@return_url@">
<include src="/packages/survey/lib/one-section"
      section_id="@object_id@">

      <if @search_results_url@ not nil><a
      href="@search_results_url@">>>Return to Search Results</a></if>