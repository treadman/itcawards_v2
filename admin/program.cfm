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
<cfparam name="where_string" default="">
<cfparam name="ID" default="">
<cfparam name="datasaved" default="no">
<cfparam name="delete" default="">

<!--- param search criteria xS=ColumnSort xT=SearchString xL=Letter --->
<cfparam name="xS" default="program">
<cfparam name="xT" default="">
<cfparam name="xL" default="">
<cfparam name="OnPage" default="">

<!--- param a/e form fields --->
<cfparam name="ID" default="">	
<cfparam  name="pgfn" default="list">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<!--- massage form data --->
	<cfif orders_from EQ "">
		<cfset orders_from = "#application.AwardsFromEmail#">
	</cfif>
	<!--- update --->
	<cfif form.ID IS NOT "" AND pgfn EQ "edit">
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.program
			SET	#FLGen_UpdateModConcatSQL()#
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelse>
		<cflock name="programLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#">
					INSERT INTO #application.database#.program
						(created_user_ID, created_datetime, can_defer, defer_msg, logo, cross_color, main_bg, main_congrats, main_instructions, return_button, text_active, bg_active, text_selected, bg_selected, cart_exceeded_msg, cc_exceeded_msg, orders_to, orders_from, conf_email_text, program_email_subject, display_col, display_row, menu_text, credit_desc, accepts_cc, login_prompt, display_welcomeyourname, display_youhavexcredits, credit_multiplier, points_multiplier)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, 		
						'#FLGen_DateTimeToMySQL()#', 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#can_defer#" maxlength="1">, 
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#defer_msg#"  null="#YesNoFormat(NOT Len(Trim(logo)))#">,  
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#logo#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(logo)))#">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#cross_color#" maxlength="6" null="#YesNoFormat(NOT Len(Trim(cross_color)))#">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#main_bg#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(main_bg)))#">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#main_congrats#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(main_congrats)))#">, 
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#main_instructions#" null="#YesNoFormat(NOT Len(Trim(main_instructions)))#">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#return_button#" maxlength="30">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#text_active#" maxlength="6">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#bg_active#" maxlength="6">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#text_selected#" maxlength="6">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#bg_selected#" maxlength="6">, 
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#cart_exceeded_msg#">, 
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#cc_exceeded_msg#" null="#YesNoFormat(NOT Len(Trim(cc_exceeded_msg)))#">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#orders_to#" maxlength="128">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#orders_from#" maxlength="64">,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#conf_email_text#" null="#YesNoFormat(NOT Len(Trim(conf_email_text)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#program_email_subject#" maxlength="50">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#display_col#" maxlength="2">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#display_row#" maxlength="2">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#menu_text#" maxlength="40">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#credit_desc#" maxlength="40">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#accepts_cc#" maxlength="1">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#login_prompt#" maxlength="120">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#display_welcomeyourname#" maxlength="1">,
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#display_youhavexcredits#" maxlength="1">,
						<cfqueryparam cfsqltype="cf_sql_float" value="#credit_multiplier#" scale="2">,
						<cfqueryparam cfsqltype="cf_sql_float" value="#points_multiplier#" scale="2">
					)
				</cfquery>
				<cfquery name="getID" datasource="#application.DS#">
					SELECT Max(ID) As MaxID FROM #application.database#.program
				</cfquery>
				<cfset ID = getID.MaxID>
			</cftransaction>  
		</cflock>
	</cfif>
	<cfset datasaved = "yes">
	<cfset pgfn = "edit">
<cfelseif delete NEQ '' AND FLGen_HasAdminAccess(1000000051)>
	<cfquery name="DeleteGroup" datasource="#application.DS#">
		DELETE FROM #application.database#.program
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#" maxlength="10">
	</cfquery>			
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<SCRIPT LANGUAGE="JavaScript"><!-- 
function openURL() { 
	// grab index number of the selected option
	selInd = document.pageform.pageselect.selectedIndex; 
	// get value of the selected option
	goURL = document.pageform.pageselect.options[selInd].value;
	// redirect browser to the grabbed value (hopefully a URL)
	top.location.href = goURL; 
}
//--></SCRIPT>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">

<!--- START pgfn LIST --->
<cfif pgfn EQ "list">

	<cflocation url="program_list.cfm" addtoken="no">
	
<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit" OR pgfn EQ "copy">
	<!--- START pgfn ADD/EDIT --->
	<cfoutput>
	<span class="pagetitle"><cfif pgfn EQ "add">Add<cfelseif pgfn EQ "edit">Edit<cfelse>Copy</cfif> an Award Program</span>
	<br />
	<br />
	<cfif datasaved eq 'yes'>
		<span class="pageinstructions"><a href="#CurrentPage#?pgfn=add&&xL=#xL#&xT=#xT#&OnPage=#OnPage#">Add</a> a new Award Program.</span>
		<br /><br />
	</cfif>
	<span class="pageinstructions">Return to <a href="program_details.cfm?&id=#ID#">Award Program Details</a> or <a href="program_list.cfm?&xL=#xL#&xT=#xT#&OnPage=#OnPage#">Award Program List</a> without making changes.</span>
	<br /><br />
	</cfoutput>
	<br />
	<cfif datasaved eq 'yes'>
		<span class="alert">The information was saved.</span><cfoutput>#FLGen_SubStamp()#</cfoutput>
		<br /><br />
	</cfif>
	<cfif pgfn EQ "edit" OR pgfn EQ "copy">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT ID 
			FROM #application.database#.program
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
		<cfset ID = ToBeEdited.ID>
	</cfif>
	<cfoutput>
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<cfif pgfn eq 'copy'>
		<tr class="content2">
		<td align="right" valign="top">&nbsp;</td>
		<td valign="top"><span class="alert">!</span> You are adding a new program.</td>
		</tr>
	</cfif>
	<tr class="content">
	<td align="right" valign="top">One-item program?*: </td>
	<td valign="top">
		<select name="is_one_item">
			<option value="0"<cfif #is_one_item# EQ 0> selected</cfif>>No</option>
			<option value="1"<cfif #is_one_item# EQ 1> selected</cfif>>Yes</option>
		</select>
	</td>
	</tr>
	<tr class="contenthead">
	<td colspan="2" class="headertext">Display Settings</td>
	</tr>

	<tr class="content2">
	<td colspan="2" class="headertext">ALL PAGES</td>
	</tr>

	<tr class="content2">
	<td colspan="2" class="headertext">MAIN PAGE</td>
	</tr>

	<tr class="content">
	<td colspan="2" align="center">
	
	<input type="hidden" name="xL" value="#xL#">
	<input type="hidden" name="xT" value="#xT#">
	<input type="hidden" name="OnPage" value="#OnPage#">
	
	<input type="hidden" name="ID" value="#ID#">
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