<!--- import function libraries --->
<cfinclude template="/cfscripts/dfm_common/function_library_page.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinvoke component="#application.ComponentPath#.encryption" method="init" returnvariable="iEncrypt">
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">

<!--- authenticate the admin user --->
<!---
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000033,true)>
--->

<!--- variables used on this page --->
<cfparam name="pgfn" default="send_email">
<cfparam name="from_name" default="From Name">
<cfparam name="from_email" default="#application.AwardsFromEmail#">
<cfparam name="email_subject" default="In More Ways Than One It Pays to Stick with Loctite&reg;">
<cfparam name="failto" default="#Application.ErrorEmailTo#">
<cfparam name="email_text" default="">
<cfparam name="send_to" default="0">
<cfset status_msg = "Invalid Email Addresses:#chr(10)#">
<cfset testing_count = 0>
<cfset email_count = 0>
<cfset database = "Resorts">
<cfset RemovePath = "http://www.resortsatlanticcity.net/">
<cfparam name="template" default="">

	
<!--- JavaScript --->
<!--- 
<script language="javascript" type="text/javascript">

	function toggleCheckboxes(){
		var f = document.form1;
		
		var disabled_status = true;
		
		if(!f.send_to[0].checked){
			disabled_status = false;
		}
		
		for(var i = 1; i < f.send_to.length; i++){
			f.send_to[i].checked = false;
			f.send_to[i].disabled = disabled_status;
		}
	}
--->	
<script language="javascript" type="text/javascript">
	function submitForm(txt){
		var cells = new Array('submit_cell_1','submit_cell_2');
		
		for(var i = 0; i < cells.length; i++){
			var elem = document.getElementById(cells[i]);
			var celltext = document.createTextNode(txt);	
			while(elem.childNodes.length > 0){
			
				elem.removeChild(elem.firstChild);
			
			}
			
			elem.appendChild(celltext);
			
		}
	}
	
	
</script>


<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif CGI.REQUEST_METHOD EQ 'POST'>

	<cfset alert_msg = "">

<!---				
	<cffile action="read" file="#application.AbsPath#email/#template#" variable="InFile">
--->
	<cffile action="read" file="/inetpub/wwwroot/content/htdocs/itcawards_v2/email/henkel_05.html" variable="InFile">
<!---
	<cfset InFile = Replace(InFile, "<!--INSERT MESSAGE HERE-->", form.email_text, "ALL")>
--->	
	<!--- send manual/testing emails --->
	<cfif testing_email NEQ "">
		<cfloop list="#testing_email#" index="i_email">
			<cfif FLGen_IsValidEmail(i_email)>
				<cfmail to="#i_email#" from="#from_email#" subject="#email_subject#" type="html" failto="#form.failto#,#Application.ErrorEmailTo#">#InFile#</cfmail>
				<cfset testing_count = IncrementValue(testing_count)>
			<cfelse>
				<cfset alert_msg = alert_msg & "\nTesting email [#i_email#] was not valid.">
			</cfif>
		</cfloop>
		<cfset alert_msg = alert_msg & "\n[#testing_count#] Testing Email(s) sent.">
	</cfif>

	<!--- send emails to opt-in group(s) --->
	<cfif send_to NEQ 0>
		<cfquery name="BroadcastList" datasource="DB" timeout="60">
			SELECT email
			FROM #application.database#.henkel_gilson_canada
		</cfquery>
		<cfif BroadcastList.RecordCount EQ 0>
			<cfset alert_msg = alert_msg & "\n\nNO BROADCAST EMAILS WERE SENT\nThere are no contacts in the selected opt-in group(s).">
		<cfelse>
			<cfoutput query="BroadcastList">
				<cfif FLGen_IsValidEmail(email)>
					<cfmail failto="#Application.ErrorEmailTo#" to="#email#" from="#from_email#" subject="#email_subject#" type="html">#Infile#</cfmail> 
Sent To: #email#<br />		
					<cfset email_count = IncrementValue(email_count)>
				<cfelse>
					<cfset status_msg = status_msg & "#Chr(10)#Email [#email#] was not valid.">
				</cfif>
			</cfoutput>
			<!--- email upon completion --->
			<cfmail to="#from_email#" from="#from_email#" subject="CLM Broadcast Email Completion">
Broadcast completed on #DateFormat(NOW(), "MM/DD/YYYY")# at #TimeFormat(NOW(), "HH:MM")#.
#email_count# emails sent.
Email "from" address: #from_email#
Subject: #email_subject#

#status_msg#
			</cfmail>
			<cfset pgfn = "emails_sent">
		</cfif>
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "clm_broadcast">

<!--- START pgfn SEND_EMAIL --->
<cfif pgfn EQ "send_email">

<span class="pagetitle">CLM Email Broadcast</span>
<br /><br />

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<cfoutput>
	
	<form method="post" name="form1" action="#CurrentPage#" onSubmit="submitForm('Sending Email...'); return true;">

	<tr class="BGdark">
	<td class="TEXTheader" colspan="2">Email Information</td>
	</tr>
	
	<tr class="BGlight1">
	<td align="right">email subject:</td><td><input type="text" name="email_subject" value="#email_subject#" size="65" />
	<input type="hidden" name="email_subject_required" value="You must enter an email subject" /></td>
	</tr>
	
	<tr class="BGlight1">
	<td align="right">sender name:</td><td><input type="text" name="from_name" value="#from_name#" size="65" />
	<input type="hidden" name="from_name_required" value="You must enter a sender email address" /></td>
	</tr>
	
	<tr class="BGlight1">
	<td align="right">sender email address:</td><td><input type="text" name="from_email" value="#application.AwardsFromEmail#" size="65" readonly />
	<input type="hidden" name="from_email_required" value="You must enter a sender name" /></td>
	</tr>
	
	<tr class="BGlight1">
	<td align="right">send bounced emails to:</td><td><input type="text" name="failto" value="#failto#" size="65" />
	<input type="hidden" name="failto_required" value="You must enter an email address where bounced emails will be sent" /></td>
	</tr>
<!---	
	<tr class="BGlight1">
	<td align="right" valign="top">Choose Template</td>
	<td>
	<input type="radio" name="template" value="Special-Offer-080129a.html"<cfif template IS "Special-Offer-080129a.html"> checked="checked"</cfif> />Template A<br />
	<input type="radio" name="template" value="Special-Offer-080129b.html"<cfif template IS "Special-Offer-080129b.html"> checked="checked"</cfif> />Template B<br />
	<input type="radio" name="template" value="Special-Offer-080129c.html"<cfif template IS "Special-Offer-080129c.html"> checked="checked"</cfif> />Template C<br />
	<input type="radio" name="template" value="Special-Offer-080129d.html"<cfif template IS "Special-Offer-080129d.html"> checked="checked"</cfif> />Template D<br />
	<input type="radio" name="template" value="Special-Offer-080129e.html"<cfif template IS "Special-Offer-080129e.html"> checked="checked"</cfif> />Template E<br />
	</td>
	</tr>
--->	
<!---
	<tr class="BGdark">
	<td class="TEXTheader" colspan="2" nowrap="nowrap"><span class="alert">[1]</span> Enter Email Text</td>
	</tr>
	
	<tr class="BGlight1">
	<td colspan="2" align="center"><textarea name="email_text" cols="80" rows="15">#email_text#</textarea>	</td>
	</tr>
--->	
	<tr class="BGdark">
	<td class="TEXTheader" colspan="2" nowrap="nowrap"><span class="alert">[2]</span> Test Email</td>
	</tr>
	<!--- onLoad="toggleCheckboxes();" --->
	<tr class="BGlight2">
	<td colspan="2"><img src="../pics/contrls-desc.gif" > Enter one or more emails (separated by commas) to receive the press release.</td>
	</tr>
	
	<tr class="BGlight1">
	<td colspan="2" align="center"><input type="text" name="testing_email" size="80" value="" /></td>
	</tr>
	
	<tr class="BGlight1">
	<td colspan="2" align="center" id="submit_cell_1"><input type="submit" name="submit" value="Send Email To Everyone Indicated On This Page" /></td>
	</tr>
	
	<tr class="BGdark">
	<td colspan="2" class="TEXTheader"><span class="alert">[3]</span> Final Broadcast  <input type="checkbox" name="send_to" value="1" /></td>
	</tr>
<!---	
	<cfquery name="getSources" datasource="#application.DS#">
		SELECT *
		FROM #application.database#.opt_in_list
		ORDER BY list_name
	</cfquery>
	<cfset colA_endrow = Ceiling((getSources.recordcount - 1) / 2)>
	<cfset colB_startrow = colA_endrow + 1>

	<tr class="BGlight1">
	<td colspan="2" valign="top">
		<table width="100%" cellpadding="2" cellspacing="1" border="0">
		
		<tr valign="top">
		<td width="50%" nowrap="nowrap">
			<input type="checkbox" name="send_to" value="0" onClick="toggleCheckboxes();"<cfif ListFindNoCase(send_to,'0',',')> checked</cfif> /> <strong>None, just testing</strong><br />
			<cfloop query="getSources" startrow="1" endrow="#colA_endrow#">
				<input type="checkbox" name="send_to" value="#listID#"<cfif ListFindNoCase(send_to,getSources.listID,',')> checked</cfif> /> #list_name#<br />
			</cfloop>	
		</td>
		<td width="50%" nowrap="nowrap">
			<cfloop query="getSources" startrow="#colB_startrow#">
				<input type="checkbox" name="send_to" value="#listID#"<cfif ListFindNoCase(send_to,getSources.listID,',')> checked</cfif> /> #list_name#<br />
			</cfloop>	
		</td>
		</tr>
		
--->	
		
		</table>
	</td>
	</tr>
	
	<tr class="BGlight1">
	<td colspan="2" align="center" id="submit_cell_2"><input type="submit" name="submit" value="Send Email To Entire List" /></td>
	</tr>
		
	</form>
	
	</cfoutput>

	</table>

<!--- END pgfn SEND_EMAIL --->
<cfelseif pgfn EQ "emails_sent">
<!--- START pgfn EMAILS_SENT --->

<span class="pagetitle">CLM Email Broadcast</span>
<br /><br />
<span class="pageinstructions">Return to <a href="<cfoutput>#CurrentPage#</cfoutput>" class="actionlink">CLM Email Broadcast</a> main page.</span>
<br /><br /><br />

<cfoutput>
<b>Broadcast report:</b> (also emailed to #from_email#)
<br /><br />
Broadcast completed on #DateFormat(NOW(), "MM/DD/YYYY")# at #TimeFormat(NOW(), "HH:MM")#.
<br /><br />
#email_count# emails sent.
<br /><br />
Email "from" address: #from_email#
<br /><br />
Subject: #email_subject#
<br /><br />
#Replace(status_msg,chr(10),"<br>","ALL")#

</cfoutput>

<!--- END pgfn EMAILS_SENT --->
</cfif>
	

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->