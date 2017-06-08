<script>
TheWindow = null

function openPreview(TheTemplate)
{

	// if a window exists and is open, close it
	if (TheWindow != null)
	{TheWindow.close()}

	// find the selected one in the select
	previewId = document.getElementById(TheTemplate)
	previewIdValue = previewId.options[previewId.selectedIndex].value
	
	// open new window with preview	
 	TheWindow = window.open('email_alert_preview.cfm?ID='+previewIdValue+'&prog=<cfoutput>#request.henkel_ID#</cfoutput>','windowname');
	
}
</script>
<cfquery name="SelectEmailTemplates" datasource="#application.DS#">
	SELECT ea.ID, ea.email_title 
	FROM #application.database#.email_templates ea
	JOIN #application.database#.xref_program_email xref ON ea.ID = xref.email_alert_ID
	WHERE ea.is_available = 1
		AND xref.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
	ORDER BY ea.email_title ASC
</cfquery>
<cfoutput>
<table cellpadding="5" cellspacing="1" border="0" width="100%">
<cfparam name="form.points" default="">
<cfparam name="form.reason" default="">
	<cfif pgfn EQ "process_simple">
		<tr class="contenthead">
			<td class="headertext">Enter the Points and the Reason for this upload:</td>
		</tr>
		<tr class="content">
			<td>Points to award:  <input type="text" name="points" value="#form.points#" size="5"></td>
		</tr>
		<tr class="content">
			<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Reason:  <input type="text" name="reason" value="#form.reason#" size="60"></td>
		</tr>
	</cfif>
	<tr class="contenthead">
		<td class="headertext">Select Template for EXISTING Users:</td>
	</tr>
	<tr class="content">
		<td>
			<select name="ex_template_ID" id="ex_template_ID">
				<cfloop query="SelectEmailTemplates">
				<option value="#ID#" <cfif isDefined("form.ex_template_ID") AND form.ex_template_ID EQ ID>selected</cfif>>#email_title#</option>
				</cfloop>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview('ex_template_ID');return false;">preview selected template</a>

		</td>
	</tr>
<cfif NOT request.selected_henkel_program.is_registration_closed>
	<tr class="contenthead">
		<td class="headertext">Select Template for PENDING Users:</td>
	</tr>
	<tr class="content">
		<td>
			<select name="pe_template_ID" id="pe_template_ID">
				<cfloop query="SelectEmailTemplates">
				<option value="#ID#" <cfif isDefined("form.pe_template_ID") AND form.pe_template_ID EQ ID>selected</cfif>>#email_title#</option>
				</cfloop>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview('pe_template_ID');return false;">preview selected template</a>

		</td>
	</tr>
</cfif>
<cfif request.selected_henkel_program.has_branch_participation>
	<tr class="contenthead">
		<td class="headertext">Select Template for BRANCH PARTICIPANTS:</td>
	</tr>
	<tr class="content">
		<td>
			<select name="bp_template_ID" id="bp_template_ID">
				<cfloop query="SelectEmailTemplates">
				<option value="#ID#" <cfif isDefined("form.bp_template_ID") AND form.bp_template_ID EQ ID>selected</cfif>>#email_title#</option>
				</cfloop>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview('bp_template_ID');return false;">preview selected template</a>

		</td>
	</tr>
	<tr class="contenthead">
		<td class="headertext">Select Template for BRANCH LEADERS:</td>
	</tr>
	<tr class="content">
		<td>
			<select name="bl_template_ID" id="bl_template_ID">
				<cfloop query="SelectEmailTemplates">
				<option value="#ID#" <cfif isDefined("form.bl_template_ID") AND form.bl_template_ID EQ ID>selected</cfif>>#email_title#</option>
				</cfloop>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;<a href="##" onClick="openPreview('bl_template_ID');return false;">preview selected template</a>

		</td>
	</tr>
</cfif>
<cfparam name="form.emailFrom" default="">
<cfparam name="form.emailSubject" default="">
	<tr class="contenthead">
		<td class="headertext">From address and subject for all emails:</td>
	</tr>
	<tr class="content">
		<td>&nbsp;&nbsp;&nbsp;&nbsp;From:  <input type="text" name="emailFrom" value="#application.AwardsFromEmail#" size="40" readonly></td>
	</tr>
	<tr class="content">
		<td>Subject:  <input type="text" name="emailSubject" value="#form.emailSubject#" size="40"></td>
	</tr>
	<tr class="content">
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CC:
			<input type="checkbox" name="cc_loctite_rep" value="1" checked>
			CC the Henkel regional sales representative on each email, where possible.
		</td>
	</tr>
	<tr class="content">
		<td align="center">
			<input type="submit" name="process" value="  Process All Records  " onClick="if ( ! confirm('Are you sure?')) return false;">
		</td>
	</tr>
	<tr class="contenthead">
		<td class="headertext">Test Email:</td>
	</tr>
	<tr class="content">
		<td>&nbsp;&nbsp;Recipient:  <input type="text" name="emailTo" value="" size="40"></td>
	</tr>
	<tr class="content">
		<td align="center">
			<input type="submit" name="test_email" value="  Send Test Email for each Template  ">
		</td>
	</tr>
	<input type="hidden" name="bonus_points" value="#bonus_points#">
	<tr><td align="right">
		<input type="checkbox" name="bonus_points_company" value="fastenal" <cfif ListFind(bonus_points_company,"fastenal")>checked</cfif>> Fastenal<br>
		<input type="checkbox" name="bonus_points_company" value="applied" <cfif ListFind(bonus_points_company,"applied")>checked</cfif>> Applied&nbsp;<br>
		<input type="submit" name="toggle_bonus_points" value="  <cfif bonus_points>DO NOT </cfif>Double Points  ">
	</td></tr>
</table>
</cfoutput>