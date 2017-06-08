<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000060,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam  name="pgfn" default="list">
<cfparam name="alert_msg" default="">
<!--- param a/e form fields --->
<cfparam name="username" default="">	
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="email" default="">
<cfparam name="is_active" default="">
<cfparam name="this_region_ID" default="">
<cfparam name="program_user_ID" default="">

<cfset thisProgramID = 1000000009>

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfset has_unique_email = false>
	<cfset has_unique_username = false>
	<cfquery name="GetAdminName" datasource="#application.DS#">
		SELECT firstname, lastname
		FROM #application.database#.admin_users
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">
	</cfquery>
	<!--- is the email address unique in this program ? --->
	<cfif IsDefined('form.email') AND form.email IS NOT "">
		<cfquery name="AnyDuplicateEmails" datasource="#application.DS#">
			SELECT ID
			FROM #application.database#.program_user
			WHERE email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128"> AND 
				program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisProgramID#">
			<cfif form.program_user_ID IS NOT "">
				 AND ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_user_ID#" maxlength="10">
			</cfif>
		</cfquery>
		<cfif AnyDuplicateEmails.RecordCount GT 0>
			<cfset alert_msg = "Error: A user with that email address already exists.">
		<cfelse>
			<cfset has_unique_email = true>
		</cfif>
	</cfif>
	
	<!--- check if the username is unique --->
	<!--- did they submit either the lastfour or the username field --->
	<cfif has_unique_email AND ((IsDefined('form.lastfour') AND form.lastfour IS NOT "" AND IsDefined('form.lname') AND form.lname IS NOT "") OR IsDefined('form.username') AND form.username IS NOT "")>
		<!--- Create Username --->
		<cfif IsDefined('form.lastfour') AND form.lastfour IS NOT "" AND IsDefined('form.lname') AND form.lname IS NOT "">
			<cfset userlastname = "">
			<cfswitch expression="#LEN(form.lname)#">
				<cfcase value="2"><cfset userlastname = Ucase(form.lname) & 'x'></cfcase>
				<cfcase value="1"><cfset userlastname = Ucase(form.lname) & 'xx'></cfcase>
				<cfdefaultcase><cfset userlastname = RemoveChars(Ucase(form.lname),4,LEN(form.lname))></cfdefaultcase>
			</cfswitch>
			<cfset NEWusername = userlastname & form.lastfour>
		<cfelseif IsDefined('form.username') AND #form.username# IS NOT "">
			<!--- use the submitted username --->
			<cfset NEWusername = form.username>
		</cfif>

		<!--- check to see if this username is already in use for this program --->
		<cfquery name="AnyDuplicateUsernames" datasource="#application.DS#">
			SELECT ID
			FROM #application.database#.program_user
			WHERE username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="16"> 
			AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisProgramID#">
			<cfif form.program_user_ID IS NOT "">
				 AND ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_user_ID#" maxlength="10">
			</cfif>
		</cfquery>
	
		<cfif AnyDuplicateUsernames.RecordCount GT 0>
			<cfset alert_msg = "Error: A user with that username already exists.">
		<cfelse>
			<cfset has_unique_username = true>
		</cfif>
	</cfif>
	
	<cfif has_unique_email AND has_unique_username>

		<!--- update --->
		<cfif form.program_user_ID IS NOT "">
			<cfquery name="UpdateQuery" datasource="#application.DS#">
				UPDATE #application.database#.program_user
				SET	username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#NEWusername#" maxlength="16">,
					fname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.fname)))#">,
					lname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.lname)))#">,
					email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128" null="#YesNoFormat(NOT Len(Trim(form.email)))#">,
					is_active = 1 
					#FLGen_UpdateModConcatSQL()#
					WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.program_user_ID#" maxlength="10">
			</cfquery>
			
			<cfset alert_msg = "The changes were saved.#FLGen_SubStamp()#">
			<cfset pgfn = "edit">
		
		<!--- add --->
		<cfelse>
			<cflock name="program_userLock" timeout="10">
				<cftransaction>
					<cfquery name="InsertQuery" datasource="#application.DS#">
						INSERT INTO #application.database#.program_user
							(created_user_ID, created_datetime, username, fname, lname, email, is_active, program_ID)
						VALUES (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, 
							'#FLGen_DateTimeToMySQL()#', 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#NEWusername#" maxlength="16">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.fname)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(form.lname)))#">, 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.email#" maxlength="128" null="#YesNoFormat(NOT Len(Trim(form.email)))#">, 
							1, 
							<cfqueryparam cfsqltype="cf_sql_integer" value="#thisProgramID#">
						)
					</cfquery>
					<cfquery name="getID" datasource="#application.DS#">
						SELECT Max(ID) As MaxID FROM #application.database#.program_user
					</cfquery>
					<cfset program_user_ID = getID.MaxID>
				</cftransaction>  
			</cflock>
			<cfset alert_msg = "The new user was saved.#FLGen_SubStamp()#">
			<cfset pgfn = "edit">
	
		</cfif>
		<!--- TODO:  Assigned the user to a region.
				This is probably not necessary, but if you want to assign program users to regions,
				you'll need to add "program_region_ID" to the program_user table. --->		

		<!--- award submitted points --->
		<cfif IsDefined('form.award_amount') AND form.award_amount IS NOT "">
		
			<cfquery name="InsertPoints" datasource="#application.DS#">
				INSERT INTO #application.database#.awards_points
				(created_user_ID, created_datetime, user_ID, points, notes)
				VALUES
				('#FLGen_adminID#', '#FLGen_DateTimeToMySQL()#',
					<cfqueryparam cfsqltype="cf_sql_integer" value="#program_user_ID#" maxlength="10">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#award_amount#" maxlength="8">,
					'*auto note* #GetAdminName.firstname# #GetAdminName.lastname# awarded points on Manage Users page.')
			</cfquery>
		</cfif>
		
		<!--- send email if prompted --->
		<cfif IsDefined('form.send_email') AND form.send_email IS NOT "">
		
			<!--- GET INFO FOR EMAIL VARS --->
		
			<!--- get a user's information --->
			<cfquery name="SelectUserInfo" datasource="#application.DS#">
				SELECT fname, username 
				FROM #application.database#.program_user
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_user_ID#" maxlength="10">
			</cfquery>
			<!--- set vars --->
			<cfset fname = HTMLEditFormat(SelectUserInfo.fname)>
			<cfset username = HTMLEditFormat(SelectUserInfo.username)>
			
			<cfoutput>#ProgramUserInfo(program_user_ID)#</cfoutput>
	
			<!--- get program information  --->
			<cfquery name="SelectProgramInfo" datasource="#application.DS#">
				SELECT company_name, logo, credit_desc, login_prompt
				FROM #application.database#.program
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisProgramID#">
			</cfquery>
			
			<!--- set vars --->
			<cfset company_name = HTMLEditFormat(SelectProgramInfo.company_name)>
			<cfset logo = HTMLEditFormat(SelectProgramInfo.logo)>
			<cfset credit_desc = HTMLEditFormat(SelectProgramInfo.credit_desc)>
			<cfset login_prompt = HTMLEditFormat(SelectProgramInfo.login_prompt)>
		
			<!--- get the logo --->
			<cfif logo NEQ "">
				<cfset vLogo = HTMLEditFormat(logo)>
			<cfelse>
				<cfset vLogo = "shim.gif">
			</cfif>
			
		<cflock name="ThisLock" type="readonly" timeout="30">
			<cffile action="read" file="#application.AbsPath#admin/program_award_subject.txt" variable="emailsubject">
		</cflock>
		
		<cfmail to="#Application.ErrorEmailTo#" from="#Application.AwardsFromEmail#" subject="#emailsubject#" type="html">
	
			<cfinclude template="program_award_email.txt">
	
		</cfmail>

		
		</cfif>

	</cfif>
	
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "program_manage_users">
<cfinclude template="includes/header.cfm">

<cfif pgfn EQ "list">
	<cfoutput>
	<span class="pagetitle">Program User List for program with the ID of #thisProgramID#</span>
	<br /><br />
	<span class="pageinstructions"><a href="#CurrentPage#?pgfn=add">Add</a> a new program user.</span>
	<br /><br />
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT u.ID AS program_user_ID, u.fname, u.lname
		FROM #application.database#.program_user u 
		WHERE u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisProgramID#">
		ORDER BY u.lname
	</cfquery>
	</cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<!--- display found records --->
	<cfoutput query="SelectList">
		<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
		<td style="padding-left:125px"><a href="#CurrentPage#?pgfn=edit&program_user_ID=#program_user_ID#">Edit</a></td>
		<td>#ProgramUserInfo(program_user_ID)##user_totalpoints#</td>
		<td valign="top" width="100%">#htmleditformat(fname)#&nbsp;#htmleditformat(lname)#</td>
		</tr>
	</cfoutput>

	</table>
<cfelseif pgfn EQ "edit" OR pgfn EQ "add">
	<cfoutput>
	<span class="pagetitle"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Program User</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="#CurrentPage#">Program User List</a> without making changes.</span>
	<br /><br />
	</cfoutput>
	<cfif 'duplicateusername' EQ 0>
		<span class="alert">No duplicate usernames are allowed in a program.  Please enter a new username.</span>
		<br /><br />
	</cfif>
	<cfif 'datasaved' eq 'yes'>
		<cfoutput>
		<span class="alert">The information was saved.</span>#FLGen_SubStamp()#
		<br /><br />
		</cfoutput>
	</cfif>
	<!--- what categories are assigned to this program - for point dropdown --->
	<cfquery name="SelectProgramCategories" datasource="#application.DS#">
		SELECT pvm.productvalue 
		FROM #application.product_database#.productvalue_program pvp 
			JOIN #application.product_database#.productvalue_master pvm ON pvp.productvalue_master_ID = pvm.ID 
		WHERE pvp.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisProgramID#">
		ORDER BY pvp.sortorder ASC
	</cfquery>
	<cfif pgfn EQ "edit">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT u.username, u.fname, u.lname, u.email, u.is_active
			FROM #application.database#.program_user u
			WHERE u.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_user_ID#" maxlength="10">
		</cfquery>
		<cfset username = htmleditformat(ToBeEdited.username)>	
		<cfset fname = htmleditformat(ToBeEdited.fname)>
		<cfset lname = htmleditformat(ToBeEdited.lname)>
		<cfset email = htmleditformat(ToBeEdited.email)>
		<cfset is_active = htmleditformat(ToBeEdited.is_active)>
		<cfif ToBeEdited.RecordCount EQ 0>
			<cflocation addtoken="no" url="#CurrentPage#?pgfn=list">
		</cfif>
	</cfif>
	<cfoutput>
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="contenthead">
	<td colspan="2" class="headertext"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Program User</td>
	</tr>
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif"> If you enter the last four digits of the SSN a username will be auto-created.</td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Username: </td>
	<td valign="top">
		<input type="text" name="username" value="#username#" maxlength="16" size="20">&nbsp;&nbsp;&nbsp;<span class="alert"><- OR -></span>&nbsp;&nbsp;&nbsp;Last 4 digits of SSN: <input type="text" name="lastfour" maxlength="4" size="6">
	</td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">First Name: </td>
	<td valign="top"><input type="text" name="fname" value="#fname#" maxlength="30" size="40"></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Last Name: </td>
	<td valign="top"><input type="text" name="lname" value="#lname#" maxlength="30" size="40"></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Email: </td>
	<td valign="top"><input type="text" name="email" value="#email#" maxlength="128" size="40"></td>
	</tr>
		
	<cfif pgfn EQ "edit">
		<tr class="content2">
		<td align="right" valign="top">&nbsp;</td>
		<td valign="top"><img src="../pics/contrls-desc.gif"> This amount will be added to the user's existing total.</td>
		</tr>
	</cfif>	

	<tr class="content">
	<td align="right" valign="top">Award&nbsp;Amount:</td>
	<td valign="top">
		<select name="award_amount" >
			<option value=""> -- Select An Amount --</option>
			<cfloop query="SelectProgramCategories">
			<option value="#productvalue#">#productvalue#</option>
			</cfloop>
		</select><cfif program_user_ID NEQ ''> <span class="sub">[ Current Total: #ProgramUserInfo(program_user_ID)##user_totalpoints# ]</span> </cfif>
	</td> 
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><input type="checkbox" name="send_email"> Send an Award Announcement Email. <a href="program_award_emailsample.cfm" target="_blank">sample</a></td>
	</tr>
		
	<tr class="content">
	<td colspan="2" align="center">

	<input type="hidden" name="program_user_ID" value="#program_user_ID#">
	<input type="hidden" name="pgfn" value="#pgfn#">
	
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" >
	
	</td>
	</tr>
		
	</table>
	</form>
	</cfoutput>

</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->