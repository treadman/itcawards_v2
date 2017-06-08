<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000096,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="ID" default="">
<cfparam name="email_list" default="">
<cfparam name="Total_Input" default=0>
<cfparam name="pgfn" default="email_list">
<cfset program_ID = 1000000066>

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit') AND IsDefined('form.pgfn') AND form.pgfn IS "save_list">
	<cfset Data_List = ArrayNew(2)>
	<cfloop index="TheField" list="#Form.FieldNames#">
		<cfset Field_Name = TheField>
		<cfset Field_Value = Evaluate(TheField)>
		<cfif Find('EMAIL', Field_Name) GT 0>
			<cfset Array_Pointer = Mid(Field_Name,6,3)>
			<cfset Data_List[1][Array_Pointer] = Field_Value>
		<cfelseif Find('FIRST', Field_Name) GT 0>
			<cfset Array_Pointer = Mid(Field_Name,6,3)>
			<cfset Data_List[2][Array_Pointer] = Field_Value>
		<cfelseif Find('LAST', Field_Name) GT 0>
			<cfset Array_Pointer = Mid(Field_Name,5,3)>
			<cfset Data_List[3][Array_Pointer] = Field_Value>
		<cfelseif Find('COMPANY', Field_Name) GT 0>
			<cfset Array_Pointer = Mid(Field_Name,8,3)>
			<cfset Data_List[4][Array_Pointer] = Field_Value>
		<cfelseif Find('PHONE', Field_Name) GT 0>
			<cfset Array_Pointer = Mid(Field_Name,6,3)>
			<cfset Data_List[5][Array_Pointer] = Field_Value>
		<cfelseif Find('AMOUNT', Field_Name) GT 0>
			<cfset Array_Pointer = Mid(Field_Name,7,3)>
			<cfset Data_List[6][Array_Pointer] = Field_Value>
		<cfelseif Find('REASON', Field_Name) GT 0>
			<cfset Array_Pointer = Mid(Field_Name,7,3)>
			<cfset Data_List[7][Array_Pointer] = Field_Value>
		</cfif>
	</cfloop>
	<cfloop index="i" from="1" to="#Total_Input#">
		<!--- USER/EMAIL --->
		<cfquery name="CheckForEMail" datasource="#application.ds#">
			SELECT ID 
			FROM #application.database#.ext_user_input
			WHERE email = <cfqueryparam value="#Data_List[1][i]#" cfsqltype="CF_SQL_VARCHAR" maxlength="128"> AND created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">
		</cfquery>
		<cfif CheckForEMail.RecordCount IS 0>
			<cflock name="ext_user_inputLock" timeout="10">
				<cftransaction>
					<cfquery name="AddEMail" datasource="#application.ds#">
						INSERT INTO #application.DataBase#.ext_user_input
							(created_user_ID, created_datetime, program_ID, email, fname, lname, company, phone)
						VALUES (
							<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">,
							#FLGen_DateTimeToMySQL()#,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[1][i]#" maxlength="128">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[2][i]#" maxlength="30">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[3][i]#" maxlength="30">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[4][i]#" maxlength="30">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[5][i]#" maxlength="14">
						)
					</cfquery>
					<cfquery name="getID" datasource="#application.DS#">
						SELECT Max(ID) As MaxID 
						FROM #application.database#.ext_user_input
					</cfquery>
					<cfset UserID = UCASE(LEFT(Data_List[3][i],1)) & UCASE(LEFT(Data_List[2][i],1)) & NumberFormat(getID.MaxID, '00000')>
					<cfquery name="AssignUsername" datasource="#application.ds#">
						UPDATE #application.DataBase#.ext_user_input SET
							username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#UserID#" maxlength="16">
						WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getID.MaxID#" maxlength="10">
					</cfquery>
				</cftransaction>
			</cflock>
			<cfset ext_user_input_ID = getID.MaxID>
		<cfelse>
			<cfset ext_user_input_ID = CheckForEMail.ID>
			<cfquery name="UpdateEMail" datasource="#application.ds#">
				UPDATE #application.DataBase#.ext_user_input SET
					fname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[2][i]#" maxlength="30">,
					lname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[3][i]#" maxlength="30">,
					company = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[4][i]#" maxlength="30">,
					phone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Data_List[5][i]#" maxlength="14">
					#FLGen_UpdateModConcatSQL()#
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ext_user_input_ID#" maxlength="10">
			</cfquery>
		</cfif>
<!--- AWARDS --->
		<cfquery name="CheckForAward" datasource="#application.ds#">
			SELECT ID 
			FROM #application.database#.ext_user_input_award
			WHERE ext_user_input_ID = <cfqueryparam value="#ext_user_input_ID#" cfsqltype="cf_sql_integer" maxlength="10"> AND status = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0" maxlength="1">
		</cfquery>
		<cfif CheckForAward.RecordCount IS 0>
			<cfquery name="AddAmount" datasource="#application.ds#">
				INSERT INTO #application.DataBase#.ext_user_input_award
					(created_user_ID, created_datetime, ext_user_input_ID, points, reason_ID)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10">,
					#FLGen_DateTimeToMySQL()#,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#ext_user_input_ID#" maxlength="10">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#Data_List[6][i]#" maxlength="8">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#Data_List[7][i]#" maxlength="10">
				)
			</cfquery>
		<cfelse>
			<cfquery name="AddAmount" datasource="#application.ds#">
				UPDATE #application.DataBase#.ext_user_input_award SET
					points = <cfqueryparam cfsqltype="cf_sql_integer" value="#Data_List[6][i]#" maxlength="8">,
					reason_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Data_List[7][i]#" maxlength="10">
					#FLGen_UpdateModConcatSQL()#
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CheckForAward.ID#" maxlength="10">
			</cfquery>
		</cfif>
	</cfloop>
	<cfset pgfn = "email_list">
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "ext_user_award_admin">
<cfinclude template="includes/header.cfm">

<cfif pgfn EQ "email_list">
	<!--- START pgfn email_list --->
	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<input type="hidden" name="pgfn" value="parse_list" />
		<span class="pagetitle">Email Input</span>
		<br /><br />
		<table cellpadding="5" cellspacing="1" border="0">
			<tr class="contenthead">
				<td colspan="2" class="headertext">Email Input List</td>
			</tr>
			<tr class="content2">
				<td align="right" valign="top">&nbsp;</td>
				<td valign="bottom"><img src="../pics/contrls-desc.gif" width="7" height="6"> List of Email addresses to award</td>
			</tr>
			<tr class="content">
				<td align="right" valign="top">List: </td>
				<td valign="top"><textarea name="email_list" cols="40" rows="10">#email_list#</textarea></td>
			</tr>
			<tr class="content">
				<td colspan="2" align="center">
				<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" >
				</td>
			</tr>
		</table>
	</form>
	</cfoutput>
	<!--- END pgfn email_list --->
<cfelseif pgfn EQ "parse_list">
	<!--- START pgfn email_list --->
	<cfset email_list = Replace(email_list, CHR(13) & CHR(10), ',' , 'ALL')>
	<cfset email_list = Replace(email_list, CHR(10), ',' , 'ALL')>
	<cfset email_list = Replace(email_list, CHR(13), ',' , 'ALL')>
	<cfset email_list = Replace(email_list, ' ', '' , 'ALL')>
	<cfset email_list = LCASE(email_list)>
	<cfset array_list = ListToArray(email_list)>
	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<input type="hidden" name="pgfn" value="save_list" />
		<input type="hidden" name="Total_Input" value="#ArrayLen(array_list)#" />
		<span class="pagetitle">Email Input</span>
		<br /><br />
		<table cellpadding="5" cellspacing="1" border="0">
			<cfloop index="i" from="1" to="#ArrayLen(array_list)#">
				<cfquery name="CheckForUser" datasource="#application.ds#">
					SELECT EUI.ID, email, fname, lname, company, phone, IFNULL(points,0) AS points, IFNULL(reason_ID,0) AS reason_ID
					FROM #application.DataBase#.ext_user_input EUI
					LEFT JOIN #application.DataBase#.ext_user_input_award EUIA ON EUIA.ext_user_input_ID = EUI.ID AND EUIA.status = 0
					WHERE EUI.email = <cfqueryparam value="#array_list[i]#" cfsqltype="CF_SQL_VARCHAR" maxlength="128"> AND EUI.created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FLGen_adminID#" maxlength="10"> AND EUI.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
				</cfquery>
				<cfif CheckForUser.RecordCount GT 0>
					<cfset FirstName = HTMLEditFormat(CheckForUser.fname)>
					<cfset LastName = HTMLEditFormat(CheckForUser.lname)>
					<cfset CompanyName = HTMLEditFormat(CheckForUser.company)>
					<cfset PhoneNumber = HTMLEditFormat(CheckForUser.phone)>
					<cfset AwardPoints = HTMLEditFormat(CheckForUser.points)>
					<cfset ReasonCode = HTMLEditFormat(CheckForUser.reason_ID)>
				<cfelse>
					<cfset FirstName = "">
					<cfset LastName = "">
					<cfset CompanyName = "">
					<cfset PhoneNumber = "">
					<cfset AwardPoints = 0>
					<cfset ReasonCode = 0>
				</cfif>
				<tr class="contenthead">
					<td class="headertext">Email</td>
					<td class="headertext" colspan="2">First Name</td>
					<td class="headertext">Last Name</td>
				</tr>
					<tr class="#Iif(((i MOD 2) is 0),de('content2'),de('content'))#">
						<td valign="top"><input name="EMAIL#i#" type="text" value="#array_list[i]#" size="30" maxlength="128" readonly="true" /></td>
						<td valign="top" colspan="2"><input type="text" name="FIRST#i#" size="30" maxlength="30" value="#FirstName#" /></td>
						<td valign="top"><input type="text" name="LAST#i#" size="30" maxlength="30" value="#LastName#" /></td>
					</tr>
				<tr class="contenthead">
					<td class="headertext">Company</td>
					<td class="headertext">Phone</td>
					<td class="headertext">Amount </td>
					<td class="headertext">Reason</td>
				</tr>
				<tr class="#Iif(((i MOD 2) is 0),de('content2'),de('content'))#">
					<td valign="top"><input type="text" name="COMPANY#i#" size="30" maxlength="30" value="#CompanyName#" /></td>
					<td valign="top"><input type="text" name="PHONE#i#" size="14" maxlength="14" value="#PhoneNumber#" /></td>
					<td valign="top">$<input type="text" name="AMOUNT#i#" size="5" maxlength="5" value="#AwardPoints#" /></td>
					</td>
					<td valign="top">
						<select name="REASON#i#">
							<cfif ReasonCode IS 1><option value="0">---SELECT---</option></cfif>
							<option value="1"<cfif ReasonCode IS 1> selected</cfif>>Reason 1</option>
							<option value="2"<cfif ReasonCode IS 2> selected</cfif>>Reason 2</option>
							<option value="3"<cfif ReasonCode IS 3> selected</cfif>>Reason 3</option>
							<option value="4"<cfif ReasonCode IS 4> selected</cfif>>Reason 4</option>
							<option value="5"<cfif ReasonCode IS 5> selected</cfif>>Reason 5</option>
						</select>
					</td>
				</tr>
			</cfloop>
			<tr class="content">
				<td colspan="4" align="center">
				<input type="reset" value="Reset" >&nbsp;&nbsp;&nbsp;<input type="submit" name="submit" value="Save" >
				</td>
			</tr>
		</table>
	</form>
	</cfoutput>
	<!--- END pgfn email_list --->
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->