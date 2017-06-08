<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000081,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="FromDate" default="">
<cfparam name="ToDate" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">
<cfparam name="sort" default="date">
<cfparam name="program_ID" default="">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "report_subprogram_accural">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Subprogram Accural Report</span>
<br /><br />

<!--- START search box --->
<table cellpadding="5" cellspacing="0" border="0">
	<tr class="contenthead">
		<td colspan="3"><span class="headertext">Report Criteria</span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="sub">(dates are optional)</span></td>
	</tr>
	<cfoutput>
	<cfif IsDefined('form.sort') AND form.sort IS NOT "" AND isNumeric(program_ID)>
		<cfif FromDate EQ "" OR ToDate EQ "">
			<!--- find program's min max order dates --->
			<cfquery name="MinMaxOrderDates" datasource="#application.DS#">
				SELECT MIN(created_datetime) AS first_order, MAX(created_datetime) AS last_order 
				FROM #application.database#.order_info
				WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
					AND is_valid = 1
			</cfquery>
			<cfif FromDate EQ "" AND MinMaxOrderDates.first_order NEQ "">
				<cfset FromDate = FLGen_DateTimeToDisplay(MinMaxOrderDates.first_order)>
			<cfelseif FromDate EQ "">
				<cfset FromDate = FLGen_DateTimeToDisplay()>
			</cfif>
			<cfif ToDate EQ "" AND MinMaxOrderDates.last_order NEQ "">
				<cfset ToDate = FLGen_DateTimeToDisplay(MinMaxOrderDates.last_order)>
			<cfelseif ToDate EQ "">
				<cfset ToDate = FLGen_DateTimeToDisplay()>
			</cfif>
		</cfif>
		<cfset FromDate = FLGen_DateTimeToDisplay(FromDate)>
		<cfset formatFromDate = FLGen_DateTimeToMySQL(FromDate)>
		<cfset ToDate = FLGen_DateTimeToDisplay(ToDate)>
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
	</cfif>
	<cfif NOT request.newNav>
		<!--- do a search for all the programs with subprograms --->
		<cfquery name="FindProgsWithSubs" datasource="#application.DS#">
			SELECT p.ID AS program_ID
			FROM #application.database#.program p
			WHERE (SELECT COUNT(s.ID) FROM #application.database#.subprogram s WHERE s.program_ID = p.ID) > 0
			AND p.is_active = 1
			ORDER BY p.company_name, p.program_name 
		</cfquery>
	</cfif>
	<form action="#CurrentPage#" method="post">
		<tr>
		<td class="content" rowspan="2">
			<cfif NOT request.newNav>
				<select name="program_ID">
					<cfloop query="FindProgsWithSubs">
						<option value="#program_ID#"<cfif IsDefined('form.program_ID') AND form.program_ID EQ FindProgsWithSubs.program_ID> selected</cfif>>#FLITC_GetProgramName(program_ID)#</option>
					</cfloop>
				</select>
				<br /><br />
			</cfif>
			<select name="sort" size="2"><option value="date"#FLForm_Selected(sort,"date"," selected")#>sort by date</option><option value="lname"#FLForm_Selected(sort,"lname"," selected")#>sort by last name</option></select>
		</td>
		<td class="content" valign="bottom">Orders Completed<br>From This Date:<br><input type="text" name="FromDate" value="#FromDate#" size="15"></td>
		<td class="content" valign="bottom">To This Date:<br><input type="text" name="ToDate" value="#ToDate#" size="15"></td>
	</tr>
	<tr>
		<td colspan="2" class="content"><br /><input type="submit" name="submit" value="Generate Report"></td>
	</tr>
	</form>
	</cfoutput>
</table>
<!--- END search box --->
<br /><br />

<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->
<cfif isDefined("form.submit") AND NOT isNumeric(program_ID)>
	<span class="alert">Please select a program from the upper left.</span>
</cfif>
<cfif formatFromDate IS NOT "" AND formatToDate IS NOT "">
	<!--- find the orders for this program between dates --->
	<cfquery name="FindUserOrders" datasource="#application.DS#">
		SELECT SP.created_datetime, SP.subpoints, S.subprogram_name, PU.username, PU.fname, PU.lname
		FROM #application.database#.subprogram_points SP
		LEFT JOIN #application.database#.subprogram S ON S.ID = SP.subprogram_ID
		LEFT JOIN #application.database#.program_user PU ON PU.ID = SP.user_ID
		WHERE SP.subpoints > 0 AND SP.created_datetime >= <cfqueryparam value="#formatFromDate#"> AND SP.created_datetime <= <cfqueryparam value="#formatToDate#"> AND S.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		ORDER BY S.subprogram_name, PU.lname, PU.fname
	</cfquery>
	<cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="1%">
	<!--- header row --->	
	<tr class="content2">
		<td colspan="3"><span class="headertext">Program:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
	</tr>
	<tr class="content2">
		<td colspan="3"><span class="headertext">Dates:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FromDate#<span class="reg">&nbsp;&nbsp;&nbsp;to&nbsp;&nbsp;&nbsp;</span>#ToDate#</span></span></td>
		<td colspan="3" align="right">&nbsp;</td>
	</tr>
	<cfset Last_Subprogram_Name = "">
	<cfset subpoints_total = 0>
	<cfloop query="FindUserOrders">
		<cfif Last_Subprogram_Name NEQ subprogram_name>
			<cfif Last_Subprogram_Name GT "" OR  subpoints_total GT 0>
				<tr><td>&nbsp;</td><td align="right"><strong>#Last_Subprogram_Name# Total</strong></td><td align="right"><strong>#subpoints_total#</strong></td></tr>
				<tr><th colspan="3">&nbsp;</th></tr>
			</cfif>
			<tr><th colspan="3">#subprogram_name#</th></tr>
			<cfset Last_Subprogram_Name = subprogram_name>
			<cfset subpoints_total = 0>
		</cfif>
		<tr><td>#DateFormat(created_datetime, 'mm/dd/yyyy')#</td><td>#lname#, #fname# (#username#)</td><td align="right">#subpoints#</td></tr>
		<cfset subpoints_total = subpoints_total + subpoints>
	</cfloop>
	<tr><td>&nbsp;</td><td align="right"><strong>#Last_Subprogram_Name# Total</strong></td><td align="right"><strong>#subpoints_total#</strong></td></tr>
	</table>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->