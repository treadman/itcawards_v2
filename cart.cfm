<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>

<cfparam name="cc_max" default="0">
<cfset order_ID = "">
<cfset carttotal = "0">
<cfparam name="c" default="">
<cfparam name="p" default="">
<cfparam name="g" default="">
<cfparam name="OnPage" default="">

<!--- *********************************      --->
<!---  processing an addition to the cart    --->
<!--- *********************************      --->

<!--- if passing a product ID in url --->
<cfif IsDefined('URL.iprod') AND URL.iprod IS NOT "">
	<!--- make sure program user is logged in --->
	<cfif IsDefined('cookie.itc_user') AND cookie.itc_user IS NOT "">
		<!--- authenticate itc_user cookie --->
		<cfif AuthenticateProgramUserCookie()>
			<!--- check for order cookie --->
			<cfif IsDefined('cookie.itc_order') AND cookie.itc_order IS NOT "">
				<!--- authenticate order cookie --->
				<cfif FLGen_CreateHash(ListGetAt(cookie.itc_order,1,"-")) EQ ListGetAt(cookie.itc_order,2,"-")>
					<cfset order_ID = ListGetAt(cookie.itc_order,1,"-")>
				<cfelse>
					<!--- order cookie not authentic --->
					<cflocation addtoken="no" url="zkick.cfm">
				</cfif>
			<cfelse>
				<!--- add new order, and get order_ID --->
				<cflock name="order_infoLock" timeout="10">
					<cftransaction>
						<cfset aToday = FLGen_DateTimeToMySQL()>
						<cfquery name="StartOrder" datasource="#application.DS#">
							INSERT INTO #application.database#.order_info
								(created_user_ID, created_datetime, program_ID)
							VALUES (
								<cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">,
								'#FLGen_DateTimeToMySQL()#',
								<cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
							)
						</cfquery>
						<cfquery datasource="#application.DS#" name="getPK">
							SELECT Max(ID) As MaxID FROM #application.database#.order_info
						</cfquery>
					</cftransaction>  
				</cflock>
				<cfset order_ID = getPK.MaxID>
				<!--- hash admin_login ID --->
				<cfset OrderIDHash = FLGen_CreateHash(getPK.MaxID)>
				<!--- write cookies --->
				<cfcookie name="itc_order" value="#getPK.MaxID#-#OrderIDHash#">
			</cfif>
			<!--- get the product's value --->
			<cfquery name="FindProdValue" datasource="#application.DS#">
				SELECT pvm.productvalue AS ThisPValue, pm.meta_name AS meta_name, pm.description AS description, p.sku AS sku, p.is_dropshipped
				FROM #application.product_database#.productvalue_master pvm
				JOIN #application.product_database#.product_meta pm ON pvm.ID = pm.productvalue_master_ID
				JOIN #application.product_database#.product p ON pm.ID = p.product_meta_ID
				WHERE p.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.iprod#">
			</cfquery>
			<!--- get the product's options --->
			<cfoutput>#FindProductOptions(URL.iprod)#</cfoutput>
			<!--- put item in the inventory table --->
			<cfquery name="InsertProduct" datasource="#application.DS#">
				INSERT INTO #application.database#.inventory
					(created_user_ID, created_datetime, product_ID, order_ID, quantity, snap_meta_name, snap_sku, snap_description, snap_productvalue, snap_options, snap_is_dropshipped)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">,
					'#FLGen_DateTimeToMySQL()#',
					<cfqueryparam cfsqltype="cf_sql_integer" value="#URL.iprod#" maxlength="10">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">,
					1,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FindProdValue.meta_name#" maxlength="64">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FindProdValue.sku#" maxlength="64">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#FindProdValue.description#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#FindProdValue.ThisPValue#" maxlength="80">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#FPO_theseoptions#">,
					<cfqueryparam cfsqltype="cf_sql_tinyint" value="#FindProdValue.is_dropshipped#" maxlength="1">
				)
			</cfquery>
<!--- TAKEN OUT AS OF 4/27/2005 PER Lou and Colleen who always want the user to go back to the shopping page --->
<!--- 
			<!--- if has used all points, stay here, otherwise, go back to main --->
			<cfquery name="CalcPoints" datasource="#application.DS#">
				SELECT SUM(snap_productvalue) AS order_total
				FROM #application.database#.inventory
				WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
			</cfquery>
			<cfset order_total = CalcPoints.order_total>
			
			<!--- if they still have points to spend, send back to shopping cart with message --->
			<cfif user_total - order_total GT 0>
				<cflocation addtoken="no" url="main.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#">
			</cfif>
 --->
			<cflocation addtoken="no" url="main.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#">
		<cfelse>
			<!--- if user cookie not authentic, kickout --->
			<cflocation addtoken="no" url="zkick.cfm">
		</cfif>
	<!--- if not logged into program as user, send to main_login --->
	<cfelse>
		<cflocation addtoken="no" url="main_login.cfm?iprod=#iprod#&prod=#prod#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#">
	</cfif>
</cfif>

<!--- *********************************      --->
<!---  processing recalculate button         --->
<!--- *********************************      --->
<cfif IsDefined('form.recalculate') AND form.recalculate IS NOT "">
	<cfif IsDefined('Form.FieldNames') AND Form.FieldNames IS NOT "">
		<cfoutput>
			<cfloop index="thisField" list="#Form.FieldNames#">
				<cfif thisField contains "q_" and Evaluate(thisField) NEQ "">
					<cfset thisinv = RemoveChars(thisField,1,2)>
					<cfif Evaluate(thisField) EQ 0>
						<cfquery name="DeleteInvItem" datasource="#application.DS#">
							DELETE FROM #application.database#.inventory
							WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisinv#" maxlength="10">
						</cfquery>
					<cfelse>
						<cfquery name="UpdateInvItems" datasource="#application.DS#">
							UPDATE #application.database#.inventory
							SET quantity = #Evaluate(thisField)#
							WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisinv#" maxlength="10">
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfoutput>
	</cfif>
</cfif>

<!--- *********************************      --->
<!---  processing checkout button         --->
<!--- *********************************      --->
<cfif IsDefined('form.checkout') AND form.checkout IS NOT "">
	<cflocation addtoken="no" url="checkout.cfm">
</cfif>

<cfinclude template="includes/header.cfm">
<cfoutput>
<table cellpadding="0" cellspacing="0" border="0" width="1200">
<tr>
<td colspan="3" width="800" height="5"><img src="pics/shim.gif" width="25" height="5"><img src="pics/shim.gif" width="355" height="5"#cross_color#></td>
</tr>
<tr>
<td width="200" valign="top" align="center">
	<br />
	<table cellpadding="8" cellspacing="1" border="0" width="150">
	<tr>
	<td align="center" class="active_cell">#menu_text#</td>
	</tr>
<cfif use_master_categories EQ 0 OR use_master_categories EQ 3>
	<!--- is this a one item store? --->
	<cfif NOT is_one_item>
		<!--- the categories for this program --->
		<cfquery name="SelectProgramCategories" datasource="#application.DS#">
			SELECT DISTINCT pvp.ID AS pvp_ID, pvp.productvalue_master_ID AS productvalue_master_ID, pvp.displayname AS displayname 
			FROM #application.product_database#.productvalue_program pvp
				JOIN #application.product_database#.productvalue_master pvm ON pvp.productvalue_master_ID = pvm.ID 
				JOIN #application.product_database#.product_meta pm ON pvm.ID = pm.productvalue_master_ID 
				JOIN #application.product_database#.product p ON pm.ID = p.product_meta_ID
			WHERE pvp.program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#" maxlength="10">
				<!--- the product is active and not excluded --->
				AND p.is_active = 1 
				AND p.is_discontinued = 0 
				AND ((SELECT COUNT(ID) FROM #application.database#.program_product_exclude ppe WHERE ppe.program_ID = #program_ID# AND ppe.product_ID = p.ID) = 0)
			ORDER BY pvp.sortorder ASC
		</cfquery>
		<cfloop query="SelectProgramCategories">
			<cfset cat_ID = HTMLEditFormat(SelectProgramCategories.pvp_ID)>
			<cfset pvm_ID = HTMLEditFormat(SelectProgramCategories.productvalue_master_ID)>
			<cfset displayname = HTMLEditFormat(SelectProgramCategories.displayname)>
			<tr>
			<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='main.cfm?c=#cat_ID#&p=#pvm_ID#&g=&OnPage=1'">
				#displayname#
				</td>
			</tr>
		</cfloop>
	</cfif>
<cfelse>
	
	<tr><td align="center"><cfinclude template="includes/product_group_menu.cfm"></td></tr>
</cfif>
	<cfif can_defer>
		<tr>
		<td>&nbsp;</td>
		</tr>
		<tr>
		<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='main_login.cfm?defer=yes'">Deferral Options</td>
		</tr>
	</cfif>
	<cfif help_button NEQ "">
		<tr>
		<td>&nbsp;</td>
		</tr>
		<tr>
		<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="openHelp()">#help_button#</td>
		</tr>
	</cfif>
	<cfif additional_content2_button NEQ "">
		<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='additional_content.cfm?n=2'">#additional_content2_button#</td></tr>
		<tr><td>&nbsp;</td></tr>
	</cfif>
	<cfif additional_content_button NEQ "">
		<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='additional_content.cfm'">#additional_content_button#</td></tr>
		<tr><td>&nbsp;</td></tr>
	</cfif>
	<cfif has_welcomepage>
		<tr><td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='welcome.cfm'">Return To Welcome Page</td></tr>
		<tr><td>&nbsp;</td></tr>
	</cfif>
	</table>
	<br>
	<img src="pics/shim.gif" width="200" height="1">
</td>
<td width="5" height="100" valign="top"><img src="pics/shim.gif" width="5" height="175"#cross_color#></td>
<td valign="top" style="padding:12px" align="center">

<!--- ********************************* --->
<!---  getting the cart display info    --->
<!--- ********************************* --->

<!--- is the order var set already --->
<!--- find items in the order --->
<cfif order_ID EQ "">
	<cfif IsDefined('cookie.itc_order') AND cookie.itc_order IS NOT "">
		<!--- authenticate order cookie --->
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_order,1,"-")) EQ ListGetAt(cookie.itc_order,2,"-")>
			<cfset order_ID = ListGetAt(cookie.itc_order,1,"-")>
			<!--- *********************************      --->
			<!---  processing remove button         --->
			<!--- *********************************      --->
			<cfif IsDefined('remove') AND remove IS NOT "">
				<cfquery name="RemoveInvItem" datasource="#application.DS#">
					DELETE FROM #application.database#.inventory
					WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#remove#" maxlength="10">
						AND order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
				</cfquery>
			</cfif>
			<cfquery name="FindOrderItems" datasource="#application.DS#">
				SELECT ID AS inventory_ID, snap_meta_name, snap_description, snap_productvalue, quantity, snap_options
				FROM #application.database#.inventory
				WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#" maxlength="10">
			</cfquery>
			<cfif FindOrderItems.RecordCount GT 0>
				<cfset HasOrder = true>
			<cfelse>
				<cfset HasOrder = false>
				<cfset carttotal = 0>
				<cfset user_total = 0>
			</cfif>
		<cfelse>
			<!--- order cookie not authentic --->
			<!--- <cflocation addtoken="no" url="zkick.cfm"> --->
			<cfset HasOrder = false>
			<cfset carttotal = 0>
			<cfset user_total = 0>
		</cfif>
	<cfelse>
		<!--- <cflocation addtoken="no" url="zkick.cfm"> --->
		<cfset HasOrder = false>
		<cfset carttotal = 0>
		<cfset user_total = 0>
	</cfif>
</cfif>
 

<!--- get user info --->
<cfif AuthenticateProgramUserCookie()>
</cfif>

<cfif HasOrder>
	<form method="post" action="#CurrentPage#">
	<table cellpadding="5" cellspacing="1" border="0" width="70%">
	<tr>
		<td class="active_cell" colspan="<cfif is_one_item>2<cfelse>5</cfif>">Cart Contents</td>
	</tr>
	<tr>
		<td class="cart_cell"><b>Remove</b></td>
		<td class="cart_cell"><b>Description</b></td>
		<cfif NOT is_one_item>
			<td class="cart_cell" align="center"><b>Quantity</b></td>
			<td class="cart_cell" colspan="2"><b>#credit_desc#</b></td>
		</cfif>
	</tr>
	<cfloop query="FindOrderItems">
		<tr>
			<td class="cart_cell" align="center">
				<img src="pics/program/remove-x.gif" width="12" height="12" onClick="window.location='#CurrentPage#?remove=#inventory_ID#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'" style="cursor:pointer">
			</td>
			<td class="cart_cell">#snap_meta_name#<cfif snap_options NEQ ""><br>#snap_options#</cfif></td>
			<cfif NOT is_one_item>
				<td class="cart_cell" align="center">
					<input type="text" size="4" maxlength="3" name="q_#inventory_ID#" value="#quantity#">
					<input type="hidden" name="q_#inventory_ID#_required" value="Quantities can't be empty.  If you want to remove the gift from your cart, make the quantity to zero and click Recalculate.">
				</td>
				<td class="cart_cell">#NumberFormat(snap_productvalue * credit_multiplier,'0.00')# <span class="sub">each</span></td>
				<td class="cart_cell" align="right">#NumberFormat(snap_productvalue * quantity * credit_multiplier,'0.00')#</td>
			</cfif>
		</tr>
		<cfset carttotal = carttotal + (snap_productvalue * quantity)>
	</cfloop>
	<cfif NOT is_one_item>
		<tr>
			<td align="right" colspan="4"><b>Order Total: </b></td>
			<td align="right"><b>#NumberFormat(carttotal * credit_multiplier,'0.00')#</b></td>
		</tr>
		<tr>
			<td align="right" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td align="right" colspan="4"><b>Total #credit_desc#: </b></td>
			<td align="right"><b>#NumberFormat(user_total * points_multiplier,'0.00')#</b></td>
		</tr>
		<tr>
			<td align="right" colspan="4"><b>Less This Order:</b> </td>
			<td align="right"><b>#NumberFormat(carttotal * credit_multiplier,'0.00')#</b></td>
		</tr>
		<tr>
			<td align="right" colspan="4"><b>Remaining #credit_desc#:</b> </td>
			<td align="right"><b>#NumberFormat(Max((user_total * points_multiplier) - (carttotal * credit_multiplier),0),'0.00')#</b></td>
		</tr>
		<cfif user_total - carttotal LT 0 AND accepts_cc GTE 1>
			<!--- there is a balance due --->
			<tr>
				<td align="right" colspan="4" class="alert">Balance Due: </td>
				<td class="alert" align="right">$ #NumberFormat(carttotal - user_total,'0.00')#</td>
			</tr>
		</cfif>
		<tr>
			<td align="right" colspan="4">&nbsp;</td>
		</tr>
	</cfif>
	<tr>
	<td align="right" colspan="<cfif is_one_item>2<cfelse>5</cfif>">
		<cfoutput><input type="button" name="Continue Shopping" value="Continue Shopping" onClick="window.location='main.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'"></cfoutput>
		<cfif NOT is_one_item>
			&nbsp;&nbsp;&nbsp;<input type="submit" name="recalculate" value="Recalculate">
		</cfif>
		&nbsp;&nbsp;&nbsp;
		<!--- only display the checkout button if:
			1) the cart total is less than the user's available credits
			2) OR if they do take cc (value 1) and the cart amount is lte the (user total PLUS the cc_max) 
			3) OR if they take cc (value 2) w/o max 
			4) OR is a one item store and there is only one item in their cart --->
		<cfif carttotal*credit_multiplier LTE user_total*points_multiplier OR (accepts_cc EQ 1 AND (carttotal LTE (cc_max + user_total))) OR accepts_cc EQ 2 OR (is_one_item AND FindOrderItems.RecordCount EQ 1)>
			<input type="submit" name="checkout" value="Checkout">
		</cfif>
		<input type="hidden" name="c" value="#c#">
		<input type="hidden" name="p" value="#p#">
		<input type="hidden" name="g" value="#g#">
		<input type="hidden" name="OnPage" value="#OnPage#">
	</td>
	</tr>
	</table>
	</form>
<cfelse>
	<br><br>
	<span class="alert">There are no gifts in your cart.</span> <cfif is_one_item><a href="main.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#">Continue Shopping</a></cfif>
</cfif>
<br><br>

<cfif is_one_item AND HasOrder>
	<cfif FindOrderItems.RecordCount GT 1>
		<span class="active_msg">You may select only 1 gift. You will have to remove #(FindOrderItems.RecordCount - 1)# gift<cfif FindOrderItems.RecordCount GT 2>s</cfif> to check out.</span>
		<!--- <span class="active_msg">You may only select one item. You will have to remove #FindOrderItems.RecordCount - (FindOrderItems.RecordCount - 1)# item(s) before you can check out.</span> --->
	<cfelseif FindOrderItems.RecordCount EQ 1>
		&nbsp;
	</cfif>
<cfelseif carttotal GT cc_max + user_total AND accepts_cc EQ 1>
	<span class="active_msg">
		You have exceeded the allowable personal credit card purchase limit.<br><br>You may only charge $#cc_max#.<br><br>
		#cc_exceeded_msg#
	</span>
<cfelseif carttotal*credit_multiplier GT user_total*points_multiplier>
	<span class="active_msg"><span class="active_msg">#cart_exceeded_msg#</span>
</cfif>
</cfoutput>
</td></tr>
</table>
</body>
</html>