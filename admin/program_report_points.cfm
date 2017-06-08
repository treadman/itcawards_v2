<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000062,true)>

<cfset thisProgramID = 1000000009>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "program_report">
<cfinclude template="includes/header.cfm">

<cfquery name="SelectList" datasource="#application.DS#">
	SELECT u.ID AS program_user_ID, u.fname, u.lname
	FROM #application.database#.program_user u
	WHERE u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisProgramID#">
	ORDER BY u.lname
</cfquery>
<span class="pagetitle">Report</span>
<br />
<table cellpadding="5" cellspacing="1" border="0">
	<cfoutput query="SelectList">
		<cfquery name="GetPointHistory" datasource="#application.DS#">
			SELECT created_datetime, points AS thispoints, notes AS thisnote, 000 AS order_number, IF(is_defered = 1, 'true', 'false') AS thisdef
			FROM #application.database#.awards_points
			WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_user_ID#" maxlength="10">
	
			UNION
	
			SELECT created_datetime, ((points_used * credit_multiplier)/points_multiplier) AS thispoints, '' AS thisnote, order_number AS order_number, 'false' AS thisdef
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
</table>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->