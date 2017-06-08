<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000091,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="vendor_ID" default="">
<cfparam name="FromDate" default="">
<cfparam name="ToDate" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">
<cfparam name="sort" default="sku">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "lorillard_redeemed">
<cfinclude template="includes/header.cfm">

<!--- <cfif NOT request.newNav>
	<cfparam name="program_ID" default="">
<cfelse> --->
	<cfset program_ID = 1000000035>
<!--- </cfif>
<cfif program_ID NEQ "1000000035">
	<cfabort showerror="This is only for 1000000035">
</cfif> --->
<cfset program_name = FLITC_GetProgramName(program_ID)>

<cfoutput>
<span class="pagetitle"><span class="selecteditem">#program_name#</span> Reedemed Report</span>
<br /><br />
<span class="pageinstructions">Leave the dates blank to see all Lorrilard points that have been redeemed.</span>
<br /><br />

<!--- search box (START) --->
<form action="#CurrentPage#" method="post">
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	<tr class="contenthead">
		<td colspan="4"><span class="headertext">Generate <span class="selecteditem">#program_name#</span> Redeemed Report</span></td>
	</tr>
	<tr>
		<td class="content" align="right">From Date: </td>
		<td class="content" align="left"><input type="text" name="FromDate" value="#FromDate#" size="12"></td>
		<td class="content" align="right">To Date:</td>
		<td class="content" align="left"><input type="text" name="ToDate" value="#ToDate#" size="12"></td>
	</tr>
	<tr class="content">
		<td colspan="2" align="center"><input type="submit" name="submit" value="Generate Report"></td>
		<td colspan="2" align="right"><a href="lorillard_compare.cfm">Download exception report</a></td>
	</tr>
	</table>
</form>
</cfoutput>
<!--- search box (END) --->
<br /><br />
	
<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->
	
<cfif isDefined("form.submit")>

	<cfif FromDate NEQ "">
		<cfset formatFromDate = FLGen_DateTimeToMySQL(FromDate)>
	</cfif>	
	<cfif ToDate NEQ "">
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
	</cfif>	

	<cfquery name="ReportLorillardRedeemed" datasource="#application.DS#">
		SELECT Date_Format(o.created_datetime,'%Y%m%d') AS created_datetime, o.points_used, p.username, p.lname 
		FROM #application.database#.order_info o
		JOIN #application.database#.program_user p ON o.created_user_ID = p.ID
		WHERE o.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" />
		AND o.is_valid = '1'
		AND o.points_used > 0 
		<cfif formatFromDate NEQ "">
			AND o.created_datetime >= '#formatFromDate#' 
		</cfif>	
		<cfif formatToDate NEQ "">
			AND o.created_datetime <= '#formatToDate#' 
		</cfif>	
		ORDER BY o.created_datetime ASC 
	</cfquery>
	
	<cfquery name="GetMultiplier" datasource="#application.DS#">
		SELECT points_multiplier 
		FROM #application.database#.program
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" />
	</cfquery>
	
	<cfoutput><a href="report_lorillard_export.cfm?formatFromDate=#formatFromDate#&formatToDate=#formatToDate#">Export Report to Excel</a></cfoutput><br><br>

	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<!--- header row --->
	<tr valign="top" class="contenthead">
		<td valign="top" class="headertext">PIN</td>
		<td valign="top" class="headertext">Points Redeemed</td>
		<td valign="top" class="headertext">Points Redeemed Date</td>
		<td valign="top" class="headertext">Last Name</td>
	</tr>
	
	<cfif ReportLorillardRedeemed.RecordCount EQ 0>
		<tr class="content2">
			<td colspan="4" align="center" class="alert"><br>There are no results to display.<br><br></td>
		</tr>
	<cfelse>
		<cfoutput query="ReportLorillardRedeemed">
			<tr class="content<cfif (CurrentRow MOD 2) is 0>2</cfif>">
				<td valign="top">#username#</td>
				<td valign="top">#points_used * GetMultiplier.points_multiplier#</span></td>
				<td valign="top">#created_datetime#</span></td>
				<td valign="top">#lname#</td>
			</tr>
		</cfoutput>
	</cfif>
	</table>

</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->