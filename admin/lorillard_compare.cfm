<cfsetting enablecfoutputonly="true" requesttimeout="600">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<cfheader name="Content-Disposition" value="filename=lorillard.csv">
<cfcontent type="application/msexcel" />
<cfset multiplier = 200>
<cfset crlf = CHR(13)&CHR(10)>
<cfspreadsheet action="read" src="../upload/lorillard.xlsx" query="GetAllUsers" rows="502-922" sheet="2" >
<cfoutput>Exceptions,In System,Email Address,,Driver Name,,Points Awarded,,Points Redeemed,#crlf#</cfoutput>
<cfoutput>,,Spreadsheet,System,Spreadsheet,System,Spreadsheet,System,Spreadsheet,System#crlf#</cfoutput>
<cfloop query="GetAllUsers">
	<cfset tick2 = GetTickCount()>
	<cfset this_email = "">
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
		</cfif>
	</cfif>
	<cfset that_awarded = GetAllUsers.col_27 + GetAllUsers.col_28>
	<cfif NOT found_one>
		<cfoutput>Not Found,No,#this_email#,,#GetAllUsers.col_9# #GetAllUsers.col_8#,,#that_awarded#,,#ABS(GetAllUsers.col_31)#,#crlf#</cfoutput>
	<cfelse>
		<cfquery name="GetOrders" datasource="#application.DS#">
			SELECT SUM(points_used) AS points_redeemed
			FROM ITCAwards.order_info
			WHERE is_valid=1
			AND created_user_ID = #GetUser.ID#
		</cfquery>
		<cfset this_awarded = 0>
		<cftry>
			<cfset this_awarded = GetUser.points_awarded * multiplier>
			<cfcatch></cfcatch>
		</cftry>
		<cfset this_redeemed = 0>
		<cftry>
			<cfset this_redeemed = GetOrders.points_redeemed * multiplier>
			<cfcatch></cfcatch>
		</cftry>
		<cfset this_active = "Yes">
		<cfif GetUser.is_active EQ 0>
			<cfset this_active = "Not Active">
		</cfif>
		<cfset this_exception = "">
		<cfif GetUser.email NEQ this_email>
			<cfset this_exception = ListAppend(this_exception,"Email","-")>
		</cfif>
		<cfif this_awarded NEQ that_awarded>
			<cfset this_exception = ListAppend(this_exception,"Awarded","-")>
		</cfif>
		<cfif this_redeemed NEQ ABS(GetAllUsers.col_31)>
			<cfset this_exception = ListAppend(this_exception,"Redeemed","-")>
		</cfif>
		<cfif GetUser.fname&GetUser.lname NEQ GetAllUsers.col_9&GetAllUsers.col_8>
			<cfset this_exception = ListAppend(this_exception,"Name","-")>
		</cfif>
		<cfoutput>#this_exception#,#this_active#,#this_email#,#GetUser.email#,#GetAllUsers.col_9# #GetAllUsers.col_8#,#GetUser.fname# #GetUser.lname#,#that_awarded#,#this_awarded#,#ABS(GetAllUsers.col_31)#,#this_redeemed##crlf#</cfoutput>
	</cfif>
</cfloop>
