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
	<cfoutput>#GetAllUsers.col_4#,</cfoutput>
	<cfset found_one = false>
	<cfif GetAllUsers.col_4 NEQ "">
		<cfset this_email = trim(GetAllUsers.col_4)>
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.ID, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
				IFNULL(SUM(p.points),0) AS points_awarded, u.is_active
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = 1000000035
			AND trim(u.email) = '#this_email#'
			AND is_active = 1
			GROUP BY u.ID
		</cfquery>
		<cfif GetUser.RecordCount EQ 1>
			<cfset found_one = true>
		</cfif>
		<cfif GetUser.RecordCount GT 1>
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.ID, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
				IFNULL(SUM(p.points),0) AS points_awarded, u.is_active
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = 1000000035
			AND trim(u.email) = '#this_email#'
			AND is_active = 1
			AND CONCAT(u.fname,' ',u.lname) = '#GetAllUsers.col_8#'
			GROUP BY u.ID
		</cfquery>
		<cfif GetUser.RecordCount EQ 1>
			<cfset found_one = true>
		</cfif>
	</cfif>
	</cfif>
	<cfif NOT found_one>
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.ID, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
				IFNULL(SUM(p.points),0) AS points_awarded, u.is_active
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = 1000000035
			AND CONCAT(u.fname,' ',u.lname) = '#GetAllUsers.col_8#'
			GROUP BY u.ID
		</cfquery>
		<cfif GetUser.RecordCount EQ 1>
			<cfset found_one = true>
		</cfif>
	</cfif>
	<cfset that_awarded = GetAllUsers.col_12>
	<cfif NOT found_one>
		not found
	<cfelse>
	<cfquery name="NegPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM(points_used),0) AS neg_pt, IFNULL(SUM(cc_charge),0) AS neg_cc
		FROM #application.database#.order_info
		WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetUser.ID#">
		AND created_datetime < '2015-05-01'
		AND is_valid = 1
	</cfquery>

		<cfset this_awarded = GetUser.points_awarded - NegPoints.neg_pt>
		<cfoutput>#GetUser.fname#,#GetUser.lname#,</cfoutput>
		<cfif this_awarded NEQ that_awarded>
			<cfif GetUser.is_active EQ 1>
					<cfquery name="AwardPoints" datasource="#application.DS#">
						INSERT INTO #application.database#.awards_points (
							created_user_ID, created_datetime, user_ID, points, notes)
						VALUES (
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
							'#FLGen_DateTimeToMySQL()#',
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GetUser.ID#" maxlength="10">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#that_awarded-this_awarded#">,
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="Lorillard Adjustment - May 20 2015">
						)
					</cfquery>
					<cfoutput>#that_awarded-this_awarded#</cfoutput>
					<cfset count = count + 1>
			<cfelse>
				not active
			</cfif>
		<cfelse>
			points ok
		</cfif>
	</cfif>
	<br>
</cfloop>

<br>
count <cfoutput>#count#</cfoutput>