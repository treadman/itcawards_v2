<!---<cfabort showerror="Kaman Update should only be used by developer.">--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Kaman Update</title>

<link href="includes/admin_style.css" rel="stylesheet" type="text/css">

</head>
<body>

<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<cfset alert_msg = "">
<cfset program_ID = 1000000010>

<cfquery name="SelectSubprograms" datasource="#application.DS#">
	SELECT ID as subprogram_ID, subprogram_name, is_active
	FROM #application.database#.subprogram
	WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
	ORDER BY sortorder
</cfquery>



<!---
Subtract inactive subprogram points...<br><br>
<cfset note_prefix='Subprogram not active:'>
<cfparam name="url.fix" default="0">

<cfquery name="GetSubPrograms" datasource="#application.DS#">
	SELECT s.ID, s.subprogram_name, SUM(p.subpoints) as total
	FROM #application.database#.subprogram_points p
	LEFT JOIN #application.database#.subprogram s ON s.ID = p.subprogram_ID
	WHERE s.is_active = 0 AND s.program_ID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
	GROUP BY p.subprogram_ID
	HAVING total != 0
</cfquery>

<cfif GetSubPrograms.recordcount EQ 0>
	All inactive supprgrams are zeroed!<br><br>
<cfelse>
	<cfloop query="GetSubPrograms">
		<cfset points_update = 0>
		<cfset sp_ID = GetSubPrograms.ID>
		<cfset sp_name = GetSubPrograms.subprogram_name>
		<cfoutput><strong>#GetSubPrograms.subprogram_name#</strong></cfoutput>:<br>
		<cfquery name="GetUsers" datasource="#application.DS#">
			SELECT u.ID, u.username, u.fname, u.lname, SUM(p.subpoints) as total
			FROM #application.database#.subprogram_points p
			LEFT JOIN #application.database#.program_user u ON u.ID = p.user_ID
			WHERE p.subprogram_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#sp_ID#" maxlength="10">
			GROUP BY u.ID
			HAVING total != 0
		</cfquery>
		<cfif GetUsers.recordCount EQ 0>
			No users with this subprograms points. (should not be possible)<br>
		<cfelse>
			<cfloop query="GetUsers">
				<cfset user_ID = getUsers.ID>
				<cfset ProgramUserInfo(user_ID)>
				<cfoutput>
				#GetUsers.username# has:<br>
				&nbsp;&nbsp;#GetUsers.total# #GetSubPrograms.subprogram_name# points<br>
				&nbsp;&nbsp;#user_totalpoints# awards points<br>
				</cfoutput>
				<cfif user_totalpoints GTE GetUsers.total>
					<cfset points_update = GetUsers.total>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<cfif points_update NEQ 0>
			<cfbreak>
		</cfif>
		<br><br>
	</cfloop>
	<cfif points_update NEQ 0>
		<cfif url.fix EQ 1>
			<cfset points_update = 0 - points_update>
			<cfquery name="UpdateSubPoints" datasource="#application.DS#">
				INSERT INTO #application.database#.subprogram_points
					(created_user_ID, created_datetime, subprogram_ID, user_ID, subpoints)
				VALUES
					(1212121212, NOW(), #sp_ID#, #user_ID#, #points_update#)
			</cfquery>
			<cfquery name="UpdatePoints" datasource="#application.DS#">
				INSERT INTO #application.database#.awards_points
					(created_user_ID, created_datetime, user_ID, points, notes)
				VALUES
					(1212121212, NOW(), #user_ID#, #points_update#, '#note_prefix##sp_name#')
			</cfquery>
			<cflocation url="kaman_update.cfm" addtoken="no">
		<cfelse>
			<cfquery name="GetPointHistory" datasource="#application.DS#">
				SELECT created_datetime, created_user_ID, points AS thispoints, IFNULL(notes,'(no note)') AS thisnote, 000 AS order_number, IF(is_defered = 1, 'true', 'false') AS thisdef, ID AS point_ID 
				FROM #application.database#.awards_points
				WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">
				
				UNION
				
				SELECT created_datetime, created_user_ID, ((points_used * credit_multiplier)/points_multiplier) AS thispoints, '' AS thisnote, order_number AS order_number, 'false' AS thisdef, 444 AS point_ID
				FROM #application.database#.order_info
				WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10"> 
					AND is_valid = 1
				ORDER BY created_datetime
			</cfquery>
			<cfoutput>
			<br><br>
			Fix #getUsers.fname# #getUsers.lname# (#getUsers.username#) in #sp_name#<br><br>
			Remove #points_update# points?
			<input type="button" value="  Remove Points " onClick="window.location='kaman_update.cfm?fix=1'">
			<br>
			<table cellpadding="5" cellspacing="1" border="0" width="800px;">
				<tr class="selectedbgcolor">
				<td colspan="3" class="headertext">Actual Award Points</td>
				</tr>
				<tr class="contenthead">
				<td class="headertext">Date</td>
				<td class="headertext">Points</td>
				<td class="headertext">Note</td>
				</tr>
				<cfloop query="GetPointHistory">
					<tr class="content">
					<td>#FLGen_DateTimeToDisplay(created_datetime)#</td>
					<td align="right"><cfif thisdef><span class="sub">[defered]</span></cfif><cfif order_number NEQ 000>-</cfif> #thispoints#</td>
					<td><cfif order_number NEQ 000>Order Number: #order_number#<cfelse>#thisnote# <span class="sub">Entered by #FLGen_GetAdminName(created_user_ID)#</span></cfif></td>
					</tr>
				</cfloop>
				<tr class="content">
				<td align="right" class="headertext" colspan="2">#user_totalpoints#</td>
				<td class="headertext">TOTAL POINTS</td>
				</tr>
				<!--- subprogram point summary --->
				<cfif SelectSubprograms.RecordCount NEQ 0>
					<cfloop query="SelectSubprograms">
						<cfquery name="FindSubprogramPoints" datasource="#application.DS#">
							SELECT IFNULL(SUM(subpoints),0) AS subpoints
							FROM #application.database#.subprogram_points
							WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#"> 
								AND subprogram_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#subprogram_ID#">
						</cfquery>
						<cfquery name="GetSubpointHistory" datasource="#application.DS#">
							SELECT ID AS subpoint_ID, created_datetime, created_user_ID, subpoints 
							FROM #application.database#.subprogram_points
							WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#">
								AND subprogram_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#subprogram_ID#">
							ORDER BY created_datetime
						</cfquery>
						<cfif GetSubpointHistory.RecordCount GT 0>
							<tr bgcolor="##D6EFF7">
							<td colspan="3" class="headertext">#subprogram_name# Points</td>
							</tr>
							<tr class="contenthead">
							<td class="headertext">Date</td>
							<td class="headertext">Points</td>
							<td class="headertext">Note</td>
							</tr>
							<cfloop query="GetSubpointHistory">
								<tr class="content">
								<td>#FLGen_DateTimeToDisplay(created_datetime)#</td>
								<td align="right">#subpoints#</td>
								<td><span class="sub">Entered by #FLGen_GetAdminName(created_user_ID)#</span></td>
								</tr>
							</cfloop>
							<tr class="content">
							<td align="right" class="headertext" colspan="2">#FindSubprogramPoints.subpoints#</td>
							<td class="headertext">TOTAL SUBPOINTS</td>
							</tr>
						</cfif>
					</cfloop>
				</cfif>
			</table>
			</cfoutput>
		</cfif>
	</cfif>
</cfif>
--->


<!--- 
Update from file...<br>
<cfparam name="url.fix" default="0">
<cfset fileName = "kaman.csv">
<cfset hasFile = true>
<cftry>
	<cffile action="read" variable="thisData" file="#application.FilePath##fileName#">
	<cfcatch><cfset hasFile = false></cfcatch>
</cftry>
<cfif NOT hasFile>
	<cfset alert_msg="Could not get data from #fileName#.">
</cfif>
<cfif alert_msg EQ "">
	<cfset thisData = Replace(thisData,"#CHR(13)##CHR(10)#","|","ALL")>
	<cfset sp_ID = 0>
	<cfset user_ID = 0>
	<cfloop list="#thisData#" index="thisLine" delimiters="|">
		<cfset points_update = 0>
		<cfif ListFirst(thisLine,':') EQ 'Program'>
			<cfset program_name = trim(ListLast(thisLine,':'))>
			<!---Get Subprogram --->
			<cfquery name="getSubprogram" datasource="#application.DS#">
				SELECT ID
				FROM #application.database#.subprogram
				WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
				AND subprogram_name = '#program_name#'
			</cfquery>
			<cfif getSubprogram.recordcount EQ 0>
				<cfset alert_msg = "Subprogram #program_name# not found!">
				<cfbreak>
			<cfelseif getSubprogram.recordcount GT 1>
				<cfset alert_msg = "Subprogram #program_name# is duplicated!">
				<cfbreak>
			<cfelse>
				<cfoutput><b>#program_name#</b></cfoutput>:
				<cfset sp_ID = getSubprogram.ID>
				<cfset user_ID = 0>
			</cfif>
		<cfelse>
			<!---Get user--->
			<cfquery name="getUsers" datasource="#application.DS#">
				SELECT ID, lname, fname
				FROM #application.database#.program_user
				WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
				AND username = '#thisLine#'
			</cfquery>
			<cfif getUsers.recordcount EQ 0>
				<cfset alert_msg = "User #thisLine# not found!">
				<cfbreak>
			<cfelseif getUsers.recordcount GT 1>
				<cfset alert_msg = "User #thisLine# is duplicated!">
				<cfbreak>
			<cfelse>
				<cfset user_ID = getUsers.ID>
				<cfoutput>#getUsers.fname# #getUsers.lname# (#thisLine#)</cfoutput>
			</cfif>
		</cfif>
		<cfif user_ID GT 0 AND sp_ID GT 0>
			<cfquery name="getSubprogramPoints" datasource="#application.DS#">
				SELECT IFNULL(SUM(subpoints),0) AS total FROM #application.database#.subprogram_points
				WHERE subprogram_ID = #sp_ID#
				AND user_ID = #user_ID#
			</cfquery>
			<cfif getSubprogramPoints.total NEQ 0>
				<cfset points_update = getSubprogramPoints.total>
				<cfbreak>
			</cfif>
		</cfif>
	</cfloop>
	<cfif points_update NEQ 0>
		<cfif url.fix GT 0>
			<cfset points_update = 0 - points_update>
			<cfquery name="UpdateSubPoints" datasource="#application.DS#">
				INSERT INTO #application.database#.subprogram_points
					(created_user_ID, created_datetime, subprogram_ID, user_ID, subpoints)
				VALUES
					(1212121212, NOW(), #sp_ID#, #user_ID#, #points_update#)
			</cfquery>
			<cfif url.fix NEQ 3>
				<cfquery name="UpdatePoints" datasource="#application.DS#">
					INSERT INTO #application.database#.awards_points
						(created_user_ID, created_datetime, user_ID, points, notes)
					VALUES
						(1212121212, NOW(), #user_ID#, #points_update#, 'Per Termed Escrow POP Points spreadsheet')
				</cfquery>
			</cfif>
			<cfif url.fix NEQ 2>
				<cfquery name="UpdateUser" datasource="#application.DS#">
					UPDATE #application.database#.program_user
					SET is_active = 0
					WHERE ID = #user_ID#
				</cfquery>
			</cfif>
			<cflocation url="kaman_update.cfm" addtoken="no">
		<cfelse>
			<cfquery name="GetPointHistory" datasource="#application.DS#">
				SELECT created_datetime, created_user_ID, points AS thispoints, IFNULL(notes,'(no note)') AS thisnote, 000 AS order_number, IF(is_defered = 1, 'true', 'false') AS thisdef, ID AS point_ID 
				FROM #application.database#.awards_points
				WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">
				
				UNION
				
				SELECT created_datetime, created_user_ID, ((points_used * credit_multiplier)/points_multiplier) AS thispoints, '' AS thisnote, order_number AS order_number, 'false' AS thisdef, 444 AS point_ID
				FROM #application.database#.order_info
				WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10"> 
					AND is_valid = 1
				ORDER BY created_datetime
			</cfquery>
			<cfoutput>
			<br><br>
			Fix #getUsers.fname# #getUsers.lname# (#thisLine#) in #program_name#<br><br>
			Remove #points_update# points?
			<input type="button" value="  Remove from Both and Deactivate " onClick="window.location='kaman_update.cfm?fix=1'">
			<input type="button" value="  Remove from Both Only " onClick="window.location='kaman_update.cfm?fix=2'">
			<input type="button" value="  Remove from #program_name# only" onClick="window.location='kaman_update.cfm?fix=3'">
			<br>
			<table cellpadding="5" cellspacing="1" border="0" width="800px;">
				<tr class="selectedbgcolor">
				<td colspan="3" class="headertext">Actual Award Points</td>
				</tr>
				<tr class="contenthead">
				<td class="headertext">Date</td>
				<td class="headertext">Points</td>
				<td class="headertext">Note</td>
				</tr>
				<cfloop query="GetPointHistory">
					<tr class="content">
					<td>#FLGen_DateTimeToDisplay(created_datetime)#</td>
					<td align="right"><cfif thisdef><span class="sub">[defered]</span></cfif><cfif order_number NEQ 000>-</cfif> #thispoints#</td>
					<td><cfif order_number NEQ 000>Order Number: #order_number#<cfelse>#thisnote# <span class="sub">Entered by #FLGen_GetAdminName(created_user_ID)#</span></cfif></td>
					</tr>
				</cfloop>
				<tr class="content">
				<td align="right" class="headertext" colspan="2">#ProgramUserInfo(user_ID)##user_totalpoints#</td>
				<td class="headertext">TOTAL POINTS</td>
				</tr>
				<!--- subprogram point summary --->
				<cfif SelectSubprograms.RecordCount NEQ 0>
					<cfloop query="SelectSubprograms">
						<cfquery name="FindSubprogramPoints" datasource="#application.DS#">
							SELECT IFNULL(SUM(subpoints),0) AS subpoints
							FROM #application.database#.subprogram_points
							WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#"> 
								AND subprogram_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#subprogram_ID#">
						</cfquery>
						<cfquery name="GetSubpointHistory" datasource="#application.DS#">
							SELECT ID AS subpoint_ID, created_datetime, created_user_ID, subpoints 
							FROM #application.database#.subprogram_points
							WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#">
								AND subprogram_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#subprogram_ID#">
							ORDER BY created_datetime
						</cfquery>
						<cfif GetSubpointHistory.RecordCount GT 0>
							<tr bgcolor="##D6EFF7">
							<td colspan="3" class="headertext">#subprogram_name# Points</td>
							</tr>
							<tr class="contenthead">
							<td class="headertext">Date</td>
							<td class="headertext">Points</td>
							<td class="headertext">Note</td>
							</tr>
							<cfloop query="GetSubpointHistory">
								<tr class="content">
								<td>#FLGen_DateTimeToDisplay(created_datetime)#</td>
								<td align="right">#subpoints#</td>
								<td><span class="sub">Entered by #FLGen_GetAdminName(created_user_ID)#</span></td>
								</tr>
							</cfloop>
							<tr class="content">
							<td align="right" class="headertext" colspan="2">#FindSubprogramPoints.subpoints#</td>
							<td class="headertext">TOTAL SUBPOINTS</td>
							</tr>
						</cfif>
					</cfloop>
				</cfif>
			</table>
			</cfoutput>
		</cfif>
	</cfif>
</cfif>
--->


<!--- set this to 'both', 'active' or 'inactive' --->
<cfset show_active = 'active'>
<cfquery name="GetLatestUpdate" datasource="#application.DS#">
	SELECT created_datetime, created_user_ID
	FROM #application.database#.subprogram_points
	WHERE subprogram_ID IN ( SELECT ID FROM #application.database#.subprogram WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">)
	AND subpoints < 0
	ORDER BY created_datetime DESC
	LIMIT 1
</cfquery>
Last Update 
<cfif GetLatestUpdate.recordcount EQ 1>
	<cfoutput>
	by #FLGen_GetAdminName(GetLatestUpdate.created_user_ID)#
	on #DateFormat(GetLatestUpdate.created_datetime,'m/d/yyyy')#
	at #TimeFormat(GetLatestUpdate.created_datetime, "h:mm tt")#.
	(Tracy's last update was 1/10/2015 )
	</cfoutput>
<cfelse>
	<span class="alert">Not Found!</span>
</cfif>
<br><br>


Showing users who are out of balance<br><br>
<!---Get users--->
<cfquery name="getUsers" datasource="#application.DS#">
	SELECT ID, lname, fname, username
	FROM #application.database#.program_user
	WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
	<cfif show_active NEQ 'both'>
		AND is_active = <cfif show_active EQ 'active'>1<cfelse>0</cfif>
	</cfif>
</cfquery>
<cfif getUsers.recordcount EQ 0>
	<cfif show_active EQ 'both'>
		<cfset alert_msg = "There are no users!">
	<cfelse>
		<cfset alert_msg = "There are no #show_active# users!">
	</cfif>
<cfelse>
	<cfloop query="getUsers">
		<cfset user_ID = getUsers.ID>
		<cfset ProgramUserInfo(user_ID)>
		<cfquery name="getSubprogramPoints" datasource="#application.DS#">
			SELECT IFNULL(SUM(subpoints),0) AS total
			FROM #application.database#.subprogram_points
			WHERE user_ID = #user_ID#
		</cfquery>
		<cfif getSubprogramPoints.total NEQ user_totalpoints>
			<cfoutput>#getUsers.fname# #getUsers.lname# (#getUsers.username#) #getUsers.ID#<br></cfoutput>
		</cfif>
	</cfloop>
</cfif>

<cfif alert_msg NEQ "">
	<span class="alert"><cfoutput>#alert_msg#</cfoutput></span>
</cfif>


<br><br>
---eof---
	
	
</body>
</html>