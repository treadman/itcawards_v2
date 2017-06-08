<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000008,true)>

<cfif de EQ "y">
	<!--- set all products with this meta_ID to is_active=0 --->
	<cfquery name="InactivateProducts" datasource="#application.DS#">
		UPDATE #application.product_database#.product
		SET	is_active= 0
			#FLGen_UpdateModConcatSQL()#
			WHERE product_meta_ID = '#meta_ID#'
	</cfquery>
	<cfset de = "y">
<cfelse>
	<!--- set all products with this meta_ID to is_active=0 --->
	<cfquery name="ActivateProducts" datasource="#application.DS#">
		UPDATE #application.product_database#.product
		SET	is_active= 1
			#FLGen_UpdateModConcatSQL()#
			WHERE product_meta_ID = '#meta_ID#'
	</cfquery>
	<cfset de = "n">
</cfif>

<!--- redirect back with msg QS --->
<cflocation addtoken="no" url="product.cfm?de=#de#&pgfn=#pgfn#&meta_ID=#meta_ID#&xS=#xS#&xL=#xL#&xT=#xT#&xW=#xW#&xA=#xA#&OnPage=#OnPage#">