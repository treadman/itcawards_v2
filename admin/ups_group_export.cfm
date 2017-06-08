<cfsetting enablecfoutputonly="yes" showdebugoutput="no">

<cfset TC = ","> <!--- Tab Char --->
<cfset NL = Chr(13) & Chr(10)> <!--- New Line --->
<cfset file_name = "ups_export_SAVED_" & DateFormat(Now(),'yyyy-mm-dd') & "_"& TimeFormat(Now(),'HH-mm') & ".csv">

<!--- application/msexcel --->
<!--- text/plain --->
<cfcontent type="text/csv">
<cfheader name="Content-Disposition" value="filename=#file_name#">

	<cfquery name="ToBeEdited" datasource="#application.DS#">
		SELECT upsg.ID, upsg.created_user_ID, Date_Format(upsg.created_datetime,'%c/%d/%Y %l:%i %p') AS created_datetime, upsg.weight, upsg.package_type, upsg.service_level, upsg.height, upsg.declared_value, upsg.width, upsg.length, upsg.is_residential, upsg.package_type, upsg.service_level 
		FROM #application.database#.ups_group upsg 
		WHERE upsg.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#" maxlength="10">
	</cfquery>
	<cfset ID = ToBeEdited.ID>
	<cfset declared_value = HTMLEditFormat(ToBeEdited.declared_value)>
	<cfset weight = HTMLEditFormat(ToBeEdited.weight)>
	<cfset height = HTMLEditFormat(ToBeEdited.height)>
	<cfset width = HTMLEditFormat(ToBeEdited.width)>
	<cfset length = HTMLEditFormat(ToBeEdited.length)>
	<cfset is_residential = HTMLEditFormat(ToBeEdited.is_residential)>
	<cfset package_type = HTMLEditFormat(ToBeEdited.package_type)>
	<cfset service_level = HTMLEditFormat(ToBeEdited.service_level)>
	
	<cfif declared_value GTE 100>
		<cfset value_option = "Y">
	<cfelse>
		<cfset value_option = "N">
	</cfif>

	<cfquery name="InvItemsInGroup" datasource="#application.DS#">
		SELECT inv.ID AS inventory_ID, oi.ID AS order_ID, inv.snap_sku, oi.snap_fname, oi.snap_lname, oi.snap_ship_company, oi.snap_ship_fname, oi.snap_ship_lname, oi.snap_ship_address1, oi.snap_ship_address2, oi.snap_ship_city, oi.snap_ship_state, oi.snap_ship_zip, oi.snap_phone, oi.snap_email 
		FROM #application.database#.inventory inv
		INNER JOIN #application.database#.order_info oi ON inv.order_ID = oi.ID 
		WHERE inv.upsgroup_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#upsgroup_ID#"> 
			AND inv.is_valid = 1 
			AND inv.quantity <> 0 
			AND inv.snap_is_dropshipped = 0  
			AND inv.order_ID <> 0 
			AND inv.ship_date IS NULL 
			AND inv.po_ID = 0
			AND inv.po_rec_date IS NULL 
	</cfquery>

<cfoutput>Name1#TC#Name2#TC#Address1#TC#Address2#TC#City#TC#State#TC#Zip_code#TC#Service#TC#Package#TC#Weight#TC#Length#TC#Width#TC#Height#TC#Value_Option#TC#Value#TC#Billing#TC#Residential#TC#PackageReference1#TC#PackageReference2#TC#PackageReference3#NL#<cfloop query="InvItemsInGroup">#snap_ship_fname##TC##snap_ship_lname##TC##snap_ship_address1##TC##snap_ship_address2##TC##snap_ship_city##TC##snap_ship_state##TC##snap_ship_zip##TC##service_level##TC##package_type##TC##weight##TC##length##TC##width##TC##height##TC##value_option##TC##declared_value##TC#Prepaid#TC##is_residential##TC##snap_sku##TC##order_ID##TC##inventory_ID##NL#</cfloop></cfoutput>