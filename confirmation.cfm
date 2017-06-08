<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<cfset this_carttotal = "0">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>

<!--- delete order and user cookies --->
<cfcookie name="itc_order" expires="now" value="">
<cfcookie name="itc_user" expires="now" value="">

<!--- get the order_ID and user_ID from the survey cookie --->
<cfoutput>#AuthenticateSurveyCookie()#</cfoutput>

<CFSCRIPT>
	kFLGen_ImageSize = FLGen_ImageSize(application.FilePath & "pics/program/" & vLogo);
</CFSCRIPT>

<!---  process survey if submitted --->
<cfif IsDefined('form.submitsurvey') AND form.submitsurvey IS NOT "">

	<cfoutput>#ProcessCustomerSurvey()#</cfoutput>

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
<td colspan="2" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
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
<td width="725" valign="top" style="padding:25px">

<!--- ********************************* --->
<!---  getting the cart display info    --->
<!--- ********************************* --->

<!--- get order info --->
<cfquery name="FindOrderInfo" datasource="#application.DS#">
	SELECT snap_fname, snap_lname, snap_ship_company, snap_ship_fname, snap_ship_lname, snap_ship_address1, snap_ship_address2, snap_ship_city, snap_ship_state, snap_ship_zip, snap_phone, snap_email, snap_bill_company, snap_bill_fname, snap_bill_lname, snap_bill_address1, snap_bill_address2, snap_bill_city, snap_bill_state, snap_bill_zip, order_note
	FROM #application.database#.order_info
	WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
</cfquery>
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
<cfset snap_bill_company = HTMLEditFormat(FindOrderInfo.snap_bill_company)>
<cfset snap_bill_fname = HTMLEditFormat(FindOrderInfo.snap_bill_fname)>
<cfset snap_bill_lname = HTMLEditFormat(FindOrderInfo.snap_bill_lname)>
<cfset snap_bill_address1 = HTMLEditFormat(FindOrderInfo.snap_bill_address1)>
<cfset snap_bill_address2 = HTMLEditFormat(FindOrderInfo.snap_bill_address2)>
<cfset snap_bill_city = HTMLEditFormat(FindOrderInfo.snap_bill_city)>
<cfset snap_bill_state = HTMLEditFormat(FindOrderInfo.snap_bill_state)>
<cfset snap_bill_zip = HTMLEditFormat(FindOrderInfo.snap_bill_zip)>
<cfset order_note = HTMLEditFormat(FindOrderInfo.order_note)>

<!--- find order items --->
<cfquery name="FindOrderItems" datasource="#application.DS#">
	SELECT ID AS inventory_ID, snap_meta_name, snap_description, snap_productvalue, quantity, snap_options
	FROM #application.database#.inventory
	WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
</cfquery>
 

	<span class="main_instructions">You will receive an email confirmation of your order.</span>
	<br><br>
	
	<table cellpadding="3" cellspacing="1" border="0">
	
	<tr>
	<td colspan="<cfif is_one_item>1<cfelse>4</cfif>"><b>Order for #snap_fname# #snap_lname# (#snap_email#)</b></td>
	</tr>
	
	<tr>
	<td colspan="<cfif is_one_item>1<cfelse>4</cfif>">&nbsp;</td>
	</tr>
	
	<tr>
	<td><b>Description</b></td>
	<cfif NOT is_one_item>
	<td align="center"><b>Quantity</b></td>
	<td colspan="2" align="center"><b>#credit_desc#</b></td>
	</cfif>
	</tr>
	
 	<cfloop query="FindOrderItems">
	
	<tr>
	<td>#snap_meta_name#<cfif snap_options NEQ ""><br>#snap_options#</cfif></td>
	<cfif NOT is_one_item>
	<td align="center">#quantity#</td>
	<td>#NumberFormat(snap_productvalue * credit_multiplier,'0.00')# <span class="sub">each</span></td>
	<td align="right">#NumberFormat(snap_productvalue * quantity * credit_multiplier,'0.00')#</td>
	</cfif>
	</tr>
	
	<cfif NOT is_one_item>
		<cfset this_carttotal = this_carttotal + (snap_productvalue * quantity)>
	</cfif>
	
	</cfloop>
	
	<cfif NOT is_one_item>
	
	<tr>
	<td align="right" colspan="3"><b>Order Total:</b> </td>
	<td align="right"><b>#NumberFormat(this_carttotal * credit_multiplier,'0.00')#</b></td>
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
	<td align="right"><b>#NumberFormat(this_carttotal * credit_multiplier,'0.00')#</b></td>
	</tr>

	<tr>
	<td align="right" colspan="3"><b>Remaining #credit_desc#:</b> </td>
	<td align="right"><b>#NumberFormat(Max((user_total * points_multiplier) - (this_carttotal * credit_multiplier),0),'0.00')#</b></td>
	</tr>
			
	<cfif user_total - this_carttotal LT 0 AND accepts_cc GTE 1>
<!--- there is a balance due --->
	<tr>
	<td align="right" colspan="3"><span class="alert">Balance Charged to Credit Card:</span> </td>
	<td class="alert">$ #NumberFormat(this_carttotal - user_total,'0.00')#</td>
	</tr>
	</cfif>
	</cfif>
	</table>
	
	<br><br>
	
	<table cellpadding="3" cellspacing="1" border="0">
			
	<tr>
	<td><b>Shipping Information</b></td>
	<td><cfif snap_bill_fname NEQ ""><b>Billing Information</b><cfelse>&nbsp;</cfif></td>
	</tr>
	
	<tr>
	<td>
	<cfif snap_ship_company NEQ "">#snap_ship_company#</cfif><br>
	<cfif snap_ship_fname NEQ "">#snap_ship_fname#</cfif> <cfif snap_ship_lname NEQ "">#snap_ship_lname#</cfif><br>
	<cfif snap_ship_address1 NEQ "">#snap_ship_address1#<br></cfif>
	<cfif snap_ship_address2 NEQ "">#snap_ship_address2#<br></cfif>
	<cfif snap_ship_city NEQ "">#snap_ship_city#</cfif>, <cfif snap_ship_state NEQ "">#snap_ship_state#</cfif> <cfif snap_ship_zip NEQ "">#snap_ship_zip#</cfif><br>
	<cfif snap_phone NEQ "">Phone: #snap_phone#</cfif>
	</td>
	<td>
	<cfif snap_bill_fname NEQ "">
	<cfif snap_bill_company NEQ "">#snap_bill_company#</cfif><br>
	<cfif snap_bill_fname NEQ "">#snap_bill_fname#</cfif> <cfif snap_bill_lname NEQ "">#snap_bill_lname#</cfif><br>
	<cfif snap_bill_address1 NEQ "">#snap_bill_address1#<br></cfif>
	<cfif snap_bill_address2 NEQ "">#snap_bill_address2#<br></cfif>
	<cfif snap_bill_city NEQ "">#snap_bill_city#</cfif>, <cfif snap_bill_state NEQ "">#snap_bill_state#</cfif> <cfif snap_bill_zip NEQ "">#snap_bill_zip#</cfif><br>
	<cfelse>&nbsp;</cfif>
	</td>
	</tr>
	
	<tr>
	<td colspan="2">&nbsp;</td>
	</tr>

	<tr>
	<td colspan="2"><b>Special Instructions</b></td>
	</tr>

	<tr>
	<td colspan="2"><cfif order_note NEQ "">#Replace(order_note,chr(10),"<br>","ALL")#<cfelse>(none)</cfif></td>
	</tr>

	</table>
	
	<br><br>
	
	<cfif has_survey>
		<cfoutput>#CustomerSurvey("order")#</cfoutput>
	</cfif>
	
</td></tr>


</table>

</body>

</cfoutput>

</html>