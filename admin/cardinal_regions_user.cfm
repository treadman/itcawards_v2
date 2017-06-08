<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000043,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam  name="pgfn" default="list">
<cfparam name="alert_msg" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>

	<cfif IsDefined('form.FieldNames') AND Trim(form.FieldNames) IS NOT "">
		<cfloop list="#Form.FieldNames#" index="ThisFieldName">
			<cfif ThisFieldName contains "reg_" AND Evaluate(ThisFieldName) NEQ ''>
				<cfset ThisNewRegionID = Evaluate(ThisFieldName)>
				<cfset ThisProgramUserID = RemoveChars(ThisFieldName,1,4)>
				<!--- delete the entry for this program user --->
				<cfquery name="DeleteUserAccess" datasource="#application.DS#">
					DELETE FROM #application.database#.cardinal_health_region_lookup
					WHERE program_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ThisProgramUserID#" maxlength="10">
				</cfquery>
				<cfquery name="InsertLookups" datasource="#application.DS#">
					INSERT INTO #application.database#.cardinal_health_region_lookup
					(created_user_ID, created_datetime, program_user_ID, region_ID)
					VALUES
					(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, 
					'#FLGen_DateTimeToMySQL()#',
					<cfqueryparam cfsqltype="cf_sql_integer" value="#ThisProgramUserID#" maxlength="10">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#ThisNewRegionID#" maxlength="10">)
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

<cfset leftnavon = "cardinal_user_regions">
<cfinclude template="includes/header.cfm">

<cfif pgfn EQ "list">
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT up.ID AS program_user_ID, up.fname, up.lname, IFNULL(chr.region_name,' Unassigned') AS region_name 
		FROM #application.database#.program_user up 
			LEFT JOIN #application.database#.cardinal_health_region_lookup chrl ON up.ID = chrl.program_user_ID
			LEFT JOIN #application.database#.cardinal_health_region chr ON chrl.region_ID = chr.ID
		WHERE up.program_ID = 1000000022
		ORDER BY chr.region_name, up.lname
	</cfquery>
	<cfoutput>
	<span class="pagetitle">Cardinal Health Program User List</span>
	<br /><br />
	<span class="pageinstructions">Change <a href="#CurrentPage#?pgfn=edit">region assignments</a>.</span>
	<br /><br />
	</cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<!--- display found records --->
	<cfoutput query="SelectList" group="region_name">
		<tr class="contenthead">
		<td valign="top"><b>#htmleditformat(region_name)#</b></td>
		</tr>
		<cfoutput>	
		<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
		<td valign="top" style="padding-left:50px">#htmleditformat(fname)#&nbsp;#htmleditformat(lname)#</td>
		</tr>
		</cfoutput>
	</cfoutput>
	</table>
<cfelseif pgfn EQ "edit">
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT up.ID AS program_user_ID, up.fname, up.lname, IFNULL(chr.region_name,' Unassigned') AS region_name, chrl.region_ID AS this_region_ID  
		FROM #application.database#.program_user up 
			LEFT JOIN #application.database#.cardinal_health_region_lookup chrl ON up.ID = chrl.program_user_ID
			LEFT JOIN #application.database#.cardinal_health_region chr ON chrl.region_ID = chr.ID
		WHERE up.program_ID = 1000000022
		ORDER BY chr.region_name, up.lname
	</cfquery>
	<cfquery name="SelectRegions" datasource="#application.DS#">
		SELECT ID AS this_region_ID, region_name 
		FROM #application.database#.cardinal_health_region
		ORDER BY region_name
	</cfquery>
	<cfoutput>
	<span class="pagetitle">Cardinal Health Program User Region Assignment</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="<cfoutput>#CurrentPage#</cfoutput>">Program User List</a> without making changes.</span>
	<br /><br />
	</cfoutput>
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<!--- display found records --->
	<cfoutput query="SelectList" group="region_name">
		<tr class="contenthead">
		<td align="center" valign="top">&nbsp;</td>
		<td valign="top" width="100%"><strong>#htmleditformat(region_name)#</strong></td>
		</tr>
		<cfoutput>	
			<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
			<td align="center" valign="top">
				<select name="reg_#SelectList.program_user_ID#">
					<option value="">   --   </option>
				<cfloop query="SelectRegions">
					<option value="#SelectRegions.this_region_ID#">#region_name#</option>
				</cfloop>
				</select>
			</td>
			<td valign="top" style="padding-left:50px">#htmleditformat(fname)#&nbsp;#htmleditformat(lname)#</td>
			</tr>
		</cfoutput>
	</cfoutput>
	<tr class="content">
	<td colspan="2" align="center"><input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Assign Selected Regions"></td>
	</tr>
	</table>
	</form>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->