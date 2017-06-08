<!---<cfabort showerror="z_tracy.cfm is not available">--->
<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<cfparam name="program_ID" default="1000000066">
 
<cfquery name="SelectList" datasource="#application.DS#">
	SELECT U.ID, U.idh, D.company_name AS distributor, U.username, U.fname, U.lname, U.email
	FROM #application.database#.program_user U
	LEFT JOIN #application.database#.henkel_distributor D ON D.idh = U.idh
	WHERE U.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
	AND U.is_active = 1
	ORDER BY D.company_name, U.idh, U.lname, U.fname
</cfquery>
<cfset QueryAddRow(SelectList)>
<cfset QuerySetCell(SelectList,"distributor","last_time")>
<!---<cfdump var="#SelectList#" abort="true" >--->

<cfset dist_awarded = 0>
<cfset dist_redeemed = 0>
<cfset sub_awarded = 0>
<cfset sub_redeemed = 0>
<cfset grand_awarded = 0>
<cfset grand_redeemed = 0>

<cfset this_dist = "first_time">
<cfset this_comp = "first_time">

<cfset year_list = "2013,2014,2015">

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr class="contenthead">
		<td>IDH Number</td>
		<td>Company Name</td>
		<!---<td>Username</td>
		<td>Name</td>
		<td>Email</td>--->
		<td align="right">Awarded</td>
		<td align="right">Redeemed</td>
	</tr>
<cfloop list="#year_list#" index="this_year">
	<tr>
		<td><cfoutput>#this_year#</cfoutput></td>
	</tr>
	<!--- header row --->
	<!--- display found records --->
	<cfoutput query="SelectList">
		<cfif this_dist NEQ "#SelectList.idh#-#SelectList.distributor#">
			<cfif this_dist NEQ "first_time" AND dist_awarded + dist_redeemed GT 0>
				<tr>
					<td align="right">#ListFirst(this_dist,"-")#</td>
					<td><cfif right(this_dist,1) NEQ "-">#ListLast(this_dist,"-")#</cfif></td>
					<td align="right">#dist_awarded#</td>
					<td align="right">#dist_redeemed#</td>
				</tr>
				<cfset dist_awarded = 0>
				<cfset dist_redeemed = 0>
			</cfif>
			<!---<tr>
				<td>#SelectList.idh# - #SelectList.distributor#</td>
			</tr>--->
		</cfif>
		<cfif this_comp NEQ SelectList.distributor>
			<cfif this_comp NEQ "first_time" AND sub_awarded + sub_redeemed GT 0>
				<tr>
					<td align="right"></td>
					<td align="right">Total for: #this_comp#<cfif this_comp EQ "">[blank]</cfif></td>
					<td align="right">#sub_awarded#</td>
					<td align="right">#sub_redeemed#</td>
				</tr>
				<tr><td></td></tr>
				<cfset sub_awarded = 0>
				<cfset sub_redeemed = 0>
			</cfif>
			<!---<tr>
				<td>#SelectList.idh# - #SelectList.distributor#</td>
			</tr>--->
		</cfif>
		<cfif SelectList.distributor NEQ "last_time">
		<cfquery name="PosPoints" datasource="#application.DS#">
			SELECT IFNULL(SUM(points),0) AS pos_pt
			FROM #application.database#.awards_points
			WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
			AND is_defered = 0
			AND YEAR(created_datetime) = '#this_year#'
		</cfquery>
		<!--- look in the order database for orders/points_used --->
		<cfquery name="NegPoints" datasource="#application.DS#">
			SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) AS neg_pt, IFNULL(SUM(cc_charge),0) AS neg_cc
			FROM #application.database#.order_info
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
			AND YEAR(created_datetime) = '#this_year#'
			AND is_valid = 1
		</cfquery>
		<cfif PosPoints.pos_pt GT 0 OR NegPoints.neg_pt GT 0>
			<!---<tr>
				<td>#SelectList.idh#</td>
				<td>#SelectList.distributor#</td>
				<td>#SelectList.username#</td>
				<td>#SelectList.lname#, #SelectList.fname#</td>
				<td>#SelectList.email#</td>
				<td align="right">#PosPoints.pos_pt#</td>
				<td align="right">#NegPoints.neg_pt#</td>
			</tr>--->
			<cfset sub_awarded = sub_awarded + PosPoints.pos_pt>
			<cfset sub_redeemed = sub_redeemed + NegPoints.neg_pt>
			<cfset dist_awarded = dist_awarded + PosPoints.pos_pt>
			<cfset dist_redeemed = dist_redeemed + NegPoints.neg_pt>
			<cfset grand_awarded = grand_awarded + PosPoints.pos_pt>
			<cfset grand_redeemed = grand_redeemed + NegPoints.neg_pt>
		</cfif>
		<cfset this_dist = "#SelectList.idh#-#SelectList.distributor#">
		<cfset this_comp = SelectList.distributor>
		</cfif>
	</cfoutput>
	<cfoutput>
	<tr>
		<td colspan="2" align="right">Total for #this_year#:</td>
		<td align="right">#grand_awarded#</td>
		<td align="right">#grand_redeemed#</td>
	</tr>
	</cfoutput>
	<cfset grand_awarded = 0>
	<cfset grand_redeemed = 0>
</cfloop>
</table>

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->

<!---

<!--- Fastenal --->

<!---<cfabort showerror="z_tracy.cfm is not available">--->
<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<cfparam name="program_ID" default="1000000066">
 
<cfquery name="SelectList" datasource="#application.DS#">
	SELECT U.ID, U.username, U.fname, U.lname, U.email
	FROM #application.database#.program_user U
	WHERE U.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
	AND U.is_active = 1
	AND U.email LIKE '%fastenal%'
	ORDER BY U.lname, U.fname
</cfquery>

<cfset sub_awarded = 0>
<cfset sub_redeemed = 0>
<cfset grand_awarded = 0>
<cfset grand_redeemed = 0>

<cfset year_list = "2012,2013,2014">

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr class="contenthead">
		<td>Username</td>
		<td>Name</td>
		<td>Email</td>
		<td align="right">Awarded</td>
		<td align="right">Redeemed</td>
	</tr>
<cfloop list="#year_list#" index="this_year">
	<tr>
		<td>Fastenal <cfoutput>#this_year#</cfoutput></td>
	</tr>
	<!--- header row --->
	<!--- display found records --->
	<cfoutput query="SelectList">
		<cfquery name="PosPoints" datasource="#application.DS#">
			SELECT IFNULL(SUM(points),0) AS pos_pt
			FROM #application.database#.awards_points
			WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
			AND is_defered = 0
			AND YEAR(created_datetime) = '#this_year#'
		</cfquery>
		<!--- look in the order database for orders/points_used --->
		<cfquery name="NegPoints" datasource="#application.DS#">
			SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) AS neg_pt, IFNULL(SUM(cc_charge),0) AS neg_cc
			FROM #application.database#.order_info
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
			AND YEAR(created_datetime) = '#this_year#'
			AND is_valid = 1
		</cfquery>
		<cfif PosPoints.pos_pt GT 0 OR NegPoints.neg_pt GT 0>
			<tr>
				<td>#SelectList.username#</td>
				<td>#SelectList.lname#, #SelectList.fname#</td>
				<td>#SelectList.email#</td>
				<td align="right">#PosPoints.pos_pt#</td>
				<td align="right">#NegPoints.neg_pt#</td>
			</tr>
			<cfset sub_awarded = sub_awarded + PosPoints.pos_pt>
			<cfset sub_redeemed = sub_redeemed + NegPoints.neg_pt>
			<cfset grand_awarded = grand_awarded + PosPoints.pos_pt>
			<cfset grand_redeemed = grand_redeemed + NegPoints.neg_pt>
		</cfif>
	</cfoutput>
	<cfoutput>
	<tr>
		<td colspan="3" align="right">Total for #this_year#:</td>
		<td align="right">#sub_awarded#</td>
		<td align="right">#sub_redeemed#</td>
	</tr>
	</cfoutput>
	<cfset sub_awarded = 0>
	<cfset sub_redeemed = 0>
</cfloop>
<cfoutput>
<tr>
	<td colspan="3" align="right">Grand Total for #ListFirst(year_list)# through #ListLast(year_list)#:</td>
	<td align="right">#grand_awarded#</td>
	<td align="right">#grand_redeemed#</td>
</tr>
</cfoutput>
</table>

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->


--->