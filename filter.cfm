<cfif isDefined("form.submitFilter")>
	<cfif form.filterValue NEQ "">
		<!--- Set the cookie --->
		<cfcookie name="filter" value="#form.filterValue#">
	<cfelse>
		<!--- Delete the cookie --->
		<cfcookie name="filter" expires="now">
	</cfif>
</cfif>

<!--- Locate to main --->
<cflocation url="main.cfm?c=#c#&g=#g#" addtoken="no">
