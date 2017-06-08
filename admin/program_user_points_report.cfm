<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess("1000000036",true)>

<cfparam name="program_ID" default="">
<cfif NOT isNumeric(program_ID) OR program_ID LTE 0>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="include_inactive" default="0">
<cfparam name="include_nopoints" default="0">
<cfparam name="only_orphans" default="0">
<cfparam name="show_subs" default="0">

<cfif show_subs eq 0>
	<cfset only_orphans = 0>
</cfif>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->
<cfquery name="Subs" datasource="#application.DS#">
	SELECT COUNT(*) AS num
	FROM #application.database#.subprogram
	WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
</cfquery>
<cfset has_subs = Subs.num>
 
<cfquery name="SelectList" datasource="#application.DS#">
	SELECT U.ID, U.username, U.fname, U.lname, U.email, U.is_active
	FROM #application.database#.program_user U
	WHERE U.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
	<cfif NOT include_inactive>
		AND U.is_active = 1
	</cfif>
	ORDER BY U.lname, U.fname
</cfquery>

<cfset TotalOutstanding = 0>
<cfset cur_row = 0>

<cfset leftnavon = "program_user_points_report">
<cfset request.main_width = 900>
<cfinclude template="includes/header.cfm">
<cfset sub_points = StructNew()>
<cfset subpts_total = 0>
<span class="pagetitle">Outstanding Program User Points</span>
<br /><br />

<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="pageinstructions" height="35px;">
		<td colspan="2"><span class="pageinstructions">Choose a different <a href="pickprogram.cfm?n=program_user_points_report">Award Program</a></span></td>
		<td colspan="<cfif has_subs and show_subs>3<cfelse>2</cfif>" align="right"><span class="pageinstructions">Include inactive users: <input type="checkbox" name="x" value="1" <cfif include_inactive>checked</cfif> onChange="javascript:window.location='program_user_points_report.cfm?<cfoutput>program_ID=#program_ID#&show_subs=#show_subs#&only_orphans=#only_orphans#&include_nopoints=#include_nopoints#&include_inactive=#abs(include_inactive-1)#</cfoutput>'"></td>
	</tr>
	<tr class="pageinstructions" height="35px;">
		<td colspan="2"></td>
		<td colspan="<cfif has_subs and show_subs>3<cfelse>2</cfif>" align="right"><span class="pageinstructions">Include users with no points: <input type="checkbox" name="x" value="1" <cfif include_nopoints>checked</cfif> onChange="javascript:window.location='program_user_points_report.cfm?<cfoutput>program_ID=#program_ID#&show_subs=#show_subs#&only_orphans=#only_orphans#&include_inactive=#include_inactive#&include_nopoints=#abs(include_nopoints-1)#</cfoutput>'"></td>
	</tr>
	<!--- header row --->
	<tr class="content2">
		<td colspan="2"><span class="headertext">Program: <span class="selecteditem"><cfoutput>#FLITC_GetProgramName(program_ID)#</cfoutput></span></span></td>
		<td colspan="<cfoutput>#2+show_subs#</cfoutput>" align="right">
			<cfif has_subs>
				<span class="pageinstructions">
					<input type="checkbox" name="x" value="1" <cfif only_orphans eq "1">checked</cfif> onChange="javascript:window.location='program_user_points_report.cfm?<cfoutput>program_ID=#program_ID#&show_subs=1&only_orphans=#abs(only_orphans-1)#&include_inactive=#include_inactive#&include_nopoints=#include_nopoints#</cfoutput>'">
					Show only user points where there is no subprogram<br>
					<a href="<cfoutput>program_user_points_report.cfm?program_ID=#program_ID#&show_subs=#abs(show_subs-1)#&only_orphans=#only_orphans#&include_inactive=#include_inactive#&include_nopoints=#include_nopoints#</cfoutput>"><cfif show_subs>Hide<cfelse>Show</cfif></a> subprogram column
				</span>
			</cfif>
		</td>
	</tr>
	<tr class="contenthead">
		<td class="headertext">Username</td>
		<td class="headertext">Name</td>
		<td class="headertext">Email</td>
		<td class="headertext">Points</td>
		<cfif has_subs and show_subs><td class="headertext">Subprogram</td></cfif>
	</tr>
	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
			<td colspan="100%" align="center"><span class="alert"><br>There are no users in this program!<br><br></span></td>
		</tr>
	<cfelse>
		<!--- display found records --->
		<cfoutput query="SelectList">
			<cfset ProgramUserInfo(SelectList.ID)>
			<cfif user_totalpoints GT 0 OR include_nopoints>
				<cfset show_it = true>
				<cfif has_subs and show_subs>
					<cfquery name="SubPoints" datasource="#application.DS#">
						SELECT SP.subprogram_name, SUM(P.subpoints) AS points, P.user_ID, P.subprogram_ID
						FROM #application.database#.subprogram_points P
						LEFT JOIN #application.database#.subprogram SP ON SP.ID = P.subprogram_ID
						WHERE P.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
						GROUP BY P.user_id, P.subprogram_ID
						HAVING points != 0
					</cfquery>
					<cfif only_orphans and SubPoints.recordcount gt 0>
						<cfset show_it = false>
					</cfif>
				</cfif>
				<cfif show_it>
					<cfset cur_row = cur_row + 1>
					<cfset TotalOutstanding = TotalOutstanding + user_totalpoints>
					<tr class="<cfif SelectList.is_active>content<cfif cur_row MOD 2>2</cfif><cfelse>inactivebg</cfif>">
						<td>#SelectList.username#</td>
						<td>#SelectList.lname#, #SelectList.fname#</td>
						<td>#SelectList.email#</td>
						<td align="right">#user_totalpoints#</td>
						<cfif has_subs and show_subs>
						<td>
							<cfif SubPoints.recordcount gt 0>
								<cfloop query="SubPoints">
									#Replace(SubPoints.subprogram_name,' ','&nbsp;','ALL')#:&nbsp;#SubPoints.points#<br>
									<cfif not StructKeyExists(sub_points,subprogram_ID)>
										<cfset sub_points[subprogram_ID] = StructNew()>
										<cfset sub_points[subprogram_ID]["points"] = 0>
										<cfset sub_points[subprogram_ID]["name"] = SubPoints.subprogram_name>
									</cfif>
									<cfset sub_points[subprogram_ID]["points"] = sub_points[subprogram_ID]["points"] + SubPoints.points>
									<cfset subpts_total = subpts_total + SubPoints.points>
								</cfloop>
							<cfelse>
								---
							</cfif>
						</td>
						</cfif>
					</tr>
				</cfif>
			</cfif>
		</cfoutput>
	</cfif>
	<cfif TotalOutstanding EQ 0>
		<tr class="content2">
			<td colspan="100%" align="center"><span class="alert"><br>Congratulations! There are no outstanding points!<br><br></span></td>
		</tr>
	<cfelse>
		<tr class="content2">
			<td colspan="100%" align="right">Total Outstanding Points in <cfoutput>#FLITC_GetProgramName(program_ID)#:&nbsp;&nbsp;&nbsp;&nbsp;#TotalOutstanding#</cfoutput></td>
		</tr>
	</cfif>
</table>
<cfif has_subs and show_subs>
<cfoutput>
<br>
Total Subpoints: #subpts_total#<br>
<br>
<cfloop collection="#sub_points#" item="x">
#sub_points[x]["name"]# - #sub_points[x]["points"]#
<br>
</cfloop>
</cfoutput>
</cfif>
<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->

