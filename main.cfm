<!--- <cfsetting showdebugoutput="no"> --->
<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfset GetProgramInfo()>
<!--- if its sanofi-aventis, email lou --->
<!---<cfif (program_ID EQ "1000000033" OR program_ID EQ "1000000034") AND IsDefined('cookie.itc_user') AND cookie.itc_user IS NOT "">

	<cfif NOT IsDefined('cookie.itc_SAdemo')>
	
		<cfcookie name="itc_SAdemo" value="yes">
		<cfparam name="username" default="no cookie!">
		<cfparam name="fname" default="no cookie!">
		<cfparam name="lname" default="no cookie!">
	
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_user,1,"_")) EQ ListGetAt(cookie.itc_user,2,"_")>
			<cfset user_ID = ListGetAt(cookie.itc_user,1,"-")>
		</cfif>
	
		<cfquery name="SAdemoInfo" datasource="#application.DS#">
			SELECT username, fname, lname 
			FROM #application.database#.program_user
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#">
		</cfquery>
		<cfif SAdemoInfo.RecordCount GT 0>
			<cfset username = HTMLEditFormat(SAdemoInfo.username)>
			<cfset fname = HTMLEditFormat(SAdemoInfo.fname)>
			<cfset lname = HTMLEditFormat(SAdemoInfo.lname)>
		</cfif>
	
		<cfmail from="#Application.AwardsFromEmail#"
				to="#application.ITCAdminEmail#" 
				subject="Sanofi Aventis Login">		
			This user clicked the welcome page button.
			
			username: #username#
			name: #fname# #lname#
			date/time: #FLGen_DateTimeToDisplay(ShowTime="true")#
		</cfmail>
		
	</cfif>
	
</cfif>
--->				

<!--- number of items in cart? --->
<cfoutput>#CartItemCount()#</cfoutput>

<!--- param all variables --->
<cfif NOT isBoolean(is_one_item)>
	<cfset is_one_item = false>
</cfif>
<cfif is_one_item>
	<cfparam name="c" default="">
<cfelse>
	<cfparam name="c" default="#default_category#">
</cfif>

<cfparam name="p" default="">
<cfparam name="g" default="">
<cfparam name="OnPage" default="1">
<cfif NOT isNumeric(OnPage)>
	<cfset OnPage = 1>
</cfif>

<cfset thisSearchText = "">
<cfif isDefined("cookie.search")>
	<cfif g NEQ "">
		<!--- They selected a group. Delete the search cookie --->
		<cfcookie name="search" expires="now">
	<cfelse>
		<!--- Use the search cookie --->
		<cfset thisSearchText = cookie.search>
	</cfif>
</cfif>
<cfif g NEQ "" OR thisSearchText NEQ "">
	<cfset show_landing_text = false>
</cfif>

<cfset thisProductValue = "">
<cfif isDefined("cookie.prodval")>
	<cfif g NEQ "" or isDefined("url.clear")>
		<!--- They selected a group. Delete the search cookie --->
		<cfcookie name="prodval" expires="now">
	<cfelse>
		<!--- Use the search cookie --->
		<cfset thisProductValue = cookie.prodval>
	</cfif>
</cfif>



<cfparam name="these_assigned_cats" default="">
<cfparam name="extrawhere_pvmID_IN" default="">
<cfparam name="extrawhere_pvmID_OR" default="">
<cfparam name="ExcludedProdGroups" default="">
<cfparam name="ExcludedProdID" default="">
<cfparam name="extrawhere_groupID_OR" default="">
<cfparam name="show_this_group" default="true">

<cfparam name="FirstEndRow" default="">

<cfinclude template="includes/header.cfm">
<cfoutput>
<table cellpadding="0" cellspacing="0" border="0" width="1200">

<tr>
<td colspan="3" width="1200" height="5"><img src="pics/shim.gif" width="25" height="5"><img src="pics/shim.gif" width="355" height="5"#cross_color#></td>
</tr>

<tr>
<td width="200" valign="top" align="center">
	<br />
	<table cellpadding="8" cellspacing="1" border="0" width="150">
		
	<tr>
	<td align="center" class="active_cell">#menu_text#</td>
	</tr>
<cfif use_master_categories EQ 0  OR use_master_categories EQ 3>
	<!--- find categories for this program --->
	<cfif program_ID EQ "1000000039">
		<cfquery name="SelectProgramCategories_Glaxo" datasource="#application.DS#" cachedwithin="#CreateTimeSpan(0,0,0,0)#">
			SELECT DISTINCT ID AS pvp_ID,productvalue_master_ID, displayname 
			FROM #application.database#.productvalue_program
			WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
			ORDER BY sortorder ASC
		</cfquery>
		<cfset SelectProgramCategories = SelectProgramCategories_Glaxo>
	<cfelse>
		<cfquery name="SelectProgramCategories_AllOthers" datasource="#application.DS#">
			SELECT DISTINCT ID AS pvp_ID,productvalue_master_ID, displayname 
			FROM #application.database#.productvalue_program
			WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#program_ID#">
			ORDER BY sortorder ASC
		</cfquery>
		<cfset SelectProgramCategories = SelectProgramCategories_AllOthers>
	</cfif>

	<!--- if this is a one items store
			1) Set c (category selected) to nothing
			2) Create SQL for limiting product searchs to just these categories --->
	
	<cfif is_one_item>
		<cfset these_assigned_cats = ValueList(SelectProgramCategories.productvalue_master_ID)>

		<cfloop query="SelectProgramCategories">
			<cfset extrawhere_pvmID_OR = extrawhere_pvmID_OR & " OR pm.productvalue_master_ID = #productvalue_master_ID# ">
		</cfloop>

		<cfif extrawhere_pvmID_OR NEQ "">
			<cfset extrawhere_pvmID_OR = RemoveChars(extrawhere_pvmID_OR,1,3)>
		</cfif>
		
		<cfif these_assigned_cats NEQ "">
			<cfset extrawhere_pvmID_IN =  " WHERE pm.productvalue_master_ID IN (#these_assigned_cats#)">
		</cfif>
		
	<!--- If this is NOT a one item store
			1) create category nav down left side of page
			2) Create SQL for limiting product searchs to the selected category --->
	
	<cfelseif NOT is_one_item>

		<cfloop query="SelectProgramCategories">
		
			<cfset cat_ID = HTMLEditFormat(SelectProgramCategories.pvp_ID)>
			<cfset pvm_ID = HTMLEditFormat(SelectProgramCategories.productvalue_master_ID)>
			<cfset displayname = HTMLEditFormat(SelectProgramCategories.displayname)>
			
			<cfif c EQ cat_ID OR c EQ "">
	
	<tr>
	<td align="center" class="selected_button">#displayname#</td>
	</tr>
				<cfif c EQ "">
					<cfset c = cat_ID>
				</cfif>

			<cfelse>

	<tr>
	<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='main.cfm?c=#cat_ID#&p=#pvm_ID#&g='">#displayname#</td>
	</tr>
		
			</cfif>
	
		</cfloop>
		<!--- p wasn't already set, set it using c--->
		<cfif p EQ "" and NOT is_one_item>
			<cfif NOT isDefined("c") OR NOT isNumeric(c)>
				<span class="alert">We apologize, but the gift categories have not been set up.</span>
			<cfelse>
				<cfquery name="SelectP" datasource="#application.DS#">
					SELECT productvalue_master_ID
					FROM #application.database#.productvalue_program
					WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#c#">
				</cfquery>
				<cfset p = SelectP.productvalue_master_ID>
			</cfif>
		</cfif>
		<cfif isNumeric(p)>
			<cfset extrawhere_pvmID_IN = " WHERE pm.productvalue_master_ID = #p# ">
		</cfif>
	</cfif>


<cfelse>
	<cfset extrawhere_pvmID_IN = " WHERE 1=1 ">
	<tr><td align="center"><cfinclude template="includes/product_group_menu.cfm"></td></tr>
</cfif>

	<cfif FileExists(application.AbsPath & "award_certificate/" & users_username & "_certificate_" & program_ID & ".pdf")>
	
	<tr>
	<td>&nbsp;</td>
	</tr>
	
	<tr>
	<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="openCertificate()">View Certificate</td>
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

	<cfif isBoolean(can_defer) AND can_defer>
	
	<tr>
	<td>&nbsp;</td>
	</tr>
	
	<tr>
	<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='main_login.cfm?defer=yes&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">Deferral Options</td>
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
<td width="995" valign="top" align="center" style="padding:12px">

	<!-- ------------- -->
	<!-- End of header -->
	<!-- ------------- -->
	
	<cfswitch expression="#use_master_categories#">
		<cfcase value="0">
			<cfinclude template="includes/master_category_groups.cfm">
		</cfcase>
		<cfcase value="1,2">
			<cfinclude template="includes/product_group_groups.cfm">
		</cfcase>
		<cfcase value="3,4">
			<cfinclude template="includes/category_tab_groups.cfm">
		</cfcase>
		<cfdefaultcase>
			<span class="alert">Category style not set!</span>
		</cfdefaultcase>
	</cfswitch>
	
	<!--- instructions, if any --->
	<cfif Trim(main_instructions) NEQ "">
	<br>
	<span class="main_instructions">#main_instructions#</span>
	<br>
	</cfif>
	
	<!--- write user name cookie --->
	<cfif IsDefined('cookie.itc_user') AND #cookie.itc_user# NEQ "" AND (NOT IsDefined('cookie.itc_userwelcome') OR #cookie.itc_userwelcome# IS "")>
		<cfquery name="GetUserName" datasource="#application.DS#">
			SELECT fname, lname
			FROM #application.database#.program_user
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(cookie.itc_user,1,"-")#">
		</cfquery>
		<cfif GetUserName.fname NEQ "" AND GetUserName.lname NEQ "">
			<cfcookie name="itc_userwelcome" value='<span class="main_cart_number">Welcome #GetUserName.fname# #GetUserName.lname#</span>.'>
		<cfelse>
			<cfcookie name="itc_userwelcome" value='<span class="main_cart_number">Welcome.</span>'>
		</cfif>
	</cfif>
	
	<cfif IsDefined('cookie.itc_userwelcome') AND #cookie.itc_userwelcome# NEQ "">
	<br>&nbsp;
	<table cellpadding="0" cellspacing="1" border="0" width="595">
	<tr>
	<td width="100%" align="center"><cfif display_message NEQ "">#display_message#</cfif></td>
	</tr>
	
	<!--- if stuff in cart, display message --->
	<cfif itemcount NEQ 0>
	<tr>
	<td width="100%" align="center"><span class="main_cart_number">#itemcount#</span> <span class="selected_msg">Item<cfif itemcount GT 1>s</cfif> In Your Cart</span></td>
	</tr>
	</cfif>
	
	</table>
	<br>
	</cfif>
	<cfset numTerms = ListLen(thisSearchText," ")>
<cfset thisTerm = 0>
	
	<cfquery name="SelectCountExcludes" datasource="#application.DS#" cachedwithin="#CreateTimeSpan(0,0,0,0)#">
		SELECT COUNT(ID) AS number_of_excludes 
		FROM #application.database#.program_product_exclude ppe 
		WHERE ppe.program_ID = #program_ID#
	</cfquery>
	
	<!--- find PRODUCTS to display (if not excluded) --->
	<cfquery name="SelectDisplayProducts" datasource="#application.DS#">
		SELECT DISTINCT pm.ID AS meta_ID, pm.meta_name AS meta_name, pm.thumbnailname AS thumbnailname,  pvm.productvalue
		FROM #application.product_database#.product_meta pm
		JOIN #application.product_database#.product p ON pm.ID = p.product_meta_ID
		LEFT JOIN #application.product_database#.productvalue_master pvm ON pvm.ID = pm.productvalue_master_ID
		WHERE p.is_active = 1 AND p.is_discontinued = 0 
		
		<cfif SelectCountExcludes.number_of_excludes GT 0>
			AND ((SELECT COUNT(ID) FROM #application.product_database#.program_product_exclude ppe WHERE ppe.program_ID = #program_ID# AND ppe.product_ID = p.ID) = 0) 
		</cfif>
		<cfif thisProductValue NEQ "" AND isNumeric(thisProductValue)>
			AND pvm.productvalue = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisProductValue/points_multiplier#">
		</cfif>
		<cfif thisSearchText NEQ "">
			AND (
			<cfloop list="#thisSearchText#" index="thisSearchWord" delimiters=" ">
				<cfset thisTerm = thisTerm + 1>
				<cfif trim(thisSearchWord) NEQ "">
					pm.meta_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisSearchWord#%"> OR
					pm.description LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#thisSearchWord#%">
				</cfif>
				<cfif thisTerm LT numTerms>
					OR
				</cfif>
			</cfloop>
			)
		<cfelse>
			<cfif g NEQ "">
				 AND ((SELECT COUNT(ID) FROM #application.product_database#.product_meta_group_lookup pmgl WHERE pmgl.product_meta_group_ID = #g# AND product_meta_ID = pm.ID) > 0)
			</cfif>
			<cfif NOT is_one_item AND isNumeric(p)>
				AND pm.productvalue_master_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#p#">
			<cfelseif is_one_item>
				<cfif these_assigned_cats NEQ "">
					AND pm.productvalue_master_ID IN (#these_assigned_cats#)
				</cfif>
			</cfif>
		</cfif>
			<cfif isDefined("cookie.filter") AND cookie.filter NEQ "">
				AND 
				<cfif true><!--- ListFind(product_set_IDs,1)> --->
					<cfswitch expression="#cookie.filter#">
						<cfcase value="0">
							pvm.productvalue BETWEEN 0 AND 100
						</cfcase>
						<cfcase value="101">
							pvm.productvalue BETWEEN 101 AND 200
						</cfcase>
						<cfcase value="201">
							pvm.productvalue BETWEEN 201 AND 300
						</cfcase>
						<cfcase value="301">
							pvm.productvalue BETWEEN 301 AND 400
						</cfcase>
						<cfcase value="401">
							pvm.productvalue BETWEEN 401 AND 500
						</cfcase>
						<cfcase value="501">
							pvm.productvalue BETWEEN 501 AND 1000
						</cfcase>
						<cfcase value="1001">
							pvm.productvalue BETWEEN 1001 AND 1500
						</cfcase>
						<cfcase value="1501">
							pvm.productvalue BETWEEN 1501 AND 2000
						</cfcase>
						<cfcase value="2001">
							pvm.productvalue > 2000
						</cfcase>
						<cfdefaultcase>
							pvm.productvalue > -1
						</cfdefaultcase>
					</cfswitch>
				<cfelse>
					<cfswitch expression="#cookie.filter#">
						<cfcase value="0">
							pvm.productvalue BETWEEN 0 AND 50
						</cfcase>
						<cfcase value="51">
							pvm.productvalue BETWEEN 51 AND 100
						</cfcase>
						<cfcase value="101">
							pvm.productvalue > 100
						</cfcase>
						<cfdefaultcase>
							pvm.productvalue > -1
						</cfdefaultcase>
					</cfswitch>
				</cfif>
			</cfif>
		ORDER BY
			<cfif isDefined("cookie.sort") AND cookie.sort NEQ "">
				<cfswitch expression="#cookie.sort#">
					<cfcase value="low">
						pvm.productvalue ASC
					</cfcase>
					<cfcase value="high">
						pvm.productvalue DESC
					</cfcase>
					<cfdefaultcase>
						pm.sortorder ASC
					</cfdefaultcase>
				</cfswitch>
			<cfelse>
				pm.sortorder ASC
			</cfif>
	</cfquery>
	<!--- set paging variables --->
	<cfparam name="OnPage" default="1">
	<cfif NOT isNumeric(display_row)>
		<cfset display_row = 1>
	</cfif>
	<cfif NOT isNumeric(display_col)>
		<cfset display_col = 1>
	</cfif>
	<cfset MaxRows_ProductDisplay=(display_row*display_col)>
	<cfset StartRow_ProductDisplay=Min((OnPage-1)*MaxRows_ProductDisplay+1,Max(SelectDisplayProducts.RecordCount,1))>
	<cfset EndRow_ProductDisplay=Min(StartRow_ProductDisplay+MaxRows_ProductDisplay-1,SelectDisplayProducts.RecordCount)>
	<cfset TotalPages_ProductDisplay=Ceiling(SelectDisplayProducts.RecordCount/MaxRows_ProductDisplay)>

	<cfinclude template="includes/paging.cfm">

<!---

	<!--- product paging --->
	<br>
	<table cellpadding="3" cellspacing="0" border="0">
	<tr>
	<!--- first page --->
	<td align="right">
		<cfif OnPage EQ 1>
			<span class="main_paging_selected">&nbsp;</span>
		<cfelse>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=1" class="main_paging_active">&laquo;</a>
		</cfif>
	</td>
	<!--- previous page --->
	<td align="right">
		<cfif OnPage EQ 1>
			<span class="main_paging_selected">&nbsp;</span>
		<cfelse>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#Max(DecrementValue(OnPage),1)#" class="main_paging_active">prev</a>
		</cfif>
	</td>
	<!--- page number links --->
	<cfloop index="PagingLoop" from="1" to="#TotalPages_ProductDisplay#">
		<cfif OnPage EQ PagingLoop>
			<td><span class="main_paging_number">#PagingLoop#</span></td>
		<cfelse>
			<td><a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#PagingLoop#" class="main_paging_active">#PagingLoop#</a></td>
		</cfif>
	</cfloop>		
	<!--- next page --->
	<td align="left">
		<cfif OnPage LT TotalPages_ProductDisplay>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#Min(IncrementValue(OnPage),TotalPages_ProductDisplay)#" class="main_paging_active">next</a>
		<cfelse>
			<span class="main_paging_selected">&nbsp;</span>
		</cfif>
	</td>
	<!--- last page --->
	<td align="left">
		<cfif OnPage LT TotalPages_ProductDisplay>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#TotalPages_ProductDisplay#" class="main_paging_active">&raquo;</a>
		<cfelse>
			<span class="main_paging_selected">&nbsp;</span>
		</cfif>
	</td>
	</tr>
	</table>
	<br>
	
--->


</cfoutput>


	<!--- display products --->
		
	<!--- this is the loop counter for the product display --->
	<cfset i_cow = 0>
	
	<cfif SelectDisplayProducts.RecordCount EQ 0><br><span class="alert">There are no products in this category.</span><br></cfif>

<cfoutput query="SelectDisplayProducts" startrow="#StartRow_ProductDisplay#" maxrows="#MaxRows_ProductDisplay#">
	
	<cfset i_cow = IncrementValue(i_cow)> 
	
	<!--- open a row if this is loop one or if the loop count equals display_col + 1 --->
	<cfif i_cow EQ 1>
	<table cellpadding="2" cellspacing="0" border="0">
	</cfif>
	<cfif i_cow EQ 1 OR ((i_cow MOD display_col) EQ 1)>
	<tr>
	</cfif>
	<!--- ************************************** --->
	<!--- DISPLAY THE PRODUCT ALREADY, WILL YOU? --->
	<!--- ************************************** --->
	<td align="center" valign="top">
		<table cellpadding="2" cellspacing="0" border="0" width="100">
		<tr>
		<td align="center"><img src="pics/shim.gif" width="100" height="1"></td>
		</tr>
		<tr>
		<td align="center" width="100" height="100" onClick="window.location='main_prod.cfm?prod=#meta_ID#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'" style="cursor:pointer"><img src="pics/products/#thumbnailname#"></td>
		</tr>
		<tr>
		<td align="center"  class="active_view" onMouseOver="mOver(this,'selected_view');" onMouseOut="mOut(this,'active_view');" onClick="window.location='main_prod.cfm?prod=#meta_ID#&c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">View Details</td>
		</tr>
		<tr>
		<td valign="top"><b>#meta_name#</b></td>
		</tr>
		<cfif use_master_categories NEQ 0 AND use_master_categories NEQ 3 AND NOT is_one_item>
				<tr>
				<td valign="bottom" class="product_value">
					#productvalue*points_multiplier# #credit_desc#
				</td>
				</tr>
			</cfif>
		</table>
	</td>
	<!--- PADDING CELL if it isn't the last cell and isn't the last record returned --->
	<cfif (i_cow NEQ display_col) AND ((i_cow + (MaxRows_ProductDisplay * (OnPage - 1))) NEQ SelectDisplayProducts.RecordCount)>
	<td align="center"><img src="pics/shim.gif" width="20" height="1"></td>
	</cfif>
	<!--- close a row --->
	<cfif ((i_cow MOD display_col) EQ 0) OR ((i_cow + (MaxRows_ProductDisplay * (OnPage - 1))) EQ SelectDisplayProducts.RecordCount)>
	<!--- FILL IN NOT COMPLETE ROWS --->
	<!--- if is the last record from the database AND not the first row of a multi row table AND not the last record to be displayed on this page AND it's not the last cell of this row, check if fill-in cells needed for row --->
		<cfif ((i_cow + (MaxRows_ProductDisplay * (OnPage - 1))) EQ SelectDisplayProducts.RecordCount) AND display_row GT 1 AND i_cow GT display_col AND i_cow NEQ MaxRows_ProductDisplay AND (i_cow MOD display_col NEQ 0)>
		<cfset fillin = display_col - (i_cow MOD display_col)>
			<cfloop from="1" to="#fillin#" index="thisfillin">
				<cfif thisfillin EQ 1>
					<td align="center"><img src="pics/shim.gif" width="20" height="8"></td>
				</cfif>
					<td align="center">&nbsp;</td>
				<cfif (thisfillin + (i_cow MOD display_col)) NEQ display_col>
					<td align="center"><img src="pics/shim.gif" width="20" height="1"></td>
				</cfif>
			</cfloop>
		</cfif>
	</tr>
	</cfif>
		
	<cfif i_cow EQ SelectDisplayProducts.RecordCount OR i_cow EQ MaxRows_ProductDisplay OR ((i_cow + (MaxRows_ProductDisplay * (OnPage - 1))) EQ SelectDisplayProducts.RecordCount)>
	</table>
	</cfif>
	
</cfoutput>
		<cfinclude template="includes/paging.cfm">
	
<cfoutput>
<!---
	<!--- product paging --->
	<br>
	<table cellpadding="3" cellspacing="0" border="0">
	<tr>
	<!--- first page --->
	<td align="right">
		<cfif OnPage EQ 1>
			<span class="main_paging_selected">&nbsp;</span>
		<cfelse>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=1" class="main_paging_active">&laquo;</a>
		</cfif>
	</td>
	<!--- previous page --->
	<td align="right">
		<cfif OnPage EQ 1>
			<span class="main_paging_selected">&nbsp;</span>
		<cfelse>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#Max(DecrementValue(OnPage),1)#" class="main_paging_active">prev</a>
		</cfif>
	</td>
	<!--- page number links --->
	<cfloop index="PagingLoop" from="1" to="#TotalPages_ProductDisplay#">
		<cfif OnPage EQ PagingLoop>
			<td><span class="main_paging_number">#PagingLoop#</span></td>
		<cfelse>
			<td><a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#PagingLoop#" class="main_paging_active">#PagingLoop#</a></td>
		</cfif>
	</cfloop>		
	<!--- next page --->
	<td align="left">
		<cfif OnPage LT TotalPages_ProductDisplay>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#Min(IncrementValue(OnPage),TotalPages_ProductDisplay)#" class="main_paging_active">next</a>
		<cfelse>
			<span class="main_paging_selected">&nbsp;</span>
		</cfif>
	</td>
	<!--- last page --->
	<td align="left">
		<cfif OnPage LT TotalPages_ProductDisplay>
			<a href="#CurrentPage#?c=#c#&p=#p#&g=#g#&OnPage=#TotalPages_ProductDisplay#" class="main_paging_active">&raquo;</a>
		<cfelse>
			<span class="main_paging_selected">&nbsp;</span>
		</cfif>
	</td>
	</tr>
	</table>
	
	<br>
	--->
</td>
</tr>

</table>

</body>

</cfoutput>

</html>
