<!--- import function libraries --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000086,true)>

<!--- variables used on page --->
<cfparam name="datasaved" default="false">

<!--- displayed form fields --->
<cfparam name="secret_word" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined("form.submit")>
	<cfquery name="updateSecretWord" datasource="#application.DS#">
		UPDATE #application.database#.ariGameSecretWord
		SET secret_word = <cfqueryparam cfsqltype="cf_sql_varchar" value="#secret_word#" maxlength="75">,
		last_updated = <cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDateTime(Now())#">
	</cfquery>
	<cflocation url="#CurrentPage#?datasaved=true" addtoken="no">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfquery name="getSecretWord" datasource="#application.DS#">
	SELECT secret_word
	FROM #application.database#.ariGameSecretWord
	ORDER BY ID
</cfquery>

<cfset secret_word = HTMLEditFormat(getSecretWord.secret_word)>

<cfset leftnavon = "ari_secretword">
<cfinclude template="includes/header.cfm">

<cfoutput>
<p class="pagetitle">ARI Game - Set Secret Word</p>
<cfif datasaved>
	<p class="alert">The secret word changes you made have been successfully saved.</p>
</cfif>
<form name="form1" method="post" action="#CurrentPage#">
	<table width="100%" cellpadding="5" cellspacing="1" border="0">
		<tr valign="top" class="contenthead">
			<td colspan="2" class="headertext"><img src="../pics/shim.gif" width="100%" height="15" alt="" /></td>
		</tr>
		<tr valign="top" class="content">
			<td align="right">Secret Word:</td>
			<td>
				<input type="text" name="secret_word" size="40" maxlength="75" value="#secret_word#" />
				<input type="hidden" name="secret_word_cfformrequired" value="You must enter a secret word." />
			</td>
		</tr>
		<tr valign="top" class="content">
			<td>&nbsp;</td>
			<td><input type="submit" name="submit" value="Save" />
<!-- #hash('ttreadway','md5')# -->
</td>
		</tr>
	</table>
</form>		
</cfoutput>

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->

<cfinclude template="includes/footer.cfm">
