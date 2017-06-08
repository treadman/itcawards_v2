<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_page.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000082,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="x" default="">
<cfparam name="ID" default="">
<cfparam name="datasaved" default="no">
<cfparam name="delete" default="">
<cfparam name="rmv_prod" default="">
<cfparam name="add_prod" default="">

<!--- param search criteria xS=ColumnSort xT=SearchString --->
<cfparam name="xS" default="created_datetime">
<cfparam name="xT" default="">
<cfparam name="xFD" default="">
<cfparam name="xTD" default="">
<cfparam name="cri_Admin" default="">
<cfparam name="this_from_date" default="">
<cfparam name="this_to_date" default="">
<cfparam name="alert_msg" default="">
<cfparam name="pgfn" default="list">
<cfparam name="OnPage" default="1">

<!--- param a/e form fields --->
<cfparam name="package_type" default="Package">
<cfparam name="service_level" default="Ground">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>

	<!--- details --->
	<cfif IsDefined('form.pgfn') AND form.pgfn EQ 'details'>
	
		<cfif declared_value LTE 99>
			<cfset declared_value = "">
		</cfif>

		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.database#.ups_group
				SET	weight = <cfqueryparam cfsqltype="cf_sql_integer" value="#weight#">,
					package_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#package_type#" maxlength="50">, 
					service_level = <cfqueryparam cfsqltype="cf_sql_varchar" value="#service_level#" maxlength="50">, 
					length = <cfqueryparam cfsqltype="cf_sql_integer" value="#length#">, 
					width = <cfqueryparam cfsqltype="cf_sql_integer" value="#width#">, 
					height = <cfqueryparam cfsqltype="cf_sql_integer" value="#height#">, 
					declared_value = <cfqueryparam cfsqltype="cf_sql_integer" value="#declared_value#" null="#YesNoFormat(NOT Len(Trim(declared_value)))#">,
					is_residential = <cfqueryparam cfsqltype="cf_sql_varchar" value="#is_residential#"> 
					#FLGen_UpdateModConcatSQL()#
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#" maxlength="10">
		</cfquery>
	
		<cfset datasaved = "yes">
		<cfset pgfn = "detail">

	</cfif>
	
<cfelseif IsDefined('pgfn') AND pgfn EQ 'manage_prod'>

	<cfif rmv_prod NEQ "">
		<cfquery name="UpdateRemoveProd" datasource="#application.DS#">
			UPDATE #application.database#.inventory
			SET	upsgroup_ID = NULL
				#FLGen_UpdateModConcatSQL()#
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#rmv_prod#">
		</cfquery>
	<cfelseif add_prod NEQ "">
		<cfquery name="UpdateRemoveProd" datasource="#application.DS#">
			UPDATE #application.database#.inventory
			SET	upsgroup_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#">
				#FLGen_UpdateModConcatSQL()#
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#add_prod#">
		</cfquery>
	</cfif>

	<cfset datasaved = "yes">
	<cfset pgfn = "manage_prod">

<cfelseif delete NEQ "">

	<cfquery name="DeleteThis" datasource="#application.DS#">
		DELETE FROM #application.database#.ups_group
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#delete#" maxlength="10">
	</cfquery>
	
	<cfquery name="DeleteUpdate" datasource="#application.DS#">
		UPDATE #application.database#.inventory
		SET	upsgroup_ID = NULL
			#FLGen_UpdateModConcatSQL()#
		WHERE upsgroup_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#delete#" maxlength="10">
	</cfquery>
		
	<cfset pgfn = "list">
	<cfset alert_msg = "The UPS Group was deleted.">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "ups_group_list">
<cfinclude template="includes/header.cfm">

<script src="../includes/paging.js"></script> 

<cfparam  name="pgfn" default="list">

<!--- START pgfn LIST --->
<cfif pgfn EQ "list">

	<!--- massage dates --->
	<cfif this_from_date NEQ "" AND IsDate(this_from_date)>
		<cfset xFD = FLGen_DateTimeToMySQL(this_from_date,'startofday')>
	</cfif>
	<cfif this_to_date NEQ "" AND IsDate(this_to_date)>
		<cfset xTD = FLGen_DateTimeToMySQL(this_to_date,'endofday')>
	</cfif>
	
	<cfif xFD NEQ "">
		<cfset x_date =  RemoveChars(Insert(',', Insert(',', xFD, 6),4),11,16)>
		<cfset this_from_date = ListGetAt(x_date,2) & '/' & ListGetAt(x_date,3) & '/' & ListGetAt(x_date,1)>
	</cfif>
	<cfif xTD NEQ "">
		<cfset x_date =  RemoveChars(Insert(',', Insert(',', xTD, 6),4),11,16)>
		<cfset this_to_date = ListGetAt(x_date,2) & '/' & ListGetAt(x_date,3) & '/' & ListGetAt(x_date,1)>
	</cfif>
	
	<!--- run query --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT upsg.ID, upsg.created_datetime, upsg.created_user_ID, upsg.product_ID, p.sku, pm.meta_name 
		FROM #application.database#.ups_group upsg 
			JOIN #application.product_database#.product p ON upsg.product_ID = p.ID 
			JOIN #application.product_database#.product_meta pm ON pm.ID = p.product_meta_ID
		WHERE is_imported = 0 
		<cfif LEN(xT) GT 0>
			AND ((SELECT COUNT(inv.ID) FROM #application.database#.inventory inv WHERE inv.upsgroup_ID = upsg.ID AND (snap_sku LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(xT)#%"> OR snap_meta_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(xT)#%">)) > 0)
		</cfif>
		<cfif cri_Admin NEQ "">
			AND upsg.created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cri_Admin#">
		</cfif>
		<cfif this_from_date NEQ "">
			AND upsg.created_datetime >= <cfqueryparam value="#xFD#">
		</cfif>
		<cfif this_to_date NEQ "">
			AND upsg.created_datetime <= <cfqueryparam value="#xTD#">
		</cfif>
		ORDER BY upsg.created_datetime DESC
	</cfquery>
	
	<span class="pagetitle">UPS Group List</span>
	<br />
	<br />
		<!--- search box --->
		<table cellpadding="5" cellspacing="0" border="0" width="100%">
		
		<tr class="contenthead">
		<td><span class="headertext">Search Criteria</span></td>
		<td align="right"><a href="<cfoutput>#CurrentPage#</cfoutput>" class="headertext">view all</a></td>
		</tr>
		
		<tr>
		<td class="contentsearch" colspan="2" align="center"><span class="sub">All fields are optional.  Leave unnecessary fields blank.</span></td>
		</tr>
	
		<tr>
		<td class="content" colspan="2" align="center">
		
		<cfquery name="SelectDistinctAdmin" datasource="#application.DS#">
			SELECT DISTINCT ups.created_user_ID, au.firstname, au.lastname 
			FROM #application.database#.ups_group ups
				JOIN #application.database#.admin_users au ON ups.created_user_ID = au.ID
			ORDER BY au.lastname
		</cfquery>
		
			<cfoutput>
				<form action="#CurrentPage#" method="post">
				
			<table cellpadding="5" cellspacing="0" border="0" width="100%">
			
			<tr>
			<td align="center"><span class="sub">admin user</span><br>
			<select name="cri_Admin">
				<option value="">All Admin Users</option>
				<cfloop query="SelectDistinctAdmin">
				<option value="#created_user_ID#"#FLForm_Selected(created_user_ID,cri_Admin," selected")#>#FLGen_GetAdminName(created_user_ID)#</option>
				</cfloop>
			</select>
			
			<br><br>			
				<span class="sub">sku or product name</span><br>
				<input type="text" name="xT" value="#HTMLEditFormat(xT)#" size="20">
			</td>
			<td align="right">			
				<span class="sub">From Date:</span> <input type="text" name="this_from_date" value="#this_from_date#" size="20"><br><br>
				<span class="sub">To Date:</span> <input type="text" name="this_to_date" value="#this_to_date#" size="20">
			</td>
			<td align="center">&nbsp;&nbsp;&nbsp;</td>
			<td>			
				<input type="submit" name="search" value="search">
			</td>
			</tr>
			
			</table>
				</form>
			</cfoutput>
			<br>		
		</td>
		</tr>
		
		</table>
		
		<br />
		
		<!--- paging code --->
		<cfoutput>#FLPage_Paging(OnPage,SelectList.RecordCount,"QUERYSTRINGHERE",10)#</cfoutput>
		
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<!--- header row --->
	<cfoutput>	
		<tr class="contenthead">
		<td align="center">&nbsp;</td>
		<td><span class="headertext">Date</span> <img src="../pics/contrls-asc.gif" width="7" height="6"></td>
		<td><span class="headertext">Qty</span></td>
		<td><span class="headertext">Product SKU and Name</span></td>
		<td nowrap="nowrap"><span class="headertext">Admin User</span></td>	</tr>
	</cfoutput>
	
	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
	<cfoutput>
		<tr class="content2">
		<td colspan="5" align="center"><span class="alert"><br>No records found.  Click "view all" to see all records.<br><br></span></td>
		</tr>
	</cfoutput>
	</cfif>
	
	<!--- display found records --->
	<cfoutput query="SelectList" startrow="#StartRow_SelectList#" maxrows="#MaxRows_SelectList#">
	
		<!--- find how many inv items in ups group --->
		<cfquery name="SelectNumberOfProd" datasource="#application.DS#">
			SELECT COUNT(ID) AS ThisCount
			FROM #application.database#.inventory 
			WHERE upsgroup_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
		</cfquery>
	
		<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
		
		<td align="center" nowrap="nowrap"><a href="#CurrentPage#?pgfn=detail&upsgroup_ID=#ID#&xT=#xT#&xTD=#xTD#&xFD=#xFD#&cri_Admin=#cri_Admin#&OnPage=#OnPage#">details</a>&nbsp;&nbsp;<a href="#CurrentPage#?pgfn=list&delete=#ID#&upsgroup_ID=#ID#&xT=#xT#&xTD=#xTD#&xFD=#xFD#&cri_Admin=#cri_Admin#" onclick="return confirm('Are you sure you want to delete this UPS Group?  There is NO UNDO.\n\nAll products in this UPS Group will be released from this group\nand available to be put into other UPS Groups.')" >delete</a></td>
		<td valign="top" nowrap="nowrap">#FLGen_DateTimeToDisplay(created_datetime,true,false,false)#</td>
		<td valign="top" nowrap="nowrap">#SelectNumberOfProd.ThisCount#&nbsp;<a href="#CurrentPage#?pgfn=manage_prod&upsgroup_ID=#ID#&xT=#xT#&xTD=#xTD#&xFD=#xFD#&cri_Admin=#cri_Admin#&OnPage=#OnPage#">+/-</a></td>
		<td valign="top" width="100%">SKU:#HTMLEditFormat(sku)#<br>#HTMLEditFormat(meta_name)#</td>
		<td valign="top" nowrap="nowrap">#FLGen_GetAdminName(created_user_ID)#</td>
			
		</tr>
	</cfoutput>
	
		</table>
	
	<!--- END pgfn LIST --->
<cfelseif pgfn EQ "detail"> 
	<!--- START pgfn DETAIL --->
	
	<span class="pagetitle">Save UPS Group Details and Export</span>
	<br /><br />
	
	<cfoutput>
	
	<span class="pageinstructions">Return to <a href="#CurrentPage#?xT=#xT#&xTD=#xTD#&xFD=#xFD#&cri_Admin=#cri_Admin#&OnPage=#OnPage#">UPS Group List</a> without making changes.</span>
	<br /><br />
	
	<cfif datasaved eq 'yes'>
		<span class="alert">The information was saved.</span>#FLGen_SubStamp()#
		<br /><br />
	</cfif>
	
	</cfoutput>
		
	<cfquery name="ToBeEdited" datasource="#application.DS#">
		SELECT upsg.ID, upsg.created_user_ID, Date_Format(upsg.created_datetime,'%c/%d/%Y %l:%i %p') AS created_datetime, upsg.weight, upsg.package_type, upsg.service_level, upsg.height, upsg.declared_value, upsg.width, upsg.length, upsg.is_residential, p.sku, pm.meta_name 
		FROM #application.database#.ups_group upsg 
			JOIN #application.product_database#.product p ON upsg.product_ID = p.ID 
			JOIN #application.product_database#.product_meta pm ON pm.ID = p.product_meta_ID
		WHERE upsg.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#" maxlength="10">
	</cfquery>
	<cfset ID = ToBeEdited.ID>
	<cfset admin_user = FLGen_GetAdminName(ToBeEdited.created_user_ID)>
	<cfset created_datetime =ToBeEdited.created_datetime>
	<cfset declared_value = HTMLEditFormat(ToBeEdited.declared_value)>
	<cfset weight = HTMLEditFormat(ToBeEdited.weight)>
	<cfset height = HTMLEditFormat(ToBeEdited.height)>
	<cfset width = HTMLEditFormat(ToBeEdited.width)>
	<cfset length = HTMLEditFormat(ToBeEdited.length)>
	<cfset is_residential = HTMLEditFormat(ToBeEdited.is_residential)>
	<cfset sku = HTMLEditFormat(ToBeEdited.sku)>
	<cfset meta_name = HTMLEditFormat(ToBeEdited.meta_name)>
	
	<cfif ToBeEdited.package_type NEQ "">
		<cfset package_type = HTMLEditFormat(ToBeEdited.package_type)>
	</cfif>
	
	<cfif ToBeEdited.service_level NEQ "">
		<cfset service_level = HTMLEditFormat(ToBeEdited.service_level)>
	</cfif>
	
		<cfquery name="InvItemsInGroup" datasource="#application.DS#">
			SELECT inv.ID AS inventory_ID, inv.order_ID, ord.program_ID, inv.quantity
			FROM #application.database#.inventory inv
			JOIN #application.database#.order_info ord ON inv.order_ID = ord.ID
			WHERE inv.upsgroup_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#"> 
				AND inv.is_valid = 1 
				AND inv.quantity <> 0 
				AND inv.snap_is_dropshipped = 0  
				AND inv.order_ID <> 0 
				AND inv.ship_date IS NULL 
				AND inv.po_ID = 0
				AND inv.po_rec_date IS NULL 
		</cfquery>
		
		
	<cfoutput>
	
	<form method="post" action="#CurrentPage#">
	
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
		
		<tr class="contenthead">
		<td colspan="2" class="headertext">UPS GROUP INFO <cfif weight NEQ "" AND height NEQ "" AND width NEQ "" AND length NEQ "" AND InvItemsInGroup.RecordCount GTE 1><a href="ups_group_export.cfm?upsgroup_ID=#ID#" style="margin-left:270px; padding:2px; background-color:##FFFFFF">EXPORT .CSV</a></cfif><a href="ups_group_import.cfm?upsgroup_ID=#ID#" style="margin-left:10px; padding:2px; background-color:##FFFFFF">IMPORT .CSV</a></td>
		</tr>
	
		<tr class="content2">
		<td colspan="2">#created_datetime# <b>SKU:#sku# #meta_name#</b> #admin_user#</td>
		</tr>
	
		<tr class="content">
		<td align="right">Billing Option: </td>
		<td>Prepaid</td>
		</tr>
			
		<tr class="content">
		<td align="right">Residential?: </td>
		<td>
			<select name="is_residential">
				<option value="Y"#FLForm_Selected("Y",is_residential," selected")#>Yes</option>
				<option value="N"#FLForm_Selected("N",is_residential," selected")#>No</option>
			</select>
		</td>
		</tr>
		
		<tr class="content">
		<td align="right">Package Type: </td>
		<td>
			<select name="package_type">
				<option value="Package"#FLForm_Selected("Package",service_level," selected")#>Package</option>
				<option value="UPS Letter (Air Services, International)"#FLForm_Selected("UPS Letter (Air Services, International)",service_level," selected")#>UPS Letter (Air Services, International)</option>
				<option value="UPS Tube (Air Services, International)"#FLForm_Selected("UPS Tube (Air Services, International)",service_level," selected")#>UPS Tube (Air Services, International)</option>
				<option value="UPS Pak (Air Services, International)"#FLForm_Selected("UPS Pak  (Air Services, International)",service_level," selected")#>UPS Pak  (Air Services, International)</option>
				<option value="UPS Express Box (Air Services, International)"#FLForm_Selected("UPS Express Box (Air Services, International)",service_level," selected")#>UPS Express Box (Air Services, International)</option>
				<option value="UPS 25 LG Box (International)"#FLForm_Selected("UPS 25 LG Box (International)",service_level," selected")#>UPS 25 LG Box (International)</option>
				<option value="UPS 10 LG Box (International)"#FLForm_Selected("UPS 10 LG Box (International)",service_level," selected")#>UPS 10 LG Box (International)</option>
			</select>
		</td>
		</tr>
		
		<tr class="content">
		<td align="right">Service Level: </td>
		<td>
			<select name="service_level">
				<option value="Next Day Air Early AM"#FLForm_Selected("Next Day Air Early AM",service_level," selected")#>Next Day Air Early AM</option>
				<option value="Next Day Air"#FLForm_Selected("Next Day Air",service_level," selected")#>Next Day Air</option>
				<option value="Next Day Air Saver"#FLForm_Selected("Next Day Air Saver",service_level," selected")#>Next Day Air Saver</option>
				<option value="2nd Day Air AM"#FLForm_Selected("2nd Day Air AM",service_level," selected")#>2nd Day Air AM</option>
				<option value="2nd Day Air"#FLForm_Selected("2nd Day Air",service_level," selected")#>2nd Day Air</option>
				<option value="3 Day Select"#FLForm_Selected("3 Day Select",service_level," selected")#>3 Day Select</option>
				<option value="Ground"#FLForm_Selected("Ground",service_level," selected")#>Ground</option>
				<option value="Worldwide Express Plus (International)"#FLForm_Selected("Worldwide Express Plus (International)",service_level," selected")#>Worldwide Express Plus (International)</option>
				<option value="Worldwide Express (International)"#FLForm_Selected("Worldwide Express (International)",service_level," selected")#>Worldwide Express (International)</option>
				<option value="Worldwide Expedited (International)"#FLForm_Selected("Worldwide Expedited (International)",service_level," selected")#>Worldwide Expedited (International)</option>
				<option value="Standard (International)"#FLForm_Selected("Standard (International)",service_level," selected")#>Standard (International)</option>
			</select>
		<input type="hidden" name="service_level_required" value="You must enter a service level."></td>
		</tr>
			
		<tr class="content">
		<td align="right" valign="top">Declared Value: </td>
		<td valign="top"><input type="text" name="declared_value" value="#declared_value#" maxlength="11" size="8"> <span class="sub">dollars (only if more than $100)</span>
		<input type="hidden" name="declared_value_integer" value="The declared value must be a whole number (no decimals)."></td>
		</tr>
		
		<tr class="content">
		<td align="right" valign="top">Package Weight: </td>
		<td valign="top"><input type="text" name="weight" value="#weight#" maxlength="11" size="8"> <span class="sub">pounds</span>
		<input type="hidden" name="weight_integer" value="The weight must be a whole number (no decimals)."></td>
		</tr>
		
		<tr class="content">
		<td align="right">Length: </td>
		<td><input type="text" size="8" maxlength="10" name="length" value="#length#"> <span class="sub">in.</span>
		<input type="hidden" name="length_required" value="You must enter a length.">&nbsp;&nbsp;&nbsp;&nbsp;
		Width: <input type="text" size="8" maxlength="10" name="width" value="#width#"> <span class="sub">in.</span>
		<input type="hidden" name="width_required" value="You must enter a width.">&nbsp;&nbsp;&nbsp;&nbsp;
		Height: <input type="text" size="8" maxlength="10" name="height" value="#height#"> <span class="sub">in.</span>
		<input type="hidden" name="height_required" value="You must enter a height.">
		
		
		<input type="hidden" name="length_integer" value="The length must be a whole number (no decimals).">
		<input type="hidden" name="width_integer" value="The width must be a whole number (no decimals).">
		<input type="hidden" name="height_integer" value="The height must be a whole number (no decimals)."></td>
		</tr>
		
		<tr class="content">
		<td colspan="2" align="center">
		
		<input type="hidden" name="pgfn" value="details">
		<input type="hidden" name="xT" value="#xT#">
		<input type="hidden" name="xFD" value="#xFD#">
		<input type="hidden" name="xTD" value="#xTD#">
		<input type="hidden" name="cri_Admin" value="#cri_Admin#">
		<input type="hidden" name="upsgroup_ID" value="#ID#">
		<input type="hidden" name="OnPage" value="#OnPage#">
				
		<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" >
	
		</td>
		</tr>
					
		</table>
	
	</form>
	
		<br><br>
		
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
		<tr class="contenthead">
		<td colspan="2" class="headertext">#InvItemsInGroup.RecordCount# ITEM<cfif InvItemsInGroup.RecordCount NEQ 1>S</cfif> IN THIS UPS GROUP</td>
		</tr>
	
		<cfif InvItemsInGroup.RecordCount EQ 0>
		
		<tr class="content">
		<td colspan="2" width="100%"><span class="alert">There are no items in this UPS Group.</span></td>
		</tr>
	
		</cfif>
	
		<cfloop query="InvItemsInGroup">
		
			<cfquery name="FindOrderInfo" datasource="#application.DS#">
				SELECT ID AS this_order_ID, program_ID AS this_program_ID, order_number, snap_fname, snap_lname, snap_ship_company, snap_ship_fname, snap_ship_lname, snap_ship_address1, snap_ship_address2, snap_ship_city, snap_ship_state, snap_ship_zip, snap_phone, snap_email, order_note
				FROM #application.database#.order_info
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsInGroup.order_ID#" maxlength="10">
					AND is_valid = 1
			</cfquery>
			<cfset this_program_ID = FindOrderInfo.this_program_ID>
			<cfset this_order_ID = FindOrderInfo.this_order_ID>
			<cfset order_number = HTMLEditFormat(FindOrderInfo.order_number)>
			<cfset snap_fname = HTMLEditFormat(FindOrderInfo.snap_fname)>
			<cfset snap_lname = HTMLEditFormat(FindOrderInfo.snap_lname)>
			<cfset snap_ship_company = HTMLEditFormat(FindOrderInfo.snap_ship_company)>
			<cfset snap_ship_fname = HTMLEditFormat(FindOrderInfo.snap_ship_fname)>
			<cfset snap_ship_lname = HTMLEditFormat(FindOrderInfo.snap_ship_lname)>
			<cfset snap_ship_address1 = HTMLEditFormat(FindOrderInfo.snap_ship_address1)>
			<cfset snap_ship_address2 = HTMLEditFormat(FindOrderInfo.snap_ship_address2)>
			<cfset snap_ship_city = HTMLEditFormat(FindOrderInfo.snap_ship_city)>
			<cfset snap_ship_state = HTMLEditFormat(FindOrderInfo.snap_ship_state)>
			<cfset snap_ship_zip = HTMLEditFormat(FindOrderInfo.snap_ship_zip)>
			<cfset snap_phone = HTMLEditFormat(FindOrderInfo.snap_phone)>
			<cfset snap_email = HTMLEditFormat(FindOrderInfo.snap_email)>
			<cfset order_note = HTMLEditFormat(FindOrderInfo.order_note)>
								
			<cfquery name="MultiProdCheck" datasource="#application.DS#">
				SELECT product_ID
				FROM #application.database#.inventory
				WHERE is_valid = 1 
					AND quantity <> 0 
					AND snap_is_dropshipped = 0 
					AND order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsInGroup.order_ID#"> 
					AND ship_date IS NULL
					AND po_ID = 0
					AND po_rec_date IS NULL
					AND upsgroup_ID IS NULL
			</cfquery>
			
			<cfoutput>
	
		<tr class="content" valign="top">
		<td valign="top">
		<cfif MultiProdCheck.RecordCount GT 1><span class="alert">This is a multi-item order.</span><br></cfif>
			QTY: #InvItemsInGroup.quantity#<br>
			#FLITC_GetProgramName(FindOrderInfo.this_program_ID)# Order #order_number#<br>
			<cfif snap_fname NEQ "">#snap_fname#</cfif> <cfif snap_lname NEQ "">#snap_lname#<br></cfif>
			<cfif snap_phone NEQ "">Phone: #snap_phone#<br></cfif>
			<cfif snap_email NEQ "">Email: #snap_email#<br></cfif>
		</td>
		<td valign="top">
			<cfif snap_ship_company NEQ "">#snap_ship_company#<br></cfif>
			<cfif snap_ship_fname NEQ "">#snap_ship_fname#</cfif> <cfif snap_ship_lname NEQ "">#snap_ship_lname#</cfif><br>
			<cfif snap_ship_address1 NEQ "">#snap_ship_address1#<br></cfif>
			<cfif snap_ship_address2 NEQ "">#snap_ship_address2#<br></cfif>
			<cfif snap_ship_city NEQ "">#snap_ship_city#</cfif>, <cfif snap_ship_state NEQ "">#snap_ship_state#</cfif> <cfif snap_ship_zip NEQ "">#snap_ship_zip#</cfif><br>
		<cfif order_note NEQ "">#Replace(HTMLEditFormat(order_note),chr(10),"<br>","ALL")#<cfelse><span class="sub">(no order note)</span></cfif></td>
		</tr>
	
			</cfoutput>
		
		</cfloop>
	
		</table>
	
	</cfoutput>
	
	<!--- END pgfn DETAIL --->
<cfelseif pgfn EQ "manage_prod">
	<!--- START pgfn MANAGE PRODUCTS --->
	
	<span class="pagetitle">Add or Remove Items from UPS Group</span>
	<br /><br />
	<cfoutput>
		<span class="pageinstructions">Return to <a href="#CurrentPage#?xT=#xT#&xTD=#xTD#&xFD=#xFD#&cri_Admin=#cri_Admin#&OnPage=#OnPage#">UPS Group List</a>.</span>
	<br /><br />
	</cfoutput>
	
		<cfquery name="UPSGroupInfo" datasource="#application.DS#">
			SELECT upsg.ID, upsg.created_user_ID, Date_Format(upsg.created_datetime,'%c/%d/%Y %l:%i %p') AS created_datetime, p.sku, pm.meta_name, upsg.product_ID 
			FROM #application.database#.ups_group upsg 
				JOIN #application.product_database#.product p ON upsg.product_ID = p.ID 
				JOIN #application.product_database#.product_meta pm ON pm.ID = p.product_meta_ID
			WHERE upsg.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#" maxlength="10">
		</cfquery>
		<cfset ID = UPSGroupInfo.ID>
		<cfset admin_user = FLGen_GetAdminName(UPSGroupInfo.created_user_ID)>
		<cfset created_datetime =UPSGroupInfo.created_datetime>
		<cfset sku = HTMLEditFormat(UPSGroupInfo.sku)>
		<cfset meta_name = HTMLEditFormat(UPSGroupInfo.meta_name)>
		<cfset product_ID = HTMLEditFormat(UPSGroupInfo.product_ID)>
	
		<cfquery name="InvItemsInGroup" datasource="#application.DS#">
			SELECT inv.ID AS inventory_ID, inv.order_ID, ord.program_ID, inv.quantity
			FROM #application.database#.inventory inv
			JOIN #application.database#.order_info ord ON inv.order_ID = ord.ID
			WHERE inv.upsgroup_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#"> 
				AND inv.product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#product_ID#">
				AND inv.is_valid = 1 
				AND inv.quantity <> 0 
				AND inv.snap_is_dropshipped = 0  
				AND inv.order_ID <> 0 
				AND inv.ship_date IS NULL 
				AND inv.po_ID = 0
				AND inv.po_rec_date IS NULL 
		</cfquery>
		
		<cfquery name="InvItemsNOTInGroup" datasource="#application.DS#">
			SELECT inv.ID AS inventory_ID, inv.order_ID, ord.program_ID, inv.quantity
			FROM #application.database#.inventory inv
			JOIN #application.database#.order_info ord ON inv.order_ID = ord.ID
			WHERE inv.upsgroup_ID IS NULL 
				AND inv.product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#product_ID#">
				AND inv.is_valid = 1 
				AND inv.quantity <> 0 
				AND inv.snap_is_dropshipped = 0  
				AND inv.order_ID <> 0 
				AND inv.ship_date IS NULL 
				AND inv.po_ID = 0
				AND inv.po_rec_date IS NULL 
		</cfquery>
		
	
		<table cellpadding="5" cellspacing="1" border="0" width="100%">
		
		
		<tr class="contenthead">
		<td colspan="3" class="headertext">UPS GROUP</td>
		</tr>
	
		<tr class="content2">
		<td colspan="3"><cfoutput>#created_datetime# <b>SKU:#sku# #meta_name#</b> #admin_user#</cfoutput></td>
		</tr>
	
		<cfif InvItemsInGroup.RecordCount EQ 0>
		
		<tr class="content">
		<td colspan="3" width="100%"><span class="alert">There are no items in this UPS Group.</span></td>
		</tr>
	
		</cfif>
	
		<cfloop query="InvItemsInGroup">
		
			<cfquery name="FindOrderInfo" datasource="#application.DS#">
				SELECT ID AS this_order_ID, program_ID AS this_program_ID, order_number, snap_fname, snap_lname, snap_ship_company, snap_ship_fname, snap_ship_lname, snap_ship_address1, snap_ship_address2, snap_ship_city, snap_ship_state, snap_ship_zip, snap_phone, snap_email, order_note
				FROM #application.database#.order_info
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsInGroup.order_ID#" maxlength="10">
					AND is_valid = 1
			</cfquery>
			<cfset this_program_ID = FindOrderInfo.this_program_ID>
			<cfset this_order_ID = FindOrderInfo.this_order_ID>
			<cfset order_number = HTMLEditFormat(FindOrderInfo.order_number)>
			<cfset snap_fname = HTMLEditFormat(FindOrderInfo.snap_fname)>
			<cfset snap_lname = HTMLEditFormat(FindOrderInfo.snap_lname)>
			<cfset snap_ship_company = HTMLEditFormat(FindOrderInfo.snap_ship_company)>
			<cfset snap_ship_fname = HTMLEditFormat(FindOrderInfo.snap_ship_fname)>
			<cfset snap_ship_lname = HTMLEditFormat(FindOrderInfo.snap_ship_lname)>
			<cfset snap_ship_address1 = HTMLEditFormat(FindOrderInfo.snap_ship_address1)>
			<cfset snap_ship_address2 = HTMLEditFormat(FindOrderInfo.snap_ship_address2)>
			<cfset snap_ship_city = HTMLEditFormat(FindOrderInfo.snap_ship_city)>
			<cfset snap_ship_state = HTMLEditFormat(FindOrderInfo.snap_ship_state)>
			<cfset snap_ship_zip = HTMLEditFormat(FindOrderInfo.snap_ship_zip)>
			<cfset snap_phone = HTMLEditFormat(FindOrderInfo.snap_phone)>
			<cfset snap_email = HTMLEditFormat(FindOrderInfo.snap_email)>
			<cfset order_note = HTMLEditFormat(FindOrderInfo.order_note)>
								
			<cfquery name="MultiProdCheck" datasource="#application.DS#">
				SELECT product_ID
				FROM #application.database#.inventory
				WHERE is_valid = 1 
					AND quantity <> 0 
					AND snap_is_dropshipped = 0 
					AND order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsInGroup.order_ID#"> 
					AND ship_date IS NULL
					AND po_ID = 0
					AND po_rec_date IS NULL
					AND upsgroup_ID IS NULL
			</cfquery>
			
			<cfoutput>
	
		<tr class="content" valign="top">
		<td><a href="#CurrentPage#?pgfn=manage_prod&rmv_prod=#InvItemsInGroup.inventory_ID#&upsgroup_ID=#upsgroup_ID#&xT=#xT#&xTD=#xTD#&xFD=#xFD#&cri_Admin=#cri_Admin#&OnPage=#OnPage#">REMOVE</a></td>
		<td valign="top">
		<cfif MultiProdCheck.RecordCount GT 1><span class="alert">This is a multi-item order.</span><br></cfif>
			QTY: #InvItemsInGroup.quantity#<br>
			#FLITC_GetProgramName(FindOrderInfo.this_program_ID)# Order #order_number#<br>
			<cfif snap_fname NEQ "">#snap_fname#</cfif> <cfif snap_lname NEQ "">#snap_lname#<br></cfif>
			<cfif snap_phone NEQ "">Phone: #snap_phone#<br></cfif>
			<cfif snap_email NEQ "">Email: #snap_email#<br></cfif>
		</td>
		<td valign="top">
			<cfif snap_ship_company NEQ "">#snap_ship_company#<br></cfif>
			<cfif snap_ship_fname NEQ "">#snap_ship_fname#</cfif> <cfif snap_ship_lname NEQ "">#snap_ship_lname#</cfif><br>
			<cfif snap_ship_address1 NEQ "">#snap_ship_address1#<br></cfif>
			<cfif snap_ship_address2 NEQ "">#snap_ship_address2#<br></cfif>
			<cfif snap_ship_city NEQ "">#snap_ship_city#</cfif>, <cfif snap_ship_state NEQ "">#snap_ship_state#</cfif> <cfif snap_ship_zip NEQ "">#snap_ship_zip#</cfif><br>
		<cfif order_note NEQ "">#Replace(HTMLEditFormat(order_note),chr(10),"<br>","ALL")#<cfelse><span class="sub">(no order note)</span></cfif></td>
		</tr>
	
			</cfoutput>
		
		</cfloop>
		
		<tr>
		<td colspan="3">&nbsp;</td>
		</tr>
		
		<tr class="contenthead">
		<td colspan="3" class="headertext">Items NOT in this UPS Group</td>
		</tr>
		
		<cfif InvItemsNOTInGroup.RecordCount EQ 0>
		
		<tr class="content">
		<td colspan="3" width="100%"><span class="alert">There are no items available to add.</span></td>
		</tr>
	
		</cfif>
	
		<cfloop query="InvItemsNOTInGroup">
		
			<cfquery name="FindOrderInfo" datasource="#application.DS#">
				SELECT ID AS this_order_ID, program_ID AS this_program_ID, order_number, snap_fname, snap_lname, snap_ship_company, snap_ship_fname, snap_ship_lname, snap_ship_address1, snap_ship_address2, snap_ship_city, snap_ship_state, snap_ship_zip, snap_phone, snap_email, order_note
				FROM #application.database#.order_info
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsNOTInGroup.order_ID#" maxlength="10">
					AND is_valid = 1
			</cfquery>
			<cfset this_program_ID = FindOrderInfo.this_program_ID>
			<cfset this_order_ID = FindOrderInfo.this_order_ID>
			<cfset order_number = HTMLEditFormat(FindOrderInfo.order_number)>
			<cfset snap_fname = HTMLEditFormat(FindOrderInfo.snap_fname)>
			<cfset snap_lname = HTMLEditFormat(FindOrderInfo.snap_lname)>
			<cfset snap_ship_company = HTMLEditFormat(FindOrderInfo.snap_ship_company)>
			<cfset snap_ship_fname = HTMLEditFormat(FindOrderInfo.snap_ship_fname)>
			<cfset snap_ship_lname = HTMLEditFormat(FindOrderInfo.snap_ship_lname)>
			<cfset snap_ship_address1 = HTMLEditFormat(FindOrderInfo.snap_ship_address1)>
			<cfset snap_ship_address2 = HTMLEditFormat(FindOrderInfo.snap_ship_address2)>
			<cfset snap_ship_city = HTMLEditFormat(FindOrderInfo.snap_ship_city)>
			<cfset snap_ship_state = HTMLEditFormat(FindOrderInfo.snap_ship_state)>
			<cfset snap_ship_zip = HTMLEditFormat(FindOrderInfo.snap_ship_zip)>
			<cfset snap_phone = HTMLEditFormat(FindOrderInfo.snap_phone)>
			<cfset snap_email = HTMLEditFormat(FindOrderInfo.snap_email)>
			<cfset order_note = HTMLEditFormat(FindOrderInfo.order_note)>
								
			<cfquery name="MultiProdCheck" datasource="#application.DS#">
				SELECT product_ID
				FROM #application.database#.inventory
				WHERE is_valid = 1 
					AND quantity <> 0 
					AND snap_is_dropshipped = 0 
					AND order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsNOTInGroup.order_ID#"> 
					AND ship_date IS NULL
					AND po_ID = 0
					AND po_rec_date IS NULL
					AND upsgroup_ID IS NULL
			</cfquery>
			
			<cfoutput>
	
		<tr class="content" valign="top">
		<td><a href="#CurrentPage#?pgfn=manage_prod&add_prod=#InvItemsNOTInGroup.inventory_ID#&upsgroup_ID=#upsgroup_ID#&xT=#xT#&xTD=#xTD#&xFD=#xFD#&cri_Admin=#cri_Admin#&OnPage=#OnPage#">ADD</a></td>
		<td valign="top">
		<cfif MultiProdCheck.RecordCount GT 1><span class="alert">This is a multi-item order.</span><br></cfif>
			QTY: #InvItemsNOTInGroup.quantity#<br>
			#FLITC_GetProgramName(FindOrderInfo.this_program_ID)# Order #order_number#<br>
			<cfif snap_fname NEQ "">#snap_fname#</cfif> <cfif snap_lname NEQ "">#snap_lname#<br></cfif>
			<cfif snap_phone NEQ "">Phone: #snap_phone#<br></cfif>
			<cfif snap_email NEQ "">Email: #snap_email#<br></cfif>
		</td>
		<td valign="top">
			<cfif snap_ship_company NEQ "">#snap_ship_company#<br></cfif>
			<cfif snap_ship_fname NEQ "">#snap_ship_fname#</cfif> <cfif snap_ship_lname NEQ "">#snap_ship_lname#</cfif><br>
			<cfif snap_ship_address1 NEQ "">#snap_ship_address1#<br></cfif>
			<cfif snap_ship_address2 NEQ "">#snap_ship_address2#<br></cfif>
			<cfif snap_ship_city NEQ "">#snap_ship_city#</cfif>, <cfif snap_ship_state NEQ "">#snap_ship_state#</cfif> <cfif snap_ship_zip NEQ "">#snap_ship_zip#</cfif><br>
		<cfif order_note NEQ "">#Replace(HTMLEditFormat(order_note),chr(10),"<br>","ALL")#<cfelse><span class="sub">(no order note)</span></cfif></td>
		</tr>
	
			</cfoutput>
		
		</cfloop>
		
		
		<cfoutput>
		
		</cfoutput>
		
		</table>
			
	<!--- END pgfn MANAGE PRODUCTS --->
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->