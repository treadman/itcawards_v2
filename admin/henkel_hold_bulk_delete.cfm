<!--- function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<cfparam name="alert_msg" default="">
<cfparam name="url.pgfn" default="home">

<cfset do_it = false>
<cfif isDefined('form.doDelete')>
	<cfset do_it = true>
	<cfset url.pgfn = "delete">
</cfif>

<cfset thisFileName = "delete_henkel_hold">

<cfif IsDefined("form.submitUpload")>
	<cfif form.upload_txt NEQ "">
		<cfset result = FLGen_UploadThis("upload_txt","admin/upload/",thisFileName)>
		<cfif result EQ "false,false">
			<cfset alert_msg = "There was an error uploading the file.">
		<cfelse>
			<cfif right(ListLast(result),4) NEQ "xlsx">
				<cfset alert_msg = "That was not an xlsx file.">
			<cfelse>
				<cfset url.pgfn = "delete">
			</cfif>
		</cfif>
		<cfif alert_msg NEQ "">
			<cfset url.pgfn = "upload">
		</cfif>
	</cfif>
</cfif>

<cfset leftnavon = "henkel_hold">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">
	Bulk Delete of Holding Tank Users
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="<cfoutput>#CurrentPage#</cfoutput>">Start Over</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="henkel-hold.cfm">Return to Hold Points list</a>
</span>
<br /><br />

<cfif url.pgfn EQ "home">
	<cfset FLGen_DeleteThisFile("#thisFileName#.csv","admin/upload/")>
	<span class="pageinstructions">
		This is a bulk delete function that will delete all entries in the Holding Tank that are listed on a spreadsheet.<br /><br />
	</span>
	<span class="pageinstructions">
		The spreadsheet must be in XLSX format.<br /><br />
	</span>
	<span class="pageinstructions">
		The first row must be a header row.  The first column must be the email address.<br />
	</span>
	<br /><br />
	<a href="<cfoutput>#CurrentPage#?pgfn=upload</cfoutput>" class="actionlink">Upload Spreadsheet</a>
<cfelseif url.pgfn EQ "upload">
	<span class="pagetitle">Upload the Spreadsheet</span>
	<br /><br />
	<cfoutput>
	<form method="post" action="#CurrentPage#" name="uploadSpreadsheet" enctype="multipart/form-data">
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="submitUpload" value="  Upload  " >
	</form>
	</cfoutput>
	</span>
<cfelseif url.pgfn EQ "delete">
	<cfset hasFile = true>
	<cftry>
		<cfspreadsheet action="read" src="#application.FilePath#admin/upload/#thisFileName#.xlsx" query="bulk_delete">
		<cfcatch><cfset hasFile = false></cfcatch>
	</cftry>
	<cfif NOT hasFile>
		<span class="pageinstructions">Sorry, but the data was lost.  You'll have to upload it again.</span>
	<cfelse>
		<cfoutput>
		<cfif NOT do_it>
			<form name="DeleteForm" method="post" action="#CurrentPage#">
				<input type="submit" name="doDelete" value="Do Bulk Delete" >
			</form>
		</cfif>
		<br>
		<cfloop query="bulk_delete" startrow="2">
			#bulk_delete.col_1#:
			<cfquery name="GetHoldUser" datasource="#application.DS#">
				SELECT h.created_datetime, h.email, h.points, h.source_import, u.username, IFNULL(u.is_active,0) as is_active
				FROM #application.database#.henkel_hold_user h
				LEFT JOIN #application.database#.program_user u ON h.email = u.email AND h.program_ID = u.program_ID AND u.registration_type != 'BranchHQ'
				WHERE h.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bulk_delete.col_1#">
				AND h.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif GetHoldUser.recordcount EQ 0>
				<span class="alert">Not found!</span>
			<cfelse>
				#GetHoldUser.recordCount# entries found.<br>
				<cfloop query="GetHoldUser">
					#DateFormat(GetHoldUser.created_datetime,"mm/dd/yyyy")# #GetHoldUser.source_import# #GetHoldUser.points# points
					<cfif GetHoldUser.is_active>
						<span class="alert">Active User: #GetHoldUser.username#!</span>
					</cfif>
					<br>
				</cfloop>
				<cfif do_it>
					 <cfquery name="DeleteHoldPoints" datasource="#application.DS#">
						DELETE FROM #application.database#.henkel_hold_user
						WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bulk_delete.col_1#">
						AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery> 
					Hold points deleted
				</cfif>
			</cfif>
			<br><br>
		</cfloop>
		</cfoutput>
	</cfif>
<cfelse>
	<cfoutput>
	#url.pgfn# is not set up.<br><br>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">
