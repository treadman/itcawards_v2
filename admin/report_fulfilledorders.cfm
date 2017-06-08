<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000087,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="program_ID" default="">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->


<cfset leftnavon = "fulfilledordersreport">
<cfinclude template="includes/header.cfm">

<cfset program_name = "">
<cfif program_ID NEQ "">
	<cfset program_name = FLITC_GetProgramName(program_ID)>
</cfif>

<cfoutput>
<span class="pagetitle">Shipped Quantity Report for <cfif program_name EQ "">All Programs<cfelse>#program_name#</cfif></span>
<br /><br />
<!--- search box (START) --->
<form action="#CurrentPage#" method="post">
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	<tr>
		<td class="content" align="center">
		<cfif NOT request.newNav>
			#SelectProgram(program_ID,"For All Programs")#
		</cfif>
		</td>
	</tr>
	<tr class="content">
		<td colspan="2" align="center"><input type="submit" name="submit" value="Generate Report"></td>
	</tr>
	</table>
</form>
<!--- search box (END) --->
</cfoutput>
<br /><br />
	
<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->
	
<cfif IsDefined('form.submit')>
	<cfquery name="ReportAllOrders" datasource="#application.DS#">
		SELECT COUNT(ID) AS total
		FROM #application.database#.order_info
		WHERE is_valid = 1
		<cfif program_ID NEQ "">
			AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10"> 
		</cfif>	
	</cfquery>
	<cfquery name="ReportFulfilledOrders" datasource="#application.DS#">
		SELECT COUNT(ID) AS total 
		FROM #application.database#.order_info
		WHERE is_all_shipped = 1
		AND is_valid = 1
		<cfif program_ID NEQ "">
			AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10"> 
		</cfif>	
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<!--- header row --->
		<tr class="content2">
			<td colspan="3"><span class="headertext">Program: <span class="selecteditem"><cfif program_ID NEQ ""><cfoutput>#program_name#</cfoutput><cfelse>All Award Programs</cfif></span></span></td>
		</tr>
		<tr valign="top" class="contenthead">
			<td valign="top" class="headertext">Total Orders</td>
			<td valign="top" class="headertext">Fulfilled</td>
			<td valign="top" class="headertext">Not Fulfilled</td>
		</tr>
		<!--- detail row --->
		<cfoutput>	
		<tr class="content">
			<td valign="top">#ReportAllOrders.total#</td>
			<td valign="top">#ReportFulfilledOrders.total#</td>
			<td valign="top">#ReportAllOrders.total - ReportFulfilledOrders.total#</td>
		</tr>
		</cfoutput>
	</table>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->