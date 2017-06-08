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
<cfparam name="User_ID" default="">
<cfparam name="company" default="">
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="email" default="">
<cfparam name="title" default="">
<cfparam name="address1" default="">
<cfparam name="address2" default="">
<cfparam name="address3" default="">
<cfparam name="city" default="">
<cfparam name="state" default="">
<cfparam name="zip" default="">
<cfparam name="country" default="">
<cfparam name="phone" default="">
<cfparam name="department" default="">
<cfparam name="gender" default="">
<cfparam name="size" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit') AND IsDefined('form.pgfn') AND form.pgfn EQ "edit">
	<cfquery name="UpdateQuery" datasource="#application.DS#">
		UPDATE #application.database#.ari60	SET
			user_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user_ID#" maxlength="16">,
			company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#company#" maxlength="30">,
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
			department = <cfqueryparam cfsqltype="cf_sql_varchar" value="#department#" maxlength="32">,
			gender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#gender#" maxlength="1">,
			size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#size#" maxlength="16">
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
	</cfquery>
	<cfset alert_msg = "The changes were saved.">
	<cfset pgfn = "list">

<cfelseif IsDefined('form.Submit') AND IsDefined('form.pgfn') AND form.pgfn EQ "add">
	<cfquery name="AddQuery" datasource="#application.DS#">
		INSERT INTO #application.database#.ari60
			(user_ID,company,fname,lname,email,title,address1,address2,address3,city,state,zip,country,phone,department,gender,size)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#user_ID#" maxlength="16">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#company#" maxlength="30">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#fname#" maxlength="30">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#lname#" maxlength="30">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#email#" maxlength="42">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#title#" maxlength="30">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#address1#" maxlength="64">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#address2#" maxlength="64">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#address3#" maxlength="64">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#city#" maxlength="30">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#state#" maxlength="30">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#zip#" maxlength="10">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#country#" maxlength="30">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#phone#" maxlength="20">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#department#" maxlength="32">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#gender#" maxlength="1">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#size#" maxlength="16">
		)
	</cfquery>
	<cfset alert_msg = "The user were added.">
	<cfset pgfn = "list">

<cfelseif delete NEQ ''>
	<!--- delete --->
	<cfquery name="ToBeDeleted" datasource="#application.DS#">
		SELECT CONCAT(fname, ' ', lname) AS this_one_deleted
		FROM #application.database#.ari60
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#delete#">
	</cfquery>
	<cfset this_one_deleted = HTMLEditFormat(ToBeDeleted.this_one_deleted)>
	<cfquery name="DeleteThis" datasource="#application.DS#">
		DELETE FROM #application.database#.ari60
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#delete#">
	</cfquery>
	<cfset pgfn = "list">
	<cfset alert_msg = "The ARI 60 User [ #this_one_deleted# ] has been deleted.">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "ari60ManageUsers">
<cfinclude template="includes/header.cfm">

<script src="../includes/paging.js"></script>
<script src="../includes/showhide.js"></script>

<cfif pgfn EQ "list">
	<!--- START pgfn LIST --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID, company,fname,lname,email,user_ID,department,gender,size
		FROM #application.database#.ari60
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
		<cfif cri_C EQ "0">
			AND created_datetime < 2006-08-18
		<cfelseif cri_C EQ "1">
			AND created_datetime > 2006-08-18
		</cfif>
		ORDER BY <cfqueryparam cfsqltype="cf_sql_varchar" value="#cri_S#"> ASC
	</cfquery>
	<cfoutput>
	<span class="pagetitle">ARI 60 - User List</span>
	<br /><br />
	<!--- search box --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	<tr class="contenthead">
	<td class="headertext">Search Criteria</td>
	<td align="right"><a href="#CurrentPage#" class="ltr">VIEW ALL</a></td>
	</tr>
	<tr valign="top">
	<td class="content2" colspan="2" align="center" valign="top">
		<form action="#CurrentPage#" method="post">
		<table cellpadding="5">
		<tr>
		<td colspan="4" align="center"> <span class="sub">Search First, Last,<br>Email Company</span><br><input type="text" name="cri_T" value="#HTMLEditFormat(cri_T)#" size="20"></td>
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
		<br />
	</td>
	</tr>
	</table>
	<br />
	<!--- paging code --->
	#FLPage_Paging(OnPage,SelectList.RecordCount,"cri_S=" & cri_S & "&cri_L=" & cri_L & "&cri_T=" & cri_T & "&cri_A=" & cri_A & "&cri_B=" & cri_B & "&cri_C=" & cri_C,15)#
	</cfoutput>
	<table width="100%" cellpadding="5" cellspacing="1" border="0">
		<cfoutput>
		<!--- header row --->
		<tr class="contenthead">
		<td nowrap="nowrap"><a href="#CurrentPage#?pgfn=add&cri_S=#cri_S#&cri_L=#cri_L#&cri_T=#cri_T#&cri_A=#cri_A#&cri_B=#cri_B#&cri_C=#cri_C#&OnPage=#OnPage#" class="actionlink">Add</a>&nbsp;&nbsp;</td>
		<td width="100%" nowrap="nowrap"><span class="headertext">User</span> <img src="../pics/contrls-asc.gif" width="7" height="6" alt="" ></td>
		<td nowrap="nowrap"><span class="headertext">Department</span>
		<td nowrap="nowrap"><span class="headertext">Gender</span>
		</td>
		<td nowrap="nowrap"><span class="headertext">Size</span>
		</td>
		</tr>
		</cfoutput>
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
				<tr valign="top" class="content<cfif CurrentRow MOD 2 EQ 1>2</cfif>">
					<td nowrap="nowrap"><a href="#CurrentPage#?pgfn=edit&id=#SelectList.ID#&cri_S=#cri_S#&cri_L=#cri_L#&cri_T=#cri_T#&cri_A=#cri_A#&cri_B=#cri_B#&cri_C=#cri_C#&OnPage=#OnPage#" class="actionlink">Edit</a>&nbsp;&nbsp;<a href="#CurrentPage#?delete=#ID#&cri_S=#cri_S#&cri_L=#cri_L#&cri_T=#cri_T#&OnPage=#OnPage#" onclick="return confirm('Are you sure you want to delete this?  There is NO UNDO.')" class="actionlink">X</a>&nbsp;&nbsp;</td>
					<td>#SelectList.fname# #SelectList.lname#<br>
					#SelectList.email#<br>
					#SelectList.company#</td>
					<td align="center">#SelectList.department#</td>
					<td align="center">#SelectList.gender#</td>
					<td align="center">#SelectList.size#</td>
				</tr>
			</cfoutput>
		</cfif>
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit"> 
	<!--- START pgfn ADD/EDIT --->
	<p class="pagetitle">ARI 60 - Edit a User</p>
	<p class="pageinstructions">Return to <a href="<cfoutput>#CurrentPage#?&cri_S=#cri_S#&cri_L=#cri_L#&cri_T=#cri_T#&cri_A=#cri_A#&cri_B=#cri_B#&cri_C=#cri_C#&OnPage=#OnPage#</cfoutput>" class="actionlink">User List</a> without making changes.</p>
	<cfif pgfn IS "edit">
	<cfquery name="ToBeEdited" datasource="#application.DS#">
		SELECT ID,user_ID,company,fname,lname,email,title,address1,address2,
			address3,city,state,zip,country,phone,gender,size,department
		FROM #application.database#.ari60
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10">
	</cfquery>
	<cfset ID = ToBeEdited.ID>
	<cfset user_ID = HTMLEditFormat(ToBeEdited.user_ID)>
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
	<cfset gender = HTMLEditFormat(ToBeEdited.gender)>
	<cfset size = HTMLEditFormat(ToBeEdited.size)>
	<cfset department = HTMLEditFormat(ToBeEdited.department)>
	</cfif>
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
				<td>
				<cfif pgfn IS "add">
					<input type="text" name="user_ID" value="#user_ID#" size="16" maxlength="16" />
				<cfelse>
					<input type="hidden" name="user_ID" value="#user_ID#">#user_ID#
				</cfif>
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap">Gender?</td>
				<td>
					<input type="radio" name="gender" value=""<cfif gender EQ ""> checked</cfif> /> None
					<input type="radio" name="gender" value="M"<cfif gender EQ "M"> checked</cfif> /> Mens
					<input type="radio" name="gender" value="W"<cfif gender EQ "W"> checked</cfif> /> Womens
				</td>
			</tr>
			<tr valign="top" class="content">
				<td align="right" nowrap="nowrap" valign="top">Size?</td>
				<td>
					<input type="radio" name="size" value=""<cfif size EQ ""> checked</cfif> /> None<br />
					<input type="radio" name="size" value="XSmall"<cfif size EQ "XSmall"> checked</cfif> /> X-Small(WOMENS ONLY)<br />
					<input type="radio" name="size" value="Small"<cfif size EQ "Small"> checked</cfif> /> Small<br />
					<input type="radio" name="size" value="Medium"<cfif size EQ "Medium"> checked</cfif> /> Medium<br />
					<input type="radio" name="size" value="Large"<cfif size EQ "Large"> checked</cfif> /> Large<br />
					<input type="radio" name="size" value="XLarge"<cfif size EQ "XLarge"> checked</cfif> /> X-Large<br />
					<input type="radio" name="size" value="2X Large"<cfif size EQ "2 XLarge"> checked</cfif> /> 2X-Large<br />
					<input type="radio" name="size" value="3X Large"<cfif size EQ "3 XLarge"> checked</cfif> /> 3X-Large (MENS ONLY)<br />
					<input type="radio" name="size" value="4X Large"<cfif size EQ "4 XLarge"> checked</cfif> /> 4X-Large (MENS ONLY)
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
				<td align="right" nowrap="nowrap">Department:</td>
				<td>
					<input type="text" name="department" value="#department#" size="16" maxlength="32" />
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