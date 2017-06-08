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

<cfparam name="ID" default="">
<cfparam name="pgfn" default="">

<!--- param a/e form fields --->
<cfparam name="ID" default="">	
<cfparam name="company_name" default="">
<cfparam name="program_name" default="">
<cfparam name="date_expiration" default="">
<cfparam name="is_one_item" default="">
<cfparam name="has_survey" default="">
<cfparam name="is_active" default="">
<cfparam name="has_password_recovery" default="">
<cfparam name="is_henkel" default="">
<cfparam name="use_master_categories" default="1">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>

	<cfif date_expiration EQ "">
		<cfset date_expiration = DateFormat(DateAdd('yyyy',1,Now()),'yyyy-mm-dd')>
	</cfif>

	<!--- update --->
	<cfif form.ID IS NOT "" AND pgfn EQ "edit">
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.program
			SET	company_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#company_name#" maxlength="32">, 
				program_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#program_name#" maxlength="50">,
				expiration_date = <cfqueryparam cfsqltype="cf_sql_date" value="#date_expiration#">,
				is_one_item = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_one_item#" maxlength="1">,
				has_survey = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_survey#" maxlength="1">,
				has_password_recovery = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_password_recovery#" maxlength="1">,
				use_master_categories = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#use_master_categories#" maxlength="1">,
				is_henkel = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_henkel#" maxlength="1">,
				is_active = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_active#" maxlength="1">
				#FLGen_UpdateModConcatSQL()#
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelse>
		<cflock name="programLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#">
					INSERT INTO #application.database#.program
						(created_user_ID, created_datetime, company_name, program_name, expiration_date, is_one_item, has_survey, is_active, has_password_recovery, use_master_categories, is_henkel)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, 		
						'#FLGen_DateTimeToMySQL()#', 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#company_name#" maxlength="32">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#program_name#" maxlength="50">, 
						<cfqueryparam cfsqltype="cf_sql_date" value="#date_expiration#">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_one_item#" maxlength="1">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_survey#" maxlength="1">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_active#" maxlength="1">,
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_password_recovery#" maxlength="1">,
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#use_master_categories#" maxlength="1">,
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_henkel#" maxlength="1">
					)
				</cfquery>
				<cfquery name="getID" datasource="#application.DS#">
					SELECT Max(ID) As MaxID FROM #application.database#.program
				</cfquery>
				<cfset ID = getID.MaxID>
			</cftransaction>  
		</cflock>
	</cfif>
	<cflocation addtoken="no" url="program_details.cfm?ID=#ID#">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">

<cfoutput>
<span class="pagetitle"><cfif pgfn EQ "add">Add<cfelseif pgfn EQ "edit">Edit<cfelse>Copy</cfif> an Award Program</span>
<br /><br />
<span class="pageinstructions">Return to <a href="program_details.cfm?&id=#ID#">Award Program Details</a> or <a href="program_list.cfm">Award Program List</a> without making changes.</span>
<br /><br />
</cfoutput>

<cfif pgfn EQ "edit" OR pgfn EQ "copy">
	<cfquery name="ToBeEdited" datasource="#application.DS#">
		SELECT ID, company_name, program_name, expiration_date, is_one_item, has_survey, is_active, has_password_recovery, is_henkel, use_master_categories
		FROM #application.database#.program
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
	<cfset ID = ToBeEdited.ID>
	<cfset company_name = htmleditformat(ToBeEdited.company_name)>
	<cfset program_name = htmleditformat(ToBeEdited.program_name)>
	<cfset date_expiration = FLGen_DateTimeToDisplay(htmleditformat(ToBeEdited.expiration_date))>
	<cfset is_one_item = htmleditformat(ToBeEdited.is_one_item)>
	<cfset has_survey = htmleditformat(ToBeEdited.has_survey)>
	<cfset is_active = htmleditformat(ToBeEdited.is_active)>
	<cfset has_password_recovery = htmleditformat(ToBeEdited.has_password_recovery)>
	<cfset is_henkel = htmleditformat(ToBeEdited.is_henkel)>
	<cfset use_master_categories = htmleditformat(ToBeEdited.use_master_categories)>
</cfif>

<cfoutput>
<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext">General Information</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Award Program Company Name*: </td>
	<td valign="top"><input type="text" name="company_name" value="<cfif pgfn eq 'copy'>COPY-</cfif>#company_name#" maxlength="32" size="40">
		<input type="hidden" name="company_name_required" value="You must enter an award program company name."></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Award Program Name <span class="sub">[admin only]</span>*: </td>
	<td valign="top"><input type="text" name="program_name" value="#program_name#" maxlength="32" size="40">
		<input type="hidden" name="program_name_required" value="You must enter an award program name."></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Is Active?*: </td>
	<td valign="top">
		<select name="is_active">
			<option value="0"<cfif pgfn EQ 'add'> selected<cfelseif is_active EQ 0> selected</cfif>>No
			<option value="1"<cfif pgfn NEQ 'add' AND is_active EQ 1> selected</cfif>>Yes
		</select>

	</td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Expiration Date*: </td>
	<td valign="top"><input type="text" name="date_expiration" value="#date_expiration#" maxlength="10" size="12"> <span class="sub">(Please use 4 digit years, for example: 3/2/2005.)</span>
	<input type="hidden" name="date_expiration_required" value="You must enter an expiration date."></td>
	</tr>
								
	<tr class="content">
	<td align="right" valign="top">Has a survey?*: </td>
	<td valign="top">
		<select name="has_survey">
			<option value="1"<cfif has_survey EQ 1> selected</cfif>>Yes
			<option value="0"<cfif has_survey EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">One-item program?*: </td>
	<td valign="top">
		<select name="is_one_item">
			<option value="0"<cfif is_one_item EQ 0> selected</cfif>>No
			<option value="1"<cfif is_one_item EQ 1> selected</cfif>>Yes
		</select>
	</td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Has password recovery?*: </td>
	<td valign="top">
		<select name="has_password_recovery">
			<option value="1"<cfif has_password_recovery EQ 1> selected</cfif>>Yes
			<option value="0"<cfif has_password_recovery EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Is a Henkel Program?*: </td>
	<td valign="top">
		<select name="is_henkel">
			<option value="1"<cfif is_henkel EQ 1> selected</cfif>>Yes
			<option value="0"<cfif is_henkel EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Category Style: </td>
	<td valign="top">
		<select name="use_master_categories">
			<option value="0"<cfif use_master_categories EQ 0> selected</cfif>>"Old Style" category buttons (master categories)</option>
			<option value="1"<cfif use_master_categories EQ 1> selected</cfif>>"Old Style" category buttons (search options)</option>
			<option value="2"<cfif use_master_categories EQ 2> selected</cfif>>"Stacked" category buttons (search options)</option>
			<option value="3"<cfif use_master_categories EQ 3> selected</cfif>>"New Style" category tabs (master categories)</option>
			<option value="4"<cfif use_master_categories EQ 4> selected</cfif>>"New Style" category tabs (search options)</option>
		</select>
	</td>
	</tr>

	<tr class="content">
	<td colspan="2" align="center">
	
	<input type="hidden" name="ID" value="#ID#">
	<input type="hidden" name="pgfn" value="#pgfn#">
			
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" >

	</td>
	</tr>
		
	</table>

</form>
</cfoutput>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->