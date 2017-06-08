<!--- -------------------------------------- --->
<!--- ------  Show MRO_OEM records   ------- --->
<!--- -------------------------------------- --->

<cfif url.pgfn EQ "results_mro_oem">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2,
			SUM((SELECT IFNULL(MAX(p.points),0) AS points_awarded
			FROM #application.database#.henkel_points_lookup p
			WHERE i.program_type = p.program_type AND p.minimum <= i.count)) AS awarded_points
		FROM #application.database#.henkel_import_mro_oem i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_mro_oem</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
	<cfoutput query="GetList">
		<tr>
			<td><a href="#CurrentPage#?pgfn=edit_mro_oem&email=#email#">Edit</a></td>
			<td>#idh#</td>
			<td>#fname#</td>
			<td>#lname#</td>
			<td>#email#</td>
			<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
			<td align="right">#awarded_points#</td>
		</tr>
	</cfoutput>
	</table>

<!--- --------------------------------- --->
<!--- ------  Show LU records   ------- --->
<!--- --------------------------------- --->

<cfelseif url.pgfn EQ "results_lu">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2,
			SUM((SELECT IFNULL(MAX(p.points),0) AS points
			FROM #application.database#.henkel_points_lookup p
			WHERE p.program_type = "LU" AND p.minimum <= 1)) AS awarded_points
		FROM #application.database#.henkel_import_lu i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_lu</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
		<cfoutput query="GetList">
			<tr>
				<td><a href="#CurrentPage#?pgfn=edit_lu&email=#email#">Edit</a></td>
				<td>#idh#</td>
				<td>#fname#</td>
				<td>#lname#</td>
				<td>#email#</td>
				<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				<td align="right">#awarded_points#</td>
			</tr>
		</cfoutput>
	</table>

<!--- --------------------------------- --->
<!--- ------  Show DCSE records   ------- --->
<!--- --------------------------------- --->

<cfelseif url.pgfn EQ "results_dcse">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2,
			SUM((SELECT IFNULL(MAX(p.points),0) AS points
			FROM #application.database#.henkel_points_lookup p
			WHERE p.program_type = "DCSE" AND p.minimum <= 1)) AS awarded_points
		FROM #application.database#.henkel_import_dcse i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_dcse</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
		<cfoutput query="GetList">
			<tr>
				<td><a href="#CurrentPage#?pgfn=edit_dcse&email=#email#">Edit</a></td>
				<td>#idh#</td>
				<td>#fname#</td>
				<td>#lname#</td>
				<td>#email#</td>
				<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				<td align="right">#awarded_points#</td>
			</tr>
		</cfoutput>
	</table>

<!--- --------------------------------- --->
<!--- ------  Show LEAK records   ------- --->
<!--- --------------------------------- --->

<cfelseif url.pgfn EQ "results_leak">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2,
			SUM((SELECT IFNULL(MAX(p.points),0) AS points
			FROM #application.database#.henkel_points_lookup p
			WHERE p.program_type = "LEAK" AND p.minimum <= 1)) AS awarded_points
		FROM #application.database#.henkel_import_leak i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_leak</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
		<cfoutput query="GetList">
			<tr>
				<td><a href="#CurrentPage#?pgfn=edit_leak&email=#email#">Edit</a></td>
				<td>#idh#</td>
				<td>#fname#</td>
				<td>#lname#</td>
				<td>#email#</td>
				<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				<td align="right">#awarded_points#</td>
			</tr>
		</cfoutput>
	</table>

<!--- ---------------------------------- --->
<!--- ------  Show DTS records   ------- --->
<!--- ---------------------------------- --->

<cfelseif url.pgfn EQ "results_DTS">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2,
			SUM((SELECT IFNULL(MAX(p.points),0) AS points
			FROM #application.database#.henkel_points_lookup p
			WHERE p.program_type = "DTS" AND p.minimum <= 1)) AS awarded_points
		FROM #application.database#.henkel_import_dts i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_dts</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
		<cfoutput query="GetList">
			<tr>
				<td><a href="#CurrentPage#?pgfn=edit_dts&email=#email#">Edit</a></td>
				<td>#idh#</td>
				<td>#fname#</td>
				<td>#lname#</td>
				<td>#email#</td>
				<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				<td align="right">#awarded_points#</td>
			</tr>
		</cfoutput>
	</table>

<!--- --------------------------------- --->
<!--- ------  Show JSC records  ------- --->
<!--- --------------------------------- --->

<cfelseif url.pgfn EQ "results_jsc">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.fname, i.lname, i.email, i.date_entered_2,
			SUM((SELECT IFNULL(MAX(p.points),0) AS points
			FROM #application.database#.henkel_points_lookup p
			WHERE p.program_type = "JSC" AND p.minimum <= 1)) AS awarded_points
		FROM #application.database#.henkel_import_jsc i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_jsc</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
		<cfoutput query="GetList">
			<tr>
				<td><a href="#CurrentPage#?pgfn=edit_jsc&email=#email#">Edit</a></td>
				<td>#fname#</td>
				<td>#lname#</td>
				<td>#email#</td>
				<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				<td align="right">#awarded_points#</td>
			</tr>
		</cfoutput>
	</table>

<!--- ------------------------------------ --->
<!--- ------  Show SIMPLE records  ------- --->
<!--- ------------------------------------ --->

<cfelseif url.pgfn EQ "results_simple">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.name, i.email, i.date_entered_2
		FROM #application.database#.henkel_import_simple i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_simple</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
		<cfoutput query="GetList">
			<tr>
				<td><a href="#CurrentPage#?pgfn=edit_simple&email=#email#">Edit</a></td>
				<td>#name#</td>
				<td>#email#</td>
				<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
			</tr>
		</cfoutput>
	</table>

<!--- ------------------------------------ --->
<!--- ------  Show POINTS records  ------- --->
<!--- ------------------------------------ --->

<cfelseif url.pgfn EQ "results_points">
	<cfquery name="GetList" datasource="#application.DS#">
		SELECT i.ID, i.fname, i.lname, i.email, i.date_entered_2, i.points, i.reason
		FROM #application.database#.henkel_import_points i
		WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND i.date_processed IS NULL
		GROUP BY email
		ORDER BY email
	</cfquery>
	<span class="pageinstructions"><a href="<cfoutput>#CurrentPage#?pgfn=process_jsc</cfoutput>" class="actionlink">Process</a></span>
	<br><br>
	<table border="0">
		<cfoutput query="GetList">
			<tr>
				<td><a href="#CurrentPage#?pgfn=edit_jsc&email=#email#">Edit</a></td>
				<td>#name#</td>
				<td>#email#</td>
				<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				<td align="right">#points#</td>
				<td>#reason#</td>
			</tr>
		</cfoutput>
	</table>

</cfif>
