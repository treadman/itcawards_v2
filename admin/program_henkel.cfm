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

<cfparam name="ID" default="">
<cfif NOT isNumeric(ID) OR ID LTE 0>
	<cflocation addtoken="no" url="program_list.cfm">
</cfif>

<cfquery name="CheckProgram" datasource="#application.DS#">
	SELECT company_name, program_name
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>

<cfif CheckProgram.recordcount NEQ 1>
	<cflocation addtoken="no" url="program_list.cfm">
</cfif>

<cfquery name="SelectEmailTemplates" datasource="#application.DS#">
	SELECT ea.ID, ea.email_title 
	FROM #application.database#.email_templates ea
	JOIN #application.database#.xref_program_email xref ON ea.ID = xref.email_alert_ID
	WHERE ea.is_available = 1
		AND xref.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
	ORDER BY ea.email_title ASC
</cfquery>

<!--- param a/e form fields --->
<cfparam name="has_distributors" default="1">
<cfparam name="has_regions" default="1">
<cfparam name="is_region_by_state" default="0">
<cfparam name="is_canadian" default="0">
<cfparam name="default_IDH" default="">
<cfparam name="default_domain" default="">
<cfparam name="registration_template_ID" default="">
<cfparam name="has_branch_participation" default="0">
<cfparam name="do_report_export" default="0">
<cfparam name="do_report_billing" default="0">
<cfparam name="do_report_branch" default="0">
<cfparam name="filename_extension" default="">
<cfparam name="is_registration_closed" default="0">
<cfparam name="distributor_label" default="Distributor">
<cfparam name="cc_max_default" default="">
<cfif NOT isNumeric(cc_max_default)>
	<cfset cc_max_default = 0>
</cfif>

<cfquery name="CheckHenkelProgram" datasource="#application.DS#">
	SELECT ID
	FROM #application.database#.program_henkel
	WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.SaveChanges')>

	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.program
		SET	cc_max_default = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#cc_max_default#" maxlength="6">
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>

	<!--- update --->
	<cfif CheckHenkelProgram.recordcount EQ 1>
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.program_henkel
			SET	has_distributors = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_distributors#" maxlength="1">,
				has_regions = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_regions#" maxlength="1">,
				is_region_by_state = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_region_by_state#" maxlength="1">,
				is_canadian = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_canadian#" maxlength="1">,
				default_IDH = <cfqueryparam cfsqltype="cf_sql_varchar" value="#default_IDH#" maxlength="16">,
				default_domain = <cfqueryparam cfsqltype="cf_sql_varchar" value="#default_domain#" maxlength="64">,
				registration_template_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#registration_template_ID#" maxlength="10">,
				has_branch_participation = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_branch_participation#" maxlength="1">,
				do_report_export = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#do_report_export#" maxlength="1">,
				do_report_billing = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#do_report_billing#" maxlength="1">,
				do_report_branch = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#do_report_branch#" maxlength="1">,
				filename_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#filename_extension#" maxlength="8">,
				is_registration_closed = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_registration_closed#" maxlength="1">,
				distributor_label = <cfqueryparam cfsqltype="cf_sql_varchar" value="#distributor_label#" maxlength="32">
			WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelseif CheckHenkelProgram.recordcount EQ 0>
		<cfquery name="InsertQuery" datasource="#application.DS#">
			INSERT INTO #application.database#.program_henkel
				( program_ID, has_distributors, has_regions, is_region_by_state, is_canadian, default_IDH, default_domain,
					registration_template_ID, has_branch_participation, do_report_export, do_report_billing,
					do_report_branch, filename_extension, is_registration_closed, distributor_label )
			VALUES (
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_distributors#" maxlength="1">, 
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_regions#" maxlength="1">, 
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_region_by_state#" maxlength="1">, 
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_canadian#" maxlength="1">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#default_IDH#" maxlength="16">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#default_domain#" maxlength="64">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#registration_template_ID#" maxlength="10">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#has_branch_participation#" maxlength="1">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#do_report_export#" maxlength="1">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#do_report_billing#" maxlength="1">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#do_report_branch#" maxlength="1">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#filename_extension#" maxlength="8">,
				<cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_registration_closed#" maxlength="1">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#distributor_label#" maxlength="32">
			)
		</cfquery>
	<cfelse>
		<cfabort showerror="There are duplicate records in the henkel_program table for program: #ID#!">
	</cfif>
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

<cfif CheckHenkelProgram.recordcount EQ 1>
	<cfquery name="GetHenkelProgram" datasource="#application.DS#">
		SELECT program_ID, has_distributors, has_regions, is_region_by_state, is_canadian, default_IDH, default_domain,
			registration_template_ID, has_branch_participation, do_report_export, do_report_billing,
			do_report_branch, filename_extension, is_registration_closed, distributor_label
		FROM #application.database#.program_henkel
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
	</cfquery>
<cfelse>
	<cfset GetHenkelProgram = StructNew()>
	<cfset GetHenkelProgram.has_distributors = 1>
	<cfset GetHenkelProgram.has_regions = 1>
	<cfset GetHenkelProgram.is_region_by_state = 0>
	<cfset GetHenkelProgram.is_canadian = 0>
	<cfset GetHenkelProgram.default_IDH = "">
	<cfset GetHenkelProgram.default_domain = "">
	<cfset GetHenkelProgram.registration_template_ID = "">
	<cfset GetHenkelProgram.has_branch_participation = 0>
	<cfset GetHenkelProgram.do_report_export = 1>
	<cfset GetHenkelProgram.do_report_billing = 1>
	<cfset GetHenkelProgram.do_report_branch = 1>
	<cfset GetHenkelProgram.filename_extension = "">
	<cfset GetHenkelProgram.is_registration_closed = 0>
	<cfset GetHenkelProgram.distributor_label = "Distributor">
</cfif>

<cfquery name="GetProgram" datasource="#application.DS#">
	SELECT cc_max_default 
	FROM #application.database#.program
	WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
</cfquery>

<cfoutput>
<span class="pagetitle">Edit Henkel Program Parameters for: #CheckProgram.company_name# [#CheckProgram.program_name#]</span>
<br />
<br />
<span class="pageinstructions">Return to <a href="program_details.cfm?&id=#ID#">Award Program Details</a> or <a href="program_list.cfm">Award Program List</a> without making changes.</span>
<br /><br />

<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext">Henkel Program Parameters</td>
	</tr>
	<cfset thisLabel = trim(GetHenkelProgram.distributor_label)>
	<cfif right(thisLabel,1) EQ "y">
		<cfset thisLabel = Left(thisLabel, Len(thisLabel)-1) & "ie">
	</cfif>
	<tr class="content">
	<td width="50%" align="right" >Has #LCase(thisLabel)#s?<br><span class="sub"></span></td>
	<td width="50%">
		<select name="has_distributors">
			<option value="1"<cfif GetHenkelProgram.has_distributors EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.has_distributors EQ 0> selected</cfif>>No
		</select>
		&nbsp;&nbsp;&nbsp;&nbsp;
		Label:&nbsp;&nbsp;<input type="text" name="distributor_label" value="#GetHenkelProgram.distributor_label#" maxlength="32" size="20">
	</td>
	</tr>

	<tr class="content">
	<td align="right">Has regions?</td>
	<td>
		<select name="has_regions">
			<option value="1"<cfif GetHenkelProgram.has_regions EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.has_regions EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right">Is Region Lookup by State?<br><span class="sub"><em>Used to determine how to lookup regions.</em></span></td>
	<td>
		<select name="is_region_by_state">
			<option value="1"<cfif GetHenkelProgram.is_region_by_state EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.is_region_by_state EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right">Is Canadian?<br><span class="sub"><em>Used to determine how to lookup zip codes.</em></span></td>
	<td>
		<select name="is_canadian">
			<option value="1"<cfif GetHenkelProgram.is_canadian EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.is_canadian EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right">Default IDH number:</td>
	<td><input type="text" name="default_IDH" value="#GetHenkelProgram.default_IDH#" maxlength="16" size="20"></td>
	</tr>

	<tr class="content">
	<td align="right">Default Email Domain:<br><span class="sub"><em>Used during import to create email addresses.</em></span></td>
	<td><input type="text" name="default_domain" value="#GetHenkelProgram.default_domain#" maxlength="64" size="20"></td>
	</tr>

	<tr class="content">
	<td align="right">Registration Email Template:<br><span class="sub"><em>Sent when ADMIN approves registration.<br>DOES NOT AFFECT PUBLIC REG. FORM!!</em></span></td><br>
	<td>
		<select name="registration_template_ID" id="e_template_ID">
			<option value="0">--- Select Template ---</option>
			<cfloop query="SelectEmailTemplates">
			<option value="#SelectEmailTemplates.ID#" <cfif GetHenkelProgram.registration_template_ID EQ SelectEmailTemplates.ID>selected</cfif>>#SelectEmailTemplates.email_title#</option>
			</cfloop>
		</select>
		<!--- &nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview('e_template_ID');return false;">preview selected template</a> --->
	</td>
	</tr>

	<tr class="content">
	<td align="right">Has Branch Participation?<br><span class="sub"><em>If yes, points are awarded to the branch participant leader when points are uploaded.</em></span></td>
	<td>
		<select name="has_branch_participation">
			<option value="1"<cfif GetHenkelProgram.has_branch_participation EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.has_branch_participation EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right">Export Reports to FTP?</td>
	<td>
		<select name="do_report_export">
			<option value="1"<cfif GetHenkelProgram.do_report_export EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.do_report_export EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right">Show Billing Report?</td>
	<td>
		<select name="do_report_billing">
			<option value="1"<cfif GetHenkelProgram.do_report_billing EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.do_report_billing EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right">Show Branch Report?</td>
	<td>
		<select name="do_report_branch">
			<option value="1"<cfif GetHenkelProgram.do_report_branch EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.do_report_branch EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>

	<tr class="content">
	<td align="right">Filename Prefix:<br><span class="sub"><em>For exported files.</em></span></td>
	<td><input type="text" name="filename_extension" value="#GetHenkelProgram.filename_extension#" maxlength="8" size="8">&nbsp;&nbsp;&nbsp;<span class="sub"><em>Ex: <strong>us</strong>_branch_report.csv</em></span></td>
	</tr>

	<tr class="content">
	<td align="right">Is Registration Closed?<br><span class="sub"><em>Stops uploads from creating "hold users".</em></span></td>
	<td>
		<select name="is_registration_closed">
			<option value="1"<cfif GetHenkelProgram.is_registration_closed EQ 1> selected</cfif>>Yes
			<option value="0"<cfif GetHenkelProgram.is_registration_closed EQ 0> selected</cfif>>No
		</select>
	</td>
	</tr>
	<tr class="content">
		<td align="right">Default Credit Card Maximum: </td>
	<td><input type="text" name="cc_max_default" value="#GetProgram.cc_max_default#" maxlength="6" size="8"></td>
	</tr>

	<tr class="content">
	<td colspan="2" align="center">

	<input type="hidden" name="ID" value="#ID#">
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="SaveChanges" value="Save" >

	</td>
	</tr>

	</table>


</form>
</cfoutput>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->