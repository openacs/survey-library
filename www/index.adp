<master>
  <property name="title">@page_title@</property>
  <property name="header_stuff">@header_stuff@</property>
  <property name="context">@context@</property>
  <property name="focus">@focus@</property>
  <a href="./categories/">Admin Categories</a>
  <if @browse@ eq 1><a href=".">Search Library</a></if><else><a href=".?browse=1">Browse Library</a></else>
  <formtemplate id="criteria"></formtemplate>

<listtemplate name="items"></listtemplate>