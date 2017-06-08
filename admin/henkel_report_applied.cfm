<cfsetting enablecfoutputonly="true" requesttimeout="300">

<cfparam name="url.year" default="">
<cfif url.year EQ "" OR NOT isnumeric(url.year)>
	<cfoutput>Please enter a year</cfoutput><cfabort>
</cfif>
<cfquery name="GetAll" datasource="#application.DS#">
	SELECT * FROM ITCAwards.henkel_report
	WHERE YEAR(entered) = #url.year#
	order by idh, email;
</cfquery>
<cfset QueryAddRow(GetAll)>
<cfset QuerySetCell(GetAll,"idh","last_time")>
<cfset QuerySetCell(GetAll,"email","last_time")>

<!---<cfdump var="#GetAll#"><cfabort>--->

<cfoutput>IDH, Distributor, Region, Reps, Points<br></cfoutput>
<cfset rep_count = 0>
<cfset rep_points = 0>
<cfset old_idh = "first_time">
<cfset old_email = "first_time">

<cfloop query="GetAll">
	<cfif old_idh neq GetAll.idh>
		<cfif old_idh NEQ "first_time">
			<!---Look up distributor and region using IDH--->
			<cfset this_distributor = 'n/a'>
			<cfset this_region = 'n/a'>
			<cfif trim(old_idh) EQ "">
				<cfset old_idh = "[blank]">
			<cfelseif old_idh EQ "999999">
				<cfset old_idh = "[unknown]">
			<cfelse>
				<cfquery name="GetDistributor" datasource="#application.DS#">
					SELECT DISTINCT d.company_name, z.territory, r.region
					FROM ITCAwards.henkel_distributor d
					LEFT JOIN ITCAwards.henkel_zipcode z on d.zip = z.zipcode
					LEFT JOIN ITCAwards.xref_zipcode_region r on d.zip = r.zipcode
					WHERE IDH = '#old_idh#'
				</cfquery>
				<cfif GetDistributor.recordcount GT 0>
					<cfif GetDistributor.company_name NEQ "">
						<cfset this_distributor = GetDistributor.company_name>
					</cfif>
					<cfif GetDistributor.territory NEQ "">
						<cfset this_region = GetDistributor.territory>
					</cfif>
					<!---<cfif GetDistributor.region NEQ "">
						<cfset this_region = GetDistributor.region>
					</cfif>--->
				</cfif>
			</cfif> 
			<cfoutput>#old_idh#,#this_distributor#,#this_region#,#rep_count#,#rep_points#<br></cfoutput>
			<cfset rep_count = 0>
			<cfset rep_points = 0>
		</cfif>
	</cfif>
	<cfif getAll.idh NEQ "last_time">
		<cfif old_email NEQ GetAll.email>
			<cfset rep_count = rep_count + 1>
		</cfif>
		<cfset rep_points = rep_points + GetAll.points>
		<cfset old_idh = GetAll.idh>
		<cfset old_email = GetAll.email>
	</cfif>
</cfloop>
<!---<cfdump var="#GetAll#">--->
<cfoutput>--end--</cfoutput>