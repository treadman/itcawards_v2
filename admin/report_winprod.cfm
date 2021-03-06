<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000036,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="program_ID" default="">
<cfparam name="FromDate" default="">
<cfparam name="ToDate" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "winprodreport">
<cfinclude template="includes/header.cfm">

<cfset program_name = "">
<cfif program_ID NEQ "">
	<cfset program_name = FLITC_GetProgramName(program_ID)>
</cfif>

<cfoutput>
<span class="pagetitle">User/Product Report<cfif program_name NEQ ""> for #program_name#</cfif></span>
<br /><br />
<span class="pageinstructions">Leave the dates blank to see users/products for all time.</span>
<br /><br />
</cfoutput>

<!--- search box (START) --->
<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="3"><span class="headertext">Generate User/Product Report</span></td>
	</tr>
	
	<cfoutput>
	<form action="#CurrentPage#" method="post">
	<tr>
	<td class="content" align="center" rowspan="2">
		<cfif NOT request.newNav>
			#SelectProgram(program_ID,"For All Programs")#
		<cfelseif program_ID EQ "">
			For All Programs<br />
			<span class="sub">(Select a program from the upper left to limit this to one program.)</span>
		</cfif>
	</td>
	<td class="content" align="right">From Date: </td>
	<td class="content" align="left"><input type="text" name="FromDate" value="#FromDate#" size="12"></td>
	</tr>

	<tr>
	<td class="content" align="right">To Date:</td>
	<td class="content" align="left"><input type="text" name="ToDate" value="#ToDate#" size="12"></td>
	</tr>

	<tr class="content">
	<td colspan="3" align="center"><input type="submit" name="submit" value="Generate Report"></td>
	</tr>
	</form>
	</cfoutput>
	
</table>
<br /><br />
<!--- search box (END) --->
	
<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->
	
<cfif IsDefined('form.submit')>

	<cfif FromDate NEQ "">
		<cfset formatFromDate = FLGen_DateTimeToMySQL(FromDate)>
	</cfif>	
	<cfif ToDate NEQ "">
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
	</cfif>	

	<cfquery name="ReportOrders" datasource="#application.DS#">
		SELECT o.ID, o.snap_fname, o.snap_lname, o.created_datetime, i.quantity, i.snap_meta_name, i.snap_options
		FROM #application.database#.order_info o
		LEFT JOIN #application.database#.inventory i ON i.order_ID = o.ID
		WHERE o.is_valid = 1 
			<cfif formatFromDate NEQ "">
				AND o.created_datetime >= '#formatFromDate#' 
			</cfif>	
			<cfif formatToDate NEQ "">
				AND o.created_datetime <= '#formatToDate#' 
			</cfif>	
			<cfif program_ID NEQ "">
				AND o.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10"> 
			</cfif>
		ORDER BY o.created_datetime, o.ID, o.snap_fname, o.snap_lname
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<!--- header row --->
	<cfif program_ID NEQ "">
	<tr class="content2">
	<td colspan="3"><span class="headertext">Program: <span class="selecteditem"><cfoutput>#program_name#</span></span></cfoutput></td>
	</tr>
	<cfelse>
	<tr class="content2">
	<td colspan="3"><span class="headertext">For <span class="selecteditem">All Award Programs</span></span></td>
	</tr>
	</cfif>
	
	<tr valign="top" class="contenthead">
	<td valign="top" class="headertext">Order Date</td>
	<td valign="top" class="headertext">User</td>
	<td valign="top" class="headertext">Qty - Product</td>
	</tr>
	
	<cfif ReportOrders.RecordCount EQ 0>
	<tr class="content2">
	<td colspan="3" align="center" class="alert"><br>There are no results to display.<br><br></td>
	</tr>
	</cfif>
	<cfset count = 1>
	<cfoutput query="ReportOrders" group="created_datetime">
		<cfset count = count + 1>
		<tr class="#Iif(((count MOD 2) is 0),de('content2'),de('content'))#">
		<td valign="top">#FLGen_DateTimeToDisplay(created_datetime)#</td>
		<td valign="top">#snap_fname# #snap_lname#</td>
		<td valign="top"><cfoutput><b>#quantity#</b> - #snap_meta_name# #snap_options#<br></cfoutput></td>
		</tr>
	
	</cfoutput>
	
	</table>

</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->