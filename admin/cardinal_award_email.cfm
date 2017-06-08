<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000045,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam  name="pgfn" default="list">
<cfparam name="alert_msg" default="">

<!--- param a/e form fields --->
<cfparam name="username" default="">	
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="email" default="">
<cfparam name="is_active" default="">
<cfparam name="this_region_ID" default="">
<cfparam name="program_user_ID" default="">
<cfparam name="email_sent" default="false">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfoutput>
	#FLGen_CreateTextFile(form.email_text,"admin/","cardinal_award_email.txt")#
	#FLGen_CreateTextFile(form.email_subject,"admin/","cardinal_award_subject.txt")#
	</cfoutput>
	<cfset alert_msg = "The changes were saved.">
	<cfif IsDefined('form.this_email') AND form.this_email IS NOT "">
		<!--- GET INFO FOR EMAIL VARS --->
		<!--- get a user's information --->
		<cfquery name="SelectUserInfo" datasource="#application.DS#">
			SELECT fname, username 
			FROM #application.database#.program_user
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.use_this_user#" maxlength="10">
		</cfquery>
		<!--- set vars --->
		<cfset fname = HTMLEditFormat(SelectUserInfo.fname)>
		<cfset username = HTMLEditFormat(SelectUserInfo.username)>
		
		<cfoutput>#ProgramUserInfo(use_this_user)#</cfoutput>

		<!--- get program information  --->
		<cfquery name="SelectProgramInfo" datasource="#application.DS#">
			SELECT company_name, logo, credit_desc, login_prompt
			FROM #application.database#.program
			WHERE ID = 1000000022
		</cfquery>
		
		<!--- set vars --->
		<cfset company_name = HTMLEditFormat(SelectProgramInfo.company_name)>
		<cfset logo = HTMLEditFormat(SelectProgramInfo.logo)>
		<cfset credit_desc = HTMLEditFormat(SelectProgramInfo.credit_desc)>
		<cfset login_prompt = HTMLEditFormat(SelectProgramInfo.login_prompt)>
	
		<!--- get the logo --->
		<cfif logo NEQ "">
			<cfset vLogo = HTMLEditFormat(logo)>
		<cfelse>
			<cfset vLogo = "shim.gif">
		</cfif>
		<cfparam name="emailsubject" default="important email">
		<cflock name="ThisLock" type="readonly" timeout="30">
			<cffile action="read" file="#application.AbsPath#admin/cardinal_award_subject.txt" variable="emailsubject">
		</cflock>
		<cfset this_is_the_subject = Trim(emailsubject)>
		<cfmail to="#form.this_email#" from="#Application.AwardsFromEmail#" subject="#this_is_the_subject#" type="html" failto="#Application.ErrorEmailTo#">
			<cfinclude template="cardinal_award_email.txt">
		</cfmail>
		<cfset email_sent = "true">
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "cardinal_award_email">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Cardinal Health Award Email</span>
<br /><br />
<cfif email_sent>
<span class="alert">Your test email was sent.</span>
<br /><br />
</cfif>

<cflock name="ThisLock" type="readonly" timeout="30">
	<cffile action="read" file="#application.FilePath#admin/cardinal_award_email.txt" variable="emailtext">
	<cffile action="read" file="#application.FilePath#admin/cardinal_award_subject.txt" variable="emailsubject">
</cflock>
<cfoutput>
<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<tr class="contenthead">
	<td valign="top" class="headertext" colspan="2">Email Text</td>
	</tr>

	<tr class="content2">
	<td colspan="2"><img src="../pics/contrls-desc.gif"> Sending a test email is optional.</td>
	</tr>
	
	<tr class="content">
	<td align="right">Send&nbsp;A&nbsp;<b>Test</b>&nbsp;Email&nbsp;To&nbsp;This&nbsp;Email:</td>
	<td><input name="this_email" type="text" size="40" maxlength="60"></td>
	</tr>
	
	<tr class="content">
	<td align="right">Using&nbsp;This&nbsp;Cardinal&nbsp;Program&nbsp;User's&nbsp;Info:</td>
	<td>
		<cfquery name="GetCardinalUsers" datasource="#application.DS#">
			SELECT ID AS program_user_ID, fname, lname  
			FROM #application.database#.program_user
			WHERE program_ID = 1000000022
			ORDER BY lname ASC 
		</cfquery>
		<select name="use_this_user">
		<cfloop query="GetCardinalUsers">
			<option value="#program_user_ID#">#fname# #lname#</option>
		</cfloop>
		</select>
	
	</td>
	</tr>
	
	<tr class="content">
	<td colspan="2" align="center"><input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save and/or Send Email" ></td>
	</tr>
	
	<tr class="content">
	<td colspan="2">Subject Line:<br><input type="text" name="email_subject" maxlength="60" size="60" value="#emailsubject#"></td>
	</tr>
	
	<tr class="content">
	<td colspan="2">Email Body:<br>&nbsp;&nbsp;&nbsp;&nbsp;<textarea name="email_text" cols="85" rows="65">#emailtext#</textarea></td>
	</tr>
	
	<tr class="content">
	<td colspan="2" align="center"><input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save and/or Send Email" ></td>
	</tr>
	
	</table>
	
</form>
</cfoutput>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->