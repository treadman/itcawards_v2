<html>
<head>
<title>Password Recovery</title>
<style type="text/css" media="screen">
<!--
td { font-weight: bold; font-size: 12px; line-height: 14px; font-family: Arial, Helvetica, Geneva, Swiss, SunSans-Regular }
.months { margin: 0px 5px 0px 0px }
--></style>
</head>
<body>
<cfif NOT isDefined("form.email")>
	<cflocation url="index.cfm" addtoken="no">
</cfif>
<cfquery name="SalesData" datasource="#application.DS#">
	SELECT username, branch_contact_fname, branch_email
	FROM #application.database#.henkel_register_branch
	WHERE branch_email = <cfqueryparam value="#form.email#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<table id="Table_01" width="890" height="615" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><img src="images/board_01.jpg" width="17" height="148" alt=""></td>
		<td><img src="images/board_02.jpg" width="856" height="148" alt=""></td>
		<td><img src="images/board_03.jpg" width="17" height="148" alt=""></td>
	</tr>
	<tr>
		<td><img src="images/board_04.jpg" width="17" height="455" alt=""></td>
		<td background="images/board_05.jpg" align="center">
			<p class="months">
				<cfif SalesData.recordcount NEQ 1>
					We cannot find your registration information.<br><br>
					Please <a href="index.cfm?p=1#AnchorSpot">click here to try again</a>.
				<cfelse>
					<cfset emailFrom = application.AwardsFromEmail>
					<cfset emailSubject = "Henkel Rewards Board">
					<cfmail to="#SalesData.branch_email#" from="#emailFrom#" subject="#emailSubject#" type="html">
Dear #SalesData.branch_contact_fname#,<br><br>
Below is your password and log-in instructions to enter the Henkel Rewards Board:<br><br><br>
<ul>
	<li> Go to <a href="#application.SecureWebPath#/henkel/anaerobics/">#application.PlainURL#/henkel/anaerobics/</a></li>
	<li> Enter Password: <strong>#SalesData.username#</strong></li>
</ul>
<br>
Should you need further assistance, please call toll-free 1.800.915.5999 or email Sarah Woodland, Henkel Rewards Administrator, at #application.AwardsProgramAdminEmail#.  Thank you.
</cfmail>
					We have sent your password to <strong><cfoutput>#SalesData.branch_email#</cfoutput></strong><br><br>Thank you!
					Please <a href="index.cfm?p=0#AnchorSpot">click here to go back to the login screen</a>.
				</cfif>
			</p>
		</td>
		<td><img src="images/board_06.jpg" width="17" height="455" alt=""></td>
	</tr>
	<tr>
		<td><img src="images/board_07.jpg" width="17" height="12" alt=""></td>
		<td><img src="images/board_08.jpg" width="856" height="12" alt=""></td>
		<td><img src="images/board_09.jpg" width="17" height="12" alt=""></td>
	</tr>
</table>



</body>
</html>
