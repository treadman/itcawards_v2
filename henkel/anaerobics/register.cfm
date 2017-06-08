<!---	This adds people to the 'henkel_branh_register' table with a status.
		If everything is OK, they will be added to the program_user table.

		Status Codes:
		
			0 - Everything is fine. Program user was created.
			1 - Could not find email in henkel_gilson table.
			2 - IDH was invalid in henkel_gilsen table.
			3 - IDH is already being used as a username in the program_user table.
--->

<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">

<cfparam name="pgfn" default="input">
<cfparam name="ID" default=0>
<cfparam name="company_name" default="">
<cfparam name="branch_ID" default="">
<cfparam name="password" default="">
<cfparam name="confirmpassword" default="">
<cfparam name="branch_address" default="">
<cfparam name="branch_city" default="">
<cfparam name="branch_state" default="">
<cfparam name="branch_zip" default="">
<cfparam name="branch_country" default="USA">
<cfparam name="branch_contact_fname" default="">
<cfparam name="branch_contact_lname" default="">
<cfparam name="branch_phone" default="">
<cfparam name="branch_email" default="">
<cfparam name="branch_reps" default="">

<cfparam name="email_addresses" default="">
<cfparam name="user_function" default="">
<cfparam name="registration_type" default="0">
<cfparam name="CONFIRM" default=0>

<cfparam name="email_template_ID" default=48>
<cfparam name="from_email" default="henkel.rewardsboard@us.henkel.com">
<cfparam name="email_subject" default="Henkel Loctite Anaerobics Program Registration">

<cfset username="">
<cfset AddRecord=False>
<cfset program_user_ID=0>

<!--- Static variables --->
<cfset created_user_ID = 1000000066>
<cfset program_ID = 1000000066>
<cfset ErrorMessage = "">

<cfif pgfn IS 'verify'>
	<cfif company_name IS ""><cfset ErrorMessage = ErrorMessage & 'company name, '></cfif>
	<cfif branch_address IS ""><cfset ErrorMessage = ErrorMessage & 'branch address, '></cfif>
	<cfif branch_city IS ""><cfset ErrorMessage = ErrorMessage & 'branch city, '></cfif>
	<cfif branch_country IS ""><cfset ErrorMessage = ErrorMessage & 'branch country, '></cfif>
	<cfif branch_country EQ "USA">
		<cfif branch_state IS ""><cfset ErrorMessage = ErrorMessage & 'branch state, '></cfif>
		<cfif branch_zip IS ""><cfset ErrorMessage = ErrorMessage & 'branch zip code, '></cfif>
	</cfif>
	<cfif branch_contact_fname IS ""><cfset ErrorMessage = ErrorMessage & 'branch contact first name, '></cfif>
	<cfif branch_contact_lname IS ""><cfset ErrorMessage = ErrorMessage & 'branch contact last name, '></cfif>
	<cfif branch_phone IS ""><cfset ErrorMessage = ErrorMessage & 'branch phone, '></cfif>
	<cfif branch_email IS ""><cfset ErrorMessage = ErrorMessage & 'branch email address, '></cfif>
	<cfif ErrorMessage GT "">
		<cfset ErrorMessage = 'Please enter your ' & LEFT(TRIM(ErrorMessage), LEN(TRIM(ErrorMessage)) - 1) & '.'>
		<cfset pgfn = 'input'>
	</cfif>
</cfif>

<cfif pgfn IS 'verify'>
	<cfquery name="CheckPriorRegistration" datasource="#application.DS#">
		SELECT branch_email
		FROM #application.database#.henkel_register_branch
		WHERE branch_email = <cfqueryparam value="#branch_email#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">
	</cfquery>
	<cfif CheckPriorRegistration.RecordCount GT 0>
		<!--- TODO:  This doesn't mean that the account is set up!!!!  They might not be approved yet. --->
		<cfset ErrorMessage = ErrorMessage & 'This account has already been set up, please log in to use this account.'>
	</cfif>
	
	<cfquery name="CheckDistributor" datasource="#application.DS#">
		SELECT IDH, IDH AS username
		FROM #application.database#.henkel_gilson
		WHERE email = <cfqueryparam value="#branch_email#" cfsqltype="CF_SQL_VARCHAR" maxlength="128">
	</cfquery>

	<cfif CheckDistributor.RecordCount IS 1>
		<cfquery name="CheckPriorPURegistration" datasource="#application.DS#">
			SELECT ID
			FROM #application.database#.program_user
			WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10"> AND username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#CheckDistributor.username#" maxlength="16">
		</cfquery>
		<cfif CheckPriorPURegistration.RecordCount GT 0>
			<!--- TODO:  This may not be their account.  Someone may have created this username randomly. --->
			<cfset ErrorMessage = ErrorMessage & 'This IDH number has already been set up, please log in to use this account.'>
		</cfif>
	</cfif>

	<cfif ErrorMessage IS "">
		<cfif CheckDistributor.RecordCount NEQ 1>
			<cfset status = 1>
		<cfelse>
			<cfif NOT IsNumeric(CheckDistributor.IDH)>
				<cfset status = 2>
			<cfelse>
				<cfset username = CheckDistributor.username>
				<cfquery name="CheckForProgramUser" datasource="#application.DS#">
					SELECT ID
					FROM #application.database#.program_user
					WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10"> AND username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#username#" maxlength="16">
				</cfquery>
				<cfif CheckForProgramUser.RecordCount EQ 0>
					<cfset status = 0>
					<cflock name="program_userLock" timeout="10">
						<cftransaction>
							<cfquery name="AddProgramUser" datasource="#application.DS#">
								INSERT INTO #application.database#.program_user 
									(created_user_ID, created_datetime, program_ID, username, fname, lname, ship_company, ship_address1,
									ship_city, ship_state, ship_zip, ship_country, phone, email, is_active, registration_type, idh)
								VALUES 
									(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
									'#FLGen_DateTimeToMySQL()#',
									<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#username#" maxlength="16">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_contact_fname#" maxlength="30">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_contact_lname#" maxlength="30">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#company_name#" maxlength="64">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_address#" maxlength="64">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_city#" maxlength="30">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_state#" maxlength="32">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_zip#" maxlength="32">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_country#" maxlength="35">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_phone#" maxlength="35">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_email#" maxlength="128">,
									1,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="BranchHQ" maxlength="16">,
									<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#username#" maxlength="16">)
							</cfquery>
							<cfquery name="getID" datasource="#application.DS#">
								SELECT Max(ID) As MaxID 
								FROM #application.database#.program_user
								WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
							</cfquery>
							<cfset program_user_ID = getID.MaxID>
						</cftransaction>
					</cflock>
					<cfquery name="BodyContent" datasource="#application.DS#">
						SELECT email_text 
						FROM #application.database#.email_templates
						WHERE ID = <cfqueryparam value="#email_template_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
					</cfquery>
					<cfset email_text = BodyContent.email_text>
					<cfset email_text = Replace(email_text,"USER-FIRST-NAME",branch_contact_fname,"all")>
					<cfset email_text = Replace(email_text,"USER-LAST-NAME",branch_contact_lname,"all")>
					<cfset email_text = Replace(email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
					<cfset email_text = Replace(email_text,"USER-NAME",username,"all")>
				<!---	
					<cfset email_text = Replace(email_text,"USER-EXPIRATION-DATE",SpoofInfo.expiration_date,"all")>
					<cfset email_text = Replace(email_text,"USER-REMAINING-POINTS",SpoofInfo.remaining_points,"all")>
					<cfset email_text = Replace(email_text,"USER-SUBPROGRAM-POINTS",spoof_subpoints,"all")>
					<cfset email_text = Replace(email_text,"LEVEL-OF-AWARD",SpoofInfo.level_of_award,"all")>
				--->	
					<!--- Send Email Alert --->
					<cfmail to="#branch_email#" from="#from_email#" subject="#email_subject#" type="html">
#email_text#
					</cfmail>
				<cfelse>
					<!--- TODO: This check was already done above and user was given an ErrorMessage --->
					<cfset status = 3>
					<cfset program_user_ID = CheckForProgramUser.ID>
				</cfif>
			</cfif>
		</cfif>
		<cflock name="henkel_register_branchLock" timeout="10">
			<cftransaction>
				<cfquery name="AddDistributor" datasource="#application.DS#">
					INSERT INTO #application.database#.henkel_register_branch 
						(created_user_ID, created_datetime, program_ID, username, company_name, branch_ID, branch_address,
						branch_city, branch_state, branch_zip, branch_contact_fname, branch_contact_lname, branch_phone,
						branch_email, branch_reps, branch_country, program_user_ID, status)
					VALUES
						(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#created_user_ID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#username#" maxlength="16">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#company_name#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_ID#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_address#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_city#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_state#" maxlength="32">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_zip#" maxlength="32">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_contact_fname#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_contact_lname#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_phone#" maxlength="35">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_email#" maxlength="128">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_reps#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#branch_country#" maxlength="32">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_user_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#status#" maxlength="10">)
				</cfquery>	
				<cfquery name="getID" datasource="#application.DS#">
					SELECT Max(ID) As MaxID 
					FROM #application.database#.henkel_register_branch
				</cfquery>
				<cfset ID = getID.MaxID>
			</cftransaction>  
		</cflock>
		<cflocation url="sales_entry.cfm?ID=#ID#" addtoken="no">
	<cfelse>
		<cfset pgfn = 'input'>
	</cfif>
</cfif>

<cfinclude template="includes/header.cfm">

	<cfif pgfn IS 'input'>							
		<cfoutput>
			<div align="center">
			<img src="images/prosknowheader.gif" alt="" width="299" height="89">
				<form action="#CurrentPage#" method="post" NAME="form_entry" onSubmit="return validateForm();">
				<input type="hidden" name="pgfn" value="verify">
					<div align="center">
						<table width="360" border="0" cellspacing="0" cellpadding="2">
							<tr>
								<td class="loctite" colspan="2" align="center" valign="top"><p class="formz"><b>#ErrorMessage#</b></p></td>
							</tr>

							<tr>
								<td class="loctite" align="right" valign="top" width="180"><p class="formz"><b>Distributor Company Name*</b></p></td>
								<td valign="top" width="172"><input type="text" name="company_name" size="26" border="0" value="#company_name#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
<!---
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Branch ID Code or ##</b></td>
								<td valign="top" width="172"><input type="text" name="branch_ID" size="26" border="0" value="#branch_ID#"></td>
							</tr>
--->
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Address*</b></td>
								<td valign="top" width="172"><input type="text" name="branch_address" size="26" border="0" value="#branch_address#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>City*</b></td>
								<td valign="top" width="172"><input type="text" name="branch_city" size="26" border="0" value="#branch_city#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>State*</b></td>
								<td valign="top" width="172"><input type="text" name="branch_state" size="2" maxlength="2" border="0" value="#branch_state#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Zip Code*</b></td>
								<td valign="top" width="172"><input type="text" name="branch_zip" size="26" border="0" value="#branch_zip#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Country*</b></td>
								<td valign="top" width="172"><input type="text" name="branch_country" size="26" border="0" value="#branch_country#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Contact Person*</b></td>
								<td class="loctite2" valign="top" width="172"><input type="text" name="branch_contact_fname" size="11" border="0" value="#branch_contact_fname#"> first name <input type="text" name="branch_contact_lname" size="11" border="0" value="#branch_contact_lname#"> last name</td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Contact Phone*</b></td>
								<td valign="top" width="172"><input type="text" name="branch_phone" size="26" border="0" value="#branch_phone#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Email Address*</b></td>
								<td valign="top" width="172"><input type="text" name="branch_email" size="26" border="0" value="#branch_email#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>Loctite&reg; Products Rep</b></td>
								<td valign="top" width="172"><input type="text" name="branch_reps" size="26" border="0" value="#branch_reps#"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td class="loctite" valign="top" width="172"></td>
							</tr>
							<tr>
								<td colspan="2" align="right" valign="top" width="356"><div align="right"><br></div></td>
							</tr>


							<tr>
								<td class="loctite" align="right" valign="top" width="180"><b>*Required Fields</b></td>
								<td valign="top" width="172">&nbsp;</td>
							</tr>

							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"><div align="right"><input type=image src="images/btn-submit.gif" border="0"></div></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
							<tr>
								<td class="loctite" align="right" valign="top" width="180"></td>
								<td valign="top" width="172"></td>
							</tr>
						</table>
					</div>
				</form>
			</div>
		</cfoutput>
	</cfif>							

<cfinclude template="includes/footer.cfm">
