<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000014,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="x" default="">
<cfparam name="datasaved" default="no">
<cfparam name="program_ID" default="">
<cfparam name="login_ID" default="">
<cfparam name="username" default="">
<cfparam name="password" default="">
<cfparam name="duplicatelogin" default="false">
<cfparam name="delete" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>

	<!--- check to see if this username/password combo is already in use --->
	<cfquery name="AnyDuplicateLogins" datasource="#application.DS#">
		SELECT ID
		FROM #application.database#.program_login
		WHERE username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="32"> AND password = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.password#" maxlength="20">
	</cfquery>

	<cfif AnyDuplicateLogins.RecordCount EQ 0>
		
		<!--- update --->
		<cfif form.login_ID IS NOT "">
			<cfquery name="UpdateQuery" datasource="#application.DS#">
				UPDATE #application.database#.program_login
				SET	username = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="32">,
					password = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.password#" maxlength="20">,
					program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#" maxlength="10">
					#FLGen_UpdateModConcatSQL()#
					WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.login_ID#" maxlength="10">
			</cfquery>
		<!--- add --->
		<cfelse>
			<cflock name="program_loginLock" timeout="10">
				<cftransaction>
					<cfquery name="InsertQuery" datasource="#application.DS#">
						INSERT INTO #application.database#.program_login
							(created_user_ID, created_datetime, username, password, program_ID)
						VALUES
							(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#', 
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.username#" maxlength="32">,<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.password#" maxlength="20">,<cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#" maxlength="10">)
					</cfquery>
					<cfquery name="getID" datasource="#application.DS#">
						SELECT Max(ID) As MaxID FROM #application.database#.program_login
					</cfquery>
					<cfset login_ID = getID.MaxID>
				</cftransaction>  
			</cflock>
			<cfset pgfn = 'list'>
		</cfif>
		
	<cfelse>
	
		<cfset duplicatelogin = true>
		<cfset pgfn = form.pgfn>
		
	</cfif>
<cfelseif delete NEQ ''>
	<cfquery name="DeleteLogin" datasource="#application.DS#">
		DELETE FROM #application.database#.program_login
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#" maxlength="10">
	</cfquery>			
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">

<cfparam  name="pgfn" default="list">

<!--- START pgfn LIST --->
<cfif pgfn EQ "list">
	<span class="pagetitle">Program Logins</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="program.cfm">Award Program List</a> without making changes.</span>
	<br /><br />
	<cfquery name="SelectLogins" datasource="#application.DS#">
		SELECT ID AS login_ID, program_ID, username, password
		FROM #application.database#.program_login
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
		ORDER BY username
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<cfoutput>
		<tr class="content2">
		<td colspan="3"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
		</tr>
	
		<tr class="contenthead">
		<td><a href="#CurrentPage#?pgfn=add&program_ID=#program_ID#">Add</a></td>
		<td><span class="headertext">Username</span></td>
		<td><span class="headertext">Password</span></td>
		</tr>
		</cfoutput>
		<cfif SelectLogins.RecordCount IS 0>
			<tr class="content2">
			<td colspan="3" align="center"><span class="alert"><br>No logins found.  Click "add" enter a login for this program.<br><br></span></td>
			</tr>
		</cfif>
		<cfoutput query="SelectLogins">
			<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
			<td><a href="#CurrentPage#?pgfn=edit&program_ID=#program_ID#&login_ID=#login_ID#">Edit</a>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?delete=#login_ID#&program_ID=#program_ID#" onclick="return confirm('Are you sure you want to delete this program login?  There is NO UNDO.')">Delete</a></td>
			<td>#HTMLEditFormat(username)#</td>
			<td>#HTMLEditFormat(password)#</td>
			</tr>
		</cfoutput>	
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit">
	<!--- START pgfn ADD/EDIT --->
	<cfoutput>
	<span class="pagetitle"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Program Login</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="program_login.cfm?program_ID=#program_ID#">Program Login List</a>  or  <a href="program.cfm?">Award Program List</a> without making changes.</span>
	<br /><br />
	</cfoutput>
	<cfif duplicatelogin>
	<span class="alert">No duplicate logins are allowed.  Please enter a new username and password.</span>
	<br /><br />
	</cfif>
	
	<cfif datasaved eq 'yes'>
		<cfoutput>
		<span class="alert">The information was saved.</span>#FLGen_SubStamp()#
		<br /><br />
		</cfoutput>
	</cfif>
	
	<cfif pgfn EQ "edit">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT ID AS login_ID, program_ID, username, password
			FROM #application.database#.program_login
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#login_ID#" maxlength="10">
		</cfquery>
		<cfset login_ID = ToBeEdited.login_ID>
		<cfset program_ID = ToBeEdited.program_ID>
		<cfset username = htmleditformat(ToBeEdited.username)>
		<cfset password = htmleditformat(ToBeEdited.password)>
	</cfif>
	
	<cfoutput>
	<form method="post" action="#CurrentPage#">
	
	
		<table cellpadding="5" cellspacing="1" border="0">
		
		<tr class="content2">
		<td colspan="2"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(program_ID)#</span></span></td>
		</tr>
	
		<tr class="contenthead">
		<td colspan="2"><span class="headertext"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Program Login</span></td>
		</tr>
		
		<tr class="content">
		<td align="right">Username: </td>
		<td><input type="text" name="username" value="#username#" maxlength="30" size="40"></td>
		</tr>
		
		<tr class="content">
		<td align="right">Password: </td>
		<td><input type="text" name="password" value="#password#" maxlength="30" size="40"></td>
		</tr>
			
		<tr class="content">
		<td colspan="2" align="center">
		
		<input type="hidden" name="pgfn" value="#pgfn#">
		
		<input type="hidden" name="program_ID" value="#program_ID#">
		<input type="hidden" name="login_ID" value="#login_ID#">
		
		<input type="hidden" name="username_required" value="You must enter a username.">
		<input type="hidden" name="password_required" value="You must enter a password.">
			
		<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" >
	
		</td>
		</tr>
			
		</table>
	</form>
	</cfoutput>
	<!--- END pgfn ADD/EDIT --->
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->