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
<cfparam name="alert_msg" default="">

<!--- param a/e form fields --->
<cfparam name="package_type" default="Package">
<cfparam name="service_level" default="Ground">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>

<cftry>

	<cffile action="read" file="#application.AbsPath#admin/upload/ups_file.csv" variable="display_file">
	
	<cfif display_file EQ "" OR ListLen(display_file,chr(13) & chr(10)) EQ 1 OR ListLen(display_file,"#chr(13) & chr(10)#,") MOD 4 NEQ 0>
		<cfset alert_msg = "There was a problem with the import. [Error 1]">
		<cfset display_file = Replace(display_file,chr(13) & chr(10),"^","all")>
	<cfelse>
		
		<cfquery name="InvItemsInGroup" datasource="#application.DS#">
			SELECT inv.ID AS inventory_ID, inv.order_ID, inv.snap_sku, inv.quantity, inv.snap_productvalue, inv.snap_meta_name, inv.snap_options 
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
						 
		<cfset display_file = Replace(display_file,chr(13) & chr(10),"^","all")>
		<cfif InvItemsInGroup.RecordCount NEQ ListLen(display_file,"^,")/4 - 1 OR InvItemsInGroup.snap_sku NEQ ListGetAt(display_file,5,"^,")>
			<cfset alert_msg = "There was a problem with the import.  [Error 2]">
		<cfelse>
			<cfset order_numbers = "">
			<cfloop index="i" from="6" to="#ListLen(display_file,"^,")#" step="4">
				<cfset order_numbers = ListAppend(order_numbers,ListGetAt(display_file,i,"^,"))>
			</cfloop>
			<cfset group_order_numbers = ValueList(InvItemsInGroup.order_ID)>
			
			<cfset all_order_numbers_match = true>
			<cfloop list="#order_numbers#" index="i">
				<cfif group_order_numbers DOES NOT CONTAIN order_numbers>
					<cfset all_order_numbers_match = false>
				</cfif>
			</cfloop>

			<cfif NOT all_order_numbers_match>
				<cfset alert_msg = "There was a problem with the import.  [Error 3]">
			<cfelse>

<!--- BEGIN: IMPORT --->

				<cfset inventory_numbers = "">
				<cfloop index="i" from="7" to="#ListLen(display_file,"^,")#" step="4">
					<cfset inventory_numbers = ListAppend(inventory_numbers,ListGetAt(display_file,i,"^,"))>
				</cfloop>
				
				<cfoutput query="InvItemsInGroup">
					<cfset matching_csv_record_index = ListFindNoCase(inventory_numbers,inventory_ID) + 1>
					<cfset matching_csv_record = ListGetAt(display_file,matching_csv_record_index,"^")>
					<cfset matching_tracking = ListGetAt(matching_csv_record,4)>
					
					<cfquery name="MarkItemShipped" datasource="#application.DS#">
						UPDATE #application.database#.inventory 
						SET	ship_date = <cfqueryparam cfsqltype="cf_sql_date" value="#date_shipped#">, 
							tracking = <cfqueryparam cfsqltype="cf_sql_varchar" value="#matching_tracking#" maxlength="32">
						WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsInGroup.inventory_ID#">
					</cfquery>

					<cfquery name="ItemsNotShipped" datasource="#application.DS#">
						SELECT ID AS ItemsNotOut
						FROM #application.database#.inventory
						WHERE is_valid = 1 
							AND quantity <> 0 
							AND snap_is_dropshipped = 0  
							AND order_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
							AND ship_date IS NULL 
							AND po_ID = 0
							AND po_rec_date IS NULL 
						
						UNION
						
						SELECT ID AS ItemsNotOut
						FROM #application.database#.inventory
						WHERE is_valid = 1 
							AND quantity <> 0 
							AND snap_is_dropshipped = 1  
							AND order_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
							AND ship_date IS NULL 
							AND po_ID = 0
							AND po_rec_date IS NULL
						
					</cfquery>

					<cfset mod_note = "(*auto* UPS Group ###upsgroup_ID# Import)">										
					<cfif ItemsNotShipped.RecordCount EQ 0>
						<cfset mod_note = mod_note & Chr(13) & Chr(10) & "(*auto* order completely fulfilled #DateFormat(NOW(),'mm/dd/yy')#)">
					</cfif>
					<cfset mod_note = mod_note & Chr(13) & Chr(10) & "(*auto* item shipped on #DateFormat(NOW(),'mm/dd/yy')#, tracking ###matching_tracking#)">
					<cfset mod_note = mod_note & Chr(13) & Chr(10) & "QTY: #quantity# CAT: #snap_productvalue# SKU: #snap_sku# PRODUCT: #snap_meta_name# #snap_options#">
					
					<cfquery name="UpdateOrderInfo" datasource="#application.DS#">
						UPDATE #application.database#.order_info 
						SET is_valid = 1 
						<cfif ItemsNotShipped.RecordCount EQ 0>, is_all_shipped = 1 </cfif>
						#FLGen_UpdateModConcatSQL(mod_note)#
						WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#InvItemsInGroup.order_ID#">
					</cfquery>

					<cfquery name="UpdateUPSGroup" datasource="#application.DS#">
						UPDATE #application.database#.ups_group 
						SET is_imported = 1 
						#FLGen_UpdateModConcatSQL()#
						WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#">
					</cfquery>
					
				</cfoutput>		
				
				<cflocation url="ups_group_list.cfm?alert_msg=The%20UPS%20group%20was%20imported%20successfully." addtoken="no"> 
		
		<!--- This is where I would send the email, if there was one... --->

<!--- END: IMPORT --->

			</cfif>

		</cfif>
		
	</cfif>

<cfcatch><cfset alert_msg = "There was a problem with the import.  [Error 4]"></cfcatch>

</cftry>

</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

	<script src="../includes/paging.js"></script> 

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "ups_group_list">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">UPS Group Data Import</span>
<br />
<br />

<cfoutput>

<span class="pageinstructions">Return to <a href="ups_group_list.cfm?pgfn=detail&upsgroup_ID=#upsgroup_ID#">UPS Group Detail</a> or <a href="ups_group_list.cfm">UPS Group List</a> without making changes.</span>
<br />
<br />

<cfif datasaved eq 'yes'>
	<span class="alert">The information was saved.</span>#FLGen_SubStamp()#
	<br /><br />
</cfif>

</cfoutput>

<cfset proper_import_file = true>

<cftry>

	<cffile action="read" file="#application.AbsPath#admin/upload/ups_file.csv" variable="display_file">
	
	<cfif display_file EQ "">
		<cfset proper_import_file = false>
		<span class="alert">There is no file or the file has no content to display.</span>
	</cfif>
	
	<cfif proper_import_file AND ListLen(display_file,chr(13) & chr(10)) EQ 1>
		<cfset proper_import_file = false>
		<span class="alert">There are no entries in this file.</span>
	</cfif>
	
	<cfif proper_import_file AND ListLen(display_file,"#chr(13) & chr(10)#,") MOD 4 NEQ 0>
		<cfset proper_import_file = false>
		<span class="alert">The .csv file is not properly formatted.</span>
	</cfif>
	
	<cfif proper_import_file> 
		
		<cfset display_file = Replace(display_file,chr(13) & chr(10),"^","all")>
			
		<cfquery name="InvItemsInGroup" datasource="#application.DS#">
			SELECT inv.ID AS inventory_ID, inv.order_ID, inv.snap_sku 
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
		
	</cfif>
					 
	<cfif proper_import_file AND InvItemsInGroup.RecordCount NEQ ListLen(display_file,"^,")/4 - 1>
		<cfset proper_import_file = false>
		<span class="alert"><cfoutput>The number of entries in the file [ #ListLen(display_file,"^,")/4 - 1# ] do not match the number of items in the UPS group [ #InvItemsInGroup.RecordCount# ].</cfoutput></span>
	</cfif>
	
	<cfif proper_import_file AND InvItemsInGroup.snap_sku NEQ ListGetAt(display_file,5,"^,")>
		<cfset proper_import_file = false>
		<span class="alert"><cfoutput>The sku in the .csv file [ #ListGetAt(display_file,5,"^,")# ] does not match the UPS Group sku [ #InvItemsInGroup.snap_sku# ].</cfoutput></span>
	</cfif>
	
	<cfif proper_import_file>
		<cfset order_numbers = "">
		<cfloop index="i" from="6" to="#ListLen(display_file,"^,")#" step="4">
			<cfset order_numbers = ListAppend(order_numbers,ListGetAt(display_file,i,"^,"))>
		</cfloop>
		<cfset group_order_numbers = ValueList(InvItemsInGroup.order_ID)>
		
		<cfset all_order_numbers_match = true>
		<cfloop list="#order_numbers#" index="i">
			<cfif group_order_numbers DOES NOT CONTAIN order_numbers>
				<cfset all_order_numbers_match = false>
			</cfif>
		</cfloop>
	</cfif>
						
 	<cfif proper_import_file AND NOT all_order_numbers_match>
		<cfset proper_import_file = false>
		<span class="alert"><cfoutput>The order numbers in the .csv group [ #group_order_numbers# ] do not match the order numbers in the UPS group [ #order_numbers# ].</cfoutput></span>
	</cfif>

<cfcatch>There is no current .csv file.</cfcatch>

</cftry>

<cfif proper_import_file>

<cfoutput>

	<form method="post" action="#CurrentPage#">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		
	<tr class="contenthead">
	<td colspan="2" class="headertext">Import Tracking Numbers</td>
	</tr>

	<tr class="content">
	<td nowrap="nowrap" align="right">Date Packages Were Shipped: </td>
	<td width="100%"><input type="text" name="date_shipped" value="#DateFormat(Now(),'mm/dd/yyyy')#">
	<input type="hidden" name="date_shipped_required" value="">
	<input type="hidden" name="date_shipped_date" value="#DateFormat(Now(),'mm/dd/yyyy')#">
	<input type="hidden" name="upsgroup_ID" value="#upsgroup_ID#"></td>
	</tr>
	
	<tr class="content">
	<td colspan="2"><span class="sub" style="margin-left:50px;margin-right:50px;display:block">When you click "Import" all order items in this UPS group will be marked as shipped and their tracking numbers will be saved.</span></td>
	</tr>

	<tr class="content">
	<td colspan="2" align="center"><input type="submit" value="Import" name="submit"></td>
	</tr>
	
	</table>
	
	</form>
	
</cfoutput>

	<br /><br />
	
<span class="selecteditem">The .csv file matches this UPS Group</span>

	<br /><br />
				
	<b>Current .csv file contains [ <cfoutput>#ListLen(display_file,"^,")/4 - 1#</cfoutput> ] record(s):</b>
	
	<br /><br />			
		
	<table border="1" cellpadding="2" style="border-width:1px;border-style:solid;border-color:##CCCCCC;border-collapse:collapse">
	<cfoutput>
	<cfloop list="#display_file#" delimiters="^" index="i">
	<tr>
		<cfloop list="#i#" delimiters="," index="j">
		<td>
		#j#
		</td>
		</cfloop>
	</tr>
	</cfloop>
	</cfoutput>
	</table>
		
	<br><br>
	
	<b>Current UPS group contains [ <cfoutput>#InvItemsInGroup.RecordCount#</cfoutput> ] record(s):</b>
	
	<br /><br />			

	<table border="1" cellpadding="2" style="border-width:1px;border-style:solid;border-color:##CCCCCC;border-collapse:collapse">
	<cfoutput query="InvItemsInGroup">
	<tr>
	<td>#snap_sku#</td>
	<td>#order_ID#</td>
	<td>#inventory_ID#</td>
	</tr>
	</cfoutput>
	</table>

<cfelse>
<br><br>
Check the <a href="ups_group_upload.cfm">.csv file</a> contents.
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->