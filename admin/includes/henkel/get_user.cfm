<cfset thisPos = 0>
<cfif isDefined("form.dupeList")>
	<cfset thisPos = ListFindNoCase(form.dupeList,GetEmails.email)>
</cfif>
<cfquery name="getExistingUser" datasource="#application.DS#">
	SELECT ID, username, fname, lname, expiration_date, idh
	FROM #application.database#.program_user
	WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
	<cfif thisPos GT 0 AND isDefined("form.dupe_#thisPos#")>
		AND username = <cfqueryparam value="#evaluate('form.dupe_#thisPos#')#" cfsqltype="cf_sql_varchar">
	</cfif>
	AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
	AND registration_type <> 'BranchHQ'
</cfquery>
<cfif request.selected_henkel_program.has_branch_participation AND getExistingUser.recordcount EQ 0>
	<cfquery name="getBranchManager" datasource="#application.DS#">
		SELECT u.ID, u.username, u.fname, u.lname, u.expiration_date, u.idh, u.email
		FROM #application.database#.henkel_register r
		LEFT JOIN #application.database#.program_user u ON u.email = r.email
		WHERE r.alternate_emails like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#GetEmails.email#%">
			AND u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
			AND u.registration_type <> 'BranchHQ'
		<cfif thisPos GT 0 AND isDefined("form.dupe_#thisPos#")>
			AND u.username = <cfqueryparam value="#evaluate('form.dupe_#thisPos#')#" cfsqltype="cf_sql_varchar">
		</cfif>
	</cfquery>
<cfelse>
	<!--- Be sure we have a defined query with no records --->
	<cfquery name="getBranchManager" datasource="#application.DS#">
		SELECT *
		FROM #application.database#.henkel_register
		WHERE ID < 0
	</cfquery>	
</cfif>