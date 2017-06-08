<!--- <cfabort showerror="Be sure you have made all necessary changes!!"> --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Import Points</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>


<cfset ProgramID=1000000079>
<!--- <cfset mcc_max = 100>
<cfset mis_active = 1>
<cfset mis_done = 0>
<cfset mdefer_allowed = 0>
<cfset mExpiration_Date = '2008-05-01'>
<cfset mDEFERED=0> --->

<!--- GET THE LIST --->
<cfquery name="UserList" datasource="#application.DS#">
	SELECT *
	FROM #application.database#.TEMP_import
</cfquery>
<cfloop query="UserList">
<!--- Check to see if user already exists in "program_user" table --->
	<cfoutput>#UserList.username# - </cfoutput>
	<cfquery name="CheckForUser" datasource="#application.DS#">
		SELECT ID AS UserID
		FROM #application.database#.program_user
		WHERE username = <cfqueryparam value="#UserList.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="16">
		AND program_ID = <cfqueryparam value="#ProgramID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	</cfquery>
	<cfif CheckForUser.RecordCount GT 0>
		<cfset User_ID = CheckForUser.UserID>
		FOUND!
	<cfelse>
		NOT FOUND.
		<!--- If user does not exists in "program_user" table add new record to 'program_user' --->
		<cflock name="AddUserLock" timeout="10">
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
						is_active)
					VALUES
						(1212121212, 
						#NOW()#, 
						'External Load May 14, 2009', 
						<cfqueryparam value="#ProgramID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">, 
						<cfqueryparam value="#username#" cfsqltype="CF_SQL_VARCHAR" maxlength="16">, 
						<cfqueryparam value="#fname#" cfsqltype="CF_SQL_VARCHAR" maxlength="30">, 
						<cfqueryparam value="#lname#" cfsqltype="CF_SQL_VARCHAR" maxlength="30">, 
						<cfqueryparam value="#email#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">,1)
				</cfquery>
			<!--- Get the 'User_ID'  to be used to update 'award_points' table with new points below --->
				<cfquery name="GetUserID" datasource="#application.DS#">
					SELECT Max(ID) AS UserID FROM #application.database#.program_user
				</cfquery>
				<cfset User_ID = GetUserID.UserID>
			</cftransaction>
		</cflock>
	</cfif>
	<br>
<!--- Add points for this user to the 'award_points' table --->
	<cfquery name="AddUserPoints" datasource="#application.DS#">
		INSERT INTO #application.database#.awards_points 
			(created_user_ID, 
			created_datetime, 
			modified_concat, 
			user_ID, 
			points, 
			notes)
		VALUES
			(1212121212, 
			#NOW()#, 
			'External Load',
			<cfqueryparam value="#User_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			<cfqueryparam value="#points#" cfsqltype="CF_SQL_INTEGER" maxlength="8">, 
			'External Load July 17, 2009')
	</cfquery>
</cfloop>
<br>
<h1 align="center">Done.</h1>
</body>
</html>
