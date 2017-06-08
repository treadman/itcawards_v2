<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
<cfparam name="url.program_ID" default="">

<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfset FLGen_AuthenticateAdmin()>

<!--- NOTE:  If you add a third program_ID here, you must look for the IF statements that use url.program_ID and modify them --->
<cfif url.program_ID EQ "1000000066">
	<cfset thisFileName = "henkel_us_registrations.xls">
	<cfset thisState = "State">
	<cfset FLGen_HasAdminAccess("1000000104",true)>
<cfelseif url.program_ID EQ "1000000069">
	<cfset thisFileName = "henkel_canada_registrations.xls">
	<cfset thisState = "Province">
	<cfset FLGen_HasAdminAccess("1000000105",true)>
<cfelse>
	<cflocation url="index.cfm" addtoken="no">
</cfif>


<!--- ***************** --->
<!--- page variables    --->
<!--- ***************** --->
<cfset TC = Chr(9)> <!--- Tab Char --->
<cfset NL = Chr(13) & Chr(10)> <!--- New Line --->

<cfcontent type="application/msexcel">
<cfheader name="Content-Disposition" value="filename=#thisFileName#">

<cfquery name="registrations" datasource="#application.DS#">
	SELECT r.ID, r.created_datetime, r.email, r.fname, r.lname, r.phone, r.company,
		r.address1, r.city, r.state, r.zip, r.region, p.program_name, r.alternate_emails,
		u.idh, u.registration_type, t.region AS henkel_region, t.division, t.grp, t.ty,
		t.fname AS terr_fname, t.lname AS terr_lname, t.email AS terr_email,
		(
			SELECT SUM(points)
			FROM #application.database#.awards_points a
			WHERE a.user_ID = r.program_user_ID
		) AS total_points
	FROM #application.database#.henkel_register r
	LEFT OUTER JOIN #application.database#.program p ON p.ID = r.program_ID
	LEFT OUTER JOIN #application.database#.program_user u ON u.ID = r.program_user_ID
	LEFT OUTER JOIN #application.database#.henkel_territory t ON t.sap_ty = CONCAT('00',r.region) AND t.program_ID = r.program_ID
	WHERE r.program_ID = <cfqueryparam value="#url.program_ID#" cfsqltype="CF_SQL_INTEGER">
	AND u.registration_type <> 'BranchHQ'
	GROUP BY r.ID
	ORDER BY r.created_datetime
</cfquery>
<cfquery name="branch_registrations" datasource="#application.DS#">
	SELECT r.ID, r.created_datetime, r.branch_email, r.branch_contact_fname, r.branch_contact_lname,
		r.branch_phone, r.company_name, r.branch_address, r.branch_city, r.branch_state, r.branch_zip,
		p.program_name, u.idh, u.registration_type,
		(
			SELECT SUM(points)
			FROM #application.database#.awards_points a
			WHERE a.user_ID = r.program_user_ID
		) AS total_points
	FROM #application.database#.henkel_register_branch r
	LEFT OUTER JOIN #application.database#.program p ON p.ID = r.program_ID
	LEFT OUTER JOIN #application.database#.program_user u ON u.ID = r.program_user_ID
 	WHERE r.program_ID = <cfqueryparam value="#url.program_ID#" cfsqltype="CF_SQL_INTEGER">
	AND u.registration_type <> 'BranchHQ'
	GROUP BY r.ID
	ORDER BY r.created_datetime
</cfquery>
<!--- <cfdump var="#branch_registrations#"><cfabort> --->
<!--- <cfoutput>Date Registered#TC#Email Address#TC#Username#TC#First Name#TC#Last Name#TC#Phone#TC#Company#TC#Address#TC#City#TC#State#TC#Zip Code#TC#Region#TC#Program ID#TC#Program User ID#TC#Status#NL#<cfloop query="registrations">#DateFormat(created_datetime,'yyyy-mm-dd')##TC##email##TC#`#username##TC##fname##TC##lname##TC#`#phone##TC##company##TC##address1##TC##city##TC##state##TC#'#zip#'#TC##region##TC##Program_ID##TC##Program_User_ID##TC##Status##NL#</cfloop></cfoutput> --->
<cfoutput>
<table>
	<tr>
		<td>Date Registered</td>
		<td>IDH</td>
		<td>Registration Type</td>
		<td>Current Points</td>
		<td>Email Address</td>
		<td>First Name</td>
		<td>Last Name</td>
		<td>Phone</td>
		<td>Company</td>
		<td>Address</td>
		<td>City</td>
		<td>#thisState#</td>
		<td>Zip Code</td>
		<td>Region Code (sap_ty)</td>
		<td>Region</td>
		<td>Rep First Name</td>
		<td>Rep Last Name</td>
		<td>Rep Email</td>
		<td>Division</td>
		<td>Group</td>
		<td>ty</td>
		<td>Program</td>
		<td>Branch Participants</td>
	</tr>
	<cfloop query="registrations">
		<tr>
			<td>#DateFormat(created_datetime,'yyyy-mm-dd')#</td>
			<td style="mso-number-format:\@">#idh#</td>
			<td>#registration_type#</td>
			<td style="mso-number-format:\@">#total_points#</td>
			<td>#email#</td>
			<td>#fname#</td>
			<td>#lname#</td>
			<td style="mso-number-format:\@">#phone#</td>
			<td>#company#</td>
			<td>#address1#</td>
			<td>#city#</td>
			<td>#state#</td>
			<td style="mso-number-format:\@">#zip#</td>
			<td style="mso-number-format:\@">#region#</td>
			<td style="mso-number-format:\@">#henkel_region#</td>
			<td>#terr_fname#</td>
			<td>#terr_lname#</td>
			<td>#terr_email#</td>
			<td>#division#</td>
			<td>#grp#</td>
			<td>#ty#</td>
			<td>#program_name#</td>
			<td>#alternate_emails#</td>
		</tr>
	</cfloop>
	<cfloop query="branch_registrations">
		<tr>
			<td>#DateFormat(created_datetime,'yyyy-mm-dd')#</td>
			<td style="mso-number-format:\@">#idh#</td>
			<td>#registration_type#</td>
			<td style="mso-number-format:\@">#total_points#</td>
			<td>#branch_email#</td>
			<td>#branch_contact_fname#</td>
			<td>#branch_contact_lname#</td>
			<td style="mso-number-format:\@">#branch_phone#</td>
			<td>#company_name#</td>
			<td>#branch_address#</td>
			<td>#branch_city#</td>
			<td>#branch_state#</td>
			<td style="mso-number-format:\@">#branch_zip#</td>
			<td style="mso-number-format:\@"><!--- #region# ---></td>
			<td style="mso-number-format:\@"><!--- #henkel_region# ---></td>
			<td><!--- #terr_fname# ---></td>
			<td><!--- #terr_lname# ---></td>
			<td><!--- #terr_email# ---></td>
			<td><!--- #division# ---></td>
			<td><!--- #grp# ---></td>
			<td><!--- #ty# ---></td>
			<td>#program_name#</td>
			<td><!--- #alternate_emails# ---></td>
		</tr>
	</cfloop>
</table>
</cfoutput>

<!---
<td>
	<cfset isEmailDupe = false>
	<cfset thisStatus = status>
	<cfif thisStatus GT 10>
		<cfset isEmailDupe = true>
		<cfset thisStatus = thisStatus - 10>
	</cfif>
	<cfswitch expression="#thisStatus#">
		<cfcase value="0">
			Approved
		</cfcase>
		<cfcase value="1">
			No Region
		</cfcase>
		<cfcase value="2">
			No Distributor
		</cfcase>
		<cfcase value="3">
			No Region or Distributor
		</cfcase>
		<cfdefaultcase>
			Unknown: #status#
		</cfdefaultcase>
	</cfswitch>
	<cfif isEmailDupe>
		- Duplicate Email
	</cfif>
</td>
--->