<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<cfparam name="id" default=0>
<cfparam name="CONFIRM" default=0>
<cfparam name="pgfn" default="input">

<cfset created_user_ID = 1000000066>
<cfset program_ID = 1000000066>
<cfset ErrorMessage = "">
<cfif pgfn IS 'verify'>
	<cfif CONFIRM IS 0><cfset ErrorMessage = ErrorMessage & 'Please confirm that you agree to the terms, conditions and privacy policy<br />'></cfif>
	<cfif ErrorMessage GT "">
		<cfset pgfn = 'input'>
	<cfelse>
		<cfquery datasource="#application.DS#" name="UpdateUser">
			UPDATE #application.database#.program_user
			SET created_user_ID = #created_user_ID#,
			is_active = 1
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#" maxlength="10">
			AND program_ID = #program_ID#
		</cfquery>
		<cfquery name="CheckProgUserLogin" datasource="#application.DS#">
			SELECT DISTINCT up.ID AS user_ID, IF(up.is_done=1,"true","false") AS is_done, up.defer_allowed, up.cc_max, pl.program_ID, p.company_name
			FROM #application.database#.program_user up
				JOIN #application.database#.program p ON up.program_ID = p.ID
				JOIN #application.database#.program_login pl ON pl.program_ID = p.ID
			WHERE up.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#id#" maxlength="10">
		</cfquery>
		<cfset program_ID = CheckProgUserLogin.program_ID>
		<cfset company_name = HTMLEditFormat(CheckProgUserLogin.company_name)>
		<cfset user_ID = CheckProgUserLogin.user_ID>
		<cfset is_done = HTMLEditFormat(CheckProgUserLogin.is_done)>
		<cfset defer_allowed = HTMLEditFormat(CheckProgUserLogin.defer_allowed)>
		<cfset cc_max = HTMLEditFormat(CheckProgUserLogin.cc_max)>

		<cfoutput>#ProgramUserInfo(id, true)#</cfoutput>
		<cfset HashedProgramID = FLGen_CreateHash(program_ID)>
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
<cfif pgfn IS 'input'>							
	<cfoutput>
	<form action="#CurrentPage#" method="post" NAME="form_entry">
		<input type="hidden" name="id" value="#id#">
		<input type="hidden" name="pgfn" value="verify">
		<table border="0" width="100%">
			<tr><td align="left" class="welcome" colspan="2"><font color="##FF0000"><br>#ErrorMessage#</font><br></td></tr>
			<tr><td align="right" class="welcome">&nbsp;</td><td>&nbsp;</td></tr>
			<tr><td align="center" colspan="2">
				<table align="center" width="90%">
				<tr>
				<td><input name="CONFIRM" type="checkbox" value="1" <cfif CONFIRM EQ 1>checked</cfif>></td>
				<td class="welcome">I agree to the <a href="terms_of_use.html" target="_blank">terms and conditions</a> and <a href="privacy_policy.html" target="_blank">privacy policy</a>.</td>
				</tr>
				</table>
			</td></tr>
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
							&nbsp;<a href="<cfoutput>#application.SecureWebPath#</cfoutput>/welcome.cfm"><img src="pics/program/henkel/HenkelHome.jpg" alt="Home" width="57" height="31" border="0"></a>
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