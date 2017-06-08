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
<cfparam name="ID" default="">
<cfif NOT isNumeric(ID)>
	<cflocation url="program_list.cfm" addtoken="no">
</cfif>

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->


<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Award Program Details</span>
<br />
<br />
<span class="pageinstructions">Return to <a href="program_list.cfm">Award Program List</a> without making changes.</span>
<br /><br />

<cfquery name="ToBeEdited" datasource="#application.DS#">
	SELECT ID, company_name, program_name, expiration_date, is_one_item, can_defer, defer_msg, has_welcomepage,
		welcome_bg, welcome_instructions, welcome_message, welcome_congrats, welcome_button, welcome_admin_button,
		admin_logo, logo, cross_color, main_bg, main_congrats, main_instructions, return_button, text_active,
		bg_active, text_selected, bg_selected, cart_exceeded_msg, cc_exceeded_msg, orders_to, orders_from,
		conf_email_text, program_email_subject, has_survey, display_col, display_row, menu_text, credit_desc,
		accepts_cc, login_prompt, is_active, display_welcomeyourname, display_youhavexcredits, credit_multiplier, points_multiplier,
		email_form_button, email_form_message, additional_content_button, additional_content_message, help_button,
		help_message, additional_content_button_unapproved, additional_content_message_unapproved, has_password_recovery, use_master_categories,
		is_henkel, additional_content2_button, additional_content2_message
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>
<cfset ID = ToBeEdited.ID>
<cfset company_name = htmleditformat(ToBeEdited.company_name)>
<cfset program_name = htmleditformat(ToBeEdited.program_name)>
<cfset expiration_date = FLGen_DateTimeToDisplay(htmleditformat(ToBeEdited.expiration_date))>
<cfset is_one_item = htmleditformat(ToBeEdited.is_one_item)>
<cfset can_defer = htmleditformat(ToBeEdited.can_defer)>
<cfset defer_msg = htmleditformat(ToBeEdited.defer_msg)>
<cfset has_welcomepage = htmleditformat(ToBeEdited.has_welcomepage)>
<cfset welcome_bg = htmleditformat(ToBeEdited.welcome_bg)>
<cfset welcome_instructions = htmleditformat(ToBeEdited.welcome_instructions)>
<cfset welcome_message = htmleditformat(ToBeEdited.welcome_message)>
<cfset welcome_congrats = htmleditformat(ToBeEdited.welcome_congrats)>
<cfset welcome_button = htmleditformat(ToBeEdited.welcome_button)>
<cfset welcome_admin_button = htmleditformat(ToBeEdited.welcome_admin_button)>
<cfset admin_logo = htmleditformat(ToBeEdited.admin_logo)>
<cfset logo = htmleditformat(ToBeEdited.logo)>
<cfset cross_color = htmleditformat(ToBeEdited.cross_color)>
<cfset main_bg = htmleditformat(ToBeEdited.main_bg)>
<cfset main_congrats = htmleditformat(ToBeEdited.main_congrats)>
<cfset main_instructions = htmleditformat(ToBeEdited.main_instructions)>
<cfset return_button = htmleditformat(ToBeEdited.return_button)>
<cfset welcome_bg = htmleditformat(ToBeEdited.welcome_bg)>
<cfset text_active = htmleditformat(ToBeEdited.text_active)>
<cfset bg_active = htmleditformat(ToBeEdited.bg_active)>
<cfset text_selected = htmleditformat(ToBeEdited.text_selected)>
<cfset bg_selected = htmleditformat(ToBeEdited.bg_selected)>
<cfset cart_exceeded_msg = htmleditformat(ToBeEdited.cart_exceeded_msg)>
<cfset cc_exceeded_msg = htmleditformat(ToBeEdited.cc_exceeded_msg)>
<cfset orders_to = htmleditformat(ToBeEdited.orders_to)>
<cfset orders_from = htmleditformat(ToBeEdited.orders_from)>
<cfset conf_email_text = htmleditformat(ToBeEdited.conf_email_text)>
<cfset program_email_subject = htmleditformat(ToBeEdited.program_email_subject)>
<cfset has_survey = htmleditformat(ToBeEdited.has_survey)>
<cfset display_col = htmleditformat(ToBeEdited.display_col)>
<cfset display_row = htmleditformat(ToBeEdited.display_row)>
<cfset menu_text = htmleditformat(ToBeEdited.menu_text)>
<cfset credit_desc = htmleditformat(ToBeEdited.credit_desc)>
<cfset accepts_cc = htmleditformat(ToBeEdited.accepts_cc)>
<cfset login_prompt = htmleditformat(ToBeEdited.login_prompt)>
<cfset is_active = htmleditformat(ToBeEdited.is_active)>
<cfset display_welcomeyourname = htmleditformat(ToBeEdited.display_welcomeyourname)>
<cfset display_youhavexcredits = htmleditformat(ToBeEdited.display_youhavexcredits)>
<cfset credit_multiplier = ToBeEdited.credit_multiplier>
<cfset points_multiplier = ToBeEdited.points_multiplier>
<cfset email_form_button = htmleditformat(ToBeEdited.email_form_button)>
<cfset email_form_message = ToBeEdited.email_form_message>
<cfset additional_content_button = htmleditformat(ToBeEdited.additional_content_button)>
<cfset additional_content_message = ToBeEdited.additional_content_message>
<cfset additional_content2_button = htmleditformat(ToBeEdited.additional_content2_button)>
<cfset additional_content2_message = ToBeEdited.additional_content2_message>
<cfset help_button = htmleditformat(ToBeEdited.help_button)>
<cfset help_message = ToBeEdited.help_message>
<cfset additional_content_button_unapproved = htmleditformat(ToBeEdited.additional_content_button_unapproved)>
<cfset additional_content_message_unapproved = ToBeEdited.additional_content_message_unapproved>
<cfset has_password_recovery = ToBeEdited.has_password_recovery>
<cfset is_henkel = ToBeEdited.is_henkel>
<cfset use_master_categories = ToBeEdited.use_master_categories>

<cfoutput>

	<!---  * * * * * * * * *  --->
	<!--- GENERAL INFORMATION --->
	<!---  * * * * * * * * *  --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_general.cfm?pgfn=edit&id=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;General Information</td>
	</tr>

	<tr class="content">
	<td valign="top" class="content_details">
   <b>#company_name# [#program_name#]</b> expires #expiration_date#<br><br>
	This Award Program <b>is <cfif is_active EQ 1>Active<cfelse>Inactive</cfif></b><br>
	This Award Program <b><cfif has_survey EQ 1>has<cfelse>does not have</cfif> a survey</b>.<br>
	This Award Program <b><cfif is_one_item EQ 0>is not<cfelse>is</cfif> a one-item store</b>.<br>
	This Award Program <b><cfif has_password_recovery>has<cfelse>does not have</cfif> password recovery</b>.<br>
	<cfif is_henkel>
		This Award Program <b>is a Henkel program.&nbsp;&nbsp;<a href="program_henkel.cfm?id=#id#">Set Henkel Program Parameters</a></b>
	<cfelse>
		This Award Program <b>is NOT a Henkel program</b>.
	</cfif>
	<br>
	<cfswitch expression="#use_master_categories#">
		<cfcase value="0">
			uses old-style <b>category buttons</b> with <b>master categories</b>.
		</cfcase>
		<cfcase value="1">
			uses old-style <b>category buttons</b> with <b>search options</b>.
		</cfcase>
		<cfcase value="2">
			uses stacked <b>category buttons</b> with <b>search options</b>.
		</cfcase>
		<cfcase value="3">
			uses new-style <b>category tabs</b> with <b>master categories</b>.
		</cfcase>
		<cfcase value="4">
			uses new-style <b>category tabs</b> with <b>search options</b>.
		</cfcase>
		<cfdefaultcase>
			<span class="alert">Category style not set!</span>
		</cfdefaultcase>
	</cfswitch>
	</td>
	</tr>
	
	</table>
	
	<br>
	
	<!---  * * * * * * * * * * * --->
	<!--- AWARD CREDITS AND CREDIT CARDS --->
	<!---  * * * * * * * * * * * --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_credit.cfm?id=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;Award Credits and Credit Cards</td>
	</tr>

	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap"><b>Award Credit</b> Description:</td>
	<td valign="top" width="100%">#credit_desc#<cfif credit_desc EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap"><b>Product</b> Multiplier:</td>
	<td valign="top"><cfif credit_multiplier NEQ "">#NumberFormat(credit_multiplier,'0.00')#<cfelse>1.00</cfif></td>
	</tr>

	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap"><b>Award Points</b> Multiplier:</td>
	<td valign="top"><cfif points_multiplier NEQ "">#NumberFormat(points_multiplier,'0.00')#<cfelse>1.00</cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Exceeded <b>Award Credit</b> Message: </td>
	<td valign="top">#cart_exceeded_msg#<cfif cart_exceeded_msg EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Can users <b>Defer</b> Award Credits?:</td>
	<td valign="top"><cfif #can_defer# EQ 1>Yes<cfelse>No</cfif></td>
	</tr>

	<cfif #can_defer# EQ 1>
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Message above <b>Defer</b> button:
	<td valign="top">#defer_msg#<cfif defer_msg EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	</cfif>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Accepts <b>Credit Cards</b>?:</td>
	<td valign="top"><cfif #accepts_cc# EQ 0>No<cfelseif #accepts_cc# EQ 1>Yes with credit card maximum<cfelseif #accepts_cc# EQ 2>Yes without credit card maximum</cfif></td>
	</tr>

	<cfif #accepts_cc# EQ 1>
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Exceeded <b>Credit Card</b><br>Maximum Message:
	<td valign="top">#cc_exceeded_msg#<cfif cc_exceeded_msg EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	</cfif>
	
	</table>
	
	<br>
	
	<!---  * * * * * * * * * * * --->
	<!--- SUBPROGRAMS --->
	<!---  * * * * * * * * * * * --->
	<cfquery name="SelectSubprograms" datasource="#application.DS#">
		SELECT subprogram_name, is_active
		FROM #application.database#.subprogram
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		ORDER BY sortorder
	</cfquery>

	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_subprograms.cfm?program_ID=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;Subprograms <span class="reg">(for billing purposes only)</span></td>
	</tr>
	
	<cfif SelectSubprograms.RecordCount EQ 0>
	
	<tr class="content">
	<td colspan="2" valign="top" class="content_details"><span class="sub">There are no subprograms.</span></td>
	</tr>

	<cfelse>

	<tr class="content">
	<td colspan="2" valign="top" class="content_details">
	<cfloop query="SelectSubprograms">
	#subprogram_name#<cfif is_active EQ 0> (inactive)</cfif><br>
	</cfloop>
	</td>
	</tr>

	</cfif>
		
	</table>
	
	<br>
	
	<!---  * * * * * * * * * * * --->
	<!--- USER CATEGORIES --->
	<!---  * * * * * * * * * * * --->
	<cfquery name="SelectUserCategories" datasource="#application.DS#">
		SELECT category_name
		FROM #application.database#.program_user_category
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		ORDER BY sortorder
	</cfquery>

	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_user_categories.cfm?program_ID=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;User Categories <span class="reg">(for reporting only)</span></td>
	</tr>
	
	<cfif SelectUserCategories.RecordCount EQ 0>
	
	<tr class="content">
	<td colspan="2" valign="top" class="content_details"><span class="sub">There are no user categories.</span></td>
	</tr>

	<cfelse>

	<tr class="content">
	<td colspan="2" valign="top" class="content_details">
	<cfloop query="SelectUserCategories">
	#category_name#<br>
	</cfloop>
	</td>
	</tr>

	</cfif>
		
	</table>

	<br>

	<!---  * * * * * * * * * * * --->
	<!--- ORDER EMAILS --->
	<!---  * * * * * * * * * * * --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_order_emails.cfm?id=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;Order Emails</td>
	</tr>

	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap"><b>Order Confirmation</b> sent FROM:</td>
	<td valign="top" width="100%">#orders_from#<cfif orders_from EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap"><b>Order Confirmation</b> Email Text:</td>
	<td valign="top">#conf_email_text#<cfif conf_email_text EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap"><b>New Order Alert</b> Email sent TO:</td>
	<td valign="top">#orders_to#<cfif orders_to EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
		
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap"><b>New Order Alert</b> Email Subject:</td>
	<td valign="top"><cfif program_email_subject EQ ""><span class="alert">Edit This Section</span><cfelse>#program_email_subject# <span class="sub">- Order ######</span></cfif></td>
	</tr>
	
	</table>
	
	<br>

	<!---  * * * * * * * * * * * --->
	<!--- GENERAL DISPLAY SETTINGS --->
	<!---  * * * * * * * * * * * --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_program_display.cfm?id=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;General Display Settings</td>
	</tr>

	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Company Logo:</td>
	<td valign="top" width="100%"><cfif logo NEQ ""><img src="/pics/program/#logo#"><cfelse><span class="sub">(no logo)</span></cfif></td>
	</tr>
	
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Cross Color:</td>
	<td valign="top"><cfif cross_color NEQ ""><img src="../pics/program/shim.gif" style="background-color:###cross_color#" width="140" height="10"><cfelse><span class="sub">(no cross)</span></cfif></td>
	</tr>
	
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Active Button:</td>
	<td valign="top">
		<cfif bg_active EQ "" AND text_active EQ "">
		<span class="alert">Edit This Section</span>
		<cfelse>
		<table cellpadding="5" cellspacing="0" border="0">
		<tr>
		<td align="center" width="130" style="background-color:###bg_active#;color:###text_active#;font-weight:bold">Active&nbsp;Colors</td>
		</tr>
		</table>
		</cfif>
	</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Selected Button:</td>
	<td valign="top">
		<cfif bg_selected EQ "" AND text_selected EQ "">
		<span class="alert">Edit This Section</span>
		<cfelse>
		<table cellpadding="5" cellspacing="0" border="0">
		<tr>
		<td align="center" width="130" style="background-color:###bg_selected#;color:###text_selected#;font-weight:bold">Selected&nbsp;Colors</td>
		</tr>
		</table>
		</cfif>
	</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Login Prompt:</td>
	<td valign="top"><cfif login_prompt EQ ""><span class="alert">Edit This Section</span><cfelse>Please Enter Your #login_prompt# Without Dashes or Spaces</cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">On Welcome and Main pages:</td>
	<td valign="top">
	"Welcome <i>Your Name</i>" <b>will <cfif #display_welcomeyourname# EQ 0>not</cfif></b> display.<br>
	"You have #### <cfif credit_desc NEQ "">#credit_desc#<cfelse>(credit description here)</cfif>" <b>will <cfif #display_youhavexcredits# EQ 0>not</cfif></b> display.
	</td>
	</tr>
	
	</table>
	
	<br>

	<!---  * * * * * * * * * * * --->
	<!--- WELCOME PAGE --->
	<!---  * * * * * * * * * * * --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_welcome.cfm?ID=#ID#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;Welcome Page</td>
	</tr>

	<cfif has_welcomepage EQ 0>
	
	<tr class="content">
	<td colspan="2" valign="top" class="content_details">
		<span class="sub">
			There is no welcome page.<br><br>
			This is the page that has the additional content and email form buttons.
		</span>
	</td>
	</tr>
	
	<cfelse>

	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Background Image:</td>
	<td valign="top" width="100%"><cfif welcome_bg NEQ ""><a href="/pics/program/#welcome_bg#" target="_blank">view in new window</a><cfelse><span class="sub">(no background image)</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Congratulations Image:</td>
	<td valign="top" width="100%"><cfif welcome_congrats NEQ ""><a href="/pics/program/#welcome_congrats#" target="_blank">view in new window</a><cfelse><span class="sub">(no congratulations image)</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Instructions:</td>
	<td valign="top" width="100%">#Left(welcome_instructions, 75)#<cfif Len(welcome_instructions) GT 50> ... <a href="program_welcome.cfm?ID=#ID#">more</a></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Message:</td>
	<td valign="top" width="100%">#Left(welcome_message, 75)#<cfif Len(welcome_message) GT 50> ... <a href="program_welcome.cfm?ID=#ID#">more</a></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Button To Main Page:</td>
	<td valign="top" width="100%">#welcome_button#</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Button To Admin Login:</td>
	<td valign="top" width="100%">#welcome_admin_button#</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Admin Co-Branding Logo:</td>
	<td valign="top" width="100%"><cfif admin_logo NEQ ""><img src="/pics/program/#admin_logo#"><cfelse><span class="sub">(no admin co-branding image)</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Button To Email Form:</td>
	<td valign="top" width="100%">#email_form_button#</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Email Form Message:</td>
	<td valign="top" width="100%">#Left(email_form_message, 75)#<cfif Len(email_form_message) GT 50> ... <a href="program_welcome.cfm?ID=#ID#">complete message</a></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Button To Additional Content:</td>
	<td valign="top" width="100%">#additional_content_button#</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Additional Content:</td>
	<td valign="top" width="100%">#Left(additional_content_message, 75)#<cfif Len(additional_content_message) GT 50> ... <a href="program_welcome.cfm?ID=#ID#">more</a></cfif></td>
	</tr>

	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Button To Additional Content 2:</td>
	<td valign="top" width="100%">#additional_content2_button#</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Additional Content 2:</td>
	<td valign="top" width="100%">#Left(additional_content2_message, 75)#<cfif Len(additional_content2_message) GT 50> ... <a href="program_welcome.cfm?ID=#ID#">more</a></cfif></td>
	</tr>
	
		<cfif additional_content_message_unapproved NEQ "" AND additional_content_button_unapproved NEQ "">
	<tr class="content">
	<td valign="top" class="content_details" colspan="2"><span class="alert">There is Additional Content waiting to be approved.</span> <a href="program_approve_additional_content.cfm?ID=#ID#">more information ...</a></td>
	</tr>
		</cfif>
	
	</cfif>
		
	</table>
	
	<br>
	
	<!---  * * * * * * * * * * * --->
	<!--- MAIN PAGE --->
	<!---  * * * * * * * * * * * --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_main_page.cfm?id=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp; Main Page</td>
	</tr>

	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Background Image:</td>
	<td valign="top" width="100%"><cfif main_bg NEQ ""><a href="/pics/program/#main_bg#" target="_blank">view in new window</a><cfelse><span class="sub">(no background image)</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Congratulations Image:</td>
	<td valign="top" width="100%"><cfif main_congrats NEQ ""><a href="/pics/program/#main_congrats#" target="_blank">view in new window</a><cfelse><span class="sub">(no congratulations image)</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Instructions:</td>
	<td valign="top" width="100%">#main_instructions#<cfif main_instructions EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Columns of products:</td>
	<td valign="top" width="100%">#display_col#<cfif display_col EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Rows of products:</td>
	<td valign="top" width="100%">#display_row#<cfif display_row EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Top Of Left Menu:</td>
	<td valign="top" width="100%">#menu_text#<cfif menu_text EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Return to Main Button:</td>
	<td valign="top" width="100%">#return_button#<cfif return_button EQ ""><span class="alert">Edit This Section</span></cfif></td>
	</tr>
	
	</table>
	
	<br>
	
	<!---  * * * * * * * * * * * --->
	<!--- HELP --->
	<!---  * * * * * * * * * * * --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><a href="program_help.cfm?id=#id#">Edit</a>&nbsp;&nbsp;&nbsp;&nbsp;Help</td>
	</tr>
	
	<cfif help_button NEQ "" and help_message NEQ "">
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Button To Help:</td>
	<td valign="top" width="100%">#help_button#</td>
	</tr>
	
	<tr class="content">
	<td valign="top" class="content_details" align="right" nowrap="nowrap">Help Content:</td>
	<td valign="top" width="100%">#help_message#</td>
	</tr>
	
	<cfelse>
		
	<tr class="content">
	<td valign="top" colspan="2" class="content_details" ><span class="sub">There is no help button or content.</span></td>
	</tr>

	</cfif>
			
	</table>
	
</cfoutput>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->