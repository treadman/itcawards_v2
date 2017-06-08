<!--- <cfabort showerror="look before you leap"> --->
<!--- function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>

<cfset multiplier = 200>

<cfspreadsheet action="read" src="../upload/update.xlsx" query="GetAllUsers" rows="3-423" sheet="2" >

<cfset count = 0>
<cfloop query="GetAllUsers">
	<cfif GetAllUsers.col_13 NEQ "">
		<cfset this_email = GetAllUsers.col_13 & "@lortobco.com">
	</cfif>
	<cfset found_one = false>
	<cfif this_email NEQ "">
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.ID, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
				SUM(p.points) AS points_awarded, u.is_active
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = 1000000035
			AND u.email = '#this_email#'
			GROUP BY u.ID
		</cfquery>
		<cfif GetUser.RecordCount EQ 1>
			<cfset found_one = true>
			<!---1 ----> 
		</cfif>
	</cfif>
	<cfif NOT found_one>
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.ID, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
				SUM(p.points) AS points_awarded, u.is_active
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = 1000000035
			AND u.fname = '#GetAllUsers.col_9#'
			AND u.lname = '#GetAllUsers.col_8#'
			GROUP BY u.ID
		</cfquery>
		<cfif GetUser.RecordCount EQ 1>
			<cfset found_one = true>
			<!---2 - --->
		</cfif>
	</cfif>
	<cfif NOT found_one>
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.ID, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
				SUM(p.points) AS points_awarded, u.is_active
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = 1000000035
			AND u.username = '#GetAllUsers.col_3#'
			GROUP BY u.ID
		</cfquery>
		<cfif GetUser.RecordCount EQ 1>
			<cfset found_one = true>
			<!---3 - --->
		</cfif>
	</cfif>
	<cfset that_awarded = (GetAllUsers.col_27 + GetAllUsers.col_28)/multiplier>
	<cfif NOT found_one>
		<!---X - --->
	<cfelse>
		<cfset this_awarded = 0>
		<cftry>
			<cfset this_awarded = GetUser.points_awarded + 0>
			<cfcatch></cfcatch>
		</cftry>
		<cfif this_awarded NEQ that_awarded>
			<cfif GetUser.is_active EQ 1>
				<!---<cfif GetUser.email EQ this_email>--->
					<!---<cfquery name="AwardPoints" datasource="#application.DS#">
						INSERT INTO #application.database#.awards_points (
							created_user_ID, created_datetime, user_ID, points, notes)
						VALUES (
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
							'#FLGen_DateTimeToMySQL()#',
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GetUser.ID#" maxlength="10">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#that_awarded-this_awarded#">,
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="Lorillard Adjustment - May 12 2015">
						)
					</cfquery>--->
					<cfoutput>#that_awarded-this_awarded#,#GetUser.fname#,#GetUser.lname#,#GetUser.email#</cfoutput>
					<!---<cfoutput>#that_awarded#, #this_awarded#, #that_awarded-this_awarded#</cfoutput>--->
					<br>
					<cfset count = count + 1>
				<!---<cfelse>
					email not a match.
				</cfif>--->
			<cfelse>
				<!---not active--->
			</cfif>
		<cfelse>
			<!---points ok.--->
		</cfif>
	</cfif>
</cfloop>
<!---
<br>
count <cfoutput>#count#</cfoutput>--->