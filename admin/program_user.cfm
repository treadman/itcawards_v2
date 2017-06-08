<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000020,true)>

<!--- param all variables used on this page --->
<cfparam name="x" default="">
<cfparam name="delete" default="">
<cfparam name="company_name" default="">
<cfparam name="where_string" default="">
<cfparam name="program_ID" default="">
<cfparam name="puser_ID" default="">
<cfparam name="datasaved" default="no">
<cfparam name="duplicateusername" default="false">
<cfparam name="pgfn" default="list">
<cfparam name="entered_by_program_admin" default="">
<cfparam name="find_users_categories" default="0">
<cfparam name="has_categories" default="false">
<cfparam name="email_from" default="#application.AwardsFromEmail#">
<cfparam name="email_subject" default="Award Notification">

<!--- param search criteria xxS=ColumnSort xxT=SearchString xxL=Letter --->
<cfparam name="xxS" default="username">
<cfparam name="xxT" default="">
<cfparam name="xxL" default="">
<cfparam name="xxA" default="">
<cfparam name="xOnPage" default="1">

<!--- param a/e form fields --->
<cfparam name="username" default="">
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="nickname" default="">
<cfparam name="email" default="">
<cfparam name="phone" default="">
<cfparam name="is_active" default="">
<cfparam name="is_done" default="">
<cfparam name="expiration_date" default="">
<cfparam name="cc_max" default="">
<cfparam name="defer_allowed" default="">
<cfparam name="ship_address1" default="">
<cfparam name="ship_address2" default="">
<cfparam name="ship_city" default="">
<cfparam name="ship_state" default="">
<cfparam name="ship_zip" default="">
<cfparam name="bill_fname" default="">
<cfparam name="bill_lname" default="">
<cfparam name="bill_address1" default="">
<cfparam name="bill_address2" default="">
<cfparam name="bill_city" default="">
<cfparam name="bill_state" default="">
<cfparam name="bill_zip" default="">
<cfparam name="supervisor_email" default="">
<cfparam name="level_of_award" default="">
<cfparam name="idh" default="">
<cfparam name="registration_type" default="">
<cfparam name="forwarding_ID" default="">

<cfparam name="show_zip" default="all">

<cfif NOT isNumeric(program_ID) OR program_ID LTE 0>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit') AND IsDefined('form.username') AND form.username IS NOT "">
	<!--- check to see if this username is already in use for this program --->
	<cfquery name="AnyDuplicateUsernames" datasource="#application.DS#">
		SELECT ID
		FROM #application.database#.program_user
		WHERE username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#">
		AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#">
		<cfif form.puser_ID IS NOT "">
			AND ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#form.puser_ID#">
		</cfif>
	</cfquery>
	<cfif AnyDuplicateUsernames.RecordCount EQ 0>
		<cfif cc_max EQ ''><cfset cc_max = 0></cfif>
		<cfif defer_allowed EQ ''><cfset defer_allowed = 0></cfif>
		<!--- upload certificate --->
		<cfif IsDefined('form.certificate_upload') AND TRIM(form.certificate_upload) IS NOT "">
			<cfset result = FLGen_UploadThis("certificate_upload","award_certificate/",username & "_certificate_" & program_ID)>
		</cfif>
		<!--- update --->
		<cfif form.puser_ID IS NOT "">
			<cfset thisType = "">
			<cfif isDefined("form.registration_type")>
				<cfset thisType = form.registration_type>
			</cfif>
			<cfquery name="UpdateQuery" datasource="#application.DS#">
				UPDATE #application.database#.program_user
				SET username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="128">,
					fname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.fname)))#">,
					lname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.lname)))#">,
					nickname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.nickname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.nickname)))#">,
					email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128" null="#YesNoFormat(NOT Len(Trim(form.email)))#">,
					phone = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.phone#" maxlength="35" null="#YesNoFormat(NOT Len(Trim(form.phone)))#">,
					ship_address1 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_address1#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.ship_address1)))#">,
					ship_address2 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_address2#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.ship_address2)))#">,
					ship_city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.ship_city)))#">,
					ship_state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ship_state#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(form.ship_state)))#">,
					ship_zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_zip#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(form.ship_zip)))#">,
					bill_fname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.bill_fname)))#">,
					bill_lname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.bill_lname)))#">,
					bill_address1 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_address1#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.bill_address1)))#">,
					bill_address2 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_address2#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.bill_address2)))#">,
					bill_city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.bill_city)))#">,
					bill_state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.bill_state#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(form.bill_state)))#">,
					bill_zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_zip#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(form.bill_zip)))#">,
					is_active = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.is_active#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(form.is_active)))#">,
					is_done = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.is_done#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(form.is_done)))#">,
					expiration_date = <cfqueryparam cfsqltype="cf_sql_date" value="#form.expiration_date#" null="#YesNoFormat(NOT Len(Trim(form.expiration_date)))#">,
					cc_max = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#cc_max#">,
					defer_allowed = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#defer_allowed#">
					<cfif IsDefined('form.entered_by_program_admin') AND form.entered_by_program_admin NEQ "">, entered_by_program_admin = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#entered_by_program_admin#"></cfif>,
					supervisor_email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.supervisor_email#" null="#YesNoFormat(NOT Len(Trim(form.supervisor_email)))#">,
					idh = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.idh#" maxlength="16">,
					registration_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thisType#" maxlength="16" null="#YesNoFormat(NOT Len(Trim(thisType)))#">,					
					forwarding_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.forwarding_ID#" null="#YesNoFormat(NOT Len(Trim(form.forwarding_ID)))#">,
					level_of_award = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.level_of_award#" null="#YesNoFormat(NOT Len(Trim(form.level_of_award)))#">
					#FLGen_UpdateModConcatSQL()#
					WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.puser_ID#">
			</cfquery>
		<!--- add --->
		<cfelse>
			<cflock name="program_userLock" timeout="10">
				<cftransaction>
					<cfquery name="InsertQuery" datasource="#application.DS#">
						INSERT INTO #application.database#.program_user
							(created_user_ID, created_datetime, username, fname, lname, nickname, email, phone, is_active, is_done, expiration_date, cc_max, defer_allowed, ship_address1, ship_address2, ship_city, ship_state,  ship_zip, bill_fname, bill_lname, bill_address1, bill_address2, bill_city, bill_state,  bill_zip, program_ID, supervisor_email, forwarding_ID, level_of_award)
						VALUES (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#', 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="128">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.fname)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.lname)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.nickname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.nickname)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128" null="#YesNoFormat(NOT Len(Trim(form.email)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.phone#" maxlength="35" null="#YesNoFormat(NOT Len(Trim(form.phone)))#">, 
							<cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.is_active#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(form.is_active)))#">, 
							<cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.is_done#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(form.is_done)))#">, 
							<cfqueryparam cfsqltype="cf_sql_date" value="#form.expiration_date#" null="#YesNoFormat(NOT Len(Trim(form.expiration_date)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#cc_max#">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#defer_allowed#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_address1#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.ship_address1)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_address2#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.ship_address2)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.ship_city)))#">, 
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ship_state#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(form.ship_state)))#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.ship_zip#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(form.ship_zip)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.bill_fname)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.bill_lname)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_address1#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.bill_address1)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_address2#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(form.bill_address2)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.bill_city)))#">, 
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.bill_state#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(form.bill_state)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.bill_zip#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(form.bill_zip)))#">, 
							<cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.supervisor_email#" null="#YesNoFormat(NOT Len(Trim(form.supervisor_email)))#">,
							<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.forwarding_ID#" null="#YesNoFormat(NOT Len(Trim(form.forwarding_ID)))#">,
							<cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.level_of_award#" null="#YesNoFormat(NOT Len(Trim(form.level_of_award)))#">
						)
					</cfquery>
					<cfquery name="getID" datasource="#application.DS#">
						SELECT Max(ID) As MaxID FROM #application.database#.program_user
					</cfquery>
					<cfset puser_ID = getID.MaxID>
				</cftransaction>
			</cflock>
			<cfif form.submit EQ "Save and go to Add Points page">
				<cflocation addtoken="no" url="program_points.cfm?program_ID=#program_ID#&puser_ID=#puser_ID#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&xOnPage=#xOnPage#">
			</cfif>
		</cfif>
		<!--- save the category information --->
		<cfif has_categories>
			<cfif pgfn EQ 'edit'>
				<cfquery name="DeleteCatXref" datasource="#application.DS#">
					DELETE FROM #application.database#.xref_user_category
					WHERE user_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#puser_ID#">
				</cfquery>
			</cfif>
			<!--- insert all the xref category data for this user --->
			<cfif IsDefined('form.FieldNames') AND Trim(#form.FieldNames#) IS NOT "">
				<cfloop list="#form.FieldNames#" index="FormField">
					<cfif FormField CONTAINS 'category_'>
						<cfset current_category_ID = ReplaceNoCase(FormField,'category_','')>
						<cfset current_category_data = Form[FormField]>
						<cfquery name="InsertUserCat" datasource="#application.DS#">
							INSERT INTO #application.database#.xref_user_category
							(created_user_ID, created_datetime, user_ID, category_ID, category_data)
							VALUES
							(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#',
								<cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#current_category_ID#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#current_category_data#" maxlength="40">
								)
						</cfquery>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<cfset datasaved = "yes">
		<cfset pgfn = "list">
	<cfelse>
		<cfset duplicateusername = true>
		<cfset pgfn = form.pgfn>
	</cfif>
<cfelseif IsDefined('form.Submit') AND pgfn EQ 'ccmax'>
	<cfquery name="SetCCMax" datasource="#application.DS#">
		UPDATE #application.database#.program_user
		SET cc_max = <cfqueryparam cfsqltype="cf_sql_integer" value="#cc_max#" maxlength="6">
			#FLGen_UpdateModConcatSQL()#
			WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
	</cfquery>
	<cfset pgfn = "list">
<cfelseif IsDefined('form.Submit') AND pgfn EQ 'allowdefer'>
	<cfquery name="SetCCMax" datasource="#application.DS#">
		UPDATE #application.database#.program_user
		SET defer_allowed = <cfqueryparam cfsqltype="cf_sql_integer" value="#defer_allowed#" maxlength="6">
			#FLGen_UpdateModConcatSQL()#
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
	</cfquery>
	<cfset pgfn = "list">
<cfelseif delete NEQ '' AND FLGen_HasAdminAccess(1000000052)>
	<cfquery name="DeleteHenkelRegister" datasource="#application.DS#">
		DELETE 
		FROM #application.database#.henkel_register
		WHERE program_user_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#">
	</cfquery>
	<cfquery name="DeleteHenkelRegister" datasource="#application.DS#">
		DELETE 
		FROM #application.database#.henkel_register_branch
		WHERE program_user_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#">
	</cfquery>
	<cfquery name="DeleteUserPoints" datasource="#application.DS#">
		DELETE 
		FROM #application.database#.awards_points
		WHERE user_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#">
	</cfquery>
	<cfquery name="DeleteUserp" datasource="#application.DS#">
		DELETE 
		FROM #application.database#.program_user
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#">
	</cfquery>
</cfif>

<cfif pgfn IS 'send_the_email'>
	<cfquery name="FLITCAwards_SelectRecipients" datasource="#application.DS#">
		SELECT ID AS this_user_ID, fname, lname, email, Date_Format(expiration_date,'%c/%d/%Y') AS expiration_date, 
			Format((((SELECT IFNULL(SUM(points),0) FROM #application.database#.awards_points WHERE user_ID = this_user_ID AND is_defered = 0) - (SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) FROM #application.database#.order_info WHERE created_user_ID = this_user_ID AND is_valid = 1)) * (SELECT points_multiplier FROM #application.database#.program WHERE program.ID = program_user.program_ID)),0) AS remaining_points,
			supervisor_email, level_of_award, username
			<!---,CONCAT(IFNULL(fname,'(no first name)'),' ',IFNULL(lname,'(no last name)'),', <b>',email,IF(TRIM(supervisor_email) <> '',' has a supervisor',''),'</b>') AS ListText--->
		FROM #application.database#.program_user
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		AND ID = <cfqueryparam value="#form.puser_ID#" cfsqltype="CF_SQL_INTEGER">
		AND email <> ''
		AND email IS NOT NULL
		AND is_active = 1
		ORDER BY lname, fname ASC 
	</cfquery>
	<!--- find template --->
	<cfquery name="ALERTFindTemplateText" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#email_template_ID#">
	</cfquery>
	<cfset email_text = ALERTFindTemplateText.email_text>
	<!--- find program info --->
	<cfquery name="ALERTGetProgramInfo" datasource="#application.DS#">
		SELECT company_name, Date_Format(expiration_date,'%c/%d/%Y') AS expiration_date, points_multiplier 
		FROM #application.database#.program
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
	</cfquery>
	<cfif Find("FILL-IN-THE-BLANK",email_text) GT 0>
		<cfset email_text = Replace(email_text,"FILL-IN-THE-BLANK",#fillin#)>
	</cfif>
	<cfset email_text = Replace(email_text,"PROGRAM-NAME-HERE","#ALERTGetProgramInfo.company_name#","all")>
	<cfset email_text = Replace(email_text,"PROGRAM-EXPIRATION-DATE","#ALERTGetProgramInfo.expiration_date#","all")>
	<cfset email_text = Replace(email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
	<cfset email_text = Replace(email_text,"USER-FIRST-NAME",FLITCAwards_SelectRecipients.fname,"all")>
	<cfset email_text = Replace(email_text,"USER-LAST-NAME",FLITCAwards_SelectRecipients.lname,"all")>
	<cfset email_text = Replace(email_text,"USER-EXPIRATION-DATE",FLITCAwards_SelectRecipients.expiration_date,"all")>
	<cfset email_text = Replace(email_text,"USER-REMAINING-POINTS",FLITCAwards_SelectRecipients.remaining_points,"all")>
	<cfset email_text = Replace(email_text,"LEVEL-OF-AWARD",FLITCAwards_SelectRecipients.level_of_award,"all")>
	<cfset email_text = Replace(email_text,"USER-NAME",FLITCAwards_SelectRecipients.username,"all")>
	<!--- Send Email Alert --->
	<cfmail to="#FLITCAwards_SelectRecipients.email#" from="#email_from#" subject="#email_subject#" type="html">
#email_text#
	</cfmail>
	<cfset pgfn="list">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "program_user">
<cfinclude template="includes/header.cfm">

<cfparam  name="pgfn" default="list">

<!--- START pgfn LIST --->
<cfif pgfn EQ "list">

<cfif LEN(xxT) GT 0>
	<cfset xxL = "">
</cfif>

<!--- run query --->
<cfif xxS EQ "username" OR xxS EQ "lname" OR xxS EQ "email" OR xxS EQ "is_active" OR xxS EQ "idh">
	<!--- TODO: Put the zipcode database in application.cfm --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT created_datetime, ID AS puser_ID, username, IFNULL(fname,"-") AS fname, IFNULL(lname,"-") AS lname, IFNULL(email,"-") AS email, If(is_active = 1,"active","inactive") AS is_active, cc_max, defer_allowed, IF(is_done=1,"ordered","not ordered") AS is_done, idh
		FROM #application.database#.program_user
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		<cfif LEN(xxT) GT 0>
				<cfloop list="#xxT#" index="this_term" delimiters=" ">
			AND (
					ID LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR username LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR fname LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR idh LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR lname LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR email LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%">
			)
				</cfloop>
		<cfelseif LEN(xxL) GT 0>
			AND #xxS# LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#xxL#%">
		</cfif>
		<cfif xxA NEQ 'all'>
			AND is_active = '1'
		</cfif>
		<cfif show_zip NEQ "all">
			<cfswitch expression="#show_zip#">
				<cfcase value="canada">
					AND ship_zip IN (SELECT PostalCode FROM ZipCodes.zipcode_canada)
				</cfcase>
				<cfcase value="us">
					AND ship_zip IN (SELECT ZIPCode FROM ZipCodes.zipcode_us)
				</cfcase>
				<cfcase value="blank">
					AND (ship_zip IS NULL OR TRIM(ship_zip) = '')
				</cfcase>
				<cfcase value="other">
					AND ship_zip NOT IN (SELECT PostalCode FROM ZipCodes.zipcode_canada)
					AND ship_zip NOT IN (SELECT ZIPCode FROM ZipCodes.zipcode_us)
				</cfcase>
			</cfswitch>
		</cfif>
		ORDER BY #xxS# ASC
	</cfquery>
</cfif>


<cfquery name="SelectProgramInfo" datasource="#application.DS#">
	SELECT ID AS program_ID, company_name, program_name, IF(is_one_item=1,"true","false") AS is_one_item, accepts_cc, IF(can_defer=1,"true","false") AS can_defer 
	FROM #application.database#.program
	WHERE ID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
</cfquery>
<cfset is_one_item = SelectProgramInfo.is_one_item>
<cfset accepts_cc = SelectProgramInfo.accepts_cc>
<cfset can_defer = SelectProgramInfo.can_defer>

<cfparam name="column_count" default="6">
<cfif is_one_item>
	<cfset column_count = 5>
<cfelseif can_defer AND accepts_cc EQ 1>
	<cfset column_count = 9>
<cfelseif can_defer AND accepts_cc NEQ 1>
	<cfset column_count = 8>
<cfelseif NOT can_defer AND accepts_cc EQ 1>
	<cfset column_count = 7>
</cfif>

<!--- set the start/end/max display row numbers --->
<cfset MaxRows_SelectList="50">
<cfset StartRow_SelectList=Min((xOnPage-1)*MaxRows_SelectList+1,Max(SelectList.RecordCount,1))>
<cfset EndRow_SelectList=Min(StartRow_SelectList+MaxRows_SelectList-1,SelectList.RecordCount)>
<cfset TotalPages_SelectList=Ceiling(SelectList.RecordCount/MaxRows_SelectList)>

<span class="pagetitle">Program User List</span>
<br /><br />
<cfif FLGen_HasAdminAccess(1000000014,false)>
	<span class="pageinstructions">Return to <a href="program.cfm">Award Program List</a> without making changes.</span>
	<br /><br />
</cfif>
<cfif FLGen_HasAdminAccess(1000000020,false)>
	<span class="pageinstructions">Choose a different <a href="pickprogram.cfm?n=program_user">Award Program</a>.</span>
	<br /><br />
</cfif>
<cfoutput>
<span class="pageinstructions">
	<cfif xxA EQ 'all'>
		<b>All Program Users Are Displayed</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="program_user.cfm?xOnPage=#xOnPage#&xxS=#xxS#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#">Display Active Program Users Only</a>
	<cfelse>
		<b>Only Active Program Users Are Displayed</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="program_user.cfm?xxA=all&xOnPage=#xOnPage#&xxS=#xxS#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#">Display All Program Users</a>
	</cfif>
	<br><br>
</span>
</cfoutput>
<!--- search box --->
<cfoutput>
<form name="search_form" action="#CurrentPage#" method="post">
	<input type="hidden" name="xxL" value="#xxL#">
	<input type="hidden" name="xxS" value="#xxS#">
	<input type="hidden" name="xxA" value="#xxA#">
	<input type="hidden" name="program_ID" value="#program_ID#">
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
		<tr class="contenthead">
			<td><span class="headertext">Search Criteria</span></td>
			<td align="right"><a href="#CurrentPage#?program_ID=#program_ID#" class="headertext">view all</a></td>
		</tr>
		<tr>
			<td class="content">
				<input type="text" name="xxT" value="#xxT#" size="40">
				<input type="submit" name="do_search" value="search">
			</td>
			<td class="content">
				Show:
												<input type="radio" name="show_zip" value="all" <cfif show_zip EQ "all">checked</cfif> onClick="form.submit();"> All zip codes<br>
					#RepeatString('&nbsp;',10)#<input type="radio" name="show_zip" value="us" <cfif show_zip EQ "us">checked</cfif> onClick="form.submit();"> only U.S.<br>
					#RepeatString('&nbsp;',10)#<input type="radio" name="show_zip" value="canada" <cfif show_zip EQ "canada">checked</cfif> onClick="form.submit();"> only Canada<br>
					#RepeatString('&nbsp;',10)#<input type="radio" name="show_zip" value="blank" <cfif show_zip EQ "blank">checked</cfif> onClick="form.submit();"> only blanks<br>
					#RepeatString('&nbsp;',10)#<input type="radio" name="show_zip" value="other" <cfif show_zip EQ "other">checked</cfif> onClick="form.submit();"> only unknown<br>
			</td>
		</tr>
		<tr>
			<td class="content" colspan="2" align="center">
				<cfif LEN(xxL) IS 0><span class="ltrON">ALL</span><cfelse><a href="#CurrentPage#?xxL=&xxS=#xxS#&xxA=#xxA#&program_ID=#program_ID#&show_zip=#show_zip#" class="ltr">ALL</a></cfif><span class="ltrPIPE">&nbsp;&nbsp;</span><cfloop index = "LoopCount" from = "0" to = "9"><cfif xxL IS LoopCount><span class="ltrON">#LoopCount#</span><cfelse><a href="#CurrentPage#?xxL=#LoopCount#&xxA=#xxA#&xxS=#xxS#&program_ID=#program_ID#&show_zip=#show_zip#" class="ltr">#LoopCount#</a></cfif><span class="ltrPIPE">&nbsp;&nbsp;</span></cfloop><cfloop index = "LoopCount" from = "1" to = "26"><cfif xxL IS CHR(LoopCount + 64)><span class="ltrON">#CHR(LoopCount + 64)#</span><cfelse><a href="#CurrentPage#?xxL=#CHR(LoopCount + 64)#&xxS=#xxS#&xxA=#xxA#&program_ID=#program_ID#&show_zip=#show_zip#" class="ltr">#CHR(LoopCount + 64)#</a></cfif><cfif LoopCount NEQ 26><span class="ltrPIPE">&nbsp;&nbsp;</span></cfif></cfloop>
			</td>
		</tr>
	</table>
</form>
</cfoutput>
<br />
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
	<td>
		<cfif xOnPage GT 1>
			<a href="<cfoutput>#CurrentPage#?xOnPage=1&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#</cfoutput>" class="pagingcontrols">&laquo;</a>&nbsp;&nbsp;&nbsp;<a href="<cfoutput>#CurrentPage#?xOnPage=#Max(DecrementValue(xOnPage),1)#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#</cfoutput>" class="pagingcontrols">&lsaquo;</a>
		<cfelse>
			<span class="Xpagingcontrols">&laquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&lsaquo;</span>
		</cfif>
	</td>
	<td align="center" class="sub"><cfoutput>[ page displayed: #xOnPage# of #TotalPages_SelectList# ]&nbsp;&nbsp;&nbsp;[ records displayed: #StartRow_SelectList# - #EndRow_SelectList# ]&nbsp;&nbsp;&nbsp;[ total records: #SelectList.RecordCount# ]</cfoutput></td>
	<td align="right">
		<cfif xOnPage LT TotalPages_SelectList>
			<a href="<cfoutput>#CurrentPage#?xOnPage=#Min(IncrementValue(xOnPage),TotalPages_SelectList)#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#</cfoutput>" class="pagingcontrols">&rsaquo;</a>&nbsp;&nbsp;&nbsp;<a href="<cfoutput>#CurrentPage#?xOnPage=#TotalPages_SelectList#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#</cfoutput>" class="pagingcontrols">&raquo;</a>
		<cfelse>
			<span class="Xpagingcontrols">&rsaquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&raquo;</span>
		</cfif>
	</td>
	</tr>
</table>

<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<!--- header row --->
	<cfoutput>
	<tr class="content2">
	<td colspan="#column_count#"><span class="headertext">Program: <span class="selecteditem">#HTMLEditFormat(SelectProgramInfo.company_name)# [#HTMLEditFormat(SelectProgramInfo.program_name)#]</span></span></td>
	</tr>
	<tr class="contenthead">
	<td align="center" rowspan="2"><a href="#CurrentPage#?pgfn=add&program_ID=#program_ID#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&xOnPage=#xOnPage#&show_zip=#show_zip#">Add</a></td>
	<td rowspan="2" colspan="3">
		<cfif xxS IS "username">
			<span class="headertext">Username</span> <img src="../pics/contrls-asc.gif" width="7" height="6">
		<cfelse>
			<a href="#CurrentPage#?xxS=username&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#" class="headertext">Username</a>
		</cfif>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif xxS IS "lname">
			<span class="headertext">Name</span> <img src="../pics/contrls-asc.gif" width="7" height="6">
		<cfelse>
			<a href="#CurrentPage#?xxS=lname&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#" class="headertext">Name</a>
		</cfif>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif xxS IS "email">
			<span class="headertext">Email</span> <img src="../pics/contrls-asc.gif" width="7" height="6">
		<cfelse>
			<a href="#CurrentPage#?xxS=email&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#" class="headertext">Email</a>
		</cfif>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif xxS IS "idh">
			<span class="headertext">IDH</span> <img src="../pics/contrls-asc.gif" width="7" height="6">
		<cfelse>
			<a href="#CurrentPage#?xxS=idh&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#" class="headertext">IDH</a>
		</cfif>
	</td>
	<cfif NOT is_one_item>
	<td colspan="2" align="center"><span class="headertext">Points</span></td>
	</cfif>
	<cfif can_defer>
	<td colspan="2" align="center"><span class="headertext">Deferred</span></td>
	</cfif>
	<cfif accepts_cc EQ 1>
	<td rowspan="2" align="center"><span class="headertext">Max CC</span><br>
	<a href="#CurrentPage#?pgfn=ccmax&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#">set for all users</a></td>
	</cfif>
	<cfif is_one_item>
	<td align="center"><span class="headertext">Ordered?</span></td>
	</cfif>
	</tr>
	<tr class="contenthead">
	<cfif NOT is_one_item>
	<td colspan="2" align="center"><a href="program_points.cfm?xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#">+/-&nbsp;for&nbsp;all&nbsp;users</a></td>
	</cfif>
	<cfif can_defer>
	<td>current</td>
	<td><a href="#CurrentPage#?pgfn=allowdefer&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#">allowed</a></td>
	</cfif>
	<cfif is_one_item>
	<td align="center"><span class="sub">(one-item store)</span></td>
	</cfif>
	</tr>
	</cfoutput>
	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
		<td colspan="<cfoutput>#column_count#</cfoutput>" align="center"><span class="alert"><br>No records found.  Click "view all" to see all records.<br><br></span></td>
		</tr>
	<cfelse>
		<!--- display found records --->
		<cfoutput query="SelectList" startrow="#StartRow_SelectList#" maxrows="#MaxRows_SelectList#">
			<cfset show_delete = false>
			<cfif FLGen_HasAdminAccess(1000000052)>
				<cfquery name="FindLink1" datasource="#application.DS#">
					SELECT COUNT(ID) as thismany
					FROM #application.database#.order_info
					WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#" maxlength="10"> 
						AND is_valid = 1
				</cfquery>
				<cfif FindLink1.thismany EQ 0>
					<!--- <cfquery name="FindLink2" datasource="#application.DS#">
						SELECT COUNT(ID) as thismany
						FROM #application.database#.inventory
						WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#" maxlength="10"> 
							AND is_valid = 1
					</cfquery>
					<cfif FindLink2.thismany EQ 0> --->
						<cfquery name="FindLink3" datasource="#application.DS#">
							SELECT COUNT(ID) as thismany
							FROM #application.database#.survey
							WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#" maxlength="10"> 
						</cfquery>
						<cfif FindLink3.thismany EQ 0>
							<cfset show_delete = true>
		<!--- Deleted per Lou on 6/19/2008 so he can delete Henkel Program Users
							<cfquery name="FindLink4" datasource="#application.DS#">
								SELECT COUNT(ID) as thismany
								FROM #application.database#.awards_points
								WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#" maxlength="10"> 
							</cfquery>
							<cfif FindLink4.thismany EQ 0>
								<cfset show_delete = true>
							</cfif>
		--->
						</cfif>
					<!--- </cfif> --->
				</cfif>
			</cfif>
			<tr class="#Iif(is_active EQ "active",de(Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))), de('inactivebg'))#">
				<td><a href="#CurrentPage#?pgfn=edit&program_ID=#program_ID#&puser_id=#puser_ID#&xxA=#xxA#&xxS=#xxS#&xxL=#xxL#&xxT=#xxT#&xOnPage=#xOnPage#&show_zip=#show_zip#">Edit</a><cfif FLGen_HasAdminAccess(1000000052) and show_delete>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?delete=#puser_ID#&program_ID=#program_ID#&xxA=#xxA#&xxS=#xxS#&xxL=#xxL#&xxT=#xxT#&xOnPage=#xOnPage#&show_zip=#show_zip#" onclick="return confirm('Are you sure you want to delete this program user?  There is NO UNDO.')">Delete</a></cfif></td>
				<td colspan="3">
					#HTMLEditFormat(username)#<br>
					#HTMLEditFormat(fname)#&nbsp;#HTMLEditFormat(lname)#<br>
					#HTMLEditFormat(email)# <cfif email GT ''>(<a href="#CurrentPage#?pgfn=email&program_ID=#program_ID#&puser_id=#puser_ID#&xxA=#xxA#&xxS=#xxS#&xxL=#xxL#&xxT=#xxT#&xOnPage=#xOnPage#&show_zip=#show_zip#">Send Notification</a>)</cfif><br>
					IDH: #idh#<br>
					Registered: #dateFormat(created_datetime,"m/dd/yyyy")# - #timeFormat(created_datetime,"h:mm tt")#
				</td>
				<cfif NOT is_one_item>
					<!--- CALCULATE USER'S POINTS --->
					#ProgramUserInfo(SelectList.puser_ID)#
					<td valign="middle" align="right">#user_totalpoints#</td>
					<td align="center"><a href="program_points.cfm?puser_ID=#SelectList.puser_ID#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&program_ID=#program_ID#&show_zip=#show_zip#">+/-</a></td>
				</cfif>
				<cfif can_defer>
				<td align="right"><span class="sub">[#user_deferedpoints#]</span></td>
				<td align="right"><span class="sub">[#defer_allowed#]</span></td>
				</cfif>
				<cfif accepts_cc EQ 1>
				<td align="right"><span class="sub">$#cc_max#</span></td>
				</cfif>
				<cfif is_one_item>
				<td align="right"><span class="sub">#is_done#</span></td>
				</cfif>
			</tr>
		</cfoutput>
	</cfif>
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit">
	<!--- START pgfn ADD/EDIT --->
	<cfquery name="SelectProgramInfo" datasource="#application.DS#">
		SELECT ID AS program_ID, company_name, IF(is_one_item=1,"true","false") AS is_one_item, accepts_cc, IF(can_defer=1,"true","false") AS can_defer 
		FROM #application.database#.program
		WHERE ID=<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
	</cfquery>
	<cfset is_one_item = SelectProgramInfo.is_one_item>
	<cfset accepts_cc = SelectProgramInfo.accepts_cc>
	<cfset can_defer = SelectProgramInfo.can_defer>
	<cfoutput>
	<span class="pagetitle"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Program User</span>
	<br /><br />
	<span class="pageinstructions">Username is the only required field.</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="program_user.cfm?program_ID=#program_ID#&xOnPage=#xOnPage#&xxA=#xxA#&xxS=#xxS#&xxL=#xxL#&xxT=#xxT#&show_zip=#show_zip#">Program User List</a><cfif FLGen_HasAdminAccess(1000000014)>  or  <a href="program.cfm">Award Program List</a></cfif> without making changes.</span>
	<br /><br />
	<cfif duplicateusername>
		<span class="alert">No duplicate usernames are allowed in a program.  Please enter a new username.</span>
		<br /><br />
	</cfif>
	<cfif datasaved eq 'yes'>
		<span class="alert">The information was saved.</span>#FLGen_SubStamp()#
		<br /><br />
	</cfif>
	</cfoutput>
	<cfset henkel_rep = "">
	<cfif pgfn EQ "edit">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT
				u.username, u.fname, u.lname, u.nickname, u.email, u.phone, u.is_active, u.is_done, u.expiration_date,
				u.cc_max, u.defer_allowed, u.ship_address1, u.ship_address2, u.ship_city, u.ship_state, u. ship_zip,
				u.bill_fname, u.bill_lname, u.bill_address1, u.bill_address2, u.bill_city, u.bill_state, u. bill_zip,
				u.entered_by_program_admin, u.supervisor_email, u.level_of_award, u.idh, u.registration_type,
				IFNULL(f.ID,0) AS forwarding_ID,
				f.company,
				f.address1,
				f.address2,
				f.city,
				f.state,
				f.zip,
				f.country
			FROM #application.database#.program_user u
			LEFT JOIN #application.database#.forwarding_address f ON f.ID = u.forwarding_ID AND f.program_ID = u.program_ID
			WHERE u.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#">
		</cfquery>
		<cfset username = htmleditformat(ToBeEdited.username)>	
		<cfset fname = htmleditformat(ToBeEdited.fname)>
		<cfset lname = htmleditformat(ToBeEdited.lname)>
		<cfset nickname = htmleditformat(ToBeEdited.nickname)>
		<cfset email = htmleditformat(ToBeEdited.email)>
		<cfset phone = htmleditformat(ToBeEdited.phone)>
		<cfset is_active = htmleditformat(ToBeEdited.is_active)>
		<cfset is_done = htmleditformat(ToBeEdited.is_done)>
		<cfset expiration_date = htmleditformat(ToBeEdited.expiration_date)>
		<cfset cc_max = htmleditformat(ToBeEdited.cc_max)>
		<cfset defer_allowed = htmleditformat(ToBeEdited.defer_allowed)>
		<cfset ship_address1 = htmleditformat(ToBeEdited.ship_address1)>
		<cfset ship_address2 = htmleditformat(ToBeEdited.ship_address2)>
		<cfset ship_city = htmleditformat(ToBeEdited.ship_city)>
		<cfset ship_state = htmleditformat(ToBeEdited.ship_state)>
		<cfset ship_zip = htmleditformat(ToBeEdited.ship_zip)>
		<cfset bill_fname = htmleditformat(ToBeEdited.bill_fname)>
		<cfset bill_lname = htmleditformat(ToBeEdited.bill_lname)>
		<cfset bill_address1 = htmleditformat(ToBeEdited.bill_address1)>
		<cfset bill_address2 = htmleditformat(ToBeEdited.bill_address2)>
		<cfset bill_city = htmleditformat(ToBeEdited.bill_city)>
		<cfset bill_state = htmleditformat(ToBeEdited.bill_state)>
		<cfset bill_zip = htmleditformat(ToBeEdited.bill_zip)>
		<cfset entered_by_program_admin = htmleditformat(ToBeEdited.entered_by_program_admin)>
		<cfset supervisor_email = htmleditformat(ToBeEdited.supervisor_email)>
		<cfset level_of_award = htmleditformat(ToBeEdited.level_of_award)>
		<cfset idh = htmleditformat(ToBeEdited.idh)>
		<cfset registration_type = htmleditformat(ToBeEdited.registration_type)>
		<cfset forwarding_ID = ToBeEdited.forwarding_ID>
		<!--- do a search for categories assigned to this user --->
		<cfquery name="FindUsersCategories" datasource="#application.DS#">
			SELECT category_ID, category_data 
			FROM #application.database#.xref_user_category
			WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#" maxlength="10">
		</cfquery>
		<cfset find_users_categories = FindUsersCategories.RecordCount>
		<cfif idh NEQ "">
			<cfquery name="getDistributor" datasource="#application.DS#">
				SELECT zip
				FROM #application.database#.henkel_distributor
				WHERE idh = <cfqueryparam cfsqltype="cf_sql_varchar" value="#idh#">
			</cfquery>
			<cfif getDistributor.recordcount GT 0>
				<cfquery name="getRegion" datasource="#application.DS#">
					SELECT region
					FROM #application.database#.xref_zipcode_region
					WHERE zipcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getDistributor.zip#">
				</cfquery>
				<cfif getRegion.recordcount GT 0>
					<cfquery name="getTerritory" datasource="#application.DS#">
						SELECT fname, lname, email
						FROM #application.database#.henkel_territory
						WHERE sap_ty = <cfqueryparam cfsqltype="cf_sql_varchar" value="00#getRegion.region#">
					</cfquery>
					<cfif getTerritory.recordcount GT 0>
						<cfset henkel_rep = "#getTerritory.fname# #getTerritory.lname# - #getTerritory.email#">
					<cfelse>
						<cfset henkel_rep = "Territory not found for region: 00#getRegion.region#">
					</cfif>
				<cfelse>
					<cfset henkel_rep = "Region not found for zip code: #getDistributor.zip#">
				</cfif>
			<cfelse>
				<cfset henkel_rep = "Distributor not found for this IDH.">
			</cfif>
		</cfif>
	</cfif>
	<cfoutput>
	<form method="post" action="#CurrentPage#" enctype="multipart/form-data">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="content2">
	<td  colspan="2"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
	</tr>
	<tr class="contenthead">
	<td colspan="2" class="headertext"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Program User</td>
	</tr>
	<cfif entered_by_program_admin EQ 1 AND pgfn EQ "edit">
		<tr class="content">
		<td align="right">Keep on<br>Users To Verify Report: </td>
		<td>
			<select name="entered_by_program_admin">
				<option value="1"<cfif entered_by_program_admin EQ 1> selected</cfif>>yes</option>
				<option value="0"<cfif entered_by_program_admin EQ 0> selected</cfif>>no</option>
			</select>
		</td>
		</tr>
	</cfif>
	<tr class="content">
	<td align="right">Username: </td>
	<td><input type="text" name="username" value="#username#" maxlength="128" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">First Name: </td>
	<td><input type="text" name="fname" value="#fname#" maxlength="30" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Last Name: </td>
	<td><input type="text" name="lname" value="#lname#" maxlength="30" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Nickname: </td>
	<td><input type="text" name="nickname" value="#nickname#" maxlength="30" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Email: </td>
	<td><input type="text" name="email" value="#email#" maxlength="128" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Phone: </td>
	<td><input type="text" name="phone" value="#phone#" maxlength="35" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">IDH Number: </td>
	<td><input type="text" name="idh" value="#idh#" maxlength="16" size="20"></td>
	</tr>
	<cfif henkel_rep NEQ "">
		<tr class="content">
		<td align="right">Henkel Regional Rep: </td>
		<td>#henkel_rep#</td>
		</tr>
	</cfif>
	<tr class="content">
		<td align="right">Registration Type:</td>
		<td>
		<input type="radio" name="registration_type" value="BranchHQ" <cfif registration_type EQ "BranchHQ">checked</cfif>> Branch HQ
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="registration_type" value="Branch" <cfif registration_type EQ "Branch">checked</cfif>> Branch
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="registration_type" value="Individual" <cfif registration_type EQ "Individual">checked</cfif>> Individual
		</td>
	</tr>
	<tr class="content">
	<td align="right">Must use award amount before: </td>
	<td><input type="text" name="expiration_date" value="<cfif expiration_date NEQ "">#FLGen_DateTimeToDisplay(expiration_date)#</cfif>" maxlength="12" size="15"> Please use date format, ex. 10/05/2005.</td>
	</tr>
	<cfif accepts_cc EQ 1>
		<tr class="content">
		<td align="right">Credit Card Maximum: </td>
		<td><input type="text" name="cc_max" value="#cc_max#" maxlength="6" size="8"></td>
		</tr>
	<cfelse>
		<input type="hidden" name="cc_max" value="0">
	</cfif>
	<cfif can_defer>
		<tr class="content">
		<td align="right">Allowed Deferal Amount: </td>
		<td><input type="text" name="defer_allowed" value="#defer_allowed#" maxlength="8" size="10"></td>
		</tr>
	<cfelse>
		<input type="hidden" name="defer_allowed" value="0">
	</cfif>
	<tr class="content">
	<td align="right">Active: </td>
	<td>
		<select name="is_active">
			<option value="1"<cfif is_active EQ 1> selected</cfif>>yes</option>
			<option value="0"<cfif is_active EQ 0> selected</cfif>>no</option>
		</select>
	</td>
	</tr>
	<cfif is_one_item>
		<tr class="content">
		<td align="right">Has ordered one item?: </td>
		<td>
			<select name="is_done">
				<option value="0"<cfif is_done EQ 0> selected</cfif>>no</option>
				<option value="1"<cfif is_done EQ 1> selected</cfif>>yes</option>
			</select>
		</td>
		</tr>
	<cfelse>
		<input type="hidden" name="is_done" value="0">
	</cfif>
	<!--- do a search for user categories --->
	<cfquery name="FindCategories" datasource="#application.DS#">
		SELECT ID as loop_category_ID, category_name 
		FROM #application.database#.program_user_category
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		ORDER BY sortorder
	</cfquery>
	<cfif FindCategories.RecordCount GT 0>
		<cfset has_categories = true>
		<tr class="content2">
		<td align="right">&nbsp;</td>
		<td><img src="../pics/contrls-desc.gif" width="7" height="6"> User Categories <span class="sub">(only used for creating email alert groups)</span></td>
		</tr>
		<cfloop query="FindCategories">
			<cfset category_value = "">
			<cfif find_users_categories GT 0>
				<cfquery name="IsUserAssignedThisCategory" dbtype="query">
					SELECT category_data 
					FROM FindUsersCategories
					WHERE category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#loop_category_ID#">
				</cfquery>
				<cfset category_value = htmleditformat(IsUserAssignedThisCategory.category_data)>
			</cfif>
			<tr class="content">
			<td align="right">#category_name#</td>
			<td><input type="text" name="category_#loop_category_ID#" value="#category_value#" maxlength="40" size="40"></td>
			</tr>
		</cfloop>
	</cfif>
	<cfquery name="FindForwarding" datasource="#application.DS#">
		SELECT
			ID,
			email,
			fname,
			lname,
			phone,
			company,
			address1,
			address2,
			city,
			state,
			zip,
			country,
			is_active
		FROM #application.database#.forwarding_address
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
		ORDER BY company
	</cfquery>
	<cfif FindForwarding.recordcount eq 0>
		<input type="hidden" name="forwarding_id" value="">
	<cfelse>
		<tr class="content2">
		<td align="right">&nbsp;</td>
		<td><img src="../pics/contrls-desc.gif" width="7" height="6"> Forwarder Address</td>
		</tr>
		<tr class="content">
		<td align="right">Select Address: </td>
		<td>
			<select name="forwarding_id">
				<option value=""> -- None --</option>
				<cfloop query="FindForwarding">
					<option value="#FindForwarding.ID#" <cfif FindForwarding.ID EQ forwarding_ID>selected</cfif>>#FindForwarding.company#, #FindForwarding.city#, #FindForwarding.state#</option>
				</cfloop>
			</select>
		</td>
		</tr>
		<cfif isNumeric(forwarding_ID) AND forwarding_ID NEQ 0>
			<tr class="content">
			<td align="right">Company: </td>
			<td>#ToBeEdited.company#</td>
			</tr>
			<tr class="content">
			<td align="right">Address Line 1: </td>
			<td>#ToBeEdited.address1#</td>
			</tr>
			<tr class="content">
			<td align="right">Address Line 2: </td>
			<td>#ToBeEdited.address2#</td>
			</tr>
			<tr class="content">
			<td align="right">City State Zip: </td>
			<td>#ToBeEdited.city#, #ToBeEdited.state# #ToBeEdited.zip#</td>
			</tr>
		</cfif>
	</cfif>
	<tr class="content2">
	<td align="right">&nbsp;</td>
	<td><img src="../pics/contrls-desc.gif" width="7" height="6"> Shipping Address</td>
	</tr>
	<tr class="content">
	<td align="right">Address Line 1: </td>
	<td><input type="text" name="ship_address1" value="#ship_address1#" maxlength="64" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Address Line 2: </td>
	<td><input type="text" name="ship_address2" value="#ship_address2#" maxlength="64" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">City State Zip: </td>
	<td>
		<input type="text" name="ship_city" value="#ship_city#" maxlength="30" size="20">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="text" name="ship_state" value="#ship_state#" maxlength="32" size="15">
		<!--- <cfoutput>#FLForm_SelectState("ship_state",ship_state,false,"",true,"",false)#</cfoutput> --->
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="text" name="ship_zip" value="#ship_zip#" maxlength="10" size="10">
	</td>
	</tr>
	<tr class="content2">
	<td align="right">&nbsp;</td>
	<td><img src="../pics/contrls-desc.gif" width="7" height="6"> Billing Address</td>
	</tr>
	<tr class="content">
	<td align="right">First Name: </td>
	<td><input type="text" name="bill_fname" value="#bill_fname#" maxlength="30" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Last Name: </td>
	<td><input type="text" name="bill_lname" value="#bill_lname#" maxlength="30" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Address Line 1: </td>
	<td><input type="text" name="bill_address1" value="#bill_address1#" maxlength="64" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">Address Line 2: </td>
	<td><input type="text" name="bill_address2" value="#bill_address2#" maxlength="64" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right">City State Zip: </td>
	<td>
		<input type="text" name="bill_city" value="#bill_city#" maxlength="30" size="20">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="text" name="bill_state" value="#bill_state#" maxlength="32" size="15">
		<!--- <cfoutput>#FLForm_SelectState("bill_state",bill_state,false,"",true,"",false)#</cfoutput> --->
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="text" name="bill_zip" value="#bill_zip#" maxlength="10" size="10">
	</td>
	</tr>
	<tr class="content2">
	<td align="right">&nbsp;</td>
	<td><img src="../pics/contrls-desc.gif" width="7" height="6"> For Email Alerts only</td>
	</tr>
	<tr class="content">
	<td align="right">Supervisor Email: </td>
	<td><input type="text" name="supervisor_email" value="#supervisor_email#" maxlength="128" size="40"><br><span class="sub">If a supervisor is entered, they will receive a copy of all Email Alerts sent to this program user.</span></td>
	</tr>
	<tr class="content">
	<td align="right">Level of Award: </td>
	<td><input type="text" name="level_of_award" value="#level_of_award#" maxlength="3" size="3"> <span class="sub">(only used as merge field in email alerts)</span>
	<input type="hidden" name="level_of_award_integer" value="You must enter a number for the Level of Award."></td>
	</tr>
	<tr class="content">
	<td align="right">PDF Certificate: </td>
	<td><input name="certificate_upload" type="file" size="40">
		<cfif FileExists(application.FilePath & "award_certificate/" & username & "_certificate_" & program_ID & ".pdf")><br>
			[ <a href="/award_certificate/#username#_certificate_#program_ID#.pdf?r=#CreateUUID()#" target="_blank">preview certificate</a> ]<br>
			<span class="sub">If you upload another certificate, it will over write this certificate.</span>
		</cfif>
	</td>
	</tr>
	<tr class="content">
	<td colspan="2" align="center">
	<input type="hidden" name="show_zip" value="#show_zip#">
	<input type="hidden" name="xxS" value="#xxS#">
	<input type="hidden" name="xxA" value="#xxA#">
	<input type="hidden" name="xxL" value="#xxL#">
	<input type="hidden" name="xxT" value="#xxT#">
	<input type="hidden" name="xOnPage" value="#xOnPage#">
	<input type="hidden" name="pgfn" value="#pgfn#">
	<input type="hidden" name="has_categories" value="#has_categories#">
	<input type="hidden" name="program_ID" value="#program_ID#">
	<input type="hidden" name="puser_ID" value="#puser_ID#">
	<input type="hidden" name="username_required" value="You must enter a username.">
	<input type="hidden" name="email_required" value="You must enter an email address.">
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" ><cfif pgfn EQ "add">&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save and go to Add Points page" ></cfif>
	</td>
	</tr>
	</table>
	</form>
	</cfoutput>
	<!--- END pgfn ADD/EDIT --->
<cfelseif pgfn EQ "email">
	<!--- START pgfn EMAIL--->
	<cfoutput>
	<span class="pagetitle">Email Notification</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="program_user.cfm?program_ID=#program_ID#&xOnPage=#xOnPage#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&show_zip=#show_zip#">Program User List</a><cfif FLGen_HasAdminAccess(1000000014)>  or  <a href="program.cfm">Award Program List</a></cfif> without making changes.</span>
	<br /><br />
	</cfoutput>
	<cfquery name="FindUser" datasource="#application.DS#">
		SELECT fname, lname, nickname, email
		FROM #application.database#.program_user
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#puser_ID#" maxlength="10">
	</cfquery>
	<cfquery name="FindTemplates" datasource="#application.DS#">
		SELECT ea.ID, ea.email_title 
		FROM #application.database#.email_templates ea
		JOIN #application.database#.xref_program_email xref ON ea.ID = xref.email_alert_ID
		WHERE ea.is_available = 1
			AND xref.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
		ORDER BY ea.email_title ASC
	</cfquery>
	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<table cellpadding="5" cellspacing="1" border="0">
			<tr class="content2"><td  colspan="2"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td></tr>
			<tr class="contenthead"><td class="headertext">Send EMail Notification</td></tr>
			<tr class="content">
				<td align="center">
					<table border="0">
						<tr><td>Template:</td><td><select name="email_template_ID"><cfloop query="FindTemplates"><option value="#ID#">#email_title#</option></cfloop></select></td></tr>
						<tr><td>To:</td><td>#FindUser.fname# #FindUser.lname# (#FindUser.email#)</td></tr>
						<tr><td>From:</td><td><input name="email_from" type="text" value="#email_from#" size="40" maxlength="64" /></td></tr>
						<tr><td>Subject:</td><td><input name="email_subject" type="text" value="#email_subject#" size="40" maxlength="64" /></td></tr>
						<tr><td>Fill In Message:</td><td><textarea name="fillin" cols="40" rows="8"></textarea></td></tr>
					</table>
				</td>
			</tr>
			<tr class="content">
				<td align="center">
					<input type="hidden" name="xxS" value="#xxS#">
					<input type="hidden" name="xxA" value="#xxA#">
					<input type="hidden" name="xxL" value="#xxL#">
					<input type="hidden" name="xxT" value="#xxT#">
					<input type="hidden" name="xOnPage" value="#xOnPage#">
					<input type="hidden" name="pgfn" value="send_the_email" />
					<input type="hidden" name="puser_ID" value="#puser_ID#" />
					<input type="hidden" name="program_ID" value="#program_ID#">
					<input type="submit" name="submit" value="Save" >
				</td>
			</tr>
		</table>
	</form>
	</cfoutput>
	<!--- END pgfn EMAIL --->
<cfelseif pgfn EQ "ccmax">
	<!--- START pgfn CC MAX --->
	<cfoutput>
	<span class="pagetitle">Set Credit Card Maximum</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="program_user.cfm?program_ID=#program_ID#&xOnPage=#xOnPage#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&show_zip=#show_zip#">Program User List</a><cfif FLGen_HasAdminAccess(1000000014)>  or  <a href="program.cfm">Award Program List</a></cfif> without making changes.</span>
	<br /><br />
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0">
	<tr class="content2">
	<td  colspan="2"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
	</tr>
	<tr class="contenthead">
	<td class="headertext">Set Credit Card Maximum for all Program Users</td>
	</tr>
	<tr class="content">
	<td align="center"><input type="text" name="cc_max" maxlength="6" size="8">
	<input type="hidden" name="xxS" value="#xxS#">
	<input type="hidden" name="xxA" value="#xxA#">
	<input type="hidden" name="xxL" value="#xxL#">
	<input type="hidden" name="xxT" value="#xxT#">
	<input type="hidden" name="xOnPage" value="#xOnPage#">
	<input type="hidden" name="pgfn" value="#pgfn#">
	<input type="hidden" name="program_ID" value="#program_ID#">
	<input type="submit" name="submit" value="Save" >
	</td>
	</tr>
	</table>
	</form>
	</cfoutput>
	<!--- END pgfn CC MAX --->
<cfelseif pgfn EQ "allowdefer">
	<!--- START pgfn DEFER ALLOWED --->
	<cfoutput>
	<span class="pagetitle">Set Allowed Deferal Amount</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="program_user.cfm?program_ID=#program_ID#&xOnPage=#xOnPage#&xxS=#xxS#&xxA=#xxA#&xxL=#xxL#&xxT=#xxT#&show_zip=#show_zip#">Program User List</a><cfif FLGen_HasAdminAccess(1000000014)>  or  <a href="program.cfm">Award Program List</a></cfif> without making changes.</span>
	<br /><br />
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0">
	<tr class="content2">
	<td  colspan="2"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
	</tr>
	<tr class="contenthead">
	<td class="headertext">Set Allowed Deferal Amount for all Program Users</td>
	</tr>
	<tr class="content">
	<td align="center"><input type="text" name="defer_allowed" maxlength="6" size="8">
	<input type="hidden" name="xxS" value="#xxS#">
	<input type="hidden" name="xxA" value="#xxA#">
	<input type="hidden" name="xxL" value="#xxL#">
	<input type="hidden" name="xxT" value="#xxT#">
	<input type="hidden" name="xOnPage" value="#xOnPage#">
	<input type="hidden" name="pgfn" value="#pgfn#">
	<input type="hidden" name="program_ID" value="#program_ID#">
	<input type="submit" name="submit" value="Save" >
	</td>
	</tr>
	</table>
	</form>
	</cfoutput>
	<!--- END pgfn DEFER ALLOWED --->
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->
