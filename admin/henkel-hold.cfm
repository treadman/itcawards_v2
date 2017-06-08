<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000098,true)>

<cfparam name="url.pgfn" default="home">
<cfparam name="url.id" default="">

<cfparam name="url.sort" default="email">
<cfparam name="xOnPage" default="1">

<cfparam name="form.username" default="">
<cfparam name="form.email" default="">

<cfparam name="form.newemail" default="">

<cfparam name="alert_msg" default="">

<cfparam name="search_text" default="">
<cfparam name="email_initial" default="">


<cfif isNumeric(url.id) AND url.id GT 0>
	<cfquery name="GetHoldUser" datasource="#application.DS#">
		SELECT h.created_user_ID, h.created_datetime, h.email, h.points, h.source_import, u.username, u.is_active
		FROM #application.database#.henkel_hold_user h
		LEFT JOIN #application.database#.program_user u ON h.email = u.email AND h.program_ID = u.program_ID AND u.registration_type != 'BranchHQ'
		WHERE h.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
		AND h.ID = <cfqueryparam value="#url.id#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfif GetHoldUser.recordcount NEQ 1>
		<cfset alert_msg = "There was an error accessing that record.">
		<cfset url.pgfn = "home">
	</cfif>
</cfif>

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<!--- ----------------------------- --->
<!--- ------  Delete  ------------- --->
<!--- ----------------------------- --->

<cfif url.pgfn EQ "delete">
	 <cfquery name="DeleteHoldPoints" datasource="#application.DS#">
		DELETE FROM #application.database#.henkel_hold_user
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
		AND ID = <cfqueryparam value="#url.id#" cfsqltype="CF_SQL_INTEGER">
	</cfquery> 
	<cfset alert_msg = "#GetHoldUser.points# hold points deleted from #GetHoldUser.email#">
	<cfset url.pgfn = "home">
</cfif>

<!--- ----------------------------- --->
<!--- ------  Change Email -------- --->
<!--- ----------------------------- --->

<cfif url.pgfn EQ "newemail">
	<cfquery name="UpdateEmail" datasource="#application.DS#">
		UPDATE #application.database#.henkel_hold_user
		SET email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.newemail#">
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
		AND email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#GetHoldUser.email#">
	</cfquery>
	<cfset alert_msg = "#GetHoldUser.email# changed to #form.newemail#\n\n">
	<cfset url.pgfn = "home">
</cfif>

<!--- --------------------------- --->
<!--- ------  Award ------------- --->
<!--- --------------------------- --->

<cfif url.pgfn EQ "award">
	<cfif isDefined("form.find_user")>
		<cfif form.username NEQ "" AND form.email NEQ "">
			<cfset alert_msg = "Please enter only one of the two fields, not both.">
		<cfelseif form.username EQ "" AND form.email EQ "">
			<cfset alert_msg = "Please enter either the username or the email address.">
		</cfif>
		<cfif alert_msg NEQ "">
			<cfset url.pgfn = "edit">
		<cfelse>
			<!--- Look up user --->
			<cfquery name="GetExistingUser" datasource="#application.DS#">
				SELECT ID, username, fname, lname, email, idh, is_active
				FROM #application.database#.program_user
				WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
				<cfif form.username NEQ "">
					AND username = <cfqueryparam value="#form.username#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					AND email = <cfqueryparam value="#form.email#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfquery>
			<cfif GetExistingUser.recordcount EQ 1>
				<cfset url.pgfn = "confirm">
			<cfelseif GetExistingUser.recordcount EQ 0>
				<cfif form.username NEQ "">
					<cfset alert_msg = "Username, #form.username#, not found.">
				<cfelse>
					<cfset alert_msg = "Email, #form.email#, not found.">
				</cfif>
				<cfset url.pgfn = "edit">
			<cfelse>
				<cfif form.username NEQ "">
					<cfset alert_msg = "Multiple records found for username, #form.username#.">
				<cfelse>
					<cfset alert_msg = "Multiple records found for email, #form.email#.">
				</cfif>
				<cfset url.pgfn = "edit">
			</cfif>
		</cfif>
	<cfelseif isDefined("form.award_points")>
		<!--- Look up user --->
		<cfquery name="GetExistingUser" datasource="#application.DS#">
			SELECT ID
			FROM #application.database#.program_user
			WHERE ID = <cfqueryparam value="#form.user_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif GetExistingUser.recordcount EQ 1>
			<cfset HoldPoints = 0>
			<cfset Notes = "Points awarded out of hold:#CHR(13)##CHR(10)#">
			<cfquery name="getHoldPoints" datasource="#application.DS#">
				SELECT points, source_import
				FROM #application.database#.henkel_hold_user
				WHERE email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#GetHoldUser.email#">
			</cfquery>
			<cfloop query="getHoldPoints">
				<cfset HoldPoints = HoldPoints + getHoldPoints.points>
				<cfset Notes = Notes & "#getHoldPoints.points# points for " & trim(getHoldPoints.source_import) & CHR(13) & CHR(10)>
			</cfloop>
			<cfif HoldPoints GT 0>
				<cfquery name="deleteHoldPoints" datasource="#application.DS#">
					DELETE FROM #application.database#.henkel_hold_user
					WHERE email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#GetHoldUser.email#">
				</cfquery>
				<cfquery name="AwardPoints" datasource="#application.DS#">
					INSERT INTO #application.database#.awards_points (
						created_user_ID, created_datetime, user_ID, points, notes)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#FLGen_adminID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.user_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#HoldPoints#">,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Notes#">
					)
				</cfquery>
				<cfset alert_msg = "Points awarded">
				<cfset url.pgfn = "home">
			</cfif>
		<cfelse>
			<cfset alert_msg = "There was an error looking up that user!">
		</cfif>
	</cfif>
</cfif>

<cfset request.main_width = 1100>
<cfset leftnavon = 'henkel_hold'>
<cfinclude template="includes/header.cfm">

<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>

<span class="pagetitle">
	Hold Points
	<cfif isDefined("GetHoldUser") AND GetHoldUser.recordcount EQ 1>
		for <cfoutput>#GetHoldUser.email#</cfoutput>
	<cfelse>
		<cfquery name="GetTotalPoints" datasource="#application.DS#">
			SELECT SUM(points) AS points
			FROM #application.database#.henkel_hold_user
			WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		- <cfoutput>#NumberFormat(GetTotalPoints.points)#</cfoutput> points.
	</cfif>
</span>
<br /><br />

<!--- Return links --->
<cfif url.pgfn NEQ "home">
	<span class="pageinstructions">Return to the <a href="<cfoutput>#CurrentPage#?sort=#url.sort#&xOnPage=#xOnPage#&pgfn=home&search_text=#search_text#&email_initial=#email_initial#</cfoutput>" class="actionlink">Hold Points Main Page</a></span>
	<br /><br />
</cfif>
<cfif url.pgfn EQ "confirm">
	<cfoutput><span class="pageinstructions">Return to <a href="#CurrentPage#?sort=#url.sort#&xOnPage=#xOnPage#&id=#url.id#&pgfn=edit&search_text=#search_text#&email_initial=#email_initial#" class="actionlink">#GetHoldUser.email#</a> without making changes.</span></cfoutput>
	<br /><br />
</cfif>

<!--- Current hold points for selected email address --->
<cfset ThisTotalPoints = 0>
<cfif url.pgfn EQ "edit" OR url.pgfn EQ "confirm">
	<cfquery name="GetAllPoints" datasource="#application.DS#">
		SELECT ID, created_user_ID, created_datetime, email, points, source_import
		FROM #application.database#.henkel_hold_user
		WHERE email = <cfqueryparam value="#GetHoldUser.email#" cfsqltype="CF_SQL_VARCHAR">
		AND program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfset numRecs = GetAllPoints.recordcount>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<tr class="contenthead">
			<td class="headertext">Imported</td>
			<td class="headertext">Email Address</td>
			<td class="headertext">Points</td>
			<td class="headertext">Source</td>
		</tr>
		<cfoutput query="GetAllPoints">
			<cfset ThisTotalPoints = ThisTotalPoints + GetAllPoints.points>
			<tr class="content<cfif GetAllPoints.currentrow MOD 2 EQ 1>2</cfif>">
				<td>#DateFormat(GetAllPoints.created_datetime,"mm/dd/yyyy")#</td>
				<td>#GetAllPoints.email#</td>
				<td>#GetAllPoints.points#</td>
				<td>#GetAllPoints.source_import#</td>
			</tr>
			</tr>
		</cfoutput>
		<tr class="contenthead"><td colspan="100%"></td></tr>
	</table>
	<br /><br />
</cfif>

<cfif url.pgfn EQ "home">

	<!--- ------------------------------------ --->
	<!--- ------  Home Page   ---------------- --->
	<!--- ------------------------------------ --->
<cfoutput>
<form name="search_form" action="#CurrentPage#" method="post">
	<table cellpadding="5" cellspacing="0" border="0" width="70%" style="float:left;">
		<tr class="contenthead">
			<td><span class="headertext">Search Criteria</span></td>
			<td align="right"><a href="#CurrentPage#" class="headertext">view all</a></td>
		</tr>
		<tr>
			<td class="content" colspan="2">
				<input type="text" name="search_text" value="#search_text#" size="40">
				<input type="submit" name="do_search" value="search">
			</td>
		</tr>
		<tr><td class="content" colspan="2" align="center"><br><cfif LEN(email_initial) IS 0><span class="ltrON">ALL</span><cfelse><a href="#CurrentPage#?sort=#url.sort#" class="ltr">ALL</a></cfif><span class="ltrPIPE">&nbsp;&nbsp;</span><cfloop index = "LoopCount" from = "0" to = "9"><cfif email_initial IS LoopCount><span class="ltrON">#LoopCount#</span><cfelse><a href="#CurrentPage#?email_initial=#LoopCount#&sort=#url.sort#" class="ltr">#LoopCount#</a></cfif><span class="ltrPIPE">&nbsp;&nbsp;</span></cfloop><cfloop index = "LoopCount" from = "1" to = "26"><cfif email_initial IS CHR(LoopCount + 64)><span class="ltrON">#CHR(LoopCount + 64)#</span><cfelse><a href="#CurrentPage#?email_initial=#CHR(LoopCount + 64)#&sort=#url.sort#" class="ltr">#CHR(LoopCount + 64)#</a></cfif><cfif LoopCount NEQ 26><span class="ltrPIPE">&nbsp;&nbsp;</span></cfif></cfloop></td></tr>
	</table>
	<table style="float:right">
		<tr>
			<td align="right">
				<br>
				<a href="henkel_hold_bulk_delete.cfm">Bulk Delete From Spreadsheet</a>
				<br>
			</td>
		</tr>
	</table>
</form>
</cfoutput>
<br><br>
<cfif LEN(search_text) GT 0>
	<cfset email_initial = "">
</cfif>

	<cfquery name="GetHoldUsers" datasource="#application.DS#">
		SELECT h.ID, h.created_user_ID, h.created_datetime, h.email, h.points, h.source_import, u.username, u.is_active
		FROM #application.database#.henkel_hold_user h
		LEFT JOIN #application.database#.program_user u ON h.email = u.email AND h.program_ID = u.program_ID AND u.registration_type != 'BranchHQ'
		WHERE h.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
		<cfif LEN(search_text) GT 0>
				<cfloop list="#search_text#" index="this_term" delimiters=" ">
			AND (
					u.username LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR u.fname LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR u.lname LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%"> 
					OR h.email LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#this_term#%">
			)
				</cfloop>
		<cfelseif LEN(email_initial) GT 0>
			AND h.email LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#email_initial#%">
		</cfif>
		ORDER BY
		<cfswitch expression="#url.sort#">
			<cfcase value="email">
				h.email
			</cfcase>
			<cfcase value="import">
				h.created_datetime DESC
			</cfcase>
			<cfcase value="source">
				h.source_import DESC
			</cfcase>
			<cfdefaultcase>
				h.email
			</cfdefaultcase>
		</cfswitch>
	</cfquery>

	<cfset MaxRows_SelectList="50">
	<cfset StartRow_SelectList=Min((xOnPage-1)*MaxRows_SelectList+1,Max(GetHoldUsers.RecordCount,1))>
	<cfset EndRow_SelectList=Min(StartRow_SelectList+MaxRows_SelectList-1,GetHoldUsers.RecordCount)>
	<cfset TotalPages_SelectList=Ceiling(GetHoldUsers.RecordCount/MaxRows_SelectList)>
	
	<cfoutput>
	<form name="pageform">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
		<td>
			<cfif xOnPage GT 1>
				<a href="#CurrentPage#?xOnPage=1&sort=#url.sort#&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#" class="pagingcontrols">&laquo;</a>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?xOnPage=#Max(DecrementValue(xOnPage),1)#&sort=#url.sort#&search_text=#search_text#&email_initial=#email_initial#" class="pagingcontrols">&lsaquo;</a>
			<cfelse>
				<span class="Xpagingcontrols">&laquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&lsaquo;</span>
			</cfif>
		</td>
		<td align="center" class="sub">[ page 	
			<cfoutput>
			<select name="pageselect" onChange="openURL()"> 
				<cfloop from="1" to="#TotalPages_SelectList#" index="this_i">
					<option value="#CurrentPage#?xOnPage=#this_i#&sort=#sort#&search_text=#search_text#&email_initial=#email_initial#"<cfif xOnPage EQ this_i> selected</cfif>>#this_i#</option> 
				</cfloop>
			</select>
			of #TotalPages_SelectList# ]&nbsp;&nbsp;&nbsp;[ records #StartRow_SelectList# - #EndRow_SelectList# of #GetHoldUsers.RecordCount# ]
			</cfoutput>
		</td>
		<td align="right">
			<cfif xOnPage LT TotalPages_SelectList>
				<a href="#CurrentPage#?xOnPage=#Min(IncrementValue(xOnPage),TotalPages_SelectList)#&sort=#url.sort#&search_text=#search_text#&email_initial=#email_initial#" class="pagingcontrols">&rsaquo;</a>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?xOnPage=#TotalPages_SelectList#&sort=#url.sort#&search_text=#search_text#&email_initial=#email_initial#" class="pagingcontrols">&raquo;</a>
			<cfelse>
				<span class="Xpagingcontrols">&rsaquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&raquo;</span>
			</cfif>
		</td>
		</tr>
	</table>
	</form>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<tr class="contenthead">
			<td>&nbsp;</td>
			<td class="headertext">
				<cfif url.sort EQ "import">
					Imported <img src="../pics/contrls-desc.gif">
				<cfelse>
					<a href="#CurrentPage#?sort=import&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#">Imported</a>
				</cfif>
			</td>
			<td class="headertext">Name</td>
			<td class="headertext">
				<cfif url.sort EQ "email">
					Email Address <img src="../pics/contrls-desc.gif">
				<cfelse>
					<a href="#CurrentPage#?sort=email&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#">Email Address</a>
				</cfif>
			</td>
			<td class="headertext">Points</td>
			<td class="headertext">
				<cfif url.sort EQ "source">
					Source <img src="../pics/contrls-desc.gif">
				<cfelse>
					<a href="#CurrentPage#?sort=source&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#">Source</a>
				</cfif>
			</td>
			<td>&nbsp;</td>
		</tr>
</cfoutput>
		<cfoutput query="GetHoldUsers" startrow="#StartRow_SelectList#" maxrows="#MaxRows_SelectList#">
			<tr class="content<cfif GetHoldUsers.currentrow MOD 2 EQ 1>2</cfif>">
				<td><a class="actionlink" href="#CurrentPage#?id=#getHoldUsers.ID#&pgfn=edit&sort=#url.sort#&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#">Edit</a></td>
				<td>#DateFormat(GetHoldUsers.created_datetime,"mm/dd/yyyy")#</td>
				<td>
					<cfif ListFindNoCase("MRO OEM,Joint Sales Call,Loctite University,Distributor Training School,Documented Cost Savings Event,Air Leak or Hydraulic Leak Survey",GetHoldUsers.source_import)>
						<cfquery name="GetName" datasource="#application.DS#">
							SELECT fname,lname
							FROM 
							<cfswitch expression="#GetHoldUsers.source_import#">
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
							WHERE email = '#GetHoldUsers.email#'
						</cfquery>
						<cfif GetName.RecordCount GT 0>
							<cfset this_first = GetName.fname>
							<cfset this_last = GetName.lname>
						<cfelse>
							<cfset this_first = '<span class="sub">Unknown</span>'>
							<cfset this_last = ''>
						</cfif>
						<cfquery name="NameSoundsAlike" datasource="#application.DS#">
							SELECT DISTINCT fname, lname 
							FROM #application.database#.program_user
							WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
							AND fname SOUNDS LIKE '#this_first#'
							AND lname SOUNDS LIKE '#this_last#'
							ORDER BY fname, lname
						</cfquery>
						#this_first# #this_last#<br>
						<cfif NameSoundsAlike.RecordCount GT 0>
							<span class="highlight">
							<cfloop query="NameSoundsAlike">
								#NameSoundsAlike.fname# #NameSoundsAlike.lname#<br>
							</cfloop>
							</span>
						</cfif>
					<cfelse>
						<span class="sub">Unknown</span>
					</cfif>
				</td>
				<td>
					#GetHoldUsers.email#
					<cfif GetHoldUsers.username NEQ "">
						<span class="alert">USER EXISTS!! - #GetHoldUsers.username#</span>
					</cfif>
					<br>
					<cfset this_user = ListFirst(GetHoldUsers.email,"@")>
					<cfset this_domain = ListLast(GetHoldUsers.email,"@")>
					<cfquery name="EmailSoundsAlike" datasource="#application.DS#">
						SELECT DISTINCT email 
						FROM #application.database#.program_user
						WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
						AND SUBSTRING(email, 1, LOCATE('@', email) - 1) SOUNDS LIKE '#this_user#'
						AND SUBSTRING(email, LOCATE('@', email) + 1) SOUNDS LIKE '#this_domain#'
						ORDER BY email
					</cfquery>
					<cfif EmailSoundsAlike.RecordCount GT 0>
						<span class="highlight">
						<cfloop query="EmailSoundsAlike">
							#EmailSoundsAlike.email#<br>
						</cfloop>
						</span>
					</cfif>
				</td>
				<td>#GetHoldUsers.points#</td>
				<td>#GetHoldUsers.source_import#</td>
				<td><a class="actionlink" href="#CurrentPage#?id=#getHoldUsers.ID#&pgfn=delete&sort=#url.sort#&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#" onclick="return confirm('Are you sure you want to delete this hold points record?  There is NO UNDO.')">X</a></td>
			</tr>
			</tr>
			<cfflush>
		</cfoutput>
	</table>

<!--- -------------------- --->
<!--- ------  Edit ------- --->
<!--- -------------------- --->

<cfelseif url.pgfn EQ "edit">
	<cfoutput>
	<cfif ListFindNoCase("MRO OEM,Joint Sales Call,Loctite University,Distributor Training School,Documented Cost Savings Event,Air Leak or Hydraulic Leak Survey",GetHoldUser.source_import)>
		<cfquery name="GetName" datasource="#application.DS#">
			SELECT fname,lname
			FROM 
			<cfswitch expression="#GetHoldUser.source_import#">
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
			WHERE email = '#GetHoldUser.email#'
		</cfquery>
		<cfif GetName.RecordCount GT 0>
			<cfset this_first = GetName.fname>
			<cfset this_last = GetName.lname>
			<cfquery name="NameSoundsAlike" datasource="#application.DS#">
				SELECT ID, username, fname, lname, email, idh, is_active
				FROM #application.database#.program_user
				WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
				AND fname SOUNDS LIKE '#this_first#'
				AND lname SOUNDS LIKE '#this_last#'
				ORDER BY fname, lname
			</cfquery>
			<cfif NameSoundsAlike.RecordCount GT 0>
				#this_first# #this_last# is in an upload for #GetHoldUser.source_import#, and could possibly be one the following <span class="highlight">program users</span>:<br>
				<table cellpadding="5" cellspacing="1" border="0" width="100%">
					<tr class="contenthead">
						<td class="headertext">Active</td>
						<td class="headertext">Username</td>
						<td class="headertext">Name</td>
						<td class="headertext">Email Address</td>
						<td class="headertext">IDH</td>
					</tr>
				<cfloop query="NameSoundsAlike">
					<tr>
						<td>#YesNoFormat(NameSoundsAlike.is_active)#</td>
						<td>
							<a href="javascript:void(0);" onClick="pointsAward.username.value='#NameSoundsAlike.username#'; pointsAward.find_user.click();">
							#NameSoundsAlike.username#
							</a>
						</td>
						<td>
							#NameSoundsAlike.fname# #NameSoundsAlike.lname#
						</td>
						<td>
							#NameSoundsAlike.email#
						</td>
						<td>
							#NameSoundsAlike.idh#
						</td>
					</tr>
				</cfloop>
				</table>
			</cfif>
		</cfif>
		<br>
	</cfif>
	<cfset this_user = ListFirst(GetHoldUser.email,"@")>
	<cfset this_domain = ListLast(GetHoldUser.email,"@")>
	<cfquery name="EmailSoundsAlike" datasource="#application.DS#">
		SELECT ID, username, fname, lname, email, idh, is_active 
		FROM #application.database#.program_user
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER">
		AND SUBSTRING(email, 1, LOCATE('@', email) - 1) SOUNDS LIKE '#this_user#'
		AND SUBSTRING(email, LOCATE('@', email) + 1) SOUNDS LIKE '#this_domain#'
		ORDER BY email
	</cfquery>
	<cfif EmailSoundsAlike.RecordCount GT 0>
		#GetHoldUser.email# is in an upload for #GetHoldUser.source_import#, and could possibly be one the following <span class="highlight">program users</span>:<br>
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
			<tr class="contenthead">
				<td class="headertext">Active</td>
				<td class="headertext">Username</td>
				<td class="headertext">Name</td>
				<td class="headertext">Email Address</td>
				<td class="headertext">IDH</td>
			</tr>
			<cfloop query="EmailSoundsAlike">
				<tr>
					<td>#YesNoFormat(EmailSoundsAlike.is_active)#</td>
					<td>
						<a href="javascript:void(0);" onClick="pointsAward.email.value='#EmailSoundsAlike.email#'; pointsAward.find_user.click();">
						#EmailSoundsAlike.username#
						</a>
					</td>
					<td>
						#EmailSoundsAlike.fname# #EmailSoundsAlike.lname#
					</td>
					<td>
						#EmailSoundsAlike.email#
					</td>
					<td>
						#EmailSoundsAlike.idh#
					</td>
				</tr>
			</cfloop>
		</table>
		<br>
	</cfif>
	<form id="emailChange" action="#CurrentPage#?pgfn=newemail&sort=#url.sort#&id=#url.id#&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#" method="post">
		<table cellpadding="3" cellspacing="0" border="0">
			<tr class="contenthead"><td colspan="2" class="headertext">Change the above email address to:</td></tr>
			<tr class="content2"><td align="right">Email:</td><td><input type="text" name="newemail" value="#form.email#"></td></tr>
			<tr class="content"><td colspan="2" align="center"><input type="submit" name="find_user" value="  Change Email  "></td></tr>
		</table>
	</form>
	<br><br>
	<form id="pointsAward" action="#CurrentPage#?pgfn=award&sort=#url.sort#&id=#url.id#&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#" method="post">
		<table cellpadding="3" cellspacing="0" border="0">
			<tr class="contenthead"><td colspan="2" class="headertext">Award the above #ThisTotalPoints# points to:</td></tr>
			<tr class="content2"><td align="right">Username:</td><td><input type="text" name="username" value="#form.username#"></td></tr>
			<tr class="content2"><td align="right">or&nbsp;&nbsp;&nbsp;</td><td align="center" class="sub">Enter only one of these fields.</td></tr>
			<tr class="content2"><td align="right">Email:</td><td><input type="text" name="email" value="#form.email#"></td></tr>
			<tr class="content"><td colspan="2" align="center"><input type="submit" name="find_user" value="  Find User  "></td></tr>
			<tr class="content"><td colspan="2" align="center" class="sub">Points will not be awarded until you confirm on the next screen.</td></tr>
		</table>
	</form>
	</cfoutput>

<!--- ----------------------- --->
<!--- ------  Confirm ------- --->
<!--- ----------------------- --->

<cfelseif url.pgfn EQ "confirm">
	<cfoutput>
	<form action="#CurrentPage#?pgfn=award&sort=#url.sort#&id=#url.id#&xOnPage=#xOnPage#&search_text=#search_text#&email_initial=#email_initial#" method="post">
		<input type="hidden" name="user_ID" value="#GetExistingUser.ID#" />
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
			<tr class="contenthead"><td colspan="2" class="headertext">Award the above #ThisTotalPoints# points to:</td></tr>
			<tr class="content"><td align="right"><strong>Username:</strong></td><td>#GetExistingUser.username#</td></tr>
			<tr class="content"><td align="right"><strong>Name:</strong></td><td>#GetExistingUser.fname#&nbsp;#GetExistingUser.lname#</td></tr>
			<tr class="content"><td align="right"><strong>Email:</strong></td><td>#GetExistingUser.email#</td></tr>
			<tr class="content"><td align="right"><strong>IDH:</strong></td><td>#GetExistingUser.idh#</td></tr>
			<tr class="content"><td colspan="2" align="center"><input type="submit" name="award_points" value="  Award Points  "></td></tr>
			<tr class="content"><td colspan="100%"></td></tr>
		</table>
	</form>
	</cfoutput>
</cfif>

<!--- ---------------------- --->
<!--- ------  DONE   ------- --->
<!--- ---------------------- --->
<SCRIPT LANGUAGE="JavaScript"><!-- 
function openURL()
{ 
// grab index number of the selected option
selInd = document.pageform.pageselect.selectedIndex; 
// get value of the selected option
goURL = document.pageform.pageselect.options[selInd].value;
// redirect browser to the grabbed value (hopefully a URL)
top.location.href = goURL; 
}
//--> 
</SCRIPT>

<cfinclude template="includes/footer.cfm">
