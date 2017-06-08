<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->

<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000063,true)>

<cfparam name="program_ID" default="">
<cfparam name="group_ID" default="">
<cfparam name="pgfn" default="list">

<cfif NOT isNumeric(program_ID) OR program_ID LTE 0>
	<cflocation url="pickprogram.cfm?n=program_exclude_group" addtoken="no">
</cfif>

<cfif pgfn NEQ "list" AND NOT isNumeric(group_ID)>
	<cfset group_ID = "list">
</cfif>

<cfset leftnavon = "program_exclude_group">
<cfinclude template="includes/header.cfm">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->
<span class="pageinstructions"><a href="pickprogram.cfm?n=program_exclude_group">Select another program.</a></span>
<br><br>
<span class="pagetitle">Exclude Product Groups from <cfoutput>#FLITC_GetProgramName(program_ID)#</cfoutput></span>
<br /><br />

<cfif pgfn EQ "list">
	<cfquery name="FindExludeProdIDs" datasource="#application.DS#">
		SELECT product_ID 
		FROM #application.database#.program_product_exclude 
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10" >
	</cfquery>
	<cfset ExcludedProdID = ValueList(FindExludeProdIDs.product_ID)>
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT ID, name, sortorder
		FROM #application.database#.product_meta_group
		ORDER BY sortorder
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	<cfoutput>
	<tr class="contenthead">
	<td width="30%" class="headertext"></td>
	<td width="50%" class="headertext">Name</td>
	<td width="20%" class="headertext">Number Excluded</td>
	</tr>
	</cfoutput>
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
		<td colspan="100%" align="center"><span class="alert"><br>No groups found.  Click "add" enter a product group.<br><br></span></td>
		</tr>
	<cfelse>
		<cfoutput query="SelectList">
			<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
			<td>
				<a href="#CurrentPage#?pgfn=exclude&group_ID=#ID#&program_ID=#program_ID#">Exclude</a>&nbsp;&nbsp;&nbsp;
				<a href="#CurrentPage#?pgfn=include&group_ID=#ID#&program_ID=#program_ID#">Include</a>&nbsp;&nbsp;&nbsp;
				<a href="#CurrentPage#?pgfn=show&group_ID=#ID#&program_ID=#program_ID#">Show</a>
			</td>
			<td>#name#</td>
			<td>
				<cfquery name="FindTotal" datasource="#application.DS#">
					SELECT COUNT(pmgl.ID) AS total 
					FROM #application.product_database#.product_meta_group_lookup pmgl
						JOIN #application.product_database#.product_meta pm ON pmgl.product_meta_ID = pm.ID 
						JOIN #application.product_database#.product p ON p.product_meta_ID = pm.ID 
					WHERE pmgl.product_meta_group_ID = #SelectList.ID#
				</cfquery>
				<cfquery name="FindExclude" datasource="#application.DS#" cachedwithin="#CreateTimeSpan(0,0,0,0)#">
					SELECT COUNT(p.ID) AS total 
					FROM #application.product_database#.product_meta_group_lookup pmgl
						JOIN #application.product_database#.product_meta pm ON pmgl.product_meta_ID = pm.ID 
						JOIN #application.product_database#.product p ON p.product_meta_ID = pm.ID 
					WHERE p.ID IN (#ExcludedProdID#)
						AND pmgl.product_meta_group_ID = #SelectList.ID#
				</cfquery>
				#FindExclude.total# of #FindTotal.total#
			</td>
			</tr>
		</cfoutput>
	</cfif>
	</table>
<cfelseif pgfn EQ "include" OR pgfn EQ "exclude" OR pgfn EQ "show">
	<span class="pageinstructions">Return to the <a href="<cfoutput>#CurrentPage#?program_ID=#program_ID#</cfoutput>">Group List.</a></span>
	<br><br>
	<cfquery name="SelectGroupName" datasource="#application.DS#">
		SELECT name
		FROM #application.database#.product_meta_group
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#group_ID#" maxlength="10">
	</cfquery>
	<cfset groupname = HTMLEditFormat(SelectGroupName.name)>
	<cfoutput>
	<span class="pagetitle">List of Products in this Group [<span class="selecteditem">#groupname#</span>]</span>
	<br /><br />
	</cfoutput>
	<!--- find all the products in this group sorted by master category, then name alpha --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT pm.meta_name, pm.meta_sku, pv.productvalue, pm.ID AS this_meta_ID
		FROM #application.product_database#.product_meta pm
			JOIN #application.product_database#.productvalue_master pv  ON pm.productvalue_master_ID = pv.ID
			JOIN #application.product_database#.product_meta_group_lookup pmgl ON pm.ID = pmgl.product_meta_ID
		WHERE pmgl.product_meta_group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#group_ID#" maxlength="10">
		ORDER BY pv.sortorder ASC, meta_name ASC
	</cfquery>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
		<tr class="contenthead">
		<td>&nbsp;</td>
		<td><span class="headertext">Category</span></td>
		<td width="100%"><span class="headertext">Product</span></td>
		</tr>
		<cfif SelectList.RecordCount IS 0>
			<tr class="content2">
				<td colspan="3" align="center"><span class="alert"><br>No products were found in this group.<br><br></span></td>
			</tr>
		<cfelse>
			<cfoutput query="SelectList">
				<cfquery name="GetProduct" datasource="#application.DS#">
					SELECT ID, sku
					FROM #application.product_database#.product
					WHERE product_meta_ID = #this_meta_ID#
				</cfquery>
				<cfloop query="GetProduct">
					<cfset thisProductID = GetProduct.ID>
					<cfquery name="GetCurrent" datasource="#application.DS#">
						SELECT ID
						FROM #application.database#.program_product_exclude
						WHERE product_ID = #thisProductID#
						AND program_ID = #program_ID#
					</cfquery>
					<!--- <cfquery name="ThisProdsGroups" datasource="#application.DS#">
						SELECT g.name
						FROM #application.database#.product_meta_group g
						JOIN #application.product_database#.product_meta_group_lookup gl ON g.ID = gl.product_meta_group_ID
						WHERE gl.product_meta_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_meta_ID#" maxlength="10">
						ORDER BY g.sortorder ASC 
					</cfquery>
					<cfset this_group_list = ValueList(ThisProdsGroups.name)> --->
					<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
					<td>
						<cfif pgfn EQ "exclude">
							<cfif GetCurrent.recordcount GT 0>
								ALREADY EXCLUDED
							<cfelse>
								excluded
								<cfquery name="InsertQuery" datasource="#application.DS#">
									INSERT INTO #application.database#.program_product_exclude
									(created_user_ID, created_datetime, program_ID, product_ID)
									VALUES
									(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, 
									'#FLGen_DateTimeToMySQL()#', 
									<cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">, 
									<cfqueryparam cfsqltype="cf_sql_integer" value="#thisProductID#" maxlength="10">)
								</cfquery>
							</cfif>
						<cfelseif pgfn EQ "include">
							<cfif GetCurrent.recordcount EQ 0>
								ALREADY INCLUDED
							<cfelse>
								included
								<cfquery name="InsertQuery" datasource="#application.DS#">
									DELETE FROM #application.database#.program_product_exclude
									WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
									AND product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisProductID#" maxlength="10">
								</cfquery>
							</cfif>
						<cfelseif pgfn EQ "show">
							<cfif GetCurrent.recordcount EQ 0>in<cfelse>ex</cfif>cluded
						<cfelse>
							<cfabort showerror="Logically, this should not happen.">
						</cfif>
					</td>
					<td align="center">#SelectList.productvalue#</td>
					<td>#SelectList.meta_name# [SKU: #GetProduct.sku#]<!--- <br><span class="sub">#this_group_list#</span> ---></td>
					</tr>
				</cfloop>
			</cfoutput>	
		</cfif>
		<tr class="contenthead" height="5px;"><td colspan="100%"></td></tr>
	</table>
<cfelse>
	<span class="alert">Unknown PGFN: <cfoutput>#pgfn#</cfoutput></span>
</cfif>
<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->