<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->

<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000033,true)>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "adminaccessreport">
<cfset request.main_width = 1400>
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Admin Access Report</span>
<br /><br />
<span class="pageinstructions">Place your cursor over the user's initials to see their full name.</span>
<br /><br />

<cfquery name="AdminLevels" datasource="#application.DS#">
	SELECT level_name, ID AS adminlevelID, note 
	FROM #application.database#.admin_level
	ORDER BY sortorder
</cfquery>

<cfquery name="AdminUsers" datasource="#application.DS#">
	SELECT firstname, lastname, ID  
	FROM #application.database#.admin_users
</cfquery>

<cfset UserIDs = ValueList(AdminUsers.ID)>

<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="contenthead">
		<td><span class="headertext">Admin Level</span></td>
		<cfoutput query="AdminUsers">
			<td align="center"><span title=" #firstname# #lastname# " class="tooltip">#RemoveChars(firstname,2,Len(firstname))##RemoveChars(lastname,2,Len(lastname))#</span></td>
		</cfoutput>
	</tr>
	<cfoutput query="AdminLevels">
		<cfif note EQ 'header'>
			<tr>
				<td colspan="#ListLen(UserIDs) + 1#" class="content2"><span class="headertext">#level_name#</span></td>
			</tr>
		<cfelse>
			<cfquery name="WhichAccess" datasource="#application.DS#">
				SELECT user_ID  
				FROM #application.database#.admin_lookup
				WHERE access_level_ID = #adminlevelID#
			</cfquery>
			<cfset WhichAccessIDs = ValueList(WhichAccess.user_ID)>
			<tr class="content">
				<td>#level_name#</td>
				<cfloop list="#UserIDs#" index="thisID">
					<td align="center"><cfif ListFind(WhichAccessIDs,thisID)><b>X</b><cfelse>&nbsp;</cfif></td>
				</cfloop>
			</tr>
		</cfif>
	</cfoutput>
</table>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->