<cffile action="read" variable="thisData" file="#application.FilePath#/lorillard.csv">
<cfset thisData = Replace(thisData,"#CHR(13)##CHR(10)#","|","ALL")>
<cfset firstLine = true>
<table cellpadding="5" cellspacing="0" border="1">
<cfloop list="#thisData#" index="thisLine" delimiters="|">
	<cfset show = false>
	<cfset lookup = false>
	<cfif firstLine>
		<tr><th>Driver</th><th>Status</th><th>Supervisor Email<th>Earned</th><th>Bonus</th><th>Total</th><th>Redeemed</th><th>Remaining</th></tr>
		<!--- <cfoutput><tr><td>#replace(thisLine,",","</td><td>","ALL")#</td></tr></cfoutput> --->
	<cfelse>
		<cfset colNum = 1>
		<cfset EmptyLine = true>
		<cfset thisCol = "">
		<cfset DriverStatus = "">
		<cfset TermDate = "">
		<cfset CorpID = "">
		<cfset SuperEmail = "">
		<cfset DriverLast = "">
		<cfset DriverFirst = "">
		<cfset AwardDate = "">
		<cfset PointsEarned = 0>
		<cfset BonusPoints = 0>
		<cfset AwardLevel = "">
		<cfset TotalPoints = 0>
		<cfset PointsRedeemed = 0>
		<cfset RedeemedDate = "">
		<cfloop from="1" to="#len(trim(thisLine))#" index="x">
			<cfset thisChar = mid(trim(thisLine),x,1)>
			<cfif thisChar EQ "," OR x EQ len(trim(thisLine))>
				<cfif x EQ len(trim(thisLine))>
					<cfif thisChar NEQ ",">
						<cfset thisCol = thisCol & thisChar>
					</cfif>
				</cfif>
				<cfif colNum EQ 1 AND thisCol NEQ "">
					<!--- Active ,Termination ,New Hire --->
					<cfset DriverStatus = trim(thisCol)>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 2 AND thisCol NEQ "">
					<cfset TermDate = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 3 AND thisCol NEQ "">
					<cfset CorpID = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 4 AND thisCol NEQ "">
					<cfset SuperEmail = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 5 AND thisCol NEQ "">
					<cfset DriverLast = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 6 AND thisCol NEQ "">
					<cfset DriverFirst = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 7 AND thisCol NEQ "">
					<cfset AwardDate = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 8 AND thisCol NEQ "">
					<cfset PointsEarned = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 9 AND thisCol NEQ "">
					<cfset BonusPoints = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 10 AND thisCol NEQ "">
					<cfset AwardLevel = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 11 AND thisCol NEQ "">
					<cfset TotalPoints = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 12 AND thisCol NEQ "">
					<cfset PointsRedeemed = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfif colNum EQ 13 AND thisCol NEQ "">
					<cfset RedeemedDate = thisCol>
					<cfset EmptyLine = false>
				</cfif>
				<cfset thisCol = "">
				<cfset colNum = colNum + 1>
			<cfelse>
				<cfif thisChar NEQ ",">
					<cfset thisCol = thisCol & thisChar>
				</cfif>
			</cfif>
		</cfloop>
		<cfif NOT EmptyLine>
<!---
			<td>#TermDate#</td>
			<td>#CorpID#</td>
			<td>#SuperEmail#</td>
			<td>#AwardDate#</td>
			<td>#PointsEarned#</td>
			<td>#BonusPoints#</td>
			<td>#AwardLevel#</td>
			<td>#TotalPoints#</td>
			<td>#PointsRedeemed#</td>
			<td>#RedeemedDate#</td>
			</tr>

			- #DriverStatus#
			- #TermDate#
			- #CorpID#
			- #SuperEmail#
			- #DriverLast#
			- #DriverFirst#
			- #AwardDate#
			- #PointsEarned#
			- #BonusPoints#
			- #AwardLevel#
			- #TotalPoints#
			- #PointsRedeemed#
			- #RedeemedDate#
			<br>
--->
			<cfquery name="GetUser" datasource="#application.ds#">
				SELECT ID, created_datetime, username, fname, lname, email, is_active, expiration_date, supervisor_email, level_of_award
				FROM #application.database#.program_user
				WHERE fname = '#trim(DriverFirst)#'
				AND lname = '#trim(DriverLast)#'
				AND program_ID = 1000000035
			</cfquery>
			<cfset text = '
			<tr>
			<td>'&DriverFirst&' '&DriverLast&'</td><td>'&DriverStatus&'<br>'>
			<cfif GetUser.recordcount eq 0>
				<!---<cfset text = text & '<td colspan="5">NOT FOUND</td>'>--->
				<cfset text = text & 'NOT FOUND</td>'>
			<cfelseif GetUser.recordcount gt 1>
				<!---<cfset text = text & '<td colspan="5">'&GetUser.recordcount&' records!</td>'>--->
				<cfset text = text & GetUser.recordcount&' records!</td>'>
			<cfelse>
				<cfset lookup = true>
				<cfif GetUser.is_active eq 1 and (DriverStatus eq "Active" or DriverStatus eq "New Hire")>
					<cfset text = text & 'OK</td>'>
				<cfelseif GetUser.is_active eq 0 and DriverStatus eq "Termination">
					<cfset text = text & 'OK</td>'>
				<cfelse>
					<cfif GetUser.is_active eq 0><cfset text = text & 'Not '></cfif>
					<cfset text = text & 'Active in Awards</td>'>
				</cfif>
			</cfif>
			<cfif lookup>
				<cfset text = text & '<td>'&SuperEmail&'<br>'&GetUser.Supervisor_email&'</td>'>
			<cfelseif GetUser.recordcount gt 1>
				<cfset text = text & '<td>'&SuperEmail&'<br>'>
				<cfquery name="GetUser" datasource="#application.ds#">
					SELECT ID, created_datetime, username, fname, lname, email, is_active, expiration_date, supervisor_email, level_of_award
					FROM #application.database#.program_user
					WHERE fname = '#trim(DriverFirst)#'
					AND lname = '#trim(DriverLast)#'
					AND program_ID = 1000000035
					AND supervisor_email = '#SuperEmail#'
				</cfquery>
				<cfif GetUser.recordcount eq 0>
					<cfset text = text & 'NOT FOUND</td>'>
				<cfelseif GetUser.recordcount gt 1>
					<cfset text = text & GetUser.recordcount&' records!</td>'>
				<cfelse>
					<cfset lookup = true>
					<cfset text = text & GetUser.Supervisor_email&'</td>'>
				</cfif>
			<cfelse>
				<cfset text = text & '<td>'&SuperEmail&'<br>---</td>'>
			</cfif>
			<cfif not show>
				<cfset show = true>
				<cfset Awarded = "---">
				<cfset Used = "---">
				<cfif lookup>
					<cfset this_userID = GetUser.ID>
					<cfquery name="PosPoints" datasource="#application.DS#">
						SELECT IFNULL(SUM(points),0) AS points
						FROM #application.database#.awards_points
						WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_userID#">
					</cfquery>
					<cfif PosPoints.recordcount eq 1>
						<cfset Awarded = PosPoints.points*200>
					<cfelse>
						<cfset Awarded = 0>
					</cfif>
					<cfquery name="NegPoints" datasource="#application.DS#">
						SELECT IFNULL(SUM(points_used),0) AS points
						FROM #application.database#.order_info
						WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_userID#">
						AND is_valid = 1
					</cfquery>
					<cfif NegPoints.recordcount eq 1>
						<cfset Used = NegPoints.points*200>
					<cfelse>
						<cfset Used = 0>
					</cfif>
				</cfif>
				<cfset text = text & '
				<td align="right" valign="top">'&PointsEarned&'</td>
				<td align="right" valign="top">'&BonusPoints&'</td>
				<td align="right">'&(TotalPoints+PointsRedeemed)&'<br>'&Awarded&'</td>
				<td align="right">'&PointsRedeemed&'<br>'&Used&'</td>'>
				<cfif isNumeric(Awarded) and isNumeric(Used)>
					<cfset text = text & '<td align="right">'&TotalPoints&'<br>'&(Awarded-Used)&'</td>'>
				<cfelse>
					<cfset text = text & '<td align="right">'&TotalPoints&'<br>---</td>'>
				</cfif>
			</cfif>
			<cfset text = text & '</tr>'>
			<cfif show>
				<cfoutput>#text#</cfoutput>
			</cfif>
			
<!---
				<cfquery name="GetManager" datasource="#application.ds#">
					SELECT ID,fname,lname,email,supervisor_email
					FROM #application.database#.program_user
					WHERE LEFT(fname,#len(trim(MgrFirst))#) = '#trim(MgrFirst)#'
					AND lname = '#MgrLast#'
					AND program_ID = 1000000035
				</cfquery>
				<!--- <cfif trim(MgrFirst) EQ 'CRAIG'>
					<cfoutput>
					SELECT ID,fname,lname,email,supervisor_email
					FROM #application.database#.program_user
					WHERE LEFT(fname,#len(trim(MgrFirst))#) = '#trim(MgrFirst)#'
					AND lname = '#MgrLast#'
					AND program_ID = 1000000035
					</cfoutput><cfabort>
				</cfif> --->
				<cfif GetManager.recordcount EQ 1>
					<cfset thisManagerID = GetManager.ID>
					<cfset thisManagerSuperEmail = GetManager.supervisor_email>
				<cfelse>
					<cfset thisManagerID = 0>
					<cfset thisManagerSuperEmail = "">
				</cfif>
					<cfif thisMidSuperSuperEmail NEQ thisTopSuperEmail>
						Change midSuper <cfoutput>(#thisMidSuperID#) #MidSuper#</cfoutput>'s supervisor email to <cfoutput>#thisTopSuperEmail#</cfoutput><br />
						<cfquery name="UpdateMidSuper" datasource="#application.ds#">
							UPDATE #application.database#.program_user
							SET supervisor_email = '#trim(thisTopSuperEmail)#'
							WHERE ID = #thisMidSuperID#
							AND program_ID = 1000000035
						</cfquery>
					</cfif>
					<cfif thisManagerSuperEmail NEQ thisMidSuperEmail>
						Change manager <cfoutput>(#thisManagerID#) #Manager#</cfoutput>'s supervisor email to <cfoutput>#thisMidSuperEmail#</cfoutput><br />
						<cfquery name="UpdateManager" datasource="#application.ds#">
							UPDATE #application.database#.program_user
							SET supervisor_email = '#trim(thisMidSuperEmail)#'
							WHERE ID = #thisManagerID#
							AND program_ID = 1000000035
						</cfquery>
					</cfif>
			--->
		</cfif>
	</cfif>
	<cfset firstLine = false>
</cfloop>
<cfoutput>
</table>
<br><br>
Done!
</cfoutput>
