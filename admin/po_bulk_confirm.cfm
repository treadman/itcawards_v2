<!--- function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000017,true)>

<cfparam name="alert_msg" default="">
<cfparam name="url.pgfn" default="home">

<cfparam name="confirm_date" default="#FLGen_DateTimeToDisplay()#">

<cfset do_it = false>
<cfif isDefined('form.doUpdate')>
	<cfset do_it = true>
	<cfset url.pgfn = "update">
</cfif>

<cfset thisFileName = "po_bulk_confirm">

<cfif IsDefined("form.submitUpload")>
	<cfif form.upload_txt NEQ "">
		<cfset result = FLGen_UploadThis("upload_txt","admin/upload/",thisFileName)>
		<cfif result EQ "false,false">
			<cfset alert_msg = "There was an error uploading the file.">
		<cfelse>
			<cfif right(ListLast(result),4) NEQ "xlsx">
				<cfset alert_msg = "That was not an xlsx file.">
			<cfelse>
				<cfset url.pgfn = "update">
			</cfif>
		</cfif>
		<cfif alert_msg NEQ "">
			<cfset url.pgfn = "upload">
		</cfif>
	</cfif>
</cfif>

<cfset leftnavon = "purchase_orders">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">
	Bulk Update to Dropship POs
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="<cfoutput>#CurrentPage#</cfoutput>">Start Over</a>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="po_list.cfm">Return to Purchase Order list</a>
</span>
<br /><br />

<cfif url.pgfn EQ "home">
	<cfset FLGen_DeleteThisFile("#thisFileName#.csv","admin/upload/")>
	<span class="pageinstructions">
		This is a bulk updater that will confirm all dropship purchase orders from a spreadsheet.<br /><br />
	</span>
	<span class="pageinstructions">
		The spreadsheet must be in XLSX format.<br /><br />
	</span>
	<span class="pageinstructions">
		The first row must be a header row.  The columns must be Date, PO Number, Tracking Number.<br />
	</span>
	<br /><br />
	<a href="<cfoutput>#CurrentPage#?pgfn=upload</cfoutput>" class="actionlink">Upload Spreadsheet</a>
<cfelseif url.pgfn EQ "upload">
	<span class="pagetitle">Upload the Spreadsheet</span>
	<br /><br />
	<cfoutput>
	<form method="post" action="#CurrentPage#" name="uploadSpreadsheet" enctype="multipart/form-data">
		<input name="upload_txt" type="file" size="48" value=""><br><br>
		<input type="submit" name="submitUpload" value="  Upload  " >
	</form>
	</cfoutput>
	</span>
<cfelseif url.pgfn EQ "update">
	<cfset hasFile = true>
	<cftry>
		<cfspreadsheet action="read" src="#application.FilePath#admin/upload/#thisFileName#.xlsx" query="po_update">
		<cfcatch><cfset hasFile = false></cfcatch>
	</cftry>
	<cfif NOT hasFile>
		<span class="pageinstructions">Sorry, but the data was lost.  You'll have to upload it again.</span>
	<cfelse>
		<cfoutput>
		<cfif NOT do_it OR NOT isValid("USdate",trim(confirm_date))>
			<form name="UpdateForm" method="post" action="#CurrentPage#">
				Confirmation/Shipment Date: <input type="text" name="confirm_date" maxlength="32" size="14" value="#confirm_date#">
				<input type="submit" name="doUpdate" value="Do Bulk Update" >
			</form>
		</cfif>
		<br>
		<cfif NOT isValid("USdate",trim(confirm_date))>
			<span class="alert">#confirm_date# is not a valid date!</span>
			<br>
			<cfset do_it = false>
		</cfif>
		<br>
		<cfloop query="po_update" startrow="2">
			<cfset po_ID = po_update.col_2 + 1000000000>
			<cfif po_ID LT 1000010000>
				<span class="alert">PO ## #po_update.col_2#??? Have the PO numbers gone from 99999 to 00000?!?  That's probably not good.  Call the developer.</span>
			<cfelse>
				PO## #po_update.col_2# (#po_update.col_1#):
				<cfquery name="GetPOInfo" datasource="#application.DS#">
					SELECT vendor_ID, snap_vendor, snap_attention, snap_phone, snap_fax, is_dropship, po_rec_date, itc_name, itc_phone, itc_fax, itc_email, po_printed_note, po_hidden_note, IFNULL(po_rec_date ,"") AS po_rec_date, Date_Format(created_datetime,'%c/%d/%Y') AS this_po_date, modified_concat  
					FROM #application.database#.purchase_order 
					WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#po_ID#">
				</cfquery>
				<cfif GetPOInfo.recordcount NEQ 1>
					<span class="alert">PO ## #po_update.col_2# was not found!</span>
				<cfelse>
					<cfif GetPOInfo.is_dropship EQ 1 AND GetPOInfo.po_rec_date EQ "">
						<cfquery name="GetPOInvItems" datasource="#application.DS#">
							SELECT <cfif GetPOInfo.is_dropship EQ 1>quantity<cfelse>po_quantity</cfif> AS qty, snap_meta_name, snap_description, snap_sku, snap_vendor_sku, snap_sku, snap_is_dropshipped, snap_options, snap_productvalue, order_ID, ID AS inventory_ID, product_ID, IFNULL(tracking,"") AS tracking
							FROM #application.database#.inventory
							WHERE po_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#po_ID#">
							AND is_valid = 1
							ORDER BY product_ID
						</cfquery>
						<cfif do_it>Updated<cfelse>Will update</cfif> with tracking ## #po_update.col_3#
						<cfloop query="GetPOInvItems">
							<cfif snap_is_dropshipped EQ 1 AND tracking EQ "">
								<cfif do_it>
									<cfset this_val = "">
									<cfif isDefined("form.inv_#inventory_ID#")>
										<cfset this_val = evaluate("form.inv_#inventory_ID#")>
									</cfif>
									<cfset this_mod_note = "QTY: #qty# CAT: #snap_productvalue# SKU: #HTMLEditFormat(snap_sku)# PRODUCT: #snap_meta_name#">
									<cfif snap_options NEQ "">
										<cfset this_mod_note = "#this_mod_note# #snap_options#">
									</cfif>
									<cfset mod_note = "(*auto* po dropshipment confirmation)"  & Chr(13) & Chr(10) & this_mod_note & Chr(13) & Chr(10) & "Tracking Number" & po_update.col_3>
									<cfquery name="ConDropItemQty" datasource="#application.DS#">
										UPDATE #application.database#.inventory
										SET tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(po_update.col_3)#" maxlength="32">, 
											po_rec_date = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#trim(confirm_date)#">
											#FLGen_UpdateModConcatSQL(mod_note)#
										WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetPOInvItems.inventory_ID#">
									</cfquery>
									<cfset user_name = FLGen_GetAdminName(FLGen_adminID)>
									<cfset mod_note = Replace(mod_note, "'","''","all")>
									<cfquery name="UpdateOrderInfo" datasource="#application.DS#">
										UPDATE #application.database#.order_info 
										SET modified_concat = concat(IF(modified_concat IS NULL,"",CONCAT(modified_concat,CHAR(13),CHAR(10),CHAR(13),CHAR(10))), '[#user_name# #FLGen_DateTimeToDisplay(showtime=true)#]'<cfif mod_note NEQ "">,CHAR(13),CHAR(10),'#mod_note# '</cfif>)
										WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetPOInvItems.order_ID#">
									</cfquery>
									<!--- check to see if all the items on the PO were dropshipped --->
									<cfquery name="AllDropped" datasource="#application.DS#">
										SELECT ID 
										FROM #application.database#.inventory
										WHERE po_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#po_ID#">
										AND po_rec_date IS NULL
									</cfquery>
									<cfif AllDropped.RecordCount EQ 0>
										<!--- update the po as received --->
										<cfset mod_note = "(*auto* all po items have been dropshipped)">
										<cfquery name="POdateconfirmed" datasource="#application.DS#">
											UPDATE #application.database#.purchase_order
											SET po_rec_date = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
												#FLGen_UpdateModConcatSQL(mod_note)#
											WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#po_ID#">
										</cfquery>
									</cfif>
									<!--- check to see if whole order(s) fulfilled --->
									<!--- find all orders associated with this PO --->
									<cfquery name="AllDroppedOrderID" datasource="#application.DS#">
										SELECT DISTINCT order_ID AS DROP_order_ID 
										FROM #application.database#.inventory
										WHERE po_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#po_ID#">
										AND po_rec_date IS NOT NULL
									</cfquery>
									<cfloop query="AllDroppedOrderID">
										<!--- check for UNSHIPPED // UNDROPSHIPPED --->
										<cfquery name="ItemsNotShipped" datasource="#application.DS#">
											SELECT ID AS ItemsNotOut
											FROM #application.database#.inventory
											WHERE is_valid = 1 
												AND quantity <> 0 
												AND snap_is_dropshipped = 0  
												AND order_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#DROP_order_ID#">
												AND ship_date IS NULL 
												AND po_ID = 0
												AND po_rec_date IS NULL 
							
											UNION
							
											SELECT ID AS ItemsNotOut
											FROM #application.database#.inventory
											WHERE is_valid = 1 
												AND quantity <> 0 
												AND snap_is_dropshipped = 1  
												AND order_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#DROP_order_ID#">
												AND ship_date IS NULL 
												AND po_ID = 0
												AND po_rec_date IS NULL
										</cfquery>
										<cfif ItemsNotShipped.RecordCount EQ 0>
											<!--- insert order mod note --->
											<cfset mod_note = "(*auto* order completely fulfilled #FLGen_DateTimeToDisplay()#)">
											<!--- if appro, mark is_all_shipped (I checked for unshipped and undropshipped items above) --->
											<cfquery name="UpdateOrderInfo" datasource="#application.DS#">
												UPDATE #application.database#.order_info 
												SET is_all_shipped = 1 
												#FLGen_UpdateModConcatSQL(mod_note)#
												WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#DROP_order_ID#">
											</cfquery>
										</cfif>
									</cfloop>
								</cfif>
							<cfelse>
								#tracking#
							</cfif>
						</cfloop>
					<cfelseif GetPOInfo.is_dropship EQ 1 AND GetPOInfo.po_rec_date NEQ "">
						All items already confirmed dropshipped as of #FLGen_DateTimeToDisplay(GetPOInfo.po_rec_date)#
					<cfelseif GetPOInfo.is_dropship EQ 0 AND GetPOInfo.po_rec_date EQ "">
						<span class="alert">PO ## #po_update.col_2# is not a dropship.</span>
					<cfelse>
						Inventory already received #FLGen_DateTimeToDisplay(GetPOInfo.po_rec_date)#
					</cfif>
				</cfif>
			</cfif>
			<br><br>
		</cfloop>
		</cfoutput>
	</cfif>
<cfelse>
	<cfoutput>
	#url.pgfn# is not set up.<br><br>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">
