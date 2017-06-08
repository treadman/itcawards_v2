<!--- Pull Loctite Rep from uploaded spreadsheet --->
<cfset thisCC_byUpload = "">
<!--- Lookup loctite rep to CC them --->
<cfset thisCC_byIDH = "">
<cfset NotFoundMsg = "">
<cfif NOT doit OR isDefined("form.cc_loctite_rep")>
	<!--- By Spreadsheet --->
	<cfif isDefined("GetImportRecords.loctite_rep_email")>
		<cfset thisCC_byUpload = GetImportRecords.loctite_rep_email>
	</cfif>
	<!--- By IDH --->
	<cfif thisIDH NEQ "">
		<cfquery name="getDistributor" datasource="#application.DS#">
			SELECT zip
			FROM #application.database#.henkel_distributor
			WHERE idh = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisIDH#">
		</cfquery>
		<cfif getDistributor.recordcount GT 0>
			<cfquery name="getRegion" datasource="#application.DS#">
				SELECT region
				FROM #application.database#.xref_zipcode_region
				WHERE zipcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getDistributor.zip#">
			</cfquery>
			<cfif getRegion.recordcount GT 0>
				<cfquery name="getTerritory" datasource="#application.DS#">
					SELECT email
					FROM #application.database#.henkel_territory
					WHERE sap_ty = <cfqueryparam cfsqltype="cf_sql_varchar" value="00#getRegion.region#">
				</cfquery>
				<cfif getTerritory.recordcount GT 0>
					<cfset thisCC_byIDH = getTerritory.email>
				<cfelse>
					<cfset NotFoundMsg = "Territory Not Found">
				</cfif>
			<cfelse>
				<cfset NotFoundMsg = "Region Not Found">
			</cfif>
		<cfelse>
			<cfset NotFoundMsg = "No Distributor for IDH">
		</cfif>
	<cfelse>
		<cfset NotFoundMsg = "No IDH number">
	</cfif>
	<cfoutput>
	<cfif thisCC_byUpload NEQ "">
		<span style="white-space:nowrap;">S: #thisCC_byUpload#</span>
	</cfif>
	<cfif thisCC_byIDH NEQ "">
		<cfif thisCC_byUpload NEQ ""><br /></cfif>
		<span style="white-space:nowrap;">D: #thisCC_byIDH#</span>
	<cfelseif thisCC_byUpload EQ "" AND NotFoundMsg NEQ "">
		<span style="white-space:nowrap;">D: #NotFoundMsg#</span>
	</cfif>
	</cfoutput>
<cfelse>
	NO
</cfif>
