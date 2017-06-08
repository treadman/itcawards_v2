<!--- https://www2.itcawards.com/henkel-welcome.cfm --->
<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>
<cfparam name="DisplayMode" default="Welcome">

<cfset thisProgramID = LEFT(cookie.itc_pid,10)>
<cfif thisProgramID NEQ "1000000066">
	<cfabort>
</cfif>
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
	</style>
</head>

<cfoutput>
	<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" background="pics/program/henkel/HenkelBackground.jpg">
		<div style="position:absolute;width:400px;left:20px; top:10px; visibility:visible"><b>Henkel Welcome Mock Up</b></div>
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
					<tr><td align="left" class="active_button_henkel">#Replace(welcome_instructions,chr(10),"<br>","ALL")#</td></tr>
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
							<cfif DisplayMode EQ "Welcome"><span class="welcome">#Replace(welcome_message,chr(10),"<br>","ALL")#</span></cfif>
							<cfif not IsDefined('cookie.itc_user') OR cookie.itc_user EQ "">
								<br><br><br>
							</cfif>
							<br /><br /><br /><br /><br /><br />
							<img src="pics/program/henkel/Henkel-Logo.jpg" width="94" height="61" align="right">&nbsp;&nbsp;&nbsp;
						</td>
						<td width="6" valign="top"><img src="pics/program/henkel/HenkelBoardLegs.jpg" width="6" height="220" alt="" border="0"></td>
					</tr>
				</table>
			</td>
			<td valign="bottom" align="left" style="padding-left:30px;">
				<span style="padding:10px; margin-top:50px; margin-left:13px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='main.cfm'">&nbsp;Main Menu&nbsp;</span>
				<br><br><br><br>
				<cfif additional_content2_button NEQ "">
					<span style="padding:10px; margin-top:50px; margin-left:13px;" class="active_button" onmouseover="mOver(this,'selected_button');" onmouseout="mOut(this,'active_button');" onclick="window.location='additional_content.cfm?n=2'">#additional_content2_button#</span>
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
				<br><br>
				<a href="http://www.loctitetraining.com/">
					<div id="mydiv2" class="squareImg2"></div>
				</a>
				<div style="height:100px;"></div>
				<a href="http://www.loctitetraining.com/"><img src="pics/program/henkel/LocktiteUniversity.gif" width="94" height="94" border="0"></a>
			</td>
		</tr>
	</table>
	</body>

</cfoutput>
</html>
