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
<cfparam name="program_ID" default="">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "report_subprogram_remain">
<cfset request.main_width = 900>
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Subprogram Point Balance Report</span>
<br /><br />

<cfif NOT request.newNav>
	<!--- do a search for all the programs with subprograms --->
	<cfquery name="FindProgsWithSubs" datasource="#application.DS#">
		SELECT p.ID AS program_ID
		FROM #application.database#.program p
		WHERE (SELECT COUNT(s.ID) FROM #application.database#.subprogram s WHERE s.program_ID = p.ID) > 0
		ORDER BY p.company_name, p.program_name 
	</cfquery>
</cfif>

<cfoutput>
<form action="#CurrentPage#" method="post">
	<table cellpadding="5" cellspacing="0" border="0">
		<tr class="contenthead">
			<td colspan="3"><span class="headertext">Report Criteria</span></td>
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
<cfelseif isNumeric(program_ID)>
	
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
			<tr><td colspan="100%"><hr></td></tr>
		</table>
		<table cellpadding="3" cellspacing="1" border="0" width="100%">
			<tr><td>ID ##</td>
				<td>Name</td>
				<td align="right">Points Available</td>
			</tr>
			<cfset grandTotalPoints = 0>
			<cfloop query="FindAllSubprograms">
				<cfset totalPoints = 0>
				<cfset showHeader = true>
				<cfset thisSubID = FindAllSubprograms.subprogram_ID>
				<cfset thisSubName = FindAllSubprograms.subprogram_name>
				<cfquery name="FindSubPoints" datasource="#application.DS#">
					SELECT SUM(p.subpoints) AS points, u.username, u.fname, u.lname
					FROM #application.database#.subprogram_points p
					JOIN #application.database#.program_user u ON p.user_ID = u.ID
					WHERE subprogram_ID = #thisSubID#
					GROUP BY u.ID
					ORDER BY u.lname, u.fname
				</cfquery>
					<cfif FindSubPoints.recordcount GT 0>
						<cfloop query="FindSubPoints">
							<cfif FindSubPoints.points GT 0>
								<cfset totalPoints = totalPoints + FindSubPoints.points>
								<cfset grandTotalPoints = grandTotalPoints + FindSubPoints.points>
								<cfif showHeader>
									<cfset showHeader = false>
									<tr><td colspan="100%">Program: <strong>#thisSubName#</strong></td></tr>
								</cfif>
								<tr><td>#FindSubPoints.username#</td>
									<td>#FindSubPoints.fname# #FindSubPoints.lname#</td>
									<td align="right">#FindSubPoints.points#</td>
								</tr>
							</cfif>
						</cfloop>
					</cfif>
				<cfif NOT showHeader>
					<tr><td align="right" colspan="2"><strong>Total for #thisSubName#</strong>:&nbsp;&nbsp;</td><td align="right"><strong>#totalPoints#</strong></td></tr>
					<tr><td colspan="100%">&nbsp;</td></tr>
				</cfif>
			</cfloop>
			<tr><td colspan="100%">&nbsp;</td></tr>
			<tr><td align="right" colspan="2">Grand Total:&nbsp;&nbsp;</td><td align="right"><strong>#grandTotalPoints#</strong></td></tr>
		</table>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->
