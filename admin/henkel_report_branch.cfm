<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess("1000000106-1000000107",true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<!--- <cfset program_ID = 1000000066>  --->
<cfparam name="program_ID" default=1000000066>
<cfset leftnavon = "henkel_report_branch">
<cfif program_ID IS 1000000069>
	<cfset leftnavon = "henkel_report_branch_ca">
</cfif>

<cfparam name="alert_msg" default="">
<cfparam name="Report_Start_Date" default="">
<cfparam name="Report_Stop_Date" default="">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfinclude template="includes/header.cfm">
<span class="highlight"><cfif program_ID EQ "1000000066">&nbsp;&nbsp;U.S.&nbsp;&nbsp;<cfelse>CANADA</cfif></span>

<!--- START pgfn DATE RANGE --->
<cfparam  name="pgfn" default="date_range">
<cfif pgfn EQ "date_range">
	<span class="pagetitle">Henkel Branch Registration List</span>
	<br /><br />
	<form method="post" action="#CurrentPage#" name="addedit">
		<input type="hidden" name="pgfn" value="list">
		<input type="hidden" name="program_ID" value="<cfoutput>#program_ID#</cfoutput>">
		<table cellpadding="5" cellspacing="1" border="0">
			<tr class="BGdark"><td class="TEXTheader" colspan="2">&nbsp;</td></tr>
			<tr class="BGlight1"><td align="right" valign="top" nowrap="nowrap">Report Starting Date: </td><td valign="top"><input type="text" name="Report_Start_Date" value="<cfoutput>#DateFormat(NOW(), 'mm/dd/yyyy')#</cfoutput>" maxlength="10" size="10"><input type="hidden" name="Report_Start_Date_required" value="You must enter a starting date for the report"></td>	</tr>
			<tr class="BGlight1"><td align="right" valign="top" nowrap="nowrap">Report Ending Date: </td><td valign="top"><input type="text" name="Report_Stop_Date" value="<cfoutput>#DateFormat(NOW(), 'mm/dd/yyyy')#</cfoutput>" maxlength="10" size="10"><input type="hidden" name="Report_Stop_Date_required" value="You must enter an ending date for the report"></td>	</tr>
			<tr class="BGlight1"><td colspan="2" align="center"><input type="submit" name="submit" value="Submit" ></td></tr>
		</table>
	</form>
</cfif>
<!--- END pgfn DATE RANGE --->


<!--- START pgfn LIST --->
<cfif pgfn EQ "list">

	<!--- run query --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT DISTINCT PU.idh, CONCAT(HD.company_name, ", ", HD.city, ", ", HD.state) AS Branch, PU.registration_type,
				CONCAT(PU.lname, ", ", PU.fname) AS Registrant, PU.email, HR.alternate_emails
		FROM #application.database#.program_user PU
		LEFT JOIN #application.database#.henkel_distributor HD ON HD.idh = PU.idh
		LEFT JOIN #application.database#.henkel_register HR ON HR.email = PU.email
		WHERE PU.program_ID = <cfqueryparam value="#program_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10"> AND PU.idh > '' and PU.idh != '##N/A'
		<cfif Report_Start_Date GT "">
			AND PU.created_datetime >= <cfqueryparam value="#Report_Start_Date#" cfsqltype="CF_SQL_DATE" maxlength="10">
		</cfif>
		<cfif Report_Stop_Date GT "">
			AND PU.created_datetime <= <cfqueryparam value="#Report_Stop_Date#" cfsqltype="CF_SQL_DATE" maxlength="10">
		</cfif>
		ORDER BY HD.company_name, PU.idh, PU.registration_type, PU.lname, PU.fname
	</cfquery>

	<span class="pagetitle">Henkel Branch Registration List</span>
	<br /><br />
	<cfoutput>
	Program Users created between #DateFormat(Report_Start_Date, 'mm/dd/yyyy')# and #DateFormat(Report_Stop_Date, 'mm/dd/yyyy')#
	</cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<!--- header row --->
	<tr class="contenthead">
	<td><span class="headertext">IDH</span></td>
	<td><span class="headertext">Registered As</span></td>
	<td><span class="headertext">Registrant</span></td>
	<td><span class="headertext">EMail</span></td>
	</tr>

	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
		<td colspan="2" align="center"><span class="alert"><br>No records found.  Click "Add" to create a region.<br><br></span></td>
		</tr>
	</cfif>

	<!--- display found records --->
	<cfset DisplayedRow = 1>
	<cfset LastIDH = "">
	<cfoutput query="SelectList">
		<cfif LastIDH NEQ idh>
			<tr class="contenthead"><td><strong>#htmleditformat(idh)#</strong></td><td colspan="3"><strong>#Branch#</strong></td></tr>
			<cfset LastIDH = idh>
		</cfif>
		<cfset DisplayedRow = DisplayedRow + 1>
		<tr class="#Iif(((DisplayedRow MOD 2) is 0),de('content2'),de('content'))#">
			<td valign="top">&nbsp;&nbsp;&nbsp;</td>
			<td valign="top">#htmleditformat(registration_type)#</td>
			<td valign="top">#htmleditformat(Registrant)#</td>
			<td valign="top">#htmleditformat(email)#</td>
		</tr>
		<cfif SelectList.alternate_emails NEQ "">
			<cfset theseEmails = "">
			<cfloop list="#SelectList.alternate_emails#" index="thisEmail">
				<cfif thisEmail NEQ "">
					<cfset theseEmails = ListAppend(theseEmails, thisEmail)>
				</cfif>
			</cfloop>
			<cfif theseEmails NEQ "">
				<tr class="#Iif(((DisplayedRow MOD 2) is 0),de('content2'),de('content'))#">
					<td colspan="100%">
						Branch Participants: #Replace(theseEmails,",",", ","ALL")#
					</td>
				</tr>
			</cfif>
		</cfif>
	</cfoutput>

	</table>


</cfif>
<!--- END pgfn LIST --->

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->