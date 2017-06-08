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
<cfparam name="unapproved" default="">

<!--- param a/e form fields --->
<cfparam name="orders_to" default="">
<cfparam name="program_email_subject" default="">
<cfparam name="orders_from" default="#application.AwardsFromEmail#">
<cfparam name="conf_email_text" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.program
		SET program_email_subject = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#program_email_subject#" maxlength="50">,
			orders_to = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#orders_to#" maxlength="128">,
			orders_from = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#orders_from#" maxlength="64">,
			conf_email_text = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#conf_email_text#" null="#YesNoFormat(NOT Len(Trim(conf_email_text)))#"> 
			#FLGen_UpdateModConcatSQL("from program_welcome.cfm")#
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
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
<span class="pagetitle">Edit Order Email Information</span>
<br /><br />
<span class="pageinstructions">Return to <a href="program_details.cfm?&id=#ID#">Award Program Details</a> or <a href="program_list.cfm">Award Program List</a> without making changes.</span>
<br /><br />
</cfoutput>

<cfquery name="ToBeEdited" datasource="#application.DS#">
	SELECT ID, orders_to, orders_from, conf_email_text, program_email_subject
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>
<cfset orders_to = htmleditformat(ToBeEdited.orders_to)>
<cfset orders_from = htmleditformat(ToBeEdited.orders_from)>
<cfset conf_email_text = htmleditformat(ToBeEdited.conf_email_text)>
<cfset program_email_subject = htmleditformat(ToBeEdited.program_email_subject)>

<cfoutput>

<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="content">
	<td colspan="4"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(ID)#</span></span></td>
	</tr>

	<tr class="contenthead">
	<td colspan="2" class="headertext">Order Email Information</td>
	</tr>
					
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif" width="7" height="6"> Please enter only ONE email address.</td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Order Confirmation  sent FROM*: </td>
	<td valign="top"><input type="text" name="orders_from" value="#application.AwardsFromEmail#" maxlength="64" size="40" readonly>
	<input type="hidden" name="orders_from_required" value="You must enter an email address from which the order confirmation emails will come."></td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Order Confirmation Email Text: </td>
	<td valign="top"><textarea name="conf_email_text" cols="38" rows="4">#conf_email_text#</textarea></td>
	</tr>

	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif" width="7" height="6">  Separate multiple email addresses with a single comma and no space, please.</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">New Order Alert Email sent TO: </td>
	<td valign="top"><input type="text" name="orders_to" value="#orders_to#" maxlength="128" size="40"></td>
	</tr>
				
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif" width="7" height="6">  This will be automatically appended with "- Order 222"</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Subject for New Order Alert Email*: </td>
	<td valign="top"><input type="text" name="program_email_subject" value="#program_email_subject#" maxlength="50" size="50">
	<input type="hidden" name="program_email_subject_required" value="You must enter a new order email subject"></td>
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