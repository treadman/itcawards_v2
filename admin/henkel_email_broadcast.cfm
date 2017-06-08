<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="form.user_type" default="active">
<cfparam name="form.get_users" default="">
<cfparam name="form.year" default="">

<cfset max_year = 0>
<cfset min_year = 0>

<cfswitch expression="#form.year#">
	<cfcase value="2012">
		<cfset max_year = 2012>
		<cfset min_year = 0>
	</cfcase>
	<cfcase value="2013">
		<cfset max_year = 2013>
		<cfset min_year = 2013>
	</cfcase>
	<cfcase value="2014">
		<cfset max_year = 2014>
		<cfset min_year = 2014>
	</cfcase>
	<cfcase value="2015">
		<cfset max_year = 2015>
		<cfset min_year = 2015>
	</cfcase>
	
</cfswitch>

<cfset request.main_width="1300">
<cfset leftnavon = 'henkel_email_broadcast'>
<cfinclude template="includes/header.cfm">

<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>
<br><br>
<cfif form.get_users EQ "" OR max_year EQ 0>
	<p class="pageinstructions">Users who have not placed orders</p>
	<br><br>
	<form action="<cfoutput>#CurrentPage#</cfoutput>" method="post">
	<table cellpadding="5" cellspacing="0" border="0">
		<tr class="contenthead">
			<th colspan="2">Select Year</th>
			<td>&nbsp;&nbsp;&nbsp;</td>
			<th colspan="2">Select User Type</th>
		</tr>
		<tr class="content">
			<td><input type="radio" name="year" value="2012" checked></td>
			<td>Prior to 2013</td>
			<td></td>
			<td><input type="radio" name="user_type" value="active" <cfif form.user_type EQ "active">checked</cfif>></td>
			<td>Active Users</td>
		</tr>
		<tr class="content">
			<td><input type="radio" name="year" value="2013"></td>
			<td>2013</td>
			<td></td>
			<td><input type="radio" name="user_type" value="hold" <cfif form.user_type EQ "hold">checked</cfif>></td>
			<td>Holding Tank</td>
		</tr>
		<tr class="content">
			<td><input type="radio" name="year" value="2014"></td>
			<td>2014</td>
			<td></td>
			<td></td>
			<td></td>
		</tr>
		<tr class="content">
			<td><input type="radio" name="year" value="2015"></td>
			<td>2015</td>
			<td></td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<td colspan="3" align="center"><br><input type="submit" name="get_users" value="Get Users"></td>
		</tr>
	</table>
	</form>
<cfelse>
	<p class="pageinstructions"><a href="<cfoutput>#CurrentPage#</cfoutput>">start over</a></p>
	<cfif form.user_type EQ "active">
		<cfquery name="GetAll" datasource="#application.DS#">
			SELECT u.ID, u.fname, u.lname, u.username, u.email, u.created_datetime, MAX(p.created_datetime) AS last_awarded
			FROM ITCAwards.program_user u
			LEFT JOIN ITCAwards.awards_points p ON p.user_ID = u.ID
			WHERE u.program_ID = #request.henkel_ID#
			AND u.is_active = 1
			AND YEAR(u.created_datetime) <= #max_year#
			AND YEAR(u.created_datetime) >= #min_year#
			AND u.ID NOT IN (
				SELECT created_user_ID
			    FROM ITCAwards.order_info
		    	WHERE program_ID = #request.henkel_ID#
			    AND is_valid = 1
			)
			GROUP BY u.ID
			ORDER BY u.created_datetime
		</cfquery>
		<cfoutput>
			<p class="pageinstructions">#GetAll.recordcount# users created 
			<cfif min_year EQ 0>up to<cfelseif min_year NEQ max_year>between #min_year# and<cfelse>in</cfif>
			#max_year# who have not placed an order.</p>
		</cfoutput>
		<table cellpadding="5" cellspacing="0" border="0">
			<tr class="contenthead">
				<td class="headertext">Username</td>
				<td class="headertext">Name</td>
				<td class="headertext">Email</td>
				<td class="headertext">Created</td>
				<td class="headertext">Last Awarded Points</td>
			</tr>
			<cfoutput query="GetAll">
				<tr class="content<cfif GetAll.currentrow MOD 2 EQ 0>2</cfif>">
					<td><a target="points" href="program_points.cfm?puser_ID=#GetAll.ID#&program_ID=#request.henkel_ID#">#GetAll.username#</a></td>
					<td>#GetAll.fname# #GetAll.lname#</td>
					<td>#GetAll.email#</td>
					<td>#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#</td>
					<td>#DateFormat(last_awarded,'mm-dd-yyyy')#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelseif form.user_type EQ "hold">
		<cfquery name="GetAll" datasource="#application.DS#">
			SELECT MAX(h.created_datetime) as last_awarded, MIN(h.created_datetime) as created_on, h.email, SUM(h.points) as points, u.ID, u.username, u.is_active
			FROM #application.database#.henkel_hold_user h
			LEFT JOIN #application.database#.program_user u ON h.email = u.email AND h.program_ID = u.program_ID AND u.registration_type != 'BranchHQ'
			WHERE h.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
			GROUP BY h.email
			ORDER BY h.created_datetime
		</cfquery>
		<cfoutput>
			<p class="pageinstructions">Holding tank users last awarded points  
			<cfif min_year EQ 0>up to<cfelseif min_year NEQ max_year>between #min_year# and<cfelse>in</cfif>
			#max_year#.</p>
		</cfoutput>
		<table cellpadding="5" cellspacing="0" border="0">
			<tr class="contenthead">
				<td class="headertext">Name</td>
				<td class="headertext">Email</td>
				<td class="headertext">Created</td>
				<td class="headertext">Last Awarded Points</td>
			</tr>
			<cfset this_row = 1>
			<cfoutput query="GetAll">
				<cfif DateFormat(GetAll.last_awarded,"yyyy") GTE min_year AND DateFormat(GetAll.last_awarded,"yyyy") LTE max_year>
				
					<tr class="content<cfif this_row MOD 2 EQ 0>2</cfif>">
						<td>
							<cfloop list="MRO OEM,Joint Sales Call,Loctite University,Distributor Training School,Documented Cost Savings Event,Air Leak or Hydraulic Leak Survey" index="this_school">
								<cfquery name="GetName" datasource="#application.DS#">
									SELECT fname,lname
									FROM 
									<cfswitch expression="#this_school#">
										<cfcase value="MRO OEM">
											#application.database#.henkel_import_mro_oem
										</cfcase>
										<cfcase value="Joint Sales Call">
											#application.database#.henkel_import_jsc
										</cfcase>
										<cfcase value="Loctite University">
											#application.database#.henkel_import_lu
										</cfcase>
										<cfcase value="Distributor Training School">
											#application.database#.henkel_import_dts
										</cfcase>
										<cfcase value="Documented Cost Savings Event">
											#application.database#.henkel_import_dcse
										</cfcase>
										<cfcase value="Air Leak or Hydraulic Leak Survey">
											#application.database#.henkel_import_leak
										</cfcase>
									</cfswitch>
									WHERE email = '#GetAll.email#'
								</cfquery>
								<cfif GetName.recordcount GT 0>
									#GetName.fname# #GetName.lname# (#this_school#)<br>
								</cfif>
							</cfloop>
						</td>
						<td>#GetAll.email#</td>
						<td>#DateFormat(GetAll.created_on,'mm-dd-yyyy')#</td>
						<td>#DateFormat(last_awarded,'mm-dd-yyyy')#</td>
						<cfif GetAll.is_active NEQ "">
							<td>
								USER EXISTS!
								<a target="points" href="program_points.cfm?puser_ID=#GetAll.ID#&program_ID=#request.henkel_ID#">#GetAll.username#</a>
								- <cfif GetAll.is_active>Active<cfelse>Inactive</cfif>
							</td>
						</cfif>
					</tr>
					<cfset this_row = this_row + 1>
				</cfif>
			</cfoutput>
		</table>
	</cfif>

</cfif>

<cfinclude template="includes/footer.cfm">
