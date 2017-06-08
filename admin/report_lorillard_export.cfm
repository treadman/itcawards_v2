<cfsetting enablecfoutputonly="yes" showdebugoutput="no">

<!--- ***************** --->
<!--- page variables    --->
<!--- ***************** --->
<cfset TC = Chr(9)> <!--- Tab Char --->
<cfset NL = Chr(13) & Chr(10)> <!--- New Line --->
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">

<cfcontent type="application/msexcel">
<cfheader name="Content-Disposition" value="filename=lorillard_reporti.xls">

<cfquery name="ReportLorillardRedeemed" datasource="#application.DS#">
	SELECT Date_Format(o.created_datetime,'%Y%m%d') AS created_datetime, o.points_used, p.username, p.lname 
	FROM #application.database#.order_info o
	JOIN #application.database#.program_user p ON o.created_user_ID = p.ID
	WHERE o.program_ID = '1000000035'
		AND o.is_valid = '1'
		AND o.points_used > 0 
		<cfif formatFromDate NEQ "">
			AND o.created_datetime >= '#formatFromDate#' 
		</cfif>	
		<cfif formatToDate NEQ "">
			AND o.created_datetime <= '#formatToDate#' 
		</cfif>	
	ORDER BY o.created_datetime ASC 
</cfquery>
	
<cfquery name="GetMultiplier" datasource="#application.DS#">
	SELECT points_multiplier 
	FROM #application.database#.program
	WHERE ID = '1000000035'
</cfquery>
<cfset multiplier = GetMultiplier.points_multiplier>

<cfoutput>PIN#TC#Points Redeemed#TC#Points Redeemed Date#TC#Last Name#NL#<cfloop query="ReportLorillardRedeemed">#username##TC##points_used * multiplier##TC##created_datetime##TC##lname##NL#</cfloop></cfoutput>

