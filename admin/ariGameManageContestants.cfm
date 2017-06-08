<!--- import function libraries --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_page.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000086,true)>

<!--- variables used on this page --->
<cfparam name="pgfn" default="list">
<cfparam name="delete" default="">

<!--- search criteria cri_S=ColumnSort cri_T =SearchString cri_L=Letter --->
<cfparam name="cri_S" default="lname">
<cfparam name="cri_T" default="">
<cfparam name="cri_L" default="">
<cfparam name="cri_A" default="">
<cfparam name="cri_B" default="">
<cfparam name="cri_C" default="">
<cfparam name="OnPage" default="1">

<!--- form fields --->
<cfparam name="ID" default="">
<cfparam name="company" default="">
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="email" default="">
<cfparam name="title" default="">
<cfparam name="address1" default="">
<cfparam name="address2" default="">
<cfparam name="address2" default="">
<cfparam name="city" default="">
<cfparam name="state" default="">
<cfparam name="zip" default="">
<cfparam name="country" default="">
<cfparam name="phone" default="">
<cfparam name="is_optin" default="1">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit') AND IsDefined('form.pgfn') AND form.pgfn EQ "edit">
	
	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.ariGameContestants
		SET company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#company#" maxlength="30">,
			fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fname#" maxlength="30">,
			lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lname#" maxlength="30">,
			email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#email#" maxlength="42">,
			title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#title#" maxlength="30">,
			address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#address1#" maxlength="64">,
			address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#address2#" maxlength="64">,
			address3 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#address3#" maxlength="64">,
			city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#city#" maxlength="30">,
			state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#state#" maxlength="30">,
			zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#zip#" maxlength="10">,
			country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#country#" maxlength="30">,
			phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#phone#" maxlength="20">,
			is_optin = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_optin#">
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
	</cfquery>
	<cfset alert_msg = "The changes were saved.">
	<cfset pgfn = "list">
	
<!--- delete --->
<cfelseif delete NEQ ''>

	<cfquery name="ToBeDeleted" datasource="#application.DS#">
		SELECT CONCAT(fname, ' ', lname) AS this_one_deleted
		FROM #application.database#.ariGameContestants
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#delete#">
	</cfquery>
	<cfset this_one_deleted = HTMLEditFormat(ToBeDeleted.this_one_deleted)>
	<cfquery name="DeleteThis" datasource="#application.DS#">
		DELETE FROM #application.database#.ariGameContestants
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#delete#">
	</cfquery>
	<cfset pgfn = "list">
	<cfset alert_msg = "The ARI game contestant [ #this_one_deleted# ] has been deleted.">

</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "ariGameManageContestants">
<cfinclude template="includes/header.cfm">

<script src="../includes/paging.js"></script>
<script src="../includes/showhide.js"></script>

<cfif pgfn EQ "list">
	<!--- START pgfn LIST --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID, company,fname,lname,email,points,is_optin, user_ID
		FROM #application.database#.ariGameContestants
		WHERE 1=1
		<cfif LEN(cri_T) GT 0>
			AND (fname LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(cri_T)#%">
				OR lname LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(cri_T)#%">
				OR email LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(cri_T)#%">
				OR company LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(cri_T)#%">)
		</cfif>
		<cfif cri_A EQ "1" OR cri_A EQ "0">
			AND is_optin = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cri_A#" maxlength="2">
		</cfif>
		<cfif cri_B EQ "0">
			AND points = 0
		<cfelseif cri_B EQ "1">
			AND points >= 1
		</cfif>
		<cfif cri_C EQ "0">
			AND created_datetime < 2006-08-18
		<cfelseif cri_C EQ "1">
			AND created_datetime > 2006-08-18
		</cfif>
		ORDER BY <cfqueryparam cfsqltype="cf_sql_varchar" value="#cri_S#"> ASC
	</cfquery>
	<span class="pagetitle">ARI Game - Contestant List</span>
	<br /><br />
	<!--- search box --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
		<tr class="contenthead">
			<td class="headertext">Search Criteria</td>
			<td align="right"><a href="#CurrentPage#" class="ltr">VIEW ALL</a></td>
		</tr>
		<tr valign="top">
			<td class="content2" colspan="2" align="center" valign="top">
				<cfoutput>
				<form action="#CurrentPage#" method="post">
					<table cellpadding="5">
					<tr>
					<td>
					<select name="cri_A" size="3">
						<option value=""#FLForm_Selected(cri_A,""," selected")#>Any User</option>
						<option value="1"#FLForm_Selected(cri_A,"1"," selected")#>Opt-in Users</option>
						<option value="0"#FLForm_Selected(cri_A,"0"," selected")#>Opt-out Users</option>
					</select>
					</td>
					<td>
					<select name="cri_B" size="3">
						<option value=""#FLForm_Selected(cri_B,""," selected")#>Any User</option>
						<option value="1"#FLForm_Selected(cri_B,"1"," selected")#>Users With Points</option>
						<option value="0"#FLForm_Selected(cri_B,"0"," selected")#>Users Without Points</option>
					</select>
					</td>
					<td>
					<select name="cri_C" size="3">
						<option value=""#FLForm_Selected(cri_C,""," selected")#>Any User</option>
						<option value="1"#FLForm_Selected(cri_C,"1"," selected")#>Preloaded</option>
						<option value="0"#FLForm_Selected(cri_C,"0"," selected")#>Self-Registered</option>
					</select>
					</td>
					<td> <span class="sub">Search First, Last,<br>Email Company</span><br><input type="text" name="cri_T" value="#HTMLEditFormat(cri_T)#" size="20"></td>
					</tr>
					<tr>
					<td colspan="4">
						<input type="hidden" name="cri_L" value="#cri_L#">
						<input type="hidden" name="cri_S" value="#cri_S#">
						<input type="submit" name="submit" value="Search">
					</td>
					</tr>
					</table>
				</form>
				</cfoutput>
				<br />
			</td>
		</tr>
	</table>
	<br />
	<!--- paging code --->
	<cfoutput>#FLPage_Paging(OnPage,SelectList.RecordCount,"cri_S=" & cri_S & "&cri_L=" & cri_L & "&cri_T=" & cri_T & "&cri_A=" & cri_A & "&cri_B=" & cri_B & "&cri_C=" & cri_C,15)#</cfoutput>
	<table width="100%" cellpadding="5" cellspacing="1" border="0">
	<!--- header row --->
	<tr class="contenthead">
	<td nowrap="nowrap">&nbsp;</td>
	<td width="100%" nowrap="nowrap"><span class="headertext">Contestant</span> <img src="../pics/contrls-asc.gif" width="7" height="6" alt="" ></td>
	<td nowrap="nowrap"><span class="headertext">Points</span>
	</td>
	<td nowrap="nowrap"><span class="headertext">Opt-in</span>
	</td>
	</tr>
	<!--- if no records --->
	<cfif SelectList.RecordCount EQ 0>
		<tr class="BGlight2">
			<td colspan="4" align="center" class="alert">
				<br />No records found.  Click "view all" to see all records.<br /><br />
			</td>
		</tr>
	<cfelse>
		<!--- display found records --->
		<cfoutput query="SelectList" startrow="#StartRow_SelectList#" maxrows="#MaxRows_SelectList#">
			<tr valign="top" class="<cfif NOT YesNoFormat(SelectList.is_optin)>inactivebg<cfelse>content<cfif CurrentRow MOD 2 EQ 1>2</cfif></cfif>">
				<td nowrap="nowrap"><a href="#CurrentPage#?pgfn=edit&id=#SelectList.ID#&cri_S=#cri_S#&cri_L=#cri_L#&cri_T=#cri_T#&cri_A=#cri_A#&cri_B=#cri_B#&cri_C=#cri_C#&OnPage=#OnPage#" class="actionlink">Edit</a>&nbsp;&nbsp;<a href="#CurrentPage#?delete=#ID#&cri_S=#cri_S#&cri_L=#cri_L#&cri_T=#cri_T#&OnPage=#OnPage#" onclick="return confirm('Are you sure you want to delete this?  There is NO UNDO.')" class="actionlink">X</a>&nbsp;&nbsp;</td>
				<td>#SelectList.fname# #SelectList.lname#<br>
				#SelectList.email#<br>
				#SelectList.company#</td>
				<td align="center">#SelectList.points#</td>
				<td align="center">#YesNoFormat(SelectList.is_optin)#</td>
			</tr>
		</cfoutput>
	</cfif>
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "edit"> 
	<!--- START pgfn ADD/EDIT --->
	<p class="pagetitle">ARI Game - Edit a Contestant</p>
	<p class="pageinstructions">Return to <a href="<cfoutput>#CurrentPage#?&cri_S=#cri_S#&cri_L=#cri_L#&cri_T=#cri_T#&cri_A=#cri_A#&cri_B=#cri_B#&cri_C=#cri_C#&OnPage=#OnPage#</cfoutput>" class="actionlink">Contestant List</a> without making changes.</p>
	<cfquery name="ToBeEdited" datasource="#application.DS#">
		SELECT ID,company,fname,lname,email,title,address1,address2,is_optin,
			address3,city,state,zip,country,phone,points,user_ID
		FROM #application.database#.ariGameContestants
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10">
	</cfquery>
	<cfset ID = ToBeEdited.ID>
	<cfset company = HTMLEditFormat(ToBeEdited.company)>
	<cfset fname = HTMLEditFormat(ToBeEdited.fname)>
	<cfset lname = HTMLEditFormat(ToBeEdited.lname)>
	<cfset email = HTMLEditFormat(ToBeEdited.email)>
	<cfset title = HTMLEditFormat(ToBeEdited.title)>
	<cfset address1 = HTMLEditFormat(ToBeEdited.address1)>
	<cfset address2 = HTMLEditFormat(ToBeEdited.address2)>
	<cfset address3 = HTMLEditFormat(ToBeEdited.address3)>
	<cfset city = HTMLEditFormat(ToBeEdited.city)>
	<cfset state = HTMLEditFormat(ToBeEdited.state)>
	<cfset zip = HTMLEditFormat(ToBeEdited.zip)>
	<cfset country = HTMLEditFormat(ToBeEdited.country)>
	<cfset phone = HTMLEditFormat(ToBeEdited.phone)>
	<cfset points = HTMLEditFormat(ToBeEdited.points)>
	<cfset user_ID = HTMLEditFormat(ToBeEdited.user_ID)>
	<cfset is_optin = ToBeEdited.is_optin>
	<cfoutput>
	<form name="form1" method="post" action="#CurrentPage#">
		<table width="100%" cellpadding="5" cellspacing="1" border="0">
			<tr class="contenthead">
				<td class="headertext" colspan="2" align="right">
					<span class="alert">*Required fields</span>
					<img src="../pics/shim.gif" width="1" height="15" alt="" OnLoad="document.form1.fname.focus();" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">User ID:</td>
				<td>#user_ID#</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Points:</td>
				<td>#points#</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Is Opted In?</td>
				<td>
					<input type="radio" name="is_optin" value="1"<cfif is_optin EQ 1> checked</cfif> /> Yes
					<input type="radio" name="is_optin" value="0"<cfif is_optin EQ 0> checked</cfif> /> No
				</td>	
			</tr>
			<tr valign="top" class="content">
				<td width="13%" align="right" nowrap="nowrap">First Name:</td>
				<td width="87%">
					<input type="text" name="fname" value="#fname#" size="35" maxlength="30" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Last Name:</td>
				<td>
					<input type="text" name="lname" value="#lname#" size="35" maxlength="30" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Company:</td>
				<td>
					<input type="text" name="company" value="#company#" size="35" maxlength="30" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Title:</td>
				<td><input type="text" name="title" value="#title#" size="35" maxlength="30" /></td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Email Address<span class="alert">*</span>:</td>
				<td>
					<input type="text" name="email" value="#email#" size="35" maxlength="42" />
					<input type="hidden" name="email_cfformrequired" value="You must enter an email address." />
					<input type="hidden" name="email_cfformemail" value="Invalid email address. Please make sure the email address you entered is valid." />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Address:</td>
				<td>
					<input type="text" name="address1" value="#address1#" size="50" maxlength="64" />
					<img src="../pics/shim.gif" width="100%" height="5" alt="" />
					<input type="text" name="address2" value="#address2#" size="50" maxlength="64" /><br />
					<img src="../pics/shim.gif" width="100%" height="5" alt="" />
					<input type="text" name="address3" value="#address3#" size="50" maxlength="64" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">City:</td>
				<td>
					<input type="text" name="city" value="#city#" size="35" maxlength="30" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">State:</td>
				<td>
					<input type="text" name="state" value="#state#" size="35" maxlength="30" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Postal Code:</td>
				<td>
					<input type="text" name="zip" value="#zip#" size="15" maxlength="10" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Country:</td>
				<td>
					<input type="text" name="country" value="#country#" size="35" maxlength="30" />
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Telephone:</td>
				<td>
					<input type="text" name="phone" value="#phone#" size="25" maxlength="20" />
				</td>
			</tr>
			<tr class="content">
				<td>&nbsp;</td>
				<td>
					<input type="hidden" name="cri_S" value="#cri_S#">
					<input type="hidden" name="cri_L" value="#cri_L#">
					<input type="hidden" name="cri_T" value="#cri_T#">
					<input type="hidden" name="cri_A" value="#cri_A#">
					<input type="hidden" name="cri_B" value="#cri_B#">
					<input type="hidden" name="cri_C" value="#cri_C#">
					<input type="hidden" name="OnPage" value="#OnPage#">
					<input type="hidden" name="pgfn" value="#pgfn#">
					<input type="hidden" name="ID" value="#ID#">
					<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;
					<input type="submit" name="submit" value="Save" >
				</td>
			</tr>
		</table>
	</form>
	</cfoutput>
	<!--- END pgfn ADD/EDIT --->
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->