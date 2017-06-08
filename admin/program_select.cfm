<cfcookie name="program_id" value="#form.Program#">

<!--- TODO:  Old henkel select stuff might go away --->
<cfif ListFind(request.henkel_ID_list,form.Program)>
	<cfcookie name="henkel_id" value="#form.Program#">
<cfelse>
	<cfcookie name="henkel_ID" expires="now" value="">
</cfif>

<cflocation url="#form.ReturnTo#" addtoken="no">
