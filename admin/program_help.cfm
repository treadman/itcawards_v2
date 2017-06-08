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

<!--- param a/e form fields --->
<cfparam name="ID" default="">
<cfparam name="help_button" default="">
<cfparam name="help_message" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.program
		SET	help_button = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#help_button#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(help_button)))#">,
			help_message = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#help_message#" null="#YesNoFormat(NOT Len(Trim(help_message)))#">
			#FLGen_UpdateModConcatSQL("from program_help.cfm")#
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
	<cflocation addtoken="no" url="program_details.cfm?ID=#ID#">

</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<cfset tinymce_fields = "help_message">
<cfinclude template="/cfscripts/dfm_common/tinymce.cfm">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">

<cfoutput>
<span class="pagetitle">Edit Help Page</span>
<br /><br />
<span class="pageinstructions">Return to <a href="program_details.cfm?&id=#ID#">Award Program Details</a> or <a href="program_list.cfm">Award Program List</a> without making changes.</span>
<br /><br />
</cfoutput>

<cfquery name="ToBeEdited" datasource="#application.DS#">
	SELECT help_button, help_message 
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>
<cfset help_button = htmleditformat(ToBeEdited.help_button)>
<cfset help_message = htmleditformat(ToBeEdited.help_message)>


<cfoutput>

<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="content">
	<td colspan="4"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(ID)#</span></span></td>
	</tr>

	<tr class="contenthead">
	<td colspan="2" class="headertext">Help Page</td>
	</tr>
					
	<tr class="content">
	<td align="right" valign="top">Help Button Text: </td>
	<td valign="top"><input type="text" name="help_button" value="#help_button#" maxlength="30" size="40"></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Help Content:</td>
	<td valign="top"><textarea name="help_message" cols="50" rows="15">#help_message#</textarea></td>
	</tr>
												
	<tr class="content">
	<td colspan="2" align="center">
		
	<input type="hidden" name="ID" value="#ID#">
			
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