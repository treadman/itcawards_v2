<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000042,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam  name="pgfn" default="list">
<cfparam name="alert_msg" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<!--- delete all the entries for this user --->
	<cfquery name="DeleteUserAccess" datasource="#application.DS#">
		DELETE FROM #application.database#.cardinal_health_region_lookup
		WHERE admin_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.admin_user_ID#" maxlength="10">
	</cfquery>
	<cfif IsDefined('form.FieldNames') AND Trim(form.FieldNames) IS NOT "">
		<cfloop list="#Form.FieldNames#" index="ThisFieldName">
			<cfif ThisFieldName contains "reg_" AND Evaluate(ThisFieldName) NEQ ''>
				<cfset ThisRegionID = RemoveChars(ThisFieldName,1,4)>
 				<cfquery name="InsertLookups" datasource="#application.DS#">
					INSERT INTO #application.database#.cardinal_health_region_lookup
					(created_user_ID, created_datetime, admin_user_ID, region_ID)
					VALUES
					(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, 
					'#FLGen_DateTimeToMySQL()#',
					<cfqueryparam cfsqltype="cf_sql_integer" value="#form.admin_user_ID#" maxlength="10">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#ThisRegionID#" maxlength="10">)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<cfset alert_msg = "The new region assignments were saved.">
	<cfset pgfn = "list">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "cardinal_admin_regions">
<cfinclude template="includes/header.cfm">

<cfif pgfn EQ "list">
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID AS admin_user_ID, firstname, lastname
		FROM #application.database#.admin_users
		WHERE program_ID = 1000000009 OR  program_ID = 1000000022 OR  program_ID = 1000000001
		ORDER BY lastname
	</cfquery>
	<span class="pagetitle">Admin User List</span>
	<br /><br />
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<!--- header row --->
	<tr class="contenthead">
		<td align="center">&nbsp;</td>
		<td><span class="headertext">Admin User</span> <img src="../pics/contrls-asc.gif" width="7" height="6"></td>
		<td width="100%">Regions Currently Assigned</td>
	</tr>
	<!--- display found records --->
	<cfoutput query="SelectList">
		<cfquery name="FindRegions" datasource="#application.DS#">
			SELECT chr.region_name
			FROM #application.database#.cardinal_health_region chr
			JOIN #application.database#.cardinal_health_region_lookup chrl ON chr.ID = chrl.region_ID 
			WHERE chrl.admin_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#admin_user_ID#" maxlength="10">
		</cfquery>
		<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
		<td align="center" valign="top"><a href="#CurrentPage#?pgfn=edit&admin_user_ID=#admin_user_ID#">manage&nbsp;regions</a></td>
		<td valign="top">#htmleditformat(firstname)#&nbsp;#htmleditformat(lastname)#</td>
		<td valign="top" width="100%">
		<cfloop query="FindRegions">#region_name#<br></cfloop><cfif FindRegions.RecordCount EQ 0><span class="sub">(none)</span></cfif>
		</td>
		</tr>
	</cfoutput>
	</table>
<cfelseif pgfn EQ "edit">
	<cfquery name="SelectUserInfo" datasource="#application.DS#">
		SELECT firstname, lastname
		FROM #application.database#.admin_users
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#admin_user_ID#" maxlength="10">
	</cfquery>
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID AS region_ID, region_name 
		FROM #application.database#.cardinal_health_region
		ORDER BY region_name ASC
	</cfquery>
	<!--- look in adminaccess db for current user access levels --->
	<cfquery name="GetThisAccess" datasource="#application.DS#">
		SELECT chr.ID 
		FROM #application.database#.cardinal_health_region chr
		JOIN #application.database#.cardinal_health_region_lookup chrl ON chr.ID = chrl.region_ID 
		WHERE chrl.admin_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#admin_user_ID#" maxlength="10">
	</cfquery>
	<cfparam name="vGetThisAccess" default="">
	<cfloop query="GetThisAccess">
		<cfset vGetThisAccess = #vGetThisAccess# & " " & #GetThisAccess.ID#>
	</cfloop>
	<cfoutput>
	<span class="pagetitle">Assign Cardinal Health Regions to an Admin User</span>
	<br /><br />
	<span class="pageinstructions">Current access level assignments are in highlighted below.</span>
	<br /><br />
	<span class="pageinstructions">You must also assign the cooresponding access level to the admin on the <a href="admin_user.cfm">Assign Access</a> page.</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="#CurrentPage#">Admin User List</a> without making changes.</span>
	<br /><br />
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="content">
	<td colspan="4"><span class="headertext">Admin User: <span class="selecteditem">#HTMLEditFormat(SelectUserInfo.firstname)# #SelectUserInfo.lastname#</span></span></td>
	</tr>
	</cfoutput>
	<tr class="contenthead">
	<td><span class="headertext">&nbsp;</span></td>
	<td width="100%"><span class="headertext">Region</span></td>
	</tr>
	<cfoutput query="SelectList">
		<cfif FLGen_HasAdminAccess(SelectList.region_ID,false,vGetThisAccess)>
			<cfset checkaccess = " checked">
		<cfelse>
			<cfset checkaccess = "">
		</cfif>
		<tr class="<cfif checkaccess NEQ "">selectedbgcolor<cfelse>#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))# </cfif>">
		<td valign="top"><input type="checkbox" name="reg_#region_ID#" value="#region_ID#"#checkaccess#></td>
		<td valign="top">#region_name#</td>
		</tr>
	</cfoutput>
	<tr class="content">
	<td colspan="2" align="center">
	<cfoutput>
	<input type="hidden" name="admin_user_ID" value="#admin_user_ID#">
	</cfoutput>
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Assign Checked Regions">
	</td>
	</tr>
	</table>
	</form>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->