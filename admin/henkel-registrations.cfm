<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->

<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="showAll" default="false">
<cfparam name="sortby" default="created_datetime">
<cfparam name="dir" default="0">

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

<!--- Move registration --->
<cfparam name="url.m" default="0">
<cfif NOT isNumeric(url.m) OR url.m LT 0>
	<cfset url.m = 0>
</cfif>
<cfif url.m GT 0>
	<!--- Just in case they both have a positive number.  Doing a kludge in the 'select where id =' below --->
	<cfset url.r = 0>
</cfif>
<cfset thisDelim = "|">

<cfset alert_msg = "">

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfset emailTemplateID = request.selected_henkel_program.registration_template_ID>
<cfif NOT isNumeric(emailTemplateID) OR emailTemplateID LTE 0>
	<cfset alert_msg = "Please assign an email template to this Henkel program.">
	<cfset url.r = 0>
	<cfset url.d = 0>
	<cfset url.m = 0>
</cfif>

<cfquery name="GetProgram" datasource="#application.DS#">
	SELECT cc_max_default 
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">
</cfquery>


<!--- Static variables --->
<cfset Points = 10>
<cfset Notes = "Approved in admin from Henkel registration form - #Points# for registering">

<cfif url.d GT 0>
	<cflock name="DeleteHenkelRegistrationLock" timeout="30">
		<cfquery name="checkDelete" datasource="#application.DS#">
			SELECT email, status
			FROM #application.database#.henkel_register
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.d#" maxlength="10">
		</cfquery>
		<cfif checkDelete.recordcount EQ 1 AND checkDelete.status GT 0>
			<cfquery name="deleteRegistration" datasource="#application.DS#">
				DELETE FROM #application.database#.henkel_register
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.d#" maxlength="10">
			</cfquery>
			<cfset alert_msg = "#checkDelete.email# deleted.">
		</cfif>
	</cflock>
</cfif>
<cfif url.r GT 0 OR url.m GT 0>
	<cfquery name="registration" datasource="#application.DS#">
		SELECT ID, created_datetime, email, username, fname, lname, phone, company,
			is_international, address1, city, state, zip, country, region, program_ID, program_user_ID, status,
			user_function, registration_type, alternate_emails
		FROM #application.database#.henkel_register
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.r+url.m#" maxlength="10">
	</cfquery>
	<cfif registration.recordcount EQ 1>
		<cfparam name="form.created_datetime" default="#registration.created_datetime#">
		<cfparam name="form.email" default="#registration.email#">
		<cfparam name="form.username" default="#registration.username#">
		<cfparam name="form.fname" default="#registration.fname#">
		<cfparam name="form.lname" default="#registration.lname#">
		<cfparam name="form.phone" default="#registration.phone#">
		<cfparam name="form.cc_max" default="#GetProgram.cc_max_default#">
		<cfparam name="form.company" default="#registration.company#">
		<cfparam name="form.is_international" default="#registration.is_international#">
		<cfparam name="form.address1" default="#registration.address1#">
		<cfparam name="form.city" default="#registration.city#">
		<cfparam name="form.state" default="#registration.state#">
		<cfparam name="form.zip" default="#registration.zip#">
		<cfparam name="form.country" default="#registration.country#">
		<cfparam name="form.region" default="#registration.region#">
		<cfparam name="form.program_ID" default="#registration.program_ID#">
		<cfparam name="form.program_user_ID" default="#registration.program_user_ID#">
		<cfparam name="form.status" default="#registration.status#">
		<cfparam name="form.award_points" default="#Points#">
		<cfparam name="form.distributor" default="#registration.company#">
		<cfparam name="form.user_function" default="#registration.user_function#">
		<cfparam name="form.registration_type" default="#registration.registration_type#">
		<cfparam name="form.alternate_emails" default="#registration.alternate_emails#">
		<cfparam name="LookupRegion" default="#form.region#">
		<cfparam name="LookupZip" default="#form.zip#">
	<cfelse>
		<cfset url.r = 0>
		<cfset url.m = 0>
	</cfif>
</cfif>

<cfif isDefined("form.submitMove") AND isDefined("form.ID") AND isNumeric(form.ID) AND form.ID GT 0 AND form.status GT 0>
	<cfif form.newProgram EQ "" OR NOT isNumeric(form.newProgram)>
		<cfset alert_msg = alert_msg & "Please select the program you want to move this registration to.\n">
	</cfif>
	<cfif alert_msg EQ "">
		<cfquery name="UpdateRegistration" datasource="#application.DS#">
			UPDATE #application.database#.henkel_register
			SET program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.newProgram#" maxlength="10">
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
		</cfquery>
		<cfset url.m = 0>
		<cfset alert_msg = "Registration moved.">
	</cfif>
</cfif>

<cfif isDefined("form.submitButton") AND isDefined("form.ID") AND isNumeric(form.ID) AND form.ID GT 0 AND form.status GT 0>
	<cfif form.email EQ "" OR NOT FLGen_IsValidEmail(form.email)>
		<cfset alert_msg = alert_msg & "Please enter a valid email address.\n">
	</cfif>
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
	<cfif form.fname EQ "">
		<cfset alert_msg = alert_msg & "Please enter a first name.\n">
	</cfif>
	<cfif form.lname EQ "">
		<cfset alert_msg = alert_msg & "Please enter a last lname.\n">
	</cfif>
	<cfif form.phone EQ "">
		<cfset alert_msg = alert_msg & "Please enter a phone number.\n">
	</cfif>
	<cfif form.is_international>
		<cfif form.distributor EQ "" AND NOT isDefined("form.overrideIDH")>
			<cfset alert_msg = alert_msg & "Please select the #request.selected_henkel_program.distributor_label#.\n">
		<cfelseif form.distributor NEQ "" AND isDefined("form.overrideIDH")>
			<cfset alert_msg = alert_msg & "You have selected the #LCase(request.selected_henkel_program.distributor_label)# AND chose to override the IDH number.  Please do one or the other.\n">
		</cfif>
	<cfelse>
		<cfif ( form.distributor EQ "" OR ListLen(form.distributor,thisDelim) NEQ 2) AND NOT isDefined("form.overrideIDH") >
			<cfset alert_msg = alert_msg & "Please select the #request.selected_henkel_program.distributor_label#.\n">
		<cfelseif form.distributor NEQ "" AND ListLen(form.distributor,thisDelim) EQ 2 AND isDefined("form.overrideIDH") >
			<cfset alert_msg = alert_msg & "You have selected the #LCase(request.selected_henkel_program.distributor_label)# AND chose to override the IDH number.  Please do one or the other.\n">
		</cfif>
	</cfif>
	<cfif form.address1 EQ "">
		<cfset alert_msg = alert_msg & "Please enter the address.\n">
	</cfif>
	<cfif form.city EQ "">
		<cfset alert_msg = alert_msg & "Please enter a city.\n">
	</cfif>
	<cfif form.state EQ "">
		<cfset alert_msg = alert_msg & "Please enter a state.\n">
	</cfif>
	<cfif form.is_international AND form.country EQ "">
		<cfset alert_msg = alert_msg & "Please enter a country for this international #LCase(request.selected_henkel_program.distributor_label)#.\n">
	</cfif>
	<cfif NOT form.is_international AND request.selected_henkel_program.has_regions>
		<cfif request.selected_henkel_program.is_region_by_state>
			<cfif form.region EQ "">
				<cfset alert_msg = alert_msg & "Please select a region.\n">
			</cfif>
		<cfelse>
			<cfif form.region EQ "" OR ListLen(form.region,thisDelim) NEQ 2>
				<cfset alert_msg = alert_msg & "Please select a region.\n">
			</cfif>
			<cfif alert_msg EQ "" AND NOT isDefined("form.overrideIDH")>
				<cfset zip_matches = true>
				<cfif request.selected_henkel_program.is_canadian>
					<cfif Left(ListLast(form.region,thisDelim),3) NEQ left(ListLast(form.distributor,thisDelim),3)>
						<cfset zip_matches = false>
					</cfif>
				<cfelse>
					<cfif Left(ListLast(form.region,thisDelim),5) NEQ Left(ListLast(form.distributor,thisDelim),5)>
						<cfset zip_matches = false>
					</cfif>
				</cfif>
				<cfif NOT zip_matches>
					<cfset alert_msg = alert_msg & "#request.selected_henkel_program.distributor_label# zip code does not match region zip code.\n">
				</cfif>
			</cfif>
		</cfif>
	</cfif>
	<cfif trim(form.alternate_emails) NEQ "">
		<cfset thisText = Replace(trim(form.alternate_emails),"#CHR(13)##CHR(10)#",",","ALL")>
		<cfset thisText = Replace(thisText," ",",","ALL")>
		<cfset thisText = Replace(thisText,";",",","ALL")>
		<cfloop list="#thisText#" index="thisEmail">
			<cfif NOT REFind("^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$",trim(thisEmail))>
				<cfset alert_msg = alert_msg & "#trim(thisEmail)# is not a valid email address.\n">
			</cfif>
		</cfloop>
		<cfset form.alternate_emails = thisText>
	</cfif>
	<cfif alert_msg EQ "">
		<cflock name="program_userLock" timeout="60">
			<cfif form.program_user_ID EQ 0>
				<cfset thisIDH = "">
				<cfif NOT isDefined("form.overrideIDH")>
					<cfquery name="GetDistributor" datasource="#application.DS#">
						SELECT idh
						FROM #application.database#.henkel_distributor
						WHERE company_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ListFirst(form.distributor,thisDelim)#">
						AND zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ListLast(form.distributor,thisDelim)#">
					</cfquery>
					<cfset thisIDH = GetDistributor.idh>
				</cfif>
				<cfif thisIDH EQ "" OR mid(thisIDH,2,3) EQ "N/A">
					<cfset thisIDH = request.selected_henkel_program.default_IDH>
				</cfif>
				<cfquery name="AddProgramUser" datasource="#application.DS#">
					INSERT INTO #application.database#.program_user (
						created_user_ID, created_datetime, program_ID, username, fname, lname, cc_max,
						ship_company, ship_address1, ship_city, ship_state, ship_zip, ship_country, phone, email, is_active, idh, registration_type)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="16">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.fname#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.lname#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.cc_max#" maxlength="6">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Left(ListFirst(form.distributor,thisDelim),64)#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.address1#" maxlength="64">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.city#" maxlength="30">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.state#" maxlength="32">,
						<cfif form.is_international OR request.selected_henkel_program.is_region_by_state>
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.zip#" maxlength="32">,
						<cfelse>
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ListLast(form.region,thisDelim)#" maxlength="32">,
						</cfif>
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.country#" maxlength="35">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.phone#" maxlength="35">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128">,
						1,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisIDH#" maxlength="16">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.registration_type#" maxlength="16">
					)
				</cfquery>
				<cfquery name="GetMaxID" datasource="#application.DS#">
					SELECT MAX(ID) AS maxID
					FROM #application.database#.program_user
				</cfquery>
				<cfset HoldPoints = 0>
				<cfquery name="getHoldPoints" datasource="#application.DS#">
					SELECT SUM(points) as totalpoints
					FROM #application.database#.henkel_hold_user
					WHERE email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#">
				</cfquery>
				<cfset programUserID = GetMaxID.maxID>
				<cfif isNumeric(getHoldPoints.totalpoints)>
					<cfset HoldPoints = getHoldPoints.totalpoints>
					<cfquery name="deleteHoldPoints" datasource="#application.DS#">
						DELETE FROM #application.database#.henkel_hold_user
						WHERE email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#">
					</cfquery>
				</cfif>
				<cfquery name="AwardPoints" datasource="#application.DS#">
					INSERT INTO #application.database#.awards_points (
						created_user_ID, created_datetime, user_ID, points, notes)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#programUserID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Points+HoldPoints#">,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Notes#">
					)
				</cfquery>
				<!--- Send email --->
				<cfset user_name = form.username>
				<cfset first_name = form.fname>
				<cfset last_name = form.lname>
				<cfset email = form.email>
				<cfset emailFrom = "henkel.rewardsboard@us.henkel.com">
				<cfinclude template="/includes/henkel_award_email.cfm">
			<cfelse>
				<cfset programUserID = form.program_user_ID>
			</cfif>
			<cfquery name="UpdateRegistration" datasource="#application.DS#">
				UPDATE #application.database#.henkel_register
				SET email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128">,
					username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="16">,
					fname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.fname#" maxlength="30">,
					lname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.lname#" maxlength="30">,
					phone = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.phone#" maxlength="35">,
					company = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Left(ListFirst(form.distributor,thisDelim),64)#" maxlength="64">,
					address1 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.address1#" maxlength="64">,
					city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.city#" maxlength="30">,
					state = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.state#" maxlength="32">,
					<cfif request.selected_henkel_program.is_region_by_state>
						zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.zip#" maxlength="32">,
					<cfelse>
						zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ListLast(form.region,thisDelim)#" maxlength="32">,
					</cfif>
					region = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ListFirst(form.region,thisDelim)#" maxlength="10">,
					program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">,
					program_user_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#programUserID#" maxlength="10">,
					status = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="0">,
					registration_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.registration_type#" maxlength="10">,
					alternate_emails = <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR" value="#form.alternate_emails#" null="#len(trim(form.alternate_emails)) EQ 0#">
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
			</cfquery>
		</cflock>
		<cfset url.r = 0>
		<cfset alert_msg = "Changes were saved">
	</cfif>
<cfelseif isDefined("form.submitOther") AND isDefined("form.ID") AND isNumeric(form.ID) AND form.ID GT 0>
	<cfif trim(form.alternate_emails) NEQ "">
		<cfset thisText = Replace(trim(form.alternate_emails),"#CHR(13)##CHR(10)#",",","ALL")>
		<cfset thisText = Replace(thisText," ",",","ALL")>
		<cfset thisText = Replace(thisText,";",",","ALL")>
		<cfloop list="#thisText#" index="thisEmail">
			<cfif NOT REFind("^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$",trim(thisEmail))>
				<cfset alert_msg = alert_msg & "#trim(thisEmail)# is not a valid email address.\n">
			</cfif>
		</cfloop>
		<cfset form.alternate_emails = thisText>
	</cfif>
	<cfif alert_msg EQ "">
		<cfquery name="UpdateRegistration" datasource="#application.DS#">
			UPDATE #application.database#.henkel_register
			SET alternate_emails = <cfqueryparam cfsqltype="CF_SQL_LONGVARCHAR" value="#form.alternate_emails#" null="#len(trim(form.alternate_emails)) EQ 0#">
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
		</cfquery>
		<cfset url.r = 0>
		<cfset alert_msg = "Changes were saved">
	</cfif>
</cfif>

<cfset leftnavon = "henkel_registrations">
<cfinclude template="includes/header.cfm">

<cfoutput>
<span class="highlight">#request.selected_henkel_program.program_name#</span>

<cfif url.m GT 0>
	<span class="pageinstructions">
		<a class="actionlink" href="#currentPage#?sortby=#sortby#&dir=#dir#&showAll=#showAll#">Return</a> to the registration list without making changes.
		<br><br>
		<cfset isDisabled = true>
		<cfset basicStatus = form.status>
		<cfif basicStatus GTE 10>
			<cfset basicStatus = basicStatus - 10>
		</cfif>
		<cfswitch expression="#basicStatus#">
			<cfcase value="0">
				<cfif form.status EQ 0>
					<span class="alert">This registration is already approved.</span>
					<cfset isDisabled = true>
				</cfif>
			</cfcase>
			<cfcase value="1">
				The #LCase(request.selected_henkel_program.distributor_label)# was found, but the region was not found.
			</cfcase>
			<cfcase value="2">
				The #LCase(request.selected_henkel_program.distributor_label)# was not found, but the region was found.
			</cfcase>
			<cfcase value="3">
				Neither the #LCase(request.selected_henkel_program.distributor_label)# nor the region was found.
			</cfcase>
			<cfdefaultcase>
				<span class="alert">UNKNOWN status: #registrations.status#.</span>
			</cfdefaultcase>
		</cfswitch>
		<cfif form.status GTE 10>
			<br>Duplicate email address.
		</cfif>
	</span>
	<br><br>
	<form name="moveForm" action="#currentPage#?#CGI.QUERY_STRING#" method="post">
		<input type="hidden" name="ID" value="#url.m#" />
		<table width="100%" border="0" cellpadding="5" cellspacing="1" class="content">
			<tr class="contenthead">
				<td width="35%" class="formLabel">Registered:</td>
				<td width="65%" class="formData">#DateFormat(form.created_datetime,"Long")#</td>
			</tr>
			<tr>
				<td class="formLabel">Email:</td>
				<td><input name="email" type="text" value="#form.email#" size="25" maxlength="50" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Username:</td>
				<td><input name="username" type="text" value="#form.username#" size="25" maxlength="50" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">First Name:</td>
				<td><input type="text" name="fname" value="#form.fname#" size="25" maxlength="40" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Last Name:</td>
				<td><input type="text" name="lname" value="#form.lname#" size="25" maxlength="40" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Function:</td>
				<td>#form.user_function#</td>
			</tr>
			<tr>
				<td class="formLabel">Phone:</td>
				<td><input name="phone" type="text" value="#form.phone#" size="25" maxlength="12" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Credit Card Max:</td>
				<td><input name="cc_max" type="text" value="#form.cc_max#" size="8" maxlength="6" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr class="contenthead">
				<td colspan="2">
					&nbsp;&nbsp;&nbsp;&nbsp;<strong><cfif form.is_international>International<cfelse>#request.selected_henkel_program.company_name# [#request.selected_henkel_program.program_name#]</cfif> #LCase(request.selected_henkel_program.distributor_label)#</strong>
				</td>
			</tr>
			<tr>
				<td class="formLabel">Address:</td>
				<td><input name="address1" type="text" value="#form.address1#" size="25" maxlength="12" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">City:</td>
				<td><input name="city" type="text" id="city" value="#form.city#" size="25" maxlength="50" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">State/Province:</td>
				<td><input name="state" type="text" value="#form.state#" size="25" maxlength="32" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<cfif form.is_international>
				<tr>
					<td class="formLabel">Country:</td>
					<td><input name="country" type="text" value="#form.country#" size="25" maxlength="32" <cfif isDisabled>disabled="disabled"</cfif> /></td>
				</tr>
			</cfif>
			<tr>
				<td class="formLabel">Zip / Postal Code:</td>
				<td><input name="zip" type="text" value="#form.zip#" size="25" maxlength="32" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Registration Type:</td>
				<td>
				<input <cfif isDisabled>disabled="disabled"</cfif> type="radio" name="registration_type" value="Branch" <cfif form.registration_type EQ "Branch">checked</cfif>> Branch
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input <cfif isDisabled>disabled="disabled"</cfif> type="radio" name="registration_type" value="Individual" <cfif form.registration_type EQ "Individual">checked</cfif>> Individual
				</td>
			</tr>
			<tr>
				<td class="formLabel">Branch Participants:</td>
				<td>#form.alternate_emails#</td>
			</tr>
		</table>
		<br />
		<div align="center">
		Move from #request.selected_henkel_program.company_name# [#request.selected_henkel_program.program_name#] to 
		<select name="newProgram">
			<option value="">--- Select ---</option>
			<cfloop query="request.henkel_programs">
				<cfif form.program_ID NEQ request.henkel_programs.ID>
					<option value="#request.henkel_programs.ID#" >#request.henkel_programs.company_name# [#request.henkel_programs.program_name#]</option>
				</cfif>
			</cfloop>
		</select>
		<br><br>
		<input name="submitMove" type="submit" value="  Move Registration  " />
		</div>
	</form>
<cfelseif url.r EQ 0>
	<cfquery name="registrations" datasource="#application.DS#">
		SELECT ID, created_datetime, email, username, fname, lname, phone,
				company, address1, city, state, zip, region, program_ID, program_user_ID, status
		FROM #application.database#.henkel_register
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		<cfif NOT showAll>
			AND status > 0
		</cfif>
		<cfif sortby NEQ "">
			ORDER BY #sortby# <cfif dir>DESC</cfif>
		</cfif>
	</cfquery>
	<table cellspacing="0" cellpadding="5" border="0">
		<tr>
			<td colspan="3">
				<p>There <cfif registrations.recordCount NEQ 1>are<cfelse>is</cfif> #registrations.recordcount# registration<cfif registrations.recordCount NEQ 1>s</cfif><cfif NOT showAll> to approve</cfif>.</p>
			</td>
			<td colspan="2" align="right">
				<a href="#currentPage#?sortby=#sortby#&dir=#dir#&showAll=<cfif showAll>0<cfelse>1</cfif>"><cfif showAll>Hide Approved<cfelse>Show All</cfif> Registrations</a>
			</td>
		</tr>
		<tr class="contenthead">
			<td width="10%"></td>
			<td width="32%"><a class="actionlink" href="#currentPage#?sortby=email<cfif sortby EQ 'email'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Email</a><cfif sortby EQ 'email'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
			<!--- <td width="18%"><a class="actionlink" href="#currentPage#?sortby=fname<cfif sortby EQ 'fname'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">First Name</a><cfif sortby EQ 'fname'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td> --->
			<td width="18%"><a class="actionlink" href="#currentPage#?sortby=lname<cfif sortby EQ 'lname'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Last Name</a><cfif sortby EQ 'lname'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
			<td width="14%"><a class="actionlink" href="#currentPage#?sortby=created_datetime<cfif sortby EQ 'created_datetime'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Registered</a><cfif sortby EQ 'created_datetime'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
			<td width="26%"><a class="actionlink" href="#currentPage#?sortby=status<cfif sortby EQ 'status'>&dir=#ABS(dir-1)#</cfif>&showAll=#showAll#">Status</a><cfif sortby EQ 'status'>&nbsp;<img src="/pics/contrls-<cfif dir>desc<cfelse>asc</cfif>.gif" /></cfif></td>
		</tr>
		<cfif registrations.recordcount GT 0>
			<cfloop query="registrations">
				<tr>
					<td nowrap="nowrap">
						<a class="actionlink" href="#currentPage#?r=#registrations.ID#&sortby=#sortby#&dir=#dir#&showAll=#showAll#"><cfif registrations.status EQ 0>View<cfelse>Approve</cfif></a>
						<cfif registrations.status GT 0>
							<a class="actionlink" href="#currentPage#?d=#registrations.ID#&sortby=#sortby#&dir=#dir#&showAll=#showAll#" onclick="return confirm('Are you sure you want to delete this registration?  There is NO UNDO.')">Delete</a>
							<a class="actionlink" href="#currentPage#?m=#registrations.ID#&sortby=#sortby#&dir=#dir#&showAll=#showAll#">Move</a>
						</cfif>
					</td>
					<td>#left(registrations.email,32)#</td>
					<!--- <td>#registrations.fname#</td> --->
					<td>#left(registrations.lname,16)#</td>
					<td>#dateFormat(registrations.created_datetime,"mm/dd/yyyy")#</td>
					<td>
		<!---	Status Codes:
			
				0 - Everything is fine.  Region was found.  Distributor was found.  Points Awarded.  Yada yada yada.
				1 - Could not find region by zip code in 'xref_zipcode_region', but found in distributor.
					or if looking up region by state, then not found in 'henkel_territory' by state.
				2 - Could not find distributor by company name in 'henkel_distributor', but found in region.
				3 - Could not find in either place.
	
				Add 10 to the status for duplicate email addresses.
		--->
						<cfset basicStatus = registrations.status>
						<cfif basicStatus GTE 10>
							<cfset basicStatus = basicStatus - 10>
						</cfif>
						<cfswitch expression="#basicStatus#">
							<cfcase value="0">
								<cfif registrations.status EQ 0>
									Points Awarded<br>
								</cfif>
							</cfcase>
							<cfcase value="1">
								<cfif request.selected_henkel_program.has_regions>
									#request.selected_henkel_program.distributor_label# Found<br>
									Region Not Found<br>
								<cfelse>
									#request.selected_henkel_program.distributor_label# Found<br><!--- This status should not happen if program has no regions --->
								</cfif>
							</cfcase>
							<cfcase value="2">
								<cfif request.selected_henkel_program.has_regions>
									#request.selected_henkel_program.distributor_label# Not Found<br>
									Region Found<br>
								<cfelse>
									#request.selected_henkel_program.distributor_label# Not Found<br>
								</cfif>
							</cfcase>
							<cfcase value="3">
								<cfif request.selected_henkel_program.has_regions>
									Neither #request.selected_henkel_program.distributor_label#<br>
									nor Region Found<br>
								<cfelse>
									#request.selected_henkel_program.distributor_label# Not Found<br>
								</cfif>
							</cfcase>
							<cfdefaultcase>
								UNKNOWN #registrations.status#<br>
							</cfdefaultcase>
						</cfswitch>
						<cfif registrations.status GTE 10>
							Duplicate email
						</cfif>
					</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr>
				<td colspan="100%" align="center">
					<br>There are no <cfif NOT showAll>UNAPPROVED </cfif>registrations.
				</td>
			</tr>
		</cfif>
	</table>
<cfelse>
	<span class="pageinstructions">
		<a class="actionlink" href="#currentPage#?sortby=#sortby#&dir=#dir#&showAll=#showAll#">Return</a> to the registration list<cfif form.status GT 0> without making changes</cfif>.
		<br><br>
		<cfset isDisabled = false>
		<cfset basicStatus = form.status>
		<cfif basicStatus GTE 10>
			<cfset basicStatus = basicStatus - 10>
		</cfif>
		<cfswitch expression="#basicStatus#">
			<cfcase value="0">
				<cfif form.status EQ 0>
					<span class="alert">This registration is already approved.</span>
					<cfset isDisabled = true>
				</cfif>
			</cfcase>
			<cfcase value="1">
				The #LCase(request.selected_henkel_program.distributor_label)# was found, but the region was not found.
			</cfcase>
			<cfcase value="2">
				The #LCase(request.selected_henkel_program.distributor_label)# was not found, but the region was found.
			</cfcase>
			<cfcase value="3">
				Neither the #LCase(request.selected_henkel_program.distributor_label)# nor the region was found.
			</cfcase>
			<cfdefaultcase>
				<span class="alert">UNKNOWN status: #registrations.status#.</span>
			</cfdefaultcase>
		</cfswitch>
		<cfif form.status GTE 10>
			<br>Duplicate email address.
		</cfif>
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
				<td class="formLabel">Email:</td>
				<td><input name="email" type="text" value="#form.email#" size="25" maxlength="50" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Username:</td>
				<td><input name="username" type="text" value="#form.username#" size="25" maxlength="50" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">First Name:</td>
				<td><input type="text" name="fname" value="#form.fname#" size="25" maxlength="40" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Last Name:</td>
				<td><input type="text" name="lname" value="#form.lname#" size="25" maxlength="40" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Function:</td>
				<td>#form.user_function#</td>
			</tr>
			<tr>
				<td class="formLabel">Phone:</td>
				<td><input name="phone" type="text" value="#form.phone#" size="25" maxlength="12" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">Credit Card Max:</td>
				<td><input name="cc_max" type="text" value="#form.cc_max#" size="8" maxlength="6" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr class="contenthead">
				<td colspan="2">
					&nbsp;&nbsp;&nbsp;&nbsp;<strong><cfif form.is_international>International<cfelse>#request.selected_henkel_program.company_name# [#request.selected_henkel_program.program_name#]</cfif> #LCase(request.selected_henkel_program.distributor_label)#</strong>
				</td>
			</tr>
			<tr>
				<td class="formLabel">Address:</td>
				<td><input name="address1" type="text" value="#form.address1#" size="25" maxlength="12" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">City:</td>
				<td><input name="city" type="text" id="city" value="#form.city#" size="25" maxlength="50" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<tr>
				<td class="formLabel">State/Province:</td>
				<td><input name="state" type="text" value="#form.state#" size="25" maxlength="32" <cfif isDisabled>disabled="disabled"</cfif> /></td>
			</tr>
			<cfif form.is_international>
				<tr>
					<td class="formLabel">Country:</td>
					<td><input name="country" type="text" value="#form.country#" size="25" maxlength="32" <cfif isDisabled>disabled="disabled"</cfif> /></td>
				</tr>
			<cfelse>
				<input type="hidden" name="country" value="USA">
			</cfif>
			<input type="hidden" name="is_international" value="#form.is_international#">
			<cfif form.is_international>
				<tr>
					<td class="formLabel">Zip / Postal Code:</td>
					<td><input name="zip" type="text" value="#form.zip#" size="25" maxlength="32" <cfif isDisabled>disabled="disabled"</cfif> /></td>
				</tr>
				<cfif form.status GT 0>
					<!--- <tr>
						<td class="formLabel">Look up Zip Code:</td>
						<td>
							<input name="LookupRegion" type="hidden" id="LookupRegion" value="#LookupRegion#" />
							<input name="LookupZip" type="text" id="LookupZip" value="#LookupZip#" size="15" maxlength="32" />
							<img src="pics/magnify.gif" onClick="document.approvalForm.submit();" style="cursor:pointer;">
						</td>
					</tr> --->
					<cfquery name="distributors" datasource="#application.DS#">
						SELECT DISTINCT company_name
						FROM #application.database#.henkel_distributor
						WHERE is_international = 1
						AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
						ORDER BY company_name
					</cfquery>
					<tr>
						<td class="formLabel">#request.selected_henkel_program.distributor_label#:</td>
						<td><cfif basicStatus GT 1>Registrant entered "#form.company#, which was not found.<br></cfif>
							<input type="hidden" name="company" value="#form.company#">
							<select name="distributor">
								<option value="">--- Select #request.selected_henkel_program.distributor_label# ---</option>
								<cfloop query="distributors">
									<option value="#distributors.company_name#" <cfif distributors.company_name EQ ListFirst(form.distributor,thisDelim)>selected</cfif>>#left(distributors.company_name,65)#</option>
								</cfloop>
							</select>
							<input type="checkbox" name="overrideIDH" value="1" <cfif isDefined("form.overrideIDH")>checked</cfif>>&nbsp;&nbsp;Override IDH with #request.selected_henkel_program.default_IDH#
						</td>
					</tr>
				<cfelse>
					<tr>
						<td class="formLabel">#request.selected_henkel_program.distributor_label#:</td>
						<td>#form.distributor#
						</td>
					</tr>
					<tr>
						<td class="formLabel">Region:</td>
						<td>International</td>
					</tr>
				</cfif>
			<cfelse>
				<cfif form.status GT 0>
					<tr>
						<td class="formLabel">Look up Zip Code:</td>
						<td>
							<input name="LookupRegion" type="hidden" id="LookupRegion" value="#LookupRegion#" />
							<input name="LookupZip" type="text" id="LookupZip" value="#LookupZip#" size="15" maxlength="32" />
							<img src="pics/magnify.gif" onClick="document.approvalForm.submit();" style="cursor:pointer;">
						</td>
					</tr>
					<cfif request.selected_henkel_program.has_regions>
						<cfif request.selected_henkel_program.is_region_by_state>
							<cfquery name="regions" datasource="#application.DS#">
								SELECT states, sap_ty
								FROM #application.database#.henkel_territory
								WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
								AND states LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#form.state#%">
							</cfquery>
							<tr>
								<td class="formLabel">Region<br>(by State):</td>
								<td><cfif basicStatus EQ 1 OR basicStatus EQ 3>Registrant entered "#form.state#", which was not found.<br></cfif>
									<select name="region">
										<option value="">--- Select ---</option>
										<cfloop query="regions">
											<option value="#right(regions.sap_ty,8)#" <cfif ListFind(regions.states,form.state)>selected</cfif>>#regions.states#</option>
										</cfloop>
									</select>
								</td>
							</tr>
						<cfelse>
							<cfif request.selected_henkel_program.is_canadian>
								<cfset LookupZip = Left(LookupZip,3)>
							</cfif>
							<cfquery name="regions" datasource="#application.DS#">
								SELECT zipcode, region
								FROM #application.database#.xref_zipcode_region
								WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
								AND zipcode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#LookupZip#%">
								ORDER BY zipcode
							</cfquery>
							<tr>
								<td class="formLabel">Region<br>(by Zip Code):</td>
								<td><cfif basicStatus EQ 1 OR basicStatus EQ 3>Registrant entered "#form.zip#", which was not found.<br></cfif>
									<select name="region">
										<option value="">--- Select ---</option>
										<cfloop query="regions">
											<option value="#regions.region##thisDelim##regions.zipcode#" <cfif regions.region EQ LookupRegion AND regions.zipcode EQ LookupZip>selected</cfif>>#regions.zipcode#</option>
										</cfloop>
									</select>
								</td>
							</tr>
						</cfif>
					</cfif>
					<cfquery name="distributors" datasource="#application.DS#">
						SELECT DISTINCT company_name, zip
						FROM #application.database#.henkel_distributor
						WHERE ( zip LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#LookupZip#%">
						AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">)
						OR company_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(form.company,10)#%">
						ORDER BY company_name, zip
					</cfquery>
					<tr>
						<td class="formLabel">#request.selected_henkel_program.distributor_label#:</td>
						<td><cfif basicStatus GT 1>Registrant entered "#form.company# #form.zip#", which was not found.<br></cfif>
							<input type="hidden" name="company" value="#form.company#">
							<select name="distributor">
								<option value="">--- Select #request.selected_henkel_program.distributor_label# ---</option>
								<cfloop query="distributors">
									<cfset zip_matches = false>
									<cfif request.selected_henkel_program.is_canadian>
										<cfif Left(distributors.zip,3) EQ left(form.zip,3)>
											<cfset zip_matches = true>
										</cfif>
									<cfelse>
										<cfif distributors.zip EQ form.zip>
											<cfset zip_matches = true>
										</cfif>
									</cfif>
									<option value="#distributors.company_name##thisDelim##distributors.zip#" <cfif distributors.company_name EQ ListFirst(form.distributor,thisDelim) AND zip_matches>selected</cfif>>#left(distributors.company_name,55)# #distributors.zip#</option>
								</cfloop>
							</select>
							<input type="checkbox" name="overrideIDH" value="1" <cfif isDefined("form.overrideIDH")>checked</cfif>>&nbsp;&nbsp;Override IDH with #request.selected_henkel_program.default_IDH#
						</td>
					</tr>
				<cfelse>
					<tr>
						<td class="formLabel">#request.selected_henkel_program.distributor_label#:</td>
						<td>#form.distributor#
						</td>
					</tr>
					<cfquery name="regions" datasource="#application.DS#">
						SELECT zipcode, region
						FROM #application.database#.xref_zipcode_region
						WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
						ORDER BY zipcode
					</cfquery>
					<tr>
						<td class="formLabel">Region<br>(by Zip Code):</td>
						<td>#form.zip#
						</td>
					</tr>
				</cfif>
			</cfif>
			<tr>
				<td class="formLabel">Registration Type:</td>
				<td>
				<input <cfif isDisabled>disabled="disabled"</cfif> type="radio" name="registration_type" value="Branch" <cfif form.registration_type EQ "Branch">checked</cfif>> Branch
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input <cfif isDisabled>disabled="disabled"</cfif> type="radio" name="registration_type" value="Individual" <cfif form.registration_type EQ "Individual">checked</cfif>> Individual
				</td>
			</tr>
			<tr>
				<td class="formLabel">Branch Participants:</td>
				<td><textarea name="alternate_emails" rows="5" cols="60" <!--- <cfif isDisabled>disabled="disabled"</cfif> --->>#form.alternate_emails#</textarea></td>
			</tr>
		</table>
		<br />
		#RepeatString("&nbsp;",30)#
		<cfif form.status GT 0>
			<input name="submitButton" type="submit" value="  Save Changes, Approve and Award Points  " />
		<cfelse>
			<input name="submitOther" type="submit" value="  Save Changes  " />
			<a href="program_user.cfm?pgfn=edit&puser_id=#form.program_user_ID#&program_ID=#request.henkel_ID#">View Program User</a>
		</cfif>
	</form>
</cfif>
</cfoutput>

<cfinclude template="includes/footer.cfm">
