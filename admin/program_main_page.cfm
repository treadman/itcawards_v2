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
<cfparam name="main_bg" default="">
<cfparam name="main_congrats" default="">
<cfparam name="main_instructions" default="">
<cfparam name="return_button" default="Return to Gifts">
<cfparam name="display_col" default="">
<cfparam name="display_row" default="">
<cfparam name="menu_text" default="Dollar Value Credit">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.program
		SET main_bg = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#main_bg#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(main_bg)))#">, 
			main_congrats = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#main_congrats#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(main_congrats)))#">, 
			main_instructions = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#main_instructions#" null="#YesNoFormat(NOT Len(Trim(main_instructions)))#">,
			return_button = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#return_button#" maxlength="30">,
			display_col = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#display_col#" maxlength="2">,
			display_row = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#display_row#" maxlength="2">,
			menu_text = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#menu_text#" maxlength="40">
			#FLGen_UpdateModConcatSQL("from program_welcome.cfm")#
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
	<cflocation addtoken="no" url="program_details.cfm?ID=#ID#">
</cfif>

<!--- javascript --->
<script language="javascript">
function enterThisImage(image,field)
{
	document.getElementById(field).value = image
}
</script>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "programs">
<cfinclude template="includes/header.cfm">

<cfoutput>
<span class="pagetitle">Edit Program Main Page</span>
<br /><br />
<span class="pageinstructions">Return to <a href="program_details.cfm?&id=#ID#">Award Program Details</a> or <a href="program_list.cfm">Award Program List</a> without making changes.</span>
<br /><br />
</cfoutput>

<cfquery name="ToBeEdited" datasource="#application.DS#">
	SELECT ID, main_bg, main_congrats, main_instructions, return_button, display_col, display_row, menu_text 
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>
<cfset main_bg = htmleditformat(ToBeEdited.main_bg)>
<cfset main_congrats = htmleditformat(ToBeEdited.main_congrats)>
<cfset main_instructions = htmleditformat(ToBeEdited.main_instructions)>
<cfset return_button = htmleditformat(ToBeEdited.return_button)>
<cfset display_col = htmleditformat(ToBeEdited.display_col)>
<cfset display_row = htmleditformat(ToBeEdited.display_row)>
<cfset menu_text = htmleditformat(ToBeEdited.menu_text)>

<cfoutput>

<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="content">
	<td colspan="4"><span class="headertext">Program: <span class="selecteditem">#FLITC_GetProgramName(ID)#</span></span></td>
	</tr>

	<tr class="contenthead">
	<td colspan="2" class="headertext">Main Page</td>
	</tr>
					
	<tr class="content">
	<td align="right" valign="top">Main Page Background Image: </td>
	<td valign="top"><input type="text" name="main_bg" value="#main_bg#" maxlength="64" size="40"> <span class="sub">(Leave blank if no background image.)</span></td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Main Page Congratulations Image: </td>
	<td valign="top"><input type="text" name="main_congrats" ID="main_congrats" value="#main_congrats#" maxlength="64" size="40"><br>
	<a href="/pics/program/ITC_Thank-you.gif">view</a> <a href="##" onClick="enterThisImage('ITC_Thank-you.gif','main_congrats');return false;">choose</a> thank you<br>
	<a href="/pics/program/Welcome-congrats.gif">view</a> <a href="##" onClick="enterThisImage('Welcome-congrats.gif','main_congrats');return false;">choose</a> congratulations</td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Main Page Instructions: </td>
	<td valign="top"><textarea name="main_instructions" cols="50" rows="6">#main_instructions#</textarea></td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Columns&nbsp;of&nbsp;products&nbsp;per&nbsp;page*:&nbsp;</td>
	<td valign="top">
		<select name="display_col">
			<option value="1"<cfif #display_col# EQ 1> selected</cfif>>1
			<option value="2"<cfif #display_col# EQ 2> selected</cfif>>2
			<option value="3"<cfif #display_col# EQ 3> selected</cfif>>3
			<option value="4"<cfif #display_col# EQ 4> selected</cfif>>4
			<option value="5"<cfif #display_col# EQ 5> selected</cfif>>5
			<option value="6"<cfif #display_col# EQ 6> selected</cfif>>6
		</select>
	</td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Rows of products per page*: </td>
	<td valign="top">
		<select name="display_row">
			<option value="1"<cfif #display_row# EQ 1> selected</cfif>>1
			<option value="2"<cfif #display_row# EQ 2> selected</cfif>>2
			<option value="3"<cfif #display_row# EQ 3> selected</cfif>>3
			<option value="4"<cfif #display_row# EQ 4> selected</cfif>>4
			<option value="5"<cfif #display_row# EQ 5> selected</cfif>>5
			<option value="6"<cfif #display_row# EQ 6> selected</cfif>>6
		</select>
	</td>
	</tr>
		
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif" width="7" height="6">  This goes in the top box of the left side menu.</td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Menu Text*: </td>
	<td valign="top"><input type="text" name="menu_text" value="#menu_text#" maxlength="40" size="40">
	<input type="hidden" name="menu_text_required" value="You must enter menu text."></td>
	</tr>
				
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif" width="7" height="6">  This is the button on the product detail page that returns the user to main page.</td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Return Button*: </td>
	<td valign="top"><input type="text" name="return_button" value="#return_button#" maxlength="30" size="40">
	<input type="hidden" name="return_button_required" value="You must enter return button text."></td>
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
