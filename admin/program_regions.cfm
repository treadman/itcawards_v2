<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000056,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="x" default="">
<cfparam name="where_string" default="">
<cfparam name="ID" default="">
<cfparam name="alert_msg" default="">
<cfparam name="delete" default="">

<!--- param search criteria xS=ColumnSort xT=SearchString xL=Letter --->
<cfparam name="xS" default="vendor">
<cfparam name="xT" default="">
<cfparam name="xL" default="">

<!--- param a/e form fields --->
<cfparam name="region_ID" default="">	
<cfparam name="region_name" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<!--- update --->
	<cfif form.pgfn EQ "edit">
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.program_region
			SET	region_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.region_name#" maxlength="75">
				#FLGen_UpdateModConcatSQL()#
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.region_ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelseif form.pgfn EQ "add">
		<cflock name="program_regionLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#">
					INSERT INTO #application.database#.program_region
						(created_user_ID, created_datetime, region_name)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#', 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.region_name#" maxlength="75">
					)
				</cfquery>
				<cfquery name="getID" datasource="#application.DS#">
					SELECT Max(ID) As MaxID FROM #application.database#.program_region
				</cfquery>
				<cfset region_ID = getID.MaxID>
			</cftransaction>  
		</cflock>
	</cfif>
	<cfset alert_msg = "The information was saved.">
	<cfset pgfn = "list">
<cfelseif delete NEQ '' AND FLGen_HasAdminAccess(1000000057)>
	<cfquery name="DeleteRegion" datasource="#application.DS#">
		DELETE FROM #application.database#.program_region
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#" maxlength="10">
	</cfquery>			
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "program_regions">
<cfinclude template="includes/header.cfm">

<cfparam  name="pgfn" default="list">

<!--- START pgfn LIST --->
<cfif pgfn EQ "list">
	<!--- run query --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID AS region_ID, region_name  
		FROM #application.database#.program_region
		ORDER BY region_name ASC
	</cfquery>
	<span class="pagetitle">Region List</span>
	<br /><br />
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<!--- header row --->
		<tr class="contenthead">
			<td align="center"><a href="<cfoutput>#CurrentPage#</cfoutput>?pgfn=add">Add</a></td>
			<td width="100%"><span class="headertext">Region</span> <img src="../pics/contrls-asc.gif" width="7" height="6"></td>
		</tr>
		<!--- if no records --->
		<cfif SelectList.RecordCount IS 0>
			<tr class="content2">
				<td colspan="2" align="center"><span class="alert"><br>No records found.  Click "Add" to create a region.<br><br></span></td>
			</tr>
		<cfelse>
			<!--- display found records --->
			<cfoutput query="SelectList">
				<cfset show_delete = true>
				<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
					<td><a href="#CurrentPage#?pgfn=edit&region_ID=#region_ID#">Edit</a><cfif FLGen_HasAdminAccess(1000000057) AND show_delete>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?delete=#region_ID#" onclick="return confirm('Are you sure you want to delete this region?  There is NO UNDO.')">Delete</a></cfif></td>
					<td valign="top" width="100%">#htmleditformat(region_name)#</td>
				</tr>
			</cfoutput>
		</cfif>
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit">
	<!--- START pgfn ADD/EDIT --->
	<span class="pagetitle"><cfif pgfn EQ "add" OR pgfn EQ "copy">Add<cfelse>Edit</cfif> a Region</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="<cfoutput>#CurrentPage#</cfoutput>">Region List</a> without making changes.</span>
	<br /><br />
	<cfif pgfn EQ "edit">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT region_name  
			FROM #application.database#.program_region
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#region_ID#" maxlength="10">
		</cfquery>
		<cfset region_name = htmleditformat(ToBeEdited.region_name)>
	</cfif>
	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
			<tr class="contenthead">
				<td colspan="2" class="headertext"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Region</td>
			</tr>
			<tr class="content">
				<td align="right" valign="top">Region Name: </td>
				<td valign="top"><input type="text" name="region_name" value="#region_name#" maxlength="75" size="60"></td>
			</tr>
			<tr class="content">
				<td colspan="2" align="center">
					<input type="hidden" name="region_ID" value="#region_ID#">
					<input type="hidden" name="pgfn" value="#pgfn#">
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