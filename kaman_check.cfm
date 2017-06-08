<cfsetting showdebugoutput="no">
<cfif REMOTE_ADDR NEQ "63.68.13.229x">

<cfquery name="getNames" datasource="#application.DS#">
	SELECT lastname,firstname
	FROM #application.database#.TEMP_Names
	ORDER BY lastname,firstname
</cfquery>
<cfquery name="getUsers" datasource="#application.DS#">
	SELECT ID, username, lname, fname
	FROM #application.database#.program_user
	WHERE program_ID = 1000000010
	ORDER BY lname,fname
</cfquery>
<cfquery name="getSubprograms" datasource="#application.DS#">
	SELECT ID, subprogram_name
	FROM #application.database#.subprogram
	WHERE program_ID = 1000000010
	ORDER BY sortorder
</cfquery>
<cfset grandTotal = 0>
Program users not found in spreadsheet:<br><br>
<table border="1">
<cfloop query="getUsers">
	<cfset thisID = getUsers.ID>
	<cfset thisUser = getUsers.username>
	<cfset thisFirst = getUsers.fname>
	<cfset thisLast = getUsers.lname>
	<cfquery name="getName1" datasource="#application.DS#">
		SELECT lastname,firstname
		FROM #application.database#.TEMP_Names
		WHERE lastname = '#thisLast#'
		AND firstname = '#thisFirst#'
	</cfquery>
	<cfif getName1.recordcount EQ 0>
		<cfoutput>
		<tr><td valign="top">#thisUser#</td><td valign="top">#thisLast#, #thisFirst#</td>
		<cfquery name="getName2" datasource="#application.DS#">
			SELECT lastname,firstname
			FROM #application.database#.TEMP_Names
			WHERE lastname = '#thisLast#'
		</cfquery>
		<td valign="top">
			<cfif getName2.recordcount GT 0>
				Possibly:<br />
				<cfloop query="getName2">
					#getName2.lastname#, #getName2.firstname#<br />
				</cfloop>
			<cfelse>
				&nbsp;
			</cfif>
		</td>
		<td valign="top">
			<cfquery name="getPos" datasource="#application.DS#">
				SELECT IFNULL(SUM(points),0) AS pos_pt
				FROM #application.database#.awards_points
				WHERE user_ID = #thisID#
			</cfquery>
			<cfquery name="getNeg" datasource="#application.DS#">
				SELECT IFNULL(SUM((points_used * credit_multiplier)/points_multiplier),0) AS neg_pt
				FROM #application.database#.order_info
				WHERE created_user_ID = #thisID#
			</cfquery>
			<cfset TotalPoints = getPos.pos_pt - getNeg.neg_pt>
			Total Points: #TotalPoints#<br />
			<cfset grandTotal = grandTotal + TotalPoints>
			<cfloop query="getSubPrograms">
				<cfset thisSubID = getSubPrograms.ID>
				<cfset thisSubName = getSubPrograms.subprogram_name>
				<cfquery name="getSubPoints" datasource="#application.DS#">
					SELECT IFNULL(SUM(subpoints),0) AS subpoints
					FROM #application.database#.subprogram_points
					WHERE user_ID = #thisID#
					AND subprogram_ID = #thisSubID#
				</cfquery>
				<cfif getSubPoints.subpoints GT 0>
					#thisSubName# - #getSubPoints.subpoints#<br />
				</cfif>
			</cfloop>
		</td>
		</tr>
		</cfoutput>
	</cfif>
</cfloop>
<tr><td colspan="3" align="right">Total : </td><td><cfoutput>#grandTotal#</cfoutput></td></tr>
</table>



<cfelse>
<cfloop list="a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z" index="init">
<cfquery name="getNames" datasource="#application.DS#">
	SELECT lastname,firstname
	FROM #application.database#.TEMP_Names
	WHERE lastname LIKE '#init#%'
	ORDER BY lastname,firstname
</cfquery>
<cfquery name="getUsers" datasource="#application.DS#">
	SELECT ID, username, lname, fname
	FROM #application.database#.program_user
	WHERE program_ID = 1000000010
	AND lname LIKE '#init#%'
	ORDER BY lname,fname
</cfquery>
<table border="1" width="600px;"><tr><td valign="top" width="50%">
Program users not found in spreadsheet:<br><br>
<cfloop query="getUsers">
	<cfset thisID = getUsers.ID>
	<cfset thisUser = getUsers.username>
	<cfset thisFirst = getUsers.fname>
	<cfset thisLast = getUsers.lname>
	<cfquery name="getName" datasource="#application.DS#">
		SELECT lastname,firstname
		FROM #application.database#.TEMP_Names
		WHERE lastname = '#thisLast#'
		AND firstname = '#thisFirst#'
	</cfquery>
	<cfif getName.recordcount EQ 0>
		<cfoutput>#thisLast#, #thisFirst#</cfoutput><br>
	</cfif>
</cfloop>
</td><td valign="top" width="50%">
Kaman employees not found in program:<br><br>
<cfloop query="getNames">
	<cfset thisFirst = getNames.firstname>
	<cfset thisLast = getNames.lastname>
	<cfquery name="getUser" datasource="#application.DS#">
		SELECT ID, username,lname,fname
		FROM #application.database#.program_user
		WHERE lname = '#thisLast#'
		AND fname = '#thisFirst#'
		AND program_ID = 1000000010
	</cfquery>
	<cfif getUser.recordcount EQ 0>
		<cfoutput>#thisLast#, #thisFirst#</cfoutput><br>
	</cfif>
</cfloop>
</td></tr></table>
</cfloop>
<cfloop list="a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z" index="init">
<cfquery name="getNames" datasource="#application.DS#">
	SELECT lastname,firstname
	FROM #application.database#.TEMP_Names
	WHERE lastname LIKE '#init#%'
	ORDER BY lastname,firstname
</cfquery>
<cfquery name="getUsers" datasource="#application.DS#">
	SELECT ID, username, lname, fname
	FROM #application.database#.program_user
	WHERE program_ID = 1000000010
	AND lname LIKE '#init#%'
	ORDER BY lname,fname
</cfquery>
<table border="1" width="600px;"><tr><td valign="top" width="50%">
Program users found more than once in spreadsheet:<br><br>
<cfloop query="getUsers">
	<cfset thisID = getUsers.ID>
	<cfset thisUser = getUsers.username>
	<cfset thisFirst = getUsers.fname>
	<cfset thisLast = getUsers.lname>
	<cfquery name="getName" datasource="#application.DS#">
		SELECT lastname,firstname
		FROM #application.database#.TEMP_Names
		WHERE lastname = '#thisLast#'
		AND firstname = '#thisFirst#'
	</cfquery>
	<cfif getName.recordcount GT 1>
		<cfoutput>#thisLast#, #thisFirst#</cfoutput><br>
		<font color="red">
		<cfoutput query="getName">
			&nbsp;&nbsp;&nbsp;#getName.lastname#, #getName.firstname#<br>
		</cfoutput>
		</font>
	</cfif>
</cfloop>
</td><td valign="top" width="50%">
Kaman employees found more than once in the awards program:<br><br>
<cfloop query="getNames">
	<cfset thisFirst = getNames.firstname>
	<cfset thisLast = getNames.lastname>
	<cfquery name="getUser" datasource="#application.DS#">
		SELECT ID, username,lname,fname
		FROM #application.database#.program_user
		WHERE lname = '#thisLast#'
		AND fname = '#thisFirst#'
		AND program_ID = 1000000010
	</cfquery>
	<cfif getUser.recordcount GT 1>
		<cfoutput>#thisLast#, #thisFirst#</cfoutput><br>
		<font color="red">
		<cfoutput query="getUser">
			&nbsp;&nbsp;&nbsp;#getUser.username# - #getUser.lname#, #getUser.fname#<br>
		</cfoutput>
		</font>
	</cfif>
</cfloop>
</td></tr></table>
</cfloop>
</cfif>
