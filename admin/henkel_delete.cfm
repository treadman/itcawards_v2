<cfabort showerror="Do not even think about doing it">

<cfsetting requesttimeout="6000">
<cffile action="read" variable="thisData" file="#application.FilePath#admin/upload/registered_inactive.csv">

<cfset thisData = Replace(thisData,"#CHR(10)#","|","ALL")>

<!--- Replace empty cells with a single space --->
<cfset thisData = Replace(thisData,",,",", ,","ALL")>


<cfset first_line = true>

<cfset total_points = 0>
<cfset total_users = 0>
<cfset id_list = "">
<cfloop list="#thisData#" index="thisLine" delimiters="|">
	<cfif NOT first_line>

			
		<cfset thisUsername = ListGetAt(thisLine,1)>
		<cfset thisFirstname = Replace(ListGetAt(thisLine,1),'"','','ALL')>
		<cfset thisLastname = Replace(ListGetAt(thisLine,2),'"','','ALL')>
		<cfset thisLastname = Replace(thisLastname,'*',',','ALL')>
		<cfset thisCompany = Replace(ListGetAt(thisLine,3),'"','','ALL')>
		<cfset thisCompany = Replace(thisCompany,'*',',','ALL')>
		<cfset thisEmail = Replace(ListGetAt(thisLine,4),'"','','ALL')>
		<cfset thisIDH = trim(ListGetAt(thisLine,5))>
		<cfset thisRegistration = ListGetAt(thisLine,6)>
		<cfset thisPoints = ListGetAt(thisLine,7)>

		<cfquery name="getUser" datasource="#application.ds#">
			SELECT ID FROM #application.database#.program_user
			WHERE program_ID = 1000000066
			AND fname='#thisFirstName#'
			AND lname='#thisLastName#'
			AND email='#thisEmail#'
			AND idh
			<cfif thisIDH EQ "NULL">
				IS NULL
			<cfelse>
				='#thisIDH#'
			</cfif>
				AND ship_company
			<cfif thisCompany EQ "NULL">
				IS NULL
			<cfelse>
					='#thisCompany#'
			</cfif>
				AND registration_type
			<cfif thisRegistration EQ "NULL">
				IS NULL
			<cfelse>
				= '#thisRegistration#'
			</cfif>
		</cfquery>
		<!--- <cfif getUser.recordcount NEQ 1>
			<cfdump var="#getUser#">
			wha?<cfabort>
		<cfelse> --->
			<cfif isNumeric(getUser.ID) AND not listFind(id_list,getUser.ID)>
				
				<cfset id_list = listAppend(id_list,getUser.ID)>
				<cfset this_user_id = getUser.ID>
						<cfquery name="AddDeletedUser" datasource="#application.DS#">
							INSERT INTO #application.database#.DELETED_program_user
								(ID, created_user_ID, created_datetime, modified_concat, program_ID, username, nickname, fname, lname, ship_company, ship_fname, ship_lname, ship_address1, ship_address2, ship_city, ship_state, ship_zip, ship_country, phone, email, bill_company, bill_fname, bill_lname, bill_address1, bill_address2, bill_city, bill_state, bill_zip, cc_max, is_active, is_done, defer_allowed, expiration_date, entered_by_program_admin, supervisor_email, level_of_award, idh, registration_type, forwarding_ID)					
							SELECT ID, created_user_ID, created_datetime, modified_concat, program_ID, username, nickname, fname, lname, ship_company, ship_fname, ship_lname, ship_address1, ship_address2, ship_city, ship_state, ship_zip, ship_country, phone, email, bill_company, bill_fname, bill_lname, bill_address1, bill_address2, bill_city, bill_state, bill_zip, cc_max, is_active, is_done, defer_allowed, expiration_date, entered_by_program_admin, supervisor_email, level_of_award, idh, registration_type, forwarding_ID
							FROM #application.database#.program_user
							WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#">
						</cfquery>
						<cfquery name="DeleteUser" datasource="#application.DS#">
							DELETE FROM #application.database#.program_user
							WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#">
						</cfquery>

						<cfquery name="GetPoints" datasource="#application.DS#">
							SELECT ID
							FROM #application.database#.awards_points
							WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#">
						</cfquery>

						<cfloop query="GetPoints">
							<cfset this_points_ID = GetPoints.ID>
							<cfquery name="AddDeletedPoints" datasource="#application.DS#">
								INSERT INTO #application.database#.DELETED_awards_points
									(ID, created_user_ID, created_datetime, modified_concat, user_ID, points, notes, is_defered)
								SELECT ID, created_user_ID, created_datetime, modified_concat, user_ID, points, notes, is_defered
								FROM #application.database#.awards_points
								WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_points_ID#">
							</cfquery>
							<cfquery name="DeletePoints" datasource="#application.DS#">
								DELETE FROM #application.database#.awards_points
								WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_points_ID#">
							</cfquery>

						</cfloop>

				<!--- <cfquery name="PosPoints" datasource="#application.DS#">
					SELECT IFNULL(SUM(points),0) AS pos_pt
					FROM #application.database#.awards_points
					WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#">
				</cfquery>
				<!--- look in the order database for orders/points_used --->
				<cfquery name="NegPoints" datasource="#application.DS#">
					SELECT IFNULL(SUM(points_used),0) AS neg_pt
					FROM #application.database#.order_info
					WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_user_id#">
					AND is_valid = 1
				</cfquery>
				<cfset this_points = PosPoints.pos_pt-NegPoints.neg_pt>
				<cfoutput>#Replace(thisLine,'*',',','ALL')#,#this_points#,#thisPoints#</cfoutput><br>
				<cfif this_points NEQ thisPoints>
					<cfabort>
				</cfif>
				<cfset total_points = total_points + this_points>
				<cfset total_users = total_users + 1> --->
			</cfif>
		<!--- </cfif> --->
	</cfif>
	<cfset first_line = false>
</cfloop>

<br><br>
<!--- <cfoutput>#total_users# users - #total_points# points</cfoutput> --->
done 12