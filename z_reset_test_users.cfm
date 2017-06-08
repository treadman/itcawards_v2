<cfinclude template="includes/function_library_itcawards.cfm">
<cfparam name="message" default="">
<cfif IsDefined('form.Submit')>
	<cfquery name="InsertPoints1" datasource="#application.DS#">
		INSERT INTO #application.database#.awards_points
			(created_user_ID, created_datetime, user_ID, points, notes)
		VALUES
			('z_reset_test_users.cfm', '#FLGen_DateTimeToMySQL()#', '1000000010', '300', 'Added using z_reset_test_users.cfm')
	</cfquery>
	<cfquery name="InsertPoints2" datasource="#application.DS#">
		INSERT INTO #application.database#.awards_points
			(created_user_ID, created_datetime, user_ID, points, notes)
		VALUES
			('z_reset_test_users.cfm', '#FLGen_DateTimeToMySQL()#', '1000000011', '300', 'Added using z_reset_test_users.cfm')
	</cfquery>
	<cfquery name="InsertPoints3" datasource="#application.DS#">
		INSERT INTO #application.database#.awards_points
			(created_user_ID, created_datetime, user_ID, points, notes)
		VALUES
			('z_reset_test_users.cfm', '#FLGen_DateTimeToMySQL()#', '1000000012', '300', 'Added using z_reset_test_users.cfm')
	</cfquery>
	<cfquery name="InsertPoints4" datasource="#application.DS#">
		INSERT INTO #application.database#.awards_points
			(created_user_ID, created_datetime, user_ID, points, notes)
		VALUES
			('z_reset_test_users.cfm', '#FLGen_DateTimeToMySQL()#', '1000000013', '300', 'Added using z_reset_test_users.cfm')
	</cfquery>
	<cfquery name="InsertPoints5" datasource="#application.DS#">
		INSERT INTO #application.database#.awards_points
			(created_user_ID, created_datetime, user_ID, points, notes)
		VALUES
			('z_reset_test_users.cfm', '#FLGen_DateTimeToMySQL()#', '1000000014', '300', 'Added using z_reset_test_users.cfm')
	</cfquery>
	<cfset message = "* * * * *  Thank you!  The points were added * * * * *">
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="shortcut icon" href="/favicon.ico" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>add 300 points to test users</title>
</head>
<body>
<form method="post" action="z_reset_test_users.cfm">
	<input type="submit" name="submit" value="Add 300 Points to each test user">
</form>
<cfoutput>
#message#<br><br>
<b>testing1</b> has #ProgramUserInfo(1000000008)#<b>#user_totalpoints#</b> points
<br><br>
<b>testing2</b> has #ProgramUserInfo(1000000007)#<b>#user_totalpoints#</b> points
<br><br>
<b>testing3</b> has #ProgramUserInfo(1000000006)#<b>#user_totalpoints#</b> points
<br><br>
<b>testing4</b> has #ProgramUserInfo(1000000005)#<b>#user_totalpoints#</b> points
<br><br>
<b>testing5</b> has #ProgramUserInfo(1000000004)#<b>#user_totalpoints#</b> points
<br><br>
</cfoutput>
</body>
</html>