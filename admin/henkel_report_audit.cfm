<cfsetting requesttimeout="300"> 

<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000103,true)>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "henkel_report_audit">
<cfinclude template="includes/header.cfm">

<!---<cfset request.henkel_ID = 1000000066>--->

<span class="pagetitle">Henkel Audit Report</span>
<br /><br />

<cfquery name="DeletedActive" datasource="#application.DS#">
	SELECT SUM(p.points) AS points
	FROM #application.database#.DELETED_awards_points p
	LEFT JOIN #application.database#.DELETED_program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
</cfquery>

<cfquery name="DeletedPending" datasource="#application.DS#">
	SELECT SUM(points) AS points
	FROM #application.database#.DELETED_henkel_hold_user
	WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
</cfquery>

<!---<cfquery name="PlusPoints" datasource="#application.DS#">
	SELECT p.points, p.created_datetime, p.notes
	FROM #application.database#.awards_points p
	LEFT JOIN #application.database#.program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	AND notes NOT LIKE 'Automatic awards from Henkel registration form%'
	AND notes NOT LIKE 'Approved in admin from Henkel registration form%'
	AND notes NOT LIKE 'Automatically awarded from Henkel%'
	ORDER BY created_datetime
</cfquery>--->

<cfquery name="April2009" datasource="#application.DS#">
	SELECT SUM(p.points) as points
	FROM #application.database#.awards_points p
	LEFT JOIN #application.database#.program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	AND p.created_datetime BETWEEN '2009-03-31' AND '2009-04-02'
	AND p.points <= 0
	AND p.notes = 'zeroed out to add correct total amount earned'
</cfquery>

<cfquery name="KamanTransfer" datasource="#application.DS#">
	SELECT SUM(p.points) as points
	FROM #application.database#.awards_points p
	LEFT JOIN #application.database#.program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	AND p.points <= 0
	AND p.notes LIKE '%to Kaman account'
</cfquery>

<cfquery name="DavidCarbone" datasource="#application.DS#">
	SELECT SUM(p.points) as points
	FROM #application.database#.awards_points p
	LEFT JOIN #application.database#.program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	AND p.points <= 0
	AND p.notes = 'No longer with company - sent by David Carbone'
</cfquery>

<cfquery name="Ungrouped" datasource="#application.DS#">
	SELECT SUM(p.points) AS points
	FROM #application.database#.awards_points p
	LEFT JOIN #application.database#.program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	AND p.points < 0
	AND p.notes != 'zeroed out to add correct total amount earned'
	AND p.notes != 'No longer with company - sent by David Carbone'
	AND p.notes NOT LIKE '%to Kaman account'
</cfquery>

<cfquery name="MinusPoints" datasource="#application.DS#">
	SELECT p.points, p.created_datetime as AdjustmentDate, p.notes, u.username
	FROM #application.database#.awards_points p
	LEFT JOIN #application.database#.program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	AND p.points < 0
	AND p.notes != 'zeroed out to add correct total amount earned'
	AND p.notes != 'No longer with company - sent by David Carbone'
	AND p.notes NOT LIKE '%to Kaman account'
	ORDER BY p.created_datetime
</cfquery>

<cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<tr class="contenthead">
			<td class="headertext">Timeframe</td>
			<td class="headertext">Activity</td>
			<td class="headertext">Points notes</td>
			<td class="headertext">Points removed</td>
		</tr>
<tr><td>Oct 2015</td><td>Bulk delete of active users</td><td></td><td align="right">#DeletedActive.points#</td></tr>
<tr><td>Oct 2015</td><td>Bulk delete of pending users</td><td></td><td align="right">#DeletedPending.points#</td></tr>
<tr><td>Nov 2013</td><td>Adjustment</td><td>No longer with company - sent by David Carbone</td><td align="right">#abs(DavidCarbone.points)#</td></tr>
<tr><td>Apr 2009</td><td>Adjustment</td><td>zeroed out to add correct total amount earned</td><td align="right">#abs(April2009.points)#</td></tr>

<tr><td>Ongoing</td><td>Transfer to Kaman</td><td>Transferred #### to Kaman account</td><td align="right">#abs(KamanTransfer.points)#</td></tr>

<tr><td></td><td>Sum of list below</td><td>See notes below</td><td align="right">#abs(Ungrouped.points)#</td></tr>

</table>
</cfoutput>

<br><br><br>
<p class="pageinstructions">The following have not yet been parsed:</p>
<cfdump var="#MinusPoints#">


<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->