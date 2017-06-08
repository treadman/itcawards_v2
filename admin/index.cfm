<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfif FLGen_AuthenticateAdmin() EQ true>
	<cfset pgfn = "welcome">
</cfif>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="username" default="">
<cfparam name="tryagain" default="no">
<cfparam name="HashedPassword" default="">
<cfparam name="nomatch" default="no">
<cfparam name="pgfn" default="login">
<cfparam name="sUserAccess" default="">
<cfparam name="adminloginIDhash" default="">
<cfparam name="logout" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit') OR isDefined('url.i')>
	<cfset login_sso = "">
	<cfif isDefined('url.i')>
		<!--- First check if time stamp is ok --->
		<cfset date_ok = false>
		<cfset today_date = now()>
		<cfset admin_datehash = mid(url.i,1,4)&mid(url.i,9,4)&mid(url.i,17,4)&mid(url.i,25,4)&mid(url.i,33,4)&mid(url.i,41,4)&mid(url.i,49,4)&mid(url.i,57,4)>
		<cfloop from="0" to="1" index="i">
			<cfset local_datehash = hash(dateformat(dateadd('n',-i,today_date),'mmmm d yyyy ') & timeformat(dateadd('n',-i,today_date),'HHmm'),'MD5') >
			<cfif admin_datehash EQ local_datehash>
				<cfset date_ok = true>
				<cfbreak>
			<cfelse>
			</cfif>
		</cfloop>

		<!--- Next see if there are any active admins that match --->
		<cfif date_ok>
			<cfset admin_userhash = mid(url.i,5,4)&mid(url.i,13,4)&mid(url.i,21,4)&mid(url.i,29,4)&mid(url.i,37,4)&mid(url.i,45,4)&mid(url.i,53,4)&mid(url.i,61,4)>
			<cfquery name="GetAdmins" datasource="#application.DS#">
				SELECT username
				FROM #application.database#.admin_users
				WHERE is_active = 1
			</cfquery>
			<cfloop query="GetAdmins">
				<cfset local_userhash = hash(GetAdmins.username,'MD5')>
				<cfif admin_userhash EQ local_userhash>
					<cfset login_sso = GetAdmins.username>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif> 
	</cfif>

 	<cfif login_sso NEQ "" OR (IsDefined('form.username') AND form.username IS NOT "" AND IsDefined('form.password') AND form.password IS NOT "")>
	
		<!--- hash the password --->
		<cfif login_sso EQ "">
			<cfset HashedPassword = FLGen_CreateHash(Lcase(form.password))>
			<cfset ThisUsername = form.username>
		<cfelse>
			<cfset ThisUsername = login_sso>
		</cfif>

		<!--- check the database for the username hash match --->
		<cfquery name="CheckLogin" datasource="#application.DS#">
			SELECT ID, IFNULL(program_ID,0) AS program_ID, firstname
			FROM #application.database#.admin_users
			WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ThisUsername#" maxlength="32">
			AND is_active = 1
			<cfif login_sso EQ "">
				AND password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#HashedPassword#">
			</cfif> 
		</cfquery>
		<cfif CheckLogin.RecordCount IS 0>
			<cfset nomatch = "yes">
			<cfset username = #form.username#>
		<cfelse>
		
			<!--- SET PROGRAM INFO, if assigned to a program --->
			<cfif CheckLogin.program_ID NEQ 0>
				<!--- hash program ID and save cookie --->
				<cfset HashedProgramID = #FLGen_CreateHash(CheckLogin.program_ID)#>
				<cfcookie name="itc_program" value="#CheckLogin.program_ID#-#HashedProgramID#">
				<cfcookie name="admin_name" value="#CheckLogin.firstname#">
				<cfset request.is_admin = false>
				<cfset request.selected_program_ID = CheckLogin.program_ID>
				<cfif CheckLogin.program_ID EQ '1000000001'>
					<cfset request.is_admin = true>
					<cfset request.selected_program_ID = 0>
				</cfif>
			</cfif>
		
			<!--- grab the user's admin access levels and save in var --->
			<cfquery name="GetAccess" datasource="#application.DS#">
				SELECT access_level_ID
				FROM #application.database#.admin_lookup
				WHERE user_ID = '#CheckLogin.ID#'
			</cfquery>
			<cfloop query="GetAccess">
				<cfset sUserAccess = #sUserAccess# & " " & #GetAccess.access_level_ID#>
			</cfloop>
				
			<!--- entry into admin_login table, get ID --->
			<cflock name="admin_loginLock" timeout="10">
				<cftransaction>
					<cfset aToday = FLGen_DateTimeToMySQL()>
					<cfquery datasource="#application.DS#" name="InsertLogin">
						INSERT INTO #application.database#.admin_login (created_user_ID, created_datetime) 
						VALUES ('#CheckLogin.ID#', '#aToday#')
					</cfquery>
					<cfquery datasource="#application.DS#" name="getPK">
						SELECT Max(ID) As MaxID FROM #application.database#.admin_login
					</cfquery>
				</cftransaction>  
			</cflock>

			<!--- hash admin_login ID --->	
			<cfset adminloginIDhash = FLGen_CreateHash(getPK.MaxID)>
			<!--- write cookies --->
		 	<cfcookie name="admin_login" value="#getPK.MaxID#-#adminloginIDhash#">

			<!--- this page becomes the welcome page --->
			<cfif FLGen_AuthenticateAdmin()>
				<cfset pgfn = "welcome">
			</cfif>
		</cfif>
	<cfelse>
		<cfset tryagain = "yes">
	</cfif>
 
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfinclude template="includes/header.cfm">

<cfswitch expression = "#pgfn#">
	<cfcase value="login">
		<table cellpadding="5" cellspacing="0" width="900" border="0">
			<tr>
				<td valign="top" width="150">&nbsp;</td>
				<td valign="top" width="30">&nbsp;</td>
				<td valign="top">
					<cfif IsDefined('cookie.itc_program') AND cookie.itc_program IS NOT "">
						<br /><cfoutput>#GetProgramInfo()#<img src="../pics/program/#vLogo#"></cfoutput><br />
					</cfif>
					<br /><span class="pagetitle">Administrative Login</span><br /><br />
					<span class="pageinstructions">If you have forgotten your password, please contact</span><br />
					<span class="pageinstructions">another administrative user to reset it for you.</span><br /><br />
					<cfif tryagain IS "yes">
						<span class="alert">You must enter a username and a password.</span><br /><br />
					</cfif>
					<cfif nomatch IS "yes">
						<span class="alert">That is an invalid username and password.</span><br /><br />
					</cfif>
					<cfif logout IS "y">
						<span class="alert">You have been logged out.</span><br /><br />
					</cfif>
					<cfoutput>
					<form method="post" action="#application.SecureWebPath#/admin/index.cfm">
						<table cellpadding="5" cellspacing="1" border="0">
							<tr class="contenthead">
								<td colspan="2">Login</td>
							</tr>
							<tr class="content">
								<td align="right">username: </td>
								<td><input type="text" maxlength="32" size="32" name="username" value="#HTMLEditFormat(username)#"></td>
							</tr>
							<tr class="content">
								<td align="right">password: </td>
								<td><input type="password" maxlength="20" size="32" name="password"></td>
							</tr>
							<tr class="content">
								<td colspan="2" align="center"><input type="submit" name="submit" value="Login" ></td>
							</tr>
						</table>
					</form>
					</cfoutput>
				</td>
			</tr>
		</table>
	</cfcase>
	<cfcase value="welcome">
		<cfset leftnavon = "index">
		<table cellpadding="5" cellspacing="0" width="800" border="0">
			<tr>
				<td valign="top" width="170" class="leftnav"><cfinclude template="includes/leftnav.cfm"></td>
				<td valign="top" width="25">&nbsp;</td>
				<td valign="top" width="575">
					<span class="pagetitle"><br><br>Welcome to the ITC Award Program Administration System.</span><br><br>
					<!--- <br /><span class="pagetitle">Admin Tips &amp; Hints</span><br /><br />
					<b>( 1 )</b> When you see a confirmation message, it might be followed by some numbers in brackets:<br /><br />
					<span class="pageinstructions"><span class="alert">Your changes were saved.</span><cfoutput>#FLGen_SubStamp()#</cfoutput></span><br /><br />
					This is the minute and second that your changes were saved.  If you make another change on the page while the save message is displayed the number will change to indicate that your new changes were saved, too.  To see this in action, look at the number above and then click Refresh on your browser.  Notice that the number above changed.<br /><br />
					<b>( 2 )</b> The meanings of the colors in this application:
					<ul>
						<li>This indicates a <span class="selecteditem">selected  item</span>.<br /><br /></li>
						<li>This indicates a <span class="selectedbgcolor">selected or active item</span>.<br /><br /></li>
						<li>This indicates a <span class="inactivebg">disabled or inactive item</span>.<br /><br /></li>
						<li>This indicates a <span class="alert">alert or confirmation</span>.</li>
					</ul>
					<b>( 3 )</b> ---> Tool Tip Help<br /><br />
					Text or a question mark in an orange box will provide more information when you place your cursor over the box and wait for the tool tip to appear.  You will know that the box has a tool tip because the cursor will change to an arrow with a question mark.<br /><br />
					<span class="tooltip" title="This is a working tool tip.">yes</span>&nbsp;&nbsp;&nbsp;<span class="tooltip" title="This tool tip would give you additional information.">?</span>&nbsp;&nbsp;&nbsp;Try these examples.<br /><br />
				</td>
			</tr>
		</table>
	</cfcase>
</cfswitch>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->