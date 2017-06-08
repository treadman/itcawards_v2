<cfset HTMLFilePath = application.AbsPath & "email/">
<cfset URLFileName = 'arigame04.html'>

<cffile action="read" file="#HTMLFilePath##URLFileName#" variable="theFile">

<cfif isDefined('url.ID') AND url.ID NEQ "">
	<cfset IDCode = url.ID>
<cfelse>
	<cfset IDCode = "">
</cfif>

<cfset theFile = Replace(theFile, '%ID%', url.ID, 'all')>
				
<cfoutput>#theFile#</cfoutput>
