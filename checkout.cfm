<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>

<CFSCRIPT>
	kFLGen_ImageSize = FLGen_ImageSize(application.FilePath & "pics/program/" & vLogo);
</CFSCRIPT>

<cfset order_ID = "">
<cfset carttotal = "0">
<cfparam name="transactionsuccessful" default="true">

<!--- rollover function --->

<!--- *********************************      --->
<!---  processing form                       --->
<!--- *********************************      --->

<cfif IsDefined('form.snap_fname') AND form.snap_fname IS NOT "">

	<!--- get the order number --->
	<cfif order_ID EQ "">
		<cfif IsDefined('cookie.itc_order') AND #cookie.itc_order# IS NOT "">
			<!--- authenticate order cookie --->
			<cfif FLGen_CreateHash(ListGetAt(cookie.itc_order,1,"-")) EQ ListGetAt(cookie.itc_order,2,"-")>
				<cfset order_ID = ListGetAt(cookie.itc_order,1,"-")>
			<cfelse>
				<!--- order cookie not authentic --->
				<cflocation addtoken="no" url="zkick.cfm">
			</cfif>
		<cfelse>
			<cflocation addtoken="no" url="zkick.cfm">
		</cfif>
	</cfif>
	
	<!--- get user info --->
	<cfif IsDefined('cookie.itc_user') AND #cookie.itc_user# IS NOT "">
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_user,1,"_")) EQ ListGetAt(cookie.itc_user,2,"_")>
			<!--- set user vars --->
			<cfset user_ID = ListGetAt(cookie.itc_user,1,"-")>
			<cfset user_total = ListGetAt(ListGetAt(cookie.itc_user,2,"-"),1,"_")>
			<!--- Get a fresh total from the DB.  If the two are different, kick them out. --->
			<cfset ProgramUserInfo(user_ID, false)>
			<cfif user_total GT 0 AND user_totalpoints NEQ user_total>
				<cflocation addtoken="no" url="zkick.cfm">
			</cfif> 
		</cfif>
	</cfif>
		
	<!--- figure total cost --->
	<cfquery name="SumOrderTotal" datasource="#application.DS#">
		SELECT snap_productvalue, quantity
		FROM #application.database#.inventory
		WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
	</cfquery>
	<cfset snap_order_total = "0">
		<cfoutput>
			 <cfloop query="SumOrderTotal">
				<cfset snap_order_total = snap_order_total + (snap_productvalue * quantity)>
			</cfloop>
		</cfoutput>

	<!--- preset cc auth codes to nothing, just incase it's not a cc order --->
	<cfset x_auth_code = "">
	<cfset x_tran_id = "">

	<cfif is_one_item>
	
		<!--- if it's a one item store, don't save points used and total cc charge --->
		<cfset points_used = 0>
		<cfset cc_charge = 0>

	<cfelse>

		<!--- if it's not a one item store, process the order normally --->
		
		<!--- figure total point used --->
		<cfif snap_order_total GTE user_total>
			<cfset points_used = user_total>
		<cfelse>
			<cfset points_used = snap_order_total>
		</cfif>
		
		<!--- figure total cc charge --->
		<cfif snap_order_total GTE user_total>
			<cfset cc_charge = snap_order_total - user_total>
		<cfelse>
			<cfset cc_charge = 0>
		</cfif>

		<!--- process credit card --->
		<cfif cc_charge EQ 0>
			<cfif snap_order_total * credit_multiplier GT user_total * points_multiplier>
				<cflocation url="cart.cfm" addtoken="no">
			</cfif>
		<cfelse>
			<!--- Nielsen gets special treatment for corporate credit cards --->
			<cfif program_ID EQ "1000000068" AND LEN(cc_number) EQ 15 AND ListFind("3782,3783,3785,3787,3794",LEFT(cc_number,4))>
				<cfset transactionsuccessful = "false">
				<cfset ccc_ResponseCode = "">
				<cfset ccc_ResponseReasonCode = "">
				<cfset ccc_ResponseReasonText = "You may not use your corporate credit card for this order.">
			<cfelse>
		
				<!--- *************************************** --->
				<!--- THIS IS WHERE I PROCESS THE CREDIT CARD --->
				<!--- *************************************** --->
				
				<cfset exp_date = cc_month & cc_year>
	
				<cfif cc_number EQ "pass" or cc_number EQ "fail">
					<cfset status = cc_number>
				<cfelse>
					<!--- before site goes live, set this to "fail"
					after site goes live, set this to "live" --->
					<cfset status = "live">
				</cfif>
				<cfoutput>#FLGen_ChargeCreditCard(status, cc_charge, cc_number, exp_date, cid_number, snap_bill_fname, snap_bill_lname, snap_bill_company, snap_bill_address1, snap_bill_address2, snap_bill_city, snap_bill_state, snap_bill_zip, snap_phone, snap_email, snap_ship_fname, snap_ship_lname, snap_ship_company, snap_ship_address1, snap_ship_address2, snap_ship_city, snap_ship_state, snap_ship_zip)#</cfoutput>
				
				<!--- the transaction is authorized --->
				<cfif ccc_ResponseCode EQ "Approved">
					<cfset x_auth_code = ccc_ResponseCode>
					<cfset x_tran_id = ccc_TransactionID>
					<cfset transactionsuccessful = "true">
					
				<!--- if the transaction fails, I need to stop processing this page --->
				<cfelse>
					<cfset transactionsuccessful = "false">
				</cfif>
			
			</cfif>
			<!--- *************************************** --->
			<!--- *************************************** --->
			<!--- *************************************** --->

		</cfif>
	</cfif>
	
	<cfif transactionsuccessful>

		<cflock name="order_infoLock" timeout="10">
			<cftransaction>
		
				<!--- get newest order number for this program --->
				<cfquery name="GetLastProgramOrderNumber" datasource="#application.DS#">
					SELECT Max(order_number) As MaxID
					FROM #application.database#.order_info
					WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
				</cfquery>
				<cfif GetLastProgramOrderNumber.MaxID LT 10000>
					<cfset order_number = "10000">
				<cfelse>
					<cfset order_number = IncrementValue(GetLastProgramOrderNumber.MaxID)>
				</cfif>
			
				<!--- save order information --->
				<cfquery name="SaveOrderInfo" datasource="#application.DS#">
					UPDATE #application.database#.order_info
					SET	snap_fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_fname#" maxlength="30">,
						snap_lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_lname#" maxlength="30">, 
						snap_ship_company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_company#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_ship_company)))#">, 
						snap_ship_fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_fname#" maxlength="30">, 
						snap_ship_lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_lname#" maxlength="30">, 
						snap_ship_address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_address1#" maxlength="30">, 
						snap_ship_address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_address2#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_ship_address2)))#">, 
						snap_ship_city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_city#" maxlength="30">, 
						snap_ship_state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_state#" maxlength="10">, 
						snap_ship_zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_zip#" maxlength="10">, 
						snap_phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_phone#" maxlength="35">, 
						order_note = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#order_note#" null="#YesNoFormat(NOT Len(Trim(order_note)))#">, 
						snap_email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_email#" maxlength="128">,
					<cfif IsDefined('snap_bill_company') AND TRIM(snap_bill_company) NEQ "">
						snap_bill_company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_company#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_company)))#">,  
					</cfif>
					<cfif IsDefined('snap_bill_fname') AND TRIM(snap_bill_fname) NEQ "">
						snap_bill_fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_fname)))#">, 
					</cfif>
					<cfif IsDefined('snap_bill_lname') AND TRIM(snap_bill_lname) NEQ "">
						snap_bill_lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_lname)))#">, 
					</cfif>
					<cfif IsDefined('snap_bill_address1') AND TRIM(snap_bill_address1) NEQ "">
						snap_bill_address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_address1#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_address1)))#">, 
					</cfif> 
					<cfif IsDefined('snap_bill_address2') AND TRIM(snap_bill_address2) NEQ "">
						snap_bill_address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_address2#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_address2)))#">,  
					</cfif>
					<cfif IsDefined('snap_bill_city') AND TRIM(snap_bill_city) NEQ "">
						snap_bill_city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_city)))#">, 
					</cfif>
					<cfif IsDefined('snap_bill_state') AND TRIM(snap_bill_state) NEQ "">
						snap_bill_state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_state#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_state)))#">, 
					</cfif>
					<cfif IsDefined('snap_bill_zip') AND TRIM(snap_bill_zip) NEQ "">
						snap_bill_zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_zip#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_zip)))#">, 
					</cfif>
						is_valid = 1,
						snap_order_total = <cfqueryparam cfsqltype="cf_sql_float" value="#snap_order_total#" maxlength="12">,
						points_used = <cfqueryparam cfsqltype="cf_sql_integer" value="#points_used#" maxlength="8">,
						credit_multiplier = <cfqueryparam cfsqltype="cf_sql_float" value="#credit_multiplier#" scale="2">,
						points_multiplier = <cfqueryparam cfsqltype="cf_sql_float" value="#points_multiplier#" scale="2">,
						cc_charge = <cfqueryparam cfsqltype="cf_sql_integer" value="#cc_charge#" maxlength="8" null="#YesNoFormat(NOT Len(Trim(cc_charge)))#">,
						order_number = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_number#" maxlength="14">,
						x_auth_code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#x_auth_code#" maxlength="32" null="#YesNoFormat(NOT Len(Trim(x_auth_code)))#">,
						x_tran_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#x_tran_id#" maxlength="64" null="#YesNoFormat(NOT Len(Trim(x_tran_id)))#">
						WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
				</cfquery>
				
			</cftransaction>
		</cflock>
		
		<!--- update all inventory items for this order to is_valid = 1 --->
		<cfquery name="UpdateInvItems" datasource="#application.DS#">
			UPDATE #application.database#.inventory
			SET	is_valid = 1
			WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
		</cfquery>
		
		<!--- update user record with first, last, shipping, and billing information --->
		<cfquery name="SaveOrderInfo" datasource="#application.DS#">
			UPDATE #application.database#.program_user
			SET	fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_fname#" maxlength="30">,
				lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_lname#" maxlength="30">, 
				ship_company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_company#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_ship_company)))#">, 
				ship_fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_fname#" maxlength="30">, 
				ship_lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_lname#" maxlength="30">, 
				ship_address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_address1#" maxlength="30">, 
				ship_address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_address2#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_ship_address2)))#">, 
				ship_city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_city#" maxlength="30">, 
				ship_state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_state#" maxlength="10">, 
				ship_zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_ship_zip#" maxlength="10">, 
				phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_phone#" maxlength="35">, 
				email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_email#" maxlength="128">
					<cfif IsDefined('snap_bill_company') AND TRIM(snap_bill_company) NEQ "">
						, bill_company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_company#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_company)))#"> 
					</cfif>
					<cfif IsDefined('snap_bill_fname') AND TRIM(snap_bill_fname) NEQ "">
						, bill_fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_fname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_fname)))#">
					</cfif>
					<cfif IsDefined('snap_bill_lname') AND TRIM(snap_bill_lname) NEQ "">
						, bill_lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_lname#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_lname)))#">
					</cfif>
					<cfif IsDefined('snap_bill_address1') AND TRIM(snap_bill_address1) NEQ "">
						, bill_address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_address1#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_address1)))#">
					</cfif> 
					<cfif IsDefined('snap_bill_address2') AND TRIM(snap_bill_address2) NEQ "">
						, bill_address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_address2#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_address2)))#">  
					</cfif>
					<cfif IsDefined('snap_bill_city') AND TRIM(snap_bill_city) NEQ "">
						, bill_city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_city#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_city)))#">
					</cfif>
					<cfif IsDefined('snap_bill_state') AND TRIM(snap_bill_state) NEQ "">
						, bill_state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_state#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_state)))#">
					</cfif>
					<cfif IsDefined('snap_bill_zip') AND TRIM(snap_bill_zip) NEQ "">
						, bill_zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#snap_bill_zip#" maxlength="30" null="#YesNoFormat(NOT Len(Trim(snap_bill_zip)))#">
					</cfif>
					<cfif is_one_item>
						, is_done = 1
					</cfif>
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">
		</cfquery>
	
		<!--- find all inventory items for this order for emails --->
		<cfquery name="FindOrderItems" datasource="#application.DS#">
			SELECT quantity, snap_meta_name, snap_sku, snap_productvalue, snap_options
			FROM #application.database#.inventory
			WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
		</cfquery>
	
		<cfquery name="SelectInfo" datasource="#application.DS#">
			SELECT meta_conf_email_text
			FROM #application.database#.program_meta
		</cfquery>
		<cfset meta_conf_email_text = HTMLEditFormat(SelectInfo.meta_conf_email_text)>

		<!--- send email confirmation, if requested --->
		<cfoutput>
			<cfmail to="#snap_email#" from="#orders_from#" subject="Thank you for your #company_name# Award Program order" failto="#application.AwardsProgramAdminEmail#">
	#DateFormat(Now(),"mm/dd/yyyy")#
	
	Thank you for your #company_name# Award Program order.
	
	<cfif meta_conf_email_text NEQ "">#meta_conf_email_text#</cfif>

	<cfif conf_email_text NEQ "">#conf_email_text#</cfif>
	
	Order #order_number# for #snap_fname# #snap_lname# (#snap_email#)
	PHONE: #snap_phone#
	
	SHIPPING ADDRESS:
	#snap_ship_fname# #snap_ship_lname##CHR(10)#
	#snap_ship_address1##CHR(10)#
	<cfif Trim(snap_ship_address2) NEQ "">#snap_ship_address2##CHR(10)#</cfif>
	#snap_ship_city#, #snap_ship_state# #snap_ship_zip#
	
	ITEM(S) IN ORDER:
<!---	<cfloop query="FindOrderItems">#quantity# - #snap_meta_name# #snap_options# <cfif NOT is_one_item>(#snap_productvalue# #credit_desc#)</cfif>#CHR(10)#</cfloop> --->
	<cfloop query="FindOrderItems">#quantity# - #snap_meta_name# #snap_options# <cfif NOT is_one_item>(#NumberFormat(snap_productvalue * credit_multiplier)# #credit_desc#)</cfif>#CHR(10)#</cfloop>

<!---	<cfif NOT is_one_item>Order Total: #snap_order_total##CHR(10)#
	#credit_desc# Used: #points_used##CHR(10)#
	#credit_desc# Left: #user_total - points_used##CHR(10)#
	<cfif cc_charge NEQ "0" AND cc_charge NEQ "" >Charged to Credit Card: #cc_charge#</cfif></cfif> --->

	<cfif NOT is_one_item>Order Total: #NumberFormat(snap_order_total* credit_multiplier)##CHR(10)#
	#credit_desc# Used: #NumberFormat(points_used * credit_multiplier)##CHR(10)#
	#credit_desc# Left: #NumberFormat((user_total* points_multiplier) - (points_used*credit_multiplier))##CHR(10)#
	<cfif cc_charge NEQ "0" AND cc_charge NEQ "" >Charged to Credit Card: #cc_charge#</cfif></cfif>
	
	ORDER NOTE:
	<cfif order_note EQ "">(none)<cfelse>#order_note#</cfif>
			</cfmail>
			
		<!--- send New Order email(s) ---->
		<cfloop list="#orders_to#" index="thisemail">
			<cfmail to="#thisemail#" from="#orders_from#" subject="#program_email_subject# - Order #order_number#" failto="#application.AwardsProgramAdminEmail#">
	#DateFormat(Now(),"mm/dd/yyyy")#
	
	Order #order_number# for #snap_fname# #snap_lname# (#snap_email#)
	PHONE: #snap_phone#
	
	SHIPPING ADDRESS:
	#snap_ship_fname# #snap_ship_lname##CHR(10)#
	#snap_ship_address1##CHR(10)#
	<cfif Trim(snap_ship_address2) NEQ "">#snap_ship_address2##CHR(10)#</cfif>
	#snap_ship_city#, #snap_ship_state# #snap_ship_zip#
	
	ITEM(S) IN ORDER:
	<cfloop query="FindOrderItems">#quantity# - [sku:#snap_sku#] #snap_meta_name# #snap_options# (#snap_productvalue*credit_multiplier# #credit_desc#)#CHR(10)#</cfloop>

	<cfif is_one_item>#CHR(10)#This is a ONE-ITEM award program<cfelse>Order Total: #snap_order_total*credit_multiplier##CHR(10)#
	#credit_desc# Used: #points_used*credit_multiplier##CHR(10)#
	#credit_desc# Left: #(user_total*points_multiplier) - (points_used*credit_multiplier)##CHR(10)#
	<cfif cc_charge NEQ "0" AND cc_charge NEQ "" >Charged to Credit Card: #cc_charge#</cfif></cfif>

	ORDER NOTE:
	<cfif order_note EQ "">(none)<cfelse>#order_note#</cfif>
			</cfmail>	
		</cfloop>
		</cfoutput>
		
		
		<!--- write the survey cookie --->
		<cfoutput>#WriteSurveyCookie()#</cfoutput>
	
		<!--- redirect --->
		<cflocation url="confirmation.cfm" addtoken="no">	
	
	</cfif>

</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="shortcut icon" href="/favicon.ico" />
<title>ITC Awards</title>

<style type="text/css"> 
	<cfinclude template="includes/program_style.cfm"> 
</style>

<script>

	// function to copy shipping address to billing address 
	function CopyAddress()
		{
		if (document.order_form.billingsame.checked)
			{
			document.order_form.snap_bill_company.value = document.order_form.snap_ship_company.value;
			document.order_form.snap_bill_fname.value = document.order_form.snap_ship_fname.value;
			document.order_form.snap_bill_lname.value = document.order_form.snap_ship_lname.value;
			document.order_form.snap_bill_lname.value = document.order_form.snap_ship_lname.value;
			document.order_form.snap_bill_address1.value = document.order_form.snap_ship_address1.value;
			document.order_form.snap_bill_address2.value = document.order_form.snap_ship_address2.value;
			document.order_form.snap_bill_city.value = document.order_form.snap_ship_city.value;
			document.order_form.snap_bill_state.value = document.order_form.snap_ship_state.value;
			document.order_form.snap_bill_zip.value = document.order_form.snap_ship_zip.value;
			} 
		}

	function SameName()
		{
		if (document.order_form.namesame.checked)
			{
			document.order_form.snap_ship_fname.value = document.order_form.snap_fname.value;
			document.order_form.snap_ship_lname.value = document.order_form.snap_lname.value;
			} 
		}

	function mOver(item, newClass)

		{
		item.className=newClass
		}

	function mOut(item, newClass)

		{
		item.className=newClass
		}

	function validateOnSubmit() {
			
		var error = false;
		var email = false;
		var re;
		
		for (i = 0;i < labelArray.length;i++)
		
			{
			document.getElementById(labelArray[i]).value = document.getElementById(labelArray[i]).value.replace(/^\s+/,"").replace(/\s+$/,"").replace(/\s+/g," ")
			
			
				if (document.getElementById(labelArray[i]).value == "")
					{
					document.getElementById("label_"+labelArray[i]).className = "alert"
					error = true
					}
				else 
					{
					document.getElementById("label_"+labelArray[i]).className = "bold"
						if(labelArray[i] == "snap_email") {
							re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    						if (! re.test(document.getElementById(labelArray[i]).value)) {
								document.getElementById("label_"+labelArray[i]).className = "alert"
								email = true;
							}
						}
					}
			
			}
		
		if (error)
		
			{
			alert("Please complete all fields highlighted in red.")
			return false
			}
		if (email)
		
			{
			alert("Please enter a valid email address.")
			return false
			}
		
		document.forms[0].submit()
		
		}

	function openHelp()
		{
		
			windowHeight = (screen.height - 150)
			helpLeft = (screen.width - 615)
			
			winAttributes = 'width=600, top=1, resizable=yes, scrollbars=yes, status=yes, titlebar=yes, height=' + windowHeight + ', left =' + helpLeft
			
			window.open('help.cfm','Help',winAttributes);
		}

</script>

</head>

<cfoutput>

<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0"#main_bg#>
<cfinclude template="includes/environment.cfm"> 

<cfif kFLGen_ImageSize.ImageWidth LT 265>

<!--- the logo is next to congrats --->

<table cellpadding="0" cellspacing="0" border="0" width="800">
<tr>
<td width="275" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
<td width="525" height="40" align="left" valign="bottom">#main_congrats#</td>
</tr>
</table>

<cfelse>

<!--- the logo extends over the congrats --->
<table cellpadding="0" cellspacing="0" border="0" width="800">

<tr>
<td colspan="2" style="padding:10px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
</tr>

<cfif welcome_congrats NEQ "&nbsp;" AND welcome_congrats NEQ "">
<tr>
<td width="275"><img src="pics/program/shim.gif" width="275" height="1"></td>
<td width="525" height="40" align="left" valign="bottom">#welcome_congrats#</td>
</tr>
</cfif>

</table>

</cfif>

<table cellpadding="0" cellspacing="0" border="0" width="800">

<tr>
<td colspan="3" width="800" height="5"><img src="pics/shim.gif" width="25" height="5"><img src="pics/shim.gif" width="355" height="5"#cross_color#></td>
</tr>

<tr>
<td width="200" valign="top" align="center">

	<br />
	
	<cfif help_button NEQ "">
	
	<table cellpadding="8" cellspacing="1" border="0" width="150">
		
	<tr>
	<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="openHelp()">#help_button#</td>
	</tr>
	
	</table>
	
	</cfif>

	<img src="pics/shim.gif" width="200" height="1">
	
</td>
<td width="5" height="100" valign="top"><img src="pics/shim.gif" width="5" height="175"#cross_color#></td>
<td width="725" valign="top" style="padding:12px">

	<cfif NOT transactionsuccessful>
		<span class="alert">
			Credit Card Authorization Failed.<br><br>Please enter your credit card information to try again.<br><br>
			<cfif ccc_ResponseCode NEQ "" OR ccc_ResponseReasonCode NEQ "">
				Code: #ccc_ResponseCode#&nbsp;&nbsp;&nbsp;&nbsp;Reason Code: #ccc_ResponseReasonCode#<br><br>
			</cfif>
			Reason: #ccc_ResponseReasonText#<br><br>
		</span>
	</cfif>


<!--- ********************************* --->
<!---  getting the cart display info    --->
<!--- ********************************* --->

<!--- is the order var set already --->
<!--- find items in the order --->
<cfif order_ID EQ "">
	<cfif IsDefined('cookie.itc_order') AND #cookie.itc_order# IS NOT "">
		<!--- authenticate order cookie --->
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_order,1,"-")) EQ ListGetAt(cookie.itc_order,2,"-")>
			<cfset order_ID = ListGetAt(cookie.itc_order,1,"-")>
		<cfelse>
			<!--- order cookie not authentic --->
			<cflocation addtoken="no" url="zkick.cfm">
		</cfif>
	<cfelse>
		<cflocation addtoken="no" url="zkick.cfm">
	</cfif>
</cfif>
 
<cfquery name="FindOrderItems" datasource="#application.DS#">
	SELECT ID AS inventory_ID, snap_meta_name, snap_description, snap_productvalue, quantity, snap_options
	FROM #application.database#.inventory
	WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
</cfquery>

<!--- get user vars --->
<cfif AuthenticateProgramUserCookie()>
	<!--- because boolean --->
</cfif>

<!--- get user info --->			
			<cfquery name="GetUserInfo" datasource="#application.DS#">
				SELECT
					u.fname, u.lname, u.ship_company, u.ship_fname, u.ship_lname, u.ship_address1, u.ship_address2,
					u.ship_city, u.ship_state, u.ship_zip, u.phone, u.email, u.bill_company, u. bill_fname,
					u.bill_lname, u.bill_address1, u. bill_address2, u. bill_city, u. bill_state, u. bill_zip,
					IFNULL(f.ID,0) AS forwarding_ID,
					f.company,
					f.address1,
					f.address2,
					f.city,
					f.state,
					f.zip,
					f.country
				FROM #application.database#.program_user u
				LEFT JOIN #application.database#.forwarding_address f ON f.ID = u.forwarding_ID AND f.program_ID = u.program_ID
				WHERE u.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">
			</cfquery>
			<cfset fname = HTMLEditFormat(GetUserInfo.fname)>
			<cfset lname = HTMLEditFormat(GetUserInfo.lname)>
			<cfset ship_company = HTMLEditFormat(GetUserInfo.ship_company)>
			<cfset ship_fname = HTMLEditFormat(GetUserInfo.ship_fname)>
			<cfset ship_lname = HTMLEditFormat(GetUserInfo.ship_lname)>
			<cfset ship_address1 = HTMLEditFormat(GetUserInfo.ship_address1)>
			<cfset ship_address2 = HTMLEditFormat(GetUserInfo.ship_address2)>
			<cfset ship_city = HTMLEditFormat(GetUserInfo.ship_city)>
			<cfset ship_state = HTMLEditFormat(GetUserInfo.ship_state)>
			<cfset ship_zip = HTMLEditFormat(GetUserInfo.ship_zip)>
			<cfset phone = HTMLEditFormat(GetUserInfo.phone)>
			<cfset email = HTMLEditFormat(GetUserInfo.email)>
			<cfset bill_company = HTMLEditFormat(GetUserInfo.bill_company)>
			<cfset bill_fname = HTMLEditFormat(GetUserInfo.bill_fname)>
			<cfset bill_lname = HTMLEditFormat(GetUserInfo.bill_lname)>
			<cfset bill_address1 = HTMLEditFormat(GetUserInfo.bill_address1)>
			<cfset bill_address2 = HTMLEditFormat(GetUserInfo.bill_address2)>
			<cfset bill_city = HTMLEditFormat(GetUserInfo.bill_city)>
			<cfset bill_state = HTMLEditFormat(GetUserInfo.bill_state)>
			<cfset bill_zip = HTMLEditFormat(GetUserInfo.bill_zip)>
	
	<table cellpadding="3" cellspacing="1" border="0" width="100%">
	
	<tr>
	<td class="active_cell" colspan="<cfif is_one_item>1<cfelse>4</cfif>">Cart Contents</td>
	</tr>
	
	<tr>
	<td class="cart_cell"><b>Description</b></td>
	<cfif NOT is_one_item>
	<td class="cart_cell" align="center"><b>Quantity</b></td>
	<td class="cart_cell" colspan="2" align="center"><b>#credit_desc#</b></td>
	</cfif>
	</tr>
	
 	<cfloop query="FindOrderItems">
	
	<tr>
	<td class="cart_cell">#snap_meta_name#<cfif snap_options NEQ ""><br>#snap_options#</cfif></td>
	<cfif NOT is_one_item>
	<td class="cart_cell" align="center">#quantity#</td>
	<td class="cart_cell">#NumberFormat(snap_productvalue * credit_multiplier,'0.00')# <span class="sub">each</span></td>
	<td class="cart_cell" align="right">#NumberFormat(snap_productvalue * quantity * credit_multiplier,'0.00')#</td>
	</cfif>
	</tr>
	
	<cfset carttotal = carttotal + (snap_productvalue * quantity)>
	
	</cfloop>
	<cfif accepts_cc LT 1 AND (user_total * points_multiplier) - (carttotal * credit_multiplier) LT 0>
		<cflocation url="cart.cfm" addtoken="no">
	</cfif>
	<cfif NOT is_one_item>
	
	<tr>
	<td align="right" colspan="3"><b>Order Total:</b> </td>
	<td align="right"><b>#NumberFormat(carttotal * credit_multiplier,'0.00')#</b></td>
	</tr>

	<tr>
	<td align="right" colspan="4">&nbsp;</td>
	</tr>
	
	<tr>
	<td align="right" colspan="3"><b>Total #credit_desc#: </b></td>
	<td align="right"><b>#NumberFormat(user_total * points_multiplier,'0.00')#</b></td>
	</tr>
	
	<tr>
	<td align="right" colspan="3"><b>Less This Order:</b> </td>
	<td align="right"><b>#NumberFormat(carttotal * credit_multiplier,'0.00')#</b></td>
	</tr>

	<tr>
	<td align="right" colspan="3"><b>Remaining #credit_desc#:</b> </td>
	<td align="right"><b>#NumberFormat(Max( (user_total * points_multiplier) - (carttotal * credit_multiplier),0),'0.00')#</b></td>
	</tr>
			
	<cfif user_total - carttotal LT 0 AND accepts_cc GTE 1>
<!--- there is a balance due --->
	<tr>
	<td align="right" colspan="3" class="alert">Balance Due: </td>
	<td class="alert" align="right">$ #NumberFormat(carttotal - user_total,'0.00')#</td>
	</tr>
	</cfif>
	</cfif>
	</table>
	
	<cfif user_total - carttotal LT 0 AND accepts_cc GTE 1 AND NOT is_one_item><br><br><b>#cart_exceeded_msg#</b></cfif>

	<br><br>
	<div align="center"><a href="cart.cfm">Return to Cart</a></div>
	<br><br>
	<b>Bold</b> fields are required to complete your order.
	<br><br>

	<form method="post" action="#CurrentPage#" name="order_form" onsubmit="return validateOnSubmit()" >
	
	<table cellpadding="3" cellspacing="1" border="0" width="100%">
	
	<tr>
	<td class="active_cell" colspan="2">Your Name </td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_fname">First&nbsp;Name</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_fname" id="snap_fname" value="#fname#">
	<input type="hidden" name="snap_fname_required" value="You must enter a first name."></td>
	</tr>
		
	<tr>
	<td align="right"><b><span id="label_snap_lname">Last&nbsp;Name</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_lname" id="snap_lname" value="#lname#">
	<input type="hidden" name="snap_lname_required" value="You must enter a last name."></td>
	</tr>
		
	<tr>
	<td class="active_cell" colspan="2">Shipping Information&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="namesame" onclick="SameName()"> <span style="font-weight:normal">Use first and last name from above.</span></td>
	</tr>
	
	<tr>
	<td align="right">Company&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_ship_company" value="#left(ship_company,30)#"></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_ship_fname">First&nbsp;Name</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_ship_fname" id="snap_ship_fname" value="#ship_fname#">
	<input type="hidden" name="snap_ship_fname_required" value="You must enter a first name for shipping."></td>
	</tr>
		
	<tr>
	<td align="right"><b><span id="label_snap_ship_lname">Last&nbsp;Name</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_ship_lname" id="snap_ship_lname" value="#ship_lname#">
	<input type="hidden" name="snap_ship_lname_required" value="You must enter a last name for shipping."></td>
	</tr>
		
	<tr>
	<td align="right"><b><span id="label_snap_ship_address1">Address&nbsp;Line&nbsp;1</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_ship_address1" id="snap_ship_address1" value="#left(ship_address1,30)#">
	<input type="hidden" name="snap_ship_address1_required" value="You must enter address information for shipping."></td>
	</tr>
	
	<tr>
	<td align="right">Address&nbsp;Line&nbsp;2&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_ship_address2" value="#ship_address2#"></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_ship_city">City</span></b> </td>
	<td valign="top"><input type="text" name="snap_ship_city" id="snap_ship_city" value="#ship_city#" maxlength="30" size="60">
	<input type="hidden" name="snap_ship_city_required" value="You must enter a city for shipping."></td>
	</tr>
	
	<tr>
	<td align="right" valign="top"><b>State</b> </td>
	<td valign="top"><cfoutput>#FLGen_SelectState("snap_ship_state","#ship_state#","true")#</cfoutput> <span class="sub">(select last option if international)</span></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_ship_zip">Zip Code</span></b> </td>
	<td valign="top"><input type="text" name="snap_ship_zip" id="snap_ship_zip" value="#ship_zip#" maxlength="10" size="60">
	<input type="hidden" name="snap_ship_zip_required" value="You must enter a zip code for shipping."></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_phone">Phone</span></b> </td>
	<td><input type="text" size="60" maxlength="35" name="snap_phone" id="snap_phone" value="#phone#">
	<input type="hidden" name="snap_phone_required" value="You must enter a daytime phone number."></td>
	</tr>
		
	<tr>
	<td align="right"><b><span id="label_snap_email">Email</span></b> </td>
	<td><input type="text" size="60" maxlength="128" name="snap_email" id="snap_email" value="#email#">
	<input type="hidden" name="snap_email_required" value="You must enter an email."></td>
	</tr>
		<cfif GetUserInfo.forwarding_ID NEQ 0>
			<tr>
			<td class="active_cell" colspan="2">Forward From</td>
			</tr>
	
			<tr class="content">
			<td align="right"></td>
			<td>#GetUserInfo.company#</td>
			</tr>
			<tr class="content">
			<td align="right"></td>
			<td>#GetUserInfo.address1#</td>
			</tr>
			<tr class="content">
			<td align="right"></td>
			<td>#GetUserInfo.address2#</td>
			</tr>
			<tr class="content">
			<td align="right"></td>
			<td>#GetUserInfo.city#, #GetUserInfo.state# #GetUserInfo.zip#</td>
			</tr>
		</cfif>	
	<!--- only if there is a balance due --->
	<!--- only if there is a balance due --->
	<!--- only if there is a balance due --->
	
<cfif user_total - carttotal LT 0 AND accepts_cc GTE 1 AND NOT is_one_item>
	
	<tr>
	<td class="active_cell" colspan="4">Credit Card Information</td>
	</tr>
		
	<tr>
	<td>&nbsp;</td>
	<td><img src="pics/program/creditcards.jpg" width="168" height="23"></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_cc_number">Card Number</span></b>&nbsp;</td>
	<td><input type="text" size="18" maxlength="16" name="cc_number" id="cc_number">
	<input type="hidden" name="cc_number_required" value="You must enter a credit card number.">&nbsp;&nbsp;&nbsp;&nbsp;<b>Expires:</b>&nbsp;#FLGen_SelectCCMonths()# #FLGen_SelectCCYears()#
	</td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_cid_number">CID</span></b>&nbsp;</td>
	<td><input type="text" size="5" maxlength="5" name="cid_number" id="cid_number"> <input type="hidden" name="cid_number_required" value="You must enter a CID number."> <a href="checkout_CID.cfm" target="_blank">What is the CID?</a>
	</td>
	</tr>
	
	<tr>
	<td class="active_cell" colspan="2">Billing Information&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="billingsame" onclick="CopyAddress()"> <span style="font-weight:normal">Same as shipping information.</span></td>
	</tr>
	
	<tr>
	<td align="right">Company&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_bill_company" value="#bill_company#"></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_bill_fname">First&nbsp;Name</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_bill_fname" id="snap_bill_fname" value="#bill_fname#">
	<input type="hidden" name="snap_bill_fname_required" value="You must enter a first name for billing."></td>
	</tr>
		
	<tr>
	<td align="right"><b><span id="label_snap_bill_lname">Last&nbsp;Name</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_bill_lname" id="snap_bill_lname" value="#bill_lname#">
	<input type="hidden" name="snap_bill_lname_required" value="You must enter a last name for billing."></td>
	</tr>
		
	<tr>
	<td align="right"><b><span id="label_snap_bill_address1">Address&nbsp;Line&nbsp;1</span></b>&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_bill_address1" id="snap_bill_address1" value="#bill_address1#">
	<input type="hidden" name="snap_bill_address1_required" value="You must enter a address information for billing."></td>
	</tr>
	
	<tr>
	<td align="right">Address&nbsp;Line&nbsp;2&nbsp;</td>
	<td><input type="text" size="60" maxlength="30" name="snap_bill_address2" value="#bill_address2#"></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_bill_city">City</span></b> </td>
	<td valign="top"><input type="text" name="snap_bill_city" id="snap_bill_city" value="#bill_city#" maxlength="30" size="60">
	<input type="hidden" name="snap_bill_city_required" value="You must enter a city for billing."></td>
	</tr>
	
	<tr>
	<td align="right" valign="top"><b>State</b> </td>
	<td valign="top"><cfoutput>#FLGen_SelectState("snap_bill_state","#bill_state#","true")#</cfoutput> <span class="sub">(select last option if international)</span></td>
	</tr>
	
	<tr>
	<td align="right"><b><span id="label_snap_bill_zip">Zip</span></b> </td>
	<td valign="top"><input type="text" name="snap_bill_zip" id="snap_bill_zip" value="#bill_zip#" maxlength="10" size="60">
	<input type="hidden" name="snap_bill_zip_required" value="You must enter a zip code for billing."></td>
	</tr>
	
</cfif>

	<tr>
	<td class="active_cell" colspan="4">Special Instructions </td>
	</tr>
	
	<tr>
	<td align="right" valign="top">&nbsp;</td>
	<td><textarea name="order_note" cols="58" rows="4"></textarea></td>
	</tr>
	
	<tr>
	<td align="center" valign="top" colspan="2"><b>Please review the shipping information before placing your order.<br><br>Allow 4 -6 weeks for delivery of your gift.</b></td>
	</tr>
	
	<tr>
	<td colspan="2" align="center">
		
		<table cellpadding="8" cellspacing="1" border="0">
			
		<tr>
		<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="validateOnSubmit();">Place Order</td>
		</tr>
		
		</table>
	
	</td>
	</tr>
	
	</table>


	</form>
	
</td></tr>


</table>

<script language="javascript">
		labelArray = new Array("snap_fname","snap_lname","snap_ship_fname","snap_ship_lname","snap_ship_address1","snap_ship_city","snap_ship_zip","snap_phone","snap_email"<cfif user_total - carttotal LT 0 AND accepts_cc GTE 1 AND NOT is_one_item>,"cc_number","cid_number","snap_bill_fname","snap_bill_lname","snap_bill_address1","snap_bill_city","snap_bill_zip"</cfif>)

</script>

</body>

</cfoutput>

</html>