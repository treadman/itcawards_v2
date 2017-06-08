<!--- function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">


<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000037,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="program_ID" default="">
<cfparam name="FromDate" default="">
<cfparam name="ToDate" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">

<cfset program_name = "">
<cfif program_ID NEQ "">
	<cfset program_name = FLITC_GetProgramName(program_ID)>
</cfif>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "newbillingreport">
<cfset request.main_width = 900>
<cfinclude template="includes/header.cfm">



<span class="pagetitle">Billing Report<cfif program_name NEQ ""> for <cfoutput>#program_name#</cfoutput></cfif></span>
<br /><br />
<!--- find program's min max order dates --->
	<cfif IsDefined('form.submit')>
		<cfif FromDate EQ "" OR ToDate EQ "">
			<cfquery name="MinMaxOrderDates" datasource="#application.DS#">
				SELECT MIN(created_datetime) AS first_order, MAX(created_datetime) AS last_order 
				FROM #application.database#.order_info
				WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
					AND is_valid = 1
			</cfquery>
			<cfif FromDate EQ "" AND MinMaxOrderDates.first_order NEQ "">
				<cfset FromDate = FLGen_DateTimeToDisplay(MinMaxOrderDates.first_order)>
			<cfelseif FromDate EQ "">
				<cfset FromDate = FLGen_DateTimeToDisplay()>
			</cfif>
			<cfif ToDate EQ "" AND MinMaxOrderDates.last_order NEQ "">
				<cfset ToDate = FLGen_DateTimeToDisplay(MinMaxOrderDates.last_order)>
			<cfelseif ToDate EQ "">
				<cfset ToDate = FLGen_DateTimeToDisplay()>
			</cfif>
		</cfif>
		<cfset FromDate = FLGen_DateTimeToDisplay(FromDate)>
		<cfset formatFromDate = FLGen_DateTimeToMySQL(FromDate)>
		<cfset ToDate = FLGen_DateTimeToDisplay(ToDate)>
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
	</cfif>

	<cfoutput>
	<!--- search box (START) --->
	<table cellpadding="5" cellspacing="0" border="0" width="500">
		<tr class="contenthead">
			<td colspan="3"><span class="headertext">Generate Billing Report</span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="sub">(dates are optional)</span></td>
		</tr>
		<form action="#CurrentPage#" method="post">
			<tr>
				<td class="content">
					#SelectProgram(program_ID)#
					<input type="hidden" name="program_ID_required" value="You must select a program">
				</td>
				<td class="content" align="right">From Date: </td>
				<td class="content" align="left"><input type="text" name="FromDate" value="#FromDate#" size="12"></td>
			</tr>
			<tr>
				<td class="content">
				</td>
				<td class="content" align="right">To Date:</td>
				<td class="content" align="left"><input type="text" name="ToDate" value="#ToDate#" size="12"></td>
			</tr>
			<tr class="content">
				<td colspan="3" align="center"><input type="submit" name="submit" value="Generate Report"></td>
			</tr>
		</form>
	</table>
	<br /><br />
	</cfoutput>
	<!--- search box (END) --->


<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->

<cfif IsDefined('form.submit') AND isNumeric(program_ID)>
	<cfset displayed_anything = false>
	<!--- find the users for this program --->
	<cfquery name="FindAllUsers" datasource="#application.DS#">
		SELECT DISTINCT u.fname, u.lname, u.ID, u.nickname, u.email, u.username
		FROM #application.database#.program_user u
		JOIN #application.database#.order_info o ON o.created_user_ID = u.ID
		WHERE u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
			AND o.order_number > 0
			AND o.is_valid = 1
			AND o.created_datetime >= <cfqueryparam value="#formatFromDate#">
			AND o.created_datetime <= <cfqueryparam value="#formatToDate#">
		ORDER BY u.lname ASC 
	</cfquery>
	<!--- <cfdump var="#FindAllUsers#"><cfabort> --->
	<cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<!--- header row --->
		<tr class="content2">
			<td colspan="100%"><span class="headertext">Program: <span class="selecteditem">#program_name#</span></span></td>
		</tr>
		<tr class="content2">
			<td colspan="100%"><span class="headertext">Dates:&nbsp;&nbsp;&nbsp;<span class="selecteditem">#FromDate#<span class="reg">&nbsp;&nbsp;&nbsp;to&nbsp;&nbsp;&nbsp;</span>#ToDate#</span></span></td>
		</tr>
		<tr class="contenthead">
			<td class="headertext" rowspan="2">Username</td>
			<td class="headertext" rowspan="2">Name</td>
			<td class="headertext" rowspan="2">Email Address</td>
			<td class="headertext" align="center" colspan="3">Total Points</td>
			<td class="headertext" rowspan="2">Last Order<br>in Range</td>
		</tr>
		<tr class="contenthead">
			<td class="headertext" align="center">Awd.</td>
			<td class="headertext" align="center">Used</td>
			<td class="headertext" align="center">Rem.</td>
		</tr>
		<cfloop query="FindAllUsers">
			<cfset username = FindAllUsers.username>
			<cfset fname = FindAllUsers.fname>
			<cfset lname = FindAllUsers.lname>
			<cfset ID = FindAllUsers.ID>
			<cfset nickname = FindAllUsers.nickname>
			<cfset email = FindAllUsers.email>
			<cfquery name="getOrders" datasource="#application.DS#">
				SELECT ID, created_user_ID, created_datetime, order_number, points_used
				FROM #application.database#.order_info
				WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
					AND is_valid = 1
					AND created_datetime >= <cfqueryparam value="#formatFromDate#">
					AND created_datetime <= <cfqueryparam value="#formatToDate#">
				ORDER BY created_datetime DESC
			</cfquery>
			#ProgramUserInfoConstrained(ID,formatFromDate,formatToDate)# 
			<cfset usedPoints = 0>
			<cfloop query="getOrders">
				<cfset usedPoints = usedPoints + points_used>
				<cfset this_order_date = FLGen_DateTimeToDisplay(getOrders.created_datetime)>
			</cfloop>
			<tr class="content">
				<td>#username#</td>
				<td>#lname#, #fname#<cfif nickname NEQ ""> (#nickname#)</cfif></td>
				<td>#email#</td>
				<td align="right">#BRp_pospoints#</td>
				<td align="right">#usedPoints#<!--- #BRp_negpoints# ---></td>
				<td align="right">#BRp_totalpoints#</td>
				<td>#this_order_date#<!---BRp_last_order---><cfset displayed_anything = true></td>
			</tr>
			<cfif getOrders.recordcount GT 0>
				<cfloop query="getOrders">
					<cfif isNumeric(getOrders.points_used) and getOrders.points_used GT 0>
						<tr>
							<td colspan="100%">
								Order #getOrders.order_number# -
								#dateFormat(getOrders.created_datetime,"mm/dd/yyyy")# -
								#getOrders.points_used# points
								<cfquery name="getItems" datasource="#application.DS#">
									SELECT quantity, snap_meta_name, snap_productvalue, snap_options
									FROM #application.database#.inventory
									WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getOrders.ID#">
								</cfquery>
								<cfif getItems.recordcount GT 0>
									<cfloop query="getItems">
										<br>&nbsp;&nbsp;&nbsp;#getItems.quantity# #getItems.snap_meta_name# #getItems.snap_options# (#DollarFormat(getItems.snap_productvalue)# value)
									</cfloop>
									<br>
								<cfelse>
									NO LINE ITEMS FOUND!
								</cfif>
							</td>
						</tr>
					</cfif>
				</cfloop>
			<cfelse>
				<tr><td colspan="100%">NO ORDERS FOUND<!--- This should never happen ---></td></tr>
			</cfif>
		</cfloop>
	</table>
	</cfoutput>
	<cfif NOT displayed_anything>
		<span class="alert">There is no information to display.</span>
	</cfif>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->