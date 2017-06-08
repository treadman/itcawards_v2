<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000020,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="where_string" default="">
<cfparam name="ID" default="">

<!--- param search criteria xS=ColumnSort xT=SearchString xL=Letter --->
<cfparam name="xS" default="company">
<cfparam name="xT" default="">
<cfparam name="xL" default="">
<cfparam name="show_inactive" default="0">

<!--- param a/e form fields --->
<cfparam name="ID" default="">	
<cfparam name="program_ID" default="">
<cfparam name="email" default="">
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="phone" default="">
<cfparam name="company" default="">
<cfparam name="address1" default="">
<cfparam name="address2" default="">
<cfparam name="city" default="">
<cfparam name="state" default="">
<cfparam name="zip" default="">
<cfparam name="country" default="">
<cfparam name="is_active" default="">
<cfparam name="delete" default="">

<cfif NOT isNumeric(program_ID) OR program_ID LTE 0>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('Submit')>
	<!--- update --->
	<cfif pgfn EQ "edit">
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.forwarding_address
			SET	company = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#company#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(company)))#">,
				fname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(fname)))#">,
				lname = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(lname)))#">,
				address1 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#address1#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(address1)))#">,
				address2 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#address2#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(address2)))#">,
				city = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#city #" maxlength="30" null="#YesNoFormat(NOT Len(Trim(city )))#">,
				state = <cfqueryparam cfsqltype="CF_SQL_CHAR" value="#state#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(state)))#">,
				zip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#zip#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(zip)))#">,
				country = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#country#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(country)))#">,
				phone = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#phone#" maxlength="35" null="#YesNoFormat(NOT Len(Trim(phone)))#">,
				email = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#email#" maxlength="128" null="#YesNoFormat(NOT Len(Trim(email)))#">,
				is_active = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_active#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(is_active)))#">
				#FLGen_UpdateModConcatSQL()#
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelseif pgfn EQ "add" OR pgfn EQ "copy">
		<cflock name="forwardingLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#" result="stResult">
					INSERT INTO #application.database#.forwarding_address
						(created_user_ID, created_datetime, program_ID, company, address1, address2, city, state, zip, country, phone, email, fname, lname, is_active)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#', 
						<cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#company#" maxlength="60">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#address1#" maxlength="38" null="#YesNoFormat(NOT Len(Trim(address1)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#address2#" maxlength="38" null="#YesNoFormat(NOT Len(Trim(address2)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#city #" maxlength="38" null="#YesNoFormat(NOT Len(Trim(city )))#">,
						<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#state#" maxlength="2" null="#YesNoFormat(NOT Len(Trim(state)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#zip#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(zip)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#country#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(country)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#phone#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(phone)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#email#" maxlength="648" null="#YesNoFormat(NOT Len(Trim(email)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(fname)))#">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(lname)))#">, 
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#is_active#" maxlength="1" null="#YesNoFormat(NOT Len(Trim(is_active)))#">
					) 
				</cfquery>
				<cfset ID = stResult.GeneratedKey>
			</cftransaction>  
		</cflock>
	</cfif>
	<cfset alert_msg = "Changes saved.">
	<cfset pgfn = "edit">
<cfelseif delete NEQ '' AND FLGen_HasAdminAccess(1000000053)>
	<cfquery name="DeleteForward" datasource="#application.DS#">
		DELETE FROM #application.product_database#.forwarding_address
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#" maxlength="10">
	</cfquery>			
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

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

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "forwarding_address">
<cfinclude template="includes/header.cfm">

<cfparam  name="pgfn" default="list">

<!--- START pgfn LIST --->
<cfif pgfn EQ "list">

	<!--- Set the WHERE clause --->
	<!--- First check if a search string passed --->
	<cfif LEN(xT) GT 0>
		<cfset xL = "">
	</cfif>
	<!--- run query --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT f.ID, f.company, COUNT(u.ID) as numUsers
		FROM #application.database#.forwarding_address f
		LEFT JOIN #application.database#.program_user u ON f.ID = u.forwarding_ID
		WHERE f.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
		<cfif LEN(xT) GT 0 OR LEN(xL) GT 0>
			<cfif LEN(xT) GT 0>
				AND f.company LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(xT)#%">
			<cfelseif LEN(xL) GT 0>
				AND f.company LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#xL#%">
			</cfif>
		</cfif>
		<cfif NOT show_inactive>
			AND f.is_active = 1
		</cfif>
		GROUP BY f.ID
		ORDER BY f.company ASC
	</cfquery>
	
	<!--- set the start/end/max display row numbers --->
	<cfparam name="OnPage" default="1">
	<cfset MaxRows_SelectList="50">
	<cfset StartRow_SelectList=Min((OnPage-1)*MaxRows_SelectList+1,Max(SelectList.RecordCount,1))>
	<cfset EndRow_SelectList=Min(StartRow_SelectList+MaxRows_SelectList-1,SelectList.RecordCount)>
	<cfset TotalPages_SelectList=Ceiling(SelectList.RecordCount/MaxRows_SelectList)>

	<cfquery name="SelectProgramInfo" datasource="#application.DS#">
		SELECT p.company_name AS company_name, p.program_name AS program_name, p.default_category AS default_category, pvp.productvalue_master_ID as default_pvp
		FROM #application.database#.program p
		LEFT JOIN #application.product_database#.productvalue_program pvp ON p.default_category = pvp.ID
		WHERE p.ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
	</cfquery>
	
	<span class="pagetitle">Forwarder Addresses for <cfoutput>#SelectProgramInfo.company_name# [#SelectProgramInfo.program_name#]</cfoutput>  <a href="pickprogram.cfm?n=forwarding_address">select another program</a></span>
	<br /><br />

	<!--- search box --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
	
	<tr class="contenthead">
	<td><span class="headertext">Search Criteria</span></td>
	<td align="right"><a href="<cfoutput>#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#</cfoutput>" class="headertext">view all</a></td>
	</tr>
	
	<tr>
	<td class="content" colspan="2" align="center">
		<cfoutput>
		<form name="SearchForm" action="#CurrentPage#" method="post">
			<input type="hidden" name="xL" value="#xL#">
			<input type="hidden" name="xS" value="#xS#">
			<input type="hidden" name="program_ID" value="#program_ID#">
			<input type="text" name="xT" value="#HTMLEditFormat(xT)#" size="20">
			<input type="submit" name="search" value="search">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="show_inactive" value="1" <cfif show_inactive eq 1>checked</cfif> onclick="javascript:SearchForm.submit();"> Include inactive addresses.
		</form>
		<br>		
		<cfif LEN(xL) IS 0><span class="ltrON">ALL</span><cfelse><a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&xL=" class="ltr">ALL</a></cfif><span class="ltrPIPE">&nbsp;&nbsp;</span><cfloop index = "LoopCount" from = "0" to = "9"><cfoutput><cfif xL IS LoopCount><span class="ltrON">#LoopCount#</span><cfelse><a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&xL=#LoopCount#" class="ltr">#LoopCount#</a></cfif></cfoutput><span class="ltrPIPE">&nbsp;&nbsp;</span></cfloop><cfloop index = "LoopCount" from = "1" to = "26"><cfoutput><cfif xL IS CHR(LoopCount + 64)><span class="ltrON">#CHR(LoopCount + 64)#</span><cfelse><a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&xL=#CHR(LoopCount + 64)#" class="ltr">#CHR(LoopCount + 64)#</a></cfif></cfoutput><cfif LoopCount NEQ 26><span class="ltrPIPE">&nbsp;&nbsp;</span></cfif></cfloop>
		</cfoutput>
	</td>
	</tr>
	
	</table>
	
	<br />
	
	<cfif SelectList.RecordCount GT 0>
		<form name="pageform">
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
		<td>
			<cfif OnPage GT 1>
				<a href="<cfoutput>#CurrentPage#?show_inactive=#show_inactive#&program_ID=#program_ID#&OnPage=1&xL=#xL#&xT=#xT#</cfoutput>" class="pagingcontrols">&laquo;</a>&nbsp;&nbsp;&nbsp;<a href="<cfoutput>#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&OnPage=#Max(DecrementValue(OnPage),1)#&xL=#xL#&xT=#xT#</cfoutput>" class="pagingcontrols">&lsaquo;</a>
			<cfelse>
				<span class="Xpagingcontrols">&laquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&lsaquo;</span>
			</cfif>
		</td>
		<td align="center" class="sub">[ page 	
			<cfoutput>
			<select name="pageselect" onChange="openURL()"> 
				<cfloop from="1" to="#TotalPages_SelectList#" index="this_i">
					<option value="#CurrentPage#?program_ID=#program_ID#&OnPage=#this_i#&xL=#xL#&xT=#xT#"<cfif OnPage EQ this_i> selected</cfif>>#this_i#</option> 
				</cfloop>
			</select>
			of #TotalPages_SelectList# ]&nbsp;&nbsp;&nbsp;[ records #StartRow_SelectList# - #EndRow_SelectList# of #SelectList.RecordCount# ]
			</cfoutput>
		</td>
		<td align="right">
			<cfif OnPage LT TotalPages_SelectList>
				<a href="<cfoutput>#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&OnPage=#Min(IncrementValue(OnPage),TotalPages_SelectList)#&xL=#xL#&xT=#xT#</cfoutput>" class="pagingcontrols">&rsaquo;</a>&nbsp;&nbsp;&nbsp;<a href="<cfoutput>#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&OnPage=#TotalPages_SelectList#&xL=#xL#&xT=#xT#</cfoutput>" class="pagingcontrols">&raquo;</a>
			<cfelse>
				<span class="Xpagingcontrols">&rsaquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&raquo;</span>
			</cfif>
		</td>
		</tr>
		</table>
		</form>
	</cfif>
	
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<!--- header row --->
	<cfoutput>	
		<tr class="contenthead">
		<td align="center"><a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&pgfn=add&xL=#xL#&xT=#xT#&OnPage=#OnPage#">Add</a></td>
		<td>
			<span class="headertext">Company</span> <img src="../pics/contrls-asc.gif" width="7" height="6">
		</td>
		</tr>
	</cfoutput>

	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
		<td colspan="3" align="center"><span class="alert"><br>No records found.  Click "view all" to see all records.<br><br></span></td>
		</tr>
	</cfif>

	<!--- display found records --->
	<cfoutput query="SelectList" startrow="#StartRow_SelectList#" maxrows="#MaxRows_SelectList#">
		<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
		<td><a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&pgfn=edit&id=#ID#&xL=#xL#&xT=#xT#&OnPage=#OnPage#">Edit</a>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&pgfn=copy&id=#ID#&xL=#xL#&xT=#xT#&OnPage=#OnPage#">Copy</a><cfif FLGen_HasAdminAccess(1000000053) and SelectList.numUsers EQ 0>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&delete=#ID#&xL=#xL#&xT=#xT#&OnPage=#OnPage#" onclick="return confirm('Are you sure you want to delete this address?  There is NO UNDO.')">Delete</a></cfif></td>
		<td valign="top" width="100%">#htmleditformat(company)#</td>
		</tr>
	</cfoutput>

	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit" OR pgfn EQ "copy">
	<!--- START pgfn ADD/EDIT --->
	<cfoutput>
	<span class="pagetitle"><cfif pgfn EQ "add" OR pgfn EQ "copy">Add<cfelse>Edit</cfif> a Forwarder Address</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="#CurrentPage#?program_ID=#program_ID#&show_inactive=#show_inactive#&xL=#xL#&xT=#xT#&OnPage=#OnPage#">Forwarder Address List</a> without making changes.</span>
	<br /><br />
	</cfoutput>

	<cfif pgfn eq 'copy'>
		<span class="pageinstructions"><span class="alert">You are creating a new forwarder address.</span> The form below is filled with</span>
		<br />
		<span class="pageinstructions">the information from the address you selected to copy.</span>
		<br /><br />
	</cfif>
	<cfif pgfn EQ "edit" OR pgfn EQ "copy">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT ID, email, fname, lname, phone, company, address1, address2, city, state, zip, country, is_active
			FROM #application.database#.forwarding_address
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
			AND program_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
		</cfquery>
		<cfset ID = ToBeEdited.ID>
		<cfset company = htmleditformat(ToBeEdited.company)>
		<cfset fname = htmleditformat(ToBeEdited.fname)>
		<cfset lname = htmleditformat(ToBeEdited.lname)>
		<cfset address1 = htmleditformat(ToBeEdited.address1)>
		<cfset address2 = htmleditformat(ToBeEdited.address2)>
		<cfset city = htmleditformat(ToBeEdited.city)>
		<cfset state = htmleditformat(ToBeEdited.state)>
		<cfset zip = htmleditformat(ToBeEdited.zip)>
		<cfset phone = htmleditformat(ToBeEdited.phone)>
		<cfset country = htmleditformat(ToBeEdited.country)>
		<cfset email = htmleditformat(ToBeEdited.email)>
		<cfset is_active = htmleditformat(ToBeEdited.is_active)>
	</cfif>

	<form method="post" action="#CurrentPage#">
	<cfoutput>

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><cfif pgfn EQ "add" OR pgfn EQ "copy">Add<cfelse>Edit</cfif> a Forwarder Address</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Company Name: </td>
	<td valign="top"><input type="text" name="company" value="#company#" maxlength="64" size="40"></td>
	</tr>
	
	<tr class="content">
	<td align="right">First Name: </td>
	<td><input type="text" name="fname" value="#fname#" maxlength="30" size="40"></td>
	</tr>

	<tr class="content">
	<td align="right">Last Name: </td>
	<td><input type="text" name="lname" value="#lname#" maxlength="30" size="40"></td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Address Line 1: </td>
	<td valign="top"><input type="text" name="address1" value="#address1#" maxlength="64" size="40"></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Address Line 2: </td>
	<td valign="top"><input type="text" name="address2" value="#address2#" maxlength="64" size="40"></td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">City: </td>
	<td valign="top"><input type="text" name="city" value="#city#" maxlength="30" size="40"></td>
	</tr>
	<tr class="content">
	<td align="right" valign="top">State: </td>
	<td valign="top"><cfoutput>#FLGen_SelectState("state",state)#</cfoutput></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Zip: </td>
	<td valign="top"><input type="text" name="zip" value="#zip#" maxlength="32" size="10"></td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Country: </td>
	<td valign="top"><input type="text" name="country" value="#country#" maxlength="32" size="10"></td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Phone: </td>
	<td valign="top"><input type="text" name="phone" value="#phone#" maxlength="35" size="40"></td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Email: </td>
	<td valign="top"><input type="text" name="email" value="#email#" maxlength="128" size="40"></td>
	</tr>

	<tr class="content">
	<td align="right">Active: </td>
	<td>
		<select name="is_active">
			<option value="1"<cfif is_active EQ 1> selected</cfif>>yes</option>
			<option value="0"<cfif is_active EQ 0> selected</cfif>>no</option>
		</select>
	</td>
	</tr>
		
	<tr class="content">
	<td colspan="2" align="center">
	
	<input type="hidden" name="pgfn" value="#pgfn#">
	<input type="hidden" name="xL" value="#xL#">
	<input type="hidden" name="xT" value="#xT#">
	<input type="hidden" name="OnPage" value="#OnPage#">
	<input type="hidden" name="program_ID" value="#program_ID#">
	<input type="hidden" name="show_inactive" value="#show_inactive#">

	<input type="hidden" name="ID" value="#ID#">
	<input type="hidden" name="company_required" value="You must enter a company name.">
		
	<input type="submit" name="submit" value="  Save Changes  " >
	</td>
	</tr>
	</table>
	</cfoutput>
	</form>

</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->