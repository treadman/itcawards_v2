<cfif NOT isDefined("prod")>
	<cflocation url="main.cfm" addtoken="no">
</cfif>
<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>

<!--- c=category (productvalue_program_ID), p=productvalueID (productvalue_master_ID), g=group (?) --->
<cfparam name="c" default="">
<cfparam name="p" default="">
<cfparam name="g" default="">
<cfparam name="OnPage" default="1">

<!--- param all variables --->
<cfparam name="extrawhere_SelectDisplayProducts" default="">
<cfparam name="extrawhere_SelectProgramsAllGroups" default="">
<cfparam name="FirstEndRow" default="">

<cfinclude template="includes/header.cfm">
<table cellpadding="0" cellspacing="0" border="0" width="1200">
<tr>
	<td colspan="4" width="900" height="5"><img src="pics/shim.gif" width="25" height="5"><img src="pics/shim.gif" width="355" height="5"<cfoutput>#cross_color#</cfoutput>></td>
</tr>
<tr>
<td width="200" valign="top" align="center" >
	<br />
	<table cellpadding="8" cellspacing="1" border="0" width="150">
		<tr>
		<cfoutput><td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='main.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">#return_button#</td></cfoutput>
		</tr>
		<cfif help_button NEQ "">
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="openHelp()"><cfoutput>#help_button#</cfoutput></td>
			</tr>
		</cfif>
	</table>
	<br>
	<img src="pics/shim.gif" width="200" height="1">
</td>
<td width="5" height="100" valign="top"><img src="pics/shim.gif" width="5" height="175" <cfoutput>#cross_color#</cfoutput>></td>
<td width="930" valign="top" style="padding:13px" colspan="2" align="center">
	<cfquery name="SelectProductInfo" datasource="#application.DS#">
		SELECT pm.meta_name, pm.description, pm.imagename, IFNULL(ml.logoname,"shim.gif") AS logoname
		FROM #application.product_database#.product_meta pm
		LEFT JOIN #application.product_database#.manuf_logo ml ON pm.manuf_logo_ID = ml.ID
		WHERE pm.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#prod#" maxlength="10">
	</cfquery>
	<cfset meta_name = SelectProductInfo.meta_name>
	<cfset description = SelectProductInfo.description>
	<cfset imagename = HTMLEditFormat(SelectProductInfo.imagename)>
	<cfset logoname = HTMLEditFormat(SelectProductInfo.logoname)>
	<cfquery name="SelectProductCat" datasource="#application.DS#">
		SELECT category_name, ID
		FROM #application.product_database#.product_meta_option_category
		WHERE product_meta_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#prod#" maxlength="10">
		ORDER BY sortorder
	</cfquery>
	<!--- narrowing the results based on the dropdown --->
	<cfset narrow_results = "">
	<cfif IsDefined('Form.FieldNames') AND #Form.FieldNames# IS NOT "">
		<cfloop index="thisField" list="#Form.FieldNames#">
			<cfif thisField contains "cat_" and Evaluate(thisField) NEQ ""> 
				<cfset narrow_results = narrow_results & " AND #RemoveChars(Evaluate(thisField),1,4)#  IN (SELECT po.product_meta_option_ID FROM #application.product_database#.product_option po WHERE product_ID = p.ID) ">
			</cfif>
		</cfloop>
	</cfif>
	<cfquery name="SelectEachProduct" datasource="#application.DS#">
		SELECT pmo.option_name, pmoc.category_name, p.ID AS product_ID
		FROM #application.product_database#.product p
			LEFT JOIN #application.product_database#.product_option po ON p.ID = po.product_ID
			LEFT JOIN #application.product_database#.product_meta_option pmo ON po.product_meta_option_ID = pmo.ID
			LEFT JOIN #application.product_database#.product_meta_option_category pmoc ON pmo.product_meta_option_category_ID = pmoc.ID
		WHERE p.product_meta_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#prod#" maxlength="10"> 
			AND is_active = 1 
			AND is_discontinued = 0 
			 #narrow_results#
		ORDER BY p.sortorder, pmoc.sortorder
	</cfquery>
	<!--- PRODUCT DISPLAY --->
	<table cellpadding="0" cellspacing="1" border="0" width="970">
		<tr>
			<td class="product_name" width="100%"><cfoutput>#meta_name#</cfoutput></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0" border="0" width="930">
	<tr>
	<td align="center" width="50%" valign="top"><img src="pics/products/<cfoutput>#imagename#</cfoutput>" style="margin: 10px 10px 10px 0px"><br><img src="pics/manuf_logos/<cfoutput>#logoname#</cfoutput>"></td>
	<td valign="top" width="50%">
		<br>
		<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
		<td valign="top" class="product_description"><span class="product_instructions"><b>Description:</b></span><br><cfoutput>#Replace(description,chr(13) & chr(10),"<br>","ALL")#</cfoutput><br><br></td>
		</tr>
		<!--- ***************************   --->
		<!--- Multi Product Meta Select     --->
		<!--- ***************************   --->
		<cfif SelectProductCat.RecordCount NEQ 0>
			<tr>
			<td valign="top" class="active_cell" style="padding:5px ">Select one option from <cfif SelectProductCat.RecordCount EQ 1>the<cfelse>each</cfif> dropdown.</td>
			</tr>
			<tr>
			<td valign="top">
				<cfoutput>
				<form method="post" action="<cfoutput>#CurrentPage#</cfoutput>">
					<table width="100%" cellpadding="5" cellspacing="0" border="0">
					<cfloop query="SelectProductCat">
						<cfset category_name = HTMLEditFormat(SelectProductCat.category_name)>
						<cfset cat_ID = HTMLEditFormat(SelectProductCat.ID)>
						<cfquery name="SelectOptions" datasource="#application.DS#">
							SELECT pmo.option_name, pmo.ID AS opt_ID
							FROM #application.product_database#.product_meta_option pmo
							WHERE pmo.product_meta_option_category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cat_ID#" maxlength="10">
								AND (SELECT COUNT(prod.ID) FROM #application.product_database#.product prod JOIN #application.product_database#.product_option po ON prod.ID =  po.product_ID WHERE po.product_meta_option_ID = pmo.ID AND prod.is_active = 1 AND prod.is_discontinued = 0) > 0
							ORDER BY pmo.sortorder ASC 
						</cfquery>
						<tr>
						<td valign="top" align="right">#category_name#: </td>
						<td valign="top">
							<select name="cat_#cat_ID#"  onChange="submit()">
								<option value="">-- SELECT ONE #category_name# option --</option>
							<cfloop query="SelectOptions">
								<cfset ThisFormField = "form.cat_" & cat_ID>
								<cfif IsDefined('Form.FieldNames') AND Form.FieldNames IS NOT "">
									<cfset if_selected = IIF(Evaluate(ThisFormField) EQ "opt_" & SelectOptions.opt_ID, DE(" selected"),DE(""))>
								<cfelse>
									<cfset if_selected = "">
								</cfif>
									<option value="opt_#SelectOptions.opt_ID#"#if_selected#>#option_name#</option>
							</cfloop>
							</select>
						</td>
						</tr>
					</cfloop>
					</table>
					<input type="hidden" name="prod" value="#prod#">
					<input type="hidden" name="c" value="#c#">
					<input type="hidden" name="p" value="#p#">
					<input type="hidden" name="g" value="#g#">
					<input type="hidden" name="OnPage" value="#OnPage#">
				</form>
				</cfoutput>
				<table cellpadding="3" cellspacing="0" border="0" width="100%">
					<cfif IsDefined('Form.FieldNames') AND Form.FieldNames IS NOT "">
						<tr>
						<td colspan="2" class="alert" align="right"><cfoutput><a href="#CurrentPage#?prod=#prod#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#">Clear Options</a></cfoutput></td>
						</tr>
					</cfif>
					<cfif SelectEachProduct.RecordCount EQ 0>
						<tr>
						<td colspan="2" class="alert" align="center">No products with those options.</td>
						</tr>
					</cfif>
					<!--- oset var that indicates that only one prod was found --->
					<cfif SelectProductCat.RecordCount EQ 0>
						<cfset thismeansone = 1>
					<cfelse>
						<cfset thismeansone = SelectProductCat.RecordCount>
					</cfif>
					<!--- only display products if one and only one found --->
					<cfif SelectEachProduct.RecordCount EQ thismeansone>
						<cfoutput query="SelectEachProduct" group="product_ID">
							<tr>
							<td style="border-width:1px 0px 1px 1px; border-style:solid; border-color:###bg_active#">
								<table cellpadding="2" cellspacing="0" border="0">
								<tr>
								<td align="right">#SelectEachProduct.category_name#: </td>
								<td><b>#SelectEachProduct.option_name#</b></td>
								</tr>
								</table>
							</td>
							<td style="border-width:1px 1px 1px 0px; border-style:solid; border-color:###bg_active#">
								<table cellpadding="8" cellspacing="0" border="0">
									<tr>
									<td class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');"  onClick="window.location='cart.cfm?iprod=#product_ID#&prod=#prod#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">Select This Gift</td>
									</tr>
								</table>
							</td>
							</tr>
							<tr><td colspan="2"><img src="pics/shim.gif" width="1" height="1"></td></tr>
						</cfoutput>
					</cfif>
				</table>
			</td>
			</tr>
		<cfelse>
			<!--- *************************** --->
			<!--- One Product Meta Select     --->
			<!--- *************************** --->
			<cfoutput query="SelectEachProduct" group="product_ID">
				<tr>
				<td>
					<table cellpadding="8" cellspacing="0" border="0">
						<tr>
						<td class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');"  onClick="window.location='cart.cfm?iprod=#product_ID#&prod=#prod#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">Select This Gift</td>
						</tr>
					</table>
				</td>
				</tr>
				<tr><td colspan="2"><img src="pics/shim.gif" width="1" height="1"></td>
				</tr>
			</cfoutput>
		</cfif>
		</table>
	</td>
	</tr>
	</table>
</td>
</tr>
</table>
</body>
</html>