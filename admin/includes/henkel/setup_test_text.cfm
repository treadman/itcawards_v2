<cfif isDefined("form.ex_template_ID")>
	<!--- EXISTING USER template --->
	<cfquery name="FindTemplateText1" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.ex_template_ID#">
	</cfquery>
	<cfset ex_email_text = FindTemplateText1.email_text>
</cfif>
<cfif isDefined("form.pe_template_ID")>
	<!--- PENDING USER template --->
	<cfquery name="FindTemplateText2" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.pe_template_ID#">
	</cfquery>
	<cfset pe_email_text = FindTemplateText2.email_text>
</cfif>
<cfif isDefined("form.bl_template_ID")>
	<!--- BRANCH LEADER template --->
	<cfquery name="FindTemplateText3" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.bl_template_ID#">
	</cfquery>
	<cfset bl_email_text = FindTemplateText3.email_text>
</cfif>
<cfif isDefined("form.bp_template_ID")>
	<!--- BRANCH PARTICIPANT template --->
	<cfquery name="FindTemplateText4" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.bp_template_ID#">
	</cfquery>
	<cfset bp_email_text = FindTemplateText4.email_text>
</cfif>
