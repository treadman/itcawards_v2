<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<cfparam name="url.pgfn" default="home">
<cfparam name="url.i" default="">
<cfparam name="alert_msg" default="">
<cfset doit = false>

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="bonus_points_company" default="">
<cfparam name="bonus_points" default="0">
<cfif isDefined("form.toggle_bonus_points")>
	<cfset bonus_points = abs(bonus_points-1)>
</cfif>

<!--- -------------------------------------- --->
<!--- ------  Upload File   ---------------- --->
<!--- -------------------------------------- --->
<cfif IsDefined("form.upload_file")>

	<cfinclude template="includes/henkel/upload_file.cfm">

<!--- -------------------------------------- --->
<!--- ------  Update Import Tables   ------- --->
<!--- -------------------------------------- --->
<cfelseif isDefined("form.save_changes") AND isDefined("url.i") AND isNumeric(url.i)>
	<cfquery name="UpdateImportRecord" datasource="#application.DS#">
		UPDATE #application.database#.henkel_import_#form.import_type#
		SET
			<cfif NOT ListFindNoCase("jsc,simple,points",form.import_type)>
				idh = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.idh#">,
			</cfif>
			<cfif NOT ListFindNoCase("simple,points",form.import_type)>
				fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fname#">,
				lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lname#">,
			<cfelse>
				name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.name#">,
				phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.phone#">,
			</cfif>
			<cfif form.import_type EQ "points">
				points = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.points#">,
				reason = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.reason#">,
			</cfif>
			email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#">
			<cfif form.import_type EQ "mro_oem">
				,
				program_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.program_type#">,
				count = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.count#">
			</cfif>
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
		AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#">
	</cfquery>
	<cfset url.i = "">
</cfif>

<cfset leftnavon = 'henkel_import_points'>
<cfinclude template="includes/header.cfm">
<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>

<cfif url.pgfn NEQ "home">
	<!--- Return link --->
	<span class="pageinstructions">Return to the <a href="<cfoutput>#CurrentPage#</cfoutput>" class="actionlink">Import Points Main Page</a></span>
	<br><br>
</cfif>

<!--- ------------------------------------ --->
<!--- ------  Home Page   ---------------- --->
<!--- ------------------------------------ --->

<cfif url.pgfn EQ "home">
	<cfquery name="mro_oem" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_mro_oem
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="lu" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_lu
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="dcse" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_dcse
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="leak" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_leak
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="dts" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_dts
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="jsc" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_jsc
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="simple" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_simple
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="points" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_points
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>

	<!--- Page Title --->
	<span class="pagetitle">Import data from Excel</span>
	<br /><br />
	<span class="pageinstructions">
		This is where you import data from the Excel spreadsheet.<br /><br />
		<ol>
			<li>Upload the spreadsheet into the database.  This populates the database with the latest data from Excel.</li>
			<li>Edit the uploaded records.</li>
			<li>Process the records to award points and send emails</li>
			<br /><br />
		</ol>
	</span>
	<br /><br />
	<cfoutput>
	<table cellpadding="8" width="100%">
		<tr>
			<td align="right">MRO OEM<cfif mro_oem.recordcount GT 0><br>#mro_oem.recordcount# disctinct users</cfif></td>
			<td><a href="#CurrentPage#?pgfn=upload&type=mro_oem" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif mro_oem.recordcount GT 0><a href="#CurrentPage#?pgfn=results_mro_oem">Edit</a></cfif></td>
			<td><cfif mro_oem.recordcount GT 0><a href="#CurrentPage#?pgfn=process_mro_oem">Process</a></cfif></td>
			<td><cfif mro_oem.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=mro_oem" onclick="return confirm('Are you sure you want to delete these #mro_oem.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>
		<tr>
			<td align="right">Loctite University<br>(Web-based Training)<cfif lu.recordcount GT 0><br>#lu.recordcount# disctinct users</cfif></td>
			<td><a href="#CurrentPage#?pgfn=upload&type=lu" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif lu.recordcount GT 0><a href="#CurrentPage#?pgfn=results_lu">Edit</a></cfif></td>
			<td><cfif lu.recordcount GT 0><a href="#CurrentPage#?pgfn=process_lu">Process</a></cfif></td>
			<td><cfif lu.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=lu" onclick="return confirm('Are you sure you want to delete these #lu.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>
		<tr>
			<td align="right">Distributor Training School<cfif dts.recordcount GT 0><br>#dts.recordcount# disctinct users</cfif></td>
			<td><a href="#CurrentPage#?pgfn=upload&type=dts" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif dts.recordcount GT 0><a href="#CurrentPage#?pgfn=results_dts">Edit</a></cfif></td>
			<td><cfif dts.recordcount GT 0><a href="#CurrentPage#?pgfn=process_dts">Process</a></cfif></td>
			<td><cfif dts.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=dts" onclick="return confirm('Are you sure you want to delete these #dts.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>
		<tr>
			<td align="right">Joint Sales Call<cfif jsc.recordcount GT 0><br>#jsc.recordcount# disctinct users</cfif></td>
			<td><a href="#CurrentPage#?pgfn=upload&type=jsc" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif jsc.recordcount GT 0><a href="#CurrentPage#?pgfn=results_jsc">Edit</a></cfif></td>
			<td><cfif jsc.recordcount GT 0><a href="#CurrentPage#?pgfn=process_jsc">Process</a></cfif></td>
			<td><cfif jsc.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=jsc" onclick="return confirm('Are you sure you want to delete these #jsc.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>
		<tr>
			<td align="right">Documented Cost Savings Event<cfif dcse.recordcount GT 0><br>#dcse.recordcount# disctinct users</cfif></td>
			<td><a href="#CurrentPage#?pgfn=upload&type=dcse" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif dcse.recordcount GT 0><a href="#CurrentPage#?pgfn=results_dcse">Edit</a></cfif></td>
			<td><cfif dcse.recordcount GT 0><a href="#CurrentPage#?pgfn=process_dcse">Process</a></cfif></td>
			<td><cfif dcse.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=dcse" onclick="return confirm('Are you sure you want to delete these #dcse.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>
		<tr>
			<td align="right">Air Leak or Hydraulic Leak Survey<cfif leak.recordcount GT 0><br>#leak.recordcount# disctinct users</cfif></td>
			<td><a href="#CurrentPage#?pgfn=upload&type=leak" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif leak.recordcount GT 0><a href="#CurrentPage#?pgfn=results_leak">Edit</a></cfif></td>
			<td><cfif leak.recordcount GT 0><a href="#CurrentPage#?pgfn=process_leak">Process</a></cfif></td>
			<td><cfif leak.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=leak" onclick="return confirm('Are you sure you want to delete these #leak.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>
		<!---<tr>
			<td align="right">Branch HQ<cfif simple.recordcount GT 0><br>#simple.recordcount# disctinct users</cfif></td>
			<td><a href="henkel_import_simple.cfm?pgfn=upload&type=simple" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif simple.recordcount GT 0><a href="#CurrentPage#?pgfn=results_simple">Edit</a></cfif></td>
			<td><cfif simple.recordcount GT 0><a href="#CurrentPage#?pgfn=process_simple">Process</a></cfif></td>
			<td><cfif simple.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=simple" onclick="return confirm('Are you sure you want to delete these #simple.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>--->
		<!--- <tr>
			<td align="right">Points<cfif points.recordcount GT 0><br>#points.recordcount# disctinct users</cfif></td>
			<td><a href="#CurrentPage#?pgfn=upload&type=points" class="actionlink">Upload Spreadsheet</a></td>
			<td><cfif points.recordcount GT 0><a href="#CurrentPage#?pgfn=results_points">Edit</a></cfif></td>
			<td><cfif points.recordcount GT 0><a href="#CurrentPage#?pgfn=process_points">Process</a></cfif></td>
			<td><cfif points.recordcount GT 0><a href="#CurrentPage#?pgfn=delete&type=points" onclick="return confirm('Are you sure you want to delete these #points.recordcount# records?  There is NO UNDO.')">Delete</a></cfif></td>
		</tr>
		<tr><td colspan="100%"><strong>Simple</strong> - This is simply a list of email addresses.  After uploading, YOU will indicate how many points everyone on the list will get and for what reason.</td></tr>
		<tr><td colspan="100%"><strong>Points</strong> - This is a list of email addresses along with the points for each person and the reason for the points.</td></tr> --->
	</table>
	</cfoutput>

<!--- ----------------------------- --->
<!--- ------  Delete  ------------- --->
<!--- ----------------------------- --->

<cfelseif url.pgfn EQ "delete">
	<cfquery name="DeleteUploaded" datasource="#application.DS#">
		DELETE FROM #application.database#.henkel_import_#url.type#
		WHERE date_processed IS NULL
		AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	</cfquery>
	<br><br>
	Uploaded records deleted.

<!--- ----------------------------- --->
<!--- ------  Upload  ------------- --->
<!--- ----------------------------- --->

<cfelseif url.pgfn EQ "upload">
	<cfswitch expression="#url.type#">
		<cfcase value="mro_oem">
			<cfset thisType = "MRO OEM">
			<cfset thisList = "IDH Number, Date Entered, ID Rep First Name, ID Rep Last Name, ID Rep Email Address, Training Type, Attendee Count">
		</cfcase>
		<cfcase value="lu">
			<cfset thisType = "LOCTITE UNIVERSITY">
			<cfset thisList = "IDH Number, First Name, Last Name, Email Address, Date completed">
		</cfcase>
		<cfcase value="dcse">
			<cfset thisType = "DOCUMENTED COST SAVINGS EVENT">
			<cfset thisList = "IDH Number, First Name, Last Name, Email Address, Date completed">
		</cfcase>
		<cfcase value="leak">
			<cfset thisType = "AIR LEAK OR HYDRAULIC LEAK SURVEY">
			<cfset thisList = "IDH Number, First Name, Last Name, Email Address, Date completed">
		</cfcase>
		<cfcase value="dts">
			<cfset thisType = "DISTRIBUTOR TRAINING SCHOOL">
			<cfset thisList = "IDH Number, First Name, Last Name, Email Address, Date completed">
		</cfcase>
		<cfcase value="jsc">
			<cfset thisType = "JOINT SALES CALL">
			<cfset thisList = "Rep Last Name, Rep First Name, Rep Email, Date of Joint Sales Call, Loctite&reg; Rep Full Name, Loctite&reg; Rep Email">
		</cfcase>
		<cfcase value="simple">
			<cfset thisType = "SIMPLE">
			<cfset thisList = "Company Name, Company Address, Rep Full Name, Rep Phone Number, Rep Email">
		</cfcase>
		<!--- <cfcase value="points">
			<cfset thisType = "POINTS">
			<cfset thisList = "Company Name, Company Address, Rep Full Name, Rep Phone Number, Rep Email, Points, Reason">
		</cfcase> --->
		<cfdefaultcase>
			<cfabort showerror="Unknown type: #url.type#">
		</cfdefaultcase>
	</cfswitch>
	<span class="pagetitle">
		Upload the <cfoutput>#thisType#</cfoutput> Spreadsheet
	</span>
	<br /><br />
	<span class="pageinstructions">
	Before uploading the spreadsheet, it needs to be saved in the proper format.<br><br>
	<ol>
		<li>Open the file in Excel.</li><br><br>
		<li>
			Make sure you have these columns in this order:<br /><strong><cfoutput>#thisList#</cfoutput></strong>
			<!---<cfif ListFindNoCase("MRO OEM,DISTRIBUTOR TRAINING SCHOOL",thisType)>--->
			<br><br>
			<cfswitch expression="#thisType#">
				<cfcase value="MRO OEM">
					Training type column:
					<ul type="disc">
						<li>OEM &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - 30 points for minimum 7 Attendee Count</li>
						<li>OEM CTS - 60 points for minimum 15 Attendee Count</li>
						<li>MRO &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - 30 points for minimum 10 Attendee Count</li>
						<li>MRO &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - 40 points for minimum 20 Attendee Count</li>
						<li>MRO CTS - 60 points for minimum 1 Attendee Count</li>
					</ul>
				</cfcase>
				<cfcase value="DISTRIBUTOR TRAINING SCHOOL">
					<ul type="disc">
					<li>Each row is awarded 40 points</li>
					</ul>
				</cfcase>
				<cfcase value="JOINT SALES CALL">
					<ul type="disc">
					<li>Each row is awarded 5 points</li>
					</ul>
				</cfcase>
				<cfcase value="DOCUMENTED COST SAVINGS EVENT">
					<ul type="disc">
					<li>Each row is awarded 25 points</li>
					</ul>
				</cfcase>
			</cfswitch>
			<!---</cfif>--->
		</li>
		<br /><br />
		<li>Make sure the first row of the spreadsheet has the column headers and <strong>NOT</strong> a data row.</li><br /><br />
		<li>Save the file as a comma-separated values (csv) file.
			<ul type="disc">
				<li>Click "File" (or Office Button in Office 2007) then "Save As".</li>
				<li>In the "Save As" dialog window, under the "File name" input field is a drop-down select box for "Save as type:".</li>
				<li>Scroll down to select the "CSV (Comma Delimited) (*.csv)" option.</li>
				<li>If the xls file has more than one worksheet you will get a window asking "The selected file type does not support ... multiple worksheets."  Click "OK".</li>
				<li>Then you'll probably get a message saying "export...csv may contain features that are incompatible..."  Click "Yes"</li>
			</ul>
		</li><br>
		<li>When you close Excel or close the file, Excel asks again to save the txt file.  There is no need to do this, so click "No".</li><br><br>
	</ol>
	<cfoutput>
	<form method="post" action="#CurrentPage#" name="uploadPoints" enctype="multipart/form-data">
		<input type="hidden" name="upload_type" value="#url.type#" />
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="upload_file" value="  Upload  " >
	</form>
	</cfoutput>
	</span>

<!--- ----------------------- --->
<!--- ------  Results ------- --->
<!--- ----------------------- --->

<cfelseif left(url.pgfn,8) EQ "results_">

	<cfinclude template="includes/henkel/results.cfm">

<!--- -------------------- --->
<!--- ------  Edit ------- --->
<!--- -------------------- --->

<cfelseif left(url.pgfn,5) EQ "edit_">

	<cfinclude template="includes/henkel/edit.cfm">

<!--- ----------------------------------------- --->
<!--- ------  Process MRO OEM records   ------- --->
<!--- ----------------------------------------- --->

<cfelseif url.pgfn EQ "process_mro_oem">
	<cfinclude template="includes/henkel/setup_test_email.cfm">
	<cfinclude template="includes/henkel/form_top.cfm">
	<cfif NOT doit>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2,
				SUM((SELECT IFNULL(MAX(p.points),0) AS points_awarded
				FROM #application.database#.henkel_points_lookup p
				WHERE i.program_type = p.program_type AND p.minimum <= i.count)) AS awarded_points
			FROM #application.database#.henkel_import_mro_oem i
			WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			GROUP BY i.email
		</cfquery>
		There are <cfoutput>#GetList.recordcount#</cfoutput> records to process.<br><br>
		<cfinclude template="includes/henkel/process_form.cfm">
	</cfif>
	<cfquery name="GetEmails" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_mro_oem
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfquery name="GetValidPrograms" datasource="#application.DS#">
		SELECT program_type FROM #application.database#.henkel_points_lookup
		GROUP BY program_type
	</cfquery>
	<cfset ValidPrograms = ValueList(GetValidPrograms.program_type)>
	<cfif doit>
		<br><br>
		Processed the following <cfoutput>#GetEmails.recordcount#</cfoutput> users:
	</cfif>
	<cfinclude template="includes/henkel/setup_test_text.cfm">
	<br><br>
	<table width="100%" cellpadding="3">
		<tr>
			<td>IDH</td>
			<td>Email</td>
			<td>CC</td>
			<td>Points</td>
			<td>User</td>
			<!--- <td>Email</td> --->
		</tr>
		<cfloop query="GetEmails">
			<cfquery name="GetImportRecords" datasource="#application.DS#">
				SELECT p.idh AS foundIDH, m.ID, m.idh, m.fname, m.lname, m.email, m.date_entered_2, m.count, m.program_type
				FROM #application.database#.henkel_import_mro_oem m
				LEFT JOIN #application.database#.program_user p ON p.email = m.email AND p.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#"> AND p.registration_type <> "BranchHQ"
				WHERE m.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
				AND m.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				AND m.date_processed IS NULL
			</cfquery>
			<cfset bonus_multiplier = Checkbonus(bonus_points,bonus_points_company,GetImportRecords.email)>
			<cfset ActivityList = "">
			<cfset BadPrograms = "">
			<cfset thesePoints = 0>
			<cfloop query="GetImportRecords">
				<cfset thisFname = GetImportRecords.fname>
				<cfset thisLname = GetImportRecords.lname>
				<cfset thisIDH = GetImportRecords.idh>
				<cfif NOT ListFindNoCase(ValidPrograms,GetImportRecords.program_type) AND NOT ListFindNoCase(BadPrograms,GetImportRecords.program_type)>
					<cfset BadPrograms = ListAppend(BadPrograms,GetImportRecords.program_type)>
				</cfif>
				<cfquery name="getPoints" datasource="#application.DS#">
					SELECT points
					FROM #application.database#.henkel_points_lookup
					WHERE program_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetImportRecords.program_type#">
					AND minimum <= <cfqueryparam cfsqltype="cf_sql_integer" value="#GetImportRecords.count#">
					ORDER BY points DESC
					LIMIT 1
				</cfquery>
				<cfif getPoints.recordcount EQ 1>
					<cfset thesePoints = thesePoints + (getPoints.points * bonus_multiplier)> 
					<cfset ActivityList = ListAppend(ActivityList,GetImportRecords.program_type & " Seminar - " & getPoints.points & " points")>
				</cfif>
			</cfloop>
			<cfset ActivityList = Replace(ActivityList,",","<br>","ALL")>
			<cfset email_sent = false>
			<cfinclude template="includes/henkel/get_user.cfm">
			<cfset thisIDH = GetImportRecords.idh>
			<cfif thisIDH EQ "">
				<cfset thisIDH = GetImportRecords.foundIDH>
			</cfif>
			<cfoutput>
			<tr>
				<td>#GetImportRecords.idh#</td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif>>#GetImportRecords.email#</td>
				<td><cfinclude template="includes/henkel/lookup_loctite_rep.cfm"></td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif> align="right">#thesePoints#</td>
				<td>
					<cfset thisProgram = "MRO OEM">
					<cfset thisTable = "mro_oem">
					<cfinclude template="includes/henkel/award_points.cfm">
				</td>
				<!--- <td>#YesNoFormat(email_sent)#</td> --->
			</tr>
			<cfif BadPrograms NEQ "">
				<tr class="highlight">
					<td colspan="100%">
						The above record includes the following programs which are NOT in the points lookup:<br><br>
						#BadPrograms#<br><br>
						If you process these records, NO points will be awarded for these programs.
					</td>
				</tr>
			</cfif>
			</cfoutput>
		</cfloop>
	</table>
	<cfinclude template="includes/henkel/send_test_email.cfm">
	<cfinclude template="includes/henkel/form_bottom.cfm">

<!--- ------------------------------------ --->
<!--- ------  Process LU records   ------- --->
<!--- ------------------------------------ --->

<cfelseif url.pgfn EQ "process_lu">
	<cfinclude template="includes/henkel/setup_test_email.cfm">
	<cfinclude template="includes/henkel/form_top.cfm">
	<cfif NOT doit>
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
		There are <cfoutput>#GetList.recordcount#</cfoutput> records to process.<br><br>
		<cfinclude template="includes/henkel/process_form.cfm">
	</cfif>
	<cfquery name="GetEmails" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_lu
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfif doit>
		<br><br>
		Processed the following <cfoutput>#GetEmails.recordcount#</cfoutput> users:
	</cfif>
	<cfinclude template="includes/henkel/setup_test_text.cfm">
	<br><br>
	<table width="100%" cellpadding="3">
		<tr>
			<td>IDH</td>
			<td>Email</td>
			<td>CC</td>
			<td>Points</td>
			<td>User</td>
			<!--- <td>Email</td> --->
		</tr>
		<cfloop query="GetEmails">
			<cfquery name="GetImportRecords" datasource="#application.DS#">
				SELECT u.idh AS foundIDH, i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
				FROM #application.database#.henkel_import_lu i
				LEFT JOIN #application.database#.program_user u ON u.email = i.email AND u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#"> AND u.registration_type <> "BranchHQ"
				WHERE i.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
				AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				AND i.date_processed IS NULL
			</cfquery>
			<cfset bonus_multiplier = Checkbonus(bonus_points,bonus_points_company,GetImportRecords.email)>
			<cfset ActivityList = "">
			<cfset thesePoints = 0>
			<cfloop query="GetImportRecords">
				<cfset thisFname = GetImportRecords.fname>
				<cfset thisLname = GetImportRecords.lname>
				<cfset thisIDH = GetImportRecords.idh>
				<cfquery name="getPoints" datasource="#application.DS#">
					SELECT points
					FROM #application.database#.henkel_points_lookup
					WHERE program_type = 'LU'
					AND minimum <= 1
					ORDER BY points DESC
					LIMIT 1
				</cfquery>
				<cfif getPoints.recordcount EQ 1>
					<cfset thesePoints = thesePoints + (getPoints.points * bonus_multiplier)>
					<cfset ActivityList = ListAppend(ActivityList,"Loctite University - " & getPoints.points & " points")>
				</cfif>
			</cfloop>
			<cfset ActivityList = Replace(ActivityList,",","<br>","ALL")>
			<cfset email_sent = false>
			<cfinclude template="includes/henkel/get_user.cfm">
			<cfset thisIDH = GetImportRecords.idh>
			<cfif thisIDH EQ "">
				<cfset thisIDH = GetImportRecords.foundIDH>
			</cfif>
			<cfoutput>
			<tr>
				<td>#thisIDH#</td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif>>#GetImportRecords.email#</td>
				<td><cfinclude template="includes/henkel/lookup_loctite_rep.cfm"></td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif> align="right">#thesePoints#</td>
				<td>
					<cfset thisProgram = "Loctite University">
					<cfset thisTable = "lu">
					<cfinclude template="includes/henkel/award_points.cfm">
				</td>
				<!--- <td>#YesNoFormat(email_sent)#</td> --->
			</tr>
			</cfoutput>
		</cfloop>
	</table>
	<cfinclude template="includes/henkel/send_test_email.cfm">
	<cfinclude template="includes/henkel/form_bottom.cfm">

<!--- ------------------------------------ --->
<!--- ------  Process DCSE records   ------- --->
<!--- ------------------------------------ --->

<cfelseif url.pgfn EQ "process_dcse">
	<cfinclude template="includes/henkel/setup_test_email.cfm">
	<cfinclude template="includes/henkel/form_top.cfm">
	<cfif NOT doit>
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
		There are <cfoutput>#GetList.recordcount#</cfoutput> records to process.<br><br>
		<cfinclude template="includes/henkel/process_form.cfm">
	</cfif>
	<cfquery name="GetEmails" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_dcse
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfif doit>
		<br><br>
		Processed the following <cfoutput>#GetEmails.recordcount#</cfoutput> users:
	</cfif>
	<cfinclude template="includes/henkel/setup_test_text.cfm">
	<br><br>
	<table width="100%" cellpadding="3">
		<tr>
			<td>IDH</td>
			<td>Email</td>
			<td>CC</td>
			<td>Points</td>
			<td>User</td>
			<!--- <td>Email</td> --->
		</tr>
		<cfloop query="GetEmails">
			<cfquery name="GetImportRecords" datasource="#application.DS#">
				SELECT u.idh AS foundIDH, i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
				FROM #application.database#.henkel_import_dcse i
				LEFT JOIN #application.database#.program_user u ON u.email = i.email AND u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#"> AND u.registration_type <> "BranchHQ"
				WHERE i.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
				AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				AND i.date_processed IS NULL
			</cfquery>
			<cfset bonus_multiplier = Checkbonus(bonus_points,bonus_points_company,GetImportRecords.email)>
			<cfset ActivityList = "">
			<cfset thesePoints = 0>
			<cfloop query="GetImportRecords">
				<cfset thisFname = GetImportRecords.fname>
				<cfset thisLname = GetImportRecords.lname>
				<cfset thisIDH = GetImportRecords.idh>
				<cfquery name="getPoints" datasource="#application.DS#">
					SELECT points
					FROM #application.database#.henkel_points_lookup
					WHERE program_type = 'DCSE'
					AND minimum <= 1
					ORDER BY points DESC
					LIMIT 1
				</cfquery>
				<cfif getPoints.recordcount EQ 1>
					<cfset thesePoints = thesePoints + (getPoints.points * bonus_multiplier)>
					<cfset ActivityList = ListAppend(ActivityList,"Documented Cost Savings Event - " & getPoints.points & " points")>
				</cfif>
			</cfloop>
			<cfset ActivityList = Replace(ActivityList,",","<br>","ALL")>
			<cfset email_sent = false>
			<cfinclude template="includes/henkel/get_user.cfm">
			<cfset thisIDH = GetImportRecords.idh>
			<cfif thisIDH EQ "">
				<cfset thisIDH = GetImportRecords.foundIDH>
			</cfif>
			<cfoutput>
			<tr>
				<td>#thisIDH#</td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif>>#GetImportRecords.email#</td>
				<td><cfinclude template="includes/henkel/lookup_loctite_rep.cfm"></td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif> align="right">#thesePoints#</td>
				<td>
					<cfset thisProgram = "Documented Cost Savings Event">
					<cfset thisTable = "dcse">
					<cfinclude template="includes/henkel/award_points.cfm">
				</td>
				<!--- <td>#YesNoFormat(email_sent)#</td> --->
			</tr>
			</cfoutput>
		</cfloop>
	</table>
	<cfinclude template="includes/henkel/send_test_email.cfm">
	<cfinclude template="includes/henkel/form_bottom.cfm">

<!--- ------------------------------------ --->
<!--- ------  Process LEAK records   ------- --->
<!--- ------------------------------------ --->

<cfelseif url.pgfn EQ "process_leak">
	<cfinclude template="includes/henkel/setup_test_email.cfm">
	<cfinclude template="includes/henkel/form_top.cfm">
	<cfif NOT doit>
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
		There are <cfoutput>#GetList.recordcount#</cfoutput> records to process.<br><br>
		<cfinclude template="includes/henkel/process_form.cfm">
	</cfif>
	<cfquery name="GetEmails" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_leak
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfif doit>
		<br><br>
		Processed the following <cfoutput>#GetEmails.recordcount#</cfoutput> users:
	</cfif>
	<cfinclude template="includes/henkel/setup_test_text.cfm">
	<br><br>
	<table width="100%" cellpadding="3">
		<tr>
			<td>IDH</td>
			<td>Email</td>
			<td>CC</td>
			<td>Points</td>
			<td>User</td>
			<!--- <td>Email</td> --->
		</tr>
		<cfloop query="GetEmails">
			<cfquery name="GetImportRecords" datasource="#application.DS#">
				SELECT u.idh AS foundIDH, i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
				FROM #application.database#.henkel_import_leak i
				LEFT JOIN #application.database#.program_user u ON u.email = i.email AND u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#"> AND u.registration_type <> "BranchHQ"
				WHERE i.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
				AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				AND i.date_processed IS NULL
			</cfquery>
			<cfset bonus_multiplier = Checkbonus(bonus_points,bonus_points_company,GetImportRecords.email)>
			<cfset ActivityList = "">
			<cfset thesePoints = 0>
			<cfloop query="GetImportRecords">
				<cfset thisFname = GetImportRecords.fname>
				<cfset thisLname = GetImportRecords.lname>
				<cfset thisIDH = GetImportRecords.idh>
				<cfquery name="getPoints" datasource="#application.DS#">
					SELECT points
					FROM #application.database#.henkel_points_lookup
					WHERE program_type = 'LEAK'
					AND minimum <= 1
					ORDER BY points DESC
					LIMIT 1
				</cfquery>
				<cfif getPoints.recordcount EQ 1>
					<cfset thesePoints = thesePoints + (getPoints.points * bonus_multiplier)>
					<cfset ActivityList = ListAppend(ActivityList,"Air Leak or Hydraulic Leak Survey - " & getPoints.points & " points")>
				</cfif>
			</cfloop>
			<cfset ActivityList = Replace(ActivityList,",","<br>","ALL")>
			<cfset email_sent = false>
			<cfinclude template="includes/henkel/get_user.cfm">
			<cfset thisIDH = GetImportRecords.idh>
			<cfif thisIDH EQ "">
				<cfset thisIDH = GetImportRecords.foundIDH>
			</cfif>
			<cfoutput>
			<tr>
				<td>#thisIDH#</td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif>>#GetImportRecords.email#</td>
				<td><cfinclude template="includes/henkel/lookup_loctite_rep.cfm"></td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif> align="right">#thesePoints#</td>
				<td>
					<cfset thisProgram = "Air Leak or Hydraulic Leak Survey">
					<cfset thisTable = "leak">
					<cfinclude template="includes/henkel/award_points.cfm">
				</td>
				<!--- <td>#YesNoFormat(email_sent)#</td> --->
			</tr>
			</cfoutput>
		</cfloop>
	</table>
	<cfinclude template="includes/henkel/send_test_email.cfm">
	<cfinclude template="includes/henkel/form_bottom.cfm">

<!--- ------------------------------------- --->
<!--- ------  Process DTS records   ------- --->
<!--- ------------------------------------- --->

<cfelseif url.pgfn EQ "process_dts">
	<cfinclude template="includes/henkel/setup_test_email.cfm">
	<cfinclude template="includes/henkel/form_top.cfm">
	<cfif NOT doit>
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
		There are <cfoutput>#GetList.recordcount#</cfoutput> records to process.<br><br>
		<cfinclude template="includes/henkel/process_form.cfm">
	</cfif>
	<cfquery name="GetEmails" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_dts
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfif doit>
		<br><br>
		Processed the following <cfoutput>#GetEmails.recordcount#</cfoutput> users:
	</cfif>
	<cfinclude template="includes/henkel/setup_test_text.cfm">
	<br><br>
	<table width="100%" cellpadding="3">
		<tr>
			<td>IDH</td>
			<td>Email</td>
			<td>CC</td>
			<td>Points</td>
			<td>User</td>
			<!--- <td>Email</td> --->
		</tr>
		<cfloop query="GetEmails">
			<cfquery name="GetImportRecords" datasource="#application.DS#">
				SELECT u.idh AS foundIDH, i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
				FROM #application.database#.henkel_import_dts i
				LEFT JOIN #application.database#.program_user u ON u.email = i.email AND u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#"> AND u.registration_type <> "BranchHQ"
				WHERE i.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
				AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				AND i.date_processed IS NULL
			</cfquery>
			<cfset bonus_multiplier = Checkbonus(bonus_points,bonus_points_company,GetImportRecords.email)>
			<cfset ActivityList = "">
			<cfset thesePoints = 0>
			<cfloop query="GetImportRecords">
				<cfset thisFname = GetImportRecords.fname>
				<cfset thisLname = GetImportRecords.lname>
				<cfset thisIDH = GetImportRecords.idh>
				<cfquery name="getPoints" datasource="#application.DS#">
					SELECT points
					FROM #application.database#.henkel_points_lookup
					WHERE program_type = 'DTS'
					AND minimum <= 1
					ORDER BY points DESC
					LIMIT 1
				</cfquery>
				<cfif getPoints.recordcount EQ 1>
					<cfset thesePoints = thesePoints + (getPoints.points * bonus_multiplier)>
					<cfset ActivityList = ListAppend(ActivityList,"Distributor Training School - " & getPoints.points & " points")>
				</cfif>
			</cfloop>
			<cfset ActivityList = Replace(ActivityList,",","<br>","ALL")>
			<cfset email_sent = false>
			<cfinclude template="includes/henkel/get_user.cfm">
			<cfset thisIDH = GetImportRecords.idh>
			<cfif thisIDH EQ "">
				<cfset thisIDH = GetImportRecords.foundIDH>
			</cfif>
			<cfoutput>
			<tr>
				<td>#thisIDH#</td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif>>#GetImportRecords.email#</td>
				<td><cfinclude template="includes/henkel/lookup_loctite_rep.cfm"></td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif> align="right">#thesePoints#</td>
				<td>
					<cfset thisProgram = "Distributor Training School">
					<cfset thisTable = "dts">
					<cfinclude template="includes/henkel/award_points.cfm">
				</td>
				<!--- <td>#YesNoFormat(email_sent)#</td> --->
			</tr>
			</cfoutput>
		</cfloop>
	</table>
	<cfinclude template="includes/henkel/send_test_email.cfm">
	<cfinclude template="includes/henkel/form_bottom.cfm">

<!--- ------------------------------------- --->
<!--- ------  Process JSC records   ------- --->
<!--- ------------------------------------- --->

<cfelseif url.pgfn EQ "process_jsc">
	<cfinclude template="includes/henkel/setup_test_email.cfm">
	<cfinclude template="includes/henkel/form_top.cfm">
	<cfif NOT doit>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.fname, i.lname, i.email, i.loctite_rep_email, i.date_entered_2,
				SUM((SELECT IFNULL(MAX(p.points),0) AS points
				FROM #application.database#.henkel_points_lookup p
				WHERE p.program_type = "JSC" AND p.minimum <= 1)) AS awarded_points
			FROM #application.database#.henkel_import_jsc i
			WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			GROUP BY email
			ORDER BY email
		</cfquery>
		There are <cfoutput>#GetList.recordcount#</cfoutput> records to process.<br><br>
		<cfinclude template="includes/henkel/process_form.cfm">
	</cfif>
	<cfquery name="GetEmails" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_jsc
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfif doit>
		<br><br>
		Processed the following <cfoutput>#GetEmails.recordcount#</cfoutput> users:
	</cfif>
	<cfinclude template="includes/henkel/setup_test_text.cfm">
	<br><br>
	<table width="100%" cellpadding="3">
		<tr>
			<td>IDH</td>
			<td>Email</td>
			<td>CC</td>
			<td>Points</td>
			<td>User</td>
			<!--- <td>Email</td> --->
		</tr>
		<cfloop query="GetEmails">
			<cfquery name="GetImportRecords" datasource="#application.DS#">
				SELECT u.idh AS foundIDH, i.ID, i.fname, i.lname, i.email, i.loctite_rep_email, i.date_entered_2, i.loctite_rep
				FROM #application.database#.henkel_import_jsc i
				LEFT JOIN #application.database#.program_user u ON u.email = i.email AND u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#"> AND u.registration_type <> "BranchHQ"
				WHERE i.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
				AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				AND i.date_processed IS NULL
			</cfquery>
			<cfset bonus_multiplier = Checkbonus(bonus_points,bonus_points_company,GetImportRecords.email)>
			<cfset ActivityList = "">
			<cfset thesePoints = 0>
			<cfloop query="GetImportRecords">
				<cfset thisFname = GetImportRecords.fname>
				<cfset thisLname = GetImportRecords.lname>
				<cfset thisIDH = "">
				<cfquery name="getPoints" datasource="#application.DS#">
					SELECT points
					FROM #application.database#.henkel_points_lookup
					WHERE program_type = 'JSC'
					AND minimum <= 1
					ORDER BY points DESC
					LIMIT 1
				</cfquery>
				<cfif getPoints.recordcount EQ 1>
					<cfset thesePoints = thesePoints + (getPoints.points * bonus_multiplier)>
					<cfset ActivityList = ListAppend(ActivityList,"Joint Sales Call - " & getPoints.points & " points")>
				</cfif>
			</cfloop>
			<cfset ActivityList = Replace(ActivityList,",","<br>","ALL")>
			<cfset email_sent = false>
			<cfinclude template="includes/henkel/get_user.cfm">
			<cfset thisIDH = "">
			<cfif thisIDH EQ "">
				<cfset thisIDH = GetImportRecords.foundIDH>
			</cfif>
			<cfif thisIDH EQ "">
				<cfset thisIDH = getExistingUser.idh>
			</cfif>
			<cfif thisIDH EQ "">
				<cfquery name="getTerritory" datasource="#application.DS#">
					SELECT DISTINCT fname, lname, sap_ty, zip
					FROM #application.database#.henkel_territory
					WHERE CONCAT(fname,' ',lname) = '#GetImportRecords.loctite_rep#'
				</cfquery>
				<!--- WHERE CONCAT('00',region) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getTerritory.sap_ty#"> --->
				<cfif getTerritory.recordcount EQ 1>
					<cfquery name="getDistributor" datasource="#application.DS#">
						SELECT idh
						FROM #application.database#.henkel_distributor
						WHERE zip = '#getTerritory.zip#'
						AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
					</cfquery>
					<cfif getDistributor.recordcount EQ 1>
						<cfset thisIDH = getDistributor.idh>
					</cfif>
					<!--- <tr><td colspan="100%"><cfdump var="#getTerritory#"></td></tr>
					<tr><td colspan="100%"><cfdump var="#getDistributor#"></td></tr> --->
				</cfif>
			</cfif>
			<cfif thisIDH EQ "">
				<!--- What's another way to find an IDH? --->
			</cfif>
			<cfoutput>
			<tr>
				<td>#thisIDH#</td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif>>#GetImportRecords.email#</td>
				<td><cfinclude template="includes/henkel/lookup_loctite_rep.cfm"></td>
				<td <cfif bonus_multiplier GT 1>class="highlight"</cfif> align="right">#thesePoints#</td>
				<td>
					<cfset thisProgram = "Joint Sales Call">
					<cfset thisTable = "jsc">
					<cfinclude template="includes/henkel/award_points.cfm">
				</td>
				<!--- <td>#YesNoFormat(email_sent)#</td> --->
			</tr>
			</cfoutput>
		</cfloop>
	</table>
	<cfinclude template="includes/henkel/send_test_email.cfm">
	<cfinclude template="includes/henkel/form_bottom.cfm">

<!--- ---------------------------------------- --->
<!--- ------  Process SIMPLE records   ------- --->
<!--- ---------------------------------------- --->

<cfelseif url.pgfn EQ "process_simple">
	<cfinclude template="includes/henkel/setup_test_email.cfm">
	<cfinclude template="includes/henkel/form_top.cfm">
	<cfset thesePoints = 1><!--- This forces it to look up a user --->
	<cfset ActivityList = "">
	<cfif isDefined("form.points") AND isNumeric(form.points) AND form.points GT 0>
		<cfset thesePoints = form.points>
	</cfif>
	<cfif isDefined("form.reason") AND form.reason NEQ "">
		<cfset ActivityList = form.reason>
	</cfif>
	<cfif doit>
		<cfif NOT isDefined("form.points") OR NOT isNumeric(form.points) OR form.points LTE 0>
			<span class="alert">Please enter the number of points each person will be awarded!</span>
			<br /><br />
			<cfset doit = false>
		</cfif>
		<cfif NOT isDefined("form.reason") OR form.reason EQ "">
			<span class="alert">Please enter the reason for this award!</span>
			<br /><br />
			<cfset doit = false>
		</cfif>
	</cfif>
	<cfif NOT doit>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.name, i.phone, i.email, i.date_entered_2
			FROM #application.database#.henkel_import_simple i
			WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			GROUP BY email
			ORDER BY email
		</cfquery>
		There are <cfoutput>#GetList.recordcount#</cfoutput> records to process.<br><br>
		<cfinclude template="includes/henkel/process_form.cfm">
	</cfif>
	<cfquery name="GetEmails" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM #application.database#.henkel_import_simple
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		AND date_processed IS NULL
	</cfquery>
	<cfif doit>
		<br><br>
		Processed the following <cfoutput>#GetEmails.recordcount#</cfoutput> users:
	</cfif>
	<cfinclude template="includes/henkel/setup_test_text.cfm">
	<br><br>
	<table width="100%" cellpadding="3">
		<tr>
			<!--- <td>IDH</td> --->
			<td>Email</td>
			<!--- <td>CC</td> --->
			<td>User</td>
		</tr>
		<cfloop query="GetEmails">
			<cfquery name="GetImportRecords" datasource="#application.DS#">
				SELECT u.idh AS foundIDH, i.ID, i.name, i.phone, i.email, i.date_entered_2
				FROM #application.database#.henkel_import_simple i
				LEFT JOIN #application.database#.program_user u ON u.email = i.email AND u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#"> AND u.registration_type <> "BranchHQ"
				WHERE i.email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetEmails.email#">
				AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				AND i.date_processed IS NULL
			</cfquery>
			<cfloop query="GetImportRecords">
				<cfset thisFname = GetImportRecords.name>
				<cfset thisLname = "">
				<cfset thisIDH = "">
			</cfloop>
			<cfset email_sent = false>
			<cfinclude template="includes/henkel/get_user.cfm">
			<cfset thisIDH = "">
			<!--- <cfif thisIDH EQ "">
				<cfset thisIDH = GetImportRecords.foundIDH>
			</cfif>
			<cfif thisIDH EQ "">
				<cfset thisIDH = getExistingUser.idh>
			</cfif>
			<cfif thisIDH EQ "">
				<cfquery name="getTerritory" datasource="#application.DS#">
					SELECT DISTINCT fname, lname, sap_ty, zip
					FROM #application.database#.henkel_territory
					WHERE CONCAT(fname,' ',lname) = '#GetImportRecords.loctite_rep#'
				</cfquery>
				<!--- WHERE CONCAT('00',region) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getTerritory.sap_ty#"> --->
				<cfif getTerritory.recordcount EQ 1>
					<cfquery name="getDistributor" datasource="#application.DS#">
						SELECT idh
						FROM #application.database#.henkel_distributor
						WHERE zip = '#getTerritory.zip#'
						AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
					</cfquery>
					<cfif getDistributor.recordcount EQ 1>
						<cfset thisIDH = getDistributor.idh>
					</cfif>
					<!--- <tr><td colspan="100%"><cfdump var="#getTerritory#"></td></tr>
					<tr><td colspan="100%"><cfdump var="#getDistributor#"></td></tr> --->
				</cfif>
			</cfif>
			<cfif thisIDH EQ "">
				<!--- What's another way to find an IDH? --->
			</cfif> --->
			<cfoutput>
			<tr>
				<!--- <td>#thisIDH#</td> --->
				<td>#GetImportRecords.email#</td>
				<!--- <td><cfinclude template="includes/henkel/lookup_loctite_rep.cfm"></td> --->
				<td>
					<cfset thisProgram = ActivityList>
					<cfset thisTable = "simple">
					<cfinclude template="includes/henkel/award_points.cfm">
				</td>
				<!--- <td>#YesNoFormat(email_sent)#</td> --->
			</tr>
			</cfoutput>
		</cfloop>
	</table>
	<cfinclude template="includes/henkel/send_test_email.cfm">
	<cfinclude template="includes/henkel/form_bottom.cfm">
</cfif>

<!--- ---------------------- --->
<!--- ------  DONE   ------- --->
<!--- ---------------------- --->

<cfinclude template="includes/footer.cfm">

<cffunction name="CheckBonus">
	<cfargument name="bonus_points" required="true">
	<cfargument name="bonus_company" required="true">
	<cfargument name="email" required="true">
	<cfset var return_value = 1>
	<cfset var multipler = 2>
	<cfset var this_domain = "">
	<cfif arguments.bonus_points AND arguments.bonus_company NEQ "">
		<cfloop list="#arguments.bonus_company#" index="this_domain"> 
			<cfif FindNoCase(this_domain,arguments.email)>
				<cfset return_value = multipler>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn return_value>
</cffunction>
