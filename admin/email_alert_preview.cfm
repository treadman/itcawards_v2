<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess("1000000072-1000000075",true)>
<cfif FLGen_HasAdminAccess(1000000075)>
	<cfif NOT FLGen_AuthHash(itc_program)>
		<cflocation addtoken="no" url="logout.cfm">
	</cfif>
</cfif>

<cfparam name="x" default="">
<cfparam name="where_string" default="">
<cfparam name="delete" default="">
<cfparam name="datasaved" default=""> 

<cfinclude template="includes/header_lite.cfm">

<cfif isDefined("ID") AND isNumeric(ID)>
	<!--- find template --->
	<cfquery name="ALERTFindTemplateText" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.ID#">
	</cfquery>
	<cfset email_text = ALERTFindTemplateText.email_text>
</cfif>
<cfif NOT isDefined("ID") OR NOT isNumeric(ID) OR ALERTFindTemplateText.RecordCount EQ 0>
	<br><div class="alert" style="padding-left:30px">This email alert template can not be displayed. <br><br>Please contact an administrative user for assistance.</div>
<cfelse>
	<cfif IsDefined('url.prog') AND url.prog NEQ "">
		<!--- find program info --->
		<cfquery name="ALERTGetProgramInfo" datasource="#application.DS#">
			SELECT company_name, Date_Format(expiration_date,'%c/%d/%Y') AS expiration_date
			FROM #application.database#.program
			<cfif FLGen_HasAdminAccess(1000000075)>
			<cfset ThisID = ListGetAt(itc_program,1,'-')>
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ThisID#">
			<cfelse>
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.prog#">
			</cfif>
		</cfquery>
		<!--- swap out the fill in the blank --->
		<cfset email_text = Replace(email_text,"PROGRAM-NAME-HERE","#ALERTGetProgramInfo.company_name#","all")>
		<cfset email_text = Replace(email_text,"PROGRAM-EXPIRATION-DATE","#ALERTGetProgramInfo.expiration_date#","all")>
	</cfif>
	<br><span class="alert" style="letter-spacing:3PX;padding-left:30px">EMAIL ALERT PREVIEW</span><br><br>
	<hr size="1" width="100%">
	<cfoutput>#email_text#</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">
