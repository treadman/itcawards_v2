<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<!--- form fields --->
<cfparam name="username" default="">
<cfparam name="password" default="">

<!--- variables --->
<cfparam name="HashedProgramID" default="">
<cfparam name="alert_msg" default="">
<cfparam name="login_msg" default="">

<cfparam name="program_ID" default="">
<cfparam name="program" default="">
<cfparam name="user_ID" default="">
<cfparam name="is_done" default="false">
<cfparam name="defer_allowed" default="0">
<cfparam name="cc_max" default="0">
<cfparam name="CheckProgUserLogin_RecordCount" default="0">
			
<cfparam name="url.p" default="">
<cfparam name="form.email" default="">

<cfset showPWRecoverLink = false>
<cfset showPWRecoverForm = false>

<cfset checkV3Site = false>

<cfset gotoTerms = 0>

<cfif url.p NEQ "">
	<!--- is the url.p valid ? --->
	<cfquery name="CheckUsername" datasource="#application.DS#">
		SELECT p.ID, p.has_password_recovery, p.orders_from, pl.username
		FROM #application.database#.program_login pl
		JOIN #application.database#.program p ON pl.program_ID = p.ID
		WHERE 	pl.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.p#" maxlength="32">
				AND p.is_active = 1 
				AND p.expiration_date >= CURDATE()
	</cfquery>
	<cfif CheckUsername.RecordCount GT 0 AND CheckUsername.has_password_recovery>
		<cfset showPWRecoverForm = true>
	<cfelse>
		<cfset url.p = "">
	</cfif>
</cfif>

<cfif url.p NEQ "" AND form.email NEQ "">
	<br><br>
	<cfquery name="CheckProgramUser" datasource="#application.DS#">
		SELECT fname, lname, username
		FROM #application.database#.program_user
		WHERE email = <cfqueryparam value="#form.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">
		AND program_ID = <cfqueryparam value="#CheckUserName.ID#" cfsqltype="cf_sql_integer">
		AND registration_type <> 'BranchHQ'
	</cfquery>
	<cfif CheckProgramUser.RecordCount EQ 0>
		<cfset alert_msg = 'The email address, <strong>#form.email#</strong>,<br /> was not found in the <strong>#url.p#</strong> program.'>
	<cfelseif CheckProgramUser.RecordCount GT 1>
		<cfmail to="#Application.ErrorEmailTo#" from="#emailFrom#" subject="#emailSubject#" type="html">
#form.email# is duplicated in ITCAwards.Program_User.<br>
WHERE Program ID EQ #CheckUserName.ID#<br>
AND registration_type <> 'BranchHQ'<br>
This is in index.cfm (login)
		</cfmail>
		<cfset alert_msg = 'There was a problem with that email address.  Please call toll-free 1.800.915.5999 or email #application.AwardsProgramAdminName#, at #application.AwardsProgramAdminEmail#.'>
	<cfelse>
		<!--- Send Email --->
		<cfset emailFrom = CheckUsername.orders_from>
		<cfset emailSubject = CheckUserName.username & " password">
		<cfmail to="#form.email#" failto="#Application.ErrorEmailTo#" from="#emailFrom#" subject="#emailSubject#" type="html">
Dear #CheckProgramUser.fname#,<br><br>
Below is your password and log-in instructions to enter the Henkel Rewards Board:<br><br><br>
<ul>
	<li> Go to www2.itcawards.com</li>
	<li> Enter Company Name: <strong># CheckUserName.username#</strong></li>
	<li> Enter Password: <strong>#CheckProgramUser.username#</strong></li>
</ul>
<br>
Should you need further assistance, please call toll-free 1.800.915.5999 or email #application.AwardsProgramAdminName#, Henkel Rewards Administrator, at #application.AwardsProgramAdminEmail#.  Thank you.
		</cfmail>
		<cfset login_msg = 'We have sent your password to <strong>#form.email#</strong><br><br>Thank you!'>
		<cfset showPWRecoverForm = false>
		<cfset url.p = "">
	</cfif>
</cfif>


<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->
 
<cfif IsDefined('username') AND Trim(username) IS NOT "" AND IsDefined('password') AND Trim(password) IS NOT "">

	<cfset username = Left(Trim(username),32)>
	<cfset password = Left(Trim(password),128)>
	
	<!--- is the username valid ? --->
	<cfquery name="CheckUsername" datasource="#application.DS#">
		SELECT p.ID, p.has_password_recovery
		FROM #application.database#.program_login pl
		JOIN #application.database#.program p ON pl.program_ID = p.ID
		WHERE 	pl.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#username#" maxlength="32">
				AND p.is_active = 1 
				AND p.expiration_date >= CURDATE()
	</cfquery>
	
	<cfif CheckUsername.RecordCount EQ 0>
		<cfset checkV3Site = true>
		<cfset alert_msg = "Please enter a valid company name.">
	<cfelse>
	
		<!--- check the database for the username/password match --->
		<cfquery name="CheckLogin" datasource="#application.DS#">
			SELECT pl.program_ID, p.company_name
			FROM #application.database#.program_login pl
			JOIN #application.database#.program p ON pl.program_ID = p.ID
			WHERE 	pl.password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#password#" maxlength="128"> 
					AND pl.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#username#" maxlength="32">
					AND p.is_active = 1 
					AND p.expiration_date >= CURDATE()
		</cfquery>
		<cfset program_ID = CheckLogin.program_ID>
		<cfset company_name = HTMLEditFormat(CheckLogin.company_name)>
		
		<!--- if no match, try the program username and one of it's user's usernames --->
		<cfif CheckLogin.RecordCount EQ 0>
			<cfquery name="CheckProgUserLogin" datasource="#application.DS#">
				SELECT DISTINCT up.ID AS user_ID, IF(up.is_done=1,"true","false") AS is_done, up.defer_allowed, up.cc_max, pl.program_ID, p.company_name
				FROM #application.database#.program_user up
					JOIN #application.database#.program p ON up.program_ID = p.ID
					JOIN #application.database#.program_login pl ON pl.program_ID = p.ID
				WHERE up.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#password#" maxlength="128">
					AND pl.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#username#" maxlength="32">
					AND p.is_active = 1
					AND up.is_active = 1
					AND p.expiration_date >= CURDATE()
					AND (up.expiration_date >= CURDATE() OR up.expiration_date IS NULL)
			</cfquery>
			<cfset program_ID = CheckProgUserLogin.program_ID>
			<cfset company_name = HTMLEditFormat(CheckProgUserLogin.company_name)>
			<cfset user_ID = CheckProgUserLogin.user_ID>
			<cfset is_done = HTMLEditFormat(CheckProgUserLogin.is_done)>
			<cfset defer_allowed = HTMLEditFormat(CheckProgUserLogin.defer_allowed)>
			<cfset cc_max = HTMLEditFormat(CheckProgUserLogin.cc_max)>
			<cfset CheckProgUserLogin_RecordCount = CheckProgUserLogin.RecordCount>
			<cfif CheckProgUserLogin.RecordCount EQ 0>
				<cfquery name="CheckNewUserLogin" datasource="#application.DS#">
					SELECT DISTINCT up.ID AS user_ID, IF(up.is_done=1,"true","false") AS is_done, up.defer_allowed, up.cc_max, pl.program_ID, p.company_name
					FROM #application.database#.program_user up
						JOIN #application.database#.program p ON up.program_ID = p.ID
						JOIN #application.database#.program_login pl ON pl.program_ID = p.ID
					WHERE up.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#password#" maxlength="128">
						AND pl.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#username#" maxlength="32">
						AND p.is_active = 1
						AND up.created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="1000000000">
						AND up.is_active = 0
						AND p.expiration_date >= CURDATE()
						AND (up.expiration_date >= CURDATE() OR up.expiration_date IS NULL)
				</cfquery>
				<cfset program_ID = CheckNewUserLogin.program_ID>
				<cfset company_name = HTMLEditFormat(CheckNewUserLogin.company_name)>
				<cfset user_ID = CheckNewUserLogin.user_ID>
				<cfset is_done = HTMLEditFormat(CheckNewUserLogin.is_done)>
				<cfset defer_allowed = HTMLEditFormat(CheckNewUserLogin.defer_allowed)>
				<cfset cc_max = HTMLEditFormat(CheckNewUserLogin.cc_max)>
				<cfif CheckNewUserLogin.recordcount GT 0>
					<cfset gotoTerms = CheckNewUserLogin.user_ID>
				</cfif>
			</cfif>
		</cfif>
	
		<cfif CheckLogin.RecordCount EQ 0 AND CheckProgUserLogin_RecordCount EQ 0 AND CheckNewUserLogin.recordcount EQ 0>
			<cfset alert_msg = "Please enter a valid password.">
			<cfif CheckUsername.has_password_recovery>
				<cfset showPWRecoverLink = true>
			</cfif>
		<cfelseif is_done>
			<cfset alert_msg = "You have already selected your gift.">
		<cfelseif CheckProgUserLogin_RecordCount GT 1>
			<cfset alert_msg = "There is more that one user in the system with that login.  Please call toll-free 1.800.915.5999 or email #application.AwardsProgramAdminName#, at #application.AwardsProgramAdminEmail#.">
		<cfelseif gotoTerms EQ 0>
		
			<!--- SET USER INFO --->
			<!--- if it was an upfront authorization login, set all the user stuff --->
			<cfif CheckProgUserLogin_RecordCount EQ 1>
				<!--- get user info and write program user cookie --->
				<cfset ProgramUserInfo(user_ID, true)>
			</cfif>
			
			<!--- SET PROGRAM INFO --->
			<!--- hash program ID and save cookie --->
			<cfset HashedProgramID = #FLGen_CreateHash(program_ID)#>
			<cfcookie name="itc_pid" value="#program_ID#-#HashedProgramID#">

			<cfquery name="GetProgram" datasource="#application.DS#">
				SELECT IF(has_welcomepage=1,"true","false") AS has_welcomepage
				FROM #application.database#.program
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
			</cfquery>
			<cfif GetProgram.has_welcomepage>
				<cflocation addtoken="no" url="welcome.cfm">
			<cfelse>
				<cflocation addtoken="no" url="main.cfm">
			</cfif>
			
		</cfif>

	</cfif>
	<cfif gotoTerms GT 0>
		<cflocation addtoken="no" url="terms.cfm?id=#gotoTerms#">
	</cfif>
	<cfif alert_msg GT "" AND IsDefined("source") AND source IS "henkel">
		<cflocation addtoken="no" url="#application.HenkelURL#/index1.html">
	</cfif>
	<cfif checkV3Site>
		<cfquery name="CheckV3Username" datasource="#application.DS#">
			SELECT p.ID
			FROM #application.v3_database#.program_login pl JOIN #application.v3_database#.program p ON pl.program_ID = p.ID
			WHERE 	pl.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#username#" maxlength="32">
					AND p.is_active = 1 
					AND p.expiration_date >= CURDATE()
		</cfquery>
		<cfif CheckV3Username.recordcount GT 0>
			<cflocation url="http://www3.itcawards.com/?username=#username#&password=#password#" addtoken="no">
		</cfif>
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="shortcut icon" href="/favicon.ico" />
<title>ITC Awards</title>

<STYLE TYPE="text/css">
td, body, .reg, button, input, select, option, textarea {font-family:Verdana, Arial, Helvetica, san-serif; font-size:8pt; color:black}
.action {border-width:2px;border-color:#ff6600;background-color:#ff6600;color:#ffffff;font-weight:bold;padding:3px;cursor:pointer}
.alert {color:#cb0400}
.login_msg {font-weight:bold;color:#969696}
.login_msg a {font-weight:bold;color:#969696}
.welcome {font-family:Arial, Verdana;font-weight:bold;font-size:8pt;color:#969696}

</STYLE>

</head>

<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" background="pics/login/bkgd-fade.jpg">
<cfinclude template="includes/environment.cfm"> 

<div align="center">
	
<cfoutput>
<form method="post" action="#application.SecureWebPath#/index.cfm<cfif Len(url.p) GT 0>?p=#url.p#</cfif>">

	<table cellpadding="5" cellspacing="0" border="0">
	
	<tr>
	<td colspan="3" align="center"><img src="pics/login/header-awards.jpg" width="392" height="178"></td>
	</tr>
	
	<tr>
	<td colspan="3" align="center">&nbsp;</td>
	</tr>
	
	<tr>
	<td colspan="3" align="center">
		<cfif alert_msg NEQ "">
			<span class="alert">#alert_msg#</span>
			<br /><br /><br />
		</cfif>
		<cfif login_msg NEQ "">
			<span class="login_msg">#login_msg#</span>
			<br /><br /><br />
		</cfif>
	</td>
	</tr>
	
	<cfif showPWRecoverForm>
		<input type="hidden" name="get_password" value="1">
		<tr>
			<td width="187"><img src="pics/shim.gif" width="187" height="5"></td>
			<td width="425" height="101" align="center">
				<br>
				<span class="welcome">Please enter your email address.<br>Your password will be emailed to you.</span>
				<br>
				<br>
				<table border="0" align="center">
					<tr><td align="right" class="welcome">Email Address </td><td><input type="text" name="email" size="30" maxlength="128" value="#form.email#"></td></tr>
					<tr><td colspan="2" align="center"><br><br><input name="submit" type="image" value="submit" src="pics/login/submitbutton_01.gif" border="0"></td></tr>
				</table>

			</td>
			<td width="188" valign="top" align="center">&nbsp;</td>
		</tr>
		<tr>
		<td colspan="3" align="center">
			<br><br>
			<span class="login_msg"><a href="index.cfm">Return to the login screen</a></span>
		</td>
		</tr>
	<cfelse>
		<tr>
		<td align="center"><img src="pics/login/entercompanyname.jpg" width="174" height="21" border="0"></td>
		<td width="8"></td>
		<td align="center"><img src="pics/login/enterpassword.jpg" width="174" height="21" border="0"></td>
		</tr>

		<tr>
		<td align="center"><input type="text" name="username" value="#username#" size="27" maxlength="32"></td>
		<td width="8"></td>
		<td align="center"><input type="password" name="password" size="27" maxlength="128"></td>
		</tr>
		
		<tr>
		<td colspan="3" align="center">&nbsp;</td>
		</tr>
		
		<tr>
		<td colspan="3" align="center">
		<cfif showPWRecoverLink>
			<span class="login_msg"><a href="index.cfm?p=#urlencodedformat(username)#">Already Registered&nbsp; &mdash; &nbsp;Forgot Your Password?</a></span>
			<br /><br /><br />
		</cfif>
		<input type="hidden" name="password_required" value="You must enter a password">
		<input type="hidden" name="username_required" value="You must enter company name">
		
		<input src="pics/login/submitbutton_01.gif" type="image" name="submit" >
		</td>
		</tr>
	</cfif>
	<tr>
	<td colspan="3" align="center">&nbsp;</td>
	</tr>
	
	<tr>
	<td colspan="3" align="center"><a href="http://www.itcawards.com/index.html"><img src="pics/login/SafetySpecialtyLink-2lines_.gif" width="260" height="23" border="0"></a>
	<br>
	<a href="http://www.itcawards.com/pages/contactus.html"><img src="pics/login/SafetySpecialtyLink-2lin-02.gif" width="260" height="23" border="0"></td>
	</tr>
	
	
	</table>

</form>
</cfoutput>
</div>

</body>
</html>
