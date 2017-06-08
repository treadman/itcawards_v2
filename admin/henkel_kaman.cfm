<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->

<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000112)>

<cfparam name="form.emailFrom" default="#application.AwardsFromEmail#">
<cfparam name="form.emailSubject" default="Award Notification">
<cfparam name="form.userIDList" default="">

<cfparam  name="pgfn" default="home">

<cfset HenkelID = 1000000066>
<cfset KamanID = 1000000010>
<cfset SubprogramID = 28>

<cfset alert_msg = "">
<cfset results = "">

<cfif isDefined("form.template_ID") AND isNumeric(form.template_ID)>
	<cfquery name="FindTemplateText" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.template_ID#">
	</cfquery>
	<cfif FindTemplateText.recordcount EQ 1>
		<cfset thisTemplateText = FindTemplateText.email_text>
	</cfif>
</cfif>

<cfif isDefined("form.process") OR isDefined("form.test_email")>
	<cfif form.userIDList EQ "">
		<cfset alert_msg = "There are no users to process.">
	<cfelseif isDefined("form.test_email") AND NOT FLGen_IsValidEmail(form.emailTo)>
		<cfset alert_msg = "Please enter a valid email address for the test recipient.">
	<cfelseif NOT isDefined("thisTemplateText")>
		<cfset alert_msg = "Selected email template not found!">
	<cfelseif NOT FLGen_IsValidEmail(form.emailFrom)>
		<cfset alert_msg = "Please enter a valid email address for the from address.">
	<cfelseif form.emailSubject EQ "">
		<cfset alert_msg = "Please enter a subject for the email.">
	<cfelse>
		<cfloop list="#form.userIDList#" index="thisID">
			<cfif isDefined("form.username_#thisID#")>
				<cfset thisUsername = trim(evaluate("form.username_#thisID#"))>
				<cfif thisUsername EQ "">
					<cfset alert_msg = "One of the username fields is blank.">
				<cfelse>
					<cfif NOT isNumeric(Right(thisUsername,4))>
						<cfset alert_msg = thisUsername & " does not end in 4 numbers.">
					</cfif>
				</cfif>
				<cfif alert_msg NEQ "">
					<cfbreak>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	<cfif alert_msg EQ "">
		<cfset NumCreated = 0>
		<cfset transferNote = "Transferred points from Henkel U.S. to Kaman">
		<cfloop list="#form.userIDList#" index="thisUserID">
			<!--- Get the user record --->
			<cfquery name="HenkelUser" datasource="#application.DS#">
				SELECT ID, username, fname, lname, email, phone, is_active, idh, registration_type,
					ship_company, ship_address1, ship_city, ship_state, ship_zip
				FROM #application.database#.program_user
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisUserID#">
			</cfquery>
			<!--- Get the found Kaman ID (if defined) --->
			<cfset thisKamanID = 0>
			<cfif isDefined("form.kamanID_#thisUserID#")>
				<cfset thisKamanID = evaluate("form.kamanID_#thisUserID#")>
			</cfif>
			<!--- Get the points (This should always be defined) --->
			<cfset thisPoints = 0>
			<cfif isDefined("form.points_#thisUserID#")>
				<cfset thisPoints = evaluate("form.points_#thisUserID#")>
			</cfif>
			<!--- Get the username that was entered (This should always be defined as either hidden or entered) --->
			<cfset thisUsername = "">
			<cfif isDefined("form.username_#thisUserID#")>
				<cfset thisUsername = evaluate("form.username_#thisUserID#")>
			</cfif>
			<cfif thisPoints GT 0>
				<cfif thisKamanID EQ 0>
					<cfif isDefined("form.process")>
						<!--- Kaman user not found using eamil so username was entered --->
						<cfquery name="CheckExists" datasource="#application.DS#">
							SELECT ID
							FROM #application.database#.program_user
							WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisUsername#">
							AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#KamanID#">
						</cfquery>
						<cfif CheckExists.recordcount EQ 1>
							<cfset thisKamanID = CheckExists.ID>
							<cfset results = results & "#thisUsername#, that you entered, was in the Kaman program">
						<cfelseif CheckExists.recordcount GT 1>
							<cfset thisKamanID = -1>
						<cfelse>
							<cfset NumCreated = NumCreated + 1>
							<!--- Add new Kaman user --->
							<cflock name="program_userLock" timeout="10">
								<cftransaction>
									<cfquery name="InsertQuery" datasource="#application.DS#">
										INSERT INTO #application.database#.program_user
											(created_user_ID, created_datetime, username, fname, lname, email, phone, is_active, ship_company, ship_address1, ship_city, ship_state, ship_zip, program_ID, idh, registration_type)
										VALUES
										(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#',
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisUsername#" maxlength="16">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(HenkelUser.fname)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(HenkelUser.lname)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.email#" maxlength="128" null="#YesNoFormat(NOT Len(Trim(HenkelUser.email)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.phone#" maxlength="35" null="#YesNoFormat(NOT Len(Trim(HenkelUser.phone)))#">,
											<cfqueryparam cfsqltype="cf_sql_tinyint" value="#HenkelUser.is_active#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(HenkelUser.is_active)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.ship_company#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(HenkelUser.ship_company)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.ship_address1#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(HenkelUser.ship_address1)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.ship_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(HenkelUser.ship_city)))#">,
											<cfqueryparam cfsqltype="cf_sql_char" value="#HenkelUser.ship_state#" maxlength="2" null="#YesNoFormat(NOT Len(Trim(HenkelUser.ship_state)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.ship_zip#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(HenkelUser.ship_zip)))#">,
											<cfqueryparam cfsqltype="cf_sql_integer" value="#KamanID#" maxlength="10">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.idh#" maxlength="16" null="#YesNoFormat(NOT Len(Trim(HenkelUser.idh)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelUser.registration_type#" maxlength="16" null="#YesNoFormat(NOT Len(Trim(HenkelUser.registration_type)))#">)
									</cfquery>
									<cfquery name="getID" datasource="#application.DS#">
										SELECT Max(ID) As MaxID FROM #application.database#.program_user
									</cfquery>
									<cfset thisKamanID = getID.MaxID>
								</cftransaction>
							</cflock>
							<cfset results = results & "#thisUsername# was created in the Kaman program">
						</cfif>
					</cfif>
				<cfelse>
					<cfset results = results & "#thisUsername#, found using email address, was in the Kaman program">
				</cfif>
				<!--- Now we have an ID for transfering points --->
				<cfif thisKamanID LT 0>
					<cfset alert_msg = alert_msg & "#thisUsername# is duplicated in the Kaman program!\n">
				<cfelseif thisKamanID EQ 0>
					<cfif isDefined("form.process")>
						<!--- This shouldn't happen --->
						<cfset alert_msg = alert_msg & "#thisUsername# had a problem! (Perhaps a lock failure)\n">
					</cfif>
				<cfelse>
					<cfif isDefined("form.process")>
						<cfset results = results & " - #thisPoints# points transferred.<br />">
						<!--- Add a negative entry for the Henkel ID --->
						<cfset thisNote = "Transferred #thisPoints# to Kaman account">
						<cfquery name="InsertNegativePoints" datasource="#application.DS#">
							INSERT INTO #application.database#.awards_points
								(created_user_ID, created_datetime, user_ID, points, notes)
							VALUES
								('#FLGen_adminID#', '#FLGen_DateTimeToMySQL()#',
								<cfqueryparam cfsqltype="cf_sql_integer" value="#HenkelUser.ID#" maxlength="10">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="-#thisPoints#" maxlength="8">,
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#thisNote#">)
						</cfquery>
						<!--- Add a positive entry for the Kaman ID --->
						<cfset thisNote = "Transferred #thisPoints# from Henkel account">
						<cfquery name="InsertPositivePoints" datasource="#application.DS#">
							INSERT INTO #application.database#.awards_points
								(created_user_ID, created_datetime, user_ID, points, notes)
							VALUES
								('#FLGen_adminID#', '#FLGen_DateTimeToMySQL()#',
								<cfqueryparam cfsqltype="cf_sql_integer" value="#thisKamanID#" maxlength="10">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#thisPoints#" maxlength="8">,
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#thisNote#">)
						</cfquery>
						<!--- Add a positive entry for the Kaman ID --->
						<cfquery name="InsertPositiveSubPoints" datasource="#application.DS#">
							INSERT INTO #application.database#.subprogram_points
								(created_user_ID, created_datetime, subprogram_ID, user_ID, subpoints)
							VALUES
								('#FLGen_adminID#', '#FLGen_DateTimeToMySQL()#',
								<cfqueryparam cfsqltype="cf_sql_integer" value="#SubprogramID#" maxlength="10">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#thisKamanID#" maxlength="10">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#thisPoints#" maxlength="8">)
						</cfquery>
						<!--- Add an entry in the transfer table --->
						<cfquery name="InsertTransfer" datasource="#application.DS#">
							INSERT INTO #application.database#.points_transfer
								(from_user_ID, to_user_ID, points, transfer_datetime, notes)
							VALUES (
								<cfqueryparam cfsqltype="cf_sql_integer" value="#HenkelUser.ID#" maxlength="10">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#thisKamanID#" maxlength="10">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#thisPoints#" maxlength="8">,
								'#FLGen_DateTimeToMySQL()#',
								<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#transferNote#">)
						</cfquery>
					</cfif>
					<cfset thisUserText = Replace(thisTemplateText,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
					<cfset thisUserText = Replace(thisUserText,"USER-NAME",thisUsername,"all")> 
					<cfset thisUserText = Replace(thisUserText,"USER-FIRST-NAME",HenkelUser.fname,"all")>
					<cfset thisUserText = Replace(thisUserText,"USER-LAST-NAME",HenkelUser.lname,"all")>
					<cfset thisUserText = Replace(thisUserText,"USER-TRANSFERRED-POINTS",thisPoints,"all")>
					<cfif isDefined("form.test_email") AND thisUsername NEQ "">
						<cfmail to="#form.emailTo#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
TESTING:<br />
Would have gone to #HenkelUser.email#<br />
<hr />
#thisUserText#
						</cfmail>
						<cfbreak>
					<cfelse>
						<cfmail failto="#Application.ErrorEmailTo#"to="#HenkelUser.email#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
#thisUserText#
						</cfmail>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfif isDefined("form.test_email")>
			<cfset alert_msg = "Test email sent to #form.emailTo#.">
		<cfelse>
			<cfif alert_msg EQ "">
				<cfset alert_msg = "Points transfer complete.">
			<cfelse>
				<cfset alert_msg = alert_msg & "Points transfered for those users without problems.\n">
			</cfif>
			<cfset pgfn = "done">
		</cfif>
	</cfif>

<cfelseif isDefined("form.upload")>
	<cfset txt_new_name = "">
	<cfif form.upload_txt NEQ "">
		<!--- Upload txt file --->
		<cftry>
			<!--- TODO: FIX THIS UPLOAD --->
			<cfset this_txt = FLGen_UploadThis(	FileFieldName="upload_txt",
												DestinationPath="/",
												NewName="kaman_names")>
			<cfset this_txt = FLGen_UploadThis(	FileFieldName="upload_txt",
												DestinationPath="itc/",
												NewName="kaman_names",
												mUSERNAME="dataxfer",
												mPASSWORD="e><p0sed",
												mSERVER="db.FIXTHIS.com",
												F_ServerPath="/inetpub/wwwroot/data/")>

			<cfset txt_original_name = ListGetAt(this_txt,1)>
			<cfset txt_new_name = ListGetAt(this_txt,2)>
			<cfcatch>
				<cfset alert_msg = "Error attempting to upload the spreadsheet FIX THIS.">
			</cfcatch>
		</cftry>
		<cfif isDefined("txt_original_name")>
			<cfif txt_original_name EQ "false">
				<cfset alert_msg = "Error attempting to upload the spreadsheet.">
			</cfif>
		</cfif>
		<cfif alert_msg EQ "">
			<!--- Get the uploaded data into the data_import file --->
			<cfquery name="TruncateHenkelKaman" datasource="#application.DS#">
				TRUNCATE #application.database#.henkel_kaman
			</cfquery>
			<cfquery name="LoadInFileHenkelKaman" datasource="#application.DS#">
				LOAD DATA INFILE '#application.AbsPath#kaman_names.csv'
				INTO TABLE #application.database#.henkel_kaman
				FIELDS OPTIONALLY ENCLOSED BY '"' TERMINATED BY ','
				LINES TERMINATED BY '\r\n'
				IGNORE 1 LINES
				(four_digit, first_name, last_name)
			</cfquery>
			<cfset alert_msg = "The names and 4 digits table has been updated.">
			<cfset pgfn = "list">
		</cfif>
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->


<cfset leftnavon = "henkel_kaman">
<cfset request.main_width = 900>
<cfinclude template="includes/header.cfm">



<span class="pagetitle">Transfer Points from Henkel U.S. Program Users to Kaman Program Users</span>
<br /><br />

<cfif pgfn NEQ "home">
	<!--- Return link --->
	<span class="pageinstructions">Return to the <a href="<cfoutput>#CurrentPage#</cfoutput>" class="actionlink">Henkel/Kaman Transfer Main Page</a></span>
	<br><br>
</cfif>

<cfif pgfn EQ "home">
	<cfoutput>
	<a href="#CurrentPage#?pgfn=upload" class="actionlink">Upload Names and 4-digits Spreadsheet</a><br /><br />
	<a href="#CurrentPage#?pgfn=list" class="actionlink">Process List of Henkel/Kaman Users</a><br /><br />
	<a href="henkel_kaman_report.cfm" class="actionlink">Henkel/Kaman Points Transfer Report</a><br />
	</cfoutput>
<cfelseif pgfn EQ "upload">
	<span class="pagetitle">Upload the Kaman Names and 4-Digits Spreadsheet</span>
	<br /><br />
	<span class="pageinstructions">
	Before uploading the spreadsheet, it needs to be saved in the proper format.<br><br>
	<ol>
		<li>Open the file in Excel.</li><br><br>
		<li>Save the file as a comma-separated values (csv) file.
			<ul type="disc">
				<li>The fields should be in this order: <strong>4-digit, first_name, last_name.</strong><br><strong>Delete *ALL* other columns</strong></li>
				<li>Click "File" (or Office Button in Office 2007) then "Save As".</li>
				<li>In the "Save As" dialog window, under the "File name" input field is a drop-down select box for "Save as type:".</li>
				<li>Scroll down to select the "CSV (Comma Delimited) (*.csv)" option.</li>
				<li>If the xls file has more than one worksheet you will get a window asking "The selected file type does not support ... multiple worksheets."  Click "OK".</li>
				<li>Then you'll probably get a message saying "export...csv may contain features that are incompatible..."  Click "Yes"</li>
			</ul>
		</li><br>
		<li>When you close Excel or close the file, Excel asks again to save the csv file.  There is no need to do this, so click "No".</li><br><br>
	</ol>
	<cfoutput>
	<form method="post" action="#CurrentPage#" name="uploadHenkelKaman" enctype="multipart/form-data">
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="upload" value="  Upload  " >
	</form>
	</cfoutput>
	</span>
<cfelseif pgfn EQ "list">
	<cfif form.userIDList EQ "">
		<!--- <cfquery name="HenkelKamanUsers" datasource="#application.DS#">
			SELECT DISTINCT u.ID
			FROM #application.database#.program_user u
			LEFT JOIN #application.database#.henkel_distributor d ON d.idh = u.idh
			WHERE u.program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HenkelID#">
			AND u.idh <> <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="999999">
			AND d.company_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="Kaman%">
			AND u.registration_type <> 'BranchHQ'
			ORDER BY u.lname, u.fname
		</cfquery> --->
		<cfquery name="HenkelKamanUsers" datasource="#application.DS#">
			SELECT DISTINCT h.ID
			FROM #application.database#.program_user h
			LEFT JOIN #application.database#.program_user k on k.email = h.email 
			WHERE h.program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HenkelID#">
			AND k.program_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#KamanID#">
			AND h.registration_type <> 'BranchHQ'
			ORDER BY h.lname, h.fname
		</cfquery>
		<cfset form.userIDList = ValueList(HenkelKamanUsers.ID)>
	</cfif>
	<cfif ListLen(form.userIDList) EQ 0>
		<span class="alert"><br>No records found.<br><br></span>
	<cfelse>
		<form method="post" action="<cfoutput>#CurrentPage#</cfoutput>?pgfn=list" name="HenkelKamanForm">
			<table cellpadding="5" cellspacing="1" border="0">
				<tr class="contenthead">
					<td class="headertext">Select Template:</td>
				</tr>
				<tr class="content">
					<td>
						<cfquery name="SelectEmailTemplates" datasource="#application.DS#">
							SELECT e.ID, e.email_title 
							FROM #application.database#.email_templates e
							JOIN #application.database#.xref_program_email x ON e.ID = x.email_alert_ID
							WHERE e.is_available = 1
								AND x.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#henkelID#">
							ORDER BY e.email_title ASC
						</cfquery>
						<select id="template_ID" name="template_ID">
							<cfoutput query="SelectEmailTemplates">
								<option value="#SelectEmailTemplates.ID#" <cfif isDefined("form.template_ID") AND form.template_ID EQ SelectEmailTemplates.ID>selected</cfif>>#SelectEmailTemplates.email_title#</option>
							</cfoutput>
						</select>
						&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" onClick="openPreview();return false;">preview selected template</a>
						<script>
						TheWindow = null;
						function openPreview() {
							// if a window exists and is open, close it
							if (TheWindow != null) {
								TheWindow.close();
							}
							// find the selected one in the select
							previewId = document.getElementById('template_ID');
							previewIdValue = previewId.options[previewId.selectedIndex].value;
							
							// open new window with preview	
							TheWindow = window.open('email_alert_preview.cfm?ID='+previewIdValue);
	
						}
						</script>
					</td>
				</tr>
				<tr class="contenthead">
					<td class="headertext">From address and subject for all emails:</td>
				</tr>
				<tr class="content">
					<td>&nbsp;&nbsp;&nbsp;&nbsp;From:  <input type="text" name="emailFrom" value="<cfoutput>#application.AwardsFromEmail#</cfoutput>" size="40" readonly></td>
				</tr>
				<tr class="content">
					<td>Subject:  <input type="text" name="emailSubject" value="<cfoutput>#form.emailSubject#</cfoutput>" size="40"></td>
				</tr>
				<tr class="contenthead">
					<td class="headertext">Test Email:</td>
				</tr>
				<tr class="content">
					<td>&nbsp;&nbsp;Recipient:  <input type="text" name="emailTo" value="" size="40"></td>
				</tr>
				<tr class="content">
					<td align="center">
						<input type="submit" name="test_email" value="  Send Test Email  ">
					</td>
				</tr>
			</table>
			<br /><br />
			<table cellpadding="5" cellspacing="1" border="0">
				<!--- header row --->
				<tr class="contenthead">
					<td class="headertext">Name</td>
					<td class="headertext">Email Address</td>
					<td class="headertext"><span title="Registration Type" style="cursor:pointer;">Reg</span></td>
					<td class="headertext" align="right">Pts</td>
					<td class="headertext">Username</td>
				</tr>
				<cfset PointsFoundList = "">
				<cfset counter = 0>
				<cfloop list="#form.userIDList#" index="thisUserID">
					<cfquery name="Positive" datasource="#application.DS#">
						SELECT IFNULL(SUM(points),0) AS points
						FROM #application.database#.awards_points
						WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisUserID#">
					</cfquery>
					<cfquery name="Negative" datasource="#application.DS#">
						SELECT IFNULL(SUM(points_used),0) AS points
						FROM #application.database#.order_info
						WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisUserID#">
					</cfquery>
					<cfset thisPoints = Positive.points - Negative.points>
					<cfif thisPoints GT 0>
						<cfset PointsFoundList = ListAppend(PointsFoundList,thisUserID)>
						<cfset counter = counter + 1>
						<!--- Get the user record --->
						<cfquery name="HenkelUser" datasource="#application.DS#">
							SELECT username, fname, lname, email, phone, is_active, idh, registration_type,
								ship_company, ship_address1, ship_city, ship_state, ship_zip
							FROM #application.database#.program_user
							WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisUserID#">
						</cfquery>
						<!--- Find them in Kaman by email address --->
						<cfquery name="Kaman" datasource="#application.DS#">
							SELECT ID, username, fname, lname, email
							FROM #application.database#.program_user
							WHERE program_ID <> <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HenkelID#">
							AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#HenkelUser.email#">
						</cfquery>
						<cfoutput>
						<tr class="#Iif(((counter MOD 2) is 0),de('content'),de('content2'))#">
							<td><cfif NOT HenkelUser.is_active><span class="alert" title="Not Active">&nbsp;*&nbsp;</span></cfif>#HenkelUser.fname# #HenkelUser.lname#</td>
							<td>#HenkelUser.email#</td>
							<td><span title="#HenkelUser.registration_type#" style="cursor:pointer;">#Left(HenkelUser.registration_type,2)#</span></td>
							<td align="right">#thisPoints#</td>
							<td>
								<cfif Kaman.recordcount EQ 0>
									<cfif isDefined("form.username_#thisUserID#")>
										<cfset thisUsername = evaluate("form.username_#thisUserID#")>
									<cfelse>
										<cfquery name="KamanNames" datasource="#application.DS#">
											SELECT four_digit
											FROM #application.database#.henkel_kaman
											WHERE first_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#HenkelUser.fname#">
											AND last_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListFirst(HenkelUser.lname)#">
										</cfquery>
										<cfset fourDigits = "">
										<cfif KamanNames.recordcount EQ 1>
											<cfset fourDigits = KamanNames.four_digit>
										</cfif>
										<cfset thisUsername = lcase(Left(HenkelUser.lname,4)) & fourDigits>
									</cfif>
									<input type="text" name="username_#thisUserID#" value="#thisUsername#" size="10" maxlength="16">
								<cfelseif Kaman.recordcount EQ 1>
									<input type="hidden" name="kamanID_#thisUserID#" value="#Kaman.ID#">
									<input type="hidden" name="username_#thisUserID#" value="#Kaman.username#">
									#Kaman.username#
								<cfelse>
									Multiple records in Kaman:  (This will be skipped)
									<cfloop query="Kaman">
										#Kaman.username# - #Kaman.email# - #Kaman.fname# #Kaman.lname#<br />
									</cfloop>
								</cfif>
								<input type="hidden" name="points_#thisUserID#" value="#thisPoints#">
							</td>
						</tr>
						</cfoutput>
					</cfif>
				</cfloop>
				<cfset NewKamanUserIDList = "">
				<cfif PointsFoundList NEQ "">
					<tr><td class="content" colspan="100%" height="10"></td></tr>
					<tr><td colspan="100%" align="center"><br>
					<input type="hidden" name="userIDList" value="<cfoutput>#PointsFoundList#</cfoutput>">
					<input type="submit" name="process" value="  Process All Records  " onClick="if ( ! confirm('Are you sure?')) return false;">
					</td></tr>
				<cfelse>
					<tr><td class="content2" colspan="100%" align="center"><span class="alert"><br>No Henkel/Kaman users found with points to transfer.<br><br></span></td></tr>
					<tr><td class="content" colspan="100%" height="10"></td></tr>
				</cfif>
			</table>
		</form>
	</cfif>
<cfelseif pgfn EQ "done">
	<cfoutput>
	<span class="pageinstructions">
		<br />
		#results#<br />
		#NumCreated# new Kaman program user<cfif NumCreated NEQ 1>s</cfif> created.<br /><br />
		#ListLen(form.userIDList)# points record<cfif ListLen(form.userIDList) NEQ 1>s</cfif> transferred.<br />
	</span>
	<br /><br />
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">
