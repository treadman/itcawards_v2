<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000017,true)>

<!--- ************************************ --->
<!--- get report info                      --->
<!--- ************************************ --->

<cfset alert_msg = "">

<cfset FF_prodphyslist = "">
<cfset FF_prodORDlist = "">
<cfset multi_prod_orders = "">
					<cfset found_one = "no">

<!--- get a distinct list of all the ordered products that are not shipped yet ordered by product value --->
<cfquery name="SelectDistinctProducts" datasource="#application.DS#">
	SELECT DISTINCT product_ID
	FROM #application.database#.inventory
	WHERE is_valid = 1 
		AND quantity <> 0 
		AND snap_is_dropshipped = 0 
		AND order_ID <> 0 
		AND ship_date IS NULL
		AND po_ID = 0
		AND po_rec_date IS NULL
	ORDER BY snap_productvalue 
</cfquery>

<!--- loop through the list and calc the physical inventory --->
<cfloop query="SelectDistinctProducts">
	<cfset thisDistinctProduct = SelectDistinctProducts.product_ID>
	<cfoutput>#PhysicalInvCalc(thisDistinctProduct)#</cfoutput>
	
	<!--- if the physical inventory is gt 0, add to productID_physicalInventory list --->
	<cfif PIC_total_physical gt 0>
		<cfset FF_prodphyslist = ListAppend(FF_prodphyslist,thisDistinctProduct & "_" & PIC_total_physical)>
	</cfif>
</cfloop>
<cfif FF_prodphyslist EQ "">
	<cfset alert_msg = "There are no products waiting to be shipped from ITC">
</cfif>
<!--- loop through the product list and select #physical_total# orders and create list of productID_orderID pairs --->
<cfif FF_prodphyslist NEQ "">
	<cfloop list="#FF_prodphyslist#" index="giraffe">
		<cfset giraffe_product_ID = ListGetAt(giraffe,1,"_")>
		<cfset giraffe_physicaltotal = ListGetAt(giraffe,2,"_")>

		<cfquery name="SelectOrderID" datasource="#application.DS#" maxrows="#giraffe_physicaltotal#">
			SELECT inv.order_ID, ord.program_ID, inv.quantity
			FROM #application.database#.inventory inv
			JOIN #application.database#.order_info ord ON inv.order_ID = ord.ID
			WHERE inv.is_valid = 1 
				AND inv.quantity <> 0 
				AND inv.snap_is_dropshipped = 0 
				AND inv.order_ID <> 0 
				AND inv.ship_date IS NULL
				AND inv.po_ID = 0
				AND inv.po_rec_date IS NULL
				AND inv.product_ID = #giraffe_product_ID#
			ORDER BY inv.created_datetime
		</cfquery>
		
		<cfset giraffe_qty_counter = 0>
		<cfloop query="SelectOrderID">
		<cfset giraffe_qty_counter = giraffe_qty_counter + SelectOrderID.quantity>
			<cfif giraffe_qty_counter LTE giraffe_physicaltotal>
				<cfset FF_prodORDlist = FF_prodORDlist & "," & giraffe_product_ID & "_" & SelectOrderID.program_ID & "_ord" & SelectOrderID.order_ID & "_" & SelectOrderID.quantity>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfloop>
	<cfif FF_prodORDlist NEQ "">
		<cfset FF_prodORDlist = RemoveChars(FF_prodORDlist,1,1)>
		<cfset FF_prodORDlist = ListSort(FF_prodORDlist,'text')>
	</cfif>
</cfif>
		
<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfinclude template="includes/header_lite.cfm">

	<!--- total user for this program --->
	<cfquery name="AllUsers" datasource="#application.DS#">
		SELECT username, IFNULL(fname,"&nbsp;") AS fname, IFNULL(lname,"&nbsp;") AS lname, IFNULL(email,"&nbsp;") AS email, ID AS user_ID
		FROM #application.database#.program_user
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
	</cfquery>

	<table cellpadding="5" cellspacing="0" border="1" width="90%" align="center">
	
			<tr>
			<td colspan="4" class="printlabel">I T C&nbsp;&nbsp;&nbsp;A W A R D S&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;
P O T E N T I A L&nbsp;&nbsp;&nbsp;O R D E R&nbsp;&nbsp;&nbsp;M A K E R S</td>
			</tr>
			
		<cfoutput>
		
			<tr class="printlabel">
			<td valign="top" class="printlabel" colspan="4" >Program: #FLITC_GetProgramName(program_ID)#</td>
			</tr>
			
			<tr>
			<td colspan="4" class="printbold">&nbsp;</td>
			</tr>
			
			<tr>
			<td class="printtext"><b>Points</b></td>
			<td class="printtext"><b>Userame</b></td>
			<td class="printtext"><b>Name</b></td>
			<td class="printtext"><b>Email</b></td>
			</tr>
			
		<cfloop query="AllUsers">
		
			<cfoutput>#ProgramUserInfo(user_ID)#</cfoutput>
			
			<cfif user_totalpoints NEQ 0>
			
			<tr>
			<td class="printtext">#user_totalpoints#</td>
			<td class="printtext">#username#</td>
			<td class="printtext">#fname# #lname#</td>
			<td class="printtext">#email#</td>
			</tr>
			
			</cfif>
			
		</cfloop>
			
		</cfoutput>

		
	</table>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->