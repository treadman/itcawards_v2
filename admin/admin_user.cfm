<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000006,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="HashedPassword" default="">
<cfparam name="SQLxUpdatePassword" default="">
<cfparam name="SQLxInsertPassword1" default="">
<cfparam name="SQLxInsertPassword2" default="">
<cfparam name="QueryString_nodupem" default="">
<cfparam name="alert_msg" default="">
<cfparam name="program_ID" default="">
<cfparam name="show_delete" default="false">
<cfparam name="ID" default="">
<cfparam  name="pgfn" default="list">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<!--- if a password was entered then salt/hash it and add in the extra sql to save it --->
	<cfif IsDefined('form.password') AND #form.password# IS NOT "">
		<cfset HashedPassword = FLGen_CreateHash(Lcase(form.password))>
		<cfset SQLxUpdatePassword = ' , password = "#HashedPassword#" '>
	</cfif>
	<cfif form.program_ID EQ "">
		<cfset form_program_ID = '1000000001'>
	<cfelse>
		<cfset form_program_ID = form.program_ID>
	</cfif>
	<!--- copy --->
	<cfif form.ID IS NOT "" AND pgfn EQ 'copy'>
		<cflock name="admin_usersLock" timeout="10">
			<cftransaction>
				<cfquery name="AddAdminUser" datasource="#application.DS#">
					INSERT INTO #application.database#.admin_users
						(firstname, lastname, username, email, program_ID, password, created_user_ID, created_datetime, is_system_admin)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstname#" maxlength="30">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastname#" maxlength="30">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.username#" maxlength="32">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="128">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#form_program_ID#">,
						'#HashedPassword#',
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						1
					)
				</cfquery>
				<cfquery datasource="#application.DS#" name="getID">
					SELECT Max(ID) As MaxID FROM #application.database#.admin_users
				</cfquery>
			</cftransaction>
		</cflock>
		<cfset new_user_ID = getID.MaxID>
		<cfquery name="FindUserAdminAccess" datasource="#application.DS#">
			SELECT al.ID AS this_access_ID
			FROM #application.database#.admin_level al
				LEFT JOIN #application.database#.admin_lookup lk ON al.ID = lk.access_level_ID 
			WHERE lk.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID#" maxlength="10">
			ORDER BY al.sortorder ASC
		</cfquery>
		<cfloop query="FindUserAdminAccess">
			<cfquery name="InsertQuery" datasource="#application.DS#">
				INSERT INTO #application.database#.admin_lookup
				(created_user_ID, created_datetime, user_ID, access_level_ID)
				VALUES
				(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#', <cfqueryparam cfsqltype="cf_sql_integer" value="#new_user_ID#" maxlength="10">, <cfqueryparam cfsqltype="cf_sql_integer" value="#this_access_ID#" maxlength="10">)
			</cfquery>
		</cfloop>
		<cfset pgfn = "list">
		<cfset alert_msg = "The new admin user was saved.">
	<!--- update --->
	<cfelseif form.ID IS NOT "">
		<cfquery name="UpdateAdminUser" datasource="#application.DS#">
			UPDATE #application.database#.admin_users
			SET	firstname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstname#" maxlength="30">,
				lastname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastname#" maxlength="30">,
				username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.username#" maxlength="32">,
				email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="128">,
				program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form_program_ID#">
				#FLGen_UpdateModConcatSQL()#
				#SQLxUpdatePassword# 
				WHERE ID = '#form.ID#'
		</cfquery>
		<cfset pgfn = "edit">
		<cfset alert_msg = "The information was saved.#FLGen_SubStamp()#">
	<!--- add --->
	<cfelse>
		<cflock name="admin_usersLock" timeout="10">
			<cftransaction>
				<cfquery name="AddAdminUser" datasource="#application.DS#">
					INSERT INTO #application.database#.admin_users
						(firstname, lastname, username, email, program_ID, password, created_user_ID, created_datetime, is_system_admin)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.firstname#" maxlength="30">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lastname#" maxlength="30">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.username#" maxlength="32">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="128">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#form_program_ID#">,
						'#HashedPassword#',
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						1
					)
				</cfquery>
				<cfquery datasource="#application.DS#" name="getID">
					SELECT Max(ID) As MaxID FROM #application.database#.admin_users
				</cfquery>
			</cftransaction>
		</cflock>
		<cfset ID = getID.MaxID>
		<cfset pgfn = "edit">
		<cfset alert_msg = "The new admin user was saved.#FLGen_SubStamp()#">
	</cfif>
</cfif>

<cfif pgfn EQ 'delete' and ID NEQ ''>
	<cfquery name="DeleteUser" datasource="#application.DS#">
		DELETE FROM #application.database#.admin_users
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
	<cfquery name="Access" datasource="#application.DS#">
		DELETE FROM #application.database#.admin_lookup
		WHERE user_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
	<cfset pgfn = "list">
	<cfset alert_msg = "The admin user was deleted.">
</cfif>

<cfif pgfn EQ 'deactivate' and ID NEQ ''>
	<cfquery name="DeactivateUser" datasource="#application.DS#">
		UPDATE #application.database#.admin_users
		SET is_active = 0
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
	<cfset pgfn = "list">
	<cfset alert_msg = "The admin user was deactivated.">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "admin_users">
<cfinclude template="includes/header.cfm">

<!--- START pgfn LIST --->
<cfif pgfn EQ "list">

	<span class="pagetitle">Admin User List</span>
	<br /><br />
	<span class="pageinstructions">The link to delete a user is on their edit page.</span>
	<br /><br />

	<cfif NOT request.newNav>
		<!--- search box (START) --->
		<table cellpadding="5" cellspacing="0" border="0" width="100%">
		<cfoutput>
		<tr class="contenthead">
		<td><span class="headertext">Search Criteria</span></td>
		</tr>
		<form action="#CurrentPage#" method="post">
		<tr>
		<td class="content" align="center">
			<!--- do query on pv_master table --->
			<cfquery name="GetProgramNames" datasource="#application.DS#">
				SELECT ID AS this_program_ID, company_name, program_name 
				FROM #application.database#.program
				ORDER BY company_name, program_name
			</cfquery>
	
			<select name="program_ID">
				<option value="">Show all admin users</option>
				<option value="1000000001"<cfif program_ID EQ '1000000001'> selected</cfif>>ITCAdmin Users</option>
			<cfloop query="GetProgramNames">
				<option value="#this_program_ID#"<cfif this_program_ID EQ program_ID> selected</cfif>>#company_name# [#program_name#]</option>
			</cfloop>
			</select>
		<input type="submit" name="submit_search" value="Submit"></td>
		</tr>
		</form>
		</cfoutput>
		</table>
		<br /><br />
		<!--- search box (END) --->
	</cfif>
	<cfquery name="SelectAdminUsers" datasource="#application.DS#">
		SELECT au.ID, au.firstname, au.lastname, au.username, au.program_ID AS this_users_program_ID
		FROM #application.database#.admin_users au
		LEFT JOIN #application.database#.program pr ON au.program_ID = pr.ID 
		WHERE au.is_active = 1 AND au.is_system_admin = 1
		<cfif program_ID NEQ ''>
			AND au.program_ID = #program_ID# 
		</cfif>
		ORDER BY pr.company_name, pr.program_name, au.firstname ASC
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="contenthead">
	<td align="center"><a href="admin_user.cfm?pgfn=add">Add</a></td>
	<td width="100%"><span class="headertext">Name</span></td>
	<td><span class="headertext">Username</span></td>
	<td>&nbsp;</td>
	</tr>
	<cfoutput query="SelectAdminUsers" group="this_users_program_ID">
		<tr class="BGshowhide">
		<td>&nbsp;</td>
		<td colspan="3">
		<span class="program_headers"><cfif this_users_program_ID EQ 1000000001>ITC Admin Users<cfelse>#FLITC_GetProgramName(this_users_program_ID)#</cfif></span>
		</td>
		</tr>
		<cfoutput>
		<!--- #FLITC_Show_Delete_Admin_User(ID)#<cfset show_delete = FLITC_show_delete> --->
		<cfset show_delete = false>
		<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
		<td><a href="admin_user.cfm?pgfn=edit&id=#ID#">Edit</a>&nbsp;&nbsp;<a href="admin_user.cfm?pgfn=copy&id=#ID#">Copy</a><cfif show_delete>&nbsp;&nbsp;<a href="#CurrentPage#?pgfn=delete&ID=#ID#" onclick="return confirm('Are you sure you want to delete this admin user?  There is NO UNDO.')">Delete</a></cfif></td>
		<td>#HTMLEditFormat(firstname)# #HTMLEditFormat(lastname)#</td>
		<td>#HTMLEditFormat(username)#</td>
		<td><cfif FLGen_HasAdminAccess(1000000030)><a href="admin_user_access.cfm?userid=#ID#">Assign&nbsp;Access</a><cfelse></cfif></td>
		</tr>
		</cfoutput>
	</cfoutput>	
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit">
	<!--- START pgfn ADD/EDIT --->
	<span class="pagetitle"><cfif pgfn EQ "add">Add an</cfif> Admin User <cfif pgfn EQ "edit">Edit</cfif></span>
	<br /><br />
	<cfif pgfn EQ 'edit'>
	<span class="pageinstructions">Passwords are not retrievable.  Forgotten passwords should be set to something new.</span>
	<br /><br />
	</cfif>
	<span class="pageinstructions">Return to <a href="admin_user.cfm">Admin User List</a> without making changes.</span>
	<br /><br />
	
	<cfparam name="firstname" default="">
	<cfparam name="lastname" default="">
	<cfparam name="username" default="">
	<cfparam name="email" default="">
	<cfparam name="program_ID" default="">
	<cfparam name="ID" default="">	

	<cfif pgfn EQ "edit">
		<cfquery name="EditAdminUsers" datasource="#application.DS#">
			SELECT ID, firstname, lastname, username, ID, email, program_ID 
			FROM #application.database#.admin_users
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10">
			ORDER BY lastname ASC
		</cfquery>
		<cfset firstname = HTMLEditFormat(EditAdminUsers.firstname)>
		<cfset lastname = HTMLEditFormat(EditAdminUsers.lastname)>
		<cfset username = HTMLEditFormat(EditAdminUsers.username)>
		<cfset email = HTMLEditFormat(EditAdminUsers.email)>
		<cfset program_ID = HTMLEditFormat(EditAdminUsers.program_ID)>
		<cfset ID = HTMLEditFormat(EditAdminUsers.ID)>	
	</cfif>

	<!--- take the m=1 off the QS if it's already on there --->
	<cfset QueryString_nodupem = Replace(#CGI.QUERY_STRING#,"&m=1","")>
	<form method="post" action="admin_user.cfm">
		<cfoutput>
		<cfif pgfn EQ "edit">
			#FLITC_Show_Delete_Admin_User(ID)#<cfset show_delete = FLITC_show_delete>
			<span class="pageinstructions" style="display:block">
				<cfif show_delete>
					<a href="#CurrentPage#?pgfn=delete&ID=#ID#" onclick="return confirm('Are you sure you want to delete this admin user?  There is NO UNDO.')">Delete</a>
				<cfelse>
				<a href="#CurrentPage#?pgfn=deactivate&ID=#ID#" onclick="return confirm('Are you sure you want to deactivate this admin user?')">Deactivate</a>&nbsp;&nbsp;&nbsp;This user <b>cannot be deleted</b> because they are linked with actions in the admin.  If you deactivate them, they will no longer appear on the Admin User list and they will no longer be able to login.
				</cfif>
			</span>
			<br>
		</cfif>
		<table cellpadding="5" cellspacing="1" border="0">
	
		<tr class="contenthead">
		<td colspan="2"><span class="headertext"><cfif pgfn EQ "add">Add an</cfif> Admin User <cfif pgfn EQ "edit">Edit</cfif></span></td>
		</tr>
		
		<tr class="content">
		<td align="right">First Name: </td>
		<td><input type="text" name="firstname" value="#firstname#" maxlength="30" size="40"></td>
		</tr>
		
		<tr class="content">
		<td align="right">Last Name: </td>
		<td><input type="text" name="lastname" value="#lastname#" maxlength="30" size="40"></td>
		</tr>
		
		<tr class="content">
		<td align="right">Username: </td>
		<td><input type="text" name="username" value="#username#" maxlength="30" size="40"></td>
		</tr>
		
		<cfif pgfn EQ "edit">
			<tr class="content2">
			<td align="right">&nbsp; </td>
			<td><img src="../pics/contrls-desc.gif"> Leave the password field blank to keep the user's current password.</td>
			</tr>
		</cfif>
		<tr class="content">
		<td align="right">Password: </td>
		<td><input type="text" name="password" maxlength="30" size="40"></td>
		</tr>

		<tr class="content">
		<td align="right">Email: </td>
		<td><input type="text" name="email" value="#email#" maxlength="30" size="40"></td>
		</tr>

		<tr class="content">
		<td align="right">Assign to this Program: </td>
		<cfif program_ID EQ '1000000001'>
			<cfset this_program_ID = "">
		<cfelse>
			<cfset this_program_ID = program_ID>
		</cfif>
		<td>#SelectProgram(this_program_ID,"ITC Admin User")#</td>
		</tr>

		<input type="hidden" name="ID" value="#ID#">
		<input type="hidden" name="firstname_required" value="You must enter a first name.">
		<input type="hidden" name="lastname_required" value="You must enter a last name.">
		<input type="hidden" name="username_required" value="You must enter a username.">
		<cfif pgfn EQ "add">
			<input type="hidden" name="password_required" value="You must enter a password.">
		</cfif>
		<input type="hidden" name="email_required" value="You must enter an email address.">
		<input type="hidden" name="pgfn" value="#pgfn#">

		<tr class="content">
		<td colspan="2" align="center"><input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" ></td>
		</tr>
		</table>
		</cfoutput>
	</form>
	<!--- END pgfn ADD/EDIT --->
<cfelseif pgfn EQ "copy">
	<!--- START pgfn COPY --->
	<span class="pagetitle">Copy an Admin User</span>
	<br /><br />
	<span class="pageinstructions"><span class="alert">!</span> You are adding a new user with the selected user's adminstrative access privledges.</span>
	<br /><br />
	<span class="pageinstructions">You must enter a unique username and password for this new user.</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="admin_user.cfm">Admin User List</a> without making changes.</span>
	<br /><br />

	<cfparam name="firstname" default="">
	<cfparam name="lastname" default="">
	<cfparam name="username" default="">
	<cfparam name="email" default="">
	<cfparam name="program_ID" default="">
	<cfparam name="ID" default="">	

	<cfquery name="EditAdminUsers" datasource="#application.DS#">
		SELECT ID, firstname, lastname, username, ID, email, program_ID 
		FROM #application.database#.admin_users
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10">
		ORDER BY lastname ASC
	</cfquery>
	<cfset firstname = HTMLEditFormat(EditAdminUsers.firstname)>
	<cfset lastname = HTMLEditFormat(EditAdminUsers.lastname)>
	<cfset username = HTMLEditFormat(EditAdminUsers.username)>
	<cfset email = HTMLEditFormat(EditAdminUsers.email)>
	<cfset program_ID = HTMLEditFormat(EditAdminUsers.program_ID)>
	<cfset ID = HTMLEditFormat(EditAdminUsers.ID)>	

	<form method="post" action="admin_user.cfm">
		<cfoutput>
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
		
		<tr class="contenthead">
		<td colspan="2"><span class="headertext">Copy an Admin User</span></td>
		</tr>
		
		<tr class="content">
		<td align="right">First Name: </td>
		<td width="100%"><input type="text" name="firstname" value="COPY-#firstname#" maxlength="30" size="40"></td>
		</tr>
		
		<tr class="content">
		<td align="right">Last Name: </td>
		<td><input type="text" name="lastname" value="COPY-#lastname#" maxlength="30" size="40"></td>
		</tr>
		
		<tr class="content">
		<td align="right">Username: </td>
		<td><input type="text" name="username" value="" maxlength="30" size="40"></td>
		</tr>
		
		<tr class="content">
		<td align="right">Password: </td>
		<td><input type="text" name="password" value="" maxlength="30" size="40"></td>
		</tr>
	
		<tr class="content">
		<td align="right">Email: </td>
		<td><input type="text" name="email" maxlength="30" size="40"></td>
		</tr>
		
		<tr class="content">
		<td align="right">Program Logo: </td>
		<td>#SelectProgram(program_ID,"ITC Admin User")#</td>
		</tr>
		
		<input type="hidden" name="ID" value="#ID#">
		<input type="hidden" name="firstname_required" value="You must enter a first name.">
		<input type="hidden" name="lastname_required" value="You must enter a last name.">
		<input type="hidden" name="username_required" value="You must enter a username.">
		<cfif pgfn EQ "add">
			<input type="hidden" name="password_required" value="You must enter a password.">
		</cfif>
		<input type="hidden" name="email_required" value="You must enter an email address.">
		<input type="hidden" name="pgfn" value="#pgfn#">
			
		<tr class="content">
		<td colspan="2" align="center"><input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" ></td>
		</tr>
			
		<cfquery name="FindUserAdminAccess" datasource="#application.DS#">
			SELECT al.ID, al.level_name, al.sortorder, IFNULL(al.note,"(no note)") AS note, al.sortorder
			FROM #application.database#.admin_level al
				LEFT JOIN #application.database#.admin_lookup lk ON al.ID = lk.access_level_ID 
			WHERE lk.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10">
				OR TRIM(al.note) = 'header'
			ORDER BY al.sortorder ASC
		</cfquery>
		
		<tr class="content">
		<td align="right" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Admin&nbsp;Access: <br><br>Bold headers are displayed even if user has no assigned access under that header.</td>
		<td><cfloop query="FindUserAdminAccess"><cfif note EQ 'header'><b></cfif>#level_name#<cfif note EQ 'header'></b></cfif><br></cfloop></td>
		</tr>
		
		</table>
		</cfoutput>
	
	</form>
	<!--- END pgfn COPY --->

</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->