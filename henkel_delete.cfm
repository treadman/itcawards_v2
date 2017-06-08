<cfabort showerror="Do not even think about doing it">

<!---<cfspreadsheet action="read" src="henkel_hold.xlsx" query="GetHenkelUsers" sheet="1">--->

<!---<cfloop query="GetHenkelUsers" >
	<cfif GetHenkelUsers.CurrentRow GT 1>
		<cfset last_award = ListLast(ListFirst(GetHenkelUsers.col_3," "),"/")>
		<cfif last_award LT 14>
			<cfset total_points = GetHenkelUsers.col_2>
			<cfset email = GetHenkelUsers.col_1>
			<cfif email contains "@">
				<cfoutput>#GetHenkelUsers.CurrentRow#) #email# #ListFirst(GetHenkelUsers.col_3," ")# #total_points#</cfoutput>
				<cfquery name="GetProgramUser" datasource="#application.DS#">
					SELECT ID
					FROM #application.product_database#.henkel_hold_user
					WHERE email = '#email#'
					AND program_ID = 1000000066
				</cfquery>
				<cfif GetProgramUser.recordcount EQ 0>
					Not found!
				<cfelse>
					<cfloop query="GetProgramUser">
						<cfquery name="AddDeletedUser" datasource="#application.DS#">
							INSERT INTO #application.product_database#.DELETED_henkel_hold_user
								(ID, created_user_ID, created_datetime, modified_concat, program_ID, email, points, source_import)					
							SELECT ID, created_user_ID, created_datetime, modified_concat, program_ID, email, points, source_import
							FROM #application.product_database#.henkel_hold_user
							WHERE ID = #GetProgramUser.ID#
						</cfquery>
						<cfquery name="DeleteUser" datasource="#application.DS#">
							DELETE FROM #application.product_database#.henkel_hold_user
							WHERE ID = #GetProgramUser.ID#
						</cfquery>
					</cfloop>
				</cfif>
				<br>
			</cfif> 
		</cfif>
	</cfif>
</cfloop>--->


<!--- <cfloop query="GetHenkelUsers" >
	<cfif GetHenkelUsers.CurrentRow GT 1>
		<cfset last_award = ListLast(ListFirst(GetHenkelUsers.col_3," "),"/")>
		<cfif last_award LT 14>
			<cfset total_points = GetHenkelUsers.col_2>
			<cfset email = GetHenkelUsers.col_1>
			<cfif email contains "@">
				<cfoutput>#GetHenkelUsers.CurrentRow#) #email# #ListFirst(GetHenkelUsers.col_3," ")# #total_points#</cfoutput>
				<cfquery name="GetProgramUser" datasource="#application.DS#">
					SELECT ID
					FROM #application.product_database#.program_user
					WHERE email = '#email#'
					AND program_ID = 1000000066
					AND is_active = 1
				</cfquery>
				<cfif GetProgramUser.recordcount EQ 0>
					Not found!
				<cfelse>
					<cfloop query="GetProgramUser">
						<cfquery name="AddDeletedUser" datasource="#application.DS#">
							INSERT INTO #application.product_database#.DELETED_program_user
								(ID, created_user_ID, created_datetime, modified_concat, program_ID, username, nickname, fname, lname, ship_company, ship_fname, ship_lname, ship_address1, ship_address2, ship_city, ship_state, ship_zip, ship_country, phone, email, bill_company, bill_fname, bill_lname, bill_address1, bill_address2, bill_city, bill_state, bill_zip, cc_max, is_active, is_done, defer_allowed, expiration_date, entered_by_program_admin, supervisor_email, level_of_award, idh, registration_type, forwarding_ID)					
							SELECT ID, created_user_ID, created_datetime, modified_concat, program_ID, username, nickname, fname, lname, ship_company, ship_fname, ship_lname, ship_address1, ship_address2, ship_city, ship_state, ship_zip, ship_country, phone, email, bill_company, bill_fname, bill_lname, bill_address1, bill_address2, bill_city, bill_state, bill_zip, cc_max, is_active, is_done, defer_allowed, expiration_date, entered_by_program_admin, supervisor_email, level_of_award, idh, registration_type, forwarding_ID
							FROM #application.product_database#.program_user
							WHERE ID = #GetProgramUser.ID#
						</cfquery>
						<cfquery name="DeleteUser" datasource="#application.DS#">
							DELETE FROM #application.product_database#.program_user
							WHERE ID = #GetProgramUser.ID#
						</cfquery>
					</cfloop>
				</cfif>
				<br>
			</cfif> 
		</cfif>
	</cfif>
</cfloop> --->
