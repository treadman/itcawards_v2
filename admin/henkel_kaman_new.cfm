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

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->
<cfset alert_msg = "">

<cfif isDefined("form.test_email")>
	<cfif NOT isDefined("thisTemplateText")>
		<cfset alert_msg = "Selected email template not found!">
	<cfelseif NOT isDefined("form.NewUserIDList")>
		<cfset alert_msg = "There are no records to run a test on.">
	<cfelseif NOT FLGen_IsValidEmail(form.emailTo)>
		<cfset alert_msg = "Please enter a valid email address for the test recipient.">
	<cfelseif NOT FLGen_IsValidEmail(form.emailFrom)>
		<cfset alert_msg = "Please enter a valid email address for the from address.">
	<cfelseif form.emailSubject EQ "">
		<cfset alert_msg = "Please enter a subject for the email.">
	<cfelse>
		<cfloop query="HenkelKamanUsers">
			<cfif isDefined("form.username_#HenkelKamanUsers.ID#")>
				<cfset thisUsername = evaluate("form.username_#HenkelKamanUsers.ID#")>
			<cfelse>
				<!--- Get current Kaman user --->
				<cfquery name="Kaman" datasource="#application.DS#">
					SELECT username
					FROM #application.database#.program_user
					WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#KamanID#">
					AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#HenkelKamanUsers.email#">
				</cfquery>
				<cfset thisUsername = Kaman.username>
			</cfif>
			<cfset thisPoints = Positive.points - Negative.points>
			<cfif thisPoints GT 0>
				<cfset thisTemplateText = Replace(thisTemplateText,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
				<!--- <cfset thisTemplateText = Replace(thisTemplateText,"USER-NAME",thisUsername,"all")> --->
				<cfset thisTemplateText = Replace(thisTemplateText,"USER-FIRST-NAME",HenkelKamanUsers.fname,"all")>
				<cfset thisTemplateText = Replace(thisTemplateText,"USER-LAST-NAME",HenkelKamanUsers.lname,"all")>
				<cfset thisTemplateText = Replace(thisTemplateText,"USER-TRANSFERRED-POINTS",thisPoints,"all")>
				<cfmail to="#form.emailTo#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
TEST EMAIL:<br />
Would have gone to #HenkelKamanUsers.email#<br />
<hr />
#thisTemplateText#
				</cfmail>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfset alert_msg = "Test email sent.">
	</cfif>
<cfelseif isDefined("form.process") AND isDefined("form.NewUserIDList")>
	<cfif NOT isDefined("thisTemplateText")>
		<cfset alert_msg = "Selected email template not found!">
	<cfelseif NOT FLGen_IsValidEmail(form.emailFrom)>
		<cfset alert_msg = "Please enter a valid email address for the from address.">
	<cfelseif form.emailSubject EQ "">
		<cfset alert_msg = "Please enter a subject for the email.">
	<cfelse>
		<cfloop list="#form.NewUserIDList#" index="thisID">
			<cfset thisUsername = trim(evaluate("form.username_#thisID#"))>
			<cfif thisUsername NEQ "">
				<cfif NOT isNumeric(Right(thisUsername,4))>
					<cfset alert_msg = thisUsername & " does not end in 4 numbers.">
				</cfif>
			</cfif>
			<cfif alert_msg NEQ "">
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	<cfif alert_msg EQ "">
		<cfset NumCreated = 0>
		<cfset transferNote = "Transferred points from Henkel U.S. to Kaman">
		<cfloop query="HenkelKamanUsers">
			<cfset thisKamanID = 0>
			<cfif thisPoints GT 0>
				<cfif isDefined("form.username_#HenkelKamanUsers.ID#")>
					<cfset NumCreated = NumCreated + 1>
					<cfset thisUsername = evaluate("form.username_#HenkelKamanUsers.ID#")>
					<cfif thisUsername NEQ "">
						<cfquery name="CheckExists" datasource="#application.DS#">
							SELECT ID
							FROM #application.database#.program_user
							WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisUsername#">
							AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#KamanID#">
						</cfquery>
						<cfif CheckExists.recordcount EQ 1>
							<cfset thisKamanID = CheckExists.ID>
						<cfelseif CheckExists.recordcount GT 1>
							<cfabort showerror="#thisUsername# is in the Kaman program multiple times!">
						<cfelse>
							<!--- Add new Kaman user --->
							<!--- <cflock name="program_userLock" timeout="10">
								<cftransaction>
									<cfquery name="InsertQuery" datasource="#application.DS#">
										INSERT INTO #application.database#.program_user
											(created_user_ID, created_datetime, username, fname, lname, email, phone, is_active, ship_company, ship_address1, ship_city, ship_state, ship_zip, program_ID, idh, registration_type)
										VALUES
										(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#',
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisUsername#" maxlength="16">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.fname)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.lname)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.email#" maxlength="128" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.email)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.phone#" maxlength="35" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.phone)))#">,
											<cfqueryparam cfsqltype="cf_sql_tinyint" value="#HenkelKamanUsers.is_active#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.is_active)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.ship_company#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.ship_company)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.ship_address1#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.ship_address1)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.ship_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.ship_city)))#">,
											<cfqueryparam cfsqltype="cf_sql_char" value="#HenkelKamanUsers.ship_state#" maxlength="2" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.ship_state)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.ship_zip#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.ship_zip)))#">,
											<cfqueryparam cfsqltype="cf_sql_integer" value="#KamanID#" maxlength="10">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.idh#" maxlength="16" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.idh)))#">,
											<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#HenkelKamanUsers.registration_type#" maxlength="16" null="#YesNoFormat(NOT Len(Trim(HenkelKamanUsers.registration_type)))#">)
									</cfquery>
									<cfquery name="getID" datasource="#application.DS#">
										SELECT Max(ID) As MaxID FROM #application.database#.program_user
									</cfquery>
									<cfset thisKamanID = getID.MaxID>
								</cftransaction>
							</cflock> --->
						</cfif>
					</cfif>
				<cfelse>
					<!--- Get current Kaman user --->
					<cfquery name="Kaman" datasource="#application.DS#">
						SELECT ID
						FROM #application.database#.program_user
						WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#KamanID#">
						AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#HenkelKamanUsers.email#">
					</cfquery>
					<cfif Kaman.recordcount EQ 1>
						<cfset thisKamanID = Kaman.ID>
					<cfelse>
						<cfquery name="KamanNames" datasource="#application.DS#">
							SELECT four_digit
							FROM #application.database#.henkel_kaman
							WHERE first_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#HenkelKamanUsers.fname#">
							AND last_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListFirst(HenkelKamanUsers.lname)#">
						</cfquery>
						<cfset fourDigits = "">
						<cfif KamanNames.recordcount EQ 1>
							<cfset fourDigits = KamanNames.four_digit>
						<cfelse>
							<cfabort showerror="This should not have happened.  This is a mismatch on email addresses for users that are in both Henkel and Kaman. [#HenkelKamanUsers.fname# #HenkelKamanUsers.lname# - #HenkelKamanUsers.username#]">
						</cfif>
						<cfset thisUsername = lcase(Left(HenkelKamanUsers.lname,4)) & fourDigits>
						<cfquery name="KamanAgain" datasource="#application.DS#">
							SELECT ID
							FROM #application.database#.program_user
							WHERE program_ID <> <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HenkelID#">
							AND username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisUsername#">
						</cfquery>
						<cfset thisKamanID = KamanAgain.ID>
					</cfif>
				</cfif>
				<!--- Now we have an ID for transfering points --->
				<cfif thisKamanID GT 0>
					<!--- Add a negative entry for the Henkel ID --->
					<cfset thisNote = "Transferred #thisPoints# to Kaman account">
					<!--- <cfquery name="InsertNegativePoints" datasource="#application.DS#">
						INSERT INTO #application.database#.awards_points
							(created_user_ID, created_datetime, user_ID, points, notes)
						VALUES
							('#FLGen_adminID#', '#FLGen_DateTimeToMySQL()#',
							<cfqueryparam cfsqltype="cf_sql_integer" value="#HenkelKamanUsers.ID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="-#thisPoints#" maxlength="8">,
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#thisNote#">)
					</cfquery> --->
					<!--- Add a positive entry for the Kaman ID --->
					<cfset thisNote = "Transferred #thisPoints# from Henkel account">
					<!--- <cfquery name="InsertPositivePoints" datasource="#application.DS#">
						INSERT INTO #application.database#.awards_points
							(created_user_ID, created_datetime, user_ID, points, notes)
						VALUES
							('#FLGen_adminID#', '#FLGen_DateTimeToMySQL()#',
							<cfqueryparam cfsqltype="cf_sql_integer" value="#thisKamanID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#thisPoints#" maxlength="8">,
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#thisNote#">)
					</cfquery> --->
					<!--- Add a positive entry for the Kaman ID --->
					<!--- <cfquery name="InsertPositiveSubPoints" datasource="#application.DS#">
						INSERT INTO #application.database#.subprogram_points
							(created_user_ID, created_datetime, subprogram_ID, user_ID, subpoints)
						VALUES
							('#FLGen_adminID#', '#FLGen_DateTimeToMySQL()#',
							<cfqueryparam cfsqltype="cf_sql_integer" value="#SubprogramID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#thisKamanID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#thisPoints#" maxlength="8">)
					</cfquery> --->
					<!--- Add an entry in the transfer table --->
					<!--- <cfquery name="InsertTransfer" datasource="#application.DS#">
						INSERT INTO #application.database#.points_transfer
							(from_user_ID, to_user_ID, points, transfer_datetime, notes)
						VALUES (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#HenkelKamanUsers.ID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#thisKamanID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#thisPoints#" maxlength="8">,
							'#FLGen_DateTimeToMySQL()#',
							<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#transferNote#">)
					</cfquery> --->
					<cfset thisUserText = Replace(thisTemplateText,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
					<!--- <cfset thisUserText = Replace(thisUserText,"USER-NAME",thisUsername,"all")> --->
					<cfset thisUserText = Replace(thisUserText,"USER-FIRST-NAME",HenkelKamanUsers.fname,"all")>
					<cfset thisUserText = Replace(thisUserText,"USER-LAST-NAME",HenkelKamanUsers.lname,"all")>
					<cfset thisUserText = Replace(thisUserText,"USER-TRANSFERRED-POINTS",thisPoints,"all")>
					<cfmail to="#form.emailTo#" from="#form.emailFrom#" subject="#form.emailSubject#" type="html">
TESTING:<br />
Would have gone to #HenkelKamanUsers.email#<br />
<hr />
#thisUserText#
					</cfmail>
				</cfif>
			</cfif>
		</cfloop>
		<cfset alert_msg = "Points transferred">
		<cfset pgfn = "done">
	</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->





				<cfset NewKamanUserIDList = "">
				<cfif FoundSome>
					<tr><td class="content" colspan="100%" height="10"></td></tr>
					<tr><td colspan="100%" align="center"><br>
					<input type="hidden" name="NewUserIDList" value="<cfoutput>#NewKamanUserIDList#</cfoutput>">
					<input type="submit" name="process" value="  Process All Records  " onClick="if ( ! confirm('Are you sure?')) return false;">
					</td></tr>
				<cfelse>
					<tr><td class="content2" colspan="100%" align="center"><span class="alert"><br>No Henkel/Kaman users found with points to transfer.<br><br></span></td></tr>
					<tr><td class="content" colspan="100%" height="10"></td></tr>
				</cfif>
<cfelseif pgfn EQ "done">
	<cfoutput>
	<span class="pageinstructions">
		#NumCreated# new Kaman program user<cfif NumCreated NEQ 1>s</cfif> created.<br><br>
		#HenkelKamanUsers.recordcount# points record<cfif HenkelKamanUsers.recordcount NEQ 1>s</cfif> transferred.<br>
	</span>
	<br /><br />
	</cfoutput>
</cfif>

</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->