<!--- function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<cfparam name="url.pgfn" default="home">
<cfparam name="alert_msg" default="">
<cfparam name="from_name" default="From Name">
<cfparam name="from_email" default="#application.AwardsFromEmail#">
<cfparam name="email_subject" default="">
<cfparam name="failto" default="#application.AwardsFromEmail#">
<cfparam name="email_text" default="">
<cfparam name="send_to" default="0">
<cfparam name="hasHeader" default="1">
<cfparam name="template_ID" default="">
<cfparam name="email" default="">
<cfparam name="firstname" default="">
<cfparam name="lastname" default="">
<cfparam name="points" default="">
<cfparam name="branchnum" default="">
<cfparam name="note" default="">

<cfparam name="testing_email" default="">

<cfset num_sent = 0>
<cfset DisplayResults = "">

<cfif IsDefined("form.submitUpload")>
	<cfif form.upload_txt NEQ "">
		<cfset result = FLGen_UploadThis("upload_txt","admin/upload/","simple")>
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

<cfif IsDefined("form.submitEmail")>
	<cfset hasFile = true>
	<cftry>
		<cffile action="read" variable="thisData" file="#application.AbsPath#admin/upload/simple.csv">
		<cfcatch><cfset hasFile = false></cfcatch>
	</cftry>
	<cfif NOT hasFile>
		<cfset alert_msg="Sorry, but the data was lost.  You will have to upload it again.">
	<cfelseif NOT isNumeric(email) OR email LTE 0>
		<cfset alert_msg="Please enter the email address column number.">
	<cfelseif NOT IsNumeric(template_ID)>
		<cfset alert_msg="Please select a template.">
	<cfelseif NOT send_to AND testing_email EQ "">
		<cfif isDefined("form.send_to")>
			<cfset alert_msg="If you want to send to everyone on the list, you must check the box next to Final Broadcast.">
		<cfelse>
			<cfset alert_msg="Please enter an email address to send the test to.">
		</cfif>
	</cfif>
	<cfif alert_msg EQ "">
		<cfquery name="getTemplate" datasource="#application.ds#">
			SELECT email_text
			FROM #application.database#.email_templates
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#template_ID#">
		</cfquery>
		<cfset email_text = getTemplate.email_text>
		<cfset thisData = Replace(thisData,"#CHR(13)##CHR(10)#","|","ALL")>
		<cfset first_line = true>
		<cfif NOT hasHeader>
			<cfset first_line = false>
		</cfif>
		<cfset DisplayResults = '<table width="100%" cellpadding="3"><tr><td>Email</td><td>User</td><td>Password</td><td align="right">Points</td><tr>'>
		<cfloop list="#thisData#" index="thisLine" delimiters="|">
			<cfif NOT first_line>
				<cfset thisEmail = "">
				<cfset thisFirstname = "">
				<cfset thisLastname = "">
				<cfset thisPoints = "">
				<cfset thisBranchNum = "">
				<cfset col_num = 1>
				<cfloop list="#thisLine#" index="thisCol">
					<cfif col_num EQ email>
						<cfset thisEmail = thisCol>
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
					<cfif branchnum NEQ "" AND col_num EQ branchnum>
						<cfset thisBranchNum = thisCol>
					</cfif>
					<cfset col_num = col_num + 1>
				</cfloop>
				<cfset DisplayResults = DisplayResults & '<tr><td>#thisEmail#</td><td>#thisFirstName# #thisLastName#</td>'>
				<!--- Look up user --->
				<cfif thisEmail NEQ "" AND FLGen_IsValidEmail(thisEmail)>
					<cfquery name="getExistingUser" datasource="#application.DS#">
						SELECT ID, username, fname, lname, expiration_date, idh
						FROM #application.database#.program_user
						WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisEmail#">
						AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
						AND registration_type = 'BranchHQ'
					</cfquery>
					<cfif getExistingUser.recordcount EQ 1>
						<cfset send_email = true>
						<cfset DisplayResults = DisplayResults & '<td>#getExistingUser.username#</td>'>
					<cfelse>
						<cfset DisplayResults = DisplayResults & '<td>NOT FOUND</td>'>
						<cfset send_email = false>
					</cfif>
				<cfelse>
					<cfset DisplayResults = DisplayResults & '<td>BAD EMAIL</td>'>
					<cfset send_email = false>
				</cfif>
				<cfif send_email>
					<cfset email_message = Replace(email_text,'USER-FIRST-NAME',thisFirstname,'all')>
					<cfset email_message = Replace(email_message,'USER-NAME',getExistingUser.username,'all')>
					<cfset email_message = Replace(email_message,'USER-LAST-NAME',thisLastname,'all')>
					<cfset email_message = Replace(email_message,'USER-POINTS-EARNED',thisPoints,'all')>
					<cfset email_message = Replace(email_message,'BRANCH-NUMBER',thisBranchNum,'all')>
					<cfset email_message = Replace(email_message,'DATE-TODAY',DateFormat(Now(),'mm/dd/yyyy'),'all')>
					<cfif NOT send_to>
						<cfif num_sent EQ 0>
							<!--- Send tests --->
							<cfmail to="#testing_email#" from="#from_email#" subject="#email_subject#" type="html">
#email_message#
							</cfmail>
							<cfset url.pgfn = "email_setup">
						</cfif>
					<cfelse>
						<!--- Send to all on list --->
						<cfmail to="#thisEmail#" from="#from_email#" subject="#email_subject#" type="html">
#email_message#
						</cfmail>
					</cfif>
					<cfset num_sent = num_sent + 1>
					<cfif send_to>
						<cfquery name="AwardPoints" datasource="#application.DS#">
							INSERT INTO #application.database#.awards_points (
								created_user_ID, created_datetime, user_ID, points, notes)
							VALUES (
								<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
								'#FLGen_DateTimeToMySQL()#',
								<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getExistingUser.ID#" maxlength="10">,
								<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thisPoints#">,
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#note#">
							)
						</cfquery>
					</cfif>
					<cfset DisplayResults = DisplayResults & '<td>#thisPoints#</td>'>
				<cfelse>
					<cfset DisplayResults = DisplayResults & '<td>---</td>'>
				</cfif>
			</cfif>
			<cfset first_line = false>
		</cfloop>
		<cfif send_to>
			<cfset url.pgfn = "done">
		</cfif>
	</cfif>
	<cfif alert_msg NEQ "">
		<cfset url.pgfn = "email_setup">
	</cfif>
</cfif>


<cfset leftnavon = 'henkel_import_points'>
<cfinclude template="includes/header.cfm">

<span class="pagetitle">
	Simple points uploader
	<cfif url.pgfn NEQ "home">
		<a href="<cfoutput>#CurrentPage#</cfoutput>">Start Over</a>
	</cfif>
</span>
<cfif url.pgfn EQ "home">
	<!--- Return link --->
	<span class="pageinstructions">Return to the <a href="henkel_import_points.cfm" class="actionlink">Import Points Main Page</a></span>
	<br><br>
</cfif>
<br /><br />
<span class="alert">REMOVE ALL COMMAS FROM YOUR DATA!!!!</span>
<br /><br />

<cfif url.pgfn EQ "home">
	<!--- Page Title --->
	<span class="pageinstructions">
		This is a points uploader that allows you to upload points and send an email to a set of people in a spreadsheet.<br /><br />
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
		This WILL ONLY work for Branch HQ accounts!
	</span>
	<br /><br />
	<a href="<cfoutput>#CurrentPage#</cfoutput>?pgfn=upload" class="actionlink">Upload Spreadsheet</a>
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
		<cffile action="read" variable="thisData" file="#application.AbsPath#admin/upload/simple.csv">
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
		<tr><td align="right">Which column is the first name?</td><td><input type="text" name="firstname" value="#firstname#" size="5" maxlength="3"> &nbsp; Merge code: USER-FIRST-NAME</td></tr>
		<tr><td align="right">Which column is the last name?</td><td><input type="text" name="lastname" value="#lastname#" size="5" maxlength="3"> &nbsp; Merge code: USER-LAST-NAME</td></tr>
		<tr><td align="right">Which column is the points?</td><td><input type="text" name="points" value="#points#" size="5" maxlength="3"> &nbsp; Merge code: USER-POINTS</td></tr>
		<tr><td align="right">Which column is the branch number?</td><td><input type="text" name="branchnum" value="#branchnum#" size="5" maxlength="3"> &nbsp; Merge code: BRANCH-NUMBER</td></tr>

	
	<tr>
	<td valign="bottom" align="right"><br>Note for points entry:</td><td></td>
	</tr>
	<tr>
	<td valign="top" align="center" colspan="2"><textarea name="note" cols="70" rows="3">#note#</textarea></td>
	</tr>
	
	
	<cfquery name="getTemplates" datasource="#application.ds#">
		SELECT ID, email_title
		FROM #application.database#.email_templates
		WHERE is_available = 1
		ORDER BY email_title
	</cfquery>
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
	<td colspan="2" align="center" id="submit_cell_1"><input type="submit" name="submitEmail" value="Send Test Email To Above Addresses" /></td>
	</tr>
	<cfif testing_email NEQ "">
	<tr class="BGdark">
	<td colspan="2" class="TEXTheader"> Final Broadcast  <input type="checkbox" name="send_to" value="1" /></td>
	</tr>
	
	<tr class="BGlight1">
	<td colspan="2" align="center" id="submit_cell_2"><input type="submit" name="submitEmail" value="Post Points and Send Email To Entire List" /></td>
	</tr>
	</cfif>
		</table>
</cfoutput>
	<cfelse>
		<span class="pageinstructions">Sorry, but the data was lost.  You'll have to upload it again.</span>
	</cfif>
<cfelseif url.pgfn EQ "done">
	<cfoutput>
	#num_sent# emails sent.<br><br>
	</cfoutput>
	<cfcookie name="efname" expires="now">
</cfif>

<cfoutput>#DisplayResults#</cfoutput>

<!--- 
		<cfloop list="#thisData#" index="thisRow" delimiters="|">
		</cfloop>

 --->
 <cfinclude template="includes/footer.cfm">
