<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset  FLGen_HasAdminAccess(1000000014,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="x" default="">
<cfparam name="ThisProgramsCategories" default="">
<cfparam name="ThisProgramsCategoryIDs" default="">
<cfparam name="program_ID" default="">
<cfparam name="datasaved" default="no">
<cfparam name="counter" default="0">
<cfparam name="thischecked" default="0">
<cfparam name="thisradioed" default="0">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<!--- delete all the entries for this program --->
	<cfquery name="DeleteProgramCat" datasource="#application.DS#">
		DELETE FROM #application.database#.productvalue_program
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#" maxlength="10">
	</cfquery>
	<!--- loop through the form fields and do individual inserts --->
	<cfloop index="cr" from="1" to="#form.TotalRecords#">
		<cfset thisID = "CR" & cr & "_MASTER_ID">
		<cfset thisIDform = "form.cr" & cr & "_master_ID">
		<cfset thissortorderform = "form.cr" & cr & "_sortorder">
		<cfset thisdisplaynameform = "form.cr" & cr & "_displayname">
		<cfif ListContains(form.FieldNames,thisID)>
			<cfset thisIDform = Evaluate(thisIDform)>
			<cfset thissortorderform = Evaluate(thissortorderform)>
			<cfset thisdisplaynameform = Evaluate(thisdisplaynameform)>
			<cfquery name="InsertQuery" datasource="#application.DS#">
				INSERT INTO #application.database#.productvalue_program
					(created_user_ID, created_datetime, productvalue_master_ID, program_ID, displayname, sortorder)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, 
					'#FLGen_DateTimeToMySQL()#', 
					<cfqueryparam cfsqltype="cf_sql_integer" value="#thisIDform#" maxlength="10">, 
					<cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#" maxlength="10">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisdisplaynameform#" maxlength="45">, 
					<cfqueryparam cfsqltype="cf_sql_integer" value="#thissortorderform#" maxlength="5">
				)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- save the default category (or delete it) --->
	<cfif IsDefined('form.default_category') AND #form.default_category# IS NOT "">
		<!--- translate pv_m into pv_c (if can't = make null) --->
		<cfquery name="TranslateDefault" datasource="#application.DS#">
			SELECT ID AS pvp_ID
			FROM #application.database#.productvalue_program
			WHERE productvalue_master_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.default_category#" maxlength="10">
				AND program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#" maxlength="10">
		</cfquery>
		<cfset default_category = TranslateDefault.pvp_ID>
	<cfelse>
		<!--- not passed in form --->
		<cfset default_category = "">
	</cfif>
	<!--- update program (with null default category if empty) --->
	<cfquery name="UpdateProgramDefaultCategory" datasource="#application.DS#">
		UPDATE #application.database#.program
		SET	default_category = <cfqueryparam cfsqltype="cf_sql_integer" value="#default_category#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(default_category)))#">
		#FLGen_UpdateModConcatSQL()#
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.program_ID#" maxlength="10">
	</cfquery>
	<cfset datasaved = "yes">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">


<cfquery name="SelectMasterCategories" datasource="#application.DS#">
	SELECT ID, productvalue, sortorder
	FROM #application.product_database#.productvalue_master
	ORDER BY sortorder ASC
</cfquery>
	
<cfquery name="SelectProgramCategories" datasource="#application.DS#">
	SELECT ID, productvalue_master_ID, CONCAT(displayname," ") AS displayname, sortorder
	FROM #application.database#.productvalue_program
	WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
	ORDER BY sortorder ASC
</cfquery>

<cfquery name="SelectProgramInfo" datasource="#application.DS#">
	SELECT p.company_name AS company_name, p.program_name AS program_name, p.default_category AS default_category, pvp.productvalue_master_ID as default_pvp
	FROM #application.database#.program p
	LEFT JOIN #application.product_database#.productvalue_program pvp ON p.default_category = pvp.ID
	WHERE p.ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
</cfquery>

<cfloop query="SelectProgramCategories">
	<cfset ThisProgramsCategories = "#ThisProgramsCategories##SelectProgramCategories.productvalue_master_ID#^#SelectProgramCategories.displayname#^#SelectProgramCategories.sortorder#|">
	<cfset ThisProgramsCategoryIDs = "#ThisProgramsCategoryIDs##SelectProgramCategories.productvalue_master_ID#,">
	<cfif CurrentRow EQ SelectProgramCategories.RecordCount>
	 	<cfset ThisProgramsCategories = Left(ThisProgramsCategories,Len(ThisProgramsCategories)-1)>
	 	<cfset ThisProgramsCategoryIDs = Left(ThisProgramsCategoryIDs,Len(ThisProgramsCategories)-1)>
	</cfif>
</cfloop>
	
<span class="pagetitle">Program Categories</span>
<br /><br />
<span class="pageinstructions">Return to <a href="program.cfm">Award Program List</a> without making changes.</span>
<br /><br />

<cfif datasaved eq 'yes'>
	<span class="alert">The information was saved.</span><cfoutput>#FLGen_SubStamp()#</cfoutput>
	<br /><br />
</cfif>

<form method="post" action="<cfoutput>#CurrentPage#</cfoutput>">
	<table cellpadding="5" cellspacing="1" border="0">
	<tr class="content">
	<td colspan="5"><span class="headertext">Program: <span class="selecteditem"><cfoutput>#SelectProgramInfo.company_name# [#SelectProgramInfo.program_name#]</cfoutput></span></span></td>
	</tr>
	<tr class="contenthead">
	<td><span class="headertext">Master<br>Category</span></td>
	<td><span class="headertext">Include</span></td>
	<td><span class="headertext">Default</span></td>
	<td><span class="headertext">Sort Order</span></td>
	<td><span class="headertext">Display Name</span></td>
	</tr>
	<!---<cfoutput>#ThisProgramsCategoryIDs#<br><br>#ThisProgramsCategories#</cfoutput><cfabort>--->
	<cfoutput query="SelectMasterCategories">
		<!--- see if this this master category is in thisprogramscategories --->
		<cfif ListContains(ThisProgramsCategoryIDs, SelectMasterCategories.ID)>
			<cfset thischecked = " checked">
			<cfset thissortorder = ListGetAt(ListGetAt(ThisProgramsCategories,ListFindNoCase(ThisProgramsCategoryIDs,SelectMasterCategories.ID),"|"),3,"^")>
			<cfset thisdisplayname = ListGetAt(ListGetAt(ThisProgramsCategories,ListFindNoCase(ThisProgramsCategoryIDs,SelectMasterCategories.ID),"|"),2,"^")>	
		<cfelse>
			<cfset thischecked = "">
			<cfset thissortorder = SelectMasterCategories.sortorder>
			<cfset thisdisplayname = SelectMasterCategories.productvalue>		
		</cfif>
		<!--- check if this is the program's default category --->
		<cfif SelectProgramInfo.default_pvp EQ SelectMasterCategories.ID>
			<cfset thisradioed = " checked">
		<cfelse>
			<cfset thisradioed = "">
		</cfif>
		<tr class="<cfif thischecked NEQ "">selectedbgcolor<cfelse>#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))# </cfif>">
		<td>#SelectMasterCategories.productvalue#</td>
		<td><input type="checkbox" name="cr#CurrentRow#_master_ID" value="#SelectMasterCategories.ID#"#thischecked#></td>
		<td><cfif thischecked NEQ ""><input type="radio" name="default_category" value="#SelectMasterCategories.ID#"#thisradioed#><cfif #thisradioed# NEQ ""><span class="selecteditem"> default</span></cfif><cfelse>&nbsp;</cfif></td>
		<td><input type="text" name="cr#CurrentRow#_sortorder" value="#HTMLEditFormat(thissortorder)#" maxlength="5" size="7"></td>
		<td><input type="text" name="cr#CurrentRow#_displayname" value="#HTMLEditFormat(thisdisplayname)#" maxlength="45" size="22"></td>
		</tr>
	</cfoutput>
	<tr class="content">
	<td colspan="5" align="center">
	<cfoutput>
	<input type="hidden" name="program_ID" value="#program_ID#">
	<input type="hidden" name="TotalRecords" value="#SelectMasterCategories.RecordCount#">
	</cfoutput>
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save All Changes" >
	</td>
	</tr>

	</table>
</form>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->