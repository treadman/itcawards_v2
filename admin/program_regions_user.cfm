<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000059,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam  name="pgfn" default="list">
<cfparam name="alert_msg" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfset alert_msg = "This does nothing.">
	<cfset pgfn = "list">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "program_user_regions">
<cfinclude template="includes/header.cfm">

<cfif pgfn EQ "list">
	<cfoutput>
	<span class="pagetitle">Program User List</span>
	<br /><br />
	<span class="pageinstructions">Change <a href="#CurrentPage#?pgfn=edit">region assignments</a>.</span>
	<br /><br />
	</cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	</table>
<cfelseif pgfn EQ "edit">
	<cfoutput>
	<span class="pagetitle">Program User Region Assignment</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="<cfoutput>#CurrentPage#</cfoutput>">Program User List</a> without making changes.</span>
	<br /><br />
	</cfoutput>
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="content">
	<td colspan="2" align="center"><input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Assign Selected Regions"></td>
	</tr>
	</table>
	</form>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->