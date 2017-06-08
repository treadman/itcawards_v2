<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="n" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cflocation addtoken="no" url="#n#.cfm?program_ID=#program_ID#">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = n>
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Pick a Program</span>
<br /><br />

<cfoutput>
<form method="post" action="#CurrentPage#">
	#SelectProgram(SelectProgram_onlyactive=true)#
	<input type="hidden" name="n" value="#n#">
	<input type="submit" name="submit" value="Select This Program" >
</form>
</cfoutput>		

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->