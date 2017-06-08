<cfsetting requesttimeout="1500">
<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000103,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfset SubTotalPoints = 0>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "henkel_report_points">
<cfinclude template="includes/header.cfm">

<cfparam name="show_active" default="0">
<cfparam name="show_pending" default="0">
<cfparam name="show_individual" default="0">
<cfparam name="show_branch" default="0">
<cfparam name="show_branchHQ" default="0">
<cfparam name="include_unreg" default="0">

<cfif NOT isDefined("submit")>
	<cfset show_active = 1>
	<cfset show_pending = 1>
	<cfset show_individual = 1>
	<cfset show_branch = 1>
	<cfset show_branchHQ = 0>
	<cfset include_unreg = 1>
</cfif>

<cfset today = FLGen_DateTimeToDisplay(NOW())>
<cfif Day(today) NEQ DaysInMonth(today)>
	<cfset today = DateAdd('m',-1,today)>
	<cfset today = FLGen_DateTimeToDisplay(CreateDate(Year(today),Month(today),DaysInMonth(today)))>
</cfif>

<cfparam name="ToDate" default="#DateFormat(today, "mm/dd/yyyy")#">
<cfparam name="formatToDate" default="">

<cfif ToDate NEQ "">
	<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
	<cfset ToDate = FLGen_DateTimeToDisplay(ToDate)>
<cfelse>
	<cfset ToDate = FLGen_DateTimeToDisplay()>
	<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
</cfif>

<cfparam name="report_type" default="summary">

<span class="pagetitle">Henkel Points Report</span>
<br /><br />

<cfoutput>
<form method="post" action="#CurrentPage#" name="addedit">
	<table cellpadding="5" cellspacing="1" border="0">
		<tr class="BGlight1"><td align="right" nowrap="nowrap"></td><td>
		<input type="checkbox" name="include_unreg" value="1" <cfif include_unreg eq 1>checked</cfif>> Show active users that did not register<br><br>
		<input type="checkbox" name="show_active" value="1" <cfif show_active eq 1>checked</cfif>> Show Active Users<br>
		<input type="checkbox" name="show_pending" value="1" <cfif show_pending eq 1>checked</cfif>> Show Pending Users<br><br>
		<input type="checkbox" name="show_individual" value="1" <cfif show_individual eq 1>checked</cfif>> Show Individual Registrations<br>
		<input type="checkbox" name="show_branch" value="1" <cfif show_branch eq 1>checked</cfif>> Show Branch Registrations<br>
		<input type="checkbox" name="show_branchHQ" value="1" <cfif show_branchHQ eq 1>checked</cfif>> Show Branch HQ Registrations<br>
		</td></tr>
		<tr class="BGlight1" height="30px;">
			<td colspan="2" align="center">
				<input type="radio" name="report_type" value="summary" <cfif report_type eq "summary">checked</cfif>> Summary Only
				&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="report_type" value="details" <cfif report_type eq "details">checked</cfif>> Show Details
			</td>
		</tr>
		<tr>
		<td class="BGlight1" align="right">To Date:</td>
		<td class="BGlight1" align="left"><input type="text" name="ToDate" value="#ToDate#" size="12"></td>
		</tr>
		<tr class="BGlight1"><td colspan="2" align="center"><input type="submit" name="submit" value="Submit" style="cursor:hand;"></td></tr>
	</table>
</form>
</cfoutput>

<cfif isDefined("form.submit")>
	<cfif (show_active OR show_pending) AND (show_individual OR show_branch OR show_branchHQ)>
		<cfquery name="SelectList" datasource="#application.DS#" result="result">
			<cfif show_individual OR show_branch>
				(SELECT CONCAT(HR.lname, ", ", HR.fname) AS fullname, IDH, PU.ID, HR.registration_type AS registration_type, IF (PU.ID > 0, "Active", "Pending") AS CurrentStatus,
					IFNULL((SELECT SUM(points)
						FROM #application.database#.awards_points AP
						WHERE AP.user_ID = PU.ID),10) AS AwardedPoints
				FROM #application.database#.henkel_register HR
				LEFT JOIN #application.database#.program_user PU ON PU.ID = HR.program_user_ID
				WHERE HR.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
				AND HR.created_datetime <= <cfqueryparam value="#formatToDate#">
					AND HR.registration_type IN (
						<cfif show_individual>
							'Individual'<cfif show_branch>,</cfif>
						</cfif>
						<cfif show_branch>
							'Branch'
						</cfif>
					)
				<cfif show_active XOR show_pending>
					AND PU.ID IS <cfif show_active>NOT</cfif> NULL
				</cfif>
				)
				<cfif include_unreg>
				UNION
				(
		SELECT CONCAT(u.lname, ", ", u.fname) AS fullname, IDH, u.ID, u.registration_type AS registration_type, "Active*" AS CurrentStatus,
			IFNULL(sum(p.points),0) as AwardedPoints
		FROM #application.database#.program_user u
		LEFT JOIN #application.database#.awards_points p ON p.user_ID = u.ID
		LEFT JOIN #application.database#.henkel_register hr ON hr.program_user_ID = u.ID
		LEFT JOIN #application.database#.henkel_register_branch hb ON hb.program_user_ID = u.ID
		WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
		AND u.is_active = 1
		AND p.created_datetime <= <cfqueryparam value="#formatToDate#">
		<!--- AND u.ID NOT IN (
			SELECT program_user_ID FROM #application.database#.henkel_register
		)
		AND u.ID NOT IN (
			SELECT program_user_ID FROM #application.database#.henkel_register_branch
		)--->
		<!--- Got rid of the two subqueries above --->
		AND hr.program_user_ID is null
		AND hb.program_user_ID is null

		GROUP BY u.ID
				)
				</cfif>
				<cfif show_branchHQ>
					UNION
				</cfif>
			</cfif>
			<cfif show_branchHQ>
				(SELECT CONCAT(HR.branch_contact_lname, ", ", HR.branch_contact_fname) AS fullname, IDH, PU.ID, "BranchHQ" AS registration_type, IF (PU.ID > 0, "Active", "Pending") AS CurrentStatus,
					IFNULL((SELECT SUM(points)
						FROM #application.database#.awards_points AP
						WHERE AP.user_ID = PU.ID),0) AS AwardedPoints
				FROM #application.database#.henkel_register_branch HR
				LEFT JOIN #application.database#.program_user PU ON PU.ID = HR.program_user_ID
				WHERE HR.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
				AND HR.created_datetime <= <cfqueryparam value="#formatToDate#">
				<cfif show_active XOR show_pending>
					AND PU.ID IS <cfif show_active>NOT</cfif> NULL
				</cfif>
				)
			</cfif>
			ORDER BY registration_type, CurrentStatus, fullname
		</cfquery>
		<!---<cfdump var="#result#">--->
	</cfif>
	<cfquery name="HoldBucketUsers" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_hold_user
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND created_datetime <= <cfqueryparam value="#formatToDate#">
	</cfquery>

	<cfquery name="HoldBucket" datasource="#application.DS#">
		SELECT source_import, SUM(points) AS Total_Points, COUNT(*) AS Total_Users
		FROM #application.database#.henkel_hold_user
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND created_datetime <= <cfqueryparam value="#formatToDate#">
		GROUP BY source_import WITH ROLLUP
	</cfquery>
	<cfquery name="PointsRedeemed" datasource="#application.DS#">
		SELECT SUM(points_used) AS Total
		FROM #application.database#.order_info
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND created_datetime <= <cfqueryparam value="#formatToDate#">
		GROUP BY program_ID
	</cfquery>
	<cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<!--- header row --->
		<cfif report_type eq "details">
			<tr class="contenthead">
				<td class="headertext">Name</td>
				<td class="headertext">IDH</td>
				<td class="headertext">Registration</td>
				<td class="headertext" align="right">Points</td>
				<td class="headertext" align="right">Status</td>
			</tr>
		</cfif>
		<cfset Num_Individual = 0>
		<cfset Num_Branch = 0>
		<cfset Num_HQ = 0>
		<cfset Num_Other = 0>
		<cfset Pts_Individual = 0>
		<cfset Pts_Branch = 0>
		<cfset Pts_HQ = 0>
		<cfset Pts_Other = 0>
		<cfset Other_Names = "">
		<cfset Total_found = 0>
		<cfif isdefined("SelectList")>
			<cfset Total_found = SelectList.recordcount>
			<!--- display found records --->
			<cfset LastIDH = "">
			<cfset DisplayedRow = 0>
			<cfloop query="SelectList">
 				<cfif report_type eq "details">
					<tr class="#Iif(((DisplayedRow MOD 2) is 0),de('content2'),de('content'))#">
						<td>#fullname#</td>
						<td>#IDH#</td>
						<td>#registration_type#</td>
						<td align="right">#AwardedPoints#</td>
						<td align="right">#CurrentStatus#</td>
					</tr>
					<cfset DisplayedRow = DisplayedRow + 1>
				</cfif>
<!---
				<cfset this_points = 10>
				<cfif AwardedPoints GT 0>
					<cfset this_points = AwardedPoints>
				</cfif>
--->
				<cfset this_points = 0>
				<cfif AwardedPoints GT 0>
					<cfset this_points = AwardedPoints>
				<cfelseif registration_type neq "BranchHQ">
					<cfset this_points = 10>
				</cfif>
				<cfset SubTotalPoints = SubTotalPoints + this_points>
				<cfswitch expression="#registration_type#">
					<cfcase value="Individual">
						<cfset Num_Individual = Num_Individual + 1>
						<cfset Pts_Individual = Pts_Individual + this_points>
					</cfcase>
					<cfcase value="Branch">
						<cfset Num_Branch = Num_Branch + 1>
						<cfset Pts_Branch = Pts_Branch + this_points>
					</cfcase>
					<cfcase value="BranchHQ">
						<cfset Num_HQ = Num_HQ + 1>
						<cfset Pts_HQ = Pts_HQ + this_points>
					</cfcase>
				</cfswitch>
			</cfloop>
		</cfif>
		<tr height="30px;"><td></td></tr>
		<cfif show_individual OR show_branch OR show_branchHQ>
		<tr class="contenthead">
			<td class="headertext" colspan="2">Registered Users</td>
			<td class="headertext" align="right">Users</td>
			<td class="headertext" align="right">Points</td>
		</tr>
		<cfset DisplayedRow = 0>
		<cfif show_individual>
		<tr class="#Iif(((DisplayedRow MOD 2) is 0),de('content2'),de('content'))#">
			<td colspan="2">Individual</td>
			<td align="right">#Num_Individual#</td>
			<td align="right">#Pts_Individual#</td>
		</tr>
		<cfset DisplayedRow = DisplayedRow + 1>
		</cfif>
		<cfif show_branch>
		<tr class="#Iif(((DisplayedRow MOD 2) is 0),de('content2'),de('content'))#">
			<td colspan="2">Branch</td>
			<td align="right">#Num_Branch#</td>
			<td align="right">#Pts_Branch#</td>
		</tr>
		<cfset DisplayedRow = DisplayedRow + 1>
		</cfif>
		<cfif show_branchHQ>
		<tr class="#Iif(((DisplayedRow MOD 2) is 0),de('content2'),de('content'))#">
			<td colspan="2">Branch HQ</td>
			<td align="right">#Num_HQ#</td>
			<td align="right">#Pts_HQ#</td>
		</tr>
		<cfset DisplayedRow = DisplayedRow + 1>
		</cfif>
		<tr>
			<td class="totals" align="right" colspan="2"><strong>Totals</strong></td>
			<td class="totals" align="right">#Total_found#</td>
			<td class="totals" align="right">#SubTotalPoints#</td>
		</tr>
		</cfif>
		<tr height="30px;"><td></td></tr>
		<tr class="contenthead">
			<td class="headertext" colspan="2">Program Name</td>
			<td class="headertext" align="right">Users</td>
			<td class="headertext" align="right">Points Pending</td>
		</tr>
		<cfset DisplayedRow = 1>
		<cfloop query="HoldBucket">
			<cfset DisplayedRow = DisplayedRow + 1>
			<cfif source_import GT "">
				<tr class="#Iif(((DisplayedRow MOD 2) is 0),de('content2'),de('content'))#">
					<td colspan="2">#source_import#</td>
					<td align="right">#Total_Users#</td>
					<td align="right">#Total_Points#</td>
				</tr>
			<cfelse>
				<tr>
					<td class="totals" colspan="2" align="right"><strong>Totals</strong></td>
					<td class="totals" align="right">#Total_Users#</td>
					<td class="totals" align="right">#Total_Points#</td>
				</tr>
			</cfif>
		</cfloop>
		<tr height="30px;"><td></td></tr>
		<tr class="contenthead">
			<td class="headertext" colspan="2">Unregistered Users</td>
			<td class="headertext" align="right">Users</td>
			<td class="headertext" align="right">Points</td>
		</tr>
		<tr class="content2">
			<td colspan="2">&nbsp;</td>
			<td align="right">#HoldBucketUsers.RecordCount#</td>
			<td align="right">#HoldBucketUsers.RecordCount*10#</td>
		</tr>
		<tr>
			<td class="totals" colspan="2">&nbsp;</td>
			<td class="totals" align="right">&nbsp;</td>
			<td class="totals" align="right">&nbsp;</td>
		</tr>
		<tr height="30px;"><td></td></tr>
		<tr class="contenthead">
			<td class="headertext" colspan="3">Points Redeemed</td>
			<td class="headertext" align="right">Points</td>
		</tr>
		<tr class="content2">
			<td colspan="3">&nbsp;</td>
			<td align="right">#PointsRedeemed.Total#</td>
		</tr>
		<tr>
			<td class="totals" colspan="2">&nbsp;</td>
			<td class="totals" align="right">&nbsp;</td>
			<td class="totals" align="right">&nbsp;</td>
		</tr>
	</table>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->