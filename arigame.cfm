<!--- <!--- variables used on the page --->
<cfparam name="pgfn" default="secretword">
<cfparam name="alert_msg" default="">
<cfparam name="email" default="">

<!--- form variables --->
<cfparam name="form.company" default="">
<cfparam name="form.fname" default="">
<cfparam name="form.lname" default="">
<cfparam name="form.email" default="">
<cfparam name="form.title" default="">
<cfparam name="form.address1" default="">
<cfparam name="form.address2" default="">
<cfparam name="form.address3" default="">
<cfparam name="form.city" default="">
<cfparam name="form.state" default="">
<cfparam name="form.zip" default="">
<cfparam name="form.country" default="">
<cfparam name="form.phone" default="">
<cfparam name="form.user_ID" default="">
<cfparam name="form.secret_word" default="">

<cfif IsDefined("form.submit") AND IsDefined("form.pgfn")>
	<cfif form.pgfn EQ 'register'>
		
		<!--- make sure all form fields are not greater than their max length --->
		<cfset formvariables = StructNew()>
		<cfset formvariables.fieldnames = 'company,fname,lname,email,title,address1,address2,address3,city,state,zip,country,phone'>
		<cfset formvariables.fieldlengths = '30,30,30,42,30,64,64,64,30,30,10,30,20'>
		<cfset violation = false>
		<cfset counter = 1>
		<cfloop list="#formvariables.fieldnames#" index="iField">
			<cfset iLength = ListGetAt(formvariables.fieldlengths, counter, ',')>
			<cfif Len(form[iField]) GT iLength>
				<cfset violation = true>
				<cfbreak>
			</cfif>
			<cfset counter = counter + 1>
		</cfloop>
		
		<cfif NOT violation>
			<!---check to see if the email address entered is already in the database--->
			<cfquery name="checkContestant" datasource="#application.DS#">
				SELECT ID, user_ID
				FROM #application.database#.ariGameContestants
				WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="42">
			</cfquery>
			
			<cfif checkContestant.recordcount EQ 0>
				
				<cflock name="ariGameContestantsLock" timeout="10">
					
					<cftransaction>
						
						<!--- Create a Valuelist of all the current UserIDs --->
						<cfquery name="checkUserID" datasource="#application.DS#">
							SELECT user_ID
							FROM #application.database#.ariGameContestants
							ORDER BY user_ID
						</cfquery>
						<cfset userIDs = ValueList(checkUserID.user_ID, ',')>
						
						<!--- Generate a unique random 6 digit numeric user_ID--->
						<cfinvoke component="#application.ComponentPath#.general" method="init" returnvariable="iGeneral">
						<cfset user_ID = iGeneral.GenerateRandomString(6,3)>
						<cfloop condition="ListFindNoCase(userIDS, user_ID, ',') NEQ 0">
							<cfset user_ID = iGeneral.GenerateRandomString(6,3)>
						</cfloop>
						
						<!--- insert the new contestant --->
						<cfquery name="insertContestant" datasource="#application.DS#">
							INSERT INTO #application.database#.ariGameContestants
								(company,fname,lname,email,title,address1,address2,
								 address3,city,state,zip,country,phone,user_ID)
							VALUES(<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.company#" maxlength="30">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fname#" maxlength="30">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lname#" maxlength="30">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="42">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.title#" maxlength="30">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address1#" maxlength="64">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address2#" maxlength="64">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address3#" maxlength="64">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.city#" maxlength="30">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.state#" maxlength="30">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zip#" maxlength="10">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.country#" maxlength="30">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.phone#" maxlength="20">,
								   <cfqueryparam cfsqltype="cf_sql_varchar" value="#user_ID#" maxlength="30">)
						</cfquery>
						
					</cftransaction>
						
				</cflock>
				
			<cfelse>
				
				<!--- update an existing contestant --->
				<cfquery name="updateContestant" datasource="#application.DS#">
					UPDATE #application.database#.ariGameContestants
					SET company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.company#" maxlength="30">,
						fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fname#" maxlength="30">,
						lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lname#" maxlength="30">,
						title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.title#" maxlength="30">,
						address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address1#" maxlength="64">,
						address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address2#" maxlength="64">,
						address3 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address3#" maxlength="64">,
						city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.city#" maxlength="30">,
						state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.state#" maxlength="30">,
						zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zip#" maxlength="10">,
						country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.country#" maxlength="30">,
						phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.phone#" maxlength="20">
					WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="42">
				</cfquery>
				
				<cfset user_ID = checkContestant.user_ID>
					
			</cfif>
			
			<!--- email the user there ARI insight ID--->
			<cfmail to="#form.email#" from="#application.AwardsFromEmail#" subject="ARI Insights Innovations Message" type="html">Congratulations on completing your ARI insight ID registration.  Your ARI insight ID is #user_ID#.<br />Please return each week and enter the last word.</cfmail>
			
			<!--- set page variables --->
			<cfset pgfn = 'secretword'>
			<cfset alert_msg = 'Congratulations on completing your ARI insight ID registration.<br />Your ARI insight ID is <strong>' & user_ID & '</strong>.'> 
			
		</cfif>	
		
	<cfelseif form.pgfn EQ "secretword" and form.user_ID NEQ "" and form.secret_word NEQ "">
		
		<!--- make sure all form fields are not greater than their max length --->
		<cfset formvariables = StructNew()>
		<cfset formvariables.fieldnames = 'user_ID'>
		<cfset formvariables.fieldlengths = '6'>
		<cfset violation = false>
		<cfset counter = 1>
		<cfloop list="#formvariables.fieldnames#" index="iField">
			<cfset iLength = ListGetAt(formvariables.fieldlengths, counter, ',')>
			<cfif Len(form[iField]) GT iLength>
				<cfset violation = true>
				<cfbreak>
			</cfif>
			<cfset counter = counter + 1>
		</cfloop>
		
		<cfif NOT violation>
			<!--- check to see if the ARI insight ID exits--->
			<cfquery name="checkID" datasource="#application.DS#">
				SELECT user_ID, points
				FROM #application.database#.ariGameContestants
				WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.user_ID#" maxlength="6">
			</cfquery>
						
			<cfif checkID.recordcount GT 0>
				
				<!--- increment the user's points --->
				<cfset newPoints = Val(checkID.points) + 1>
				<cfquery name="updatePoints" datasource="#application.DS#">
					UPDATE #application.database#.ariGameContestants
					SET points = <cfqueryparam cfsqltype="cf_sql_integer" value="#newPoints#">
					WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.user_ID#" maxlength="6">
				</cfquery>
				
				<cfset pgfn = 'congratulations'>
				
			<cfelse>
				
				<cfset pgfn = 'secretword'>
				<cfset alert_msg = 'Either the ARI insight ID or secret word you entered is incorrect.<br />Please try again.'>
				
			</cfif>
			
		</cfif>			
	<cfelseif pgfn EQ 'remove'>
		
		<cfquery name="checkForUser" datasource="#application.DS#">
			SELECT ID
			FROM #application.database#.ariGameContestants
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="42">
		</cfquery>
		
		<cfif checkForUser.recordcount GT 0>
		
			<cfquery name="optUserOut" datasource="#application.DS#">
				UPDATE #application.database#.ariGameContestants
				SET is_optin = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
				WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="42">
			</cfquery>
			
			<cfset alert_msg = 'You have been successfully removed from the ARI insight mailing list.  Thank you.'>
		
		<cfelse>
			
			<cfset alert_msg = 'The email address you entered could not be found in the ARI insight mailing list.  Please check the email address you enterd and try again.'>	
			
		</cfif>
		
	</cfif>
</cfif>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Win a Dell Insights D620 - ARI Insights</title>
		<style type="text/css">
			body{
				background-color: #FFFFFF;
				font-family: Arial, Helvetica, sans-serif;
				font-size: 12px;
				color: #000000;
				margin: 0px;
			}
			p{
				margin-left: 40px;
				margin-right: 40px;
			}
			a{color: #0000CC;}
			a:vlink{color: #0000CC;}
			a:alink{color: #FF0000;}
			a:hover{text-decoration:none;}
			.reglink{font-size: 11px;}
			.redBold{
				color: #FF0000;
				font-weight: bold;
			}
		</style>
	</head>

	<body>
		<table width="553" cellpadding="5" border="1" align="center" bordercolor="#000000">
  			<tr>
    			<td>
					<img src="email/pics/ari/top.jpg" alt="Win a new Dell Latitude D620!" width="550" height="347" />
					<cfif ListFindNoCase('secretword,register',pgfn,',')>
						<cfif pgfn EQ 'register'>
							<p>Please fill out all required fields and click submit.<p>
						<cfelse>
							<p>Enter your ARI insights ID in the box provided.  Next enter this week’s word in the box provided.  Click submit.</p>
						</cfif>
						<cfif alert_msg NEQ ""><cfoutput><p class="redBold">#alert_msg#</p></cfoutput></cfif>
						<p><span class="redBold">*</span>&nbsp;&nbsp;Denotes required fields</p>				
						<table width="550" cellpadding="5" cellspacing="0" border="0" align="center">
							<form name="form1" method="post" action="<cfoutput>#CurrentPage#</cfoutput>">
								<input type="hidden" name="pgfn" value="<cfoutput>#pgfn#</cfoutput>" />
								<cfif pgfn EQ 'secretword'>
									<tr valign="middle">
										<td align="right" nowrap="nowrap">
											<span class="redBold">*</span> Your ARI insights ID:<br />
											<span class="reglink">(get an <a href="<cfoutput>#CurrentPage#</cfoutput>?pgfn=register">ARI insights ID</a>)</span>
									  </td>
										<td>
											<input type="text" name="user_ID" size="30" maxlength="6" />
											<input type="hidden" name="user_ID_cfformrequired" value="You must enter your ARI insight ID." />
									  </td>
									</tr>
									<tr valign="middle">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> This week's word:</td>
										<td>
											<input type="text" name="secret_word" size="30" maxlength="75"/>
											<input type="hidden" name="secret_word_cfformrequired" value="You must enter this week's last word." />
										</td>
									</tr>
								<cfelseif pgfn EQ 'register'>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> First name:</td>
										<td>
											<input type="text" name="fname" size="35" maxlength="30" />
											<input type="hidden" name="fname_cfformrequired" value="You must enter a first name." />	
									  </td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> Last name:</td>
										<td>
											<input type="text" name="lname" size="35" maxlength="30" />
											<input type="hidden" name="lname_cfformrequired" value="You must enter a last name." />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> Company:</td>
										<td>
											<input type="text" name="company" size="35" maxlength="30" />
											<input type="hidden" name="company_cfformrequired" value="You must enter a company." />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap">Title:</td>
										<td><input type="text" name="title" size="35" maxlength="30" /></td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> Email Address:</td>
										<td>
											<input type="text" name="email" size="35" maxlength="42" />
											<input type="hidden" name="email_cfformrequired" value="You must enter an email address." />
											<input type="hidden" name="email_cfformemail" value="The email address you entered is invalid.  Please enter a valid email address." />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> Address:</td>
										<td>
											<input type="text" name="address1" size="50" maxlength="64" />
											<input type="hidden" name="address1_cfformrequired" value="You must enter an address." /><br />
											<img src="pics/shim.gif" width="1" height="5" alt="" /><br />
											<input type="text" name="address2" size="50" maxlength="64" /><br />
											<img src="pics/shim.gif" width="1" height="5" alt="" /><br />
											<input type="text" name="address3" size="50" maxlength="64" />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> City:</td>
										<td>
											<input type="text" name="city" size="35" maxlength="30" />
											<input type="hidden" name="city_cfformrequired" value="You must enter a city." />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> State:</td>
										<td>
											<input type="text" name="state" size="35" maxlength="30" />
											<input type="hidden" name="state_cfformrequired" value="You must enter a state." />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> Postal Code:</td>
										<td>
											<input type="text" name="zip" size="15" maxlength="10" />
											<input type="hidden" name="zip_cfformrequired" value="You must enter a postal code." />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> Country:</td>
										<td>
											<input type="text" name="country" size="35" maxlength="30" />
											<input type="hidden" name="country_cfformrequired" value="You must enter a country." />
										</td>
									</tr>
									<tr valign="top">
										<td align="right" nowrap="nowrap"><span class="redBold">*</span> Phone:</td>
										<td>
											<input type="text" name="phone" size="25" maxlength="20" />
											<input type="hidden" name="phone_cfformrequired" value="You must enter a phone number." />
										</td>	
									</tr>
								</cfif>
								<tr>
									<td width="165">&nbsp;</td>
								  <td width="365"><input type="submit" name="submit" value="Submit" /></td>
								</tr>
							</form>
						</table>
					<cfelseif pgfn EQ 'congratulations'>
						<p><strong>CONGRATULATIONS!!!!</strong> You  entered the correct word.</p>						
					<cfelseif pgfn EQ 'remove'>
						<p>To be removed from future emails please enter your email address below and click the 'Remove Me' button.</p>
						<cfif alert_msg NEQ ""><cfoutput><p class="redBold">#alert_msg#</p></cfoutput></cfif>
						<p><span class="redBold">*</span>&nbsp;&nbsp;Denotes required fields</p>				
						<table width="550" cellpadding="5" cellspacing="0" border="0" align="center">
							<form name="form1" method="post" action="<cfoutput>#CurrentPage#</cfoutput>">
								<input type="hidden" name="pgfn" value="<cfoutput>#pgfn#</cfoutput>" />
								<tr valign="top">
									<td align="right" nowrap="nowrap"><span class="redBold">*</span> Email Address:</td>
									<td>
										<input type="text" name="email" value="<cfoutput>#email#</cfoutput>" size="35" maxlength="42" />
										<input type="hidden" name="email_cfformrequired" value="You must enter an email address." />
										<input type="hidden" name="email_cfformemail" value="The email address you entered is invalid.  Please enter a valid email address." />
									</td>
								</tr>
								<tr>
									<td width="165">&nbsp;</td>
								  	<td width="365"><input type="submit" name="submit" value="Remove Me" /></td>
								</tr>
								
							</form>
						</table>
					</cfif>
					<p>&nbsp;</p>
					<a href="http://www.arifleet.com" target="_blank"><img src="email/pics/ari/header.gif" alt="Automotive Resources International - 9000 Midlantic Drive - Mt. Laurel, NJ 08054 - arifleet.com" width="552" height="18" border="0" /></a>
				</td>
			</tr>
		</table>
	</body>
</html>

 --->
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<link rel="shortcut icon" href="/favicon.ico" />
<title>Win a Dell Insights D620 - ARI Insights</title>
</head>

<body text="#000000" link="#0000CC" vlink="#0000CC" alink="#FF0000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<cfinclude template="includes/environment.cfm"> 

<table width="553" border="1" align="center" bordercolor="#000000" bgcolor ="#FFFFFF">
  <tr>
    <td valign="top"><div align="center"><img src="/email/pics/ari/winner_top.jpg" alt="Win a new Dell Latitude D620!" width="562" height="345" /></div>
      <div align="center"> </div>
      <table width="500" align="center">
        <tr> 
          <td height="290" valign="top"> 
            <p>Congratulations!</p>
            <p>We held our drawing for three free laptop PCs and ARI - Automotive 
              Resources International is pleased to announce the winners. They 
              are:</p>
            <table width="496" border="0" cellpadding="2">
              <tr> 
                <td width="109">Theresa Belding</td>
                <td width="28"><font color="#FFFFFF">MM</font></td>
                <td width="118">Darrell Womack</td>
                <td width="28"><font color="#FFFFFF">MM</font></td>
                <td width="145">Mel Sprouse</td>
              </tr>
              <tr> 
                <td><font size="-1">Forest Pharmaceuticals</font></td>
                <td><font size="-1">&nbsp;</font></td>
                <td><font size="-1">Siemens</font></td>
                <td><font size="-1">&nbsp;</font></td>
                <td><font size="-1">Norfolk Southern RR</font></td>
              </tr>
            </table>
            <p>We ask the winners to contact Tom Ragan at 856-787-6547 or tragan@arifleet.com 
              so that we can arrange delivery of your new laptop.</p>
            <p>With approximately 600 contest entries, the response to our <strong>ARI 
              <em>insights</em></strong>&#8482; Innovations mailings was excellent. 
              We believe everyone who participated is a winner and we thank all 
              who did!</p>
            <p align="center"><img src="/email/pics/ari/winner_ARI.gif" width="117" height="61" /><br />
            </p></td>
        </tr>
      </table>
      <a href="http://www.arifleet.com" target="_blank"><img src="/email/pics/ari/winner_header.gif" alt="Automotive Resources International - 9000 Midlantic Drive - Mt. Laurel, NJ 08054 - arifleet.com" width="552" height="18" border="0" /></a>    </td>
  </tr>
</table>
</body>
</html>
