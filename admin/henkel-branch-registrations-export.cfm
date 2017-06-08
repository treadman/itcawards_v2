<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
<cfparam name="url.program_ID" default="">

<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfset FLGen_AuthenticateAdmin()>

<!--- NOTE:  If you add a third program_ID here, you must look for the IF statements that use url.program_ID and modify them --->
<cfif url.program_ID EQ "1000000066">
	<cfset thisFileName = "henkel_us_branch_registrations.xls">
	<cfset thisState = "State">
	<cfset FLGen_HasAdminAccess("1000000108",true)>
<!--- <cfelseif url.program_ID EQ "1000000069">
	<cfset thisFileName = "henkel_canada_branch_registrations.xls">
	<cfset thisState = "Province">
	<cfset FLGen_HasAdminAccess("1000000105",true)> --->
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

<cfquery name="branch_registrations" datasource="#application.DS#">
	SELECT r.ID, r.created_datetime, r.branch_email, r.branch_contact_fname, r.branch_contact_lname,
		r.branch_phone, r.company_name, r.branch_address, r.branch_city, r.branch_state, r.branch_zip,
		p.program_name, u.idh, u.registration_type, r.branch_reps, r.py_sales, r.jan_sales, r.feb_sales,
		r.mar_sales, r.apr_sales, r.may_sales, r.jun_sales, r.jul_sales, r.aug_sales, r.sep_sales,
		r.oct_sales, r.nov_sales, r.dec_sales, r.py_sales * 1.05 AS proj_sales,
		(r.jan_sales + r.feb_sales + r.mar_sales + r.apr_sales + r.may_sales + r.jun_sales + r.jul_sales +
			r.aug_sales + r.sep_sales + r.oct_sales + r.nov_sales + r.dec_sales) AS cy_sales,
		( 	SELECT SUM(points)
			FROM #application.database#.awards_points a
			WHERE a.user_ID = r.program_user_ID	) AS total_points
	FROM #application.database#.henkel_register_branch r
	LEFT OUTER JOIN #application.database#.program p ON p.ID = r.program_ID
	LEFT OUTER JOIN #application.database#.program_user u ON u.ID = r.program_user_ID
 	WHERE r.program_ID = <cfqueryparam value="#url.program_ID#" cfsqltype="CF_SQL_INTEGER">
	AND u.registration_type <> 'BranchHQ'
	GROUP BY r.ID
	ORDER BY r.created_datetime
</cfquery>
<cfoutput>
<table>
	<!--- <tr><td colspan="15"></td><td colspan="12">Monthly Sales</td></tr> --->
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
		<td>Program</td>
		<td>Branch Reps</td>
		<td>Prior Year</td>
		<td>Projected</td>
		<td>Current Year</td>
		<td>Percent Met</td>
		<td>Jan</td>
		<td>Feb</td>
		<td>Mar</td>
		<td>Apr</td>
		<td>May</td>
		<td>Jun</td>
		<td>Jul</td>
		<td>Aug</td>
		<td>Sep</td>
		<td>Oct</td>
		<td>Nov</td>
		<td>Dec</td>
	</tr>
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
			<td>#program_name#</td>
			<td>#branch_reps#</td>
			<td>#py_sales#</td>
			<td>#round(proj_sales)#</td>
			<td>#cy_sales#</td>
			<td><cfif proj_sales GT 0><cfif cy_sales GT 0>#round(cy_sales / proj_sales * 100)#<cfelse>0</cfif>%</cfif></td>
			<td>#jan_sales#</td>
			<td>#feb_sales#</td>
			<td>#mar_sales#</td>
			<td>#apr_sales#</td>
			<td>#may_sales#</td>
			<td>#jun_sales#</td>
			<td>#jul_sales#</td>
			<td>#aug_sales#</td>
			<td>#sep_sales#</td>
			<td>#oct_sales#</td>
			<td>#nov_sales#</td>
			<td>#dec_sales#</td>
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