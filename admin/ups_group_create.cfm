<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000017,true)>

<cfset alert_msg = "">

<cfif IsDefined('form.fieldnames') AND form.fieldnames CONTAINS "SubmitButton">

	<cfif form.fieldnames DOES NOT CONTAIN "inv_">
		<cfset alert_msg = "You must select at least one order to be included in the UPS Group.">
		<cfset item = product_ID>
	<cfelse>
		<cflock name="ups_groupLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#">
					INSERT INTO #application.database#.ups_group
						(created_user_ID, created_datetime, product_ID)
					VALUES
						(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">, '#FLGen_DateTimeToMySQL()#', 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.product_ID#">)
				</cfquery>
				<cfquery name="getID" datasource="#application.DS#">
					SELECT Max(ID) As MaxID FROM #application.database#.ups_group
				</cfquery>
				<cfset UPS_Group_ID = getID.MaxID>
			</cftransaction>  
		</cflock>
		<cfloop list="#Form.FieldNames#" index="ThisFieldName">
			<cfif ThisFieldName contains "inv_" AND Evaluate(ThisFieldName) NEQ ''>
				<cfset ThisID = RemoveChars(ThisFieldName,1,4)>
	
				<cfquery name="UpdateInvItem" datasource="#application.DS#">
					UPDATE #application.database#.inventory
					SET	upsgroup_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#UPS_Group_ID#">
						#FLGen_UpdateModConcatSQL()#
						WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ThisID#">
				</cfquery>
	
			</cfif>
		</cfloop>
		<cflocation addtoken="no" url="ups_group_list.cfm">
	</cfif>
</cfif>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Create UPS Group</span>
<br /><br />

<span class="pageinstructions">Return to <a href="report_fulfillment.cfm">Ship From ITC</a> without making changes.</span>
<br /><br />
<!--- <span class="pageinstructions">Open <a href="report_fulfillment_print.cfm" target="_blank">printable</a> list.</span>
<br /><br />
 --->
<cfquery name="SelectProdCount" datasource="#application.DS#">
	SELECT COUNT(product_ID) AS NumberToShip
	FROM #application.database#.inventory
	WHERE is_valid = 1 
		AND quantity <> 0 
		AND snap_is_dropshipped = 0 
		AND order_ID <> 0 
		AND ship_date IS NULL
		AND po_ID = 0
		AND po_rec_date IS NULL
		AND upsgroup_ID IS NULL
		AND product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#">
</cfquery>

<cfoutput>#PhysicalInvCalc(item)#</cfoutput>
	
<cfif PIC_total_physical LT SelectProdCount.NumberToShip>
	<cfset alert_msg = "There are #PIC_total_physical# in stock and #SelectProdCount.NumberToShip# to be shipped">
</cfif>

<cfquery name="SelectOrders" datasource="#application.DS#">
	SELECT inv.ID AS inventory_ID, inv.order_ID, ord.program_ID, inv.quantity
	FROM #application.database#.inventory inv
	JOIN #application.database#.order_info ord ON inv.order_ID = ord.ID
	WHERE inv.is_valid = 1 
		AND inv.quantity <> 0 
		AND inv.snap_is_dropshipped = 0 
		AND inv.order_ID <> 0 
		AND inv.ship_date IS NULL
		AND inv.po_ID = 0
		AND inv.po_rec_date IS NULL
		AND inv.upsgroup_ID IS NULL
		AND inv.product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#">
	ORDER BY inv.created_datetime
</cfquery>	

<cfquery name="SelectProdInfo" datasource="#application.DS#">
	SELECT meta.meta_name, prod.sku, pval.productvalue, prod.ID AS individual_ID, 
			IF((SELECT COUNT(*) FROM #application.product_database#.product_meta_option_category pm WHERE meta.ID = pm.product_meta_ID)=0,"false","true") AS has_options
	FROM #application.product_database#.product_meta meta
	JOIN #application.product_database#.product prod ON prod.product_meta_ID = meta.ID 
	JOIN #application.product_database#.productvalue_master pval ON pval.ID = meta.productvalue_master_ID
	WHERE prod.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#item#"> 
</cfquery>

<cfset these_options = "">
<cfif SelectProdInfo.has_options>
	<cfquery name="FindProductOptionInfo" datasource="#application.DS#">
		SELECT pmoc.category_name AS category_name, pmo.option_name AS option_name
		FROM #application.product_database#.product_meta_option_category pmoc
		JOIN #application.product_database#.product_meta_option pmo ON pmoc.ID = pmo.product_meta_option_category_ID 
		JOIN #application.product_database#.product_option po ON pmo.ID = po.product_meta_option_ID
		WHERE po.product_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#item#"> 
		ORDER BY pmoc.sortorder
	</cfquery>
	<cfloop query="FindProductOptionInfo">
		<cfset these_options = these_options & "  [#category_name#: #option_name#] ">
	</cfloop>
	<cfset these_options = Trim(these_options)>
</cfif>

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		
	<cfoutput>
	<tr class="contenthead">
	<td colspan="3">New UPS Group:<br><b>#DateFormat(Now(),'mm/dd/yyyy')# [#TimeFormat(Now(),'HH:mm')#] SKU:#SelectProdInfo.sku# #SelectProdInfo.meta_name#</b></td>
	</tr>
	
	<tr class="content2">
	<td colspan="3"><cfif PIC_total_physical LT SelectOrders.RecordCount><span class="alert">IMPORTANT: </span></cfif><b>#PIC_total_physical#</b> Available in Physical Inventory</td>
	</tr>
	</cfoutput>
	
	<form action="<cfoutput>#CurrentPage#</cfoutput>" method="post">
					
	<tr class="content">
	<td colspan="3" align="center"><input type="submit" value="Save New UPS Group" name="SubmitButton1"></td>
	</tr>

	<cfloop query="SelectOrders">
		
		<cfquery name="FindOrderInfo" datasource="#application.DS#">
			SELECT ID AS this_order_ID, program_ID AS this_program_ID, order_number, snap_fname, snap_lname, snap_ship_company, snap_ship_fname, snap_ship_lname, snap_ship_address1, snap_ship_address2, snap_ship_city, snap_ship_state, snap_ship_zip, snap_phone, snap_email, order_note
			FROM #application.database#.order_info
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectOrders.order_ID#" maxlength="10">
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
				AND order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectOrders.order_ID#"> 
				AND ship_date IS NULL
				AND po_ID = 0
				AND po_rec_date IS NULL
				AND upsgroup_ID IS NULL
		</cfquery>
		
<cfoutput>

	<tr class="content" valign="top">
	<td><input type="checkbox" name="inv_#inventory_ID#" checked="checked"> include</td>
	<td valign="top">
	<cfif MultiProdCheck.RecordCount GT 1><span class="alert">This is a multi-item order.</span><br></cfif>
		QTY: #SelectOrders.quantity#<br>
		#FLITC_GetProgramName(FindOrderInfo.this_program_ID)# Order #order_number#<br>
		<cfif snap_fname NEQ "">#snap_fname#</cfif> <cfif snap_lname NEQ "">#snap_lname#<br></cfif>
		<cfif snap_phone NEQ "">Phone: #snap_phone#<br></cfif>
		<cfif snap_email NEQ "">Email: #snap_email#<br></cfif>
	</td>
	<td valign="top">
		<a href="order_ship.cfm?shipID=#SelectOrders.order_ID#&back=ups_group&item=#item#">SHIP TO</a><br>
		<cfif snap_ship_company NEQ "">#snap_ship_company#<br></cfif>
		<cfif snap_ship_fname NEQ "">#snap_ship_fname#</cfif> <cfif snap_ship_lname NEQ "">#snap_ship_lname#</cfif><br>
		<cfif snap_ship_address1 NEQ "">#snap_ship_address1#<br></cfif>
		<cfif snap_ship_address2 NEQ "">#snap_ship_address2#<br></cfif>
		<cfif snap_ship_city NEQ "">#snap_ship_city#</cfif>, <cfif snap_ship_state NEQ "">#snap_ship_state#</cfif> <cfif snap_ship_zip NEQ "">#snap_ship_zip#</cfif><br>
	<cfif order_note NEQ "">#Replace(HTMLEditFormat(order_note),chr(10),"<br>","ALL")#<cfelse><span class="sub">(no order note)</span></cfif></td>
	</tr>

</cfoutput>

	</cfloop>

	<tr class="content">
	<td colspan="3" align="center">
		<input type="hidden" value="<cfoutput>#item#</cfoutput>" name="product_ID">
		<input type="submit" value="Save New UPS Group" name="SubmitButton2">
	</td>
	</tr>

	</form>
	
	</table>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->