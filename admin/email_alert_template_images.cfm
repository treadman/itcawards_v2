<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>ITC Awards Administration</title>
</head>
<body>
<!--- find program logos and admin logos --->
<cfquery name="FindProgramLogos" datasource="#application.DS#">
	SELECT company_name, program_name, logo, admin_logo
	FROM #application.database#.program
	ORDER BY company_name, program_name ASC 
</cfquery>
<!--- find all images in the pics/email_alerts folder --->
<cfdirectory action="list" directory="#application.FilePath#pics/email_alerts" name="AlertImages" sort="Name ASC">
<!--- display everything --->
Available Images for Email Alerts
<br /><br />
<table cellpadding="4" cellspacing="3">
<cfoutput query="FindProgramLogos">
	<cfif logo NEQ "">
		<tr bgcolor="##dddddd">
		<td><img src="../pics/program/#logo#" /><br />
		<span style="color:##777777">#company_name# [#program_name#] logo</span><br />
		&lt;img src="#application.SecureWebPath#/pics/program/#logo#"&gt;
		</td>
		</tr>
	</cfif>
	<cfif admin_logo NEQ "">
		<tr bgcolor="##dddddd">
		<td><img src="../pics/program/#logo#" /><br />
		<span style="color:##777777">#company_name# [#program_name#] admin logo</span><br />
		&lt;img src="#application.SecureWebPath#/pics/program/#admin_logo#"&gt;
		</td>
		</tr>
	</cfif>
</cfoutput>
<tr bgcolor="#aaaaaa">
<td>Email Alert Images<br />
To make images available on this page, send to upload.
</td>
</tr>
<cfoutput query="AlertImages">
	<tr bgcolor="##dddddd">
	<td><img src="../pics/email_alerts/#Name#" /><br />
	&lt;img src="#application.SecureWebPath#/pics/email_alerts/#Name#"&gt;</td>
	</tr>
</cfoutput>
</table>
</body>
</html>