<cfparam name="in_trivia_answer" default="false" >
<cfif NOT in_trivia_answer>
	<!--- import function library --->
	<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
	<cfinclude template="includes/function_library_itcawards.cfm">
	<!--- authenticate program cookie and get program vars --->
	<cfset GetProgramInfo()>
</cfif>

<cfparam name="DisplayMode" default="Welcome">

<cfset thisProgramID = LEFT(cookie.itc_pid,10)>

<CFSCRIPT>
	kFLGen_ImageSize = FLGen_ImageSize(application.FilePath & "pics/program/" & vLogo);
</CFSCRIPT>

<cfif thisProgramID EQ "1000000071" OR thisProgramID EQ "1000000070">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="shortcut icon" href="/favicon.ico" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Henkel Rewards Board</title>
<link href="globalrewards.css" rel="stylesheet" type="text/css" />
</head>
<cfelse>
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
    width: 140px;
    height: 140px;
	margin-top:15px;
	margin-left:5px;
    background-image: url("pics/group-2.gif"); 
	background-size: 100% 100%; 
    }

.squareImg2
    {
    display: block;
    width: 140px;
    height: 66px;
    background-image: url("pics/locgun-400.gif");
	background-size: 100% 100%; 
    }
a:hover {
	color:#CC2D30 !important;
}
#trivia_button {
	display: block;
	position: fixed;
	width: 390px;
	margin-left:14px;
}
#trivia_question {
	display: none;
	position: fixed;
	border: 1px solid #6E6F73;
	/* background-image: url('pics/program/henkel/HenkelBackground.jpg'); */
	background-color: #ebe1d8;
	margin-left:28px;
	margin-top: -20px;
	padding-left: 25px;
	height:200px;
	width:340px;
}

	</style>
</head>
</cfif>

<cfoutput>
<cfif thisProgramID EQ "1000000066">


	<!--- Answer trivia - win points --->
	<cfset has_answered = false>
	<cfset has_trivia = false>
	<cfset mydomain = ''>

	<cfif NOT in_trivia_answer>
		<!--- Check for valid email address --->
		<cfif isDefined('GetUserName.email') AND GetUserName.email NEQ '' AND find('@',GetUserName.email) GT 0>
			<cfset mydomain = mid(GetUserName.email,find('@',GetUserName.email)+1,555)>
	
			<!--- limited to certain email addresses --->
			<cfif
				len(GetUserName.email) GT 10
				AND ( 
					ListFindNoCase('treadmen@hotmail.com',GetUserName.email)
					OR mydomain EQ 'fastenal.com'
					OR left(mydomain,3) EQ 'itc'
				)
			>
				<cfset has_trivia = true>
			</cfif>
	
			<!--- Is there a questions for today? --->
			<cfif has_trivia>
				<cfset thisQuestion = GetQuestion()>
				<cfif thisQuestion.recordcount NEQ 1>
					<cfset has_trivia = false>
				</cfif>
			</cfif>
	
			<!--- Have they answered already? --->
			<cfif has_trivia>
				<cfset userAnswer = GetUserAnswer(thisQuestion.ID,ListGetAt(cookie.itc_user,1,"-"))>
				<cfif userAnswer.recordcount GT 0>
					<cfset has_answered = true>
				</cfif>
			</cfif>
	
			<!--- Get the answers --->
			<cfif has_trivia>
				<cfset theseAnswers = GetAnswers(thisQuestion.ID)>
				<cfif theseAnswers.recordcount EQ 0>
					<cfset has_trivia = false>
				</cfif>
			</cfif>
	
	
		</cfif>
		<!--- End of trivia set up --->
	</cfif>



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
				<table cellpadding="8" cellspacing="1" border="0">
					<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='main.cfm'">#welcome_button#</td></tr>
					<tr><td align="left" class="active_button_henkel">#welcome_instructions#</td></tr>
					<cfif additional_content_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='additional_content.cfm'">#additional_content_button#</td></tr>
					</cfif>
					<cfif email_form_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='email_form.cfm'">#email_form_button#</td></tr>
					</cfif>
					<tr><td>&nbsp;</td></tr>
					<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='henkel-register.cfm'">Registration</td></tr>
					<tr><td align="left" class="active_button_henkel">
<font size="1">&nbsp; <br />&nbsp;
You must <strong>register</strong> to<br />&nbsp;
use this web site.<br />&nbsp;
Click the registration<br />&nbsp;
button and follow the<br />&nbsp;
prompts. You must<br />&nbsp;
create a unique<br />&nbsp;
password and agree<br />&nbsp;
to the terms and<br />&nbsp;
conditions and privacy<br />&nbsp;
policy.<br /><br /></font>
</td></tr>

					<cfif FileExists(application.FilePath & "award_certificate/" & users_username & "_certificate_" & program_ID & ".pdf")>
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="openCertificate()">View Certificate</td></tr>
					</cfif>
					<cfif help_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="openHelp()">#help_button#</td></tr>
					</cfif>
					<cfif welcome_admin_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='/admin/index.cfm'">#welcome_admin_button#</td></tr>
					</cfif>
				</table><br><a href="henkel-contact-us.cfm"><img src="pics/program/henkel/HenkelContactUs.jpg" alt="Contact Us" width="82" height="31" border="0"></a> &nbsp;<a href="welcome.cfm"><img src="pics/program/henkel/HenkelHome.jpg" alt="Home" width="57" height="31" border="0"></a>
			</td>
			<td valign="top">
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="6" valign="top"><img src="pics/program/henkel/HenkelBoardLegs.jpg" width="6" height="220" alt="" border="0"></td>
						<td width="413" valign="bottom" align="center">
							<cfif display_message NEQ "">#display_message#<br><br><br></cfif>

							<!--- Answer trivia - win points --->
							<cfif in_trivia_answer>

								#trivia_answer_output#

							<cfelseif has_trivia>

							 	<div id="trivia_button">
									<span style="padding:10px; margin-top:50px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="showThis('trivia_question'); hideThis('trivia_button');">
										Loctite Trivia Question ###thisQuestion.sort_order#... earn Henkel bucks!
									</span>
								</div>

								<div class="trivia" id="trivia_question">
									<p class="trivia_question" align="left">#thisQuestion.question#</p>
									<cfif has_answered>
										<br>
										<p align="left" class="alert">You already answered this question.</p>
										<br><br><br><br>
										<span style="padding:10px; margin-top:50px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="hideThis('trivia_question'); showThis('trivia_button');">
											Close
										</span>
									<cfelse>
										<form name="trivia_form" method="post" action="trivia_answer.cfm">
											<input type="hidden" name="question" value="#thisQuestion.ID#">
											<p align="left" class="trivia_answer">
											<cfloop query="theseAnswers">
												<input type="radio" name="answer" value="#theseAnswers.ID#">
												#theseAnswers.answer#<br><br>
											</cfloop>
											</p>
											<span style="padding:10px; margin-top:50px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="hideThis('trivia_question'); trivia_form.submit();">
												Continue
											</span>
										</form>
									</cfif>
								</div>
									



								</cfif>
	
	
							<cfif DisplayMode EQ "Welcome"><span class="welcome">#Replace(welcome_message,chr(10),"<br>","ALL")#</span></cfif>
							<cfif not IsDefined('cookie.itc_user') OR cookie.itc_user EQ "">
								<br><br><br>
							</cfif>
							<!---<br><br><br><br><br>--->
							
							<a href="http://na.henkel-adhesives.com/thread-sealant-14405.htm" target="_blank">
								<img src="pics/program/henkel/15613_Sealant-Upgrade.jpg" width="330" height="143">
							</a>
							<!---<img src="pics/program/henkel/Henkel-Logo.jpg" width="94" height="61">--->
						</td>
						<td width="6" valign="top"><img src="pics/program/henkel/HenkelBoardLegs.jpg" width="6" height="220" alt="" border="0"></td>
					</tr>
				</table>
			</td>
			<td valign="bottom" align="left" style="padding-left:30px;">
				<span style="padding:10px; margin-top:50px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='main.cfm'">&nbsp;Main Menu&nbsp;</span>
				<br><br><br><br>
				<cfif additional_content2_button NEQ "">
					<span style="padding:10px; margin-top:50px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='additional_content.cfm?n=2'">#additional_content2_button#</span>
				</cfif>
				<br><br><br><br>
				<a href="http://www.loctitetraining.com/" style="text-decoration:none; color:black;">
					<div style="width:123px; text-align:center;">
					Check out the new Loctite&reg; 4090&trade; Hybrid Structural Instant Adhesive training module at Henkel University.com and earn valuable Henkel Reward Board points!
					</div>
				</a>
				<a href="http://www.loctitetraining.com/" style="text-decoration:none; color:black;">
					<div id="mydiv1" class="squareImg1"></div>
				</a>
				<br>
				<a href="http://www.loctitetraining.com/">
					<div id="mydiv2" class="squareImg2"></div>
				</a>
				<div style="height:100px;"></div>
				<a href="http://www.loctitetraining.com/"><img src="pics/program/henkel/LocktiteUniversity.gif" width="94" height="94" border="0"></a>
				<br><br>
				<img src="pics/program/henkel/Henkel-Logo.jpg" width="94" height="61">
			</td>
		</tr>
<!---		<tr bgcolor="##FFFFFF">
			<td width="187" align="center"></td>
			<td width="425" align="right" ></td>
			<td width="188" align="center"><img src="pics/shim.gif" width="188" height="5"></td>
		</tr>
--->	</table>
<br><br><br>
	</body>
<cfelseif thisProgramID EQ "1000000071">
	<body>
	<div id="wrapper">
		<div id="header"></div>
		<div id="canvas">
			<div id="sidebar">
				<div class="redbox"><a href="main.cfm">VIEW REWARDS</a></div>
				<div class="sidecopy">Gifts are categorized by points earned for performing valued functions associated with selling Loctite&reg; products. Your points can be applied to any category of gifts. If your gift selection exceeds your earned points, you can use your personal credit card to complete your gift transaction.</div>
				<div class="redbox"><a href="henkel-register-aam.cfm">REGISTRATION</a></div>
				<div class="sidecopy">
					<p>You must register to use this web site. Click the registration button and follow the prompts. You must create a unique password and agree to the terms and conditions and privacy policy.  </p>
					<h2>Register now and earn 10 points instantly!</h2>
				</div>
			</div>
			<div id="content">
				<cfif DisplayMode EQ "Welcome"><span class="welcome"><!---#Replace(welcome_message,chr(10),"<br>","ALL")#--->#welcome_message#</span></cfif>
				<!--- <p>The new Henkel Rewards Board is designed to recognize outstanding contributors to the continued growth and success of Loctite&reg; products.  The new Rewards Board is an exciting and flexible incentive program that allows each participant to accumulate points for performing valued selling activities and then redeem them via our online merchandise catalog.  Look for these ongoing opportunities to earn rewards.</p>
				<p>&nbsp;</p>
				<h1>How to Earn Points</h1>
				<h2>&nbsp;</h2>
				<h2>
					Grow Sales 10% Over Prior Year .  . .  . . . . . . . . 1 point/$10 of growth<br />
					Earn (1) point for every $10 of growth				</h2>
				<p>
					For example:  2007 Sales total was $50,000. <br />
					Grow that in 2008 at least 10% ($5,000) and you receive 500 points to go shopping on Henkel Rewards Board!				</p>
				<p>&nbsp;</p>
				<h2>
					Run A Loctite&reg; Product Promotion  . . . . . . . . . . 10 points/promotion<br />
					With Your Customers				</h2>
				<p>&nbsp;</p>
				<p class="boldred">How to Get The Earned Points Added to Rewards Board</p>
				<h2>Grow 2008 Sales 10% of 2007! Automatically loaded by 1/15/09 </h2>
				<p>
					Loctite&reg; Product Promotions <br />
					Send an Email To: <a href="mailto:marybeth.wallett@us.henkel.com" target="_blank">marybeth.wallett@us.henkel.com </a><br />
					with promo sheet and customer contact information				</p>
				<p>&nbsp;</p>
				<p><span class="italic">Promos are subject to change.</span></p> --->
			</div>
		</div>
		<div id="footer"><span class="footer">&copy; Copyright Henkel Corporation, #Year(Now())#&nbsp;| &nbsp;<a href="http://www.henkelna.com/cps/rde/xchg/henkel_us/hs.xsl/6120_USE_HTML.htm" target="_blank" class="footer">privacy policy</a>&nbsp; | &nbsp;<a href="http://www.henkelna.com/cps/rde/xchg/henkel_us/hs.xsl/6119_USE_HTML.htm" target="_blank">terms of use</a>&nbsp;&nbsp; | &nbsp;<a href="http://www.henkelna.com/cps/rde/xchg/henkel_us/hs.xsl/6101_USE_HTML.htm" target="_blank">henkelna.com/industrial</a></span></div>
	</div>
	</body>
<cfelseif thisProgramID EQ "1000000070">
	<body>
		<div id="wrapper">
			<div id="header"></div>
			<div id="canvas">
				<div id="sidebar">
					<div class="redbox"><a href="main.cfm">VIEW REWARDS</a></div>
					<div class="sidecopy">Gifts are categorized by points earned for performing valued functions associated with selling Loctite® products. Your points can be applied to any category of gifts. If your gift selection exceeds your earned points, you can use your personal credit card to complete your gift transaction.</div>
					<div class="redbox"><a href="henkel-register-rr.cfm">REGISTRATION</a></div>
					<div class="sidecopy">
						<p>You must register to use this web site. Click the registration button and follow the prompts. You must create a unique password and agree to the terms and conditions and privacy policy.  </p>
						<h2>Register now and earn 10 points instantly!</h2>
					</div>
				</div>
				<div id="content">
					<cfif DisplayMode EQ "Welcome"><span class="welcome"><!---#Replace(welcome_message,chr(10),"<br>","ALL")#--->#welcome_message#</span></cfif>
					<!--- <p>The new Henkel Rewards Board is designed to recognize outstanding contributors to the continued growth and success of Loctite® products.  The new Rewards Board is an exciting and flexible incentive program that allows each participant to accumulate points for performing valued selling activities and then redeem them via our online merchandise catalog.  Look for these ongoing opportunities to earn rewards.</p>
					<p>&nbsp;</p>
					<h1>How to Earn Points</h1>
					<h2>&nbsp;</h2>
					<h2>Close New Accounts . . .  . .  . . . . . . . . . 1 point/$10 of opening order</h2>
					<p>Close a New AAM Account and receive 1 point for every $10 worth of Loctite® products sold into the opening order, after all applicable discounts have been taken. <br />
						For example:  New customer opening order total is $1,000 after all discounts you receive 100 points</p>
					<p>&nbsp;</p>
					<h2>Run Loctite® Product Promotions  . . . . . . . 10 points/promotion<br />
						With Your Customers</h2>
					<p>&nbsp;</p>
					<h2>Get Your WD Customers to Sign up . . . . . . 5 points/customer signed-up<br />
						For Rewards Board</h2>
					<h2>&nbsp;</h2>
					<p class="boldred">How to Get The Earned Points Added to Rewards Board</p>
					<h2>Close New Accounts! Automatically loaded monthly </h2>
					<p>&nbsp;</p>
					<h2>Loctite® Product Promotions </h2>
					<p>Send an Email To: <a href="mailto:marybeth.wallett@us.henkel.com" target="_blank">marybeth.wallett@us.henkel.com </a><br />
						with promo sheet and customer contact information</p>
					<p>&nbsp;</p>
					<h2>WD Customers Signed Up </h2>
					<p>Send an Email To: <a href="mailto:marybeth.wallett@us.henkel.com" target="_blank">marybeth.wallett@us.henkel.com</a><br />
						with customer contact information and date they signed up.</p>
					<p>&nbsp;</p>
					<p class="italic">Promos are subject to change.</p> --->
				</div>
			</div>
			<div id="footer"><span class="footer">&copy; Copyright Henkel Corporation, 2008&nbsp;| &nbsp;<a href="http://www.henkelna.com/cps/rde/xchg/henkel_us/hs.xsl/6120_USE_HTML.htm" target="_blank" class="footer">privacy policy</a>&nbsp; | &nbsp;<a href="http://www.henkelna.com/cps/rde/xchg/henkel_us/hs.xsl/6119_USE_HTML.htm" target="_blank">terms of use</a>&nbsp;&nbsp; | &nbsp;<a href="http://www.henkelna.com/cps/rde/xchg/henkel_us/hs.xsl/6101_USE_HTML.htm" target="_blank">henkelna.com/industrial</a></span></div>
		</div>
	</body>

<cfelseif thisProgramID EQ "1000000072">
	<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0"#welcome_bg#>
<cfinclude template="includes/environment.cfm"> 
	<!--- <cfif kFLGen_ImageSize.ImageWidth LT 265>
		<!--- the logo is next to congrats --->
		<table cellpadding="0" cellspacing="0" border="0" width="800">
			<tr><td width="275" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td><td width="525" height="40" align="left" valign="bottom" style="padding-bottom:5px">#welcome_congrats#</td></tr>
		</table>
	<cfelse>
		<!--- the logo extends over the congrats --->
		<table cellpadding="0" cellspacing="0" border="0" width="800" align="center">
			<tr><td colspan="2" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td></tr>
			<cfif welcome_congrats NEQ "&nbsp;" AND welcome_congrats NEQ "">
				<tr><td width="275"><img src="pics/program/shim.gif" width="275" height="1"></td><td width="525" height="40" align="left" valign="bottom">#welcome_congrats#</td></tr>
			</cfif>
		</table>
	</cfif> --->
	<table cellpadding="0" cellspacing="0" border="0" width="800">
		<tr><td></td><td></td><td><img src="pics/program/#vLogo#" style="padding-left:35px"></td></tr>
		<tr><td colspan="3" width="800" height="5"><img src="pics/shim.gif" width="25" height="5"><img src="pics/shim.gif" width="355" height="5"#cross_color#></td></tr>
		<tr>
			<td width="200" valign="top" align="center">
				<img src="pics/shim.gif" width="200" height="1">
				<br /><br />
				<table cellpadding="8" cellspacing="1" border="0" width="150">
					<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='main.cfm'">#welcome_button#</td></tr>
					<tr><td align="left" class="active_button_henkel"><!---#Replace(welcome_instructions,chr(10),"<br>","ALL")#--->#welcome_instructions#</td></tr>
					<cfif additional_content_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<cfif additional_content_button EQ "Francais">
							<tr><td align="center"><a href="additional_content.cfm"><img src="pics/welcome/btn-francais.gif" width="147" height="99" border="0" /></a></td></tr>
						<cfelse>
							<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='additional_content.cfm'">#additional_content_button#</td></tr>
						</cfif>
					</cfif>
					<cfif email_form_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='email_form.cfm'">#email_form_button#</td></tr>
					</cfif>
					<cfif thisProgramID EQ "1000000072">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='henkel-register-fre.cfm'">Registration</td></tr>
					<tr><td align="left" class="active_button_henkel">
<font size="1">&nbsp; <br />&nbsp;
You must <strong>register</strong> to<br />&nbsp;
use this web site.<br />&nbsp;
Click the registration<br />&nbsp;
button and follow the<br />&nbsp;
prompts. You must<br />&nbsp;
create a unique<br />&nbsp;
password and agree<br />&nbsp;
to the terms and<br />&nbsp;
conditions and privacy<br />&nbsp;
policy.<br /><br /></font>
</td></tr>
					</cfif>
					<cfif welcome_admin_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='/admin/index.cfm'">#welcome_admin_button#</td></tr>
					</cfif>
					<cfif FileExists(application.FilePath & "award_certificate/" & users_username & "_certificate_" & program_ID & ".pdf")>
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="openCertificate()">View Certificate</td></tr>
					</cfif>
					<cfif help_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="openHelp()">#help_button#</td></tr>
					</cfif>
				</table><br><a href="henkel-contact-us.cfm"><img src="pics/program/henkel/HenkelContactUs.jpg" alt="Contact Us" width="82" height="31" border="0"></a> &nbsp;<a href="welcome.cfm"><img src="pics/program/henkel/HenkelHome.jpg" alt="Home" width="57" height="31" border="0"></a>
			</td>
			<td width="5" height="100" valign="top"><img src="pics/shim.gif" width="5" height="175"#cross_color#></td>
			<td width="725" valign="top" style="padding:25px">
				<cfif display_message NEQ "">#display_message#<br><br><br></cfif>
				<cfif DisplayMode EQ "Welcome">
					<cfif thisProgramID EQ "1000000068">
						<cfif IsDefined("cookie.ITC_USER")>
							<cfset ThisUser = #GetUserName.fname# & " " & #GetUserName.lname#>
						<cfelse>
							<cfset ThisUser = "Award Winner">
						</cfif>
						<span class="welcome">
							<table border="0" width="545">
								<tr><td width="545"align="center"><img src="/pics/uploaded_images/nielsen-cert-top.jpg" /></td></tr>
								<tr><td width="545"align="center" class="nielsen_award_winner_name">#ThisUser#</td></tr>
								<tr><td width="545"align="center"><img src="/pics/uploaded_images/nielsen-cert-bottom.jpg" /></td></tr>
							</table>
						</span>
					<cfelse>
						<span class="welcome"><!---#Replace(welcome_message,chr(10),"<br>","ALL")#--->#welcome_message#</span>
					</cfif>
				</cfif>
			</td>
		</tr>
	</table>
	</body>
<cfelse>
	<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0"#welcome_bg#>
<cfinclude template="includes/environment.cfm"> 
	<cfif kFLGen_ImageSize.ImageWidth LT 265>
		<!--- the logo is next to congrats --->
		<table cellpadding="0" cellspacing="0" border="0" width="800">
			<tr><td width="275" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td><td width="525" height="40" align="left" valign="bottom" style="padding-bottom:5px">#welcome_congrats#</td></tr>
		</table>
	<cfelse>
		<!--- the logo extends over the congrats --->
		<table cellpadding="0" cellspacing="0" border="0" width="800">
			<tr><td colspan="2" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td></tr>
			<cfif welcome_congrats NEQ "&nbsp;" AND welcome_congrats NEQ "">
				<tr><td width="275"><img src="pics/program/shim.gif" width="275" height="1"></td><td width="525" height="40" align="left" valign="bottom">#welcome_congrats#</td></tr>
			</cfif>
		</table>
	</cfif>
	<table cellpadding="0" cellspacing="0" border="0" width="800">
		<tr><td colspan="3" width="800" height="5"><img src="pics/shim.gif" width="25" height="5"><img src="pics/shim.gif" width="355" height="5"#cross_color#></td></tr>
		<tr>
			<td width="200" valign="top" align="center">
				<img src="pics/shim.gif" width="200" height="1">
				<br /><br />
				<table cellpadding="8" cellspacing="1" border="0" width="150">
					<tr><td align="left" class="welcome_instructions"><!---#Replace(welcome_instructions,chr(10),"<br>","ALL")#--->#welcome_instructions#</td></tr>
					<tr><td>&nbsp;</td></tr>
					<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='main.cfm'">#welcome_button#</td></tr>
					<cfif additional_content_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<cfif additional_content_button EQ "Francais">
							<tr><td align="center"><a href="additional_content.cfm"><img src="pics/welcome/btn-francais.gif" width="147" height="99" border="0" /></a></td></tr>
						<cfelse>
							<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='additional_content.cfm'">#additional_content_button#</td></tr>
						</cfif>
					</cfif>
					<cfif email_form_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='email_form.cfm'">#email_form_button#</td></tr>
					</cfif>
					<cfif thisProgramID EQ "1000000069" AND DateDiff('d',NOW(),CreateDate(2008,08,31)) GTE 0>
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='henkel-register-cn.cfm'">Registration</td></tr>
					</cfif>
					<cfif thisProgramID EQ "1000000072">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='henkel-register-fre.cfm'">Registration</td></tr>
					<tr><td align="left" class="active_button_henkel">
<font size="1">&nbsp; <br />&nbsp;
You must <strong>register</strong> to<br />&nbsp;
use this web site.<br />&nbsp;
Click the registration<br />&nbsp;
button and follow the<br />&nbsp;
prompts. You must<br />&nbsp;
create a unique<br />&nbsp;
password and agree<br />&nbsp;
to the terms and<br />&nbsp;
conditions and privacy<br />&nbsp;
policy.<br /><br /></font>
</td></tr>
					</cfif>
					<cfif welcome_admin_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='/admin/index.cfm'">#welcome_admin_button#</td></tr>
					</cfif>
					<cfif FileExists(application.FilePath & "award_certificate/" & users_username & "_certificate_" & program_ID & ".pdf")>
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="openCertificate()">View Certificate</td></tr>
					</cfif>
					<cfif help_button NEQ "">
						<tr><td>&nbsp;</td></tr>
						<tr><td align="center" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="openHelp()">#help_button#</td></tr>
					</cfif>
				</table>
			</td>
			<td width="5" height="100" valign="top"><img src="pics/shim.gif" width="5" height="175"#cross_color#></td>
			<td width="725" valign="top" style="padding:25px">
				<cfif display_message NEQ "">#display_message#<br><br><br></cfif>
				<cfif DisplayMode EQ "Welcome">
					<cfif thisProgramID EQ "1000000068">
						<cfif IsDefined("cookie.ITC_USER")>
							<cfset ThisUser = #GetUserName.fname# & " " & #GetUserName.lname#>
						<cfelse>
							<cfset ThisUser = "Award Winner">
						</cfif>
						<span class="welcome">
							<table border="0" width="545">
								<tr><td width="545"align="center"><img src="/pics/uploaded_images/nielsen-cert-top.jpg" /></td></tr>
								<tr><td width="545"align="center" class="nielsen_award_winner_name">#ThisUser#</td></tr>
								<tr><td width="545"align="center"><img src="/pics/uploaded_images/nielsen-cert-bottom.jpg" /></td></tr>
							</table>
						</span>
					<cfelse>
						<span class="welcome"><!---#Replace(welcome_message,chr(10),"<br>","ALL")#--->#welcome_message#</span>
					</cfif>
				</cfif>
			</td>
		</tr>
	</table>
	</body>
</cfif>

</cfoutput>
</html>
