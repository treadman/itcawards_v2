<!--- 
<cfdump var="#cookie#">
<cfdump var="#request#">
 --->

<!--- --------------------------------------- --->
<!--- ------ Logo for selected program ------ --->
<!--- --------------------------------------- --->

<cfif IsDefined('cookie.itc_program') AND cookie.itc_program IS NOT "">
	<cfoutput>#ADMIN_GetProgramInfo()#
	<cfif IsDefined('admin_logo') AND admin_logo IS NOT "">
		<div align="center" style="background-color:##FFFFFF; padding:20px 5px 20px 5px  "><img src="../pics/program/#admin_logo#" width="170" height="43"></div><br />
	</cfif>
	</cfoutput>
</cfif>


<!--- --------------------------------------- --->
<!--- ------ Program Selector --------------- --->
<!--- --------------------------------------- --->

<!--- <cfif request.is_admin>
	<cfquery name="GetProgramNames" datasource="#application.DS#">
		SELECT ID, company_name, program_name 
		FROM #application.database#.program
		WHERE is_active = 1
		ORDER BY company_name, program_name
	</cfquery>
	<cfoutput>
	<br />
	<form action="program_select.cfm" method="post" name="ProgramSelect">
		<input type="hidden" name="ReturnTo" value="#CurrentPage#" />
		<select name="Program" onChange="ProgramSelect.submit();">
			<option value="">--- <cfif request.selected_program_ID EQ 0>Select a<cfelse>No</cfif> Program ---</option>
			<cfloop query="GetProgramNames">
				<option value="#GetProgramNames.ID#"<cfif GetProgramNames.ID EQ request.selected_program_ID> selected</cfif>>#company_name# [#program_name#]</option>
			</cfloop>
		</select>
	</form>
	<br />
	</cfoutput>

</cfif> --->


<!--- --------------------------------------- --->
<!--- ------------   Home   ----------------- --->
<!--- --------------------------------------- --->

&nbsp;&nbsp;&nbsp;&nbsp;
<cfif leftnavon EQ 'index'>
	<b>Home &rsaquo;</b>
<cfelse>
	<a href="index.cfm">Home</a>
</cfif>
<br />


<!--- --------------------------------------- --->
<!--- ---- Admin Users and Access Levels ---- --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000006-1000000007-1000000033")>

	<br />
	<span class="leftnavhead">A D M I N&nbsp;&nbsp;&nbsp;S Y S T E M</span>
	<br />

	<cfif FLGen_HasAdminAccess(1000000006)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'admin_users'>
			<b>Admin Users &rsaquo;</b>
		<cfelse>
			<a href="admin_user.cfm">Admin Users</a>
		</cfif>
		<br />
	</cfif>

	<cfif FLGen_HasAdminAccess(1000000007)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'admin_access_levels'>
			<b>Admin Access Levels &rsaquo;</b>
		<cfelse>
			<a href="admin_access_level.cfm">Admin Access Levels</a>
		</cfif>
		<br />
	</cfif>

	<cfif FLGen_HasAdminAccess(1000000033)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'adminaccessreport'>
			<b>Admin Access Report &rsaquo;</b>
		<cfelse>
			<a href="report_adminaccess.cfm">Admin Access Report</a>
		</cfif>
		<br />
	</cfif>

</cfif>


<!--- --------------------------------------- --->
<!--- ---------- Products Admin ------------- --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000008-1000000009-1000000010-1000000011-1000000012-1000000013-1000000015")>

	<br />
	<span class="leftnavhead">P R O D U C T S</span>
	<br />

	<cfif FLGen_HasAdminAccess(1000000008)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'products'>
			<b>Products &rsaquo;</b>
		<cfelse>
			<a href="product.cfm">Products</a>
		</cfif>
		<br />
	</cfif>
	
	<cfif FLGen_HasAdminAccess(1000000015)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'master_categories'>
			<b>Master Categories &rsaquo;</b>
		<cfelse>
			<a href="master_categories.cfm">Master Categories</a>
		</cfif>
		<br />
	</cfif>
	
	<cfif FLGen_HasAdminAccess(1000000009)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'productsortorder'>
			<b>Product Sort Order &rsaquo;</b>
		<cfelse>
			<a href="product_order.cfm">Product Sort Order</a>
		</cfif>
		<br />
	</cfif>
	
	<cfif FLGen_HasAdminAccess(1000000010)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'groups'>
			<b>Product Groups &rsaquo;</b>
		<cfelse>
			<a href="product_groups.cfm">Product Groups</a>
		</cfif>
		<br />
	</cfif>
	
	<cfif FLGen_HasAdminAccess(1000000011)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'manuflogos'>
			<b>Manufacturer Logos &rsaquo;</b>
		<cfelse>
			<a href="product_manuflogo.cfm">Manufacturer Logos</a>
		</cfif>
		<br />
	</cfif>
	
	<cfif FLGen_HasAdminAccess(1000000012)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'vendors'>
			<b>Vendors &rsaquo;</b>
		<cfelse>
			<a href="vendor.cfm">Vendors</a>
		</cfif>
		<br />
	</cfif>
	
	<cfif FLGen_HasAdminAccess(1000000013)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'inventory'>
			<b>Inventory &rsaquo;</b>
		<cfelse>
			<a href="inventory.cfm?p=n">Inventory</a>
		</cfif>
		<br />
	</cfif>

</cfif>


<!--- --------------------------------------- --->
<!--- -------- Program and Users Admin ------ --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000014-1000000016-1000000020-1000000063-1000000065-1000000088")>

	<br />
	<span class="leftnavhead">A W A R D&nbsp;&nbsp;&nbsp;P R O G R A M S</span>
	<br />

	<cfif FLGen_HasAdminAccess(1000000065)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'meta_program'>
			<b>Program Meta Info &rsaquo;</b>
		<cfelse>
			<a href="program_meta.cfm">Program Meta Info</a>
		</cfif>
		<br />
	</cfif>

	<cfif FLGen_HasAdminAccess(1000000014)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<!--- <cfif leftnavon EQ 'programs' OR leftnavon EQ 'programusers' OR leftnavon EQ 'program_product'> --->
		<cfif leftnavon EQ 'programs'>
			<b>Programs &rsaquo;</b>
		<cfelse>
			<a href="program.cfm">Programs</a>
		</cfif>
		<br />
	</cfif>

	<cfif FLGen_HasAdminAccess(1000000088)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'image_upload'>
			<b>Image Upload &rsaquo;</b>
		<cfelse>
			<a href="image_upload.cfm">Image Upload</a>
		</cfif>
		<br />
	</cfif>

	<cfif isDefined("request.selected_program_ID") AND request.selected_program_ID GT 0>

		<cfif FLGen_HasAdminAccess(1000000020)>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cfif leftnavon EQ 'program_user'>
				<b>Program Users &rsaquo;</b>
			<cfelse>
				<a href="program_user.cfm?program_ID=<cfoutput>#request.selected_program_ID#</cfoutput>">Program Users</a>
			</cfif>
			<br />
		</cfif>

		<cfif FLGen_HasAdminAccess(1000000063)>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cfif leftnavon EQ 'program_product'>
				<b>Exclude Products &rsaquo;</b>
			<cfelse>
				<a href="program_product.cfm?program_ID=<cfoutput>#request.selected_program_ID#</cfoutput>">Exclude Products</a>
			</cfif>
			<br />
		</cfif>

		<cfif FLGen_HasAdminAccess(1000000016)>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cfif leftnavon EQ 'report_survey'>
				<b>Surveys &rsaquo;</b>
			<cfelse>
				<a href="report_survey.cfm?program_ID=<cfoutput>#request.selected_program_ID#</cfoutput>">Surveys</a>
			</cfif>
			<br />
		</cfif>

	</cfif>

</cfif>


<!--- --------------------------------------- --->
<!--- ------  Orders Admin ------------------ --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000017-1000000082")>

	<br />
	<span class="leftnavhead">O R D E R S</span>
	<br />
	
	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'orders'>
			<b>Orders &rsaquo;</b>
		<cfelse>
			<a href="order.cfm">Orders</a>
		</cfif>
	<br />
	
	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'report_fulfillment'>
			<b>Ship From ITC &rsaquo;</b>
		<cfelse>
			<a href="report_fulfillment.cfm">Ship From ITC</a>
		</cfif>
	<br />
	
	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'po_builder'>
			<b>PO Builder &rsaquo;</b>
		<cfelse>
			<a href="report_po.cfm">PO Builder</a>
		</cfif>
	<br />
	
	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'purchase_orders'>
			<b>Purchase Orders &rsaquo;</b>
		<cfelse>
			<a href="po_list.cfm">Purchase Orders</a>
		</cfif>
	<br />

	<cfif FLGen_HasAdminAccess(1000000082)>
	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'ups_group_list'>
			<b>UPS Groups &rsaquo;</b>
		<cfelse>
			<a href="ups_group_list.cfm">UPS Groups</a>
		</cfif>
	<br />

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'ups_group_upload'>
			<b>UPS Upload .CSV &rsaquo;</b>
		<cfelse>
			<a href="ups_group_upload.cfm">UPS Upload .CSV </a>
		</cfif>
	<br />
	</cfif>

</cfif>


<!--- --------------------------------------- --->
<!--- ----- Email Broadcast System ---------- --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000072-1000000073-1000000074")>

	<br />
	<span class="leftnavhead">E M A I L&nbsp;&nbsp;&nbsp;A L E R T S</span>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000072)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'email_alert_templates'>
			<b>Templates &rsaquo;</b>
		<cfelse>
			<a href="email_alert_templates.cfm">Templates</a>
		</cfif>
	<br />

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'email_alert_groups'>
			<b>Groups &rsaquo;</b>
		<cfelse>
			<a href="email_alert_groups.cfm">Groups</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000073)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'email_alert_send'>
			<b>Send Email Alert &rsaquo;</b>
		<cfelse>
			<a href="email_alert_send.cfm">Send Email Alert</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000074)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'email_alert_report'>
			<b>Email Alert Report &rsaquo;</b>
		<cfelse>
			<a href="email_alert_report.cfm">Email Alert Report</a>
		</cfif>
	<br />

</cfif>

<!--- --------------------------------------- --->
<!--- -------- Report System ---------------- --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000035-1000000036-1000000037-1000000038-1000000039-1000000070-1000000091-1000000094")>

	<br />
	<span class="leftnavhead">R E P O R T S</span>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000035)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'ordertotalreport'>
			<b>Order Totals &rsaquo;</b>
		<cfelse>
			<a href="report_ordertotal.cfm">Order Totals</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000036)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'winprodreport'>
			<b>User/Product &rsaquo;</b>
		<cfelse>
			<a href="report_winprod.cfm">User/Product</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000037)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'billingreport'>
			<b>Billing &rsaquo;</b>
		<cfelse>
			<a href="report_billing.cfm">Billing</a>
		</cfif>
	<br />
	<cfif isDefined("request.selected_henkel_program.do_report_billing") AND isBoolean(request.selected_henkel_program.do_report_billing) AND request.selected_henkel_program.do_report_billing>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_billingreport'>
			<b>Henkel Billing &rsaquo;</b>
		<cfelse>
			<a href="henkel_report_billing.cfm">Henkel Billing</a>
		</cfif>
		<br />
	</cfif>

</cfif>

<cfif FLGen_HasAdminAccess(1000000039)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'orderquanreport'>
			<b>Order Quantity &rsaquo;</b>
		<cfelse>
			<a href="report_ordquantities.cfm">Order Quantity</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000084)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'shipquanreport'>
			<b>Shipped Quantity &rsaquo;</b>
		<cfelse>
			<a href="report_shipquantities.cfm">Shipped Quantity</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000087)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'fulfilledordersreport'>
			<b>Fulfilled Orders &rsaquo;</b>
		<cfelse>
			<a href="report_fulfilledorders.cfm">Fulfilled Orders</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000038)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'poquantities'>
			<b>PO Quantity &rsaquo;</b>
		<cfelse>
			<a href="report_poquantities.cfm">PO Quantity</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000091) AND isDefined("request.selected_program_ID") AND request.selected_program_ID EQ "1000000035">

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'lorillard_redeemed'>
			<b>Lorillard Redeemed &rsaquo;</b>
		<cfelse>
			<a href="report_lorillard.cfm">Lorillard Redeemed</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000094)><!--- AND isDefined("request.selected_program_ID") AND request.selected_program_ID EQ "1000000010">--->

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'report_subprogram_balance'>
			<b>Subprogram Acct Bal &rsaquo;</b>
		<cfelse>
			<a href="report_subprogram_balance.cfm">Subprogram Acct Bal</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000070)>

	<cfquery name="ReportSelect" datasource="#application.DS#">
		SELECT COUNT(*) AS this_many 
		FROM #application.database#.program_user
		WHERE entered_by_program_admin = 1	
	</cfquery>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'verifyusers'>
			<b>Users To Verify &rsaquo;</b>
		<cfelse>
			<a href="report_verifyusers.cfm">Users To Verify</a><cfif ReportSelect.this_many GTE 1> <span class="alert">[<cfoutput>#ReportSelect.this_many#</cfoutput>]</span></cfif>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000081) AND isDefined("request.selected_program_ID") AND isNumeric(request.selected_program_ID)>
	<cfquery name="FindProgsWithSubs" datasource="#application.DS#">
		SELECT p.ID AS program_ID
		FROM #application.database#.program p
		WHERE (SELECT COUNT(s.ID) FROM #application.database#.subprogram s WHERE s.program_ID = p.ID) > 0
		AND p.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.selected_program_ID#">
	</cfquery>
	<cfif FindProgsWithSubs.recordcount GT 0>
	<br />
	<span class="leftnavhead" style="letter-spacing:1px">SUBPROGRAM REPORTS</span>
	<br />

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'report_subprogram_billing'>
			<b>Order Report &rsaquo;</b>
		<cfelse>
			<a href="report_subprogram_billing.cfm">Billing/Order Report</a>
		</cfif>
	<br />

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'report_subprogram_accural'>
			<b>Accrual Report &rsaquo;</b>
		<cfelse>
			<a href="report_subprogram_accural.cfm">Accrual Report</a>
		</cfif>
	<br />
	
	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'report_subprogram_user'>
			<b>User Report &rsaquo;</b>
		<cfelse>
			<a href="report_subprogram_user.cfm">User Report</a>
		</cfif>
	<br />
	</cfif>
</cfif>

<!--- --------------------------------------- --->
<!--- ------ Cardinal Health Admin ---------- --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000041-1000000042-1000000043-1000000044-1000000045-1000000046")>

	<br />
	<span class="leftnavhead">C A R D I N A L&nbsp;&nbsp;&nbsp;H E A L T H</span>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000041)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'cardinal_regions'>
			<b>Regions &rsaquo;</b>
		<cfelse>
			<a href="cardinal_regions.cfm">Regions</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000042)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'cardinal_admin_regions'>
			<b>Regions/Admins &rsaquo;</b>
		<cfelse>
			<a href="cardinal_regions_admin.cfm">Regions/Admins</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000043)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'cardinal_user_regions'>
			<b>Regions/Users &rsaquo;</b>
		<cfelse>
			<a href="cardinal_regions_user.cfm">Regions/Users</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000044)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'cardinal_manage_users'>
			<b>Manage Users &rsaquo;</b>
		<cfelse>
			<a href="cardinal_manage_users.cfm">Manage Users</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000045)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'cardinal_award_email'>
			<b>Award Email &rsaquo;</b>
		<cfelse>
			<a href="cardinal_award_email.cfm">Award Email</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000046)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'cardinal_report'>
			<b>Report &rsaquo;</b>
		<cfelse>
			<a href="cardinal_report_points.cfm">Report</a>
		</cfif>
	<br />

</cfif>

<!--- --------------------------------------- --->
<!--- --------- Region Admin ---------------- --->
<!--- --------------------------------------- --->

<cfif FLGen_HasAdminAccess("1000000056-1000000058-1000000059-1000000060-1000000061-1000000062")>

	<br />
	<span class="leftnavhead">R E G I O N&nbsp;&nbsp;&nbsp;A D M I N</span>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000056)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'program_regions'>
			<b>Regions &rsaquo;</b>
		<cfelse>
			<a href="program_regions.cfm">Regions</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000058)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'program_admin_regions'>
			<b>Regions/Admins &rsaquo;</b>
		<cfelse>
			<a href="program_regions_admin.cfm">Regions/Admins</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000059)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'program_user_regions'>
			<b>Regions/Users &rsaquo;</b>
		<cfelse>
			<a href="program_regions_user.cfm">Regions/Users</a>
		</cfif>
	<br />

</cfif>

<cfif isDefined("request.selected_program_ID") AND request.selected_program_ID EQ "1000000009">
<cfif FLGen_HasAdminAccess(1000000060)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'program_manage_users'>
			<b>Manage Users &rsaquo;</b>
		<cfelse>
			<a href="program_manage_users.cfm">Manage Users</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000061)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'program_award_email'>
			<b>Award Email &rsaquo;</b>
		<cfelse>
			<a href="program_award_email.cfm">Award Email</a>
		</cfif>
	<br />

</cfif>

<cfif FLGen_HasAdminAccess(1000000062)>

	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'program_report'>
			<b>Report &rsaquo;</b>
		<cfelse>
			<a href="program_report_points.cfm">Report</a>
		</cfif>
	<br />

</cfif>

</cfif>

<!--- --------------------------------------- --->
<!--- ----- Shared Henkel Programs Admin ---- --->
<!--- --------------------------------------- --->

<cfif isDefined("request.selected_henkel_program")>
	<cfoutput>
	<br />
	<span class="leftnavhead">
		<cfloop from="1" to="#Len(request.selected_henkel_program.program_name)#" index="x">
			<cfset y = Mid(request.selected_henkel_program.program_name,x,1)>
			<cfif x EQ 8>
				<br />
			</cfif>
			<cfif y EQ " ">
				&nbsp;
			<cfelse>
				#UCase(y)#
			</cfif>
		</cfloop>
	</span>
	<br />
	<cfif FLGen_HasAdminAccess(1000000098)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_import'>
			<b>Upload Excel Files &rsaquo;</b>
		<cfelse>
			<a href="henkel_import.cfm">Upload Excel Files</a>
		</cfif>
		 <br />
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_import_points'>
			<b>Upload Points Files &rsaquo;</b>
		<cfelse>
			<a href="henkel_import_points.cfm">Upload Points Files</a>
		</cfif>
		 <br />
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_registrations'>
			<b>Henkel Registrations&rsaquo;</b>
		<cfelse>
			<a href="henkel-registrations.cfm">Henkel Registrations</a>
		</cfif>
		<br />
	</cfif>
	<cfif FLGen_HasAdminAccess(1000000099)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel-branch-registrations'>
			<b>Branch Registrations &rsaquo;</b>
		<cfelse>
			<a href="henkel-branch-registrations.cfm">Branch Registrations</a>
		</cfif>
		 <br />
	</cfif>
	<cfif FLGen_HasAdminAccess(1000000100)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_distributor_admin'>
			<b>#request.selected_henkel_program.distributor_label# Admin &rsaquo;</b>
		<cfelse>
			<a href="henkel_distributor_admin.cfm">#request.selected_henkel_program.distributor_label# Admin</a>
		</cfif>
		 <br />
	</cfif>
	<cfif FLGen_HasAdminAccess(1000000101)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_territory_admin'>
			<b>Territory Admin &rsaquo;</b>
		<cfelse>
			<a href="henkel_territory_admin.cfm">Territory Admin</a>
		</cfif>
		 <br />
	</cfif>
	<cfif FLGen_HasAdminAccess(1000000103)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_report_points'>
			<b>Points Report &rsaquo;</b>
		<cfelse>
			<a href="henkel_report_points.cfm">Points Report</a>
		</cfif>
		 <br />
	</cfif>
	</cfoutput>
</cfif>


<!--- --------------------------------------- --->
<!--- ----- Miscellaneous Henkel Stuff ------ --->
<!--- --------------------------------------- --->

<cfif isDefined("request.selected_program_ID") AND ListFind("1000000010,1000000066,1000000069",request.selected_program_ID)>
<cfif FLGen_HasAdminAccess("1000000104-1000000105-1000000106-1000000107")>
	<br />
	<span class="leftnavhead">H E N K E L</span>
	<br />
	<cfif request.selected_program_ID EQ "1000000066">
	<cfif FLGen_HasAdminAccess(1000000104)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_registrations_export_us'>
			<b>Export US Registrations &rsaquo;</b>
		<cfelse>
			<a href="henkel-registrations-export.cfm?program_id=1000000066">Export US Registrations</a>
		</cfif>
		<br />
	</cfif>
	<cfif FLGen_HasAdminAccess(1000000108)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_registrations_export_us_branch'>
			<b>Export US Registrations &rsaquo;</b>
		<cfelse>
			<a href="henkel-branch-registrations-export.cfm?program_id=1000000066">Export Br. Registrations</a>
		</cfif>
		<br />
	</cfif>
	<cfif FLGen_HasAdminAccess(1000000106)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_report_branch'>
			<b>Branch Report US &rsaquo;</b>
		<cfelse>
			<a href="henkel_report_branch.cfm?program_id=1000000066">Branch Report US</a>
		</cfif>
		<br />
	</cfif>
	</cfif>
	<cfif request.selected_program_ID EQ "1000000069">
	<cfif FLGen_HasAdminAccess(1000000105)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_registrations_export_ca'>
			<b>Export CA Registrations &rsaquo;</b>
		<cfelse>
			<a href="henkel-registrations-export.cfm?program_id=1000000069">Export CA Registrations</a>
		</cfif>
		<br />
	</cfif>
	<cfif FLGen_HasAdminAccess(1000000107)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_report_branch_ca'>
			<b>Branch Report CA &rsaquo;</b>
		<cfelse>
			<a href="henkel_report_branch.cfm?program_id=1000000069">Branch Report CA</a>
		</cfif>
		<br />
	</cfif>
	</cfif>
	<cfif ListFind("1000000010,1000000066",request.selected_program_ID)>
	<cfif FLGen_HasAdminAccess(1000000098)>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'henkel_kaman'>
			<b>Transfer to Kaman &rsaquo;</b>
		<cfelse>
			<a href="henkel_kaman.cfm">Transfer to Kaman</a>
		</cfif>
		 <br />
	</cfif>
	</cfif>
</cfif>
</cfif>

<cfif FLGen_HasAdminAccess("1000000086")>
	<br />
	<span class="leftnavhead">A R I  G A M E</span>
	<br />
	&nbsp;&nbsp;&nbsp;&nbsp;
	<cfif leftnavon EQ 'ari60ManageUsers'>
		<strong>Manage 60 Users &rsaquo;</strong>
	<cfelse>
		<a href="ari60ManageUsers.cfm">Manage 60 Users</a>
	</cfif>
	<br />
	&nbsp;&nbsp;&nbsp;&nbsp;
	<cfif leftnavon EQ 'ari60Report'>
		<strong>60 Report &rsaquo;</strong>
	<cfelse>
		<a href="ari60Report.cfm">60 Report</a>
	</cfif>
	<br />
	<!--- &nbsp;&nbsp;&nbsp;&nbsp;
	<cfif leftnavon EQ 'ari60ExportUsers'>
		<strong>Export 60 Users &rsaquo;</strong>
	<cfelse>
		<a href="ari60ExportUsers.cfm">Export 60 Users</a>
	</cfif>
	<br /> --->

	&nbsp;&nbsp;&nbsp;&nbsp;
	<cfif leftnavon EQ 'ariGameManageContestants'>
		<strong>Manage Contestants &rsaquo;</strong>
	<cfelse>
		<a href="ariGameManageContestants.cfm">Manage Contestants</a>
	</cfif>
	<br />
	&nbsp;&nbsp;&nbsp;&nbsp;
	<cfif leftnavon EQ 'ari_broadcaster'>
		<b>Email Broadcaster &rsaquo;</b>
	<cfelse>
		<a href="ariGameBroadcastEmail.cfm">Email Broadcaster</a>
	</cfif>
	<br />
	&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif leftnavon EQ 'ari_secretword'>
			<b>Set Secret Word &rsaquo;</b>
		<cfelse>
			<a href="ariGameSecretWord.cfm">Set Secret Word</a>
		</cfif>
	<br />
</cfif>

<cfif FLGen_HasAdminAccess("1000000067-1000000075-1000000076-1000000080-1000000083-1000000089")>
	<br />
	<span class="leftnavhead">P R O G R A M&nbsp;&nbsp;&nbsp;A D M I N</span>
	<br />
	
	<cfif ListGetAt(cookie.itc_program,1,'-') EQ '1000000001'>
	<br />
	You are an <b>ITC</b> admin user.  Only admin users assigned to one of the Awards Programs can access the Program Admin pages.
	
	<cfelse>
	
		<cfif FLGen_HasAdminAccess(1000000067)>
		&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'programadminusers'>
					<b>Program Users &rsaquo;</b>
				<cfelse>
					<a href="program_admin_user.cfm">Program Users</a>
				</cfif>
		<br />
		</cfif>

		<cfif FLGen_HasAdminAccess(1000000075)>
		
			&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'email_alert_send'>
					<b>Send Email Alert &rsaquo;</b>
				<cfelse>
					<a href="email_alert_send.cfm">Send Email Alert</a>
				</cfif>
			<br />
		
		</cfif>
	
		<cfif FLGen_HasAdminAccess(1000000080)>
		
			&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'email_alert_report'>
					<b>Email Alert Report &rsaquo;</b>
				<cfelse>
					<a href="email_alert_report.cfm">Email Alert Report</a>
				</cfif>
			<br />
		
		</cfif>
	
		<cfif FLGen_HasAdminAccess(1000000076)>
		&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'programadminreportbilling'>
					<b>Billing Reports &rsaquo;</b>
				<cfelse>
					<a href="program_admin_report_billing.cfm">Billing Reports</a>
				</cfif>
		<br />
		</cfif>
	
		<cfif FLGen_HasAdminAccess(1000000083)>
		&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'programadminsurveyreport'>
					<b>Surveys &rsaquo;</b>
				<cfelse>
					<a href="program_admin_report_survey.cfm">Surveys</a>
				</cfif>
		<br />
		</cfif>
	
		<cfif FLGen_HasAdminAccess(1000000089)>
		&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'programadmin_additionalcontent'>
					<b>Additional Content &rsaquo;</b>
				<cfelse>
					<a href="program_admin_additional_content.cfm">Additional Content</a>
				</cfif>
		<br />
		</cfif>
	
	</cfif>
	
</cfif>

<cfif FLGen_HasAdminAccess("1000000095-1000000096")>
	<br />
	<span class="leftnavhead">P R O G R A M&nbsp;&nbsp;&nbsp;A D M I N</span>
	<br />
		<cfif FLGen_HasAdminAccess(1000000095)>
		&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'sub_admin_user'>
					<b>Regional Users &rsaquo;</b>
				<cfelse>
					<a href="sub_admin_user.cfm">Regional Users</a>
				</cfif>
		<br />
		</cfif>
		<cfif FLGen_HasAdminAccess(1000000096) AND isDefined("request.selected_program_ID") AND request.selected_program_ID EQ "1000000066">
		&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif leftnavon EQ 'ext_user_award_admin'>
					<b>Award Points &rsaquo;</b>
				<cfelse>
					<a href="ext_user_award_admin.cfm">Award Points</a>
				</cfif>
		<br />
		</cfif>
</cfif>

<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />