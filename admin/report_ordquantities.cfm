<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000039,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="program_ID" default="">
<cfparam name="FromDate" default="">
<cfparam name="ToDate" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">
<cfparam name="sort" default="sku">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "orderquanreport">
<cfinclude template="includes/header.cfm">

<cfset program_name = "">
<cfif program_ID NEQ "">
	<cfset program_name = FLITC_GetProgramName(program_ID)>
</cfif>

<cfoutput>
<span class="pagetitle">Order Quantity Report<cfif program_name NEQ ""> for #program_name#</cfif></span>
<br /><br />
<span class="pageinstructions">Leave the dates blank to see ordered quantities for all time.</span>
<br /><br />
<!--- search box (START) --->
<form action="#CurrentPage#" method="post">
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	<tr class="contenthead">
		<td colspan="3"><span class="headertext">Generate Order Quantity Report</span></td>
	</tr>
	<tr>
	<td class="content" align="center" rowspan="2">
		<cfif NOT request.newNav>
			#SelectProgram(program_ID,"For All Programs")#
		<cfelseif program_ID EQ "">
			For All Programs<br />
			<span class="sub">(Select a program from the upper left to limit this to one program.)</span>
		</cfif>
		<br><br>
		sort by: <select name="sort"><option value="sku"<cfif sort EQ "sku"> selected</cfif>>ITC SKU</option><option value="name"<cfif sort EQ "name"> selected</cfif>>Product Name</option></select>
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
	</table>
</form>
<!--- search box (END) --->
<br /><br />
</cfoutput>

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
	<cfquery name="ReportDistinctProd" datasource="#application.DS#">
		SELECT inv.product_ID, inv.snap_meta_name, inv.snap_options, inv.snap_sku, SUM(inv.quantity) AS thistotalquantity
		FROM #application.database#.inventory inv
		JOIN #application.database#.order_info oi ON inv.order_ID = oi.ID
		WHERE inv.is_valid = 1
		AND inv.quantity <> 0
		AND inv.order_ID <> 0
		<cfif formatFromDate NEQ "">
			AND inv.created_datetime >= '#formatFromDate#' 
		</cfif>	
		<cfif formatToDate NEQ "">
			AND inv.created_datetime <= '#formatToDate#' 
		</cfif>	
		<cfif program_ID NEQ "">
			AND oi.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
		</cfif>
		GROUP BY inv.snap_meta_name, inv.snap_sku
		ORDER BY <cfif sort EQ "sku">inv.snap_sku<cfelseif sort EQ "name">inv.snap_meta_name</cfif>
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<tr class="content2">
			<td colspan="3"><span class="headertext">Program: <span class="selecteditem"><cfif program_ID NEQ ""><cfoutput>#program_name#</span></span></cfoutput><cfelse>All Award Programs</cfif></td>
		</tr>
		<tr valign="top" class="contenthead">
			<td valign="top" class="headertext">ITC&nbsp;SKU<cfif sort EQ "sku">&nbsp;<img src="../pics/contrls-desc.gif"></cfif></td>
			<td valign="top" class="headertext">Total</td>
			<td valign="top" class="headertext">Product Name<cfif sort EQ "name">&nbsp;<img src="../pics/contrls-desc.gif"></cfif></td>
		</tr>
		<cfif ReportDistinctProd.RecordCount EQ 0>
			<tr class="content2">
			<td colspan="3" align="center" class="alert"><br>There are no results to display.<br><br></td>
			</tr>
		<cfelse>
			<cfoutput query="ReportDistinctProd">
				<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
				<td valign="top">#snap_sku#</td>
				<td valign="top">#thistotalquantity#</td>
				<td valign="top">#snap_meta_name# #snap_options#</td>
				</tr>
			</cfoutput>
		</cfif>
	</table>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->