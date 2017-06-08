<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>

<CFSCRIPT>
	kFLGen_ImageSize = FLGen_ImageSize(application.AbsPath & "pics/program/" & vLogo);
</CFSCRIPT>

<cfset has_defered = "no">

<!--- delete order and user cookies --->
<cfcookie name="itc_order" expires="now" value="">
<cfcookie name="itc_user" expires="now" value="">

<!--- get the order_ID and user_ID from the survey cookie --->
<cfoutput>#AuthenticateSurveyCookie()#</cfoutput>

<!--- FORM PROCESSING CODE to defer credits --->
<cfif IsDefined('form.submit') and can_defer>

	<!--- double check that they have points to defer, just in case the user refreshed --->
	<!--- get current total --->
	<cfoutput>#ProgramUserInfo(user_ID)#</cfoutput>
	<cfif user_totalpoints EQ user_total>
		<!--- awards_points entry for negative amount that is available --->
		<cfquery name="NegatePoints" datasource="#application.DS#">
			INSERT INTO #application.database#.awards_points
				(created_user_ID, created_datetime, user_ID, points, notes, is_defered)
			VALUES
				('#user_ID#', '#FLGen_DateTimeToMySQL()#', '#user_ID#', -#user_total#, "negating available points before deferring them", 0)
		</cfquery>
		<!--- awards_points entry for that amount set to defered ---> 
		<cfquery name="DeferPoints" datasource="#application.DS#">
			INSERT INTO #application.database#.awards_points
				(created_user_ID, created_datetime, user_ID, points, notes, is_defered)
			VALUES
				('#user_ID#', '#FLGen_DateTimeToMySQL()#', '#user_ID#', #user_total#, "deferring points at program user's request", 1)
		</cfquery>
	</cfif>
	<cfset has_defered = "yes">
</cfif>

<!---  process survey if submitted --->
<cfif IsDefined('form.submitsurvey') AND form.submitsurvey IS NOT "">
	<cfoutput>#ProcessCustomerSurvey()#</cfoutput>
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="shortcut icon" href="/favicon.ico" />
<title>ITC Awards</title>
<!--- include variable style info --->
<style type="text/css"> 
	<cfinclude template="includes/program_style.cfm"> 
</style>
<!--- rollover function --->
<script>
function mOver(item, newClass) {
	item.className=newClass
}
function mOut(item, newClass) {
	item.className=newClass
}
</script>
</head>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0"<cfoutput>#main_bg#</cfoutput>>
	<cfinclude template="includes/environment.cfm"> 

<cfoutput>
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
	<td width="200" valign="top" align="center">
		<img src="pics/shim.gif" width="200" height="1">
		<br />
	</td>
	<td width="5" height="100" valign="top"><img src="pics/shim.gif" width="5" height="175"#cross_color#></td>
	<td width="725" valign="top" style="padding:25px" align="center">
		<br><br><br><br>
		<cfif has_defered EQ "no">
			<table cellpadding="8" cellspacing="0" border="1" bordercolor="#bg_active#">
				<tr>
					<td align="center">
						To defer your entire <span class="active_msg">#user_total#</span> #credit_desc# for<br>
						the next #company_name# Award Program, please<br>
						click the Defer Credits button.
						<br><br>
						<form method="post" action="#CurrentPage#">
							<input type="submit" name="submit" value="Defer Credits">
						</form>
					</td>
				</tr>
			</table>
		<cfelse>
			Your #credit_desc# have been deferred.<br>Thank you!
			<br><br>
			<cfif has_survey>
				<cfoutput>#CustomerSurvey("defer")#</cfoutput>
			</cfif>
		</cfif>
	</td></tr>
</table>
</cfoutput>
</body>
</html>