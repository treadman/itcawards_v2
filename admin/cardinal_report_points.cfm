<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000046,true)>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "cardinal_report">
<cfinclude template="includes/header.cfm">

<!--- grab this admin, user's regions and create a list --->
<cfquery name="GetThisAccess" datasource="#application.DS#">
	SELECT chr.ID, chr.region_name  
	FROM #application.database#.cardinal_health_region chr
	JOIN #application.database#.cardinal_health_region_lookup chrl ON chr.ID = chrl.region_ID 
	WHERE chrl.admin_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">
</cfquery>
<cfset vGetThisAccess = ValueList(GetThisAccess.ID)>

<cfif GetThisAccess.RecordCount GT 0>
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT up.ID AS program_user_ID, up.fname, up.lname, IFNULL(chr.region_name,' Unassigned') AS region_name 
		FROM #application.database#.program_user up 
			LEFT JOIN #application.database#.cardinal_health_region_lookup chrl ON up.ID = chrl.program_user_ID
			LEFT JOIN #application.database#.cardinal_health_region chr ON chrl.region_ID = chr.ID
		WHERE up.program_ID = 1000000022
			AND chr.ID IN (#PreserveSingleQuotes(vGetThisAccess)#)
		ORDER BY chr.region_name, up.lname
	</cfquery>
	<span class="pagetitle">Cardinal Health Report</span>
	<br />
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<cfoutput query="SelectList" group="region_name">
			<tr>
			<td valign="top" colspan="3"><br><b>#region_name#</b><br><br></td>
			</tr>
			<cfoutput>
				<cfquery name="GetPointHistory" datasource="#application.DS#">
					SELECT created_datetime, points AS thispoints, notes AS thisnote, 000 AS order_number, IF(is_defered = 1, 'true', 'false') AS thisdef
					FROM #application.database#.awards_points
					WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_user_ID#" maxlength="10">
					
					UNION
					
					SELECT created_datetime, points_used AS thispoints, '' AS thisnote, order_number AS order_number, 'false' AS thisdef
					FROM #application.database#.order_info
					WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_user_ID#" maxlength="10"> 
						AND is_valid = 1
					ORDER BY created_datetime
				</cfquery>
					
				<tr class="contenthead">
				<td class="headertext" colspan="3">#fname# #lname#</td>
				</tr>
				
				<tr class="contenthead">
				<td class="headertext">Date</td>
				<td class="headertext">Points</td>
				<td class="headertext">Order Number/Inventory Note</td>
				</tr>
				
				<cfloop query="GetPointHistory">
					<tr class="content">
					<td>#FLGen_DateTimeToDisplay(created_datetime)#</td>
					<td align="right"><cfif thisdef><span class="sub">[defered]</span></cfif><cfif order_number NEQ 000>-</cfif> #thispoints#</td>
					<td><cfif order_number NEQ 000>Order Number: #order_number#<cfelseif thisnote NEQ "">#thisnote#<cfelse> - </cfif></td>
					</tr>
				</cfloop>
				<tr class="content">
				<td align="right" class="headertext" colspan="2">#ProgramUserInfo(program_user_ID)##user_totalpoints#</td>
				<td class="headertext">TOTAL POINTS</td>
				</tr>
			</cfoutput>
		</cfoutput>
	</table>
<cfelse>
	<span class="pagetitle">Cardinal Health Program User List</span>
	<br /><br />
	<span class="alert">You have no regions assigned to you.<br>Contact an administrative user for assistance.</span>
	<br /><br />
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->