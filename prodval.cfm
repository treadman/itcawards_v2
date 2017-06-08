<cfif isDefined("form.searchText") AND form.searchText NEQ "">
	<!--- Set the cookie --->
	<cfcookie name="prodval" value="#form.searchText#">
<!--- <cfelseif isDefined("url.clear")>
	<!--- Delete the cookie --->
	<cfcookie name="search" expires="now"> --->
<cfelse>
	<cfdump var="#form#"><cfabort>
</cfif>

<!--- Locate to main --->
<cflocation url="main.cfm?c=#c#&g=#g#" addtoken="no">
