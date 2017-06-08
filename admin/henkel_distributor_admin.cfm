<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000100,true)>

<!--- param all variables used on this page --->
<cfparam name="x" default="">
<cfparam name="where_string" default="">

<cfparam name="ID" default=0>
<cfparam name="idh" default="">
<cfparam name="company_name" default="">
<cfparam name="address1" default="">
<cfparam name="city" default="">
<cfparam name="state" default="">
<cfparam name="zip" default="">
<cfparam name="phone" default="">
<cfparam name="fax" default="">
<cfparam name="cmusr1" default="">
<cfparam name="program_ID" default=0>
<cfparam name="is_international" default=0>

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="orderby" default="zipcode">
<cfparam name="sortdir" default="ASC">

<cfparam name="alert_msg" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit') AND form.Submit IS NOT "">
	
	<!--- update --->
	<cfif form.pgfn EQ "edit">
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.henkel_distributor SET
				idh = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.idh#" maxlength="16">,
				company_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.company_name#" maxlength="128">,
				address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address1#" maxlength="32">,
				city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.city#" maxlength="32">,
				state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.state#" maxlength="2">,
				zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zip#" maxlength="10">,
				phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.phone#" maxlength="14">,
				fax = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fax#" maxlength="14">,
				cmusr1 = <cfqueryparam cfsqltype="cf_sql_char" value="#form.cmusr1#" maxlength="2">,
				is_international = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.is_international#" maxlength="1">
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelseif form.pgfn EQ "add">
		<cflock name="henkel_distributorLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#">
					INSERT INTO #application.database#.henkel_distributor
						(idh, company_name, address1, city, state, zip, phone, fax, cmusr1, program_ID, is_international)
					VALUES
						(<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.idh#" maxlength="16">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.company_name#" maxlength="128">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address1#" maxlength="32">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.city#" maxlength="32">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.state#" maxlength="2">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zip#" maxlength="10">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.phone#" maxlength="14">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fax#" maxlength="14">,
						<cfqueryparam cfsqltype="CF_SQL_CHAR" value="#form.cmusr1#" maxlength="2">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="cf_sql_tinyint" value="#form.is_international#" maxlength="1">)
				</cfquery>
				<cfquery name="getID" datasource="#application.DS#">
					SELECT Max(ID) As MaxID FROM #application.database#.henkel_distributor
				</cfquery>
			</cftransaction>  
		</cflock>
		<cfset ID = getID.MaxID>
	</cfif>
	<cfset alert_msg = "The information was saved.">
	<cfset pgfn = "list">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = 'henkel_distributor_admin'>
<cfinclude template="includes/header.cfm">

<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>

<cfparam  name="pgfn" default="list">

<cfif pgfn EQ "list">
	<!--- START pgfn LIST --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID, idh, company_name, address1, city, state, zip, phone, fax, cmusr1, program_ID, is_international
		FROM #application.database#.henkel_distributor
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">
		ORDER BY
		<cfswitch expression="#orderby#">
		<cfcase value="zipcode">
			zip #sortdir#, city #sortdir#, state #sortdir#, company_name #sortdir#, idh #sortdir#
		</cfcase>
		<cfcase value="location">
			city #sortdir#, state #sortdir#, zip #sortdir#, company_name #sortdir#, idh #sortdir#
		</cfcase>
		<cfcase value="company">
			company_name #sortdir#, city #sortdir#, state #sortdir#, zip #sortdir#, idh #sortdir#
		</cfcase>
		<cfcase value="idh">
			idh #sortdir#, company_name #sortdir#, city #sortdir#, state #sortdir#, zip #sortdir#
		</cfcase>
		<cfdefaultcase>
			lname #sortdir#, fname #sortdir#
		</cfdefaultcase>
		</cfswitch>
	</cfquery>
	<cfoutput>
	<span class="pagetitle">Henkel #request.selected_henkel_program.distributor_label# List</span>
	<br /><br />
	</cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<!--- header row --->
	<cfoutput>
	<tr class="contenthead">
	<td align="center"><a href="#CurrentPage#?pgfn=add&orderby=#orderby#&sortdir=#sortdir#">Add</a></td>
	<td class="headertext" style="white-space:nowrap">
		<a href="#CurrentPage#?orderby=idh&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'idh'>ASC<cfelse>DESC</cfif>">
			IDH <cfif orderby EQ "idh"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
		</a>
	</td>
	<td class="headertext" style="white-space:nowrap">
		<a href="#CurrentPage#?orderby=company&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'company'>ASC<cfelse>DESC</cfif>">
			Company <cfif orderby EQ "company"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
		</a>
	</td>
	<td class="headertext" style="white-space:nowrap">
		<a href="#CurrentPage#?orderby=location&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'location'>ASC<cfelse>DESC</cfif>">
			Location <cfif orderby EQ "location"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
		</a>
	</td>
	<td class="headertext" style="white-space:nowrap">
		<a href="#CurrentPage#?orderby=zipcode&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'zipcode'>ASC<cfelse>DESC</cfif>">
			Zipcode <cfif orderby EQ "zipcode"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
		</a>
	</td>
	</tr>
	</cfoutput>

	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
		<td colspan="100%" align="center"><span class="alert"><br>No records found.  Click "Add" to create one.<br><br></span></td>
		</tr>
	<cfelse>
		<!--- display found records --->
		<cfoutput query="SelectList">
			<cfset show_delete = false>
			<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content'),de('content2'))#">
			<td><a href="#CurrentPage#?pgfn=edit&ID=#ID#&orderby=#orderby#&sortdir=#sortdir#">Edit</a><cfif FLGen_HasAdminAccess(1000000100) AND show_delete>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?delete=#ID#&orderby=#orderby#&sortdir=#sortdir#" onclick="return confirm('Are you sure you want to delete this region?  There is NO UNDO.')">Delete</a></cfif></td>
			<td>#htmleditformat(idh)#</td>
			<td>#htmleditformat(company_name)#</td>
			<td>#htmleditformat(city)#, #htmleditformat(state)#</td>
			<td>#htmleditformat(zip)#</td>
			</tr>
		</cfoutput>
	</cfif>
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit">
	<!--- START pgfn ADD/EDIT --->
	<cfoutput>
	<span class="pagetitle"><cfif pgfn EQ "add" OR pgfn EQ "copy">Add<cfelse>Edit</cfif> #request.selected_henkel_program.distributor_label#</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="#CurrentPage#?orderby=#orderby#&sortdir=#sortdir#">Henkel #request.selected_henkel_program.distributor_label# List</a> without making changes.</span>
	<br /><br />
	</cfoutput>

	<cfif pgfn EQ "edit">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT ID, idh, company_name, address1, city, state, zip, phone, fax, cmusr1, program_ID, is_international
			FROM #application.database#.henkel_distributor
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
		<cfset idh = htmleditformat(ToBeEdited.idh)>
		<cfset company_name = htmleditformat(ToBeEdited.company_name)>
		<cfset address1 = htmleditformat(ToBeEdited.address1)>
		<cfset city = htmleditformat(ToBeEdited.city)>
		<cfset state = htmleditformat(ToBeEdited.state)>
		<cfset zip = htmleditformat(ToBeEdited.zip)>
		<cfset phone = htmleditformat(ToBeEdited.phone)>
		<cfset fax = htmleditformat(ToBeEdited.fax)>
		<cfset cmusr1 = htmleditformat(ToBeEdited.cmusr1)>
		<cfset program_ID = htmleditformat(ToBeEdited.program_ID)>
		<cfset is_international = htmleditformat(ToBeEdited.is_international)>
	</cfif>
	<cfoutput>

	<form method="post" action="#CurrentPage#">
		<input type="hidden" name="orderby" value="#orderby#">
		<input type="hidden" name="sortdir" value="#sortdir#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<tr class="contenthead">
		<td colspan="2" class="headertext"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> #request.selected_henkel_program.distributor_label#</td>
	</tr>
	<tr class="content"><td align="right">IDH: </td><td><input type="text" name="idh" value="#idh#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Company Name: </td><td><input type="text" name="company_name" value="#company_name#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Address: </td><td><input type="text" name="address1" value="#address1#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">City: </td><td><input type="text" name="city" value="#city#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">State: </td><td><input type="text" name="state" value="#state#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Zip: </td><td><input type="text" name="zip" value="#zip#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Phone: </td><td><input type="text" name="phone" value="#phone#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Fax: </td><td><input type="text" name="fax" value="#fax#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">CMUSRL: </td><td><input type="text" name="cmusr1" value="#cmusr1#" maxlength="75" size="60"></td></tr>
	<tr class="content">
		<td align="right">International: </td>
		<td>
			<input name="is_international" type="radio" value="1"<cfif is_international IS 1> checked</cfif> /> Yes
			<input name="is_international" type="radio" value="0"<cfif is_international IS 0> checked</cfif> /> No
		</td>
	</tr>
	<tr class="content">
		<td colspan="2" align="center">
		<input type="hidden" name="ID" value="#ID#">
		<input type="hidden" name="pgfn" value="#pgfn#">
		<input type="submit" name="submit" value="  Save Changes  " >
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