<cfabort showerror="Look before you leap!">

<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/includes/function_library_itcawards.cfm">

<cfset FLGen_AuthenticateAdmin()>
<cfset program_ID = 1000000010>

<cfset cur_row = 0>

<cfspreadsheet action="read" src="#application.FilePath#admin/upload/kaman.xlsx" sheet="2" query="kaman_spreadsheet"> 

<cfinclude template="../includes/header_lite.cfm">

<!---<cfdump var="#kaman_spreadsheet#">--->
<cfoutput>
<table cellpadding="5" cellspacing="1" border="0">
	<!--- header row --->
	<tr class="content2">
		<td colspan="100%"><span class="headertext">Program: <span class="selecteditem">Kaman</span></span></td>
	</tr>
	<tr class="contenthead">
		<td class="headertext">Row</td>
		<td class="headertext">Username</td>
		<td class="headertext">Name</td>
		<td class="headertext">Email</td>
		<td class="headertext">Points</td>
		<td class="headertext">Subprogram</td>
	</tr>
	
	<cfloop query="kaman_spreadsheet">
		<cfset errors = false>
		<cfif NOT ListFind('1,2,3,7,12,13,14,15,16,18,24,25,30,38,41,43,44,45,46,47,49,51,54,56,58,59,60,61,64,66,68,69,71',currentrow)>
			<cfquery name="GetUser" datasource="#application.DS#">
				SELECT U.ID, U.username, U.fname, U.lname, U.email, p.company_name, U.is_active
				FROM #application.database#.program_user U
				LEFT JOIN #application.database#.program p on p.id = U.program_id
				WHERE U.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">
				AND U.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#kaman_spreadsheet.col_1#">
			</cfquery>
			<cfif GetUser.recordcount NEQ 1>
				<cfabort showerror="Problem with row #currentrow#">
			</cfif>
			<cfset this_user_id = GetUser.ID>
			<cfset this_output = "">
			<cfset ProgramUserInfo(this_user_id)>
			<cfset this_points = user_totalpoints>
			<cfquery name="GetOrders" datasource="#application.DS#">
				SELECT created_datetime, ((points_used * credit_multiplier)/points_multiplier) AS points
				FROM #application.database#.order_info
				WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#" maxlength="10">
				AND is_valid = 1
				ORDER BY created_datetime
			</cfquery>
			<cfif GetOrders.recordcount GT 0>
				<cfloop query="GetOrders">
					<cfset this_points = this_points + GetOrders.points>
				</cfloop>
			</cfif>
			<cfquery name="SubPoints" datasource="#application.DS#">
				SELECT SP.subprogram_name, SUM(P.subpoints) AS points, P.user_ID, P.subprogram_ID
				FROM #application.database#.subprogram_points P
				LEFT JOIN #application.database#.subprogram SP ON SP.ID = P.subprogram_ID
				WHERE P.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#">
				GROUP BY P.user_id, P.subprogram_ID
				HAVING points != 0
			</cfquery>
			<cfif SubPoints.recordcount gt 0>
				<cfset matched = false>
				<cfsavecontent variable="this_output">
					<cfloop query="SubPoints">
						<cfset col5_name = ListFirst(kaman_spreadsheet.col_5,":")>
						<cfset col5_points = mid(ListLast(kaman_spreadsheet.col_5,":"),2,999)>
						<cfif NOT matched AND SubPoints.points EQ col5_points>
							<cfset matched = true>
							<cfloop list="#SubPoints.subprogram_name#" delimiters=" " index="this_word">
								<cfif NOT col5_name CONTAINS this_word>
									<cfset matched = false>
								</cfif>
							</cfloop>
						</cfif>
						#Replace(SubPoints.subprogram_name,' ','&nbsp;','ALL')#: #SubPoints.points#<br>
						<cfset this_points = this_points - SubPoints.points>
					</cfloop>
					<cfif NOT matched>
						<span class="alert">MISMATCH</span>
						<cfset errors = true>
					</cfif>
				</cfsavecontent>
			</cfif>
			<cfset cur_row = cur_row + 1>
			<tr class="<cfif cur_row MOD 2>content2<cfelse>content</cfif>">
				<td>#currentrow#</td>
				<td>#kaman_spreadsheet.col_1#</td>
				<td>#kaman_spreadsheet.col_2#</td>
				<td>#kaman_spreadsheet.col_3#</td>
				<td align="right">#kaman_spreadsheet.col_4#</td>
				<td>#kaman_spreadsheet.col_5#</td>
			</tr>
			<cfif this_points neq 0>
				<tr class="<cfif cur_row MOD 2>content2<cfelse>content</cfif>">
					<td>Orders: #GetOrders.recordcount#</td>
					<td>
						#GetUser.username#
						<cfif GetUser.username NEQ kaman_spreadsheet.col_1>
							<cfset errors = true>
							<br><span class="alert">MISMATCH</span>
						</cfif>
					</td>
					<td>#GetUser.lname#, #GetUser.fname#</td>
					<td>
						#GetUser.email#
						<cfif GetUser.email NEQ kaman_spreadsheet.col_3>
							<cfset errors = true>
							<br><span class="alert">MISMATCH</span>
						</cfif>
					</td>
					<td align="right">
						#user_totalpoints#
						<cfif user_totalpoints NEQ kaman_spreadsheet.col_4>
							<cfset errors = true>
							<br><span class="alert">MISMATCH</span>
						</cfif>
						<cfif user_totalpoints LT 0>
							<cfset errors = true>
							<br><span class="alert">NEGATIVE BALANCE</span>
						</cfif>
					</td>
					<td>
						#this_output#
					</td>
				</tr>
			</cfif>
			<tr class="<cfif cur_row MOD 2>content2<cfelse>content</cfif>">
				<td colspan="6">
					<cfset last_orders = '2015-12-01'>
					<cfquery name="GetNew" dbtype="query" >
						SELECT *
						FROM GetOrders
						WHERE created_datetime > '#last_orders#'
					</cfquery>
					<cfif GetNew.recordcount GT 0>
						<br><span class="alert">Had orders since #last_orders#</span>
						<cfset errors = true>
						<br>#ValueList(GetNew.created_datetime,'<br>')#
					</cfif>
					<cfif errors>
						<span class="alert">PLEASE FIX BEFORE PROCEEDING</span>
						<br><br>
						<cfbreak>
					<cfelse>
						<cfif GetUser.is_active>
							deactivate:<br>
							<cfquery name="UpdateUser" datasource="#application.DS#">
								UPDATE #application.database#.program_user
								SET is_active = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
								WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_user_id#">
							</cfquery>
						</cfif>
						<cfif SubPoints.recordcount gt 0>
							<cfloop query="SubPoints">
								zero #SubPoints.subprogram_name#:#SubPoints.points#<br>
								<cfset update_points = 0 - SubPoints.points>
								<cfquery name="ZeroSubPoints" datasource="#application.DS#">
									INSERT INTO #application.database#.subprogram_points
										(
											created_user_ID, created_datetime, modified_concat,
											subprogram_ID, user_ID, subpoints
										)
									VALUES (
										<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#',
										'Kaman terminations 3/6/2015',
										<cfqueryparam cfsqltype="cf_sql_integer" value="#SubPoints.subprogram_id#" maxlength="10">,
										<cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#" maxlength="10">,
										<cfqueryparam cfsqltype="cf_sql_integer" value="#update_points#" maxlength="10">
										)
								</cfquery>
							</cfloop>
						</cfif>
						<cfif user_totalpoints GT 0>
							zero points:#user_totalpoints#<br>
							<cfset update_points = 0 - user_totalpoints>
							<cfquery name="ZeroPoints" datasource="#application.DS#">
								INSERT INTO #application.database#.awards_points
									(
										created_user_ID, created_datetime, notes,
										user_ID, points
									)
								VALUES (
									<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#',
									'Kaman terminations 3/6/2015',
									<cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#" maxlength="10">,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#update_points#" maxlength="10">
									)
							</cfquery>
						</cfif>
					</cfif>
				</td>
			</tr>
		</cfif>
	</cfloop>
</table>
<br><br>
Done!
</cfoutput>
<cfinclude template="../includes/footer.cfm">
