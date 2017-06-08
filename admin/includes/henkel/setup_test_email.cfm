<cfif isDefined("form.emailFrom") AND isDefined("form.emailSubject")>
	<cfif LEN(form.emailFrom) EQ 0>
		<cfset form.emailFrom = application.AwardsFromEmail>
	</cfif>
	<cfif LEN(form.emailSubject) EQ 0>
		<cfset form.emailSubject = "Henkel Loctite Awards">
	</cfif>
</cfif>
<cfif isDefined("form.test_email")>
	<cfset ex_first = "">
	<cfset ex_last = "">
	<cfset ex_user = "">
	<cfset ex_points = "">
	<cfset ex_activity = "">
	<cfset pe_first = "">
	<cfset pe_last = "">
	<cfset pe_user = "">
	<cfset pe_points = "">
	<cfset pe_activity = "">
	<cfset bl_first = "">
	<cfset bl_last = "">
	<cfset bl_user = "">
	<cfset bl_points = "">
	<cfset bl_activity = "">
	<cfset bp_first = "">
	<cfset bp_last = "">
	<cfset bp_user = "">
	<cfset bp_points = "">
	<cfset bp_activity = "">
</cfif>
