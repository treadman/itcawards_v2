<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>ITC Award Programs Administration.</title>

<link href="../includes/admin_style.css" rel="stylesheet" type="text/css">

</head>
<cfparam name="alert_msg" default="">
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" <cfif alert_msg NEQ ''>onLoad='alert("<cfoutput>#alert_msg#</cfoutput>");'</cfif>>

<cfinclude template="../../includes/environment.cfm"> 
<cfoutput>
<div class="pageheader">
	<div class="pageheadleft">
		A W A R D&nbsp;&nbsp;&nbsp;P R O G R A M S&nbsp;&nbsp;&nbsp;A D M I N I S T R A T I O N
	</div>
	<div class="pageheadright">
		<cfif #FLGen_AuthenticateAdmin()# EQ true>
			<cfif isDefined("cookie.admin_name") AND cookie.admin_name EQ "Tracy">
				<span class="loginname">Hello #cookie.admin_name#!</span> &nbsp;&nbsp;&nbsp;
			</cfif>
			<a href="logout.cfm" class="logout">Logout</a>
		</cfif>
	</div>
</div>
</cfoutput>

<!---<table cellpadding="0" cellspacing="0" width="900" border="0">
<cfif request.newNav>
<!--- --------------------------------------- --->
<!--- ------ Program Selector --------------- --->
<!--- --------------------------------------- --->

<cfif isDefined("request.is_admin") AND request.is_admin>
	<cfquery name="GetProgramNames" datasource="#application.DS#">
		SELECT ID, company_name, program_name 
		FROM #application.database#.program
		WHERE is_active = 1
		ORDER BY company_name, program_name
	</cfquery>
	<tr><td colspan="2" class="pageheader">
	<cfoutput>
	<form action="program_select.cfm" method="post" name="ProgramSelect">
		<input type="hidden" name="ReturnTo" value="#CurrentPage#" />
		<select name="Program" onChange="ProgramSelect.submit();">
			<option value="">ITC Admin</option>
			<cfloop query="GetProgramNames">
				<option value="#GetProgramNames.ID#"<cfif GetProgramNames.ID EQ request.selected_program_ID> selected</cfif>>#company_name# [#program_name#]</option>
			</cfloop>
		</select>
	</form>
	</cfoutput>
</td></tr>
</cfif>
</cfif>
</table>--->

<cfif isDefined("leftnavon")>
	<cfparam name="request.main_width" default="900">
	<table cellpadding="5" cellspacing="0" width="<cfoutput>#request.main_width#</cfoutput>" border="0">
	
	<tr>
	<td valign="top" width="185" class="leftnav"><cfinclude template="leftnav.cfm"></td>
	<td valign="top" width="10">&nbsp;</td>
	<td valign="top" width="<cfoutput>#request.main_width - 195#</cfoutput>">
	<br />
</cfif>
