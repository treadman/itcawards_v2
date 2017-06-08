<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000017,true)>

<cfset error = "">
<cfparam name="po_ID" default="">
<cfif NOT isNumeric(po_ID)>
	<cfset error = "Invalid PO Number">
	<cfset po_ID = 0>
</cfif>

<cfinclude template="includes/header_lite.cfm">

<cfif error NEQ "">
	<cfoutput>#error#</cfoutput>
<cfelse>
	<!--- get po info --->
	<cfquery name="GetPOInfo" datasource="#application.DS#">
		SELECT vendor_ID, snap_vendor, snap_attention, snap_phone, snap_fax, is_dropship, po_rec_date, itc_name, itc_phone, itc_fax, itc_email, po_printed_note, Date_Format(created_datetime,'%c/%d/%Y') AS created_date   
		FROM #application.database#.purchase_order 
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#po_ID#" maxlength="10">
	</cfquery>
<cfif GetPOInfo.recordcount NEQ 1>
	PO not found!
<cfelse>
<table cellpadding="0" cellspacing="0" border="0" width="593" align="center">
<tr>
	<td colspan="4" align="left"><img src="../pics/itclogo.jpg" width="794" height="149"></td>
</tr>
<tr>
	<td colspan="4" align="left">
		<table cellspacing="0" cellpadding="6" width="593" style="border:2px solid #000000;">
		<cfoutput>
		<tr>
			<td align="left" width="297" class="printhead" style="border-bottom:2px solid ##000000">Purchase Order</td>
			<td align="right" width="296" class="printlabel" style="border-bottom:2px solid ##000000;border-left:2px solid ##000000">#GetPOInfo.created_date#</td>
		</tr>
		<tr>
		<td align="left" width="297" valign="top" class="printlabel">
			For: #GetPOInfo.snap_vendor#<br /><br />
			Attn: #GetPOInfo.snap_attention#<br /><br />
			Phone: #GetPOInfo.snap_phone#<br /><br />
			Fax: #GetPOInfo.snap_fax#
		</td>
		<td align=left width=296 valign="top" class="printlabel" style="border-left:2px solid ##000000">
			From: #GetPOInfo.itc_name#<br /><br />
			Phone: #GetPOInfo.itc_phone#<br /><br />
			Fax: #GetPOInfo.itc_fax#<br /><br />
			Email: #GetPOInfo.itc_email#
		</td>
		</tr>
		</cfoutput>
		</table>
	</td>
</tr>
<tr>
	<td colspan="4" align=center height=10>&nbsp;</td>
</tr>
<tr>
	<td colspan="4" align="center" class="printlabel">Purchase Order <cfoutput>#RemoveChars(po_ID,1,5)#</cfoutput></td>
</tr>
<tr>
	<td colspan="4" align="center" height="20">&nbsp;</td>
</tr>
<cfquery name="GetPOInvItems" datasource="#application.DS#">
	SELECT <cfif GetPOInfo.is_dropship EQ 1>quantity<cfelse>po_quantity</cfif> AS qty, snap_meta_name, snap_description, snap_sku, snap_vendor_sku, snap_sku, snap_options, snap_productvalue , order_ID, ID AS inventory_ID, product_ID 
	FROM #application.database#.inventory
	WHERE po_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#po_ID#" maxlength="10"> 
		AND is_valid = 1 
	ORDER BY product_ID
</cfquery>
<cfset old_product_id = "">
<cfset old_ship_to = "FIRST_TIME">
<cfset old_forward_to = "FIRST_TIME">
<cfloop query="GetPOInvItems">
	<!--- need to get the pack size/desc, min qty, and min order $ --->
	<cfquery name="ProdVenLkup" datasource="#application.DS#">
		SELECT is_default, vendor_sku, vendor_cost, vendor_min_qty, pack_size, pack_desc 
		FROM #application.product_database#.vendor_lookup 
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#product_ID#" maxlength="10"> 
		AND vendor_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetPOInfo.vendor_ID#" maxlength="10"> 
	</cfquery>
	<cfif GetPOInfo.is_dropship EQ 1>
		<!--- find the shipto address --->
		<cfquery name="OrderInfo" datasource="#application.DS#">
			SELECT created_user_ID, snap_ship_fname, snap_ship_lname, snap_ship_address1, snap_ship_address2, 
				snap_ship_city, snap_ship_state, snap_ship_zip, snap_phone 
			FROM #application.database#.order_info
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
		</cfquery>
		<cfquery name="UserForwarding" datasource="#application.DS#">
			SELECT
				u.ID,
				IFNULL(f.ID,0) AS forwarding_ID,
				f.company,
				f.address1,
				f.address2,
				f.city,
				f.state,
				f.zip,
				f.country,
				f.phone
			FROM #application.database#.program_user u
			LEFT JOIN #application.database#.forwarding_address f ON f.ID = u.forwarding_ID AND f.program_ID = u.program_ID
			WHERE u.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#OrderInfo.created_user_ID#">
		</cfquery>
		<cfset hasForwarding = false>
		<cfif UserForwarding.recordcount eq 1 AND UserForwarding.forwarding_ID gt 0>
			<cfset hasForwarding = true>
		</cfif>
		<cfif hasForwarding>
			<cfset this_ship_to = "#UserForwarding.company#<br>#UserForwarding.address1#<br>">
			<cfif UserForwarding.address2 NEQ ""><cfset this_ship_to = this_ship_to & "#UserForwarding.address2#<br>"></cfif>
			<cfset this_ship_to = this_ship_to & "#UserForwarding.city#, #UserForwarding.state# #UserForwarding.zip#<br>#UserForwarding.phone#">
			<cfset this_forward_to = "#OrderInfo.snap_ship_fname# #OrderInfo.snap_ship_lname#<br>#OrderInfo.snap_ship_address1#<br>">
			<cfif OrderInfo.snap_ship_address2 NEQ ""><cfset this_forward_to = this_forward_to & "#OrderInfo.snap_ship_address2#<br>"></cfif>
			<cfset this_forward_to = this_forward_to & "#OrderInfo.snap_ship_city#, #OrderInfo.snap_ship_state# #OrderInfo.snap_ship_zip#<br>#OrderInfo.snap_phone#">
		<cfelse>
			<cfset this_ship_to = "#OrderInfo.snap_ship_fname# #OrderInfo.snap_ship_lname#<br>#OrderInfo.snap_ship_address1#<br>">
			<cfif OrderInfo.snap_ship_address2 NEQ ""><cfset this_ship_to = this_ship_to & "#OrderInfo.snap_ship_address2#<br>"></cfif>
			<cfset this_ship_to = this_ship_to & "#OrderInfo.snap_ship_city#, #OrderInfo.snap_ship_state# #OrderInfo.snap_ship_zip#<br>#OrderInfo.snap_phone#">
			<cfset this_forward_to = "">
		</cfif>
		<cfif old_ship_to NEQ "FIRST_TIME" AND (old_ship_to NEQ this_ship_to OR old_forward_to NEQ this_forward_to)>
			<tr>
				<td class="printtext" align="right" valign="top">SHIP TO:&nbsp;&nbsp;&nbsp;</td>
				<td valign="top">
					<cfoutput>#old_ship_to#</cfoutput>
					<cfif old_forward_to EQ "">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					</cfif>
				</td>
				<td class="printtext" align="right" valign="top">SHIP TO:&nbsp;&nbsp;&nbsp;</td>
					<cfif old_forward_to NEQ "">
						FWD TO:
					</cfif>
				</td>
				<td valign="top">
					<cfif old_forward_to NEQ "">
						<cfoutput>#old_forward_to#</cfoutput>
					</cfif>
				</td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
		</cfif>
		<cfset old_ship_to = this_ship_to>
		<cfset old_forward_to = this_forward_to>
	</cfif>
	<!---<cfif old_product_id NEQ product_ID>--->
		<tr>
			<td colspan="4" class="printlabel"><cfoutput>#snap_meta_name# #snap_options#<cfif snap_vendor_sku NEQ ""><br><span class="printtext">Vendor SKU: #snap_vendor_sku#</span></cfif></cfoutput></td>
		</tr>
	<!---</cfif>--->
	<!--- if this prod has packs, make adjustment to qty --->
	<cfif ProdVenLkup.pack_size NEQ "">
		<cfset qty_display = "#qty / ProdVenLkup.pack_size# #ProdVenLkup.pack_desc#(s) (#qty# pieces)">
	<cfelse>
		<cfset qty_display = qty>
	</cfif>
	<tr>
		<td colspan="4" class="printtext" valign="top">Quantity: <cfoutput>#qty_display#</cfoutput></td>
	</tr>
	<tr>
		<td colspan="4" class="printtext" valign="top">Price: <cfoutput>#ProdVenLkup.vendor_cost#</cfoutput></td>
	</tr>
	
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<cfset old_product_id = product_ID>
</cfloop>
<tr>
	<td class="printtext" align="right" valign="top">SHIP TO:&nbsp;&nbsp;&nbsp;</td>
	<td valign="top">
		<cfif GetPOInfo.is_dropship EQ 0>
			ITC Specialty<br>Attn: Awards<br>13 Garfield Way<br>Newark, DE 19713
		<cfelse>
			<cfif old_ship_to NEQ "FIRST_TIME">
				<cfoutput>#old_ship_to#</cfoutput>
				<cfif old_forward_to EQ "">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</cfif>
			</cfif>
		</cfif>
	</td>
	<td class="printtext" align="right" valign="top">
		<cfif old_ship_to NEQ "FIRST_TIME" AND old_forward_to NEQ "">
			FWD TO:&nbsp;&nbsp;&nbsp;
		</cfif>
	</td>
	<td valign="top">
		<cfif old_ship_to NEQ "FIRST_TIME" AND old_forward_to NEQ "">
			<cfoutput>#old_forward_to#</cfoutput>
		</cfif>
	</td>
</tr>
<tr>
	<td colspan="4">&nbsp;</td>
</tr>
<cfquery name="FindVendor" datasource="#application.DS#">
	SELECT what_terms   
	FROM #application.product_database#.vendor 
	WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetPOInfo.vendor_ID#" maxlength="10">
</cfquery>
<cfset what_terms = HTMLEditFormat(FindVendor.what_terms)>
<tr>
	<td colspan="4" align="left" class="printtext">
		<cfoutput>
		Terms: #what_terms#
		<cfif GetPOInfo.po_printed_note NEQ ''>
			<br><br>
			Note:<br>
			#Replace(HTMLEditFormat(GetPOInfo.po_printed_note),chr(10),"<br>","ALL")#
		</cfif>
		</cfoutput>
		<br><br>
		Thank you
	</td>
</tr>
</table>
</cfif>
</cfif>
<cfinclude template="includes/footer.cfm">
