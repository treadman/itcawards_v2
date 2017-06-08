<cfsetting enablecfoutputonly="true" requesttimeout="600">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<cfheader name="Content-Disposition" value="filename=lorillard.csv">
<cfcontent type="application/msexcel" />

<!---
col_3 - corp ID (alternate email maybe)


col_8 - last name
col_9 - first name

col_13 - email (just the username)

col_30 - total awarded
col_31 - total redeemed

502 to 922
<cfset tick1 = GetTickCount()> 
<cfset tick2 = GetTickCount()> 
<cfoutput>#tick2-tick1#<br><br></cfoutput>
	<cfset tick3 = GetTickCount()> 
	<cfoutput>#tick3-tick2#<br><br></cfoutput>

<br>
Done!
--->
<cfset crlf = CHR(13)&CHR(10)>
<!---<cfset crlf = "<br><br>">--->
<cfspreadsheet action="read" src="upload/lorillard.xlsx" query="GetAllUsers" rows="502-511" sheet="2" >
<cfoutput>Exceptions,In System,Email Address,,Driver Name,,Points Awarded,,Points Redeemed,#crlf#</cfoutput>
<cfoutput>,,Spreadsheet,System,Spreadsheet,System,Spreadsheet,System,Spreadsheet,System#crlf#</cfoutput>
<cfloop query="GetAllUsers">
	<cfset tick2 = GetTickCount()>
	<cfset this_email = "">
	<cfif GetAllUsers.col_13 NEQ "">
		<cfset this_email = GetAllUsers.col_13 & "@lortobco.com">
	<cfelseif GetAllUsers.col_3 NEQ "">
		<cfset this_email = GetAllUsers.col_3 & "@lortobco.com">
	</cfif>
	<cfset found_one = false>
	<cfif this_email NEQ "">
		<cfquery name="GetUser" datasource="#application.DS#">
			SELECT u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
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
			SELECT u.lname, u.fname, u.email, DATE_FORMAT(u.created_datetime,'%m/%d/%Y') AS registered,
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
	<cfif NOT found_one>
		<cfoutput>Not Found,No,#this_email#,,#GetAllUsers.col_9# #GetAllUsers.col_8#,,#GetAllUsers.col_30#,,#GetAllUsers.col_31#,#crlf#</cfoutput>
	<cfelse>
		<cfset this_active = "Yes">
		<cfif GetUser.is_active EQ 0>
			<cfset this_active = "Not Active">
		</cfif>
		<cfset this_exception = "">
		<cfif GetUser.email NEQ this_email>
			<cfset this_exception = ListAppend(this_exception,"Email")>
		</cfif>
		<cfoutput>#this_exception#,#this_active#,#this_email#,#GetUser.email#,#GetAllUsers.col_9# #GetAllUsers.col_8#,#GetUser.fname# #GetUser.lname#,#GetAllUsers.col_30#,,#GetAllUsers.col_31#,#crlf#</cfoutput>
	</cfif>
</cfloop>
