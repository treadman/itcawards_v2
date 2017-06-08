<!--- ----------------------------------------------- --->
<!--- ------  List and Edit MRO OEM records   ------- --->
<!--- ----------------------------------------------- --->
<cfif url.pgfn EQ "edit_mro_oem">
	<cfif NOT isNumeric(url.i)>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.program_type, i.count, i.date_entered_2,
				(SELECT IFNULL(MAX(p.points),0) AS points_awarded
				FROM #application.database#.henkel_points_lookup p
				WHERE i.program_type = p.program_type AND p.minimum <= i.count) AS awarded_points
			FROM #application.database#.henkel_import_mro_oem i
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
			AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			ORDER BY email
		</cfquery>
		<a href="<cfoutput>#CurrentPage#</cfoutput>?pgfn=results_mro_oem">Return</a>
		<br /><br />
		<table border="0">
			<cfoutput query="GetList">
				<tr>
					<td><a href="#CurrentPage#?pgfn=edit_mro_oem&email=#email#&i=#GetList.ID#">Edit</a></td>
					<td>#idh#</td>
					<td>#fname#</td>
					<td>#lname#</td>
					<td>#email#</td>
					<td>#program_type#</td>
					<td>#count#</td>
					<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
					<td>#awarded_points#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<cfquery name="GetEdit" datasource="#application.DS#">
			SELECT ID, idh, fname, lname, email, program_type, count, date_entered_2
			FROM #application.database#.henkel_import_mro_oem
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
			AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=edit_mro_oem&email=#url.email#</cfoutput>">Return</a>
		<br><br>
		<cfif GetEdit.recordcount NEQ 1>
			Cannot find the selected record!
		<cfelse>
			<cfoutput>
			<form method="post" action="#CurrentPage#?#CGI.QUERY_STRING#" name="changesForm">
			<table cellpadding="5" cellspacing="1" border="0" width="100%">
			
			<tr class="content">
			<td align="right" valign="top">IDH: </td>
			<td valign="top"><input type="text" name="idh" value="#GetEdit.idh#" maxlength="16" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">First Name: </td>
			<td valign="top"><input type="text" name="fname" value="#GetEdit.fname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Last Name: </td>
			<td valign="top"><input type="text" name="lname" value="#GetEdit.lname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Email: </td>
			<td valign="top"><input type="text" name="email" value="#GetEdit.email#" maxlength="128" size="40"></td>
			</tr>
				
			<tr class="content">
			<td align="right" valign="top">Program Type: </td>
			<td valign="top"><input type="text" name="program_type" value="#GetEdit.program_type#" maxlength="32" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Count: </td>
			<td valign="top"><input type="text" name="count" value="#GetEdit.count#" maxlength="4" size="10"></td>
			</tr>
				
			<tr class="content">
			<td colspan="2">
			<input type="hidden" name="import_type" value="mro_oem">
			<input type="submit" name="save_changes" value="  Save Changes  " >
		
			</td>
			</tr>
				
			</table>
			</form>
			</cfoutput>
		</cfif>
	</cfif>

<!--- ------------------------------------------ --->
<!--- ------  List and Edit LU records   ------- --->
<!--- ------------------------------------------ --->

<cfelseif url.pgfn EQ "edit_lu">
	<cfif NOT isNumeric(url.i)>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
			FROM #application.database#.henkel_import_lu i
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
			AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			ORDER BY email
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=results_lu</cfoutput>">Return</a>
		<br /><br />
		<table border="0">
			<cfoutput query="GetList">
				<tr>
					<td><a href="#CurrentPage#?pgfn=edit_lu&email=#email#&i=#GetList.ID#">Edit</a></td>
					<td>#idh#</td>
					<td>#fname#</td>
					<td>#lname#</td>
					<td>#email#</td>
					<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<cfquery name="GetEdit" datasource="#application.DS#">
			SELECT ID, idh, fname, lname, email, date_entered_2
			FROM #application.database#.henkel_import_lu
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
			AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=edit_lu&email=#url.email#</cfoutput>">Return</a>
		<br><br>
		<cfif GetEdit.recordcount NEQ 1>
			Cannot find the selected record!
		<cfelse>
			<cfoutput>
			<form method="post" action="#CurrentPage#?#CGI.QUERY_STRING#" name="changesForm">
			<table cellpadding="5" cellspacing="1" border="0" width="100%">
			
			<tr class="content">
			<td align="right" valign="top">IDH: </td>
			<td valign="top"><input type="text" name="idh" value="#GetEdit.idh#" maxlength="16" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">First Name: </td>
			<td valign="top"><input type="text" name="fname" value="#GetEdit.fname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Last Name: </td>
			<td valign="top"><input type="text" name="lname" value="#GetEdit.lname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Email: </td>
			<td valign="top"><input type="text" name="email" value="#GetEdit.email#" maxlength="128" size="40"></td>
			</tr>

			<tr class="content">
			<td colspan="2">
			<input type="hidden" name="import_type" value="lu">
			<input type="submit" name="save_changes" value="  Save Changes  " >
		
			</td>
			</tr>
				
			</table>
			</form>
			</cfoutput>
		</cfif>
	</cfif>

<!--- ------------------------------------------ --->
<!--- ------  List and Edit DCSE records   ------- --->
<!--- ------------------------------------------ --->

<cfelseif url.pgfn EQ "edit_dcse">
	<cfif NOT isNumeric(url.i)>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
			FROM #application.database#.henkel_import_dcse i
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
			AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			ORDER BY email
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=results_dcse</cfoutput>">Return</a>
		<br /><br />
		<table border="0">
			<cfoutput query="GetList">
				<tr>
					<td><a href="#CurrentPage#?pgfn=edit_dcse&email=#email#&i=#GetList.ID#">Edit</a></td>
					<td>#idh#</td>
					<td>#fname#</td>
					<td>#lname#</td>
					<td>#email#</td>
					<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<cfquery name="GetEdit" datasource="#application.DS#">
			SELECT ID, idh, fname, lname, email, date_entered_2
			FROM #application.database#.henkel_import_dcse
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
			AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=edit_dcse&email=#url.email#</cfoutput>">Return</a>
		<br><br>
		<cfif GetEdit.recordcount NEQ 1>
			Cannot find the selected record!
		<cfelse>
			<cfoutput>
			<form method="post" action="#CurrentPage#?#CGI.QUERY_STRING#" name="changesForm">
			<table cellpadding="5" cellspacing="1" border="0" width="100%">
			
			<tr class="content">
			<td align="right" valign="top">IDH: </td>
			<td valign="top"><input type="text" name="idh" value="#GetEdit.idh#" maxlength="16" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">First Name: </td>
			<td valign="top"><input type="text" name="fname" value="#GetEdit.fname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Last Name: </td>
			<td valign="top"><input type="text" name="lname" value="#GetEdit.lname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Email: </td>
			<td valign="top"><input type="text" name="email" value="#GetEdit.email#" maxlength="128" size="40"></td>
			</tr>

			<tr class="content">
			<td colspan="2">
			<input type="hidden" name="import_type" value="dcse">
			<input type="submit" name="save_changes" value="  Save Changes  " >
		
			</td>
			</tr>
				
			</table>
			</form>
			</cfoutput>
		</cfif>
	</cfif>

<!--- ------------------------------------------ --->
<!--- ------  List and Edit LEAK records   ------- --->
<!--- ------------------------------------------ --->

<cfelseif url.pgfn EQ "edit_leak">
	<cfif NOT isNumeric(url.i)>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
			FROM #application.database#.henkel_import_leak i
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
			AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			ORDER BY email
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=results_leak</cfoutput>">Return</a>
		<br /><br />
		<table border="0">
			<cfoutput query="GetList">
				<tr>
					<td><a href="#CurrentPage#?pgfn=edit_leak&email=#email#&i=#GetList.ID#">Edit</a></td>
					<td>#idh#</td>
					<td>#fname#</td>
					<td>#lname#</td>
					<td>#email#</td>
					<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<cfquery name="GetEdit" datasource="#application.DS#">
			SELECT ID, idh, fname, lname, email, date_entered_2
			FROM #application.database#.henkel_import_leak
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
			AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=edit_leak&email=#url.email#</cfoutput>">Return</a>
		<br><br>
		<cfif GetEdit.recordcount NEQ 1>
			Cannot find the selected record!
		<cfelse>
			<cfoutput>
			<form method="post" action="#CurrentPage#?#CGI.QUERY_STRING#" name="changesForm">
			<table cellpadding="5" cellspacing="1" border="0" width="100%">
			
			<tr class="content">
			<td align="right" valign="top">IDH: </td>
			<td valign="top"><input type="text" name="idh" value="#GetEdit.idh#" maxlength="16" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">First Name: </td>
			<td valign="top"><input type="text" name="fname" value="#GetEdit.fname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Last Name: </td>
			<td valign="top"><input type="text" name="lname" value="#GetEdit.lname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Email: </td>
			<td valign="top"><input type="text" name="email" value="#GetEdit.email#" maxlength="128" size="40"></td>
			</tr>

			<tr class="content">
			<td colspan="2">
			<input type="hidden" name="import_type" value="leak">
			<input type="submit" name="save_changes" value="  Save Changes  " >
		
			</td>
			</tr>
				
			</table>
			</form>
			</cfoutput>
		</cfif>
	</cfif>

<!--- ------------------------------------------- --->
<!--- ------  List and Edit DTS records   ------- --->
<!--- ------------------------------------------- --->

<cfelseif url.pgfn EQ "edit_dts">
	<cfif NOT isNumeric(url.i)>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2
			FROM #application.database#.henkel_import_dts i
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
			AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			ORDER BY email
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=results_dts</cfoutput>">Return</a>
		<br /><br />
		<table border="0">
			<cfoutput query="GetList">
				<tr>
					<td><a href="#CurrentPage#?pgfn=edit_dts&email=#email#&i=#GetList.ID#">Edit</a></td>
					<td>#idh#</td>
					<td>#fname#</td>
					<td>#lname#</td>
					<td>#email#</td>
					<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<cfquery name="GetEdit" datasource="#application.DS#">
			SELECT ID, idh, fname, lname, email, date_entered_2
			FROM #application.database#.henkel_import_dts
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
			AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=edit_dts&email=#url.email#</cfoutput>">Return</a>
		<br><br>
		<cfif GetEdit.recordcount NEQ 1>
			Cannot find the selected record!
		<cfelse>
			<cfoutput>
			<form method="post" action="#CurrentPage#?#CGI.QUERY_STRING#" name="changesForm">
			<table cellpadding="5" cellspacing="1" border="0" width="100%">
			
			<tr class="content">
			<td align="right" valign="top">IDH: </td>
			<td valign="top"><input type="text" name="idh" value="#GetEdit.idh#" maxlength="16" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">First Name: </td>
			<td valign="top"><input type="text" name="fname" value="#GetEdit.fname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Last Name: </td>
			<td valign="top"><input type="text" name="lname" value="#GetEdit.lname#" maxlength="30" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Email: </td>
			<td valign="top"><input type="text" name="email" value="#GetEdit.email#" maxlength="128" size="40"></td>
			</tr>

			<tr class="content">
			<td colspan="2">
			<input type="hidden" name="import_type" value="dts">
			<input type="submit" name="save_changes" value="  Save Changes  ">
		
			</td>
			</tr>
				
			</table>
			</form>
			</cfoutput>
		</cfif>
	</cfif>

<!--- ------------------------------------------- --->
<!--- ------  List and Edit JSC records   ------- --->
<!--- ------------------------------------------- --->

<cfelseif url.pgfn EQ "edit_jsc">
	<cfif NOT isNumeric(url.i)>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.fname, i.lname, i.email, i.date_entered_2
			FROM #application.database#.henkel_import_jsc i
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
			AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			ORDER BY email
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=results_jsc</cfoutput>">Return</a>
		<br /><br />
		<table border="0">
			<cfoutput query="GetList">
				<tr>
					<td><a href="#CurrentPage#?pgfn=edit_jsc&email=#email#&i=#GetList.ID#">Edit</a></td>
					<td>#fname#</td>
					<td>#lname#</td>
					<td>#email#</td>
					<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<cfquery name="GetEdit" datasource="#application.DS#">
			SELECT ID, fname, lname, email, date_entered_2
			FROM #application.database#.henkel_import_jsc
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
			AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=edit_jsc&email=#url.email#</cfoutput>">Return</a>
		<br><br>
		<cfif GetEdit.recordcount NEQ 1>
			Cannot find the selected record!
		<cfelse>
			<cfoutput>
			<form method="post" action="#CurrentPage#?#CGI.QUERY_STRING#" name="changesForm">
			<table cellpadding="5" cellspacing="1" border="0" width="100%">
			
			<tr class="content">
			<td align="right" valign="top">First Name: </td>
			<td valign="top"><input type="text" name="fname" value="#GetEdit.fname#" maxlength="32" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Last Name: </td>
			<td valign="top"><input type="text" name="lname" value="#GetEdit.lname#" maxlength="32" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Email: </td>
			<td valign="top"><input type="text" name="email" value="#GetEdit.email#" maxlength="128" size="40"></td>
			</tr>

			<tr class="content">
			<td colspan="2">
			<input type="hidden" name="import_type" value="jsc">
			<input type="submit" name="save_changes" value="  Save Changes  " >
		
			</td>
			</tr>
				
			</table>
			</form>
			</cfoutput>
		</cfif>
	</cfif>

<!--- ---------------------------------------------- --->
<!--- ------  List and Edit SIMPLE records   ------- --->
<!--- ---------------------------------------------- --->

<cfelseif url.pgfn EQ "edit_simple">
	<cfif NOT isNumeric(url.i)>
		<cfquery name="GetList" datasource="#application.DS#">
			SELECT i.ID, i.name, i.phone, i.email, i.date_entered_2
			FROM #application.database#.henkel_import_simple i
			WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
			AND i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
			AND i.date_processed IS NULL
			ORDER BY email
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=results_simple</cfoutput>">Return</a>
		<br /><br />
		<table border="0">
			<cfoutput query="GetList">
				<tr>
					<td><a href="#CurrentPage#?pgfn=edit_simple&email=#email#&i=#GetList.ID#">Edit</a></td>
					<td>#name#</td>
					<td>#phone#</td>
					<td>#email#</td>
					<td>#DateFormat(date_entered_2, "mm/dd/yyyy")#</td>
				</tr>
			</cfoutput>
		</table>
	<cfelse>
		<cfquery name="GetEdit" datasource="#application.DS#">
			SELECT ID, name, phone, email, date_entered_2
			FROM #application.database#.henkel_import_simple
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.i#">
			AND email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.email#" maxlength="128">
		</cfquery>
		<a href="<cfoutput>#CurrentPage#?pgfn=edit_simple&email=#url.email#</cfoutput>">Return</a>
		<br><br>
		<cfif GetEdit.recordcount NEQ 1>
			Cannot find the selected record!
		<cfelse>
			<cfoutput>
			<form method="post" action="#CurrentPage#?#CGI.QUERY_STRING#" name="changesForm">
			<table cellpadding="5" cellspacing="1" border="0" width="100%">
			
			<tr class="content">
			<td align="right" valign="top">Name: </td>
			<td valign="top"><input type="text" name="name" value="#GetEdit.name#" maxlength="64" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Phone: </td>
			<td valign="top"><input type="text" name="phone" value="#GetEdit.phone#" maxlength="32" size="40"></td>
			</tr>
			
			<tr class="content">
			<td align="right" valign="top">Email: </td>
			<td valign="top"><input type="text" name="email" value="#GetEdit.email#" maxlength="128" size="40"></td>
			</tr>

			<tr class="content">
			<td colspan="2">
			<input type="hidden" name="import_type" value="simple">
			<input type="submit" name="save_changes" value="  Save Changes  " >
		
			</td>
			</tr>
				
			</table>
			</form>
			</cfoutput>
		</cfif>
	</cfif>
</cfif>
