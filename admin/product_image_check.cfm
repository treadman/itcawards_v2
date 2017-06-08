<cfabort showerror="product_image_check.cfm is not working properly">
<cfsetting enablecfoutputonly="yes" showdebugoutput="no">

<cfset valid_files = "gif,jpg,psd">
<cfset prod_path = application.AbsPathProdImages&"pics/products/">
<cfset product_image_files = DirectoryList(prod_path)>

<!---  Multiple problems trying to do this:

Cannot delete files because no permission to do so
	<cfset FileDelete(prod_path & ListLast(product_image_files[x],"/"))>
	
File exists is case-sensitive, at least on this server


<!--- Is there a product record for the image? --->
<cfloop from="1" to="#ArrayLen(product_image_files)#" index="x">
	<cfset this_type = ListLast(product_image_files[x],".")>
	<cfset this_ID = ListFirst(ListLast(product_image_files[x],"/"),"_")>
	<cfif NOT isNumeric(this_ID) OR NOT ListFindNoCase(valid_files,this_type)>
		<cfoutput>Filename #ListLast(product_image_files[x],"/")# is not valid!<br></cfoutput>
	<cfelse>
		<cfquery name="GetProduct" datasource="#application.DS#">
			SELECT ID
			FROM #application.product_database#.product_meta
			WHERE ID = #this_ID#
		</cfquery>
		<cfif GetProduct.recordcount EQ 0>
			<cfoutput>#this_ID# (#this_type#): Orphaned file!<br></cfoutput>
		</cfif>
	</cfif>
</cfloop>
--->
		
<!--- Is there an image for the product record? --->
<cfquery name="MaxProductID" datasource="#application.DS#">
	SELECT MIN(ID) as min_id, MAX(ID) as max_id
	FROM #application.product_database#.product_meta
</cfquery>
<cfset row_num = MaxProductID.min_id>
<cfset max_id = MaxProductID.max_id>
<cfoutput>
First ID is: #row_num#<br>
Last ID is: #max_id#<br>
</cfoutput>
<cfquery name="GetProducts" datasource="#application.DS#">
	SELECT ID
	FROM #application.product_database#.product_meta
	ORDER BY ID
</cfquery>
<cfloop query="GetProducts">
	<cfif GetProducts.ID NEQ row_num>
		<cfloop condition="GetProducts.ID NEQ row_num">
			<cfoutput>#row_num# is not in products<br></cfoutput>
			<cfset row_num = row_num + 1>
			<cfif row_num GT max_id>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	<cfif NOT FileExists(prod_path&GetProducts.ID&"_thumbnail.jpg")
		AND NOT FileExists(prod_path&GetProducts.ID&"_thumbnail.gif")
		AND NOT FileExists(prod_path&GetProducts.ID&"_thumbnail.psd")>
		<cfoutput>#GetProducts.ID# has no thumbnail.<br></cfoutput>
	</cfif>
	
	<cfif NOT FileExists(prod_path&GetProducts.ID&"_image.jpg")
		AND NOT FileExists(prod_path&GetProducts.ID&"_image.gif")
		AND NOT FileExists(prod_path&GetProducts.ID&"_image.psd")>
		<cfoutput>#GetProducts.ID# has no image.<br></cfoutput>
	</cfif>
	<cfset row_num = row_num + 1>
</cfloop>
