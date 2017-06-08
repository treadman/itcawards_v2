<!---	This adds people to the 'henkel_register' table with a status.
		If everything is OK, they will be added to the program_user table and get 10 points in the awards_points table.

		Status Codes:
		
			0 - Everything is fine.  Region was found.  Distributor was found.  Points Awarded.  Yada yada yada.
			1 - Could not find region by zip code in 'xref_zipcode_region', but found in distributor.
			2 - Could not find distributor by company name in 'henkel_distributor', but found in region.
			3 - Could not find in either place.

			Add 10 to the status if they are entering the email address again.

		If email address is already in the register table, they will not get an "already registered" message.
--->

<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">

<cfparam name="pgfn" default="input">
<cfparam name="email" default="">
<cfparam name="password" default="">
<cfparam name="confirmpassword" default="">
<cfparam name="first_name" default="">
<cfparam name="last_name" default="">
<cfparam name="phone" default="">
<cfparam name="branch_name" default="">
<cfparam name="branch_address" default="">
<cfparam name="branch_city" default="">
<cfparam name="branch_state" default="">
<cfparam name="branch_zip" default="">
<cfparam name="branch_country" default="">
<cfparam name="CONFIRM" default=0>

<!--- Static variables --->
<cfset created_user_ID = 1000000066>
<cfset program_ID = 1000000066>
<cfset Points = 10>
<cfset Notes = "Automatic awards from Henkel registration form">

<cfset ErrorMessage = "">

<cfif pgfn IS 'verify'>
	<cfif email IS "" OR NOT FLGen_IsValidEmail(form.email)><cfset ErrorMessage = ErrorMessage & 'Please enter a valid email address<br />'></cfif>
	<cfif password IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter a password<br />'></cfif>
	<cfif LEN(password) LT 8><cfset ErrorMessage = ErrorMessage & 'Your password must be at least 8 characters in length<br />'></cfif>
	<cfif confirmpassword IS ""><cfset ErrorMessage = ErrorMessage & 'Please confirm your password<br />'></cfif>
	<cfif password NEQ confirmpassword><cfset ErrorMessage = ErrorMessage & 'Your passwords do not match<br />'></cfif>
	<cfif first_name IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your first name<br />'></cfif>
	<cfif last_name IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your last name<br />'></cfif>
	<cfif phone IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your phone number<br />'></cfif>
	<cfif branch_name IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch name<br />'></cfif>
	<cfif branch_address IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch address<br />'></cfif>
	<cfif branch_country IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch country<br />'></cfif>
	<cfif CONFIRM IS 0><cfset ErrorMessage = ErrorMessage & 'Please confirm that you agree to the terms and conditions<br />'></cfif>
	<cfif ErrorMessage GT "">
		<cfset pgfn = 'input'>
	</cfif>
</cfif>

<!doctype html public "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<link rel="shortcut icon" href="/favicon.ico" />
<title>Henkel Loctite</title>
<style type="text/css"> 
td, body, .reg, button, input, select, option, textarea {font-family:Verdana, Arial, Helvetica, sans-serif; font-size:8pt; color:#000000; font-weight:normal}
.welcome {font-family:Arial, Verdana;font-weight:bold;font-size:8pt}
</style>
</head>
<body background="pics/program/henkel/register/LoginPageTile.jpg">
	<cfinclude template="includes/environment.cfm"> 

<font face="Arial, Helvetica, sans-serif">
	<table cellpadding="0" cellspacing="0" border="0" width="800">
		<tr>
			<td width="187"><img src="pics/shim.gif" width="187" height="5"></td>
			<td width="425" height="168" valign="bottom"><img src="pics/program/henkel/register/148x425RewardsBoard.jpg" width="425" height="148" lt="Henkel Rewards Board" border="0"></td>
			<td width="188" valign="top" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td width="187"><img src="pics/shim.gif" width="187" height="5"></td>
			<td width="425" height="101">
				<table border="0" width="425" cellpadding="0" cellspacing="0">
					<tr>
						<td width="6" valign="top"><img src="pics/program/henkel/register/HenkelBoardLegs.jpg" width="6" height="220" alt="" border="0"></td>
						<td width="413" valign="top" align="center">
<cfif pgfn IS 'verify'>
	<cflock name="program_userLock" timeout="60">
		<br><br>
		<cfquery name="CheckProgramUser" datasource="#application.DS#">
			SELECT ID 
			FROM #application.database#.program_user
			WHERE username = <cfqueryparam value="#form.password#" cfsqltype="CF_SQL_VARCHAR" maxlength="16">
			AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
		</cfquery>
		<cfquery name="CheckForRegister" datasource="#application.DS#">
			SELECT ID 
			FROM #application.database#.henkel_register
			WHERE username = <cfqueryparam value="#form.password#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">
			AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
		</cfquery>
		<cfif CheckProgramUser.RecordCount IS 0 AND CheckForRegister.recordcount IS 0>
			<!--- Set status to zero --->
			<cfset status = 0>
			<!--- Check for email in register table --->
			<cfquery name="CheckForRecord" datasource="#application.DS#">
				SELECT ID 
				FROM #application.database#.henkel_register
				WHERE email = <cfqueryparam value="#form.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">
				AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
			</cfquery>
			<cfif CheckForRecord.recordcount GT 0>
				<cfset status = status + 10>
			</cfif>
			<cfquery name="AddRegistration" datasource="#application.DS#">
				INSERT INTO #application.database#.henkel_register (
					created_user_ID, created_datetime, email, username, fname, lname, phone, company,
					address1, city, state, zip, country, region, program_ID, program_user_ID, status)
				VALUES (
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
					'#FLGen_DateTimeToMySQL()#',
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.password#" maxlength="16">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.first_name#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.last_name#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.phone#" maxlength="35">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisDistributor#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address#" maxlength="64">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state#" maxlength="2">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_country#" maxlength="32">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisRegion#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#programUserID#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#status#" maxlength="10">)
			</cfquery>
			<cfif status EQ 0>
				Thank you for registering for Henkel Loctite Rewards.<br>
				You have been awarded 10 Loctite Credits.<br>
				Please click the Home button to view the Henkel Loctite Rewards Board.
			<cfelseif status LT 10>
				Thank you for registering for Henkel Loctite Rewards.<br>
				Your registration will be officially verified and you will receive an email in 24-48 hours with additional information.
			<cfelse>
				Our records indicate you have previously registered for Henkel Loctite Rewards.  Your registration will be authenticated and you will receive an email with additional information.
			</cfif>
		<cfelse>
			<cfset ErrorMessage = ErrorMessage & 'That password is already in use, please enter a different password.<br />'>
			<cfset pgfn='input'>
		</cfif>
	</cflock>
</cfif>							
<cfif pgfn IS 'input'>							
	<cfoutput>
	<form action="#application.SecureWebPath#/henkel-register-international.cfm" method="post" NAME="form_entry" onSubmit="return validateForm();">
		<input type="hidden" name="pgfn" value="verify">
		<table border="0">
			<tr><td align="left" class="welcome" colspan="2"><font color="##FF0000"><br>#ErrorMessage#</font><br></td></tr>
			<tr><td align="right" class="welcome">Email Address </td><td><input type="text" name="email" size="30" maxlength="128" value="#email#"></td></tr>
			<tr><td align="right" class="welcome">Password </td><td><input type="password" name="password" size="16" maxlength="16" value="#password#"><font size="-6"> (minimum 8 characters)</font></td></tr>
			<tr><td align="right" class="welcome">Confirm Password </td><td><input type="password" name="confirmpassword" size="16" maxlength="16" value="#confirmpassword#"><font size="-6"> (numbers and/or letters)</font></td></tr>
			<tr><td align="right" class="welcome">First Name </td><td><input type="text" name="first_name" size="30" maxlength="30" value="#first_name#"></td></tr>
			<tr><td align="right" class="welcome">Last Name </td><td><input type="text" name="last_name" size="30" maxlength="30" value="#last_name#"></td></tr>
			<tr><td align="right" class="welcome">Phone Number </td><td><input type="text" name="phone" size="14" maxlength="305" value="#phone#"></td></tr>
			<tr><td align="right" class="welcome">Distributor Company Name </td><td><input type="text" name="branch_name" size="30" maxlength="128" value="#branch_name#"></td></tr>
			<tr><td align="right" class="welcome">&nbsp;</td><td><font size="-4">(Official Company Name)</font></td></tr>
			<tr><td align="right" class="welcome">Branch Address </td><td><input type="text" name="branch_address" size="30" maxlength="64" value="#branch_address#"></td></tr>
			<tr><td align="right" class="welcome">Branch City </td><td><input type="text" name="branch_city" size="15" maxlength="30" value="#branch_city#"></td></tr>
			<tr><td align="right" class="welcome">Branch State </td><td><input type="text" name="branch_state" size="2" maxlength="2" value="#branch_state#"></td></tr>
			<tr><td align="right" class="welcome">Branch Zip </td><td><input type="text" name="branch_zip" size="10" maxlength="10" value="#branch_zip#"></td></tr>
			<tr><td align="right" class="welcome">Branch Country </td><td><input type="text" name="branch_country" size="32" maxlength="32" value="#branch_country#"></td></tr>
			<tr><td align="right" class="welcome">&nbsp;</td><td>&nbsp;</td></tr>
			<tr><td align="center" class="welcome" valign="top" colspan="2"><input name="CONFIRM" type="checkbox" value="1" <cfif CONFIRM EQ 1>checked</cfif>> I agree to the terms and conditions and privacy policy.</td></tr>
			<tr><td align="right" class="welcome">&nbsp;</td><td>&nbsp;</td></tr>
			<tr><td colspan="2" align="center"><input name="submit" type="image" value="submit" src="pics/program/henkel/register/submit-btn.jpg" border="0"></td></tr>
		</table>
	</form>
	</cfoutput>
</cfif>							
							<br />
						</td>
						<td width="6" valign="top"><img src="pics/program/henkel/register/HenkelBoardLegs.jpg" width="6" height="220" alt="" border="0"></td>
					</tr>
				</table>
			</td>
			<td width="188" valign="top" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td width="187" align="center">&nbsp;</td>
			<td width="425" align="center">
				<table border="0" width="100%">
					<tr>
						<td align="left">
							<a href="henkel-contact-us.cfm"><img src="pics/program/henkel/HenkelContactUs.jpg" alt="Contact Us" width="82" height="31" border="0"></a>
							&nbsp;<a href="#application.HenkelURL#"><img src="pics/program/henkel/HenkelHome.jpg" alt="Home" width="57" height="31" border="0"></a>
						</td>
						<td align="right">
							<img src="pics/program/henkel/Henkel-Logo.jpg" width="94" height="61">&nbsp;&nbsp;&nbsp;
						</td>
					</tr>
				</table>
			</td>
			<td width="188" align="center"></td>
		</tr>

	</table>
</font>
</body>
</html>