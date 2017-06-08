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
<cfparam  name="pgfn" default="">
<cfparam name="thisProdsGroups" default="">
<cfparam name="thischecked" default="">
<cfparam name="gpgfn" default="">
<cfparam name="gID" default="">

<!--- param search criteria xS=ColumnSort xT=SearchString xL=Letter --->
<cfparam name="xS" default="">
<cfparam name="xT" default="">
<cfparam name="xL" default="">
<cfparam name="xW" default="">
<cfparam name="xA" default="">
<cfparam name="OnPage" default="">
<cfparam name="orderbyvar" default="">

<!--- param a/e form fields --->
<cfparam name="meta_name" default="">	
<cfparam name="meta_sku" default="">	
<cfparam name="description" default="">
<cfparam name="manuf_logo_ID" default="">
<cfparam name="imagename" default="">
<cfparam name="thumbnailname" default="">
<cfparam name="productvalue_master_ID" default="">
<cfparam name="product_meta_group_ID" default="">
<cfparam name="imagename_original" default="">
<cfparam name="thumbnailname_original" default="">
<cfparam name="images" default="">
<cfparam name="thumbnails" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<!--- update --->
	<cfif form.meta_ID IS NOT "">
		<!--- delete existing group lookups --->
		<cfquery name="DeleteGroupLookup" datasource="#application.DS#">
			DELETE FROM #application.product_database#.product_meta_group_lookup
			WHERE product_meta_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.meta_ID#" maxlength="10">
		</cfquery>
		<!--- do product_meta update --->
		<cfquery name="UpdateQuery" datasource="#application.DS#">
			UPDATE #application.product_database#.product_meta
			SET	productvalue_master_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.productvalue_master_ID#" maxlength="10">,
				manuf_logo_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.manuf_logo_ID#" maxlength="10" null="#YesNoFormat(NOT Len(Trim(form.manuf_logo_ID)))#">,
				meta_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.meta_name#" maxlength="64">,
				meta_sku = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.meta_sku#" maxlength="64">,
				description = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#form.description#">
				#FLGen_UpdateModConcatSQL()#
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.meta_ID#" maxlength="10">
		</cfquery>
	<!--- add --->
	<cfelse>
		<cflock name="product_metaLock" timeout="10">
			<cftransaction>
				<cfquery name="InsertQuery" datasource="#application.DS#">
					INSERT INTO #application.product_database#.product_meta
						(created_user_ID, created_datetime, productvalue_master_ID, manuf_logo_ID, meta_name, meta_sku, description, sortorder)
					VALUES (
						<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#', 
						<cfqueryparam cfsqltype="cf_sql_integer" value="#form.productvalue_master_ID#" maxlength="10">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#form.manuf_logo_ID#" maxlength="10" null = "#YesNoFormat(NOT Len(Trim(form.manuf_logo_ID)))#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.meta_name#" maxlength="64">, 
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.meta_sku#" maxlength="64">, 
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#form.description#">,
						0
					)
				</cfquery>
				<cfquery datasource="#application.DS#" name="getID">
					SELECT Max(ID) As MaxID FROM #application.product_database#.product_meta
				</cfquery>
				<cfset meta_ID = getID.MaxID>
			</cftransaction>  
		</cflock>
	</cfif>
	<!--- loop through comma delimited checkboxes that were passed and insert into group lookup --->
	<cfif IsDefined('form.product_meta_group_ID') AND form.product_meta_group_ID IS NOT "">
		<cfloop list="#form.product_meta_group_ID#" index="thisGroup">
			<cfquery name="InsertGroupLookup" datasource="#application.DS#">
				INSERT INTO #application.product_database#.product_meta_group_lookup
				(created_user_ID, created_datetime, product_meta_ID, product_meta_group_ID)
				VALUES
				(<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">,
				 '#FLGen_DateTimeToMySQL()#',
				  <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#meta_ID#" maxlength="10">,
				 #thisGroup#)			
			</cfquery>
		</cfloop>
	</cfif>
	<!--- deal with the images if they were submitted --->
	<!--- upload image, name is #meta_ID#_image.ext --->
	<cfif form.imagename_original IS NOT ""> 
		<cfset images = #FLGen_UploadThis("imagename_original","pics/products/",meta_ID & "_image")#>
		<cfset imagename_original = ListGetAt(images,1,",")>
		<cfset imagename = ListGetAt(images,2,",")>
			<!--- update this field in the database --->
			<cfquery name="UpdateQueryImage" datasource="#application.DS#">
				UPDATE #application.product_database#.product_meta
				SET	imagename_original = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imagename_original#" maxlength="64">,
					imagename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imagename#" maxlength="25">
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#meta_ID#" maxlength="10">
		</cfquery>
	</cfif>
	<!--- upload thumbnail, name is #meta_ID#_thumbnail.ext  --->
	<cfif form.thumbnailname_original IS NOT ""> 
		<cfset thumbnails = #FLGen_UploadThis("thumbnailname_original","pics/products/",meta_ID & "_thumbnail")#>
		<cfset thumbnailname_original = ListGetAt(thumbnails,1,",")>
		<cfset thumbnailname = ListGetAt(thumbnails,2,",")>
			<!--- update this field in the database --->
			<cfquery name="UpdateQueryThumb" datasource="#application.DS#">
				UPDATE #application.product_database#.product_meta
				SET	thumbnailname_original = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thumbnailname_original#" maxlength="64">,
					thumbnailname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thumbnailname#" maxlength="25">
				WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#meta_ID#" maxlength="10">
		</cfquery>
	</cfif>
	<cfif gpgfn NEQ "">
		<cfset pgfn = "edit">
		<cfset datasaved = "yes">
	<cfelse>
		<cflocation addtoken="no" url="product.cfm?pgfn=edit&meta_ID=#meta_ID#&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#&xA=#xA#&OnPage=#OnPage#&alert_msg=The%20information%20was%20saved.">
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<cfset tinymce_fields = "description">
<cfinclude template="/cfscripts/dfm_common/tinymce.cfm">


<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "products">
<cfinclude template="includes/header.cfm">

<!--- START pgfn ADD/EDIT --->

<span class="pagetitle"><cfif pgfn EQ "add">Add<cfelse>Edit</cfif> Product Meta Information</span>
<br /><br />
<cfif gpgfn NEQ "">
	<span class="pageinstructions">Return to <a href="<cfoutput>product_groups.cfm?pgfn=#gpgfn#&ID=#gID#</cfoutput>">Group Product List</a>  without making changes.</span>
	<br /><br />
<cfelse>
	<span class="pageinstructions">Return to <cfif pgfn EQ "edit"><a href="<cfoutput>product.cfm?pgfn=edit&meta_ID=#meta_ID#&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#&xA=#xA#&OnPage=#OnPage#</cfoutput>">Product Detail</a> or </cfif><a href="<cfoutput>product.cfm?&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#&xA=#xA#&OnPage=#OnPage#</cfoutput>">Product List</a> without making changes.</span>
	<br /><br />
</cfif>

<cfif datasaved eq 'yes'>
	<span class="alert">The information was saved.</span><cfoutput>#FLGen_SubStamp()#</cfoutput>
	<br /><br />
</cfif>

<cfif pgfn EQ "edit">
	<cfquery name="ToBeEdited" datasource="#application.DS#">
		SELECT ID AS meta_ID, productvalue_master_ID, meta_name, meta_sku, description, imagename_original, thumbnailname_original, imagename, thumbnailname, manuf_logo_ID
		FROM #application.product_database#.product_meta
		WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#meta_ID#" maxlength="10">
	</cfquery>
	<cfset meta_ID = ToBeEdited.meta_ID>
	<cfset productvalue_master_ID = htmleditformat(ToBeEdited.productvalue_master_ID)>
	<cfset meta_name = htmleditformat(ToBeEdited.meta_name)>
	<cfset meta_sku = htmleditformat(ToBeEdited.meta_sku)>
	<cfset description = htmleditformat(ToBeEdited.description)>
	<cfset imagename_original = htmleditformat(ToBeEdited.imagename_original)>
	<cfset thumbnailname_original = htmleditformat(ToBeEdited.thumbnailname_original)>
	<cfset imagename = htmleditformat(ToBeEdited.imagename)>
	<cfset thumbnailname = htmleditformat(ToBeEdited.thumbnailname)>
	<cfset manuf_logo_ID = ToBeEdited.manuf_logo_ID>
	<!--- make list of the groups this meta_product is in --->
	<cfquery name="GetThisProdsGroups" datasource="#application.DS#">
		SELECT product_meta_group_ID
		FROM #application.product_database#.product_meta_group_lookup
		WHERE product_meta_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#meta_ID#" maxlength="10">
	</cfquery>
	<cfloop query="GetThisProdsGroups">
		<cfset thisProdsGroups = #thisProdsGroups# & " " & #GetThisProdsGroups.product_meta_group_ID#>
	</cfloop>
</cfif>

<cfquery name="SelectGroups" datasource="#application.DS#">
	SELECT ID, name
	FROM #application.database#.product_meta_group
	ORDER BY sortorder
</cfquery>

<cfquery name="GetManufLogo" datasource="#application.DS#">
	SELECT ID AS getmanuflogo_ID, manuf_name, logoname, logoname_original
	FROM #application.product_database#.manuf_logo
	ORDER BY manuf_name ASC 
</cfquery>

<cfoutput>
<form method="post" action="#CurrentPage#" enctype="multipart/form-data">
	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="contenthead">
	<td colspan="2" class="headertext">Meta Information</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Product Name: </td>
	<td valign="top"><input type="text" name="meta_name" value="#meta_name#" maxlength="64" size="64"></td>
	</tr>
	
	<cfif pgfn EQ 'add'>
		<cfquery name="GetSkus" datasource="#application.DS#">
			SELECT meta_sku, created_datetime
			FROM #application.product_database#.product_meta
			Order by created_datetime DESC
			limit 5
		</cfquery>
		<cfquery dbtype="query" name="GetSkusReordered">
			SELECT meta_sku
			FROM GetSkus
			Order by created_datetime ASC
		</cfquery>
	<tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif"> The last five SKUs used: <cfloop query="GetSkusReordered">#meta_sku# </cfloop> <span class="tooltip" title="This list is to help you pick the next SKU">?</span>
	</td>
	</tr>
		
	</cfif>
	
	<tr class="content">
	<td align="right" valign="top">ITC SKU (meta): </td>
	<td valign="top"><input type="text" name="meta_sku" value="#meta_sku#" maxlength="64" size="64"></td>
	</tr>
	
	<!--- <tr class="content2">
	<td align="right" valign="top">&nbsp;</td>
	<td valign="top"><img src="../pics/contrls-desc.gif"> The only symbols that require special codes are:
	<br>
	&nbsp;&nbsp;&nbsp;&middot;&nbsp;&trade;&nbsp;&nbsp;&nbsp;#HTMLEditFormat("&trade;")#<br>
	&nbsp;&nbsp;&nbsp;&middot;&nbsp;&reg;&nbsp;&nbsp;&nbsp;#HTMLEditFormat("&reg;")#<br>
	&nbsp;&nbsp;&nbsp;&middot;&nbsp;&deg; (degrees)&nbsp;&nbsp;&nbsp;#HTMLEditFormat("&deg;")#
	</td>
	</tr> --->
	
	<tr class="content">
	<td align="right" valign="top">Description: </td>
	<td valign="top"><textarea name="description" rows="15" cols="62">#description#</textarea></td>
	</tr>
	
	<tr class="content">
	<td align="right" valign="top">Manufacturer's Logo: </td>
	<td valign="top">
		<select name="manuf_logo_ID">
			<option value=""<cfif manuf_logo_ID EQ ""> selected</cfif>>-- Select a Manufacturer --</option>
		<cfloop query="GetManufLogo">
			<option value="#getmanuflogo_ID#"<cfif manuf_logo_ID EQ getmanuflogo_ID> selected</cfif>>#manuf_name#</option>
		</cfloop>
		</select>

	</td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Product Category: </td>
	<td valign="top">#SelectPVMaster("productvalue_master_ID",productvalue_master_ID)#</td>
	</tr>
		
	<tr class="content">
	<td align="right" valign="top">Product Groups: </td>
	<td valign="top">
		<cfloop query="SelectGroups">
			<cfif Find(ID,thisProdsGroups)>
				<cfset thischecked = " checked">
			<cfelse>
				<cfset thischecked = "">
			</cfif>
			<input type="checkbox" name="product_meta_group_ID" value="#ID#"#thischecked#> #HTMLEditFormat(name)#<cfif SelectGroups.CurrentRow NEQ SelectGroups.RecordCount><br></cfif>
		</cfloop>
	</td>
	</tr>

	<tr class="content">
	<td align="right" valign="top">Upload Image: </td>
	<td valign="top"><input name="imagename_original" type="FILE" value="">
	<cfif imagename NEQ "">&nbsp;&nbsp;&nbsp;&nbsp;current image: <a href="../pics/products/#HTMLEditFormat(imagename)#" target="_blank">#htmleditformat(imagename_original)#</a></cfif></td>
	</tr>
				
	<tr class="content">
	<td align="right" valign="top">Upload Thumbnail: </td>
	<td valign="top"><input name="thumbnailname_original" type="FILE" value="">
	<cfif thumbnailname NEQ "">&nbsp;&nbsp;&nbsp;&nbsp;current image: <a href="../pics/products/#HTMLEditFormat(thumbnailname)#" target="_blank">#htmleditformat(thumbnailname_original)#</a></cfif></td>
	</tr>
				
	<tr class="content">
	<td colspan="2" align="center">
	
	<input type="hidden" name="xS" value="#xS#">
	<input type="hidden" name="xL" value="#xL#">
	<input type="hidden" name="xT" value="#xT#">
	<input type="hidden" name="xW" value="#xW#">
	<input type="hidden" name="xA" value="#xA#">
	<input type="hidden" name="OnPage" value="#OnPage#">
	
	<input type="hidden" name="meta_ID" value="#meta_ID#">
	<input type="hidden" name="gID" value="#gID#">
	<input type="hidden" name="gpgfn" value="#gpgfn#">
	
	<input type="hidden" name="meta_name_required" value="You must enter a product name.">
	<input type="hidden" name="description_required" value="You must enter a product description.">
	<input type="hidden" name="productvalue_master_ID_required" value="You must select a product category.">
		
	<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" >
	
	</td>
	</tr>
		
	</table>
</form>
</cfoutput>

<!--- END pgfn ADD/EDIT --->

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->