<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<cfif isDefined('url.c') and url.c EQ 1 and isDefined('url.user')>
	<cfquery name="clear" datasource="#application.DS#">
		DELETE FROM #application.product_database#.xref_trivia_user
		WHERE program_user_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.user#">
	</cfquery>
	Cleared trivia answers.<br><br>
	<a href="javascript:history.back()" class="actionlink">Go back</a>
	<cfabort>
</cfif>

<cfset GetProgramInfo()>
<cfif NOT AuthenticateProgramUserCookie()>
	<cflocation addtoken="no" url="zkick.cfm">
</cfif>


<cfsavecontent variable="trivia_answer_output" >
<cfoutput>
<div class="trivia" id="trivia_question">
	<cfset award_points = true>
	<cfset is_correct = false>
	<cfset this_user = ListGetAt(cookie.itc_user,1,"-")>
	<cfset this_notes = "">
	<cfset this_points = "">
	<cfset points_id = 0>

	<cfif award_points>
		<cfset thisQuestion = GetQuestionByID(form.question)>
		<cfif thisQuestion.recordcount NEQ 1>
			<cfset award_points = false>
			<p class="alert">Error: Question not found.</p>
		</cfif>
	</cfif>

	<cfif award_points>
		<p class="trivia_question" align="left">#thisQuestion.question#</p>
		<cfset this_notes = "Correctly answered question: #thisQuestion.question#">
		<cfset this_points = thisQuestion.award_points>
		<cfif NOT isDefined('form.answer') OR NOT isDefined('form.question')>
			<cfset award_points = false>
			<br>
			<p align="left" class="alert">You did not select an answer.</p>
			<br><br><br>
		</cfif>
	</cfif>
	
	<cfif award_points>
		<cfset userAnswer = GetUserAnswer(form.question,this_user)>
		<cfif userAnswer.recordcount GT 0>
			<cfset award_points = false>
			<br>
			<p class="alert">You already answered this question.</p>
			<br><br><br>
		</cfif>
	</cfif>

	<cfif award_points>
		<cfset is_correct = CheckAnswer(form.question,form.answer)>
		<cfif is_correct>
			 <cfif this_points GT 0>
				<cfquery datasource="#application.DS#" name="AwardPoints" result="this_result">
					INSERT INTO #application.database#.awards_points (
					created_user_ID, created_datetime, user_ID, points, notes)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_user#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_user#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_points#">,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#this_notes#">
					)
				</cfquery>
			 </cfif>
			<cfset points_id = this_result.generatedkey>
			<cfset ProgramUserInfo(this_user,true)>
		</cfif>
		<cfquery name="UserAnswer" datasource="#application.DS#">
			INSERT INTO #application.database#.xref_trivia_user (
				trivia_question_id, trivia_answer_id, program_user_ID, created_datetime, was_correct, award_points_id)
			VALUES (
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.question#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.answer#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_user#" maxlength="10">,
				'#FLGen_DateTimeToMySQL()#',
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iif(is_correct,1,0)#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#points_id#">
			)
		</cfquery>
		
		<p align="left" class="trivia_answer">
			<cfset userAnswer = GetUserAnswer(form.question,this_user)>
			Your answer: #userAnswer.answer#
		</p>
		<p align="left" class="trivia_answer">
			<cfif is_correct>
				Congrats!  You've just earned #this_points# HRB points!
			<cfelse>
				Sorry, but that is incorrect.
			</cfif>
		</p>
		<p align="left" class="trivia_question">
			Remember to come back soon to test your Loctite knowledge and earn more points!
		</p>
	</cfif>
	<br>

		<span style="padding:10px; margin-top:50px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='welcome.cfm'">
			Close
		</span>

</div>
<script>
	showThis('trivia_question');
	hideThis('trivia_button');
</script>
</cfoutput>
</cfsavecontent>


<cfset in_trivia_answer = true>
<cfinclude template="welcome.cfm" >


<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>
<cfabort>





<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>
<cfparam name="DisplayMode" default="Welcome">

<cfif NOT AuthenticateProgramUserCookie()>
	<cflocation addtoken="no" url="zkick.cfm">
</cfif>


<cfset thisProgramID = LEFT(cookie.itc_pid,10)>

<CFSCRIPT>
	kFLGen_ImageSize = FLGen_ImageSize(application.FilePath & "pics/program/" & vLogo);
</CFSCRIPT>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<title>ITC Awards</title>
	<style type="text/css"> 
		<cfinclude template="includes/program_style.cfm"> 
	</style>
	<!--- <cfif thisProgramID EQ "1000000071">
		<link href="globalrewards.css" rel="stylesheet" type="text/css" />
	</cfif> --->
	<script src="includes/showhide.js"></script>
	<script language="javascript">
		function mOver(item, newClass)
			{item.className=newClass}
		function mOut(item, newClass)
			{item.className=newClass}
		function openHelp()
			{
			 windowHeight = (screen.height - 150)
			 helpLeft = (screen.width - 615)
			 winAttributes = 'width=600, top=1, resizable=yes, scrollbars=yes, status=yes, titlebar=yes, height=' + windowHeight + ', left =' + helpLeft
			 window.open('help.cfm','Help',winAttributes);
			}
		<cfoutput>
		function openCertificate()
			{
			 winAttributes = 'width=600, top=1, resizable=yes, scrollbars=yes, status=yes, titlebar=yes'
			 winPath = '#application.WebPath#/award_certificate/#users_username#_certificate_#program_ID#.pdf'
			 window.open(winPath,'Certificate',winAttributes);
			}
		</cfoutput>
	</script>
		<style>
.squareImg1
    {
    display: block;
    width: 111px;
    height: 111px;
	margin-top:15px;
	margin-left:5px;
    background-image: url("pics/4090_Tube.jpg"); 
    }

.squareImg2
    {
    display: block;
    width: 112px;
    height: 56px;
    background-image: url("pics/4090_Dispenser.jpg"); 
    }
a:hover {
	color:#CC2D30 !important;
}
#trivia_answer {
	display: block;
	position: fixed;
	width: 270px;
	margin-left:75px;
}
	</style>
</head>

<cfoutput>
<cfif thisProgramID EQ "1000000066">

	<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" background="pics/program/henkel/HenkelBackground.jpg">
	<cfinclude template="includes/environment.cfm"> 
	<table cellpadding="0" cellspacing="0" border="0" align="center" width="100%">
		<tr>
			<td></td>
			<td width="425"><img src="pics/program/henkel/HenkelBoard.jpg" width="425" height="101" lt="Henkel Rewards Board" border="0"></td>
			<td>&nbsp;</td>
		</tr>
		<tr bgcolor="##FFFFFF">
			<td valign="top" align="right" style="padding-right:30px;">
			</td>
			<td valign="top">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="6" valign="top"><img src="pics/program/henkel/HenkelBoardLegs.jpg" width="6" height="220" alt="" border="0"></td>
						<td width="413" valign="top" align="center">

<div id="trivia_answer">
	<cfset award_points = true>
	<cfset is_correct = false>
	<cfset this_user = ListGetAt(cookie.itc_user,1,"-")>
	<cfset this_notes = "">
	<cfset this_points = "">
	<cfset points_id = 0>

	<cfif award_points>
		<cfset thisQuestion = GetQuestionByID(form.question)>
		<cfif thisQuestion.recordcount NEQ 1>
			<cfset award_points = false>
			<p class="alert">Error: Question not found.</p>
		</cfif>
	</cfif>

	<cfif award_points>
		<p align="left">#thisQuestion.question#</p>
		<cfset this_notes = "Correctly answered question: #thisQuestion.question#">
		<cfset this_points = thisQuestion.award_points>
		<cfif NOT isDefined('form.answer') OR NOT isDefined('form.question')>
			<cfset award_points = false>
			<p class="alert">You did not select an answer.</p>
		</cfif>
	</cfif>
	
	<cfif award_points>
		<cfset userAnswer = GetUserAnswer(form.question,this_user)>
		<cfif userAnswer.recordcount GT 0>
			<cfset award_points = false>
			<p class="alert">You already answered this question.</p>
		</cfif>
	</cfif>

	<cfif award_points>
		<!--- form exists, question exists, user not answered --->
		<cfset is_correct = CheckAnswer(form.question,form.answer)>
		<cfif is_correct>
			Yes!  That's right!
		<cfelse>
			Sorry, but that answer was incorrect.
		</cfif>
	</cfif>
	
	<cfif award_points>
		<cfif is_correct>
			 <cfif this_points GT 0>
				<cfquery datasource="#application.DS#" name="AwardPoints" result="this_result">
					INSERT INTO #application.database#.awards_points (
					created_user_ID, created_datetime, user_ID, points, notes)
					VALUES (
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_user#" maxlength="10">,
						'#FLGen_DateTimeToMySQL()#',
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_user#" maxlength="10">,
						<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_points#">,
						<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#this_notes#">
					)
				</cfquery>
			 </cfif>
			<cfset points_id = this_result.generatedkey>
			<cfset ProgramUserInfo(this_user,true)>
		</cfif>
		<cfquery name="UserAnswer" datasource="#application.DS#">
			INSERT INTO #application.database#.xref_trivia_user (
				trivia_question_id, trivia_answer_id, program_user_ID, created_datetime, was_correct, award_points_id)
			VALUES (
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.question#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#form.answer#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#this_user#" maxlength="10">,
				'#FLGen_DateTimeToMySQL()#',
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#iif(is_correct,1,0)#" maxlength="10">,
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#points_id#">
			)
		</cfquery>
		
	</cfif>

<br><br><br>

									<span style="padding:10px; margin-top:50px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='welcome.cfm'">
										Return to Henkel Rewards Board
									</span>

</div>

						</td>
						<td width="6" valign="top"><img src="pics/program/henkel/HenkelBoardLegs.jpg" width="6" height="220" alt="" border="0"></td>
					</tr>
				</table>
			</td>
			<td valign="bottom" align="left" style="padding-left:30px;">
			</td>
		</tr>
	</table>
	</body>
</cfif>
</cfoutput>
</html>
