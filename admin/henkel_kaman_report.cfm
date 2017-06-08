<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="form.FromDate" default="">
<cfparam name="form.ToDate" default="">
<cfparam name="form.TotalOnly" default="0">

<cfset alert_msg = "">

<cfif isDefined("form.submit")>
	<cfif form.FromDate NEQ "" AND NOT isDate(form.FromDate)>
		<cfset alert_msg = alert_msg & "Please enter a valid From Date.\n">
	</cfif>
	<cfif form.ToDate NEQ "" AND NOT isDate(form.ToDate)>
		<cfset alert_msg = alert_msg & "Please enter a valid To Date.\n">
	</cfif>
	<cfif isDate(form.FromDate) AND isDate(form.ToDate) AND DateDiff('d',form.FromDate,form.ToDate) LT 0>
		<cfset alert_msg = alert_msg & "The To Date is earlier than the From Date.\n">
	</cfif>
</cfif>

<cfset leftnavon = "henkel_kaman">
<cfset request.main_width = 1100>
<cfinclude template="includes/header.cfm">

<span class="pageinstructions">Return to the <a href="henkel_kaman.cfm" class="actionlink">Henkel/Kaman Transfer Main Page</a></span>
<br><br>
<span class="pagetitle">Henkel/Kaman Points Transfer Report</span>
<br /><br />
<!--- search box (START) --->
<form action="<cfoutput>#CurrentPage#</cfoutput>" method="post">
	<table cellpadding="5" cellspacing="0" border="0">
		<tr class="contenthead">
			<td colspan="3"><span class="headertext">Select Date Range</span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="sub">(leave dates blank for all dates)</span></td>
		</tr>
		<tr>
				<td class="content" align="right">From Date:</td>
				<td class="content" align="left"><input type="text" name="FromDate" value="<cfoutput>#form.FromDate#</cfoutput>" size="12"></td>
			</tr>
			<tr>
				<td class="content" align="right">To Date:</td>
				<td class="content" align="left"><input type="text" name="ToDate" value="<cfoutput>#form.ToDate#</cfoutput>" size="12"></td>
			</tr>
			<tr class="content">
				<td colspan="2" align="center"><input type="checkbox" name="TotalOnly" value="1" <cfif form.TotalOnly>checked</cfif>>Show Grand Total Only</td>
			</tr>
			<tr class="content">
				<td colspan="2" align="center"><input type="submit" name="submit" value="  Generate Report  "></td>
			</tr>
	</table>
	<br /><br />
</form>

<cfif isDefined("form.submit") AND alert_msg EQ "">
	<cfquery name="ProgramUsers" datasource="#application.DS#">
		SELECT p.ID, a.transfer_datetime, p.username, p.fname, p.lname, p.email, a.points
		FROM #application.database#.points_transfer a
		LEFT JOIN #application.database#.program_user p ON p.ID = a.from_user_ID
		WHERE 1=1
		<cfif isDate(form.FromDate)>
			AND a.transfer_datetime >= <cfqueryparam cfsqltype="cf_sql_date" value="#form.FromDate#">
		</cfif>
		<cfif isDate(form.ToDate)>
			AND a.transfer_datetime <= <cfqueryparam cfsqltype="cf_sql_date" value="#DateAdd('d',1,form.ToDate)#">
		</cfif>
		ORDER BY a.transfer_datetime, p.lname, p.fname
	</cfquery>
	<!--- <cfdump var="#ProgramUsers#"> --->
	<cfset RangeText = "">
	<cfif NOT isDate(form.FromDate) AND NOT isDate(form.ToDate)>
		<cfset RangeText = "Since 10/31/2008">
	<cfelseif form.FromDate EQ form.ToDate>
		<cfset RangeText = "On #DateFormat(form.FromDate,'mm/dd/yyyy')#">
	<cfelse>
		<cfif isDate(form.FromDate)>
			<cfset RangeText = "From #DateFormat(form.FromDate,'mm/dd/yyyy')#">
		</cfif>
		<cfif isDate(form.ToDate)>
			<cfset RangeText = RangeText & " To #DateFormat(form.ToDate,'mm/dd/yyyy')#">
		</cfif>
	</cfif>
	<cfoutput>
	<table cellpadding="5" cellspacing="1" border="0">
		<tr class="contenthead">
			<td colspan="100%"><span class="headertext">Points Transfered From Henkel To Kaman</span></td>
		</tr>
		<tr class="content2">
			<td colspan="100%"><span class="headertext">#RangeText#</span></td>
		</tr>
		<cfif ProgramUsers.recordcount GT 0>
			<cfset TotalPoints = 0>
			<cfif NOT form.TotalOnly>
				<tr class="contenthead">
					<td class="headertext">Name</td>
					<td class="headertext">Email Address</td>
					<td class="headertext">Points</td>
					<td class="headertext">Transfer Date</td>
				</tr>
			</cfif>
			<cfloop query="ProgramUsers">
				<cfif NOT form.TotalOnly>
					<tr class="content<cfif ProgramUsers.currentrow MOD 2 EQ 1>2</cfif>">
						<td>#ProgramUsers.lname#, #ProgramUsers.fname#</td>
						<td>#ProgramUsers.email#</td>
						<td align="right">#ProgramUsers.points#</td>
						<td>#DateFormat(ProgramUsers.transfer_datetime,'mm/dd/yyyy')#</td>
					</tr>
				</cfif>
				<cfset TotalPoints = TotalPoints + ProgramUsers.points>
			</cfloop>
			<tr class="content<cfif NOT form.TotalOnly AND ProgramUsers.recordcount MOD 2 EQ 0>2</cfif>">
				<td colspan="<cfif form.TotalOnly>100%<cfelse>3</cfif>" align="right">Total Points Transferred #RangeText#:&nbsp;&nbsp;&nbsp;<strong>#TotalPoints#</strong></td>
				<cfif NOT form.TotalOnly>
					<td>&nbsp;</td>
				</cfif>
			</tr>
		<cfelse>
			<tr class="content">
				<td colspan="100%">No points were transferred in the selected date range.</td>
			</tr>
		</cfif>
	</table>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">
