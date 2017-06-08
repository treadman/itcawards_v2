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

<!--- param a/e form fields --->
<cfparam name="additional_content_button" default="">
<cfparam name="additional_content_message" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfif form.submit EQ 'Edit'>
		<cflocation addtoken="no" url="program_welcome.cfm?ID=#ID#&unapproved=yes">
	<cfelseif form.submit EQ 'Approve'>
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.program
			SET	
				additional_content_button = additional_content_button_unapproved,
				additional_content_message = additional_content_message_unapproved							
				#FLGen_UpdateModConcatSQL("from program_approve_additional_content.cfm")#
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.program
			SET	additional_content_button_unapproved = <cfqueryparam null="yes">,
				additional_content_message_unapproved = <cfqueryparam null="yes">,
				additional_content_program_admin_ID = <cfqueryparam null="yes">
				#FLGen_UpdateModConcatSQL("from program_approve_additional_content.cfm")#
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
		<cflocation addtoken="no" url="program_details.cfm?ID=#ID#">
	<cfelseif form.submit EQ 'Delete'>
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.program
			SET	additional_content_button_unapproved = <cfqueryparam null="yes">,
				additional_content_message_unapproved = <cfqueryparam null="yes">,
				additional_content_program_admin_ID = <cfqueryparam null="yes">
				#FLGen_UpdateModConcatSQL("from program_approve_additional_content.cfm")#
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#">
		</cfquery>
		<cflocation addtoken="no" url="program_details.cfm?ID=#ID#">
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Approve Additional Content</span>
<br /><br />

<cfquery name="ToBeEdited" datasource="#application.DS#">
	SELECT additional_content_button, additional_content_message, additional_content_button_unapproved, additional_content_message_unapproved
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>
<cfset additional_content_button = ToBeEdited.additional_content_button>
<cfset additional_content_message = ToBeEdited.additional_content_message>
<cfset additional_content_button_unapproved = ToBeEdited.additional_content_button_unapproved>
<cfset additional_content_message_unapproved = ToBeEdited.additional_content_message_unapproved>

<cfoutput>
<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="content">
	<td colspan="4"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(ID)#</span></span></td>
	</tr>

	<tr class="contenthead">
	<td colspan="2" class="content"><span class="alert">This text is awaiting approval.</span></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Additional Content Button Text: </td>
	<td valign="top">#additional_content_button_unapproved#</td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Additional Content Message:</td>
	<td valign="top">#additional_content_message_unapproved#</td>
	</tr>
												
	<tr class="content">
	<td colspan="2" align="center">
	<input type="hidden" name="ID" value="#ID#">
			
	<input type="submit" name="submit" value="Approve"> <input type="submit" name="submit" value="Edit"> <input type="submit" name="submit" value="Delete"> 

	</td>
	</tr>
		
	</table>

</form>
<cfif additional_content_button NEQ "" AND additional_content_message NEQ "">
	<br><br>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext">Current Additional Content Available on Live Website</td>
	</tr>
																																			
	<tr class="content">
	<td align="right" valign="top">Additional Content Button Text: </td>
	<td valign="top">#additional_content_button#</td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Additional Content Message:</td>
	<td valign="top">#additional_content_message#</td>
	</tr>
														
	</table>
</cfif>
</cfoutput>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->