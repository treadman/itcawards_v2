<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000113,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->

<!--- param form fields --->

<!--- questions --->
<cfparam name="ID" default="0">
<cfparam name="question" default="">
<cfparam name="comment" default="">
<cfparam name="date_start_d" default="#DateFormat(Now(),'yyyy-mm-dd')#">
<cfparam name="date_start_t" default="00:00">
<cfparam name="date_end_d" default="#DateFormat(Now(),'yyyy-mm-dd')#">
<cfparam name="date_end_t" default="23:59">
<cfparam name="award_points" default="">

<!--- answers --->
<cfparam name="answer_ID" default="0">
<cfparam name="trivia_question_ID" default="">
<cfparam name="answer" default="">
<cfparam name="is_correct" default="0">


<!--- shared --->
<cfparam name="sort_order" default=""> <!--- This is just a label on the main button for questions which are sorted by start date --->

<cfparam name="pgfn" default="list">

<cfset alert_msg = "">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.UpdateQuestion')>
	<cfif NOT isValid('date',date_start_d)>
		<cfset alert_msg = alert_msg & "#date_start_d# is not a valid date. \n">
	</cfif>
	<cfif NOT isValid('time',date_start_t)>
		<cfset alert_msg = alert_msg & "#date_start_t# is not a valid time. \n">
	</cfif>
	<cfif NOT isValid('date',date_end_d)>
		<cfset alert_msg = alert_msg & "#date_end_d# is not a valid date. \n">
	</cfif>
	<cfif NOT isValid('time',date_end_t)>
		<cfset alert_msg = alert_msg & "#date_end_t# is not a valid time. \n">
	</cfif>
	<cfif NOT isValid('integer',award_points) OR award_points lte 0>
		<cfset alert_msg = alert_msg & "#award_points# is not a valid number for points. \n">
	</cfif>
	<cfif trim(question) EQ "">
		<cfset alert_msg = alert_msg & "Please enter a question. \n">
	</cfif>
	<!--- TODO: Warn if dates overlap anywhere --->
	<cfif alert_msg EQ "">
		<cfset date_start = date_start_d & " " & date_start_t & ":00.0">
		<cfset date_end = date_end_d & " " & date_end_t & ":59.9">
		<cfif ID EQ 0>
			<cfquery name="AddQuestion" datasource="#application.DS#">
				INSERT INTO #application.database#.trivia_question
					(program_ID,question,comment,date_start,date_end,award_points,sort_order)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#question#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#comment#">,
					<cfqueryparam cfsqltype="cf_sql_datetime" value="#date_start#">,
					<cfqueryparam cfsqltype="cf_sql_datetime" value="#date_end#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#award_points#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#sort_order#" maxlength="8">
				)
			</cfquery>
		<cfelse>
			<cfquery name="UpdateAdminUser" datasource="#application.DS#">
				UPDATE #application.database#.trivia_question
				SET
					question = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#question#">,
					comment = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#comment#">,
					date_start = <cfqueryparam cfsqltype="cf_sql_datetime" value="#date_start#">,
					date_end = <cfqueryparam cfsqltype="cf_sql_datetime" value="#date_end#">,
					award_points = <cfqueryparam cfsqltype="cf_sql_integer" value="#award_points#">,
					sort_order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sort_order#" maxlength="8">
					WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10">
			</cfquery>
		</cfif>
		<cfset pgfn = "list">
	</cfif>
</cfif>

<cfif IsDefined('form.UpdateAnswer')>
	<cfif trim(answer) EQ "">
		<cfset alert_msg = alert_msg & "Please enter an answer. \n">
	</cfif>
	<cfif alert_msg EQ "">
		<cfif answer_ID EQ 0>
			<cfquery name="AddQuestion" datasource="#application.DS#">
				INSERT INTO #application.database#.trivia_answer
					(trivia_question_ID,answer,is_correct,sort_order)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">,
					<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#answer#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#is_correct#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#sort_order#" maxlength="8">
				)
			</cfquery>
		<cfelse>
			<cfquery name="UpdateAdminUser" datasource="#application.DS#">
				UPDATE #application.database#.trivia_answer
				SET
					answer = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#answer#">,
					is_correct = <cfqueryparam cfsqltype="cf_sql_integer" value="#is_correct#">,
					sort_order = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sort_order#" maxlength="8">
					WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#answer_ID#" maxlength="10">
			</cfquery>
		</cfif>
		<cfset pgfn = "edit_q">
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "trivia">
<cfset request.main_width = 1100>
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Trivia Questions<cfif program_ID NEQ ""> for <cfoutput>#FLITC_GetProgramName(program_ID)#</cfoutput></cfif></span>
<br /><br />


<!--- START pgfn LIST QUESTIONS --->
<cfif pgfn EQ "list">

	<!--- run query --->
	<cfquery name="SelectList" datasource="#application.DS#">
		SELECT q.ID, q.question, q.comment, q.date_start, q.date_end, a.answer, a.is_correct,
			q.award_points, q.sort_order as qnum, a.sort_order as anum
		FROM #application.product_database#.trivia_question q
		LEFT JOIN #application.product_database#.trivia_answer a ON q.ID = a.trivia_question_ID
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
		ORDER BY q.date_start, q.ID, a.sort_order
	</cfquery>
	
	<table cellpadding="5" cellspacing="1" border="0" width="100%">

	<!--- header row --->
	<cfoutput>	
		<tr class="contenthead">
		<td align="center"><a href="#CurrentPage#?program_ID=#program_ID#&pgfn=add_q">Add</a></td>
		<td class="headertext">Question</td>
		<td class="headertext">Starts</td>
		<td class="headertext">Ends</td>
		</tr>
	</cfoutput>

	<!--- display found records --->
	<cfset check_date = "2000-01-01 00:00:00">
	<cfset dates_ok = true>
	<cfoutput query="SelectList" group="ID">
		<cfset can_delete = false>
		<!--- TODOD: If points have been awarded, they cannot delete --->
		<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
		<td><a href="#CurrentPage#?program_ID=#program_ID#&pgfn=edit_q&id=#ID#">Edit</a>&nbsp;&nbsp;&nbsp;<cfif can_delete><a href="#CurrentPage#?program_ID=#program_ID#&delete_q=#ID#" onclick="return confirm('Are you sure you want to delete this question?  There is NO UNDO.')">Delete</a></cfif></td>
		<td width="100%">
			#qnum#. #htmleditformat(question)# <i>[#award_points# points]</i><br>
			<cfoutput>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif isBoolean(is_correct) and is_correct>&##x2713;<cfelse>&nbsp;&nbsp;</cfif>
				#answer#
				<br>
			</cfoutput>
		</td>
		<td>
			<cfif date_start LT check_date>
				<span class="alert">
			</cfif>
			#DateFormat(date_start,'mm/dd/yyyy')#<br>at #TimeFormat(date_start,'HH:mm')#
			<cfif date_start LT check_date>
				<em>overlapped</em>
				</span>
			</cfif>
			<cfset check_date = date_start>
		</td>
		<td>
			<cfif date_end LT check_date>
				<span class="alert">
			</cfif>
			#DateFormat(date_end,'mm/dd/yyyy')#<br>at #TimeFormat(date_end,'HH:mm')#
			<cfif date_end LT check_date>
				<em>overlapped</em>
				</span>
			</cfif>
			<cfset check_date = date_end>
		</td>
		</tr>
	</cfoutput>

	</table>

<!----------------->
<!--- Questions --->	
<!----------------->

<cfelseif pgfn EQ "add_q" OR pgfn EQ "edit_q">
	<cfoutput>
	<span class="pageinstructions">Return to <a href="#CurrentPage#?program_ID=#program_ID#">Question List</a> without making changes.</span>
	<br /><br />
	</cfoutput>

	<cfif pgfn EQ "edit_q" and alert_msg EQ "">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT ID, question, comment, date_start, date_end, award_points, sort_order
			FROM #application.product_database#.trivia_question
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
		<cfset ID = ToBeEdited.ID>
		<cfset question = htmleditformat(ToBeEdited.question)>
		<cfset comment = htmleditformat(ToBeEdited.comment)>
		<cfset sort_order = htmleditformat(ToBeEdited.sort_order)>
		<cfset date_start_d = left(ToBeEdited.date_start,10)>
		<cfset date_start_t = mid(ToBeEdited.date_start,12,5)>
		<cfset date_end_d = left(ToBeEdited.date_end,10)>
		<cfset date_end_t = mid(ToBeEdited.date_end,12,5)>
		<cfset award_points = ToBeEdited.award_points>
	</cfif>

	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<input type="hidden" name="pgfn" value="#pgfn#">
		<input type="hidden" name="Program_ID" value="#Program_ID#">
		<input type="hidden" name="ID" value="#ID#">
			
	
		<table cellpadding="5" cellspacing="1" border="0" width="80%">
		
		<tr class="contenthead">
		<td colspan="2" class="headertext"><cfif pgfn EQ "add_q">Add<cfelse>Edit</cfif> a Question</td>
		</tr>
	
		<tr class="content">
		<td align="right">Button Text:</td>
		<td>Trivia Question <input type="text" name="sort_order" value="#sort_order#" maxlength="8" size="3">... Earn Points</td>
		</tr>
	
		<tr class="content">
		<td align="right">Question: </td>
		<td><textarea name="question" cols="58" rows="3">#question#</textarea></td>
		</tr>
		
		<tr class="content">
		<td align="right">Comment:<br><em>Displayed after answering question.</em></td>
		<td><textarea name="comment" cols="58" rows="3">#comment#</textarea></td>
		</tr>
		
		<tr class="content">
		<td align="right">Starting:</td>
		<td>
			<input type="text" name="date_start_d" value="#date_start_d#" maxlength="10" size="10">
			at
			<input type="text" name="date_start_t" value="#date_start_t#" maxlength="5" size="5">
		</td>
		</tr>

		<tr class="content">
		<td align="right">Ending:</td>
		<td>
			<input type="text" name="date_end_d" value="#date_end_d#" maxlength="10" size="10">
			at
			<input type="text" name="date_end_t" value="#date_end_t#" maxlength="5" size="5">
		</td>
		</tr>

		<tr class="content">
		<td align="right">Points to Award:</td>
		<td>
			<input type="text" name="award_points" value="#award_points#" maxlength="5" size="5">
		</td>
		</tr>


		<tr class="contenthead">
		<td colspan="2" style="height:1px;"></td>
		</tr>

		<tr>	
		<td colspan="2" align="center"><br>
		<input type="submit" name="UpdateQuestion" value="   Save  Question   " >
		</td>
		</tr>
		</table>
	</form>
	</cfoutput>
	<cfif ID GT 0>
		<br><br>
		<cfquery name="SelectList" datasource="#application.DS#">
			SELECT ID as answer_ID, answer, is_correct, sort_order
			FROM #application.product_database#.trivia_answer
			WHERE trivia_question_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10">
			ORDER BY sort_order
		</cfquery>
		<table cellpadding="5" cellspacing="1" border="0" width="60%">
		
			<!--- header row --->
			<cfoutput>	
				<tr class="contenthead">
				<td align="center" width="10%"><a href="#CurrentPage#?program_ID=#program_ID#&pgfn=add_a&id=#ID#">Add</a></td>
				<td class="headertext" width="5%"></td>
				<td class="headertext" width="85%">Answer</td>
				</tr>
			</cfoutput>
		
			<cfif SelectList.recordcount EQ 0>
				<tr class="content"><td colspan="3" align="center">No answers entered yet.</td></tr>
			<cfelse>
				<!--- display found records --->
				<cfoutput query="SelectList">
					<cfset can_delete = false>
					<!--- TODOD: If points have been awarded, they cannot delete --->
					<tr class="#Iif(((CurrentRow MOD 2) is 0),de('content2'),de('content'))#">
					<td><a href="#CurrentPage#?program_ID=#program_ID#&pgfn=edit_a&answer_id=#answer_ID#&id=#ID#">Edit</a><cfif can_delete>&nbsp;&nbsp;&nbsp;<a href="#CurrentPage#?program_ID=#program_ID#&delete_a=#answer_ID#&id=#ID#" onclick="return confirm('Are you sure you want to delete this question?  There is NO UNDO.')">Delete</a></cfif></td>
					<td align="center"><cfif isBoolean(is_correct) and is_correct>&##x2713;<cfelse>&nbsp;&nbsp;</cfif></td>
					<td>#answer#</td>
					</tr>
				</cfoutput>
			
			</cfif>
		</table>
	</cfif>

<!--------------->
<!--- Answers --->	
<!--------------->
	
<cfelseif pgfn EQ "add_a" OR pgfn EQ "edit_a">
	<cfoutput>
	<span class="pageinstructions">
		Return to the <a href="#CurrentPage#?program_ID=#program_ID#&ID=#ID#&pgfn=edit_q">Question</a>
		or to the <a href="#CurrentPage#?program_ID=#program_ID#">Question List</a> without making changes.
	</span>
	<br /><br />
	</cfoutput>

	<cfif pgfn EQ "edit_a" and alert_msg EQ "">
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT a.ID as answer_ID, a.trivia_question_ID, q.question, a.answer, a.is_correct, a.sort_order
			FROM #application.product_database#.trivia_answer a
			LEFT JOIN #application.product_database#.trivia_question q ON q.ID = a.trivia_question_ID
			WHERE a.ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#answer_ID#" maxlength="10">
		</cfquery>
		<cfset answer_ID = ToBeEdited.answer_ID>
		<cfset ID = ToBeEdited.trivia_question_ID>
		<cfset answer = htmleditformat(ToBeEdited.answer)>
		<cfset is_correct = ToBeEdited.is_correct>
		<cfset sort_order = htmleditformat(ToBeEdited.sort_order)>
	<cfelse>
		<cfquery name="ToBeEdited" datasource="#application.DS#">
			SELECT question
			FROM #application.product_database#.trivia_question
			WHERE ID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#ID#" maxlength="10">
		</cfquery>
	</cfif>
	<cfset question = htmleditformat(ToBeEdited.question)>

	<cfoutput>
	<form method="post" action="#CurrentPage#">
		<input type="hidden" name="pgfn" value="#pgfn#">
		<input type="hidden" name="Program_ID" value="#Program_ID#">
		<input type="hidden" name="ID" value="#ID#">
		<input type="hidden" name="answer_ID" value="#answer_ID#">
			
	
		<table cellpadding="5" cellspacing="1" border="0" width="80%">
		
		<tr class="contenthead">
		<td colspan="2" class="headertext"><cfif pgfn EQ "add_a">Add<cfelse>Edit</cfif> an Answer</td>
		</tr>

		<tr class="content">
		<td align="right">Question:</td>
		<td class="headertext">#question#</td>
		</tr>
	
		<tr class="content">
		<td align="right">Sort&nbsp;Order:</td>
		<td><input type="text" name="sort_order" value="#sort_order#" maxlength="8" size="3"></td>
		</tr>
	
		<tr class="content">
		<td align="right">Answer: </td>
		<td><textarea name="answer" cols="58" rows="3">#answer#</textarea></td>
		</tr>
		
		<tr class="content">
		<td align="right">Correct?</td>
		<td>
			<input type="radio" name="is_correct" value="1" <cfif is_correct>checked</cfif>> Yes
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="is_correct" value="0" <cfif not is_correct>checked</cfif>> No
		</td>
		</tr>


		<tr class="contenthead">
		<td colspan="2" style="height:1px;"></td>
		</tr>

		<tr>	
		<td colspan="2" align="center"><br>
		<input type="submit" name="UpdateAnswer" value="   Save  Answer   " >
		</td>
		</tr>
		</table>
	</form>
	</cfoutput>
</cfif>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->