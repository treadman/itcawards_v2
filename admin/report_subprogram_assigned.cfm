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
<cfparam name="FromDateA" default="">
<cfparam name="ToDateA" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">
<cfparam name="formatFromDateA" default="">
<cfparam name="formatToDateA" default="">
<cfparam name="sort" default="date">
<cfparam name="program_ID" default="">

<cfset alert_msg = "">
<!--- START search box --->
<cfif isNumeric(program_ID)>
	<cfif NOT isDate(FromDate)>
		<cfset alert_msg = "Please enter an orders completed from date.">
	<cfelseif NOT isDate(ToDate)>
		<cfset alert_msg = "Please enter an orders completed to date.">
	<cfelseif NOT isDate(FromDateA)>
		<cfset alert_msg = "Please enter a taken from subprogram from date.">
	<cfelseif NOT isDate(ToDateA)>
		<cfset alert_msg = "Please enter a taken from subprogram to date.">
	</cfif>
	<cfif alert_msg EQ "">
		<cfset FromDate = FLGen_DateTimeToDisplay(FromDate)>
		<cfset formatFromDate = FLGen_DateTimeToMySQL(FromDate)>
		<cfset ToDate = FLGen_DateTimeToDisplay(ToDate)>
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
		<cfset FromDateA = FLGen_DateTimeToDisplay(FromDateA)>
		<cfset formatFromDateA = FLGen_DateTimeToMySQL(FromDateA)>
		<cfset ToDateA = FLGen_DateTimeToDisplay(ToDateA)>
		<cfset formatToDateA = FLGen_DateTimeToMySQL(ToDateA & "23:59:59")>
	</cfif>
</cfif>

<cfif NOT request.newNav>
	<!--- do a search for all the programs with subprograms --->
	<cfquery name="FindProgsWithSubs" datasource="#application.DS#">
		SELECT p.ID AS program_ID
		FROM #application.database#.program p
		WHERE (SELECT COUNT(s.ID) FROM #application.database#.subprogram s WHERE s.program_ID = p.ID) > 0
		ORDER BY p.company_name, p.program_name 
	</cfquery>
</cfif>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->
<cfset leftnavon = "report_subprogram_assigned">
<cfset request.main_width = 900>
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Subprogram Order Transaction Report</span>
<br /><br />

<cfoutput>
<form action="#CurrentPage#" method="post">
	<table cellpadding="5" cellspacing="0" border="0">
		<tr class="contenthead">
			<td colspan="3"><span class="headertext">Report Criteria</span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="sub">(dates are optional)</span></td>
		</tr>
		<tr>
			<td class="content" rowspan="3" valign="top"><br><br>
				<cfif NOT request.newNav>
					<select name="program_ID">
						<cfloop query="FindProgsWithSubs">
							<option value="#program_ID#"<cfif IsDefined('form.program_ID') AND form.program_ID EQ FindProgsWithSubs.program_ID> selected</cfif>>#FLITC_GetProgramName(program_ID)#</option>
						</cfloop>
					</select>
					<br /><br />
				</cfif>
				<!--- <select name="sort" size="2">
					<option value="date"#FLForm_Selected(sort,"date"," selected")#>sort by date</option>
					<option value="lname"#FLForm_Selected(sort,"lname"," selected")#>sort by last name</option>
				</select> --->
			</td>
			<td class="content" valign="bottom">Orders Completed<br>From This Date:<br><input type="text" name="FromDate" value="#FromDate#" size="15"></td>
			<td class="content" valign="bottom">To This Date:<br><input type="text" name="ToDate" value="#ToDate#" size="15"></td>
		</tr>
		<tr>
			<td class="content" valign="bottom">Taken from Subprogram<br>From This Date:<br><input type="text" name="FromDateA" value="#FromDateA#" size="15"></td>
			<td class="content" valign="bottom">To This Date:<br><input type="text" name="ToDateA" value="#ToDateA#" size="15"></td>
		</tr>
		<tr>
			<td colspan="2" class="content"><br><input type="submit" name="submit" value="Generate Report"></td>
		</tr>
	</table>
</form>
</cfoutput>
<!--- END search box --->
<br /><br />

<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->
<cfif isDefined("form.submit") AND NOT isNumeric(program_ID)>
	<span class="alert">Please select a program from the upper left.</span>
</cfif>

<cfif formatFromDate IS NOT "" AND formatToDate IS NOT "" AND formatFromDateA IS NOT "" AND formatToDateA IS NOT "">

	<!--- find the orders for this program between dates --->
	<cfquery name="FindUserOrders" datasource="#application.DS#">
		SELECT oi.order_number, oi.points_used, oi.created_datetime, up.username, up.fname, up.lname, up.ID AS user_ID, up.nickname
		FROM #application.database#.order_info oi
		JOIN #application.database#.program_user up ON oi.created_user_ID = up.ID
		WHERE oi.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
			AND oi.created_datetime >= <cfqueryparam value="#formatFromDate#">
			AND oi.created_datetime <= <cfqueryparam value="#formatToDate#">
			AND oi.is_valid = 1
		ORDER BY <cfif sort EQ "date">oi.created_datetime<cfelse>up.lname</cfif>
	</cfquery>
	
	<!--- find all active subprograms --->
	<cfquery name="FindAllSubprograms" datasource="#application.DS#">
		SELECT ID AS subprogram_ID, subprogram_name
		FROM #application.database#.subprogram
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
			AND is_active = 1
		ORDER BY sortorder, ID
	</cfquery>
	
	<cfoutput>
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
			<!--- header row --->	
			<tr class="content2">
				<td colspan="100%"><span class="headertext">Program:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
			</tr>
			<tr class="content2">
				<td colspan="100%">
					<span class="headertext">Dates:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FromDate#<span class="reg">&nbsp;&nbsp;&nbsp;to&nbsp;&nbsp;&nbsp;</span>#ToDate#</span></span>
				</td>
			</tr>
			<tr><td colspan="100%"><hr></td></tr>
		</table>
		<table cellpadding="3" cellspacing="1" border="0" width="100%">
			<tr><td>ID ##</td>
				<td>Name</td>
				<td>Date Ordered</td>
				<td align="right">Total Points</td>
				<td align="right">Points Assigned</td>
			</tr>
			<cfloop query="FindAllSubprograms">
				<cfset showHeader = true>
				<cfset thisSubID = FindAllSubprograms.subprogram_ID>
				<cfset thisSubName = FindAllSubprograms.subprogram_name>
				<cfloop query="FindUserOrders">
					<cfset thisUserID = FindUserOrders.user_ID>
					<cfset thisUserName = FindUserOrders.username>
					<cfset thisFullName = "#FindUserOrders.fname# #FindUserOrders.lname#">
					<cfset thisDate = FindUserOrders.created_datetime>
					<cfset thisPoints = FindUserOrders.points_used>
					<cfquery name="FindSubPoints" datasource="#application.DS#">
						SELECT subpoints
						FROM #application.database#.subprogram_points
						WHERE user_ID = #thisUserID#
						AND subprogram_ID = #thisSubID#
						AND created_datetime >= <cfqueryparam value="#formatFromDateA#">
						AND created_datetime <= <cfqueryparam value="#formatToDateA#">
					</cfquery>
					<cfif FindSubPoints.recordcount GT 0>
						<cfloop query="FindSubPoints">
							<cfif showHeader>
								<cfset showHeader = false>
								<tr><td colspan="100%">Program: <strong>#thisSubName#</strong></td></tr>
							</cfif>
							<tr><td>#thisUserName#</td>
								<td>#thisFullName#</td>
								<td>#DateFormat(thisDate,"mm/dd/yyyy")#</td>
								<td align="right">#thisPoints#</td>
								<td align="right">#FindSubPoints.subpoints#</td>
							</tr>
						</cfloop>
					</cfif>
				</cfloop>
				<cfif NOT showHeader>
					<tr><td colspan="100%">&nbsp;</td></tr>
				</cfif>
			</cfloop>
		</table>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->
