<cfif NOT isDefined("userID") OR userID LTE 0>
	<cflocation url="admin_user.cfm" addtoken="no">
</cfif>

<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000030,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="x" default="">
<cfparam name="datasaved" default="no">
<cfparam name="currentrow" default=0>
<cfparam name="accessred" default="">
<cfparam name="checkaccess" default="">
<cfparam name="vGetThisAccess" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<!--- delete all the entries for this user --->
	<cfquery name="DeleteUserAccess" datasource="#application.DS#">
		DELETE FROM #application.database#.admin_lookup
		WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.userid#" maxlength="10">
	</cfquery>
	<!--- loop through the form fields and do individual inserts --->
	<cfloop index="lc" from="1" to="#form.TotalRecords#">
		<cfset thisID = "LC" & lc & "_ID">
		<cfset thisIDform = "form.LC" & lc & "_ID">
		<cfif ListContains(form.FieldNames,thisID)>
			<cfset thisIDform = Evaluate(thisIDform)>
			<cfquery name="InsertQuery" datasource="#application.DS#">
				INSERT INTO #application.database#.admin_lookup
				(created_user_ID, created_datetime, user_ID, access_level_ID)
				VALUES
				(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#', <cfqueryparam cfsqltype="cf_sql_integer" value="#userID#" maxlength="10">, <cfqueryparam cfsqltype="cf_sql_integer" value="#thisIDform#" maxlength="10">)
			</cfquery>
		</cfif>
	</cfloop>
	<cfset datasaved = "yes">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "admin_users">
<cfinclude template="includes/header.cfm">

<cfquery name="SelectUserInfo" datasource="#application.DS#">
	SELECT firstname, lastname
	FROM #application.database#.admin_users
	WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userID#" maxlength="10">
</cfquery>

<!--- if no user is found, send back to user page --->
<cfif SelectUserInfo.RecordCount EQ 0><cflocation url="admin_user.cfm" addtoken="no"></cfif>

<cfquery name="SelectList" datasource="#application.DS#">
	SELECT ID, level_name, sortorder, IFNULL(note,"(no note)") AS note, sortorder
	FROM #application.database#.admin_level
	WHERE note <> 'NOT USED YET' 
	ORDER BY sortorder ASC
</cfquery>

<!--- look in adminaccess db for current user access levels --->
<cfquery name="GetThisAccess" datasource="#application.DS#">
	SELECT access_level_ID
	FROM #application.database#.admin_lookup
	WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userID#" maxlength="10">
</cfquery>

<cfparam name="vGetThisAccess" default="">

<cfloop query="GetThisAccess">
	<cfset vGetThisAccess = #vGetThisAccess# & " " & #GetThisAccess.access_level_ID#>
</cfloop>

<cfoutput>
<span class="pagetitle">Assign Admin Access</span>
<br /><br />
<span class="pageinstructions">Current access level assignments are in bold below.</span>
<br /><br />
<span class="pageinstructions">Return to <a href="admin_user.cfm">Admin User List</a> without making changes.</span>
<br /><br />
</cfoutput>

<cfif datasaved EQ "yes">
<span class="alert">The information was saved.</span><cfoutput>#FLGen_SubStamp()#</cfoutput>
<br /><br />
</cfif>

<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<cfoutput>
	<tr class="content">
	<td colspan="4"><span class="headertext">Admin User: <span class="selecteditem">#HTMLEditFormat(SelectUserInfo.firstname)# #SelectUserInfo.lastname#</span></span></td>
	</tr>
	</cfoutput>
	
	<tr class="contenthead">
	<td><span class="headertext">&nbsp;</span></td>
	<td><span class="headertext">Code&nbsp;Number</span></td>
	<td width="175"><span class="headertext">Level Name</span></td>
	<td><span class="headertext">[Sort&nbsp;Order] Note</span></td>
	</tr>
	
	<cfoutput query="SelectList">

	<cfif note EQ 'header'>
	
	<tr class="contentsearch">
	<td colspan="4" class="headertext">#HTMLEditFormat(level_name)# <span class="sub">[#HTMLEditFormat(sortorder)#]</span></td>
	</tr>
	
	<cfelse>

	<cfif FLGen_HasAdminAccess(SelectList.ID,false,vGetThisAccess)>
		<cfset checkaccess = " checked">
	<cfelse>
		<cfset checkaccess = "">
	</cfif>

	<tr class="<cfif checkaccess NEQ "">selectedbgcolor<cfelse>#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))# </cfif>">
	<td valign="top"><input type="checkbox" name="lc#currentrow#_ID" value="#ID#"#checkaccess#></td>
	<td valign="top">#ID#</td>
	<td valign="top">#HTMLEditFormat(level_name)#</td>
	<td valign="top"><span class="sub">[ #HTMLEditFormat(sortorder)# ]</span> #Replace(HTMLEditFormat(note),chr(10),"<br>","ALL")#</td>
	</tr>
	
	</cfif>
	
	</cfoutput>

	<tr class="content">
	<td colspan="4" align="center">
	
	<cfoutput>
	<input type="hidden" name="TotalRecords" value="#SelectList.RecordCount#">
	<input type="hidden" name="userid" value="#userid#">
	</cfoutput>
	
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Assign Checked Access Levels">
	
	</td>
	</tr>

	</table>

</form>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->