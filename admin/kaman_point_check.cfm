<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000081,true)>
<cfset program_ID = 1000000010>
<cfif NOT isNumeric(program_ID) OR program_ID LTE 0>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->
 
<cfquery name="SelectList" datasource="#application.DS#">
	SELECT U.ID, U.username, U.fname, U.lname, U.email
	FROM #application.database#.program_user U
	WHERE U.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
	AND U.is_active = 1
	ORDER BY U.lname, U.fname
</cfquery>

<cfset TotalOutstanding = 0>
<cfset TotalDefered = 0>
<cfset cur_row = 0>

<cfset leftnavon = "kaman_point_check">
<cfset request.main_width = 900>
<cfinclude template="includes/header.cfm">
<cfset sub_points = StructNew()>
<cfset subpts_total = 0>
<cfset diff_total = 0>
<cfset curr_orders = 0>
<span class="pagetitle">Kaman Subprogram Points Check</span>
<br /><br />

<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<!--- header row --->
	<tr class="content2">
		<td colspan="100%"><span class="headertext">Program: <span class="selecteditem"><cfoutput>#FLITC_GetProgramName(program_ID)#</cfoutput></span></span></td>
	</tr>
	<tr class="contenthead">
		<td class="headertext">Username</td>
		<td class="headertext">Name</td>
		<td class="headertext">Email</td>
		<td class="headertext">Points</td>
		<td class="headertext">Subprogram</td>
	</tr>
	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
			<td colspan="100%" align="center"><span class="alert"><br>There are no users in this program!<br><br></span></td>
		</tr>
	<cfelse>
		<!--- display found records --->
		<cfoutput query="SelectList">
			<cfset this_user_id = SelectList.ID>
			<cfset this_output = "">
			<cfset ProgramUserInfo(this_user_id)>
			<cfset this_points = user_totalpoints>
			<cfquery name="GetOrders" datasource="#application.DS#">
				SELECT created_datetime, ((points_used * credit_multiplier)/points_multiplier) AS points
				FROM #application.database#.order_info
				WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#" maxlength="10">
				AND is_valid = 1
				ORDER BY created_datetime
			</cfquery>
			<cfif GetOrders.recordcount GT 0>
				<cfloop query="GetOrders">
					<cfset this_points = this_points + GetOrders.points>
					<cfset curr_orders = curr_orders + GetOrders.points>
				</cfloop>
			</cfif>
			<cfset TotalOutstanding = TotalOutstanding + user_totalpoints>
			<cfset TotalDefered = TotalDefered + user_deferedpoints>
			<cfquery name="SubPoints" datasource="#application.DS#">
				SELECT SP.subprogram_name, SUM(P.subpoints) AS points, P.user_ID, P.subprogram_ID
				FROM #application.database#.subprogram_points P
				LEFT JOIN #application.database#.subprogram SP ON SP.ID = P.subprogram_ID
				WHERE P.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#">
				GROUP BY P.user_id, P.subprogram_ID
				HAVING points != 0
			</cfquery>
			<!--- cfif SelectList.lname eq "Anderson" and SelectList.fname eq "Bill"><tr><td colspan="100%"><cfdump var="#SubPoints#"></td></tr></cfif --->
			<cfif SubPoints.recordcount gt 0>
				<cfsavecontent variable="this_output">
					<cfloop query="SubPoints">
						#Replace(SubPoints.subprogram_name,' ','&nbsp;','ALL')#:&nbsp;#SubPoints.points#<br>
						<cfif not StructKeyExists(sub_points,subprogram_ID)>
							<cfset sub_points[subprogram_ID] = StructNew()>
							<cfset sub_points[subprogram_ID]["points"] = 0>
							<cfset sub_points[subprogram_ID]["name"] = SubPoints.subprogram_name>
						</cfif>
						<cfset sub_points[subprogram_ID]["points"] = sub_points[subprogram_ID]["points"] + SubPoints.points>
						<cfset subpts_total = subpts_total + SubPoints.points>
						<cfset this_points = this_points - SubPoints.points>
					</cfloop>
				</cfsavecontent>
			</cfif>
			<cfif this_points neq 0>
				<cfset diff_total = diff_total + this_points>
				<cfset cur_row = cur_row + 1>
				<tr class="<cfif cur_row MOD 2>content2<cfelse>content</cfif>">
					<td><!--- #this_user_id# - --->#SelectList.username#</td>
					<td>#SelectList.lname#, #SelectList.fname#</td>
					<td>#SelectList.email#</td>
					<td align="right">#user_totalpoints#</td>
					<td>#this_output#</td>
				</tr>
			</cfif>
		</cfoutput>
	</cfif>
	<!---
		<tr class="content2">
			<td colspan="100%" align="right">Total Deferred Points&nbsp; <cfoutput>#TotalDefered#</cfoutput></td>
		</tr>
		<tr class="content2">
			<td colspan="100%" align="right">Grand Total&nbsp; <cfoutput>#TotalOutstanding+TotalDefered#</cfoutput></td>
		</tr>
	--->

<tr><td><br></td></tr>
<tr>
	<td align="right"><cfoutput>#TotalOutstanding#</cfoutput></td><td colspan="4">Total Outstanding Award Points</td>
</tr>
<tr>
	<td align="right"><cfoutput>#curr_orders#</cfoutput></td><td colspan="4">Order points</td>
</tr>
<tr>
	<td align="right"><cfoutput>#diff_total#</cfoutput></td><td colspan="4">Difference in balances (in the above user accounts)</td>
</tr>
<tr>
	<td align="right"><cfoutput>#subpts_total#</cfoutput></td><td colspan="4">Total Outstanding Subprogram Points</td>
</tr>
<tr><td colspan="5"><hr></td></tr>
<tr><td colspan="5">Breakdown of outstanding subprogram points:<br><br></td></tr>
<cfloop collection="#sub_points#" item="x">
	<tr>
		<td align="right"><cfoutput>#sub_points[x]["points"]#</cfoutput></td><td colspan="4"><cfoutput>#sub_points[x]["name"]#</cfoutput></td>
	</tr>
</cfloop>
</table>
<br><hr><span class="sub">end</span>


<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->

