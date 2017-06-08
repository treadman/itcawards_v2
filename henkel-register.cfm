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
<cfparam name="is_international" default="">
<cfparam name="branch_address1" default="">
<cfparam name="branch_city1" default="">
<cfparam name="branch_state1" default="">
<cfparam name="branch_zip1" default="">
<cfparam name="branch_address2" default="">
<cfparam name="branch_city2" default="">
<cfparam name="branch_state2" default="">
<cfparam name="branch_zip2" default="">
<cfparam name="country" default="">
<cfparam name="user_function" default="">
<cfparam name="registration_type" default="0">
<cfparam name="CONFIRM" default=0>

<cfif NOT isBoolean(registration_type)>
	<cfset registration_type = 0>
</cfif>

<!--- Static variables --->
<cfset created_user_ID = 1000000066>
<cfset program_ID = 1000000066>
<cfset Points = 10>
<cfset HoldPoints = 0>
<cfset Notes = "Automatic awards from Henkel registration form - #Points# for registering">
<cfset UserFunctionList = "Outside,Inside,Manager">
<cfset ErrorMessage = "">

<cfquery name="GetProgram" datasource="#application.DS#">
	SELECT cc_max_default 
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
</cfquery>


<cfif pgfn IS 'verify'>
	<cfif email IS "" OR NOT FLGen_IsValidEmail(form.email)>
		<cfset ErrorMessage = ErrorMessage & 'Please enter a valid email address<br />'>
	</cfif>
	<cfif password IS "">
		<cfset ErrorMessage = ErrorMessage & 'Please enter a password<br />'>
	<cfelse>
		<cfif LEN(password) LT 8>
			<cfset ErrorMessage = ErrorMessage & 'Your password must be at least 8 characters in length<br />'>
		<cfelse>
			<cfif confirmpassword IS "">
				<cfset ErrorMessage = ErrorMessage & 'Please confirm your password<br />'>
			<cfelseif password NEQ confirmpassword>
				<cfset ErrorMessage = ErrorMessage & 'Your passwords do not match<br />'>
			</cfif>
		</cfif>
	</cfif>
	<cfif first_name IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your first name<br />'></cfif>
	<cfif last_name IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your last name<br />'></cfif>
	<cfif user_function IS ""><cfset ErrorMessage = ErrorMessage & 'Please select your function<br />'></cfif>
	<cfif phone IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your phone number<br />'></cfif>
	<cfif branch_name IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your distributor company name<br />'></cfif>
	<cfif NOT isBoolean(is_international)>
		<cfset ErrorMessage = ErrorMessage & 'Please select either US or International<br />'>
	<cfelse>
		<cfif is_international>
			<cfif branch_address2 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch address<br />'></cfif>
			<cfif branch_city2 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch city<br />'></cfif>
			<cfif branch_state2 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch state / province<br />'></cfif>
			<cfif branch_zip2 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch postal code<br />'></cfif>
			<cfif country IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your country name<br />'></cfif>
		<cfelse>
			<cfif branch_address1 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch address<br />'></cfif>
			<cfif branch_city1 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch city<br />'></cfif>
			<cfif branch_state1 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch state<br />'></cfif>
			<cfif branch_zip1 IS ""><cfset ErrorMessage = ErrorMessage & 'Please enter your branch zip code<br />'></cfif>
		</cfif>
	</cfif>
	<cfif CONFIRM IS 0><cfset ErrorMessage = ErrorMessage & 'Please confirm that you agree to the terms, conditions and privacy policy<br />'></cfif>
	<!--- <cfif registration_type IS ""><cfset ErrorMessage = ErrorMessage & 'Please select a registration type<br />'></cfif> --->
	<cfif ListLast(email,'@') EQ "genpt.com">
		<cfset ErrorMessage = "We're sorry.  Registration is currently unavailable.<br />">
	</cfif>
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
	<cfif is_international>
		<cfset branch_zip1 = "">
	</cfif>
	<cflock name="program_userLock" timeout="60">
		<br><br>
		<cfquery name="CheckProgramUser" datasource="#application.DS#">
			SELECT ID 
			FROM #application.database#.program_user
			WHERE username = <cfqueryparam value="#form.password#" cfsqltype="CF_SQL_VARCHAR">
			AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
		</cfquery>
		<cfquery name="CheckForRegister" datasource="#application.DS#">
			SELECT ID 
			FROM #application.database#.henkel_register
			WHERE username = <cfqueryparam value="#form.password#" cfsqltype="CF_SQL_VARCHAR">
			AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
		</cfquery>
		<cfif CheckProgramUser.RecordCount IS 0 AND CheckForRegister.recordcount IS 0>
			<!--- Set status to zero --->
			<cfset status = 0>
			<!--- Check if zip code is in region --->
			<cfquery name="GetRegion" datasource="#application.DS#">
				SELECT DISTINCT region
				FROM #application.database#.xref_zipcode_region
				WHERE program_ID = <cfqueryparam value="#program_ID#" cfsqltype="CF_SQL_INTEGER">
				AND zipcode = <cfqueryparam value="#branch_zip1#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfset thisRegion = 0>
			<cfif GetRegion.recordcount EQ 1>
				<cfset thisRegion = GetRegion.region>
			</cfif>
			<cfset hasDistributor = false>
			<cfset thisDistributor = branch_name>
			<cfset thisIDH = "">
			<!--- Check if company name is in distributor table by EXACT MATCH--->
			<cfquery name="CheckDistributor1" datasource="#application.DS#">
				SELECT DISTINCT company_name, idh
				FROM #application.database#.henkel_distributor
				WHERE company_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#branch_name#">
				AND zip = <cfqueryparam value="#branch_zip1#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfif CheckDistributor1.recordcount EQ 1>
				<cfset hasDistributor = true>
				<cfset thisIDH = CheckDistributor1.IDH>
			<cfelse>
				<!--- Check if company name is in distributor table by FIRST N CHARACTERS --->
				<cfset checkLength = MIN(LEN(branch_name),10)>
				<cfquery name="CheckDistributor2" datasource="#application.DS#">
					SELECT DISTINCT company_name, idh
					FROM #application.database#.henkel_distributor
					WHERE LEFT(company_name,#checkLength#) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LEFT(branch_name,checkLength)#">
					AND zip = <cfqueryparam value="#branch_zip1#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<cfif CheckDistributor2.recordcount EQ 1>
					<cfset hasDistributor = true>
					<cfset thisDistributor = CheckDistributor2.company_name>
					<cfset thisIDH = CheckDistributor2.IDH>
				</cfif>
			</cfif>
			<cfif thisRegion EQ 0 AND hasDistributor>
				<!--- Could not find region by zip code, but found in distributor. --->
				<cfset status = 1>
			<cfelseif thisRegion GT 0 AND NOT hasDistributor>
				<!--- Could not find distributor by company name, but found in region. --->
				<cfset status = 2>
			<cfelseif thisRegion EQ 0 AND NOT hasDistributor>
				<!--- Could not find in either place. --->
				<cfset status = 3>
			</cfif>
			<!--- Check for email in register table --->
			<cfquery name="CheckForRecord" datasource="#application.DS#">
				SELECT ID 
				FROM #application.database#.henkel_register
				WHERE email = <cfqueryparam value="#form.email#" cfsqltype="CF_SQL_VARCHAR">
				AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
			</cfquery>
			<cfif CheckForRecord.recordcount GT 0>
				<cfset status = status + 10>
			</cfif>
			<cfset programUserID = 0>
			<cfif registration_type>
				<cfset thisType = "Branch">
			<cfelse>
				<cfset thisType = "Individual">
			</cfif>
			<cfif status EQ 0>
				<cfif thisIDH EQ "" OR mid(thisIDH,2,3) EQ "N/A">
					<cfset thisIDH = "999999">
				</cfif>
				<cfquery name="AddProgramUser" datasource="#application.DS#">
					INSERT INTO #application.database#.program_user (
						created_user_ID, created_datetime, program_ID, username, fname, lname, cc_max,
						ship_company, ship_address1, ship_city, ship_state, ship_zip, phone, email, is_active, idh, registration_type)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.password#" maxlength="16">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.first_name#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.last_name#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#GetProgram.cc_max_default#" maxlength="6">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisDistributor#" maxlength="64">,
						<cfif is_international>
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address2#" maxlength="64">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city2#" maxlength="30">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state2#" maxlength="2">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip2#" maxlength="32">,
						<cfelse>
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address1#" maxlength="64">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city1#" maxlength="30">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state1#" maxlength="2">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip1#" maxlength="32">,
						</cfif>
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.phone#" maxlength="35">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128">,
						1,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisIDH#" maxlength="16">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisType#" maxlength="16">

					)
				</cfquery>
				<cfquery name="GetMaxID" datasource="#application.DS#">
					SELECT MAX(ID) AS maxID
					FROM #application.database#.program_user
				</cfquery>
				<cfset programUserID = GetMaxID.maxID>
				<cfset HoldPoints = 0>
				<cfset Notes = "">
				<cfquery name="getHoldPoints" datasource="#application.DS#">
					SELECT points, source_import
					FROM #application.database#.henkel_hold_user
					WHERE email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#">
				</cfquery>
				<cfloop query="getHoldPoints">
					<cfset HoldPoints = HoldPoints + getHoldPoints.points>
					<cfset Notes = Notes & "#getHoldPoints.points# points for " & trim(getHoldPoints.source_import) & CHR(13) & CHR(10)>
				</cfloop>
				<cfif HoldPoints GT 0>
					<cfquery name="deleteHoldPoints" datasource="#application.DS#">
						DELETE FROM #application.database#.henkel_hold_user
						WHERE email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#">
					</cfquery>
					<cfset Notes = "Points awarded out of hold:#CHR(13)##CHR(10)#" & Notes>
				</cfif>
				<cfset Notes = "#Points# points for registering" & CHR(13) & CHR(10) & Notes>
				<cfquery name="AwardPoints" datasource="#application.DS#">
					INSERT INTO #application.database#.awards_points (
						created_user_ID, created_datetime, user_ID, points, notes)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#programUserID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Points+HoldPoints#">,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Notes#">
					)
				</cfquery>
				<!--- Send email --->
				<cfset user_name = form.password>
				<cfset first_name = form.first_name>
				<cfset email = form.email>
				<cfset emailTemplateID = 45>
				<cfset emailFrom = "henkel.rewardsboard@us.henkel.com">
				<cfinclude template="/includes/henkel_award_email.cfm">
			</cfif>
			<cfquery name="AddRegistration" datasource="#application.DS#">
				INSERT INTO #application.database#.henkel_register (
					created_user_ID, created_datetime, email, username, fname, lname, user_function, phone, company,
					is_international, address1, city, state, zip,<cfif form.is_international> country,</cfif> region, program_ID, program_user_ID, status, registration_type)
				VALUES (
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
					'#FLGen_DateTimeToMySQL()#',
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.password#" maxlength="16">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.first_name#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.last_name#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.user_function#" maxlength="16">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.phone#" maxlength="35">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisDistributor#" maxlength="64">,
					<cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.is_international#" maxlength="30">,
					<cfif form.is_international>
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address2#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city2#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state2#" maxlength="32">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip2#" maxlength="32">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.country#" maxlength="32">,
					<cfelse>
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address1#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city1#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state1#" maxlength="32">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip1#" maxlength="32">,
					</cfif>
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisRegion#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#programUserID#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#status#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisType#" maxlength="10">
				)
			</cfquery>
			<cfif status EQ 0>
				Thank you for registering for Henkel Loctite Rewards.<br>
				<cfoutput>
				<cfif HoldPoints EQ 0>
					You have been awarded #Points# Loctite Points.
				<cfelse>
					You have been awarded #Points# Loctite Points, along with #HoldPoints# additional points that were awarded to you prior to registering.
				</cfif>
				</cfoutput>
				<br>
				Please click the Home button to view the Henkel Loctite Rewards Board.
			<cfelseif status LT 10>
				Thank you for registering for Henkel Loctite Rewards.<br>
				Your registration will be officially verified and you will receive an email in 24-48 hours with additional information.
			<cfelse>
				Our records indicate you have previously registered for Henkel Loctite Rewards.  Your registration will be authenticated and you will receive an email with additional information.
			</cfif>
		<cfelse>
			<cfset ErrorMessage = ErrorMessage & 'That password is already in use, please enter a different password.<br />'>
			<cfset password = "">
			<cfset confirmpassword = "">
			<cfset pgfn='input'>
		</cfif>
	</cflock>
</cfif>							
<cfif pgfn IS 'input'>							
	<cfoutput>
	<form action="#application.SecureWebPath#/henkel-register.cfm" method="post" NAME="form_entry" onSubmit="return validateForm();">
		<input type="hidden" name="pgfn" value="verify">
		<table border="0">
			<tr><td align="left" class="welcome" colspan="2"><font color="##FF0000"><br>#ErrorMessage#</font><br></td></tr>
			<tr><td align="right" class="welcome">Email Address </td><td><input type="text" name="email" size="30" maxlength="128" value="#email#"></td></tr>
			<tr><td align="right" class="welcome">Password </td><td><input type="password" name="password" size="16" maxlength="16" value="#password#"><font size="-6"> (minimum 8 characters)</font></td></tr>
			<tr><td align="right" class="welcome">Confirm Password </td><td><input type="password" name="confirmpassword" size="16" maxlength="16" value="#confirmpassword#"><font size="-6"> (numbers and/or letters)</font></td></tr>
			<tr><td align="right" class="welcome">First Name </td><td><input type="text" name="first_name" size="30" maxlength="30" value="#first_name#"></td></tr>
			<tr><td align="right" class="welcome">Last Name </td><td><input type="text" name="last_name" size="30" maxlength="30" value="#last_name#"></td></tr>
			<tr><td align="right" class="welcome">Function </td>
				<td>
				<cfloop list="#UserFunctionList#" index="thisFunction">
					&nbsp;&nbsp;&nbsp;<input type="radio" name="user_function" value="#thisFunction#" <cfif thisFunction EQ user_function>checked</cfif>> #thisFunction#
				</cfloop>
				</td>
			</tr>
			<tr><td align="right" class="welcome">Phone Number </td><td><input type="text" name="phone" size="14" maxlength="35" value="#phone#"></td></tr>
			<tr><td align="right" class="welcome">Distributor Company Name </td><td><input type="text" name="branch_name" size="30" maxlength="64" value="#branch_name#"></td></tr>
			<tr><td align="right" class="welcome">&nbsp;</td><td><font size="-4">(Official Company Name)</font></td></tr>
			<tr><td align="right" class="welcome">&nbsp;</td><td>&nbsp;</td></tr>
			<tr><td align="right" class="welcome">This address is</td>
				<td>
				&nbsp;&nbsp;&nbsp;<input onClick="show_USA();" type="radio" name="is_international" value="0" <cfif is_international EQ "0">checked</cfif>> in the U.S.
				&nbsp;&nbsp;&nbsp;<input onClick="show_INTL();" type="radio" name="is_international" value="1" <cfif is_international EQ "1">checked</cfif>> International
				</td>
			</tr>
			<tr><td align="right" class="welcome">&nbsp;</td><td>&nbsp;</td></tr>
		</table>
		<script>
			function show_USA() {
				var srcElement1 = document.getElementById('USA');
				var srcElement2 = document.getElementById('INTL');
				srcElement1.style.display = 'block';
				srcElement2.style.display = 'none';
			}
			function show_INTL() {
				var srcElement1 = document.getElementById('USA');
				var srcElement2 = document.getElementById('INTL');
				srcElement1.style.display = 'none';
				srcElement2.style.display = 'block';
			}
		</script>
		<cfset thisDisplay = "none">
		<cfif isBoolean(is_international) AND NOT is_international>
			<cfset thisDisplay = "block">
		</cfif>
		<div id="USA" style="display:#thisDisplay#;">
		<table border="0">
			<tr><td align="right" class="welcome">Branch Address </td><td><input type="text" name="branch_address1" size="30" maxlength="64" value="#branch_address1#"></td></tr>
			<tr><td align="right" class="welcome">Branch City </td><td><input type="text" name="branch_city1" size="15" maxlength="30" value="#branch_city1#"></td></tr>
			<tr><td align="right" class="welcome">Branch State </td><td><input type="text" name="branch_state1" size="2" maxlength="2" value="#branch_state1#"></td></tr>
			<tr><td align="right" class="welcome">Branch Zip </td><td><input type="text" name="branch_zip1" size="10" maxlength="32" value="#branch_zip1#"></td></tr>
		</table>
		</div>
		<cfset thisDisplay = "none">
		<cfif isBoolean(is_international) AND is_international>
			<cfset thisDisplay = "block">
		</cfif>
		<div id="INTL" style="display:#thisDisplay#;">
		<table border="0">
			<tr><td align="right" class="welcome">Branch Address </td><td><input type="text" name="branch_address2" size="30" maxlength="64" value="#branch_address2#"></td></tr>
			<tr><td align="right" class="welcome">Branch City </td><td><input type="text" name="branch_city2" size="15" maxlength="30" value="#branch_city2#"></td></tr>
			<tr><td align="right" class="welcome">State or Province </td><td><input type="text" name="branch_state2" size="10" maxlength="32" value="#branch_state2#"></td></tr>
			<tr><td align="right" class="welcome">Postal Code</td><td><input type="text" name="branch_zip2" size="10" maxlength="32" value="#branch_zip2#"></td></tr>
			<tr><td align="right" class="welcome">Country </td><td><input type="text" name="country" size="30" maxlength="32" value="#country#"></td></tr>
		</table>
		</div>
		<table border="0">
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
			<!--- Check box method --->
			<cfset text_branch = "My branch/company policy requires redemption of points based on group rewards.  All individual points earned for this branch must be accumulated to be redeemed.">
			<tr><td align="left" colspan="2">
				<table align="center" width="90%">
				<tr>
					<td valign="top"><input name="registration_type" type="checkbox" value="1" <cfif registration_type EQ 1>checked</cfif>></td>
					<td class="welcome">#text_branch#</td>
				</tr>
				</table>
			</td></tr>
			<!--- Radio button method: <tr><td align="right" class="welcome">Registration Type </td>
				<td>
				<cfset text_individual = "My company allows me to redeem points toward prizes.">
				<cfset text_branch = "My branch/company policy requires redemption of points based on group rewards.  All individual points earned for this branch must be accumulated to be redeemed.">
				&nbsp;&nbsp;&nbsp;<input title="#text_individual#" type="radio" name="registration_type" value="Individual" <cfif registration_type EQ "Individual">checked</cfif>> <span style="cursor:hand; color:##0000AA; font-weight:bold;" title="#text_individual#">Individual</span>
				&nbsp;&nbsp;&nbsp;<input title="#text_branch#" type="radio" name="registration_type" value="Branch" <cfif registration_type EQ "Branch">checked</cfif>> <span style="cursor:hand; color:##FF0000; font-weight:bold;" title="#text_branch#">Branch</span>
				</td>
			</tr> --->
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