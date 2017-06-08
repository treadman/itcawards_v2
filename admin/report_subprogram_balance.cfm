<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000094,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="sort" default="date">
<cfif request.newNav>
	<cfparam name="program_ID" default="">
<cfelse>
	<cfset program_ID = 1000000010>
</cfif>

<cfset program_name = "">
<cfif program_ID NEQ "">
	<cfset program_name = FLITC_GetProgramName(program_ID)>
</cfif>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfinclude template="includes/header_lite.cfm">

<span class="pagetitle">Subprogram Account Balance</span>
<br /><br />
	
<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->

<cfif NOT isNumeric(program_ID)>
	<span class="alert">Please select a program from the upper left.</span>
<cfelse>
	<!--- find the orders for this program between dates --->
	<cfquery name="UsersList" datasource="#application.DS#">
		SELECT UP.ID, UP.program_ID, UP.lname, UP.fname, UP.nickname,
			(SELECT IFNULL(SUM(AP.points),0) AS pos_pt
			FROM #application.database#.awards_points AP
			WHERE AP.user_ID = UP.ID) AS Awarded_Points,
		
			(SELECT IFNULL(SUM(OI.points_used),0) AS neg_pt
			FROM #application.database#.order_info OI
			WHERE OI.created_user_ID = UP.ID) AS Used_Points,
					
			(SELECT IFNULL(SUM(SP.subpoints),0) AS blah
				FROM #application.database#.subprogram_points SP
				WHERE SP.user_ID = UP.ID) AS subprogrampoints
		FROM #application.database#.program_user UP
		WHERE UP.program_ID = <cfqueryparam value="#program_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		ORDER BY UP.lname, UP.fname
	</cfquery>
	
	<cfquery name="SubprogramList" datasource="#application.DS#">
		SELECT ID, subprogram_name
		FROM #application.database#.subprogram
		WHERE program_ID = <cfqueryparam value="#program_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		ORDER BY sortorder
	</cfquery>
		
	<cfoutput>
	<table cellpadding="5" cellspacing="1" border="0">
		<!--- header row --->	
		<cfset Totals_Array = ArrayNew(1)>
		<cfset i = 1>
		<tr class="content2"><td colspan="100%"><span class="headertext">Program:&nbsp;&nbsp;&nbsp;<span class="selecteditem"><cfoutput>#program_name#</cfoutput></span></span></td></tr>
			<tr>
				<th>Name</th>
				<th>Awarded Points</th>
				<th>Used Points</th>
				<cfloop query="SubprogramList">
					<th align="left">#subprogram_name#</th>
					<cfset Totals_Array[i] = 0>
					<cfset i = i + 1>
				</cfloop>
			</tr>
	
		<cfloop query="UsersList">
			<cfif Awarded_Points - Used_Points NEQ 0>
				<tr>
					<td>#lname#, #fname#</td>
					<td align="right">#Awarded_Points#</td>
					<td align="right">#Used_Points#</td>
					<cfquery name="UserSubprogramList" datasource="#application.DS#">
						SELECT subprogram_ID, SUM(subpoints) AS SubprogramPoints
						FROM #application.database#.subprogram_points
						WHERE user_ID = <cfqueryparam value="#UsersList.ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
						GROUP BY subprogram_ID
						ORDER BY subprogram_ID
					</cfquery>
					<cfset i = 1>
					<cfloop query="SubprogramList">
						<cfset CurrentProgramID = SubprogramList.ID>
						<cfset FinalValue = 0>
						<cfloop query="UserSubprogramList">
							<cfif UserSubprogramList.subprogram_ID EQ CurrentProgramID>
								<cfset FinalValue = UserSubprogramList.SubprogramPoints>
							</cfif>
						</cfloop>
						<td align="right">#FinalValue#</td>
						<cfset Totals_Array[i] = Totals_Array[i] + FinalValue>
						<cfset i = i + 1>
					</cfloop>
				</tr>
			</cfif>
		</cfloop>
		<tr>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
			<th align="right">Total</th>
				<cfset i = 1>
				<cfloop query="SubprogramList">
					<th align="right">#Totals_Array[i]#</th>
					<cfset i = i + 1>
				</cfloop>
		</tr>
	</table>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->

