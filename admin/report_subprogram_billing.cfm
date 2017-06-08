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

<cfif IsDefined('form.subtractions')>
	<cfif IsDefined('form.FieldNames') AND Trim(form.FieldNames) IS NOT "">
		<cfloop list="#Form.FieldNames#" index="ThisFieldName">
			<cfif ThisFieldName contains "sub_" AND Evaluate(ThisFieldName) NEQ ''>
				<cfset this_subprogram_ID = ListGetAt(ThisFieldName,2,"_")>
				<cfset this_user_ID = ListGetAt(ThisFieldName,3,"_")>
				<cfset thisPoints = Evaluate(ThisFieldName)>
				<cfset points_to_subtract = 0>
				<cfloop list="#thisPoints#" index="x">
					<cfif isNumeric(x)>
						<cfset points_to_subtract = points_to_subtract - x>
					</cfif>
				</cfloop>
				<cfif points_to_subtract NEQ 0>
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
			</cfif>
		</cfloop>
	</cfif>
</cfif>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "report_subprogram_billing">
<cfset request.main_width = 1600>
<cfinclude template="includes/header.cfm">

<script LANGUAGE="JavaScript"><!--
	function confirmSubmit() {
		var agree=confirm("Are you ready to save all the points to be subtracted?");
		if (agree)
			return true ;
		else
			return false ;
	}
	function updateTotal(obj, user_id, dir){
		var points_used = document.getElementById('points_'+user_id).innerHTML;
		var total_subtracted = document.getElementById('total_'+user_id).innerHTML;
		var new_value = obj.value;
		if (isNaN(parseInt(new_value))) {
			if(new_value != '') {
				obj.value = '';
			} 
			new_value = 0;
		}
		if (dir == 'subtract') {
			new_value = 0 - new_value;
		}
		new_total = parseInt(total_subtracted) + parseInt(new_value)
		document.getElementById('total_' + user_id).innerHTML = new_total;
		if (points_used == new_total) {
			document.getElementById('color_' + user_id).style.color = '#000000';
			document.getElementById('color_' + user_id).style.fontSize = '8pt';
		} else {
			document.getElementById('color_' + user_id).style.color = '#cb0400';
			document.getElementById('color_' + user_id).style.fontSize = '6pt';
		}
	}
// --></script>

<span class="pagetitle">Subprogram Order Transaction Report</span>
<br /><br />

<!--- START search box --->
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

<cfoutput>
<form action="#CurrentPage#" method="post">
	<table cellpadding="5" cellspacing="0" border="0">
		<tr class="contenthead">
			<td colspan="3"><span class="headertext">Report Criteria</span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="sub">(dates are optional)</span></td>
		</tr>
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
				<select name="sort" size="2">
					<option value="date"#FLForm_Selected(sort,"date"," selected")#>sort by date</option>
					<option value="lname"#FLForm_Selected(sort,"lname"," selected")#>sort by last name</option>
				</select>
			</td>
			<td class="content" valign="bottom">Orders Completed<br>From This Date:<br><input type="text" name="FromDate" value="#FromDate#" size="15"></td>
			<td class="content" valign="bottom">To This Date:<br><input type="text" name="ToDate" value="#ToDate#" size="15"></td>
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

<cfif formatFromDate IS NOT "" AND formatToDate IS NOT "">

	<!--- find the orders for this program between dates --->
	<cfquery name="FindUserOrders" datasource="#application.DS#">
		SELECT oi.order_number, oi.points_used, oi.created_datetime, up.username, up.fname, up.lname, up.ID AS user_ID, up.nickname
		FROM #application.database#.order_info oi
		JOIN #application.database#.program_user up ON oi.created_user_ID = up.ID
		WHERE oi.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
			AND oi.created_datetime >= <cfqueryparam value="#formatFromDate#">
			AND oi.created_datetime <= <cfqueryparam value="#formatToDate#">
			AND oi.is_valid = 1
		ORDER BY <cfif sort EQ "date">oi.created_datetime<cfelse>up.lname, up.fname</cfif>
	</cfquery>
	<cfset userid_list = ValueList(FindUserOrders.user_ID)>
	<!--- find all active subprograms --->
	<!---<cfquery name="FindAllSubprograms" datasource="#application.DS#">
		SELECT ID AS subprogram_ID, subprogram_name
		FROM #application.database#.subprogram
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
			AND is_active = 1
		ORDER BY sortorder, ID
	</cfquery>--->
	<cfquery name="FindAllSubprograms" datasource="#application.DS#">
		SELECT s.ID AS subprogram_ID, s.subprogram_name, SUM(p.subpoints) as total, s.is_active
		FROM #application.database#.subprogram_points p
		LEFT JOIN #application.database#.subprogram s ON s.ID = p.subprogram_ID
		WHERE s.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		AND p.user_ID IN (<cfqueryparam value="#userid_list#" list="true">)
		GROUP BY p.subprogram_ID
		HAVING total != 0
	</cfquery>
	<cfoutput>
	<form action="#CurrentPage#" method="post">
		<table cellpadding="5" cellspacing="1" border="0" width="1%">
			<!--- header row --->	
			<tr class="content2">
				<td colspan="100%"><span class="headertext">Program:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
			</tr>
			<tr class="content2">
				<td colspan="100%">
					<span class="headertext">Dates:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FromDate#<span class="reg">&nbsp;&nbsp;&nbsp;to&nbsp;&nbsp;&nbsp;</span>#ToDate#</span></span>
					<input type="submit" value="Save All" onClick="return confirmSubmit()">
					<input type="hidden" name="subtractions"><input type="hidden" name="ToDate" value="#ToDate#">
					<input type="hidden" name="FromDate" value="#FromDate#"><input type="hidden" name="sort" value="#sort#">
				</td>
			</tr>
			<tr class="contenthead">
				<td class="headertext">Username<br>Name<cfif sort EQ "lname"> <img src="../pics/contrls-asc.gif" width="7" height="6"></cfif></td>
				<td class="headertext">Order ##<br>Order&nbsp;Date<cfif sort EQ "date"> <img src="../pics/contrls-asc.gif" width="7" height="6"></cfif></td>
				<td class="headertext" align="center">Points<Br>Used</td>
				<cfloop query="FindAllSubprograms">
					<td align="center" valign="top" class="headertext" style="background-color:##<cfif is_active eq 1>EBD3C3<cfelse>CBB3A3</cfif>;">#subprogram_name#<cfif is_active eq 0><br><span class="sub">inactive</span></cfif></td>
				</cfloop>
			</tr>
			<cfloop query="FindUserOrders">
				<cfset user_ID = FindUserOrders.user_ID>
				<cfif FindUserOrders.RecordCount EQ 0>
					<span class="alert">There are no orders to display.</span>
				<cfelse>
					<!--- calculate this user's point for each subprogram --->
					<cfset this_users_subpoints = "">
					<cfloop query="FindAllSubprograms">
						<cfset this_users_subpoints = ListAppend(this_users_subpoints,SubprogramPoints(subprogram_ID,user_ID))>
					</cfloop>
					<tr class="content<cfif CurrentRow MOD 2 is 0>2</cfif>">
						<td rowspan="2" width="100%"><a href="report_subprogram_points_pop.cfm?user_ID=#user_ID#&program_ID=#program_ID#" target="_blank">#username#</a><br>#lname#, #fname#</td>
						<td rowspan="2">#FindUserOrders.order_number#<br>#FLGen_DateTimeToDisplay(FindUserOrders.created_datetime)#</td>
						<td align="center" valign="top" id="points_#user_id#">#FindUserOrders.points_used#</td>
						<cfset counter = 1>
						<cfloop query="FindAllSubprograms">
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
					<tr class="content<cfif CurrentRow MOD 2 is 0>2</cfif>">
						<td align="center" valign="top"><span id="color_#user_ID#" style="font-weight:bold;color:##cb0400;font-size:6pt">- <span id="total_#user_ID#">0</span></span></td>
						<cfset counter = 1>
						<cfloop query="FindAllSubprograms">
							<td align="center" valign="top" style="background-color:##<cfif is_active eq 1>FFE6D4<cfelse>EFD6C4</cfif>;">
								<cfif ListGetAt(this_users_subpoints,counter) EQ 0>
									&nbsp;
								<cfelse>
									<input type="text" size="3" name="sub_#subprogram_ID#_#user_ID#" style="margin:0px; padding:0px" onFocus="updateTotal(this,#user_ID#,'subtract')" onBlur="updateTotal(this,#user_ID#,'add');">
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

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->
