<cfset txt_new_name = "">
<cfif form.upload_txt NEQ "">
	<!--- Upload txt file --->
	<!---<cftry>--->
		<cfset this_txt = FLGen_UploadThis(	FileFieldName="upload_txt",
											DestinationPath="/",
											NewName="loctite_#upload_type#")>

		<cfset txt_original_name = ListGetAt(this_txt,1)>
		<cfset txt_new_name = ListGetAt(this_txt,2)>
		<!---<cfcatch>
			<cfset alert_msg = "Error attempting to upload the spreadsheet (1).">
		</cfcatch>
	</cftry>--->
	<cfif isDefined("txt_original_name")>
		<cfif txt_original_name EQ "false">
			<cfset alert_msg = "Error attempting to upload the spreadsheet (2).">
		</cfif>
	</cfif>
	<cfif alert_msg EQ "">
		<!--- Get the uploaded data into the data_import file --->
		<!--- <cfquery name="TruncateQuery" datasource="#application.DS#">
			DELETE FROM #application.database#.henkel_import_mro_oem
			WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		</cfquery> --->
		<cftry>
			<cfquery name="LoadInFileQuery" datasource="#application.DS#">
				LOAD DATA INFILE '#application.FilePath#loctite_#upload_type#.csv'
				INTO TABLE #application.database#.henkel_import_#upload_type#
				FIELDS OPTIONALLY ENCLOSED BY '"' TERMINATED BY ','
				LINES TERMINATED BY '\r\n'
				IGNORE 1 LINES
				<cfswitch expression="#upload_type#">
				<cfcase value="jsc">
					(lname, fname, email, date_entered, loctite_rep, loctite_rep_email)
				</cfcase>
				<cfcase value="dts,lu,dcse,leak">
					(idh, fname, lname, email, date_entered)
				</cfcase>
				<cfcase value="mro_oem">
					(idh, date_entered, fname, lname, email, program_type, count)
				</cfcase>
				<cfcase value="simple">
					(company_name, company_address, name, phone, email, date_entered)
				</cfcase>
				<cfcase value="points">
					(company_name, company_address, name, phone, email, points, reason, date_entered)
				</cfcase>
				</cfswitch>
			</cfquery>
		<cfcatch>
			<cfif cfcatch.queryError EQ "">
				<cfset alert_msg = "We're sorry, but that file could not be uploaded.  Please check it and try again.">
			<cfelse>
				<cfset alert_msg = Replace(cfcatch.queryError,"'",'\"',"ALL")>
			</cfif>
		</cfcatch>
		</cftry>
		<cfif alert_msg EQ "">
			<cfif upload_type NEQ "simple" AND upload_type NEQ "points">
				<cfquery name="Cleanup1Query" datasource="#application.DS#">
					DELETE FROM #application.database#.henkel_import_#upload_type#
					WHERE program_ID = 0 AND lname = '' AND fname = '' AND email = ''
				</cfquery>
			<cfelse>
				<cfquery name="Cleanup1Query" datasource="#application.DS#">
					DELETE FROM #application.database#.henkel_import_#upload_type#
					WHERE program_ID = 0 AND name = '' AND email = ''
				</cfquery>
			</cfif>
			<cfquery name="Cleanup2Query" datasource="#application.DS#">
				UPDATE #application.database#.henkel_import_#upload_type#
				SET	date_entered_2 =  STR_TO_DATE(date_entered, '%m/%d/%Y'),
					program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				WHERE program_ID = 0
			</cfquery>
			<cfset url.pgfn = "results_#upload_type#">
		</cfif>
	</cfif>
	<cfif alert_msg NEQ "">
		<cfset url.pgfn = "upload">
		<cfset url.type = form.upload_type>
	</cfif>
</cfif>
