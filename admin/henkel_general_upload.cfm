<!--- function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<cfparam name="url.pgfn" default="home">

<cfif NOT isDefined("request.henkel_ID") OR  NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="alert_msg" default="">
<cfparam name="send_email" default="0">
<cfparam name="from_name" default="From Name">
<cfparam name="from_email" default="#application.AwardsFromEmail#">
<cfparam name="cc_email" default="">
<cfparam name="email_subject" default="">
<cfparam name="failto" default="#application.AwardsFromEmail#">
<cfparam name="email_text" default="">
<cfparam name="hasHeader" default="1">
<cfparam name="ex_template_ID" default="">
<cfparam name="pe_template_ID" default="">
<cfparam name="email" default="">
<cfparam name="ccmail" default="">
<cfparam name="firstname" default="">
<cfparam name="lastname" default="">
<cfparam name="points" default="">
<cfparam name="zipcode" default="">
<cfparam name="note" default="">
<cfparam name="activity" default="">
<cfparam name="merge1" default="">
<cfparam name="merge2" default="">
<cfparam name="merge3" default="">

<cfparam name="testing_email" default="">

<cfset num_sent = 0>
<cfset pe_test = 0>
<cfset ex_test = 0>
<cfset DisplayResults = "">
<cfset thisFileName = "upload_points#Replace(CGI.REMOTE_ADDR,'.','','ALL')#">

<cfif IsDefined("form.submitUpload")>
	<cfif form.upload_txt NEQ "">
		<cfset result = FLGen_UploadThis("upload_txt","admin/upload/",thisFileName)>
		<cfif result EQ "false,false">
			<cfset alert_msg = "There was an error uploading the file.">
		<cfelse>
			<cfif right(ListLast(result),3) NEQ "csv">
				<cfset alert_msg = "That was not a CSV file.">
			<cfelse>
				<cfset url.pgfn = "email_setup">
			</cfif>
		</cfif>
		<cfif alert_msg NEQ "">
			<cfset url.pgfn = "upload">
		</cfif>
	</cfif>
</cfif>

<cfif IsDefined("form.submitEmail") OR IsDefined("form.submitTest")>
	<cfset testing_only = IsDefined("form.submitTest")>
	<cfset hasFile = true>
	<cftry>
		<cffile action="read" variable="thisData" file="#application.FilePath#admin/upload/#thisFileName#.csv">
		<cfcatch><cfset hasFile = false></cfcatch>
	</cftry>
	<cfif NOT hasFile>
		<cfset alert_msg="Sorry, but the data was lost.  You will have to upload it again.">
	</cfif>
	<cfif alert_msg EQ "" AND send_email>
		<cfif NOT isNumeric(email) OR email LTE 0>
			<cfset alert_msg="Please enter the email address column number.">
		<cfelseif NOT IsNumeric(ex_template_ID)>
			<cfset alert_msg="Please select a template for existing users.">
		<cfelseif NOT IsNumeric(pe_template_ID)>
			<cfset alert_msg="Please select a template for pending users.">
		<cfelseif testing_email EQ "" AND testing_only>
			<cfset alert_msg="Please enter an email address to send the test to.">
		</cfif>
	</cfif>
	<cfif alert_msg EQ "">
		<cfif send_email>
			<cfquery name="getExTemplate" datasource="#application.ds#">
				SELECT email_text
				FROM #application.database#.email_templates
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ex_template_ID#">
			</cfquery>
			<cfset ex_email_text = getExTemplate.email_text>
			<cfquery name="getPeTemplate" datasource="#application.ds#">
				SELECT email_text
				FROM #application.database#.email_templates
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#pe_template_ID#">
			</cfquery>
			<cfset pe_email_text = getPeTemplate.email_text>
		</cfif>
		<cfset thisData = Replace(thisData,"#CHR(13)##CHR(10)#","|","ALL")>
		<cfset first_line = true>
		<cfif NOT hasHeader>
			<cfset first_line = false>
		</cfif>
		<cfset DisplayResults = '<table width="100%" cellpadding="3"><tr><td>Email</td><td>User</td><td>Notes</td><td align="right">Points</td><tr>'>
		<cfloop list="#thisData#" index="thisLine" delimiters="|">
			<cfif NOT first_line>
				<cfset thisEmail = "">
				<cfset thisCC = "">
				<cfset thisFirstname = "">
				<cfset thisLastname = "">
				<cfset thisPoints = "">
				<cfset thisZipcode = "">
				<cfset thisMerge1 = "">
				<cfset thisMerge2 = "">
				<cfset thisMerge3 = "">
				<cfset col_num = 1>
				<cfloop list="#thisLine#" index="thisCol">
					<cfif col_num EQ email>
						<cfset thisEmail = thisCol>
					</cfif>
					<cfif col_num EQ ccmail>
						<cfset thisCC = thisCol>
					</cfif>
					<cfif firstname NEQ "" AND col_num EQ firstname>
						<cfset thisFirstname = thisCol>
					</cfif>
					<cfif lastname NEQ "" AND col_num EQ lastname>
						<cfset thisLastname = thisCol>
					</cfif>
					<cfif points NEQ "" AND col_num EQ points>
						<cfset thisPoints = thisCol>
					</cfif>
					<cfif zipcode NEQ "" AND col_num EQ zipcode>
						<cfset thisZipcode = thisCol>
					</cfif>
					<cfif merge1 NEQ "" AND col_num EQ merge1>
						<cfset thisMerge1 = thisCol>
					</cfif>
					<cfif merge2 NEQ "" AND col_num EQ merge2>
						<cfset thisMerge2 = thisCol>
					</cfif>
					<cfif merge3 NEQ "" AND col_num EQ merge3>
						<cfset thisMerge3 = thisCol>
					</cfif>
					<cfset col_num = col_num + 1>
				</cfloop>
				<cfset DisplayResults = DisplayResults & '<tr><td>#thisEmail#</td><td>#thisFirstName# #thisLastName#</td>'>
				<cfset zip_ok = true>
				<cfif zipcode NEQ "" AND thisZipcode NEQ "">
					<cfquery name="checkZipCode" datasource="#application.DS#">
						SELECT ZIPCode
						FROM ZipCodes.zipcode_us
						WHERE ZIPCode = <cfqueryparam value="#thisZipcode#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif checkZipCode.recordcount EQ 0>
						<cfset zip_ok = false>
					</cfif>
				</cfif>
				<!--- Look up user --->
				<cfset User_ID = 0>
				<cfset thisUsername = "">
				<cfif zip_ok AND thisEmail NEQ "" AND FLGen_IsValidEmail(thisEmail)>
					<cfquery name="getExistingUser" datasource="#application.DS#">
						SELECT ID, fname, lname, expiration_date, username
						FROM #application.database#.program_user
						WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisEmail#">
						AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
						AND registration_type <> 'BranchHQ'
					</cfquery>
					<cfif getExistingUser.recordcount EQ 1>
						<cfset DisplayResults = DisplayResults & '<td>Email Found</td>'>
						<cfset User_ID = getExistingUser.ID>
						<cfset thisUserName = getExistingUser.username>
					<cfelseif getExistingUser.recordcount EQ 0>
						<cfif NOT testing_only>
							<cfquery name="addHoldUser" datasource="#application.DS#">
								INSERT INTO #application.database#.henkel_hold_user (
										created_user_ID, created_datetime, program_ID, email, points, source_import
									)
								VALUES (
									<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
									'#FLGen_DateTimeToMySQL()#',
									<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisEmail#" maxlength="128">,
									<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisPoints#" maxlength="8">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#left(note,32)#">
								)
							</cfquery>
						</cfif>
						<cfset DisplayResults = DisplayResults & '<td>Add to Hold Points</td>'>
					<cfelse>
						<cfset DisplayResults = DisplayResults & '<td>MULTIPLES FOUND!</td>'>
					</cfif>
				<cfelse>
					<cfif zip_ok>
						<cfset DisplayResults = DisplayResults & '<td>BAD EMAIL</td>'>
					<cfelse>
						<cfset DisplayResults = DisplayResults & '<td>#thisZipcode# IS NOT IN U.S.</td>'>
					</cfif>
				</cfif>
				<cfif zip_ok AND send_email AND trim(thisEmail) NEQ "" AND FLGen_IsValidEmail(thisEmail)>
					<cfif User_ID GT 0>
						<cfset email_text = ex_email_text>
					<cfelse>
						<cfset email_text = pe_email_text>
					</cfif>
					<cfset email_message = Replace(email_text,'USER-FIRST-NAME',thisFirstname,'all')>
					<cfset email_message = Replace(email_message,'USER-LAST-NAME',thisLastname,'all')>
					<cfset email_message = Replace(email_message,'USER-POINTS-EARNED',thisPoints,'all')>
					<cfset email_message = Replace(email_message,'USER-POINTS',thisPoints,'all')>
					<cfset email_message = Replace(email_message,'USER-NAME',thisUsername,'all')>
					<cfset email_message = Replace(email_message,'VALUED-SELLING-ACTIVITY',activity,'all')>
					<cfset email_message = Replace(email_message,'DATE-TODAY',DateFormat(Now(),'mm/dd/yyyy'),'all')>
					<cfset email_message = Replace(email_message,'MERGE-COLUMN-1',thisMerge1,'all')>
					<cfset email_message = Replace(email_message,'MERGE-COLUMN-2',thisMerge2,'all')>
					<cfset email_message = Replace(email_message,'MERGE-COLUMN-3',thisMerge3,'all')>
					<cfif testing_only>
						<cfif User_ID GT 0 AND ex_test EQ 0>
							<!--- Send tests --->
							<cfmail to="#testing_email#" from="#from_email#" subject="#email_subject#" type="html">
#email_message#
							</cfmail>
							<cfset url.pgfn = "email_setup">
							<cfset ex_test = 1>
						</cfif>
						<cfif User_ID EQ 0 AND pe_test EQ 0>
							<!--- Send tests --->
							<cfmail to="#testing_email#" from="#from_email#" subject="#email_subject#" type="html">
#email_message#
							</cfmail>
							<cfset url.pgfn = "email_setup">
							<cfset pe_test = 1>
						</cfif>
					<cfelse>
						<cfset combined_cc = "">
						<cfif cc_email NEQ "" AND FLGen_IsValidEmail(cc_email)>
							<cfset combined_cc = ListAppend(combined_cc,cc_email)>
						</cfif>
						<cfif thisCC NEQ "" AND FLGen_IsValidEmail(thisCC)>
							<cfset combined_cc = ListAppend(combined_cc,thisCC)>
						</cfif>
						<cfmail to="#thisEmail#" from="#from_email#" cc="#combined_cc#" subject="#email_subject#" type="html">
#email_message#
						</cfmail>
					</cfif>
					<cfset num_sent = num_sent + 1>
				</cfif>
				<cfif zip_ok AND NOT testing_only AND isNumeric(thisPoints) AND thisPoints GT 0 AND User_ID GT 0>
					<cfquery name="AwardPoints" datasource="#application.DS#">
						INSERT INTO #application.database#.awards_points (
							created_user_ID, created_datetime, user_ID, points, notes)
						VALUES (
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
							'#FLGen_DateTimeToMySQL()#',
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#User_ID#" maxlength="10">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisPoints#">,
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#note#">
						)
					</cfquery>
				</cfif>
				<cfset DisplayResults = DisplayResults & '<td align="right">#thisPoints#</td>'>
			</cfif>
			<cfset first_line = false>
		</cfloop>
		<cfif testing_only>
			<cfset alert_msg = "">
			<cfset s = "">
			<cfif ex_test EQ 1>
				<cfset alert_msg = alert_msg & "Existing user">
			</cfif>
			<cfif pe_test EQ 1>
				<cfif ex_test EQ 1>
					<cfset alert_msg = alert_msg & " and pending user">
					<cfset s = "s">
				<cfelse>
					<cfset alert_msg = alert_msg & "Pending user">
				</cfif>
			</cfif>
			<cfset alert_msg = alert_msg & " test email#s# sent to #testing_email#.">
		<cfelse>
			<cfset FLGen_DeleteThisFile("#thisFileName#.csv","admin/upload/")>
			<cfset url.pgfn = "done">
		</cfif>
	</cfif>
	<cfif alert_msg NEQ "" OR testing_only>
		<cfset url.pgfn = "email_setup">
	</cfif>
</cfif>

<cfset leftnavon = 'henkel_general_upload'>
<cfinclude template="includes/header.cfm">

<script src="../includes/showhide.js"></script>

<script>
TheWindow = null

function openPreview(TheTemplate)
{

	// if a window exists and is open, close it
	if (TheWindow != null)
	{TheWindow.close()}

	// find the selected one in the select
	previewId = document.getElementById(TheTemplate)
	previewIdValue = previewId.options[previewId.selectedIndex].value
	
	// open new window with preview	
 	TheWindow = window.open('email_alert_preview.cfm?ID='+previewIdValue+'&prog=<cfoutput>#request.henkel_ID#</cfoutput>','windowname');
	
}
</script>

<span class="pagetitle">
	Upload points to <cfoutput>#request.selected_henkel_program.program_name#</cfoutput> &nbsp;&nbsp;&nbsp;&nbsp; <a href="<cfoutput>#CurrentPage#</cfoutput>">Start Over</a>
</span>
<br /><br />


<cfif url.pgfn EQ "home">
	<span class="alert">REMOVE ALL COMMAS FROM YOUR DATA!!!!</span>
	<br /><br />
	<cfset FLGen_DeleteThisFile("#thisFileName#.csv","admin/upload/")>
	<!--- Page Title --->
	<span class="pageinstructions">
		This is a points uploader that allows you to upload points and (optionally) send an email to a set of people in a spreadsheet.<br /><br />
	</span>
	<span class="pageinstructions">
		The spreadsheet must be saved in CSV format.<br /><br />
	</span>
	<span class="pageinstructions">
		After uploading the spreadsheet you will indicate which column is the email address,<br />
	</span>
	<span class="pageinstructions">
		and which columns will be merged to the email template and points to award.
	</span>
	<br /><br />
	<span class="pageinstructions">
		Do not use this for Henkel Branch HQ accounts!
	</span>
	<br /><br />
	<a href="<cfoutput>#CurrentPage#?pgfn=upload</cfoutput>" class="actionlink">Upload Spreadsheet</a>
<cfelseif url.pgfn EQ "upload">
	<!--- Page Title --->
	<span class="pagetitle">Upload the Spreadsheet</span>
	<br /><br />
	<span class="pageinstructions">
	Before uploading the spreadsheet, it needs to be saved in the proper format.<br><br>
	<ol>
		<li>Open the file in Excel.</li><br><br>
		<li>Save the file as a comma-separated values (csv) file.
			<ul type="disc">
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
	<form method="post" action="#CurrentPage#" name="uploadSpreadsheet" enctype="multipart/form-data">
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="submitUpload" value="  Upload  " >
	</form>
	</cfoutput>
	</span>
<cfelseif url.pgfn EQ "email_setup">
	<cfset hasFile = true>
	<cftry>
		<cffile action="read" variable="thisData" file="#application.FilePath#admin/upload/#thisFileName#.csv">
		<cfcatch><cfset hasFile = false></cfcatch>
	</cftry>
	<cfif hasFile>
		<cfset thisData = Replace(thisData,"#CHR(13)##CHR(10)#","|","ALL")>
		Here is the first line of your spreadsheet:<br>
		<cfset thisLineOne = ListFirst(thisData,"|")>
		<cfset colNum = 1>
		<cfloop list="#thisLineOne#" index="thisCol">
			<cfoutput>#colNum#) #thisCol#</cfoutput><br>
			<cfset colNum = colNum + 1>
		</cfloop>
		<cfoutput>
		<br>
		<form method="post" action="#CurrentPage#" name="emailSetup">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<tr class="BGdark">
	<td colspan="2" class="TEXTheader"> First row is header  <input type="checkbox" name="hasHeader" value="1" <cfif hasHeader>checked</cfif> /> <i>Uncheck this if the first row is a data row.</i></td>
	</tr>

		<tr><td align="right">Which column is the email address?</td><td><input type="text" name="email" value="#email#" size="5" maxlength="3"></td></tr>
		<tr><td align="right">Which column is the CC address?</td><td><input type="text" name="ccmail" value="#ccmail#" size="5" maxlength="3"></td></tr>
		<tr><td align="right">Which column is the first name?</td><td><input type="text" name="firstname" value="#firstname#" size="5" maxlength="3"> &nbsp; Merge code: USER-FIRST-NAME</td></tr>
		<tr><td align="right">Which column is the last name?</td><td><input type="text" name="lastname" value="#lastname#" size="5" maxlength="3"> &nbsp; Merge code: USER-LAST-NAME</td></tr>
		<tr><td align="right">Which column is the points?</td><td><input type="text" name="points" value="#points#" size="5" maxlength="3"> &nbsp; Merge code: USER-POINTS</td></tr>
		<tr><td align="right">Which column is the zip code?</td><td><input type="text" name="zipcode" value="#zipcode#" size="5" maxlength="3"> &nbsp; Used to filter non-US zip codes</td></tr>
		<td valign="bottom" align="right"><br>Optional Merge Codes:</td><td></td>
		<tr><td align="right">VALUED-SELLING-ACTIVITY : </td><td><input type="text" name="activity" value="#activity#" size="30" maxlength="255"></td></tr>
		<tr><td align="right">MERGE-COLUMN-1 : </td><td><input type="text" name="merge1" value="#merge1#" size="5" maxlength="3"></td></tr>
		<tr><td align="right">MERGE-COLUMN-2 : </td><td><input type="text" name="merge2" value="#merge2#" size="5" maxlength="3"></td></tr>
		<tr><td align="right">MERGE-COLUMN-3 : </td><td><input type="text" name="merge3" value="#merge3#" size="5" maxlength="3"></td></tr>
	<tr>
	<td valign="bottom" align="right"><br>Note for points entry:</td><td></td>
	</tr>
	<tr>
	<td valign="top" align="center" colspan="2"><textarea name="note" cols="70" rows="3">#note#</textarea></td>
	</tr>
	<tr class="BGlight1">
		<td align="right">Send Email to Recipients?</td>
		<td>
			<input type="radio" name="send_email" value="1" onClick="showThis('email_lines')" <cfif send_email>checked</cfif>> Yes
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="send_email" value="0" onClick="hideThis('email_lines')" <cfif NOT send_email>checked</cfif>> No
		</td>
	</tr>
	</table>
	<cfquery name="SelectEmailTemplates" datasource="#application.ds#">
		SELECT ID, email_title
		FROM #application.database#.email_templates
		WHERE is_available = 1
		ORDER BY email_title
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%" id="email_lines" style="display:<cfif send_email>block<cfelse>none</cfif>">
	<tr class="BGlight1">
		<td align="right">EXISTING Users:</td>
		<td>
			<select name="ex_template_ID" id="ex_template_ID">
				<cfloop query="SelectEmailTemplates">
				<option value="#ID#" <cfif isDefined("form.ex_template_ID") AND form.ex_template_ID EQ ID>selected</cfif>>#email_title#</option>
				</cfloop>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview('ex_template_ID');return false;">preview</a>
		</td>
	</tr>
	<tr class="BGlight1">
		<td align="right">PENDING Users:</td>
		<td>
			<select name="pe_template_ID" id="pe_template_ID">
				<cfloop query="SelectEmailTemplates">
				<option value="#ID#" <cfif isDefined("form.pe_template_ID") AND form.pe_template_ID EQ ID>selected</cfif>>#email_title#</option>
				</cfloop>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview('pe_template_ID');return false;">preview</a>

		</td>
	</tr>
	<!---
	<tr class="BGlight1">
	<td align="right">email template:</td>
	<td>
		<select name="template_ID" id="template_ID">
			<option value="">--- Select Template ---</option>
			<cfloop query="getTemplates">
				<option value="#getTemplates.ID#" <cfif template_ID EQ getTemplates.ID>selected</cfif>>#getTemplates.email_title#</option>
			</cfloop>
		</select>
		<!--- &nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview();return false;">preview selected template</a> --->
	</td>
	</tr>
	--->
	
	<tr class="BGlight1">
	<td align="right">email subject:</td><td><input type="text" name="email_subject" value="#email_subject#" size="45" />
</td>
	</tr>
	
	<!--- <tr class="BGlight1">
	<td align="right">sender name:</td><td><input type="text" name="from_name" value="#from_name#" size="45" />
</td>
	</tr> --->
	
	<tr class="BGlight1">
	<td align="right">sender email address:</td><td><input type="text" name="from_email" value="#application.AwardsFromEmail#" size="45" readonly />
</td>
	</tr>
	
	<tr class="BGlight1">
	<td align="right">send bounced emails to:</td><td><input type="text" name="failto" value="#failto#" size="45" />
</td>
	</tr>

	<tr class="BGlight1">
	<td align="right">send CC of all emails to:</td><td><input type="text" name="cc_email" value="#cc_email#" size="45" />
</td>
	</tr>

	<tr class="BGdark">
	<td class="TEXTheader" colspan="2" nowrap="nowrap">Test Email</td>
	</tr>
	<tr class="BGlight2">
	<td colspan="2"><img src="../pics/contrls-desc.gif" > Enter one or more emails (separated by commas) to receive the test email.</td>
	</tr>
	
	<tr class="BGlight1">
	<td colspan="2" align="center"><input type="text" name="testing_email" size="80" value="" /></td>
	</tr>
	
	<tr class="BGlight1">
	<td colspan="2" align="center" id="submit_cell_1"><input type="submit" name="submitTest" value="Send Test Email To Above Addresses" /></td>
	</tr>
	</table>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="BGlight1">
	<td colspan="2" align="center" id="submit_cell_2"><input type="submit" name="submitEmail" value="Post Points<!---  and Send Email To Entire List --->" /></td>
	</tr>
	</table>
</cfoutput>
	<cfelse>
		<span class="pageinstructions">Sorry, but the data was lost.  You'll have to upload it again.</span>
	</cfif>
<cfelseif url.pgfn EQ "done">
	<cfoutput>
	#num_sent# emails sent.<br><br>
	</cfoutput>
</cfif>


<cfoutput>#DisplayResults#</cfoutput>

<!--- 
		<cfloop list="#thisData#" index="thisRow" delimiters="|">
		</cfloop>

 --->
 <cfinclude template="includes/footer.cfm">
