<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000089,true)>
<cfif NOT FLGen_AuthHash(itc_program)>
	<cflocation addtoken="no" url="logout.cfm">
</cfif>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="x" default="">
<cfparam name="where_string" default="">
<cfparam name="ID" default="">
<cfparam name="datasaved" default="">

<!--- param a/e form fields --->
<cfparam name="additional_content_button" default="">
<cfparam name="additional_content_message" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit') AND form.Submit IS NOT "" AND IsDefined('form.additional_content_message_unapproved') AND form.additional_content_message_unapproved IS NOT "">

	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.program
		SET	additional_content_button_unapproved = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#additional_content_button_unapproved#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(additional_content_button_unapproved)))#">,
			additional_content_message_unapproved = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#additional_content_message_unapproved#" null="#YesNoFormat(NOT Len(Trim(additional_content_message_unapproved)))#">,
			additional_content_program_admin_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#">
			#FLGen_UpdateModConcatSQL("from program_admin_additional_content.cfm")#
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ListGetAt(cookie.itc_program,1,'-')#" maxlength="10">
	</cfquery>
	<cfmail to="#application.ITCAdminEmail#" from="#Application.AwardsFromEmail#" subject="#FLITC_GetProgramName(ListGetAt(cookie.itc_program,1,'-'))# Content Approval Needed">
	
	Lou,
	
	Please review the additional content entered by #FLGen_GetAdminName(FLGen_adminID)# for the award program #FLITC_GetProgramName(ListGetAt(cookie.itc_program,1,'-'))#.
	
	1) Login to the admin website
	2) Click on Program
	3) Click on Details for #FLITC_GetProgramName(ListGetAt(cookie.itc_program,1,'-'))#
	4) Scroll to the bottom of the Welcome Page section and click "more information ..."
	5) Review unapproved additional content and take appropriate action.
	
	Thank you!
	
	Love,
	
	Alice   xoxoxox
	
	p.s.  This is an automatic email.
	
	</cfmail>
	
	<cfset datasaved = "Your entries have been saved and will be sent to ITC for approval.">

</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<cfset tinymce_fields = "additional_content_message_unapproved">
<cfset tinymce_image_list = "/admin/image_lists/#ListGetAt(cookie.itc_program,1,'-')#_1_image_list.js">
<cfinclude template="/cfscripts/dfm_common/tinymce.cfm">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programadmin_additionalcontent">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Edit Additional Content</span>
<br /><br />
<span class="pageinstructions">The information submitted by this form must be approved by ITC before it will be available on the live website.</span>
<br /><br />

<cfif datasaved NEQ "">
	<span class="alert"><cfoutput>#datasaved#</cfoutput></span>
	<br /><br />
</cfif>

<cfquery name="ToBeEdited" datasource="#application.DS#">
	SELECT additional_content_button, additional_content_message, additional_content_button_unapproved, additional_content_message_unapproved
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ListGetAt(cookie.itc_program,1,'-')#" maxlength="10">
</cfquery>
<cfset additional_content_button = ToBeEdited.additional_content_button>
<cfset additional_content_message = ToBeEdited.additional_content_message>
<cfset additional_content_button_unapproved = ToBeEdited.additional_content_button_unapproved>
<cfset additional_content_message_unapproved = ToBeEdited.additional_content_message_unapproved>

<cfoutput>

<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="content">
	<td colspan="4"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(ListGetAt(cookie.itc_program,1,'-'))#</span></span></td>
	</tr>

	<tr class="contenthead">
	<td colspan="2" class="headertext">Additional Content</td>
	</tr>
	
	<cfif additional_content_button_unapproved NEQ "" AND additional_content_message_unapproved NEQ "">
																	
	<tr class="contenthead">
	<td colspan="2" class="content"><span class="alert">The text in the form is awaiting approval.</span></td>
	</tr>
	
	</cfif>
																	
	<tr class="content">
	<td align="right" valign="top">Additional Content Button Text: </td>
	<td valign="top"><input type="text" name="additional_content_button_unapproved" value="#additional_content_button_unapproved#" maxlength="30" size="40">
	<input type="hidden" name="additional_content_button_unapproved_required" value="You must enter button text."></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Additional Content Message:</td>
	<td valign="top"><textarea name="additional_content_message_unapproved" cols="50" rows="15">#additional_content_message_unapproved#</textarea>
	<input type="hidden" name="additional_content_message_unapproved_required" value="You must enter message text."></td>
	</tr>
												
	<tr class="content">
	<td colspan="2" align="center">
			
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save and Request Approval" >

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