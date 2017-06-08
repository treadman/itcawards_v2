<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000008,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="x" default="">
<cfparam name="where_string" default="">
<cfparam name="meta_ID" default="">
<cfparam name="datasaved" default="no">

<!--- param search criteria xS=ColumnSort xT=SearchString xL=Letter --->
<cfparam name="xS" default="added">
<cfparam name="xL" default="">
<cfparam name="xT" default="">
<cfparam name="xW" default="">
<cfparam name="OnPage" default="1">
<cfparam name="orderbyvar" default="">
<cfparam name="translate" default="">
<cfparam name="searchboxtext" default="">
<cfparam name="group_count" default="">

<!--- param display fields --->
<cfparam name="meta_ID" default="">	
<cfparam name="value" default="">
<cfparam name="productvalue_master_ID" default="">
<cfparam name="meta_name" default="">
<cfparam name="meta_sku" default="">
<cfparam name="description" default="">
<cfparam name="imagename_original" default="">
<cfparam name="thumbnailname_original" default="">
<cfparam name="sortorder" default="">
<cfparam name="manuf_name" default="">
<cfparam name="logoname" default="">
<cfparam name="de" default="">
<cfparam name="dis" default="">
<cfparam name="alert_msg" default="">


<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "report_products">
<cfinclude template="includes/header.cfm">

<SCRIPT LANGUAGE="JavaScript"><!-- 
	function openURL() { 
		// grab index number of the selected option
		selInd = document.pageform2.pageselect.selectedIndex; 
		// get value of the selected option
		goURL = document.pageform2.pageselect.options[selInd].value;
		// redirect browser to the grabbed value (hopefully a URL)
		top.location.href = goURL; 
	}

	function openURLAgain() { 
		// grab index number of the selected option
		selInd = document.pageform2.pageselect.selectedIndex; 
		// get value of the selected option
		goURL = document.pageform2.pageselect.options[selInd].value;
		// redirect browser to the grabbed value (hopefully a URL)
		top.location.href = goURL; 
	}

//--> </SCRIPT>

	<!--- set ORDER BY --->
	<cfswitch expression="#xS#">
		<cfcase value="name">
			<cfset orderbyvar = "m.meta_name">
			<cfset orderbyclause = "m.meta_name">
			<cfset searchboxtext = "Product Name">
		</cfcase>
		<cfcase value="mcat">
			<cfset orderbyvar = "p.productvalue">
			<cfset orderbyclause = "p.productvalue, m.sortorder">
			<cfset searchboxtext = "Master Category">
		</cfcase>
		<cfcase value="sku">
			<cfset orderbyvar = "m.meta_sku">
			<cfset orderbyclause = "m.meta_sku">
			<cfset searchboxtext = "ITC SKU (meta)">
		</cfcase>
		<cfcase value="added">
			<cfset orderbyvar = "m.created_datetime">
			<cfset orderbyclause = "m.created_datetime">
			<cfset searchboxtext = "Product Added On">
		</cfcase>
	</cfswitch>

	<!--- Set the WHERE clause --->
	<!--- First check if a search string passed --->
	<cfif LEN(xT) GT 0 AND (IsDefined('form.submit1') AND form.submit1 IS NOT "")>
		<cfset xW = "1">
	<cfelseif LEN(xT) GT 0 AND (IsDefined('form.submit2') AND form.submit2 IS NOT "")>
		<cfset xW = "2">
	<cfelseif LEN(xT) GT 0 AND (IsDefined('form.submit3') AND form.submit3 IS NOT "")>
		<cfset xW = "3">
	<cfelseif LEN(xT) GT 0 AND xW EQ ''>
		<cfset xW = "1">
	</cfif>

	<!--- run query --->
	<cfif ListFind("m.meta_name,p.productvalue,m.meta_sku,m.created_datetime",orderbyvar)>
		<cfquery name="SelectList" datasource="#application.DS#">
			SELECT 	m.ID AS meta_ID, m.meta_name, m.meta_sku, p.productvalue, m.sortorder AS sortorder, m.created_datetime,
			SUM(o.is_discontinued) AS discontinued, COUNT(o.ID) as optioncount, SUM(o.is_active) AS is_active,
			COUNT(i2.ID) AS total_sold_w2,
			COUNT(i3.ID) AS total_sold_w3,
			COUNT(i4.ID) AS total_sold_w4
			FROM #application.product_database#.product_meta m
			LEFT JOIN #application.product_database#.productvalue_master p ON m.productvalue_master_ID = p.ID
			LEFT JOIN #application.product_database#.product o ON o.product_meta_ID = m.ID
			LEFT JOIN ITCAwards.inventory i2 ON i2.product_ID = o.ID AND i2.is_valid = 1 
			LEFT JOIN ITCAwards_v3.inventory i3 ON i3.product_ID = o.ID AND i3.is_valid = 1 
			LEFT JOIN ITCAwards_v4.inventory i4 ON i4.product_ID = o.ID AND i4.is_valid = 1 
			WHERE 1 = 1 
			<cfif LEN(xT) GT 0 AND ((IsDefined('form.submit1') AND form.submit1 IS NOT "") OR (xW EQ 1))>
				AND (m.meta_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(xT)#%"> 
				OR m.meta_sku LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#PreserveSingleQuotes(xT)#%">)
			<cfelseif LEN(xT) GT 0 AND ((IsDefined('form.submit2') AND form.submit2 IS NOT "") OR (xW EQ 2))>
				AND (p.productvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#xT#">)
			<cfelseif LEN(xT) GT 0 AND ((IsDefined('form.submit3') AND form.submit3 IS NOT "") OR (xW EQ 3)) AND xT contains "n">
				AND ((SELECT COUNT(*) FROM #application.product_database#.product_meta_option_category pm WHERE m.ID = pm.product_meta_ID) = 0 )
			<cfelseif LEN(xT) GT 0 AND ((IsDefined('form.submit3') AND form.submit3 IS NOT "") OR (xW EQ 3)) AND xT contains "y">
				AND ((SELECT COUNT(*) FROM #application.product_database#.product_meta_option_category pm WHERE m.ID = pm.product_meta_ID) > 0 )	
			</cfif>
			<cfif LEN(xL) GT 0>
				AND 
				<cfif ListFind("m.created_datetime",orderbyvar)>
					m.meta_name
				<cfelse>
					#orderbyvar#
				</cfif>
				LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#xL#%" maxlength="3">
			</cfif>
			GROUP BY m.ID
			HAVING (optioncount = 0 OR optioncount != discontinued) AND total_sold_w2+total_sold_w3+total_sold_w4 <= 0 AND is_active > 0
			ORDER BY #orderbyclause#
		</cfquery>
	</cfif>

	<!--- set the start/end/max display row numbers --->
	<cfset MaxRows_SelectList="50">
	<cfset StartRow_SelectList=Min((OnPage-1)*MaxRows_SelectList+1,Max(SelectList.RecordCount,1))>
	<cfset EndRow_SelectList=Min(StartRow_SelectList+MaxRows_SelectList-1,SelectList.RecordCount)>
	<cfset TotalPages_SelectList=Ceiling(SelectList.RecordCount/MaxRows_SelectList)>

	<span class="pagetitle">Product Report</span> - Unsold Products
	<br /><br />

	<cfoutput>	
	<!--- search box --->
	<table cellpadding="5" cellspacing="0" border="0" width="100%">
		<tr class="contenthead">
			<td><span class="headertext">Search Criteria</span></td>
			<td align="right"><a href="#CurrentPage#" class="headertext">view all</a></td>
		</tr>
		<tr class="contentsearch">
			<td align="center" colspan="2">
				<span class="searchcriteria">
					current search/sort &raquo;&nbsp;&nbsp;
					<!--- text--->
					<cfif xT NEQ "" AND xW EQ "1">
						[ find "#xT#" in SKU or Product Name ]&nbsp;&nbsp;
					<cfelseif xT NEQ "" AND xW EQ "2">
						[ select all products in Master Category #xT# ]&nbsp;&nbsp;
					<cfelseif xT contains "y" AND xW EQ "3">
						[ select all products with options ]&nbsp;&nbsp;
					<cfelseif xT contains "n" AND xW EQ "3">
						[ select all products without options ]&nbsp;&nbsp;
					</cfif>
					<!--- letter/number--->
					<cfif LEN(xL) GT 0>
						[ where #searchboxtext# starts with "#xL#" ]&nbsp;&nbsp;
					</cfif>
					<!--- sort--->
					[ sorted by #searchboxtext# ]
				</span>
			</td>
		</tr>
		<tr>
			<td class="content" colspan="2" align="center">
				<form action="#CurrentPage#" method="post">
					<input type="hidden" name="xL" value="#xL#">
					<input type="hidden" name="xS" value="#xS#">
					<input type="text" name="xT" value="#HTMLEditFormat(xT)#" size="20">
					<input type="submit" name="submit1" value="sku or name">
					<input type="submit" name="submit2" value="master category">
					<input type="submit" name="submit3" value="has options? (y/n)">
				</form>
				<br>
				<cfif LEN(xL) IS 0>
					<span class="ltrON">ALL</span>
				<cfelse>
					<a href="#CurrentPage#?xL=&xS=#xS#&xT=#xT#&xW=#xW#" class="ltr">ALL</a>
				</cfif>
				<span class="ltrPIPE">&nbsp;&nbsp;</span>
				<cfloop index = "LoopCount" from = "0" to = "9"><cfif xL IS LoopCount><span class="ltrON">#LoopCount#</span><cfelse><a href="#CurrentPage#?xL=#LoopCount#&xS=#xS#&xT=#xT#&xW=#xW#" class="ltr">#LoopCount#</a></cfif><span class="ltrPIPE">&nbsp;&nbsp;</span></cfloop>
				<cfloop index = "LoopCount" from = "1" to = "26"><cfif xL IS CHR(LoopCount + 64)><span class="ltrON">#CHR(LoopCount + 64)#</span><cfelse><a href="#CurrentPage#?xL=#CHR(LoopCount + 64)#&xS=#xS#&xT=#xT#&xW=#xW#" class="ltr">#CHR(LoopCount + 64)#</a></cfif><cfif LoopCount NEQ 26><span class="ltrPIPE">&nbsp;&nbsp;</span></cfif></cfloop>
			</td>
		</tr>
	</table>
	<br />
	<cfif IsDefined('SelectList.RecordCount') AND SelectList.RecordCount GT 0>
		<form name="pageform2">
			<table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr>
				<td><cfif OnPage GT 1><a href="#CurrentPage#?OnPage=1&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#" class="pagingcontrols">&laquo;</a>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?OnPage=#Max(DecrementValue(OnPage),1)#&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#" class="pagingcontrols">&lsaquo;</a><cfelse><span class="Xpagingcontrols">&laquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&lsaquo;</span></cfif></td> 
				<td align="center" class="sub">[ page <select name="pageselect" onChange="openURL(document.pageform2.pageselect)"><cfloop from="1" to="#TotalPages_SelectList#" index="this_i"><option value="#CurrentPage#?OnPage=#this_i#&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#"<cfif OnPage EQ this_i> selected</cfif>>#this_i#</option></cfloop></select> of #TotalPages_SelectList# ]&nbsp;&nbsp;&nbsp;[ records #StartRow_SelectList# - #EndRow_SelectList# of #SelectList.RecordCount# ]</td>
				<td align="right">
					<cfif OnPage LT TotalPages_SelectList><a href="#CurrentPage#?OnPage=#Min(IncrementValue(OnPage),TotalPages_SelectList)#&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#" class="pagingcontrols">&rsaquo;</a>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?OnPage=#TotalPages_SelectList#&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#" class="pagingcontrols">&raquo;</a><cfelse><span class="Xpagingcontrols">&rsaquo;</span>&nbsp;&nbsp;&nbsp;<span class="Xpagingcontrols">&raquo;</span></cfif>
				</td>
			</tr>
			</table>
		</form>
	</cfif>
	</cfoutput>
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
		<!--- header row --->
		<cfoutput>
		<tr class="contenthead">
			<td align="right"></td>
			<td><cfif xS IS "sku"><span>ITC SKU</span> (meta) <img src="../pics/contrls-asc.gif" width="7" height="6"><cfelse><a href="#CurrentPage#?xS=sku&xL=#xL#&xT=#xT#&xW=#xW#" class="headertext">ITC SKU</a> (meta)</cfif></td>
			<td><cfif xS IS "name"><span class="headertext">Product Name</span> <img src="../pics/contrls-asc.gif" width="7" height="6"><cfelse><a href="#CurrentPage#?xS=name&xL=#xL#&xT=#xT#&xW=#xW#" class="headertext">Product Name</a></cfif></td>
			<td><cfif xS IS "mcat"><span class="headertext">Master Category</span> <img src="../pics/contrls-asc.gif" width="7" height="6"><cfelse><a href="#CurrentPage#?xS=mcat&xL=#xL#&xT=#xT#&xW=#xW#" class="headertext">Master Category</a></cfif></td>
			<td><cfif xS IS "added"><span class="headertext">Product Added On</span> <img src="../pics/contrls-asc.gif" width="7" height="6"><cfelse><a href="#CurrentPage#?xS=added&xL=#xL#&xT=#xT#&xW=#xW#" class="headertext">Product Added On</a></cfif></td>
			<td class="headertext" align="center">Number Sold</td>
		</tr>
		</cfoutput>
		<!--- display found records --->
		<cfset display_any_records = false>
		<cfset thisRow = 1>
		<cfoutput query="SelectList" startrow="#StartRow_SelectList#" maxrows="#MaxRows_SelectList#">
			
			<cfset total_sold_all3 = total_sold_w2+total_sold_w3+total_sold_w4>
			<!---<cfif total_sold_all3 lt 0>
				<cfabort showerror="Error in inventory" >
			<cfelseif total_sold_all3 eq 0>--->
<!---
		<cfquery name="FindProductInfo" datasource="#application.DS#">
			SELECT ID AS prod_ID, sku, sortorder, IF(is_dropshipped=1,"true", "false") AS is_dropshipped, IF(is_active=1,"yes","no") AS is_active, IF(is_discontinued=1,"true","false") AS is_discontinued
			FROM #application.product_database#.product
			WHERE product_meta_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ThisMetaID#" maxlength="10">
			ORDER BY sortorder
		</cfquery>
--->
				<cfset ThisMetaID = SelectList.meta_ID>
				<cfset thisRow = thisRow + 1>
				<cfset is_discontinued = (optioncount GT 0 AND optioncount EQ discontinued)>
				<tr class="#Iif(is_active AND NOT is_discontinued,de(Iif(((thisRow MOD 2) is 0),de('content2'),de('content'))), de('inactivebg'))#">
					<td valign="top" align="right">
						
					</td>
					<td valign="top">#HTMLEditFormat(meta_sku)#</td>
					<td valign="top"><cfif is_discontinued><b>DISCONTINUED</b><br /></cfif>#meta_name#</td>
					<td valign="top">#HTMLEditFormat(productvalue)#</td>
					<td valign="top">#dateFormat(created_datetime,"mm/dd/yyyy")#</td>
					<td valign="top" align="right">#total_sold_all3#</td>
				</tr>
				<cfset display_any_records = true>
			<!---</cfif>--->
		</cfoutput>
		<!--- if no records --->
		<cfif SelectList.RecordCount IS 0 OR NOT display_any_records>
			<tr class="content2">
				<td colspan="6" align="center"><span class="alert"><br>No records found.  Click "view all" to see all records.<br><br></span></td>
			</tr>
		</cfif>
		<tr>
			<td><img src="../pics/shim.gif" width="40" height="1"></td>
			<td><img src="../pics/shim.gif" width="60" height="1"></td>
			<td width="100%"><img src="../pics/shim.gif" width="20" height="1"></td>
			<td><img src="../pics/shim.gif" width="50" height="1"></td>
			<td><img src="../pics/shim.gif" width="50" height="1"></td>
			<td><img src="../pics/shim.gif" width="40" height="1"></td>
		</tr>
	</table>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->