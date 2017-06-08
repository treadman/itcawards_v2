<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<!--- THESE FIELDS ARE REQUIRED --->
<cfset ProgramID=1000000068>
<cfset mcc_max = 100>
<cfset mis_active = 1>
<cfset mis_done = 0>
<cfset mdefer_allowed = 0>
<cfset mExpiration_Date = '2008-05-01'>
<cfset mDEFERED=0>
<!--- GET THE LIST --->
<cfquery name="UserList" datasource="#application.DS#">
	SELECT *
	FROM #application.database#.TEMP_neilsen
	ORDER BY lname, fname
</cfquery>
<cfloop query="UserList">
<!--- Check to see if user already exists in "program_user" table --->
	<cfquery name="CheckForUser" datasource="#application.DS#">
		SELECT ID AS UserID
		FROM #application.database#.program_user
		WHERE username = <cfqueryparam value="#username#" cfsqltype="CF_SQL_VARCHAR" maxlength="16"> AND program_ID = <cfqueryparam value="#ProgramID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	</cfquery>
	<cfif CheckForUser.RecordCount GT 0>
		<cfset User_ID = CheckForUser.UserID>
		<cfquery name="UpdateUser" datasource="#application.DS#">
			UPDATE #application.database#.program_user SET
			expiration_date = <cfqueryparam value="#mExpiration_Date#" cfsqltype="CF_SQL_DATE">
			WHERE ID = <cfqueryparam value="#User_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		</cfquery>
	<cfelse>
<!--- If user does not exists in "program_user" table add new record to 'program_user' --->
		<cflock timeout="10">
			<cftransaction>
				<cfquery name="AddUser" datasource="#application.DS#">
					INSERT INTO #application.database#.program_user 
						(created_user_ID, 
						created_datetime, 
						modified_concat, 
						program_ID, 
						username, 
						fname, 
						lname, 
						email, 
						cc_max, 
						is_active, 
						is_done, 
						defer_allowed,
						expiration_date,
						entered_by_program_admin)
					VALUES
						(1212121213, 
						#NOW()#, 
						'External Load March 25, 2008', 
						<cfqueryparam value="#ProgramID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">, 
						<cfqueryparam value="#username#" cfsqltype="CF_SQL_VARCHAR" maxlength="16">, 
						<cfqueryparam value="#fname#" cfsqltype="CF_SQL_VARCHAR" maxlength="30">, 
						<cfqueryparam value="#lname#" cfsqltype="CF_SQL_VARCHAR" maxlength="30">, 
						<cfqueryparam value="#email#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">, 
						<cfqueryparam value="#mcc_max#" cfsqltype="CF_SQL_INTEGER" maxlength="6">, 
						<cfqueryparam value="#mis_active#" cfsqltype="CF_SQL_TINYINT" maxlength="1">, 
						<cfqueryparam value="#mis_done#" cfsqltype="CF_SQL_TINYINT" maxlength="1">, 
						<cfqueryparam value="#mdefer_allowed#" cfsqltype="CF_SQL_INTEGER" maxlength="8">,
						<cfqueryparam value="#mExpiration_Date#" cfsqltype="CF_SQL_DATE">,
						0)
				</cfquery>
<!--- Get the 'User_ID'  to be used to update 'award_points' table with new points below --->
				<cfquery name="GetUserID" datasource="#application.DS#">
					SELECT Max(ID) AS UserID FROM #application.database#.program_user
				</cfquery>
				<cfset User_ID = GetUserID.UserID>
			</cftransaction>
		</cflock>
	</cfif>
<!--- Add points for this user to the 'award_points' table --->
	<cfquery name="AddUserPoints" datasource="#application.DS#">
		INSERT INTO #application.database#.awards_points 
			(created_user_ID, 
			created_datetime, 
			modified_concat, 
			user_ID, 
			points, 
			notes, 
			is_defered)
		VALUES
			(1212121213, 
			#NOW()#, 
			'External Load',
			<cfqueryparam value="#User_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			<cfqueryparam value="#points#" cfsqltype="CF_SQL_INTEGER" maxlength="8">, 
			'External Load March 25, 2008',
			<cfqueryparam value="#mDEFERED#" cfsqltype="CF_SQL_TINYINT" maxlength="1">)
	</cfquery>
</cfloop>

<h1 align="center">Done.</h1>
</body>
</html>
