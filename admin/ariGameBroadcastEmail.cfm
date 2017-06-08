<!--- ARI Game Email Changes
	1) line 26 change file name
	2) line 127 change number
 --->

<!--- import function libraries --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000086,true)>

<!--- variables used on page --->
<cfparam name="pgfn" default="broadcast">
<cfparam name="previewSent" default="false">
<cfset HTMLFilePath = application.AbsPath & "email/">
<cfset URLFileName = 'arigame10.html'>

<!--- displayed form fields --->
<cfparam name="fromemail" default="#application.AwardsFromEmail#">
<cfparam name="subject" default="ARI insights Innovations Message">
<cfparam name="ID" default="0">
<cfparam name="testEmailAddress" default="#application.AwardsFromEmail#">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined("form.pgfn")>
	<cffile action="read" file="#HTMLFilePath##URLFileName#" variable="theFile">

	<cfif ListFindNoCase('Test E-Mail,Resend Test E-Mail', form.pgfn, ',')>
		<cfquery name="getTestContestant" datasource="#application.DS#">
			SELECT ID, fname, lname, email, points, user_ID
			FROM #application.database#.ariGameContestants
			WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ID#">
			ORDER BY email
		</cfquery>
		<cfset emailFile = Replace(theFile, '%DATE%', DateFormat(Now(), 'mm/dd/yyyy'), 'all')>
		<cfset emailFile = Replace(emailFile, '%ID%', getTestContestant.user_ID, 'all')>
		<cfset emailFile = Replace(emailFile, '%FNAME%', getTestContestant.fname, 'all')>
		<cfset emailFile = Replace(emailFile, '%LNAME%', getTestContestant.lname, 'all')>
		<cfset emailFile = Replace(emailFile, '%POINTS%', getTestContestant.points, 'all')>
		<cfmail failto="#Application.ErrorEmailTo#" to="#testEmailAddress#" from="#fromemail#" subject="#subject#" type="html">#emailFile#<p align="center">Please <a href="#application.SecureWebPath#/arigame.cfm?pgfn=remove&email=#testEmailAddress#">remove me</a> from any future mailings<br>Go to: #application.SecureWebPath#/arigame.cfm?pgfn=remove&email=#testEmailAddress#</p></cfmail>
		<cflocation url="#CurrentPage#?previewSent=true&id=#ID#&testemailaddress=#testemailaddress#&subject=#subject#&fromemail=#fromemail#" addtoken="no">

	<cfelseif form.pgfn EQ 'Send Final Broadcast'>

		<cfquery name="getContestants" datasource="#application.DS#">
			SELECT ID, fname, lname, email, points, user_ID
			FROM #application.database#.ariGameContestants
			WHERE is_optin = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
			ORDER BY email
		</cfquery>
		
		<cfset numEmailsSent = 0>
		<cfloop query="getContestants">
			<cfif FLGen_IsValidEmail(getContestants.email)>
				<cfset emailFile = Replace(theFile, '%DATE%', DateFormat(Now(), 'mm/dd/yyyy'), 'all')>
				<cfset emailFile = Replace(emailFile, '%ID%', user_ID, 'all')>
				<cfset emailFile = Replace(emailFile, '%FNAME%', fname, 'all')>
				<cfset emailFile = Replace(emailFile, '%LNAME%', lname, 'all')>
				<cfset emailFile = Replace(emailFile, '%POINTS%', points, 'all')>
				
				<cfmail failto="#Application.ErrorEmailTo#" to="#email#" from="#fromemail#" subject="#subject#" type="html">#emailFile#<p align="center">Please <a href="#application.SecureWebPath#/arigame.cfm?pgfn=remove&email=#email#">remove me</a> from any future mailings.<br>Go to: #application.SecureWebPath#/arigame.cfm?pgfn=remove&email=#testEmailAddress#</p></cfmail>
				<cfset numEmailsSent = numEmailsSent + 1>
			</cfif>
		</cfloop>
		
		<cfmail failto="#Application.ErrorEmailTo#" to="#fromemail#" from="#fromemail#" subject="Broadcast Completion">
			Broadcast completed on #DateFormat(Now(), "mm/dd/yyyy")# at #TimeFormat(Now(), "hh:mm")#.
			#numEmailsSent# emails sent.
			EMail address sent from: #fromemail#
			Subject: #subject#
		</cfmail>
		
		<cflocation url="#CurrentPage#?pgfn=broadcastSent" addtoken="no">
		
	</cfif>	
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "ari_broadcaster">
<cfinclude template="includes/header.cfm">
<cfoutput>
<table width="100%" cellpadding="2" cellspacing="0" border="0">
	<tr>
		<td width="10%" nowrap="nowrap">Date:</td>
		<td width="90%">#DateFormat(NOW(), 'mm/dd/yyyy')#</td>
	</tr>
	<tr>
		<td nowrap="nowrap">Program:</td>
		<td>ARI Game</td>
	</tr>
	<tr>
		<td nowrap="nowrap">Email:</td>
		<td>Letter ##10 <cfif URLFileName GT "">(<a href="/email/#URLFileName#" target="_blank">Preview</a>)</cfif></td>
	</tr>
	<cfif pgfn EQ 'broadcast'>
		<tr>
			<td nowrap="nowrap">Go to:</td>
			<td><a href="#CurrentPage#?pgfn=previewList">Preview</a></td>
		</tr>
	<cfelse>
		<tr>
			<td nowrap="nowrap">Go to:</td>
			<td><a href="#CurrentPage#?pgfn=broadcast">Broadcast</a></td>
		</tr>
	</cfif>
</table>
<br />
<cfif ListFindNoCase('previewList,broadcastSent', pgfn, ',')>
	<cfquery name="getContestants" datasource="#application.DS#">
		SELECT ID, email, CONCAT(fname, ' ', lname) AS username, points
		FROM #application.database#.ariGameContestants
		WHERE is_optin = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
		ORDER BY email
	</cfquery>
	<table width="100%" cellpadding="5" cellspacing="1" border="0">
		<tr valign="top" class="contenthead">
			<td width="35%" class="headertext">Email Address</td>
			<td width="35%" class="headertext">Name</td>
			<td width="15%" align="center" class="headertext">Points</td>
			<td width="15%" align="center" class="headertext">Broadcast</td>
		</tr>
		<cfif getContestants.recordcount GT 0>
			<cfset validEmailAddresses = 0>
			<cfloop query="getContestants">
				<cfif FLGen_IsValidEmail(getContestants.email)>
					<cfset TextStyle = "color: ##00CC00;">
					<cfset broadcast = "Yes">
					<cfset validEmailAddresses = validEmailAddresses + 1>
				<cfelse>
					<cfset TextStyle = "color: ##FF0000;">
					<cfset broadcast = "No">
				</cfif>
				<cfif getContestants.currentrow MOD 2 EQ 0>
					<cfset rowClass = "content">
				<cfelse>
					<cfset rowClass = "content2"></cfif>
				<tr valign="top" class="#rowClass#">
					<td>#email#</td>
					<td>#username#</td>
					<td align="center">#points#</td>
					<td align="center" style="#TextStyle#">#broadcast#</td>
				</tr>
			</cfloop>
			<tr valign="top" bgcolor="##FFFFFF">
				<td align="right" colspan="4">Total Users: #NumberFormat(getContestants.recordcount, '_,___')#</td>
			</tr>
			<tr valign="top" bgcolor="##FFFFFF">
				<td align="right" colspan="4">
					<cfif pgfn EQ "previewList">Total to email:<cfelse>Total emails sent:</cfif> #NumberFormat(validEmailAddresses, '_,___')#</td>
			</tr>
		<cfelse>
			<tr valign="top" class="content">
				<td colspan="4" align="center">There are currently no registered contestants.</td>
			</tr>
		</cfif>	
	</table>
<cfelseif pgfn EQ 'broadcast'>
	<form name="form1" method="post" action="#CurrentPage#">
		<table width="100%" cellpadding="9" cellspacing="0" border="2" class="leftnav">
			<tr valign="top">
				<td class="pageheader">Send Broadcast Email From:</td>
			</tr>
			<tr valign="top">
				<td align="center">
					<table cellpadding="2" cellspacing="0" border="0">
						<tr>
							<td align="right">From Email Address:</td>
							<td><input type="text" name="fromemail" size="60" value="#application.AwardsFromEmail#" readonly /></td>
						</tr>
						<tr>
							<td align="right">Subject:</td>
							<td><input type="text" name="subject" size="60" value="#subject#" /></td>
						</tr>
						<cfquery name="getTestUser_ID" datasource="#application.DS#">
							SELECT user_ID, CONCAT(fname,' ',lname) AS username, email 
							FROM #application.database#.ariGameContestants
							ORDER BY ID
							LIMIT 10
						</cfquery>
						<tr>
							<td align="right">Test ID:</td>
							<td>
								<select name="ID">
									<cfloop query="getTestUser_ID">
										<option value="#user_ID#">#user_ID# - #username# #email#</option>
									</cfloop>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right">Send Test to E-mail Address:</td>
							<td><input type="text" name="testemailaddress" size="60" value="#testemailaddress#" /></td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td align="center">
					<table cellpadding="5" cellspacing="0" border="1">
						<tr><th colspan="2">MERGE CODES</th></tr>
						<tr>
							<th>Code</th>
							<th>Replacement Value</th>
						</tr>
						<tr>
							<td>%DATE%</td>
							<td>Current Date</td>
						</tr>
						<tr>
							<td>%FNAME%</td>
							<td>First Name</td>
							</tr>
						<tr>
							<td>%LNAME%</td>
							<td>Last Name</td>
						</tr>
						<tr>
							<td>%POINTS%</td>
							<td>Points/Dollar Value Credits</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr valign="top">
				<td align="center">
					<cfif previewSent>
						Click the button below if you would like to test your message again.
					<cfelse>
						Click the button below to test your message.
					</cfif>
				</td>
			</tr>
			<tr valign="top">
				<td align="center"><input type="submit" name="pgfn" value="<cfif previewSent>Resend </cfif>Test E-Mail" /></td>
			</tr>
			<cfif previewSent>
				<tr valign="top">
					<td align="center">
						Click the button below
						<div class="alert">ONLY ONCE!</div>
						Your broadcast may take some time. Please exit this window and check your e-mail later for a confirmation of the finished broadcast.
					</td>
				</tr>
				<tr>
					<td align="center"><input type="submit" name="pgfn" value="Send Final Broadcast"></td>
				</tr>
			</cfif>
		</table>
	</form>					
</cfif>
</cfoutput>

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->

<cfinclude template="includes/footer.cfm">
