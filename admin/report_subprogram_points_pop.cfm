<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess("1000000081",true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="user_ID" default="">
<cfparam name="delete" default="">
<cfparam name="program_ID" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif delete NEQ ''>
	<cfquery name="DeleteLineItem" datasource="#application.DS#">
		DELETE FROM #application.database#.subprogram_points
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#" maxlength="10">
	</cfquery>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfinclude template="includes/header_lite.cfm">

<table cellpadding="5" cellspacing="0" width="800" border="0">

<tr>
<td valign="top" width="800">
<br />

<cfquery name="SelectUserInfo" datasource="#application.DS#">
	SELECT username, fname, lname 
	FROM #application.database#.program_user
	WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#">
		AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
</cfquery>
<cfset username = HTMLEditFormat(SelectUserInfo.username)>
<cfset fname = HTMLEditFormat(SelectUserInfo.fname)>
<cfset lname = HTMLEditFormat(SelectUserInfo.lname)>

	<cfoutput>

<cfif SelectUserInfo.RecordCount EQ 0>

The user could not be found.

<cfelse>

<span class="pagetitle">Point History For</span> <span class="selecteditem">#fname# #lname# (#username#)</span>
<br />
<br />

	<cfquery name="GetPointHistory" datasource="#application.DS#">
		SELECT created_datetime, created_user_ID, points AS thispoints, IFNULL(notes,'(no note)') AS thisnote, 000 AS order_number, IF(is_defered = 1, 'true', 'false') AS thisdef, ID AS point_ID 
		FROM #application.database#.awards_points
		WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">
		
		UNION
		
		SELECT created_datetime, created_user_ID, points_used AS thispoints, '' AS thisnote, order_number AS order_number, 'false' AS thisdef, 444 AS point_ID
		FROM #application.database#.order_info
		WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10"> 
			AND is_valid = 1
		ORDER BY created_datetime
	</cfquery>
	
	<cfquery name="FindAllSubprograms" datasource="#application.DS#">
		SELECT ID AS subprogram_ID, subprogram_name, is_active
		FROM #application.database#.subprogram
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		ORDER BY sortorder, ID
	</cfquery>
	
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<tr class="selectedbgcolor">
	<td colspan="4" class="headertext">Actual Award Points</td>
	</tr>
	
	<tr class="contenthead">
	<td class="headertext">Date&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<td class="headertext">Points&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<td class="headertext" align="center">&nbsp;</td>
	<td class="headertext" width="100%">Order Number/Inventory Note</td>
	</tr>
	
	<cfloop query="GetPointHistory">
	<tr class="content">
	<td>#FLGen_DateTimeToDisplay(created_datetime)#</td>
	<td align="right"><cfif thisdef><span class="sub">[defered]</span></cfif><cfif order_number NEQ 000>-</cfif> #thispoints#</td>
	<td class="headertext" align="center">&nbsp;</td>
	<td><cfif order_number NEQ 000>Order Number: #order_number#<cfelse>#thisnote# <span class="sub">Entered by #FLGen_GetAdminName(created_user_ID)#</span></cfif></td>
	</tr>
	</cfloop>
	
	<tr class="content">
	<td align="right" class="headertext" colspan="2">#ProgramUserInfo(user_ID)##user_totalpoints#</td>
	<td class="headertext">&nbsp;</td>
	<td class="headertext">TOTAL POINTS</td>
	</tr>
	
	<cfif user_deferedpoints GT 0>
	<tr class="content">
	<td align="right" colspan="2"><span class="sub">#user_deferedpoints#</span></td>
	<td class="headertext">&nbsp;</td>
	<td><span class="sub">Deferred Points</span></td>
	</tr>
	</cfif>

	<tr><td colspan="4">&nbsp;</td></tr>
	<tr><td colspan="4"><span class="alert">The amounts below are ONLY used to determine billing and email blasts.  They are NOT used during the ordering process.</span></td></tr>

	<cfloop query="FindAllSubprograms">
	
		<cfquery name="FindSubprogramPoints" datasource="#application.DS#">
			SELECT IFNULL(SUM(subpoints),0) AS subpoints
			FROM #application.database#.subprogram_points
			WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#"> 
				AND subprogram_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#subprogram_ID#">
		</cfquery>
		
		<cfquery name="GetSubpointHistory" datasource="#application.DS#">
			SELECT ID AS subpoint_ID, created_datetime, created_user_ID, subpoints 
			FROM #application.database#.subprogram_points
			WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#">
				AND subprogram_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#subprogram_ID#">
			ORDER BY created_datetime
		</cfquery>
		
		<cfif GetSubpointHistory.RecordCount GT 0>
	
	<tr><td colspan="4">&nbsp;</td></tr>

	<tr bgcolor="##D6EFF7">
	<td colspan="3" class="headertext">#subprogram_name# Points</td>
	<td align="right" class="headertext"><cfif NOT is_active>NOT ACTIVE</cfif></td>
	</tr>
	
	<tr class="contenthead">
	<td class="headertext">Date&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<td class="headertext">Points&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<!---  --->
	<td class="headertext" align="center"><span class="tooltip" title="Click the X to remove that line item.">?</span></td>
	<!---  --->
	<td class="headertext" width="100%">Order Number/Inventory Note</td>
	</tr>
	
			<cfloop query="GetSubpointHistory">
		<tr class="content">
		<td>#FLGen_DateTimeToDisplay(created_datetime)#</td>
		<td align="right">#subpoints#</td>
		<td class="headertext" align="center"><cfif subpoints LTE 0><a href="#CurrentPage#?delete=#subpoint_ID#&user_ID=#user_ID#&program_ID=#program_ID#" onclick="return confirm('Are you sure you want to delete this line item?  There is NO UNDO.')">X</a><cfelse>&nbsp;</cfif></td>
		<td><span class="sub">Entered by #FLGen_GetAdminName(created_user_ID)#</span></td>
		</tr>
			</cfloop>
				
		<tr class="content">
		<td align="right" class="headertext" colspan="2">#FindSubprogramPoints.subpoints#</td>
		<td class="headertext">&nbsp;</td>
		<td class="headertext">TOTAL SUBPOINTS</td>
		</tr>
			
		</cfif>

	</cfloop>
	
	</table>

</cfif>

	</cfoutput>

</td>
</tr>

</table>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->