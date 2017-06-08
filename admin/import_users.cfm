<cfabort showerror="import_users.cfm should not be run.">
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">

<cfset created_user_ID = 1000000000>
<cfset program_ID = 1000000066>
<cfset Points = 5>
<cfset Notes = "Automatic awards from Henkel Fastenal uploaded - #Points# for registering">
<cfquery name="getImports" datasource="#application.DS#">
	SELECT IDH, email, first, last, function, phone, distrib, national, address1, city, state, zip
	FROM #application.database#.import_users
</cfquery>
<cfset thisPassword = 111111>
<cfloop query="getImports">
	<cfset ErrorMessage = "">
	<cfoutput>#getImports.last#, #getImports.first# - #getImports.email#</cfoutput>
	<cfif getImports.national EQ "US">
		<cfset is_international = false>
	<cfelse>
		<cfset is_international = true>
	</cfif>
	<cfif getImports.email IS "" OR NOT FLGen_IsValidEmail(getImports.email)><cfset ErrorMessage = ErrorMessage & '#getImports.email# is not a valid email address<br />'></cfif>
	<cfif getImports.first IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your first name<br />'></cfif>
	<cfif getImports.last IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your last name<br />'></cfif>
	<cfif getImports.function IS ""><cfset ErrorMessage = ErrorMessage & 'Please select your function<br />'></cfif>
	<cfif getImports.phone IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your phone number<br />'></cfif>
	<cfif getImports.distrib IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your distributor company name<br />'></cfif>
	<cfif getImports.address1 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch address<br />'></cfif>
	<cfif getImports.city IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch city<br />'></cfif>
	<cfif getImports.state IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch state<br />'></cfif>
	<cfif getImports.zip IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch zip code<br />'></cfif>
	<cfquery name="CheckEmail" datasource="#application.DS#">
		SELECT ID 
		FROM #application.database#.program_user
		WHERE email = <cfqueryparam value="#getImports.email#" cfsqltype="CF_SQL_VARCHAR">
		AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
		AND registration_type = 'Branch'
	</cfquery>
	<cfif CheckEmail.recordcount GT 0>
		<cfset ErrorMessage = ErrorMessage & 'That email is already registered<br />'>
	</cfif>
	<cfif ErrorMessage EQ "">
		<cflock name="program_userLock" timeout="60">
			<cfset gotOne = false>
			<cfloop condition="NOT gotOne">
				<cfquery name="CheckProgramUser" datasource="#application.DS#">
					SELECT ID 
					FROM #application.database#.program_user
					WHERE username = <cfqueryparam value="#thisPassword#" cfsqltype="CF_SQL_VARCHAR">
					AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
				</cfquery>
				<cfif CheckProgramUser.RecordCount IS 0>
					<cfset gotOne = true>
				<cfelse>
					<cfset thisPassword = thisPassword + 1>
				</cfif>
			</cfloop>
			<cfif gotOne>
				<cfoutput>#thisPassword# - </cfoutput>
				<cfquery name="AddProgramUser" datasource="#application.DS#">
					INSERT INTO #application.database#.program_user (
						created_user_ID, created_datetime, program_ID, username, fname, lname,
						ship_company, ship_address1, ship_city, ship_state, ship_zip, phone, email, is_active, idh, registration_type)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisPassword#" maxlength="16">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.first#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.last#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.distrib#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.address1#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.city#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#LEFT(getImports.state,2)#" maxlength="2">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.zip#" maxlength="32">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.phone#" maxlength="35">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.email#" maxlength="128">,
						0,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#getImports.IDH#" maxlength="16">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Branch" maxlength="16">

					)
				</cfquery>
				<cfquery name="GetMaxID" datasource="#application.DS#">
					SELECT MAX(ID) AS maxID
					FROM #application.database#.program_user
				</cfquery>
				<cfset programUserID = GetMaxID.maxID>
				<cfquery name="AwardPoints" datasource="#application.DS#">
					INSERT INTO #application.database#.awards_points (
						created_user_ID, created_datetime, user_ID, points, notes)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#programUserID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Points#">,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Notes#">
					)
				</cfquery>
				<!--- Send email --->
				<cfset user_name = thisPassword>
				<cfset first_name = getImports.first>
				<cfset last_name = getImports.last>
				<cfset email = getImports.email>
				<cfset emailTemplateID = 114>
				<cfset emailFrom = application.AwardsFromEmail>
				<cfset emailSubject = "Henkel Rewards Board Notification">
				<cfinclude template="/includes/henkel_award_email.cfm">
				OK!
			<cfelse>
				<cfset ErrorMessage = ErrorMessage & 'That password is already in use, please enter a different password.<br />'>
			</cfif>
		</cflock>
	</cfif>
	<cfif ErrorMessage NEQ "">
		<cfoutput>#ErrorMessage#</cfoutput>
	</cfif>
	<cfset thisPassword = thisPassword + 1>
	<br /><br />
</cfloop>
DONE!