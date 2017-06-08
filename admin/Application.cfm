<!--- TODO: Take this cookie expiration out after a while: --->
<cfcookie name="pgm_ID" expires="now" value="">

<cfset request.newNav = false>
<cfif cgi.remote_addr EQ "63.68.13.37adf">
	<cfset request.newNav = true>
</cfif>

<cfinclude template="../Application.cfm">
<!--- TODO:  Get rid of the old Henkel selector.  You'll have to search for "request.henkel_ID" --->
<!--- Old way of doing Henkel as a separate selector (Must stay here until new method in place)--->
<!--- We'll still need "request.selected_henkel_program" for various reasons --->
<cfset request.henkel_ID = 0>
<cfif isDefined("cookie.henkel_id") AND isNumeric(cookie.henkel_ID)>
	<cfset request.henkel_ID = cookie.henkel_id>
	<cfquery name="request.selected_henkel_program" datasource="#application.DS#">
		SELECT p.company_name, p.program_name, h.has_distributors, h.has_regions, h.is_region_by_state,
			h.is_canadian, h.default_IDH, h.default_domain, h.registration_template_ID,
			h.has_branch_participation, h.do_report_export, h.do_report_billing,
			h.do_report_branch, h.is_registration_closed, distributor_label
		FROM #application.database#.program p
		LEFT JOIN #application.database#.program_henkel h ON h.program_ID = p.ID
		WHERE p.ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="cf_sql_integer">
	</cfquery>
</cfif>
<cfquery name="request.henkel_programs" datasource="#application.DS#">
	SELECT ID, company_name, program_name
	FROM #application.database#.program
	WHERE is_henkel = 1
</cfquery>
<cfset request.henkel_ID_list = ValueList(request.henkel_programs.ID)>
<!--- End of old Henkel selector --->


<!--- The new way is going to force a selection of any program --->
<cfset request.selected_program_ID = 0>

<cfif isDefined("cookie.itc_program")>
	
	<!--- Let's be sure that the cookie was not hacked --->
	<cfif ListLast(cookie.itc_program,"-") NEQ Hash(Insert(application.salt,Left(cookie.itc_program,10),1))>
		<cfabort showerror="This cookie may have been hacked: #cookie.itc_program#">
	</cfif>
	
	<cfset request.is_admin = false>
	<cfif IsDefined('cookie.itc_program') AND Left(cookie.itc_program,10) EQ '1000000001'>
		<cfset request.is_admin = true>
		<cfif isDefined("cookie.program_ID")>
			<cfset request.selected_program_ID = cookie.program_ID>
		</cfif>
	<cfelse>
		<cfset request.selected_program_ID = Left(cookie.itc_program,10)>
	</cfif>
	<cfif request.selected_program_ID NEQ 0>
		<cfset request.henkel_ID = request.selected_program_ID>
	</cfif>

</cfif>