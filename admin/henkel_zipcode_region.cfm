<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000100,true)>

<cfif NOT ListFind(request.henkel_ID_list, request.henkel_ID)>
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="orderby" default="region">
<cfparam name="sortdir" default="ASC">

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = 'henkel_zipcode_region'>
<cfinclude template="includes/header.cfm">

<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>

<cfparam name="pgfn" default="list">

<cfif pgfn EQ "list">
	<!--- START pgfn LIST --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT zipcode, region
		FROM #application.database#.xref_zipcode_region
		WHERE program_ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#request.henkel_ID#" maxlength="10">
		ORDER BY
		<cfswitch expression="#orderby#">
		<cfcase value="region">
			region #sortdir#, zipcode #sortdir#
		</cfcase>
		<cfcase value="zipcode">
			zipcode #sortdir#, region #sortdir#
		</cfcase>
		<cfdefaultcase>
			region #sortdir#, zipcode #sortdir#
		</cfdefaultcase>
		</cfswitch>
	</cfquery>
	<br /><br />
	<span class="pagetitle">Zipcode - Region</span>
	<br /><br />
	<table cellpadding="5" cellspacing="1" border="0">

	<cfoutput>
	<!--- header row --->
	<tr class="contenthead">
	<td class="headertext" style="white-space:nowrap">
		<a href="#CurrentPage#?orderby=zipcode&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'zipcode'>ASC<cfelse>DESC</cfif>">
			Zipcode <cfif orderby EQ "zipcode"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
		</a>
	</td>
	<td class="headertext" style="white-space:nowrap">
		<a href="#CurrentPage#?orderby=region&sortdir=<cfif sortdir EQ 'DESC' OR orderby NEQ 'region'>ASC<cfelse>DESC</cfif>">
			Region <cfif orderby EQ "region"><cfif sortdir EQ "ASC"><img src="/pics/contrls-asc.gif"><cfelse><img src="/pics/contrls-desc.gif"></cfif></cfif>
		</a>
	</td>
	</tr>
	</cfoutput>

	<!--- if no records --->
	<cfif SelectList.RecordCount IS 0>
		<tr class="content2">
		<td colspan="100%" align="center"><span class="alert"><br>No records found.<br><br></span></td>
		</tr>
	<cfelse>
		<!--- display found records --->
		<cfoutput query="SelectList">
			<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content'),de('content2'))#">
			<td>#htmleditformat(zipcode)#</td>
			<td>#htmleditformat(region)#</td>
			</tr>
		</cfoutput>
	</cfif>
	</table>
	<!--- END pgfn LIST --->
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->