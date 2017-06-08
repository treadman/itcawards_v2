<cfsetting requesttimeout="120">
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
<cfparam name="show_zero" default="0">
<cfparam name="subprogram_ID" default="0">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.subtractions')>
	<cfif IsDefined('form.FieldNames') AND Trim(#form.FieldNames#) IS NOT "">
		<cfloop list="#Form.FieldNames#" index="ThisFieldName">
			<cfif ThisFieldName contains "sub_" AND Evaluate(ThisFieldName) NEQ ''>
				<cfset this_subprogram_ID = ListGetAt(ThisFieldName,2,"_")>
				<cfset this_user_ID = ListGetAt(ThisFieldName,3,"_")>
				<cfset points_to_subtract = Evaluate(ThisFieldName) - (Evaluate(ThisFieldName) * 2)>
				<cfquery name="InsertLookups" datasource="#application.DS#">
					INSERT INTO #application.database#.subprogram_points
						(created_user_ID, created_datetime, user_ID, subprogram_ID, subpoints)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_ID#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#this_subprogram_ID#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#points_to_subtract#">
					)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "report_subprogram_user">
<cfinclude template="includes/header.cfm">

<script LANGUAGE="JavaScript"><!--
function confirmSubmit() {
	var agree=confirm("Are you ready to save all the points to be subtracted?");
	if (agree)
		return true ;
	else
		return false ;
	}
// --></script>

<span class="pagetitle">Subprogram User Report</span>
<br /><br />

<cfif NOT request.newNav>
	<!--- do a search for all the programs with subprograms --->
	<cfquery name="FindProgsWithSubs" datasource="#application.DS#">
		SELECT p.ID
		FROM #application.database#.program p
		WHERE (SELECT COUNT(s.ID) FROM #application.database#.subprogram s WHERE s.program_ID = p.ID) > 0
		AND p.is_active = 1
		ORDER BY p.company_name, p.program_name 
	</cfquery>
</cfif>

<cfif isNumeric(program_ID)>
	<!--- find all subprograms --->
	<cfquery name="FindAllSubprograms" datasource="#application.DS#">
		SELECT ID, subprogram_name, is_active
		FROM #application.database#.subprogram
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		ORDER BY sortorder, ID
	</cfquery>
</cfif>

<cfoutput>
<form name="ProgramSelect" action="#CurrentPage#" method="post">
	<!--- START search box --->
	<table cellpadding="5" cellspacing="0" border="0">
	<tr>
	<cfif NOT request.newNav>
	<td class="content" valign="top">
		<select name="program_ID" onChange="ProgramSelect.submit();"><!--- onChange="document.form1.submit();">--->
			<option value="">--- Select Program ---</option>
			<cfloop query="FindProgsWithSubs">
				<option value="#FindProgsWithSubs.ID#" <cfif program_ID EQ FindProgsWithSubs.ID> selected</cfif>>#FLITC_GetProgramName(FindProgsWithSubs.ID)#</option>
			</cfloop>
		</select>
		<cfif isNumeric(program_ID)>
			<br><br>
			<select name="subprogram_ID">
				<option value="0"<cfif subprogram_ID EQ 0> selected</cfif>>Show all active subprograms</option>
				<option value="-1"<cfif subprogram_ID EQ -1> selected</cfif>>Show all subprograms</option>
				<option value="-2"<cfif subprogram_ID EQ -2> selected</cfif>>Show only inactive subprograms</option>
				<cfloop query="FindAllSubprograms">
					<option value="#FindAllSubprograms.ID#"<cfif subprogram_ID EQ FindAllSubprograms.ID> selected</cfif>>#FindAllSubprograms.subprogram_name#</option>
				</cfloop>
			</select>
		</cfif>
	</td>
	</cfif>
	<td class="content">
		<input type="checkbox" name="show_zero" value="1" <cfif show_zero EQ "1">checked</cfif>>
		Show users with zero points<br><br>
		<input type="submit" name="generate" value="Generate Report">
	</td>
	</tr>
	</table>
</form>
</cfoutput>
<!--- END search box --->
<br /><br />
<cfif isDefined("form.generate")>
	<cfif NOT isNumeric(program_ID)>
		<span class="alert">Please select a program from the upper left.</span>
	<cfelse>
		<!--- find the orders for this program between dates --->
		<cfquery name="FindUsers" datasource="#application.DS#">
			SELECT username, fname, lname, ID AS user_ID, nickname
			FROM #application.database#.program_user
			WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
			ORDER BY lname
		</cfquery>
		<!--- find all active subprograms --->
		<cfquery name="FindSelectedSubprograms" datasource="#application.DS#">
			SELECT ID AS subprogram_ID, subprogram_name, is_active
			FROM #application.database#.subprogram
			WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
			<cfif subprogram_ID GT 0>
				AND ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#subprogram_ID#">
			<cfelseif subprogram_ID EQ 0>
				AND is_active = 1
			<cfelseif subprogram_ID EQ -2>
				AND is_active = 0
			</cfif>
			ORDER BY sortorder, ID
		</cfquery>
		<cfoutput>
		<form action="#CurrentPage#" method="post">
		<table cellpadding="5" cellspacing="1" border="0" width="1%">
		<!--- header row --->	
		<tr class="content2">
		<td colspan="2"><span class="headertext">Program:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
		<td colspan="#FindSelectedSubprograms.RecordCount#"><input type="submit" value="Save All" onClick="return confirmSubmit()"><input type="hidden" name="subtractions"></td>
		</tr>
		<tr class="contenthead">
		<td class="headertext">Username<br>Name <img src="../pics/contrls-asc.gif" width="7" height="6"></td>
		<td class="headertext" align="center">Actual Points</td>
		<cfloop query="FindSelectedSubprograms">
			<td align="center" valign="top" class="headertext" style="background-color:##<cfif is_active eq 1>EBD3C3<cfelse>CBB3A3</cfif>">#subprogram_name#<cfif is_active eq 0><br><span class="sub">inactive</span></cfif></td>
		</cfloop>
		</tr>
		<cfset cnt = 0>
		<cfloop query="FindUsers">
			<cfset user_ID = FindUsers.user_ID>
			<!--- calculate this user's actual points & subpoints --->
			#ProgramUserInfo(user_ID)#
			<!--- calculate this user's point for each subprogram --->
			<cfset this_users_subpoints = "">
			<cfset total_subpoints = 0>
			<cfloop query="FindSelectedSubprograms">
				<cfset this_subpoints = SubprogramPoints(subprogram_ID,user_ID)>
				<cfset this_users_subpoints = ListAppend(this_users_subpoints,this_subpoints)>
				<cfset total_subpoints = total_subpoints + this_subpoints>
			</cfloop>
			<cfif subprogram_ID LTE 0>
				<cfset check_zero = total_subpoints + user_totalpoints>
			<cfelse>
				<cfset check_zero = this_subpoints>
			</cfif>
			<cfif show_zero or check_zero gt 0>
				<cfif cnt MOD 2 is 0>
					<cfset row_color = "content2">
				<cfelse>
					<cfset row_color = "content">
				</cfif>
				<cfset cnt = cnt + 1>
				<tr class="#row_color#">
					<td rowspan="2" width="100%"><a href="report_subprogram_points_pop.cfm?user_ID=#user_ID#&program_ID=#program_ID#" target="_blank">#username#</a><br>#lname#, #fname#</td>
					<td>#user_totalpoints# / #total_subpoints#</td>
					<cfset counter = 1>
					<cfloop query="FindSelectedSubprograms">
						<td align="center" valign="top" style="background-color:##<cfif is_active eq 1>FFE6D4<cfelse>EFD6C4</cfif>;">
							<cfif ListGetAt(this_users_subpoints,counter) EQ 0>
								<span class="sub">#ListGetAt(this_users_subpoints,counter)#</span>
							<cfelse>
								#ListGetAt(this_users_subpoints,counter)#
							</cfif>
						</td>
						<cfset counter = IncrementValue(counter)>
					</cfloop>
				</tr>
				<tr class="#row_color#">
					<td align="center" valign="top"><span style="font-weight:bold;color:##cb0400;font-size:6pt">SUBTRACT:</span></td>
					<cfset counter = 1>
					<cfloop query="FindSelectedSubprograms">
						<td align="center" valign="top" style="background-color:##<cfif is_active eq 1>FFE6D4<cfelse>EFD6C4</cfif>;">
							<cfif ListGetAt(this_users_subpoints,counter) EQ 0>
								&nbsp;
							<cfelse>
								<input type="text" size="3" name="sub_#subprogram_ID#_#user_ID#" style="margin:0px; padding:0px">
							</cfif>
						</td>
						<cfset counter = IncrementValue(counter)>
					</cfloop>
				</tr>
			</cfif>
		</cfloop>
		</table>
		<input type="hidden" name="program_ID" value="#program_ID#">
		</form>
		</cfoutput>
	</cfif>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->