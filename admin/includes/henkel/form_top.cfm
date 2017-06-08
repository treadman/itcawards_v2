<cfset thisDupeList = "">
<cfif isDefined("form.process")>
	<cfset doit = true>
	<cfif ListLen(form.dupeList) GT 0>
		<cfset counter = 1>
		<cfloop list="#form.dupeList#" index="thisDupe">
			<cfif NOT isDefined("form.dupe_#counter#")>
				<script>alert('Please select a user for <cfoutput>#thisDupe#</cfoutput>!');</script>
				<cfset doit = false>
			</cfif>
			<cfset counter = counter + 1>
		</cfloop>
	</cfif>
	<cfif request.selected_henkel_program.is_registration_closed>
		<cfif isDefined("form.hasHolds")>
			<script>alert('There are people in the spreadsheet who are not in the system.\n\nNormally, these would go into the "hold" area.  Since registration is closed for this program, this is not allowed.\n\nPlease correct this problem and try again.');</script>
			<cfset doit = false>
		</cfif>
	</cfif>
</cfif>
<form method="post" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>" name="processForm">
