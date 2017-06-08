<!--- Hard-coded Stuff --->
<cfparam name="emailSubject" default="Henkel Loctite Registration">
<cfif NOT isDefined("emailFrom")>
	<cfabort showerror="emailFrom is required.  (includes/henkel_award_email.cfm, line 5)">
</cfif>
<cfif NOT isDefined("emailTemplateID") OR NOT isNumeric(emailTemplateID)>
	<cfabort showerror="emailTemplateID must be a valid ID for the email_templates table.  (includes/henkel_award_email.cfm, line 8)">
</cfif>

<cfif isDefined("first_name") AND isDefined("user_name") AND isDefined("email")>

	<!--- Find template --->
	<cfquery name="template" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#emailTemplateID#">
	</cfquery>

	<!--- Replace variables --->
	<cfset emailText = template.email_text>
	<cfset emailText = Replace(emailText,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
	<cfif isDefined("last_name")>
		<cfset emailText = Replace(emailText,"USER-LAST-NAME",last_name,"all")>
	</cfif>
	<cfset emailText = Replace(emailText,"USER-FIRST-NAME",first_name,"all")>
	<cfset emailText = Replace(emailText,"USER-NAME",user_name,"all")>

	<!--- Send Email --->
	<cfmail to="#email#" from="#emailFrom#" subject="#emailSubject#" type="html">
#emailText#
	</cfmail>

</cfif>	
