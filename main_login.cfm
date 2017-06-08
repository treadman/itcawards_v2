<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<cfparam name="iprod" default="">
<cfparam name="prod" default="">
<cfparam name="c" default="">
<cfparam name="p" default="">
<cfparam name="g" default="">
<cfparam name="OnPage" default="1">
<cfparam name="defer" default="">

<cfparam name="founduser" default="yes">
<cfparam name="has_points" default="yes">
<cfparam name="is_done" default="false">
<cfparam name="cantdefer" default="false">
<cfparam name="partialcredit" default="false">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>

<CFSCRIPT>
	kFLGen_ImageSize = FLGen_ImageSize(application.FilePath & "pics/program/" & vLogo);
</CFSCRIPT>

<!--- kick out if trying to defer and program doesn't allow it --->
<cfif NOT isBoolean(can_defer) OR (NOT can_defer and defer EQ "yes")>
	<cflocation addtoken="no" url="zkick.cfm">
</cfif>

<!--- form was submitted --->
<cfif IsDefined('form.username') AND form.username IS NOT "">
	<!--- check for username/program --->
	<cfquery name="FindProgramUser" datasource="#application.DS#">
		SELECT ID AS user_ID, IF(is_done=1,"true","false") AS is_done, defer_allowed, cc_max
		FROM #application.database#.program_user
		WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#username#" maxlength="128">
			AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
			AND is_active = 1
			AND (expiration_date >= CURDATE() OR expiration_date IS NULL)
	</cfquery>
	<cfif FindProgramUser.RecordCount EQ 1>
		<cfset user_ID = FindProgramUser.user_ID>
		<cfset is_done = FindProgramUser.is_done>
		<cfset defer_allowed = FindProgramUser.defer_allowed>
		<cfset cc_max = FindProgramUser.cc_max>
	</cfif>
	<!--- calculate award points as long as one user was found in this program with the submitted username --->
	<cfif FindProgramUser.RecordCount EQ 1 AND NOT is_done>
		<!--- get user info and write program user cookie --->
		<cfoutput>#ProgramUserInfo(user_ID, true)#</cfoutput>
		<!--- user was found and is ORDERING --->
		<cfif IsDefined('form.defer') AND form.defer IS NOT "yes">
			<cfif user_totalpoints GT 0 OR is_one_item>
				<cfif defer EQ "yes">
					<cflocation addtoken="no" url="defer.cfm">
				<cfelse>
					<cflocation addtoken="no" url="cart.cfm?iprod=#iprod#&prod=#prod#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#">
				</cfif>
			<cfelse>
				<cfset has_points = "no">
			</cfif>
		<!--- user was found and is DEFERRING --->
		<cfelseif IsDefined('form.defer') AND form.defer IS "yes">
			<cfif defer_allowed EQ 0>
				<cfset cantdefer = "true">
			<cfelseif user_totalpoints EQ defer_allowed>
				<cfset user_total = user_totalpoints>
				<cfoutput>#WriteSurveyCookie()#</cfoutput>
				<!--- the defer_allowed equals the total points available --->
				<cflocation  addtoken="no" url="defer.cfm">
			<cfelse>
				<cfset partialcredit = "true">
			</cfif>
		</cfif>
	<cfelse>
		<!--- username not found --->
		<cfset founduser = "no">
	</cfif>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="shortcut icon" href="/favicon.ico" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>ITC Awards</title>

<style type="text/css"> 
	<cfinclude template="includes/program_style.cfm"> 
</style>

<script>
function mOver(item, newClass) {
	item.className=newClass
}
function mOut(item, newClass) {
	item.className=newClass
}
function openHelp() {
	windowHeight = (screen.height - 150)
	helpLeft = (screen.width - 615)
	winAttributes = 'width=600, top=1, resizable=yes, scrollbars=yes, status=yes, titlebar=yes, height=' + windowHeight + ', left =' + helpLeft
	window.open('help.cfm','Help',winAttributes);
}
</script>
</head>
<cfoutput>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0"#main_bg#>
<cfinclude template="includes/environment.cfm"> 
<cfif kFLGen_ImageSize.ImageWidth LT 265>
	<!--- the logo is next to congrats --->
	<table cellpadding="0" cellspacing="0" border="0" width="800">
		<tr>
			<td width="275" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
			<td width="525" height="40" align="left" valign="bottom">#main_congrats#</td>
		</tr>
	</table>
<cfelse>
	<!--- the logo extends over the congrats --->
	<table cellpadding="0" cellspacing="0" border="0" width="800">
		<tr>
			<td colspan="2" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
		</tr>
		<cfif welcome_congrats NEQ "&nbsp;" AND welcome_congrats NEQ "">
			<tr>
				<td width="275"><img src="pics/program/shim.gif" width="275" height="1"></td>
				<td width="525" height="40" align="left" valign="bottom">#welcome_congrats#</td>
			</tr>
		</cfif>
	</table>
</cfif>
<table cellpadding="0" cellspacing="0" border="0" width="800">
<tr>
<td colspan="3" width="800" height="5"><img src="pics/shim.gif" width="25" height="5"><img src="pics/shim.gif" width="355" height="5"#cross_color#></td>
</tr>
<tr>
<td width="200" valign="top" align="center" >
	<br />
	<table cellpadding="8" cellspacing="1" border="0" width="150">
		<tr>
			<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='main.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">#return_button#</td>
		</tr>
		<cfif help_button NEQ "">
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="openHelp()">#help_button#</td>
			</tr>
		</cfif>
	</table>
	<br>
	<img src="pics/shim.gif" width="200" height="1">
</td>
<td width="5" height="100" valign="top"><img src="pics/shim.gif" width="5" height="175"#cross_color#></td>
<td width="725" valign="top" style="padding:12px" align="center">
	<cfif defer EQ "yes">
		<div align="left">
			<span class="main_login">#Replace(defer_msg,chr(13) & chr(10),"<br>","ALL")#</span>
		</div>
	</cfif>
	<br><br><br><br><br>
	<span class="main_login">To Continue With The <cfif defer EQ "yes">Deferral<cfelse>Ordering</cfif> Process<br>
		Please Enter Your<br>
		<b>#login_prompt#</b><br>
		<!--- Without Dashes or Spaces<br> ---><br>
	</span>
	<form method="post" action="#CurrentPage#">
		<input type="text" name="username" maxlength="128" size="50">
		<input type="hidden" name="username_required" value="You must enter a #login_prompt#.">
		<input type="hidden" name="iprod" value="#iprod#">
		<input type="hidden" name="prod" value="#prod#">
		<input type="hidden" name="c" value="#c#">
		<input type="hidden" name="p" value="#p#">
		<input type="hidden" name="g" value="#g#">
		<input type="hidden" name="OnPage" value="#OnPage#">
		<input type="hidden" name="defer" value="#defer#">
		<br><br>
		<input type="submit" name="submit" value="Submit">
	</form>
	<br><br>

	<!--- ************** --->
	<!--- ERROR MESSAGES --->
	<!--- ************** --->

	<!--- already ordered one item in one item store --->
	<cfif is_done>
		<span class="alert">You have already selected your gift.</span>
	<!--- used all their points --->
	<cfelseif has_points EQ "no">
		<span class="alert">You have no #credit_desc# remaining.</span>
	<!--- invalid login for ORDER--->
	<cfelseif founduser EQ "no" and defer NEQ "yes">
		<span class="main_login">
			<b>Invalid Entry</b>
			<br><br>
			You may have entered your #login_prompt#<br>
			incorrectly or may not be eligible for this award.
			<br><br>
			Please Try Again
			<br><br>
			If you continue to experience difficulty<br>
			please contact #application.AwardsProgramAdminName#,<br>
			ITC Awards Administrator, toll free at 1.888.266.6108.
		</span>
	<!--- invalid login for DEFER--->
	<cfelseif founduser EQ "no" and defer EQ "yes">
		<span class="main_login">
			<b>Invalid Entry</b>
			<br><br>
			You may have entered your<br>
			#login_prompt# incorrectly.
			<br><br>
			Please Try Again
			<br><br>
			If you continue to experience difficulty<br>
			please contact #application.AwardsProgramAdminName#l,<br>
			ITC Awards Administrator, toll free at 1.888.266.6108.
		</span>
	<!--- if they aren't allowed to defer --->
	<cfelseif cantdefer>
		<span class="main_login">
			You are not eligible to defer and must use<br>your #credit_desc#.
		</span>
		<br><br>
		<a href="main.cfm?c=#c#&p=#p#&g=#g#&Onpage=#Onpage#">Return to Award Selection</a>
	<!--- if cant defer because total points doesn't match the defer amount --->
	<cfelseif partialcredit>
		<span class="main_login">
			You have a partial #credit_desc# balance and cannot defer.
		</span>
		<br><br>
		<a href="main.cfm?c=#c#&p=#p#&g=#g#&Onpage=#Onpage#">Return to Award Selection</a>
	</cfif>
</td>
</tr>
</table>
</body></cfoutput>

</html>