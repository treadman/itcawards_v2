<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->

<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000101,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<cfparam name="x" default="">
<cfparam name="where_string" default="">

<cfparam name="ID" default=0>
<cfparam name="fname" default="">
<cfparam name="lname" default="">
<cfparam name="address1" default="">
<cfparam name="address2" default="">
<cfparam name="city" default="">
<cfparam name="state" default="">
<cfparam name="zip" default="">
<cfparam name="country" default="">
<cfparam name="sub_group" default="">
<cfparam name="region" default="">
<cfparam name="division" default="">
<cfparam name="grp" default="">
<cfparam name="ty" default="">
<cfparam name="sap_ty" default="">
<cfparam name="cost_center" default="">
<cfparam name="regional_manager" default="">
<cfparam name="email" default="">
<cfparam name="program_ID" default="">

<cfparam name="orderby" default="name">
<cfparam name="sortdir" default="ASC">

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="alert_msg" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	
	<!--- update --->
	<cfif form.pgfn EQ "edit">
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.henkel_territory	SET
				fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fname#" maxlength="30">,
				lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lname#" maxlength="30">,
				address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address1#" maxlength="64">,
				address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address2#" maxlength="64">,
				city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.city#" maxlength="30">,
				state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.state#" maxlength="2">,
				zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zip#" maxlength="10">,
				country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.country#" maxlength="32">,
				sub_group = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.sub_group#" maxlength="32">,
				region = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.region#" maxlength="4">,
				division = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.division#" maxlength="3">,
				grp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.grp#" maxlength="3">,
				ty = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ty#" maxlength="3">,
				sap_ty = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.sap_ty#" maxlength="10">,
				cost_center = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.cost_center#" maxlength="10">,
				regional_manager = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.regional_manager#" maxlength="30">,
				email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="128">
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelseif form.pgfn EQ "add">
		<cflock name="henkel_territoryLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#">
						INSERT INTO #application.database#.henkel_territory
							(fname, lname, address1, address2, city, state, zip, country, sub_group, region, division, grp,
							ty, sap_ty, cost_center, regional_manager, email, program_ID)
						VALUES
							(<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fname#" maxlength="30">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.lname#" maxlength="30">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address1#" maxlength="64">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.address2#" maxlength="64">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.city#" maxlength="30">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.state#" maxlength="2">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.zip#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.country#" maxlength="32">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.sub_group#" maxlength="32">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.region#" maxlength="4">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.division#" maxlength="3">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.grp#" maxlength="3">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ty#" maxlength="3">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.sap_ty#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.cost_center#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.regional_manager#" maxlength="30">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email#" maxlength="128">,
							<cfqueryparam cfsqltype="cf_sql_integer"value="#request.henkel_ID#" maxlength="10">)
				</cfquery>
				<cfquery name="getID" datasource="#application.DS#">
					SELECT Max(ID) As MaxID FROM #application.database#.henkel_territory
				</cfquery>
				<cfset ID = getID.MaxID>
			</cftransaction>  
		</cflock>
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

<cfset leftnavon = "henkel_territory_admin">
<cfinclude template="includes/header.cfm">
<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>

<cfparam  name="pgfn" default="list">

<!--- START pgfn LIST ---> <!--- o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0 o 0  --->
<cfif pgfn EQ "list">

	<!--- run query --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID, fname, lname, address1, address2, city, state, zip, country, sub_group, region, division, grp, ty, sap_ty, cost_center, regional_manager, email, program_ID
		FROM #application.database#.henkel_territory
		WHERE program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		ORDER BY
		<cfswitch expression="#orderby#">
		<cfcase value="name">
			lname #sortdir#, fname #sortdir#
		</cfcase>
		<cfcase value="email">
			email #sortdir#
		</cfcase>
		<cfcase value="location">
			city #sortdir#, state #sortdir#, lname #sortdir#, fname #sortdir#
		</cfcase>
		<cfcase value="region">
			sap_ty #sortdir#, city #sortdir#, state #sortdir#, lname #sortdir#, fname #sortdir#
		</cfcase>
		<cfdefaultcase>
			lname #sortdir#, fname #sortdir#
		</cfdefaultcase>
		</cfswitch>
	</cfquery>
	<span class="pagetitle">Henkel Territory List</span>
	<br /><br />

	<table cellpadding="5" cellspacing="1" border="0" width="100%">

		<!--- header row --->
		<cfoutput>	
		<tr class="contenthead">
		<td align="center"><a href="#CurrentPage#?pgfn=add&orderby=#orderby#&sortdir=#sortdir#">Add</a></td>
		<td class="headertext" style="white-space:nowrap">
			<a href="#CurrentPage#?orderby=name&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'name'>ASC<cfelse>DESC</cfif>">
				Henkel Rep <cfif orderby EQ "name"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
			</a>
		</td>
		<td class="headertext" style="white-space:nowrap">
			<a href="#CurrentPage#?orderby=email&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'email'>ASC<cfelse>DESC</cfif>">
				Email <cfif orderby EQ "email"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
			</a>
		</td>
		<td class="headertext" style="white-space:nowrap">
			<a href="#CurrentPage#?orderby=location&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'location'>ASC<cfelse>DESC</cfif>">
				Location <cfif orderby EQ "location"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
			</a>
		</td>
		<td class="headertext" style="white-space:nowrap">
			<a href="#CurrentPage#?orderby=region&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'region'>ASC<cfelse>DESC</cfif>">
				Region <cfif orderby EQ "region"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
			</a>
		</td>
		</tr>
		</cfoutput>
		<!--- if no records --->
		<cfif SelectList.RecordCount IS 0>
			<tr class="content2">
			<td colspan="100%" align="center" class="alert"><br>No records found.  Click "Add" to create a region.<br><br></td>
			</tr>
		<cfelse>
			<!--- display found records --->
			<cfoutput query="SelectList">
				<cfset show_delete = false>
				<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
				<td><a href="#CurrentPage#?pgfn=edit&ID=#ID#&orderby=#orderby#&sortdir=#sortdir#">Edit</a><cfif FLGen_HasAdminAccess(1000000101) AND show_delete>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?delete=#ID#&orderby=#orderby#&sortdir=#sortdir#" onclick="return confirm('Are you sure you want to delete this region?  There is NO UNDO.')">Delete</a></cfif></td>
				<td>#htmleditformat(lname)#, #htmleditformat(fname)#</td>
				<td>#htmleditformat(email)#</td>
				<td>#htmleditformat(city)#, #htmleditformat(state)#</td>
				<td>#htmleditformat(sap_ty)#</td>
				</tr>
			</cfoutput>
		</cfif>
	</table>
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "add" OR pgfn EQ "edit">
	<!--- START pgfn ADD/EDIT --->
	<cfoutput>
	<span class="pagetitle"><cfif pgfn EQ "add" OR pgfn EQ "copy">Add<cfelse>Edit</cfif> a Territory</span>
	<br /><br />
	<span class="pageinstructions">Return to <a href="#CurrentPage#?orderby=#orderby#&sortdir=#sortdir#">Henkel Territory List</a> without making changes.</span>
	<br /><br />
	</cfoutput>
	<cfif pgfn EQ "edit">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT ID, fname, lname, address1, address2, city, state, zip, country, sub_group, region, division, grp, ty, sap_ty, cost_center, regional_manager, email, program_ID
			FROM #application.database#.henkel_territory
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
		<cfset fname = htmleditformat(ToBeEdited.fname)>
		<cfset lname = htmleditformat(ToBeEdited.lname)>
		<cfset address1 = htmleditformat(ToBeEdited.address1)>
		<cfset address2 = htmleditformat(ToBeEdited.address2)>
		<cfset city = htmleditformat(ToBeEdited.city)>
		<cfset state = htmleditformat(ToBeEdited.state)> 
		<cfset zip = htmleditformat(ToBeEdited.zip)>
		<cfset country = htmleditformat(ToBeEdited.country)>
		<cfset sub_group = htmleditformat(ToBeEdited.sub_group)>
		<cfset region = htmleditformat(ToBeEdited.region)>
		<cfset division = htmleditformat(ToBeEdited.division)>
		<cfset grp = htmleditformat(ToBeEdited.grp)>
		<cfset ty = htmleditformat(ToBeEdited.ty)>
		<cfset sap_ty = htmleditformat(ToBeEdited.sap_ty)>
		<cfset cost_center = htmleditformat(ToBeEdited.cost_center)>
		<cfset regional_manager = htmleditformat(ToBeEdited.regional_manager)>
		<cfset email = htmleditformat(ToBeEdited.email)>
		<cfset program_ID = htmleditformat(ToBeEdited.program_ID)>
	</cfif>
	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<input type="hidden" name="orderby" value="#orderby#">
		<input type="hidden" name="sortdir" value="#sortdir#">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> a Territory</td>
	</tr>
	<tr class="content"><td align="right">First Name: </td><td><input type="text" name="fname" value="#fname#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Last Name: </td><td><input type="text" name="lname" value="#lname#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Email: </td><td><input type="text" name="email" value="#email#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Address: </td><td><input type="text" name="address1" value="#address1#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right"></td><td><input type="text" name="address2" value="#address2#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">City: </td><td><input type="text" name="city" value="#city#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">State: </td><td><input type="text" name="state" value="#state#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Zip: </td><td><input type="text" name="zip" value="#zip#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Region: </td><td><input type="text" name="sap_ty" value="#sap_ty#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Sub Region: </td><td><input type="text" name="region" value="#region#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Group: </td><td><input type="text" name="grp" value="#grp#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Sub Group: </td><td><input type="text" name="sub_group" value="#sub_group#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Division: </td><td><input type="text" name="division" value="#division#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Country: </td><td><input type="text" name="country" value="#country#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">TY: </td><td><input type="text" name="ty" value="#ty#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Cost Center: </td><td><input type="text" name="cost_center" value="#cost_center#" maxlength="75" size="60"></td></tr>
	<tr class="content"><td align="right">Regional Manager: </td><td><input type="text" name="regional_manager" value="#regional_manager#" maxlength="75" size="60"></td></tr>
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