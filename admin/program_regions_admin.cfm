<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000058,true)>

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

<cfset leftnavon = "program_admin_regions">
<cfinclude template="includes/header.cfm">

<cfif pgfn EQ "list">
	<span class="pagetitle">Admin User List</span>
	<br /><br />
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<!--- header row --->
		<tr class="contenthead">
			<td align="center">&nbsp;</td>
			<td nowrap><span class="headertext">Admin User</span> <img src="../pics/contrls-asc.gif" width="7" height="6"></td>
		</tr>
		<!--- display found records --->
		<!--- <tr class="<cfoutput>#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#</cfoutput>">
		</tr> --->
	</table>
<cfelseif pgfn EQ "edit"> 
	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
			<tr>
				<td>
					<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Assign Checked Regions">
				</td>
			</tr>
		</table>
	</form>
	</cfoutput>

</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->