<!---

col_3 - corp ID (alternate email maybe)


col_8 - last name
col_9 - first name

col_13 - email (just the username)

col_30 - total awarded
col_31 - total redeemed
<cfset crlf = "<br><br>">--->
<cfspreadsheet action="read" src="upload/lorillard.xlsx" query="GetAllUsers" rows="502-511" sheet="2" >
<cfloop query="GetAllUsers">
	<cfset this_email = "">
	<cfset this_username1 = GetAllUsers.col_13>
	<cfset this_username2 = GetAllUsers.col_3>
	<cfif GetAllUsers.col_13 NEQ "">
		<cfset this_email = GetAllUsers.col_13 & "@lortobco.com">
	<cfelseif GetAllUsers.col_3 NEQ "">
		<cfset this_email = GetAllUsers.col_3 & "@lortobco.com">
	</cfif>
	<cfset found_one = false>
	<cfif this_email NEQ "">
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.username, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
				SUM(p.points) AS points_awarded, u.is_active
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = 1000000035
			AND u.email = '#this_email#'
			GROUP BY u.ID
		</cfquery>
		<cfif GetUser.RecordCount EQ 1>
			<cfset found_one = true>
		</cfif>
	</cfif>
	<cfif NOT found_one>
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.username, u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
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
		</cfif>
	</cfif>
	<cfif found_one>
		<cfoutput>
		username = #GetUser.username#<br>
		points = #GetAllUsers.col_30#,,#GetAllUsers.col_31#,#crlf#</cfoutput>
		<cfif GetUser.is_active EQ 1 AND GetUser.email EQ this_email >
		<cfelse>
		</cfif>
		</cfoutput>
	</cfif>
</cfloop>
