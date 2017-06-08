<cfset SendSecondEmail = false>
<cfif thesePoints LTE 0>
	No&nbsp;points
<cfelseif getExistingUser.recordcount EQ 1>
	Award&nbsp;Points
	<cfif doit>
		<cfset Notes = "Automatically awarded from Henkel import file - #thisProgram#">
		<cfquery name="AwardPoints" datasource="#application.DS#">
			INSERT INTO #application.database#.awards_points (
				created_user_ID, created_datetime, user_ID, points, notes)
			VALUES (
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
				'#FLGen_DateTimeToMySQL()#',
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getExistingUser.ID#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thesePoints#">,
				<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Notes#">
			)
		</cfquery>
		<cfset user_email_address = GetImportRecords.email>
		<cfset user_email_text = ex_email_text>
		<cfset user_email_text = Replace(user_email_text,"USER-NAME",getExistingUser.username,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",getExistingUser.fname,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",getExistingUser.lname,"all")>
		<!--- <cfset user_email_text = Replace(user_email_text,"USER-EXPIRATION-DATE",getExistingUser.expiration_date,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-REMAINING-POINTS",getExistingUser.remaining_points,"all")> --->
	</cfif>
	<cfif isDefined("form.test_email") AND ex_first EQ "">
		<cfset ex_first = getExistingUser.fname>
		<cfset ex_last = getExistingUser.lname>
		<cfset ex_user = getExistingUser.username>
		<cfset ex_points = thesePoints>
		<cfset ex_activity = ActivityList>
	</cfif>
<cfelseif getBranchManager.recordcount EQ 1>
	Award&nbsp;Points<br />to&nbsp;Branch&nbsp;Leader
	<cfif doit>
		<cfset Notes = "Automatically awarded to Branch Participant Leader from Henkel import file - #thisProgram# - From Branch Participant #GetEmails.email#">
		<cfquery name="AwardPoints" datasource="#application.DS#">
			INSERT INTO #application.database#.awards_points (
				created_user_ID, created_datetime, user_ID, points, notes)
			VALUES (
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
				'#FLGen_DateTimeToMySQL()#',
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#getBranchManager.ID#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thesePoints#">,
				<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Notes#">
			)
		</cfquery>
		<!--- Setup email for Branch Leader --->
		<cfset user_email_address = getBranchManager.email>
		<cfset user_email_text = bl_email_text>
		<cfset user_email_text = Replace(user_email_text,"USER-NAME",getBranchManager.username,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",getBranchManager.fname,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",getBranchManager.lname,"all")>
		<cfset user_email_text = Replace(user_email_text,"BRANCH-PARTICIPANT",GetImportRecords.fname & " " & GetImportRecords.lname,"all")>
		<!--- Setup email for Branch Participant --->
		<cfset user_email_address2 = GetImportRecords.email>
		<cfset user_email_text2 = bp_email_text>
		<cfset user_email_text2 = Replace(user_email_text2,"USER-FIRST-NAME",GetImportRecords.fname,"all")>
		<cfset user_email_text2 = Replace(user_email_text2,"USER-LAST-NAME",GetImportRecords.lname,"all")>
		<cfset user_email_text2 = Replace(user_email_text2,"PARTICIPANT-LEADER",getBranchManager.fname & " " & getBranchManager.lname,"all")>
		<cfset SendSecondEmail = true>
	</cfif>
	<cfif isDefined("form.test_email") AND bl_first EQ "">
		<cfset bl_first = getBranchManager.fname>
		<cfset bl_last = getBranchManager.lname>
		<cfset bl_user = getBranchManager.username>
		<cfset bl_participant = GetImportRecords.fname & " " & GetImportRecords.lname>
		<cfset bl_points = thesePoints>
		<cfset bl_activity = ActivityList>
	</cfif>
	<cfif isDefined("form.test_email") AND bp_first EQ "">
		<cfset bp_first = GetImportRecords.fname>
		<cfset bp_last = GetImportRecords.lname>
		<cfset bp_leader = getBranchManager.fname & " " & getBranchManager.lname>
		<cfset bp_points = thesePoints>
		<cfset bp_activity = ActivityList>
	</cfif>
<cfelseif getExistingUser.recordcount EQ 0 AND getBranchManager.recordcount EQ 0>
	<cfif request.selected_henkel_program.is_registration_closed>
		<span class="highlight">&nbsp;&nbsp;&nbsp;HOLD&nbsp;&nbsp;&nbsp;</span>
	<cfelse>
		Hold
	</cfif>
	<input type="hidden" name="hasHolds" value="1" />
	<cfif doit>
		<cfquery name="addHoldUser" datasource="#application.DS#">
			INSERT INTO #application.database#.henkel_hold_user (
					created_user_ID, created_datetime, program_ID, email, points, source_import
				)
			VALUES (
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
				'#FLGen_DateTimeToMySQL()#',
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#GetImportRecords.email#" maxlength="128">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#thesePoints#" maxlength="8">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisProgram#">
			)
		</cfquery>
		<cfset user_email_address = GetImportRecords.email>
		<cfset user_email_text = pe_email_text>
		<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",thisFname,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",thisLname,"all")>
	</cfif>
	<cfif isDefined("form.test_email") AND pe_first EQ "" AND thesePoints GT 0>
		<cfset pe_first = thisFname>
		<cfset pe_last = thisLname>
		<cfset pe_points = thesePoints>
		<cfset pe_activity = ActivityList>
	</cfif>

<cfelseif getExistingUser.recordcount GT 1>

	<cfif doit>
		<cfabort showerror="Multiple users found with the email address: #GetEmails.email#">
	<cfelse>
		</td></tr><tr class="highlight"><td></td><td colspan="4">
		<cfset thisDupeList = ListAppend(thisDupeList,GetEmails.email)>
		<cfoutput>
		<span class="alert">#GetEmails.email# is in program users multiple times!</span><br /><br />
		Import file has the following name(s):
		<cfset theseNames = "">
		<cfloop query="GetImportRecords">
			<cfif NOT ListFindNoCase(theseNames,"#GetImportRecords.fname# #GetImportRecords.lname#")>
				<cfset theseNames = ListAppend(theseNames,"#GetImportRecords.fname# #GetImportRecords.lname#")>
			</cfif>
		</cfloop>
		#theseNames#<br /><br />
		&nbsp;&nbsp;&nbsp;&nbsp;Award these points to:<br />
		<cfloop query="getExistingUser">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="dupe_#ListLen(thisDupeList)#" value="#getExistingUser.username#" />#getExistingUser.fname# #getExistingUser.lname# (#getExistingUser.username#)<br />
		</cfloop>
		</cfoutput>
	</cfif>

<cfelseif getBranchManager.recordcount GT 1>

	<cfif doit>
		<cfabort showerror="Multiple Branch Participant Leaders found in henkel_register with the alternate email address: #GetEmails.email#">
	<cfelse>
		</td></tr><tr class="highlight"><td></td><td colspan="4">
		<cfset thisDupeList = ListAppend(thisDupeList,GetEmails.email)>
		<cfoutput>
		<span class="alert">#GetEmails.email# is in multiple branch leaders participant lists!</span><br /><br />
		Import file has the following name(s):
		&nbsp;&nbsp;&nbsp;&nbsp;Award these points to:<br />
		<cfloop query="getBranchManager">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="dupe_#ListLen(thisDupeList)#" value="#getBranchManager.username#" />#getBranchManager.fname# #getBranchManager.lname# (#getBranchManager.username#)<br />
		</cfloop>
		</cfoutput>
	</cfif>

</cfif>


<cfif thesePoints GT 0>
	<cfif doit>
		<cfset user_email_text = Replace(user_email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-POINTS-EARNED",thesePoints,"all")>
		<cfset user_email_text = Replace(user_email_text,"VALUED-SELLING-ACTIVITY","<br>"&ActivityList,"all")>
		<cfif isDefined("user_email_text2")>
			<cfset user_email_text2 = Replace(user_email_text2,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
			<cfset user_email_text2 = Replace(user_email_text2,"USER-POINTS-EARNED",thesePoints,"all")>
			<cfset user_email_text2 = Replace(user_email_text2,"VALUED-SELLING-ACTIVITY","<br>"&ActivityList,"all")>
		</cfif>
		<cfset thisCC = "">
		<cfif isDefined("thisCC_byUpload") AND isDefined("thisCC_byIDH")>
			<cfif thisCC_byUpload NEQ "">
				<cfset thisCC = thisCC_byUpload>
			<cfelseif thisCC_byIDH NEQ "">
				<cfset thisCC = thisCC_byIDH>
			</cfif>
		</cfif>
	</cfif>
	<cftry>
		<cfif doit>
			<cfif thisCC NEQ "">
			<cfmail to="#user_email_address#" cc="#thisCC#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
#user_email_text#
			</cfmail>
			<cfif SendSecondEmail>
				<cfmail to="#user_email_address2#" cc="#thisCC#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
#user_email_text2#
				</cfmail>
			</cfif>
			<cfelse>
			<cfmail to="#user_email_address#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
#user_email_text#
			</cfmail>
			<cfif SendSecondEmail>
				<cfmail to="#user_email_address2#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
#user_email_text2#
				</cfmail>
			</cfif>
			</cfif>
		</cfif>
		<cfset email_sent = true>
		<cfcatch></cfcatch>
	</cftry>
</cfif>
<cfif doit>
	<!--- Mark the import file as processed. --->
	<cfquery name="MarkProcessedQuery" datasource="#application.DS#">
		UPDATE #application.database#.henkel_import_#thisTable#
		SET date_processed = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
		WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetImportRecords.email#">
		AND date_processed IS NULL
	</cfquery>
</cfif>
