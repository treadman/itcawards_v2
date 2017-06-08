<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<!---
<cfset oImport = createObject("component","components.import").init()>
--->

<cfparam name="url.pgfn" default="home">
<cfparam name="url.s" default="">
<cfparam name="inst" default="">
<cfparam name="alert_msg" default="">

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfset alert_msg = "">
<cfif IsDefined("form.submit")>
	<cfif upload_type IS "territories">
		<cfset txt_new_name = "">
		<cfif form.upload_txt NEQ "">
			<!--- Upload txt file --->
			<cftry>
				<cfset this_txt = FLGen_UploadThis(	FileFieldName="upload_txt",
													DestinationPath="/",
													NewName="loctite_t")>
	
				<cfset txt_original_name = ListGetAt(this_txt,1)>
				<cfset txt_new_name = ListGetAt(this_txt,2)>
				<cfcatch>
					<cfset alert_msg = "Error attempting to upload the spreadsheet.">
				</cfcatch>
			</cftry>
			<cfif isDefined("txt_original_name")>
				<cfif txt_original_name EQ "false">
					<cfset alert_msg = "Error attempting to upload the spreadsheet.">
				</cfif>
			</cfif>
			<cfif alert_msg EQ "">
				<!--- Get the uploaded data into the data_import file --->
				<cfquery name="TruncateQuery" datasource="#application.DS#">
					DELETE FROM #application.database#.henkel_territory
					WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				</cfquery>
				<cfquery name="LoadInFileQuery" datasource="#application.DS#">
					LOAD DATA INFILE '#application.FilePath#loctite_t.csv'
					INTO TABLE #application.database#.henkel_territory
					FIELDS OPTIONALLY ENCLOSED BY '"' TERMINATED BY ','
					LINES TERMINATED BY '\r\n'
					IGNORE 1 LINES
					(fname, lname, email, address1, address2, city, state, zip, country, sub_group, region, division, grp, ty, sap_ty, cost_center, regional_manager)
				</cfquery>
				<cfquery name="Cleanup1Query" datasource="#application.DS#">
					UPDATE #application.database#.henkel_territory SET
					email = CONCAT(LOWER(fname),".",LOWER(lname),"@#request.selected_henkel_program.default_domain#"),
					program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
					WHERE program_ID = 0
				</cfquery>
				<cfquery name="CleanUp2Query" datasource="#application.DS#">
					UPDATE #application.database#.henkel_territory SET
					email = "kenneth.ward@us.henkel.com"
					WHERE lname = "Ward" AND fname = "Ken"
				</cfquery>
				<cfquery name="CleanUp3Query" datasource="#application.DS#">
					UPDATE #application.database#.henkel_territory SET
					email = "jim.kennedy@us.henkel.com"
					WHERE lname = "Kennedy" AND fname = "James"
				</cfquery>
				<cfquery name="CleanUp4Query" datasource="#application.DS#">
					UPDATE #application.database#.henkel_territory SET
					email = "jim.kullberg@us.henkel.com"
					WHERE lname = "Kullberg" AND fname = "James"
				</cfquery>
				<cfquery name="CleanUp5Query" datasource="#application.DS#">
					UPDATE #application.database#.henkel_territory SET
					email = "joseph.dequinque@us.henkel.com"
					WHERE lname = "DeQuinque" AND fname = "Joe"
				</cfquery>
				<cfset alert_msg = "The territory table has been updated.">
			<cfelse>
				<cfset url.pgfn = "upload">
			</cfif>
		</cfif>
	<cfelseif upload_type IS "zipcodes">
		<cfset txt_new_name = "">
		<cfif form.upload_txt NEQ "">
			<!--- Upload txt file --->
			<cftry>
				<cfset this_txt = FLGen_UploadThis(	FileFieldName="upload_txt",
													DestinationPath="/",
													NewName="loctite_z")>
	
				<cfset txt_original_name = ListGetAt(this_txt,1)>
				<cfset txt_new_name = ListGetAt(this_txt,2)>
				<cfcatch>
					<cfset alert_msg = "Error attempting to upload the spreadsheet.">
				</cfcatch>
			</cftry>
			<cfif isDefined("txt_original_name")>
				<cfif txt_original_name EQ "false">
					<cfset alert_msg = "Error attempting to upload the spreadsheet.">
				</cfif>
			</cfif>
			<cfif alert_msg EQ "">
				<!--- Get the uploaded data into the data_import file --->
				<cfquery name="TruncateQuery" datasource="#application.DS#">
					DELETE FROM #application.database#.xref_zipcode_region
					WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
					OR program_ID = 0
				</cfquery>
				<cfset success = false>
				<cftry>
					<cfquery name="LoadInFileQuery" datasource="#application.DS#">
						LOAD DATA INFILE '#application.FilePath#loctite_z.csv'
						INTO TABLE #application.database#.xref_zipcode_region
						FIELDS OPTIONALLY ENCLOSED BY '"' TERMINATED BY ','
						LINES TERMINATED BY '\r\n'
						IGNORE 1 LINES
						(zipcode, region)
					</cfquery>
					<cfset success = true>
					<cfcatch>
						<cfif LEFT(cfcatch.detail,15) NEQ "Duplicate entry">
							<cfrethrow>
						<cfelse>
							<cfset this_zipcode = ListGetAt(cfcatch.detail,2,"-")>
							<cfset this_region = ListGetAt(cfcatch.detail,3,"-")>
							<cfset this_region = ListFirst(this_region,"'")>
							<cfquery name="GetCountQuery" datasource="#application.DS#">
								SELECT COUNT(*) AS total_num
								FROM #application.database#.xref_zipcode_region
								WHERE program_ID = 0
							</cfquery>
							<cfset duplicate_row = GetCountQuery.total_num + 1>
							<cfset alert_msg = "Zipcodes were not uploaded!\n\nSpreadsheet has a duplicate at row #duplicate_row#.\n\nZipcode is #this_zipcode#\nRegion is #this_region#">
							<cfquery name="Cleanup0Query" datasource="#application.DS#">
								DELETE FROM #application.database#.xref_zipcode_region
								WHERE program_ID = 0
							</cfquery>
						</cfif>
					</cfcatch>
				</cftry>
				<cfif success>
					<cfquery name="Cleanup1Query" datasource="#application.DS#">
						UPDATE #application.database#.xref_zipcode_region SET
						program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
						WHERE program_ID = 0
					</cfquery>
					<cfset rec_count = 1>
					<cfloop condition="rec_count gt 0">
						<cfquery name="CheckShortZipcodes" datasource="#application.DS#">
							SELECT zipcode
							FROM #application.database#.xref_zipcode_region
							WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
							AND CHAR_LENGTH(TRIM(zipcode)) < 5
						</cfquery>
						<cfset rec_count = CheckShortZipcodes.recordcount>
						<cfif rec_count GT 0>
							<cfquery name="UpdateShortZipcodes" datasource="#application.DS#">
								UPDATE #application.database#.xref_zipcode_region
								SET zipcode = CONCAT('0',TRIM(zipcode))
								WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
								AND CHAR_LENGTH(TRIM(zipcode)) < 5
							</cfquery>
						</cfif>
					</cfloop>
					<cfset alert_msg = "The zipcode table has been updated.">
				</cfif>
			<cfelse>
				<cfset url.pgfn = "upload">
			</cfif>
		</cfif>
	<cfelseif upload_type IS "distributors">
		<cfset txt_new_name = "">
		<cfif form.upload_txt NEQ "">
			<!--- Upload txt file --->
			<cftry>
				<cfset this_txt = FLGen_UploadThis(	FileFieldName="upload_txt",
													DestinationPath="/",
													NewName="loctite_d")>
	
				<cfset txt_original_name = ListGetAt(this_txt,1)>
				<cfset txt_new_name = ListGetAt(this_txt,2)>
				<cfcatch>
					<cfset alert_msg = "Error attempting to upload the spreadsheet.">
				</cfcatch>
			</cftry>
			<cfif isDefined("txt_original_name")>
				<cfif txt_original_name EQ "false">
					<cfset alert_msg = "Error attempting to upload the spreadsheet.">
				</cfif>
			</cfif>
			<cfif alert_msg EQ "">
				<!--- Get the uploaded data into the data_import file --->
				<cfquery name="TruncateQuery" datasource="#application.DS#">
					DELETE FROM #application.database#.henkel_distributor
					WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				</cfquery>
				<cfquery name="LoadInFileQuery" datasource="#application.DS#">
					LOAD DATA INFILE '#application.FilePath#loctite_d.csv'
					INTO TABLE #application.database#.henkel_distributor
					FIELDS OPTIONALLY ENCLOSED BY '"' TERMINATED BY ','
					LINES TERMINATED BY '\r\n'
					IGNORE 1 LINES
					(idh, company_name, address1, city, state, zip, phone, fax, cmusr1)
				</cfquery>
				<cfquery name="Cleanup1Query" datasource="#application.DS#">
					UPDATE #application.database#.henkel_distributor SET
					program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
					WHERE program_ID = 0
				</cfquery>
				<cfquery name="Cleanup2Query" datasource="#application.DS#">
					DELETE FROM #application.database#.henkel_distributor
					WHERE company_name = ''
				</cfquery>
				<cfset alert_msg = "The #LCase(request.selected_henkel_program.distributor_label)# table has been updated.">
			<cfelse>
				<cfset url.pgfn = "upload">
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfset leftnavon = 'henkel_import'>
<cfinclude template="includes/header.cfm">
<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>

<br /><br />
<cfif url.pgfn NEQ "home">
	<!--- Return link --->
	<span class="pageinstructions">Return to the <a href="<cfoutput>#CurrentPage#</cfoutput>" class="actionlink">Import Main Page</a></span>
	<br><br>
</cfif>

<cfif url.pgfn EQ "home">
	<!--- Page Title --->
	<span class="pagetitle">Import data from Excel</span>
	<br /><br />
	<span class="pageinstructions">
		This is where you import data from the Excel spreadsheet.<br /><br />
		<ol>
			<li>Upload the spreadsheet into the database.  This populates the database with the latest data from Excel.</li>
			<br /><br />
		</ol>
	</span>
	<br /><br />
	<cfoutput>
	<a href="#CurrentPage#?pgfn=upload_territories" class="actionlink">Upload Territory</a> spreadsheet.<br />
	<a href="#CurrentPage#?pgfn=upload_zipcodes" class="actionlink">Upload Zip Code</a> spreadsheet.<br />
	<a href="#CurrentPage#?pgfn=upload_distributors" class="actionlink">Upload #request.selected_henkel_program.distributor_label#</a> spreadsheet.<br />
	</cfoutput>
<cfelseif url.pgfn EQ "upload_territories">
	<!--- Page Title --->
	<span class="pagetitle">Upload the TERRITORY Spreadsheet</span>
	<br /><br />
	<span class="pageinstructions">
	Before uploading the spreadsheet, it needs to be saved in the proper format.<br><br>
	<ol>
		<li>Open the file in Excel.</li><br><br>
		<li>Save the file as a comma-separated values (csv) file.
			<ul type="disc">
				<li>The fields should be in this order: <strong>fname, lname, email, address1, address2, city, state, zip, country, sub_group, region, division, group, ty, sap_ty, cost_center, regional_manager<cfif request.selected_henkel_program.is_region_by_state>, states</cfif>.</strong><br><strong>Delete *ALL* other columns</strong></li>
				<li>Click "File" (or Office Button in Office 2007) then "Save As".
				<li>In the "Save As" dialog window, under the "File name" input field is a drop-down select box for "Save as type:".</li>
				<li>Scroll down to select the "CSV (Comma Delimited) (*.csv)" option.</li>
				<li>If the xls file has more than one worksheet you will get a window asking "The selected file type does not support ... multiple worksheets."  Click "OK".</li>
				<li>Then you'll probably get a message saying "export...csv may contain features that are incompatible..."  Click "Yes"</li>
			</ul>
		</li><br>
		<li>When you close Excel or close the file, Excel asks again to save the txt file.  There is no need to do this, so click "No".</li><br><br>
	</ol>
	<cfoutput>
	<form method="post" action="#CurrentPage#" name="uploadQbooks" enctype="multipart/form-data">
		<input type="hidden" name="upload_type" value="territories" />
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="submit" value="  Upload  " >
	</form>
	</cfoutput>
	</span>
<cfelseif url.pgfn EQ "upload_zipcodes">
	<!--- Page Title --->
	<span class="pagetitle">Upload the ZIP CODE Spreadsheet</span>
	<br /><br />
	<span class="pageinstructions">
	Before uploading the spreadsheet, it needs to be saved in the proper format.<br><br>
	<ol>
		<li>Open the file in Excel.</li><br><br>
		<li>Save the file as a comma-separated values (csv) file.
			<ul type="disc">
				<li>The fields should be in this order: <strong>zip code, region.</strong><br><strong>Delete *ALL* other columns</strong></li>
				<li>Click "File" (or Office Button in Office 2007) then "Save As".
				<li>In the "Save As" dialog window, under the "File name" input field is a drop-down select box for "Save as type:".</li>
				<li>Scroll down to select the "CSV (Comma Delimited) (*.csv)" option.</li>
				<li>If the xls file has more than one worksheet you will get a window asking "The selected file type does not support ... multiple worksheets."  Click "OK".</li>
				<li>Then you'll probably get a message saying "export...csv may contain features that are incompatible..."  Click "Yes"</li>
			</ul>
		</li><br>
		<li>When you close Excel or close the file, Excel asks again to save the txt file.  There is no need to do this, so click "No".</li><br><br>
	</ol>
	<cfoutput>
	<form method="post" action="#CurrentPage#" name="uploadQbooks" enctype="multipart/form-data">
		<input type="hidden" name="upload_type" value="zipcodes" />
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="submit" value="  Upload  " >
	</form>
	</cfoutput>
	</span>
<cfelseif url.pgfn EQ "upload_distributors">
	<!--- Page Title --->
	<span class="pagetitle">Upload the <cfoutput>#UCase(request.selected_henkel_program.distributor_label)#</cfoutput> Spreadsheet</span>
	<br /><br />
	<span class="pageinstructions">
	Before uploading the spreadsheet, it needs to be saved in the proper format.<br><br>
	<ol>
		<li>Open the file in Excel.</li><br><br>
		<li>Save the file as a comma-separated values (csv) file.
			<ul type="disc">
				<li>The fields should be in this order: <strong>idh, company_name, address1, city, state, zip, phone, fax, cmusr1.</strong><br><strong>Delete *ALL* other columns</strong></li>
				<li>Click "File" (or Office Button in Office 2007) then "Save As".
				<li>In the "Save As" dialog window, under the "File name" input field is a drop-down select box for "Save as type:".</li>
				<li>Scroll down to select the "CSV (Comma Delimited) (*.csv)" option.</li>
				<li>If the xls file has more than one worksheet you will get a window asking "The selected file type does not support ... multiple worksheets."  Click "OK".</li>
				<li>Then you'll probably get a message saying "export...csv may contain features that are incompatible..."  Click "Yes"</li>
			</ul>
		</li><br>
		<li>When you close Excel or close the file, Excel asks again to save the txt file.  There is no need to do this, so click "No".</li><br><br>
	</ol>
	<cfoutput>
	<form method="post" action="#CurrentPage#" name="uploadQbooks" enctype="multipart/form-data">
		<input type="hidden" name="upload_type" value="distributors" />
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="submit" value="  Upload  " >
	</form>
	</cfoutput>
	</span>
<cfelseif url.pgfn EQ "imported">
	<!--- Page Title --->
	<span class="pagetitle">Import the Data</span>
	<br /><br />
	<cfif url.s EQ "">
		<span class="pageinstructions">
			The import has completed.<br><br>
		</span>
	</cfif>
	<br><br>
</cfif>

<cfinclude template="includes/footer.cfm">
