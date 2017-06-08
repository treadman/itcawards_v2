<!--- <cfif isDefined("form.HenkelProgram")> --->
	<cfcookie name="henkel_id" value="#form.HenkelProgram#">
	<!--- <cfif isDefined("form.ReturnTo")> --->
		<cfif form.ReturnTo EQ "program_user.cfm">
			<cfset form.ReturnTo = "pickprogram.cfm?n=program_user">
		</cfif>
		<cflocation url="#form.ReturnTo#" addtoken="no">
	<!--- <cfelse>
		<cflocation url="index.cfm" addtoken="no">
	</cfif> --->
<!--- <cfelse>
	<cflocation url="index.cfm" addtoken="no"> --->
<!--- </cfif> --->