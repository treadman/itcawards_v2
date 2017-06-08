<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->

<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000099,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="showAll" default=0>
<cfparam name="sortby" default="created_datetime">
<cfparam name="dir" default="0">

<cfparam name="email_template_ID" default=48>
<cfparam name="from_email" default="henkel.rewardsboard@us.henkel.com">
<cfparam name="email_subject" default="Henkel Loctite Anaerobics Program Enrollment">
<cfparam name="LookupRegion" default="">

<!--- Selected registration --->
<cfparam name="url.r" default="0">
<cfif NOT isNumeric(url.r) OR url.r LT 0>
	<cfset url.r = 0>
</cfif>

<!--- Delete  --->
<cfparam name="url.d" default="0">
<cfif NOT isNumeric(url.d) OR url.d LT 0>
	<cfset url.d = 0>
</cfif>

<cfset alert_msg = "">

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<!--- Static variables --->
<cfset Notes = "Approved in admin from Henkel BRANCH registration form">

<cfif url.d GT 0>
	<cflock name="DeleteHenkelRegistrationLock" timeout="30">
		<cfquery name="checkDelete" datasource="#application.DS#">
			SELECT status
			FROM #application.database#.henkel_register_branch
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.d#" maxlength="10">
		</cfquery>
		<cfif checkDelete.recordcount EQ 1 AND checkDelete.status GT 0>
			<cfquery name="deleteRegistration" datasource="#application.DS#">
				DELETE FROM #application.database#.henkel_register_branch
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.d#" maxlength="10">
			</cfquery>
			<cfset alert_msg = "Registration deleted.">
		</cfif>
	</cflock>
</cfif>

<cfif url.r GT 0>
	<cfquery name="registration" datasource="#application.DS#">
		SELECT ID, created_datetime, username, company_name, branch_ID, branch_address, branch_city, branch_state, branch_zip, branch_contact_fname, branch_contact_lname, branch_phone, branch_email, branch_reps, branch_country, program_ID, program_user_ID, status,
			   py_sales, jan_sales, feb_sales, mar_sales, apr_sales, may_sales, jun_sales, jul_sales, aug_sales, sep_sales, oct_sales, nov_sales, dec_sales
		FROM #application.database#.henkel_register_branch
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.r#" maxlength="10">
	</cfquery>
	<cfif registration.recordcount EQ 1>
		<cfparam name="form.ID" default="#registration.ID#">
		<cfparam name="form.created_datetime" default="#registration.created_datetime#">
		<cfparam name="form.username" default="#registration.username#">
		<cfparam name="form.company_name" default="#registration.company_name#">
		<cfparam name="form.branch_ID" default="#registration.branch_ID#">
		<cfparam name="form.branch_address" default="#registration.branch_address#">
		<cfparam name="form.branch_city" default="#registration.branch_city#">
		<cfparam name="form.branch_state" default="#registration.branch_state#">
		<cfparam name="form.branch_zip" default="#registration.branch_zip#">
		<cfparam name="form.branch_contact_fname" default="#registration.branch_contact_fname#">
		<cfparam name="form.branch_contact_lname" default="#registration.branch_contact_lname#">
		<cfparam name="form.branch_phone" default="#registration.branch_phone#">
		<cfparam name="form.branch_email" default="#registration.branch_email#">
		<cfparam name="form.branch_reps" default="#registration.branch_reps#">
		<cfparam name="form.branch_country" default="#registration.branch_country#">
		<cfparam name="form.program_ID" default="#registration.program_ID#">
		<cfparam name="form.program_user_ID" default="#registration.program_user_ID#">
		<cfparam name="form.status" default="#registration.status#">
		<cfparam name="form.py_sales" default="#registration.py_sales#">
		<cfparam name="form.jan_sales" default="#registration.jan_sales#">
		<cfparam name="form.feb_sales" default="#registration.feb_sales#">
		<cfparam name="form.mar_sales" default="#registration.mar_sales#">
		<cfparam name="form.apr_sales" default="#registration.apr_sales#">
		<cfparam name="form.may_sales" default="#registration.may_sales#">
		<cfparam name="form.jun_sales" default="#registration.jun_sales#">
		<cfparam name="form.jul_sales" default="#registration.jul_sales#">
		<cfparam name="form.aug_sales" default="#registration.aug_sales#">
		<cfparam name="form.sep_sales" default="#registration.sep_sales#">
		<cfparam name="form.oct_sales" default="#registration.oct_sales#">
		<cfparam name="form.nov_sales" default="#registration.nov_sales#">
		<cfparam name="form.dec_sales" default="#registration.dec_sales#">
	<cfelse>
		<cfset url.r = 0>
	</cfif>
</cfif>

<cfif isDefined("form.submitButton") AND isDefined("form.ID") AND isNumeric(form.ID) AND form.ID GT 0 AND form.status GT 0>
	<cfif form.branch_email EQ "" OR NOT FLGen_IsValidEmail(form.branch_email)>
		<cfset alert_msg = alert_msg & "Please enter a valid email address.\n">
	</cfif>
<!---	
	<cfif form.username EQ "">
		<cfset alert_msg = alert_msg & "Please enter a user name.\n">
	<cfelseif len(form.username) LT 8>
		<cfset alert_msg = alert_msg & "User name must be at least eight characters.\n">
	<cfelseif form.program_user_ID EQ 0>
		<cfquery name="CheckProgramUser" datasource="#application.DS#">
			SELECT ID 
			FROM #application.database#.program_user
			WHERE username = <cfqueryparam value="#form.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="16">
			AND program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">
		</cfquery>
		<cfif CheckProgramUser.recordcount GT 0>
			<cfset alert_msg = alert_msg & "User name is already in use.\n">
		</cfif>
	</cfif>
--->	
	<cfif form.branch_contact_fname EQ "">
		<cfset alert_msg = alert_msg & "Please enter a first name.\n">
	</cfif>
	<cfif form.branch_contact_lname EQ "">
		<cfset alert_msg = alert_msg & "Please enter a last lname.\n">
	</cfif>
	<cfif form.branch_phone EQ "">
		<cfset alert_msg = alert_msg & "Please enter a phone number.\n">
	</cfif>
	<cfif form.branch_address EQ "">
		<cfset alert_msg = alert_msg & "Please enter the address.\n">
	</cfif>
	<cfif form.branch_city EQ "">
		<cfset alert_msg = alert_msg & "Please enter a city.\n">
	</cfif>
	<cfif form.branch_state EQ "">
		<cfset alert_msg = alert_msg & "Please enter a state.\n">
	</cfif>
	<cfif form.selected_distributor EQ "">
		<cfset alert_msg = alert_msg & "Please select a distributor company name.\n">
	</cfif>
	<cfquery name="CheckPriorPURegistration" datasource="#application.DS#">
		SELECT ID
		FROM #application.database#.program_user
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10"> AND username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.selected_distributor#" maxlength="16">
	</cfquery>
	<cfif CheckPriorPURegistration.RecordCount GT 0>
		<cfset alert_msg = alert_msg & 'This IDH number has already been set up.'>
	</cfif>
	
	<cfif alert_msg EQ "">
			<cfquery name="BranchInformation" datasource="#application.DS#">
				SELECT idh, company_name
				FROM #application.database#.henkel_distributor
				WHERE idh = <cfqueryparam value="#form.selected_distributor#" cfsqltype="CF_SQL_VARCHAR" maxlength="16">
			</cfquery>
			<cfquery name="UpdateRegistration" datasource="#application.DS#">
				UPDATE #application.database#.henkel_register_branch SET
					company_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#BranchInformation.company_name#" maxlength="64">,
					<cfif selected_distributor GT "">
						username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.selected_distributor#" maxlength="16">,
						branch_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.selected_distributor#" maxlength="64">,
					<cfelse>
						username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_ID#" maxlength="16">,
						branch_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_ID#" maxlength="64">,
					</cfif>
					branch_address = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address#" maxlength="64">,
					branch_city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city#" maxlength="30">,
					branch_state = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state#" maxlength="32">,
					branch_zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip#" maxlength="32">,
					branch_contact_fname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_contact_fname#" maxlength="30">,
					branch_contact_lname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_contact_lname#" maxlength="30">,
					branch_phone = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_phone#" maxlength="35">,
					branch_email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_email#" maxlength="128">,
					branch_reps = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_reps#" maxlength="64">,
					branch_country = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_country#" maxlength="32">,
					status = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
			</cfquery>
			<cfset thisIDH = BranchInformation.idh>
			<cfif thisIDH EQ "" OR mid(thisIDH,2,3) EQ "N/A">
				<cfset thisIDH = request.selected_henkel_program.default_IDH>
			</cfif>
			<cfquery name="AddProgramUser" datasource="#application.DS#">
				INSERT INTO #application.database#.program_user
					(created_user_ID, 
					created_datetime, 
					program_ID, 
					username, 
					fname, 
					
					lname,
					ship_company, 
					ship_address1, 
					ship_city, 
					ship_state,
					
					ship_zip, 
					phone, 
					email, 
					is_active, 
					idh, 
					
					registration_type)
				VALUES
					(<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
					'#FLGen_DateTimeToMySQL()#',
					<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisIDH#" maxlength="16">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_contact_fname#" maxlength="30">,
					
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_contact_lname#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#BranchInformation.company_name#" maxlength="64">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address#" maxlength="64">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city#" maxlength="30">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state#" maxlength="2">,
					
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip#" maxlength="32">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_phone#" maxlength="35">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_email#" maxlength="128">,
					1,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisIDH#" maxlength="16">,
					
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="BranchHQ" maxlength="16">)
			</cfquery>
			<cfquery name="GetMaxID" datasource="#application.DS#">
				SELECT MAX(ID) AS maxID
				FROM #application.database#.program_user
			</cfquery>			
			<cfquery name="UpdateRegistration" datasource="#application.DS#">
				UPDATE #application.database#.henkel_register_branch SET
					program_user_ID = <cfqueryparam value="#GetMaxID.maxID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
			</cfquery>
		<cfset url.r = 0>
		<cfquery name="BodyContent" datasource="#application.DS#">
			SELECT email_text 
			FROM #application.database#.email_templates
			WHERE ID = <cfqueryparam value="#email_template_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		</cfquery>
		<cfset email_text = BodyContent.email_text>
		<cfset email_text = Replace(email_text,"USER-FIRST-NAME",form.branch_contact_fname,"all")>
		<cfset email_text = Replace(email_text,"USER-LAST-NAME",form.branch_contact_lname,"all")>
		<cfset email_text = Replace(email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
		<cfset email_text = Replace(email_text,"USER-NAME",BranchInformation.idh,"all")>
		<!--- Send Email Alert --->
		<cfmail failto="#Application.ErrorEmailTo#" to="#form.branch_email#" from="#from_email#" subject="#email_subject#" type="html">
#email_text#
		</cfmail>
		<cfset alert_msg = "Changes were saved">
	</cfif>
<cfelseif isDefined("form.saveButton") AND isDefined("form.ID") AND isNumeric(form.ID) AND form.ID GT 0>
	<cfif form.branch_email EQ "" OR NOT FLGen_IsValidEmail(form.branch_email)>
		<cfset alert_msg = alert_msg & "Please enter a valid email address.\n">
	</cfif>
	<cfif form.branch_contact_fname EQ "">
		<cfset alert_msg = alert_msg & "Please enter a first name.\n">
	</cfif>
	<cfif form.branch_contact_lname EQ "">
		<cfset alert_msg = alert_msg & "Please enter a last lname.\n">
	</cfif>
	<cfif form.branch_phone EQ "">
		<cfset alert_msg = alert_msg & "Please enter a phone number.\n">
	</cfif>
	<cfif form.branch_address EQ "">
		<cfset alert_msg = alert_msg & "Please enter the address.\n">
	</cfif>
	<cfif form.branch_city EQ "">
		<cfset alert_msg = alert_msg & "Please enter a city.\n">
	</cfif>
	<cfif form.branch_state EQ "">
		<cfset alert_msg = alert_msg & "Please enter a state.\n">
	</cfif>
	
	<cfif alert_msg EQ "">
			<cfquery name="UpdateRegistration" datasource="#application.DS#">
				UPDATE #application.database#.henkel_register_branch SET
					company_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.company_name#" maxlength="64">,
					username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="16">,
					branch_address = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_address#" maxlength="64">,
					branch_city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_city#" maxlength="30">,
					branch_state = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_state#" maxlength="32">,
					branch_zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_zip#" maxlength="32">,
					branch_contact_fname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_contact_fname#" maxlength="30">,
					branch_contact_lname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_contact_lname#" maxlength="30">,
					branch_phone = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_phone#" maxlength="35">,
					branch_email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_email#" maxlength="128">,
					branch_reps = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_reps#" maxlength="64">,
					branch_country = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.branch_country#" maxlength="32">
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
			</cfquery>
		<cfset alert_msg = "Changes were saved">
	</cfif>
</cfif>

<cfset leftnavon = "henkel-branch-registrations">
<cfinclude template="includes/header.cfm">

<cfoutput>
<span class="highlight">#request.selected_henkel_program.program_name#</span>

<cfif url.r EQ 0>
	<cfquery name="registrations" datasource="#application.DS#">
		SELECT ID, created_datetime, username, company_name, branch_ID, branch_address, branch_city, branch_state, branch_zip, branch_contact_fname, branch_contact_lname, branch_phone, branch_email, branch_reps, branch_country, program_ID, program_user_ID, status
		FROM #application.database#.henkel_register_branch
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">
		<cfif showAll IS 0>
			AND status > 0
		</cfif>
		<cfif sortby NEQ "">
			ORDER BY #sortby# <cfif dir>DESC</cfif>
		</cfif>
	</cfquery>
	<cfquery name="TotalRegistered" datasource="#application.DS#">
		SELECT COUNT(ID) AS RegTotal
		FROM #application.database#.henkel_register_branch
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">
	</cfquery>
	<cfquery name="ToBeChecked" datasource="#application.DS#">
		SELECT COUNT(ID) AS RegTotal
		FROM #application.database#.henkel_register_branch
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10"> AND status > 0
	</cfquery>
	<table cellspacing="0" cellpadding="5" border="0">
		<tr>
			<td colspan="3">
				<p>There are #TotalRegistered.RegTotal# registrations submitted, both approved and pending.</p>
				<p>There <cfif ToBeChecked.RegTotal NEQ 1>are<cfelse>is</cfif> #ToBeChecked.RegTotal# registration<cfif ToBeChecked.RegTotal NEQ 1>s</cfif><cfif showAll GT 0> to approve</cfif>.</p>
			</td>
			<td colspan="2" align="right">
				<a href="#currentPage#?sortby=#sortby#&dir=#dir#&showAll=<cfif showAll GT 0>0<cfelse>1</cfif>"><cfif showAll IS 1>Hide Approved<cfelse>Show All</cfif> Registrations</a>
			</td>
		</tr>
		<tr class="contenthead">
			<td width="10%"></td>
			<td width="32%"><a class="actionlink" href="#currentPage#?sortby=branch_email<cfif sortby EQ 'email'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Email</a><cfif sortby EQ 'email'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
			<!--- <td width="18%"><a class="actionlink" href="#currentPage#?sortby=fname<cfif sortby EQ 'fname'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">First Name</a><cfif sortby EQ 'fname'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td> --->
			<td width="18%"><a class="actionlink" href="#currentPage#?sortby=branch_contact_lname<cfif sortby EQ 'lname'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Last Name</a><cfif sortby EQ 'lname'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
			<td width="14%"><a class="actionlink" href="#currentPage#?sortby=created_datetime<cfif sortby EQ 'created_datetime'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Registered</a><cfif sortby EQ 'created_datetime'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
			<td width="26%"><a class="actionlink" href="#currentPage#?sortby=status<cfif sortby EQ 'status'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Status</a><cfif sortby EQ 'status'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
		</tr>
		<cfif registrations.recordcount GT 0>
			<cfloop query="registrations">
				<tr>
					<td nowrap="nowrap">
						<a class="actionlink" href="#currentPage#?r=#registrations.ID#&sortby=#sortby#&dir=#dir#&showAll=#showAll#">Edit</a>
						<cfif registrations.status GT 0>
						<a class="actionlink" href="#currentPage#?r=#registrations.ID#&sortby=#sortby#&dir=#dir#&showAll=#showAll#">Appr</a>
						<a class="actionlink" href="#currentPage#?d=#registrations.ID#&sortby=#sortby#&dir=#dir#&showAll=#showAll#" onclick="return confirm('Are you sure you want to delete this registration?  There is NO UNDO.')">Del</a>
						</cfif>
					</td>
					<td>#left(registrations.branch_email,32)#</td>
					<!--- <td>#registrations.fname#</td> --->
					<td>#left(registrations.branch_contact_lname,16)#</td>
					<td>#dateFormat(registrations.created_datetime,"mm/dd/yyyy")#</td>
					<td>
		<!---	Status Codes:
			
				0 - Either automatically approved or admin approved.
				1 - Could not find email address in henkel_gilson table.
				2 - IDH in henkel_gilson table was not valid.
				3 - IDH was already being used as a username in program_user table.
		--->
						<cfswitch expression="#registrations.status#">
							<cfcase value="0">
								Account Created
							</cfcase>
							<cfcase value="1">
								Branch Email<br>not Found
							</cfcase>
							<cfcase value="2">
								IDH was invalid
							</cfcase>
							<cfcase value="3">
								IDH already in<br>Program User
							</cfcase>
							<cfdefaultcase>
								UNKNOWN #registrations.status#<br>
							</cfdefaultcase>
						</cfswitch>
					</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr>
				<td colspan="100%" align="center">
					<br>There are no <cfif showAll GT 0>UNAPPROVED </cfif>registrations.
				</td>
			</tr>
		</cfif>
	</table>
<cfelse>
	<span class="pageinstructions">
		<a class="actionlink" href="#currentPage#?sortby=#sortby#&dir=#dir#&showAll=#showAll#">Return</a> to the registration list<cfif form.status GT 0> without making changes</cfif>.
		<br><br>
	</span>
	<br><br>
	<form name="approvalForm" action="#currentPage#?#CGI.QUERY_STRING#" method="post">
		<input type="hidden" name="ID" value="#url.r#" />
		<table width="100%" border="0" cellpadding="5" cellspacing="1" class="content">
			<tr class="contenthead">
				<td width="35%" class="formLabel">Registered:</td>
				<td width="65%" class="formData">#DateFormat(form.created_datetime,"Long")#</td>
			</tr>
			<tr>
				<td class="formLabel">Distributor Company Name:</td>
				<td><input name="company_name" type="text" value="#form.company_name#" size="25" maxlength="64"></td>
			</tr>
<!---			
			<tr>
				<td class="formLabel">Branch ID Code or ##:</td>
				<td><input name="branch_ID" type="text" value="#form.branch_ID#" size="25" maxlength="64"></td>
			</tr>
--->			
			<tr>
				<td class="formLabel">Branch ID Code or ##:</td>
				<!--- <cfif form.username GT "">
					<td>#form.username#</td>
				<cfelse> --->
					<td><input name="username" type="text" value="#form.username#" size="25" maxlength="16"></td>
				<!--- </cfif> --->
			</tr>
			<tr>
				<td class="formLabel">Address:</td>
				<td><input type="text" name="branch_address" value="#form.branch_address#" size="25" maxlength="64"></td>
			</tr>
			<tr>
				<td class="formLabel">City:</td>
				<td><input type="text" name="branch_city" value="#form.branch_city#" size="25" maxlength="30"></td>
			</tr>
			<tr>
				<td class="formLabel">State:</td>
				<td><input type="text" name="branch_state" value="#form.branch_state#" size="25" maxlength="32"></td>
			</tr>
			<tr>
				<td class="formLabel">Zip:</td>
				<td><input type="text" name="branch_zip" value="#form.branch_zip#" size="25" maxlength="32"></td>
			</tr>
			<tr>
				<td class="formLabel">First Name:</td>
				<td><input type="text" name="branch_contact_fname" value="#form.branch_contact_fname#" size="25" maxlength="40"></td>
			</tr>
			<tr>
				<td class="formLabel">Last Name:</td>
				<td><input type="text" name="branch_contact_lname" value="#form.branch_contact_lname#" size="25" maxlength="40"></td>
			</tr>
			<tr>
				<td class="formLabel">Contact Phone:</td>
				<td><input type="text" name="branch_phone" value="#form.branch_phone#" size="25" maxlength="35"></td>
			</tr>

			<tr>
				<td class="formLabel">Email:</td>
				<td><input type="text" name="branch_email" value="#form.branch_email#" size="25" maxlength="128"></td>
			</tr>
			<tr>
				<td class="formLabel">Loctite&reg; Products Rep:</td>
				<td><input type="text" name="branch_reps" value="#form.branch_reps#" size="25" maxlength="64"></td>
			</tr>
				<cfif form.status GT 0>
					<cfparam name="LookupZip" default="#form.branch_zip#">
					<tr>
						<td class="formLabel">Look up Zip Code:</td>
						<td>
							<input name="LookupRegion" type="hidden" id="LookupRegion" value="#LookupRegion#" />
							<input name="LookupZip" type="text" id="LookupZip" value="#LookupZip#" size="15" maxlength="32" />
							<img src="pics/magnify.gif" onClick="document.approvalForm.submit();" style="cursor:pointer;">
						</td>
					</tr>
					<cfif request.henkel_ID EQ "1000000069">
						<cfset LookupZip = Left(LookupZip,3)>
					</cfif>
					<cfquery name="distributors" datasource="#application.DS#">
						SELECT DISTINCT idh, company_name, zip
						FROM #application.database#.henkel_distributor
						WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
						<cfif LookupZip NEQ ''>
							AND zip LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#LookupZip#%">
						<cfelse>
							AND zip = '' OR zip IS NULL
						</cfif>
						ORDER BY company_name, zip
					</cfquery>
					<tr>
						<td class="formLabel">Distributor:</td>
						<td>Please verify distributor:<!--- Registrant entered "#form.company_name# #form.branch_zip#", which was not found. ---><br>
							<input type="hidden" name="company" value="#form.company_name#">
							<select name="selected_distributor">
								<option value="">--- Select Distributor ---</option>
								<cfloop query="distributors">
									<cfset zip_matches = false>
									<cfif request.henkel_ID NEQ "1000000069">
										<cfif distributors.zip EQ form.branch_zip>
											<cfset zip_matches = true>
										</cfif>
									<cfelse>
										<cfif Left(distributors.zip,3) EQ left(form.branch_zip,3)>
											<cfset zip_matches = true>
										</cfif>
									</cfif>
									<option value="#idh#" <cfif distributors.company_name EQ ListFirst(form.company_name) AND zip_matches>selected</cfif>>#left(distributors.company_name,55)# #distributors.zip#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				<cfelse>
					<tr>
						<td class="formLabel">Distributor:</td>
						<td>#company_name#
						</td>
					</tr>
				</cfif>			
			<tr><td class="formLabel">Pryor Year Sales:</td><td><input type="text" name="py_sales" value="#form.py_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">January Sales:</td><td><input type="text" name="jan_sales" value="#form.jan_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">February Sales:</td><td><input type="text" name="feb_sales" value="#form.feb_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">March Sales:</td><td><input type="text" name="mar_sales" value="#form.mar_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">April Sales:</td><td><input type="text" name="apr_sales" value="#form.apr_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">May Sales:</td><td><input type="text" name="may_sales" value="#form.may_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">June Sales:</td><td><input type="text" name="jun_sales" value="#form.jun_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">July Sales:</td><td><input type="text" name="jul_sales" value="#form.jul_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">August Sales:</td><td><input type="text" name="aug_sales" value="#form.aug_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">September Sales:</td><td><input type="text" name="sep_sales" value="#form.sep_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">October Sales:</td><td><input type="text" name="oct_sales" value="#form.oct_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">November Sales:</td><td><input type="text" name="nov_sales" value="#form.nov_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">December Sales:</td><td><input type="text" name="dec_sales" value="#form.dec_sales#" size="25" maxlength="14"></td></tr>
			<tr><td class="formLabel">Target Sales:</td><td><input type="text" name="dec_sales" value="#(form.py_sales * 1.05)#" size="25" maxlength="14"></td></tr>
		<br />
		<tr>
			<td colspan="2" align="center">
				<cfif form.status GT 0>
					<input name="submitButton" type="submit" value="  Save Changes  " />
				<cfelse>
					<input name="saveButton" type="submit" value="  Save Changes  " />
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a href="program_user.cfm?pgfn=edit&puser_id=#form.program_user_ID#">View Program User</a>
				</cfif>
			</td>
		</tr>
	</form>
</cfif>
</cfoutput>

<cfinclude template="includes/footer.cfm">
