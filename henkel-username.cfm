<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">

<cfparam name="pgfn" default="input">
<cfparam name="email" default="">

<!--- Hard-coded Stuff --->
<!--- <cfparam name="emailTemplateID" default="45"> --->
<cfparam name="emailFrom" default="henkel.rewardsboard@us.henkel.com">
<cfparam name="emailSubject" default="Henkel Rewards Board Password">

<cfset ErrorMessage = "">

<cfif pgfn IS 'verify'>
	<cfif email IS "" OR NOT FLGen_IsValidEmail(form.email)>
		<cfset ErrorMessage = ErrorMessage & 'Please enter a valid email address.<br />'>
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
	<br><br>
	<cfquery name="CheckProgramUser" datasource="#application.DS#">
		SELECT fname, lname, username, program_ID
		FROM #application.database#.program_user
		WHERE email = <cfqueryparam value="#form.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">
		AND registration_type <> 'BranchHQ'
		AND ( program_ID = 1000000066 OR program_ID = 1000000069 )
	</cfquery>
	<cfif CheckProgramUser.RecordCount EQ 0>
		<cfset ErrorMessage = ErrorMessage & 'The email address, <strong>#form.email#</strong>,<br /> was not found in the Henkel Rewards Board program.<br />'>
		<cfset pgfn = 'input'>
	<cfelseif CheckProgramUser.RecordCount GT 1>
		<cfmail to="#Application.ErrorEmailTo#" from="#emailFrom#" subject="#emailSubject#" type="html">
#form.email# is duplicated in ITCAwards.Program_User.<br>
WHERE Program ID EQ 1000000066 OR 1000000069<br>
AND registration_type NEQ 'BranchHQ'<br>
This is in henkel-username.cfm
		</cfmail>
		<cfset ErrorMessage = ErrorMessage & 'There was a problem with that email address.  Please call toll-free 1.800.915.5999 or email #application.AwardsProgramAdminName#, Henkel Rewards Administrator, at #application.AwardsProgramAdminEmail#.<br />'>
		<cfset pgfn = 'input'>
	<cfelse>
		<!--- Send Email --->
		<cfmail to="#form.email#" failto="#Application.ErrorEmailTo#" from="#emailFrom#" subject="#emailSubject#" type="html">
Dear #CheckProgramUser.fname#,<br><br>
Below is your password and log-in instructions to enter the Henkel Rewards Board:<br><br><br>
<ul>
	<li> Go to www.henkelna.com/loctiterewards</li>
	<li> Enter Company Name: <strong>Henkel<cfif CheckProgramUser.program_ID EQ 1000000069>Canada</cfif></strong></li>
	<li> Enter Password: <strong>#CheckProgramUser.username#</strong></li>
</ul>
<br>
Should you need further assistance, please call toll-free 1.800.915.5999 or email #application.AwardsProgramAdminName#, Henkel Rewards Administrator, at #application.AwardsProgramAdminEmail#.  Thank you.
		</cfmail>
		We have sent your password to <cfoutput>#form.email#</cfoutput><br><br>
		Thank you!
	</cfif>
</cfif>
<cfif pgfn IS 'input'>
	<cfoutput>
	<br>
	<span class="welcome">Please enter your email address.<br>Your password will be emailed to you.</span>
	<form action="#CurrentPage#" method="post" NAME="username_entry">
		<input type="hidden" name="pgfn" value="verify">
		<table border="0" align="center">
			<tr><td align="center" class="welcome" colspan="2"><font color="##FF0000"><br>#ErrorMessage#</font><br></td></tr>
			<tr><td align="right" class="welcome">Email Address </td><td><input type="text" name="email" size="30" maxlength="128" value="#email#"></td></tr>
			<tr><td colspan="2" align="center"><br><br><input name="submit" type="image" value="submit" src="pics/program/henkel/register/submit-btn.jpg" border="0"></td></tr>
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