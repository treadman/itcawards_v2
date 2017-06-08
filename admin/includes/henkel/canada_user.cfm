<cfif NOT isLeader AND LeaderList NEQ "" AND NOT ListFindNoCase(InDatabaseList,GetUserByEmail.email)>
	<cfset InDatabaseList = ListAppend(InDatabaseList,GetUserByEmail.email)>
</cfif>
<cfoutput>
<td <cfif thisIDH NEQ GetuserByEmail.idh>class="alert"</cfif>><cfif GetUserByEmail.idh EQ "">&nbsp;<cfelse>#GetUserByEmail.idh#</cfif></td>
<td><cfif GetUserByEmail.created_datetime EQ "">&nbsp;<cfelse>#DateFormat(GetUserByEmail.created_datetime,"m/d/yyyy")#</cfif></td>
<td <cfif thisRegType NEQ GetuserByEmail.registration_type OR NOT ListFind("Branch,Individual",GetuserByEmail.registration_type)>class="alert"</cfif>><cfif GetUserByEmail.registration_type EQ "">&nbsp;<cfelse>#GetUserByEmail.registration_type#</cfif></td>
<td><cfif GetUserByEmail.email EQ "">&nbsp;<cfelse>#GetUserByEmail.email#</cfif></td>
<td><cfif GetUserByEmail.fname EQ "">&nbsp;<cfelse>#GetUserByEmail.fname#</cfif></td>
<td><cfif GetUserByEmail.lname EQ "">&nbsp;<cfelse>#GetUserByEmail.lname#</cfif></td>
<td align="right">
	<cfquery name="Positive" datasource="#application.DS#">
		SELECT IFNULL(SUM(points),0) AS points
		FROM #application.database#.awards_points
		WHERE user_ID = #GetUserByEmail.ID#
		<!--- AND datediff(created_datetime,'2008-09-02') < 0 --->
	</cfquery>
	<cfquery name="Negative" datasource="#application.DS#">
		SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) AS points
		FROM #application.database#.order_info
		WHERE created_user_ID = #GetUserByEmail.ID#
		<!--- AND datediff(created_datetime,'2008-09-02') < 0 --->
	</cfquery>
	#Positive.points - Negative.points#
	<cfquery name="HoldUser" datasource="#application.DS#">
		SELECT IFNULL(SUM(points),0) AS points
		FROM #application.database#.henkel_hold_user
		WHERE email = '#GetUserByEmail.email#'
		<!--- AND datediff(created_datetime,'2008-09-02') < 0 --->
	</cfquery>
	<cfif HoldUser.points GT 0>
		<br /><span class="alert">Hold:</span> #HoldUser.points#
	</cfif>
</td>
<td>
	<cfset thatAltEmails = "">
	<cfset DoAltCheck = true>
	<cfquery name="GetAltEmails" datasource="#application.DS#">
		SELECT alternate_emails
		FROM #application.Database#.henkel_register
		WHERE program_ID = 1000000069
		AND email = '#thisEmail#'
		AND alternate_emails IS NOT NULL
	</cfquery>
	<cfif GetAltEmails.recordcount EQ 0>
		&nbsp;
	<cfelseif GetAltEmails.recordcount EQ 1>
		<cfif ListFind(GetAltEmails.alternate_emails, thisEmail)>
			<span class="alert">Leader email is on the Branch Participant List</span><br />
		</cfif>
		<cfif GetAltEmails.alternate_emails EQ "">&nbsp;<cfelse>#ListSort(GetAltEmails.alternate_emails,"textnocase")#<cfset thatAltEmails = GetAltEmails.alternate_emails></cfif>
	<cfelse>
		Multiples:<cfdump var="#GetAltEmails#">
		<cfset DoAltCheck = false>
	</cfif>
	<cfif DoAltCheck>
		<!--- Something not right about this check:
		<cfset AltCheckList = "">
		<cfloop list="#thisAltEmails#" index="thisAltEmail">
			<cfif thisAltEmail NEQ thisEmail AND NOT ListFindNoCase(thatAltEmails,thisAltEmail)>
				<cfset AltCheckList = ListAppend(AltCheckList,thisAltEmail)>
			</cfif>
		</cfloop>
		<cfif AltCheckList NEQ "">
			<br><span class="alert">Branch Participants not in database: #AltCheckList#</span>
		</cfif> --->
		<cfset AltCheckList = "">
		<cfloop list="#thatAltEmails#" index="thisAltEmail">
			<cfif NOT ListFindNoCase(thisAltEmails,thisAltEmail)>
				<cfset AltCheckList = ListAppend(AltCheckList,thisAltEmail)>
			</cfif>
		</cfloop>
		<cfif AltCheckList NEQ "">
			<br><span class="alert">Branch Participants not in leader's list: #AltCheckList#</span>
		</cfif>
	</cfif>
</td>
</cfoutput>