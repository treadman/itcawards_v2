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
<cfparam name="credit_desc" default="Dollar Value Credit">
<cfparam  name="credit_multiplier" default="0">
<cfparam  name="points_multiplier" default="0">
<cfparam name="cart_exceeded_msg" default="">
<cfparam name="accepts_cc" default="">
<cfparam name="cc_exceeded_msg" default="">
<cfparam name="can_defer" default="">
<cfparam name="defer_msg" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfif NOT Find(".",credit_multiplier) AND Len(credit_multiplier) LTE 4>
		<cfset credit_multiplier = credit_multiplier>
	<cfelseif NOT Find(".",credit_multiplier) AND Len(credit_multiplier) GT 4>
		<cfset credit_multiplier = Right(credit_multiplier,4)>
	<cfelseif Find(".",credit_multiplier) AND (Len(credit_multiplier) - Find(".",credit_multiplier)) LTE 2 AND Len(credit_multiplier) LTE 7>
		<cfset credit_multiplier = credit_multiplier>
	<cfelse>
		<cfset credit_multiplier = 1>
	</cfif>
	<cfif NOT Find(".",points_multiplier) AND Len(points_multiplier) LTE 4>
		<cfset points_multiplier = points_multiplier>
	<cfelseif NOT Find(".",points_multiplier) AND Len(points_multiplier) GT 4>
		<cfset points_multiplier = Right(points_multiplier,4)>
	<cfelseif Find(".",points_multiplier) AND (Len(points_multiplier) - Find(".",points_multiplier)) LTE 2 AND Len(points_multiplier) LTE 7>
		<cfset points_multiplier = points_multiplier>
	<cfelse>
		<cfset points_multiplier = 1>
	</cfif>
	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.program
		SET	can_defer = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#can_defer#" maxlength="1">,
			defer_msg = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#defer_msg#"  null="#YesNoFormat(NOT Len(Trim(defer_msg)))#">,
			cart_exceeded_msg = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#cart_exceeded_msg#">,
			cc_exceeded_msg = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#cc_exceeded_msg#" null="#YesNoFormat(NOT Len(Trim(cc_exceeded_msg)))#">,
			credit_desc = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#credit_desc#" maxlength="40">,
			accepts_cc = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#accepts_cc#" maxlength="1">,
			credit_multiplier = <cfqueryparam cfsqltype="cf_sql_float" value="#credit_multiplier#" scale="2">,
			points_multiplier = <cfqueryparam cfsqltype="cf_sql_float" value="#points_multiplier#" scale="2">
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
<span class="pagetitle">Edit Program Award Credit and Credit Card Information </span>
<br />
<br />
<span class="pageinstructions">Return to <a href="program_details.cfm?&id=#ID#">Award Program Details</a> or <a href="program_list.cfm">Award Program List</a> without making changes.</span>
<br /><br />
</cfoutput>

<cfquery name="ToBeEdited" datasource="#application.DS#">
	SELECT ID, credit_multiplier, points_multiplier, credit_desc, cart_exceeded_msg, can_defer, defer_msg, cc_exceeded_msg, accepts_cc 
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>
<cfset can_defer = htmleditformat(ToBeEdited.can_defer)>
<cfset defer_msg = htmleditformat(ToBeEdited.defer_msg)>
<cfset cart_exceeded_msg = htmleditformat(ToBeEdited.cart_exceeded_msg)>
<cfset cc_exceeded_msg = htmleditformat(ToBeEdited.cc_exceeded_msg)>
<cfset credit_desc = htmleditformat(ToBeEdited.credit_desc)>
<cfset accepts_cc = htmleditformat(ToBeEdited.accepts_cc)>
<cfset credit_multiplier = ToBeEdited.credit_multiplier>
<cfset points_multiplier = ToBeEdited.points_multiplier>

<cfoutput>

<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="content">
	<td colspan="4"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(ID)#</span></span></td>
	</tr>

	<tr class="contenthead">
	<td colspan="2" class="headertext">Award Credits and Credit Cards</td>
	</tr>
					
	<tr class="content">
	<td align="right" valign="top">Credit Description*: </td>
	<td valign="top"><input type="text" name="credit_desc" value="#credit_desc#" maxlength="40" size="40">
	<input type="hidden" name="credit_desc_required" value="You must enter a credit description."></td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top" nowrap="nowrap">Product Multiplier:<br /><span class="sub">Product that users see are multiplied by this number.</span> </td>
	<td valign="top"><input type="text" name="credit_multiplier" value="<cfif credit_multiplier NEQ "">#NumberFormat(credit_multiplier,'0.00')#<cfelse>1.00</cfif>" maxlength="8" size="20"> <span class="sub">(ex. <b>1.00</b> or <b>.50</b> or <b>1000.00</b>)</span>
	</td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top" nowrap="nowrap">Award Points Multiplier:<br /><span class="sub">Award Points that users see are multiplied by this number. </span> </td>
	<td valign="top"><input type="text" name="points_multiplier" value="<cfif points_multiplier NEQ "">#NumberFormat(points_multiplier,'0.00')#<cfelse>1.00</cfif>" maxlength="8" size="20"> <span class="sub">(ex. <b>1.00</b> or <b>.50</b> or <b>1000.00</b>)</span>
	</td>
	</tr>
				
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="bottom"><img src="../pics/contrls-desc.gif" width="7" height="6"> This message appears on the cart and checkout pages. Tailor the message depending on whether credit cards are accepted.  Examples: <span class="sub">You have exceeded your credits. You will have to use your credit card to complete this order.</span> or <span class="sub">You have exceeded your credits. You will have to edit your order before you are able to checkout.</span></td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top" nowrap="nowrap">Exceeded Your Credits Message*: </td>
	<td valign="top"><textarea name="cart_exceeded_msg" cols="38" rows="4">#cart_exceeded_msg#</textarea>
	<input type="hidden" name="cart_exceeded_msg_required" value="You must enter a message that displays when a user's cart total exceed his available credits."></td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Accepts Credit Cards?*: </td>
	<td valign="top">
		<select name="accepts_cc">
			<option value="0"<cfif #accepts_cc# EQ 0> selected</cfif>>No
			<option value="1"<cfif #accepts_cc# EQ 1> selected</cfif>>Yes with credit card maximum
			<option value="2"<cfif #accepts_cc# EQ 2> selected</cfif>>Yes without credit card maximum
		</select>
	</td>
	</tr>
		
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="bottom"><img src="../pics/contrls-desc.gif" width="7" height="6"> Only used if the above is set to <b>Yes with credit card maximum</b>. The automatic message, "You may only charge $##." is displayed when a user exceeds their personal credit card maximum. The message you enter below will appear under that automatic message.  Example: <span class="sub">You will have to edit your order before you are able to checkout.</span></td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Exceeded Credit Card Maximum Message: </td>
	<td valign="top"><textarea name="cc_exceeded_msg" cols="38" rows="4">#cc_exceeded_msg#</textarea> </td>
	</tr>
												
	<tr class="content">
	<td align="right" valign="top">Can users defer points?*: </td>
	<td valign="top">
		<select name="can_defer">
			<option value="0"<cfif #can_defer# EQ 0> selected</cfif>>No
			<option value="1"<cfif #can_defer# EQ 1> selected</cfif>>Yes
		</select>
	</td>
	</tr>
		
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="bottom"><img src="../pics/contrls-desc.gif" width="7" height="6"> This is the message above the defer button.</td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Defer Message: </td>
	<td valign="top"><textarea name="defer_msg" cols="38" rows="4">#defer_msg#</textarea> </td>
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