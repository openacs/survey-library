<master>
  <property name="title">@page_title@</property>
  <property name="header_stuff">@header_stuff@</property>
  <property name="context">@context@</property>
  <property name="focus">@focus@</property>
<if @warning_message@ not nil><div class="boxed-user-message"><ul><li>@warning_message@</li></ul></div></if>  
<h4>Originated by @orig_name@</h4>
<listtemplate name="survey_elements"></listtemplate>