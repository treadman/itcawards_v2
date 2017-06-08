<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000038,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="FromDate" default="">
<cfparam name="ToDate" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">
<cfparam name="sort_by" default="vendor">
<cfparam name="group_by" default="vendor">

<!--- all, range --->
<!---<cfparam name="vendor_filter" default="range">
<cfparam name="po_filter" default="range">--->

<!--- created, po_rcvd, drop --->
<cfparam name="range_filter" default="po_created">



<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "report_vendor">
<cfset request.main_width = "1100">
<cfinclude template="includes/header.cfm">

<cfoutput>
<span class="pagetitle">Vendor Report</span>
<br /><br />
<span class="pageinstructions">Leave the dates blank to see vendor data for all time.</span>
<br /><br />
<form action="#CurrentPage#" method="post">
	<!--- search box (START) --->
	<table cellpadding="4" cellspacing="0" border="0" width="55%">
		<tr class="contenthead">
			<td colspan="3"><span class="headertext">Generate Report</span></td>
		</tr>
		<tr>
			<td class="content" align="right">
				Date for Range: <select name="range_filter">
					<option value="po_created"<cfif range_filter EQ "po_created"> selected</cfif>>PO Created Date</option>
					<option value="inv_created"<cfif range_filter EQ "inv_created"> selected</cfif>>Item Created Date</option>
					<option value="drop"<cfif range_filter EQ "drop"> selected</cfif>>Drop Date</option>
					<option value="po_rcvd"<cfif range_filter EQ "po_rcvd"> selected</cfif>>PO Received</option>
				</select>
			</td>
			<td class="content" align="right">From Date: </td>
			<td class="content" align="left"><input type="text" name="FromDate" value="#FromDate#" size="12"></td>
		</tr>
		<tr>
			<td class="content" align="right">
				Sort By: <select name="sort_by">
					<option value="vendor"<cfif sort_by EQ "vendor"> selected</cfif>>Vendor</option>
					<option value="date"<cfif sort_by EQ "date"> selected</cfif>>Date</option>
					<option value="sku"<cfif sort_by EQ "sku"> selected</cfif>>ITC SKU</option>
					<option value="name"<cfif sort_by EQ "name"> selected</cfif>>Product Name</option>
				</select>
			</td>
			<td class="content" align="right">To Date:</td>
			<td class="content" align="left"><input type="text" name="ToDate" value="#ToDate#" size="12"></td>
		</tr>
		<!---<tr>
			<td class="content" align="right">
				group by: <select name="group_by">
					<option value="vendor"<cfif group_by EQ "vendor"> selected</cfif>>Vendor</option>
					<!---<option value="product"<cfif group_by EQ "product"> selected</cfif>>Product</option>--->
				</select>
				<!---Vendors: <select name="vendor_filter">
					<option value="range"<cfif vendor_filter EQ "range"> selected</cfif>>Only with POs in Date Range</option>
					<option value="all"<cfif vendor_filter EQ "all"> selected</cfif>>Show All</option>
				</select>--->
			</td>
			<td class="content" colspan="2"></td>
		</tr>--->
		<tr class="content">
			<td colspan="3" align="center"><input type="submit" name="show_report" value="  Generate Report  "></td>
		</tr>
	</table>
</form>
<!--- search box (END) --->
</cfoutput>
<br /><br />
	
<!--- **************** --->
<!--- if survey report --->
<!--- **************** --->
	
<cfif IsDefined('form.show_report')>
	<cfif FromDate NEQ "">
		<cfset formatFromDate = FLGen_DateTimeToMySQL(FromDate)>
	</cfif>	
	<cfif ToDate NEQ "">
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
	</cfif>
	<cfset this_range = "">
	<cfif range_filter EQ "inv_created">
		<cfset this_range = "i.created_datetime">
	<cfelseif range_filter EQ "po_created">
		<cfset this_range = "po.created_datetime">
	<cfelseif range_filter EQ "po_rcvd">
		<cfset this_range = "i.po_rec_date">
	<cfelseif range_filter EQ "drop">
		<cfset this_range = "i.drop_date">
	</cfif>
	<cfif sort_by EQ "sku">
		<cfset this_sort = "i.snap_sku">
	<cfelseif sort_by EQ "name">
		<cfset this_sort = "i.snap_meta_name">
	<cfelseif sort_by EQ "vendor">
		<cfset this_sort = "v.vendor, " & this_range>
	<cfelseif sort_by EQ "date">
		<cfif range_filter EQ "inv_created">
			<cfset this_sort = "i.created_datetime">
		<cfelseif range_filter EQ "po_created">
			<cfset this_sort = "po.created_datetime">
		<cfelseif range_filter EQ "po_rcvd">
			<cfset this_sort = "i.po_rec_date">
		<cfelseif range_filter EQ "drop">
			<cfset this_sort = "i.drop_date">
		</cfif>
	</cfif>
	<cfquery name="getProducts" datasource="#application.DS#">
		SELECT
			i.vendor_ID,
			i.snap_vendor AS vendor,
			v.vendor AS vendor2,
			i.po_quantity,
			i.quantity,
			## Note that the cost is associated to the product, not the purchase order:
			IFNULL(l.vendor_cost,0) AS cost,
			i.snap_meta_name as product1,
			i.snap_sku,
			pm.meta_name as product2,
			CAST(i.po_rec_date AS DATE) AS po_received, 
			CAST(i.drop_date AS DATE) AS drop_date,
			CAST(i.created_datetime AS DATE) AS inv_created_date,
			CAST(po.created_datetime AS DATE) AS po_created_date,
			IFNULL(po.is_dropship,0) AS is_dropship
		FROM #application.database#.vendor v
		LEFT JOIN #application.product_database#.purchase_order po ON v.ID = po.vendor_ID
		LEFT JOIN #application.database#.inventory i on po.ID = i.po_ID
		LEFT JOIN #application.database#.vendor_lookup l ON l.product_ID = i.product_ID AND l.vendor_ID = po.vendor_ID
		LEFT JOIN #application.product_database#.product p on p.ID = i.product_ID
		LEFT JOIN #application.product_database#.product_meta pm on pm.ID = p.product_meta_ID
		WHERE i.po_ID > 0
		AND ( i.po_quantity > 0 OR i.quantity > 0 )
		<cfif formatFromDate NEQ "">
			AND #this_range# >= '#formatFromDate#' 
		</cfif>	
		<cfif formatToDate NEQ "">
			AND #this_range# <= '#formatToDate#' 
		</cfif>	
		AND i.is_valid = 1
		ORDER BY #this_sort#
	</cfquery>
	<!---<cfdump var="#getProducts#">---> 
	<p class="page_instructions"><cfoutput>#getProducts.RecordCount#</cfoutput> item<cfif getProducts.RecordCount GT 1>s</cfif> found.</p>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<!--- header row --->
		<tr valign="top" class="contenthead">
			<td class="headertext">Vendor</td>
			<td class="headertext" align="right">SKU</td>
			<td class="headertext">Product</td>
			<td class="headertext" align="right">Quantity</td>
			<td class="headertext" align="right">Item Cost</td>
			<td class="headertext" align="right">Total Cost</td>
			<td class="headertext" align="center">Item Created</td>
			<td class="headertext" align="center">PO Created</td>
			<td class="headertext" align="center">Drop Date</td>
			<td class="headertext" align="center">PO Rcvd</td>
		</tr>
		<cfif getProducts.RecordCount EQ 0>
			<tr class="content2">
				<td colspan="5" align="center" class="alert"><br>There are no results to display.<br><br></td>
			</tr>
		<cfelse>
			<cfset QueryAddRow(getProducts,1)>
			<cfset QuerySetCell(getProducts,group_by,'LAST_TIME')>
			<cfset grand_total = 0>
			<cfset sub_total = 0>
			<cfset old_sub = "FIRST_TIME">
			<cfset old_name = "">
			<cfset toggle = "2">
			<cfoutput query="getProducts">
				<cfif isBoolean(getProducts.is_dropship) AND getProducts.is_dropship>
					<cfset this_quantity = quantity>
				<cfelse>
					<cfset this_quantity = po_quantity>
				</cfif>
				<cfif toggle EQ "">
					<cfset toggle = "2">
				<cfelse>
					<cfset toggle = "">
				</cfif>
				<cfif old_sub NEQ getProducts.vendor_ID>
					<cfif old_sub NEQ "FIRST_TIME">
						<tr class=""><td colspan="5" align="right">Total for <b>#old_name#:</b></td><td align="right"><b>#NumberFormat(sub_total,'0.00')#</b></td></tr>
						<tr><td></td></tr>
						<cfset sub_total = 0>
						<cfset toggle = "">
						<cfif getProducts.vendor EQ "LAST_TIME">
							<tr class=""><td colspan="5" align="right"><b>Grand Total:</b></td><td align="right"><b>#NumberFormat(grand_total,'0.00')#</b></td></tr>
						</cfif>
					</cfif>
					<!---<tr class=""><td align="right">#group_by#:</td><td colspan="6">#getProducts.vendor#</td></tr>--->
				</cfif>
				<cfif getProducts.vendor NEQ "LAST_TIME">
					<cfset this_total = this_quantity * cost>
					<tr class="content#toggle#">
						<td>#vendor#<cfif trim(Replace(vendor2,"(DROPSHIP)","")) NEQ trim(Replace(vendor,"(DROPSHIP)",""))><br><span class="sub">#vendor2#</span></cfif></td>
						<td align="right">#snap_sku#</td>
						<td>#product1#<cfif trim(product2) NEQ trim(product1)><br><span class="sub">#product2#</span></cfif></td>
						<td align="right">#this_quantity#</td>
						<td align="right">#cost#</td>
						<td align="right">#NumberFormat(this_total,'0.00')#</td>
						<td align="right">#DateFormat(inv_created_date,"mm/dd/yyyy")#</td>
						<td align="right">#DateFormat(po_created_date,"mm/dd/yyyy")#</td>
						<td align="right">#DateFormat(drop_date,"mm/dd/yyyy")#</td>
						<td align="right">#DateFormat(po_received,"mm/dd/yyyy")#</td>
					</tr>
					<cfif isNumeric(cost)>
						<cfset grand_total = grand_total + this_total>
						<cfset sub_total = sub_total + this_total>
					</cfif>
					<cfset old_name = getProducts.vendor>
					<cfset old_sub = getProducts.vendor_ID>
				</cfif>
			</cfoutput>
		</cfif>
	</table>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->
<!---
------------------------------
purchase_order:
------------------------------
Date created
Date po rec (received?)

vendor_id  (FK)
snap_* vendor info (if different now)
dropship

itc_* ITC info (admin input)

printed note
hidden note

------------------------------
vendor:
------------------------------
Date created
is dropshipper
Terms
Min order
vendor info
notes

------------------------------
vendor_lookup:
------------------------------
Date created

vendor_id (FK)
product_ID (FK) option or meta?
vendor details about the product
is_default?


------------------------------
inventory:
------------------------------
Date created

product_ID (FK) option or meta?

Orders
	order_ID (FK)
	is valid
Shipping
	ship date
	tracking
	ups_group_ID
POs
	po_ID (FK)
	po_quantity
	po_rec_date (matches po?)
	
	
snap_* product info
snap_* vendor info




------------------------------
------------------------------

--->