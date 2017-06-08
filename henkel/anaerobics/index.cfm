<cfparam name="url.p" default="0">
<cfif NOT isBoolean(url.p)>
	<cfset url.p = 0>
</cfif>
<html>
<head>
<title>Henkel Rewards Board</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css" media="screen"><!--
.loctite   { color: white; font-weight: bold; font-size: 15px; line-height: 17px; font-family: Arial, Helvetica, Geneva, Swiss, SunSans-Regular; padding-top: 3px; padding-right: 2px; padding-left: 16px }
.loctitebd { color: #fc9; font-weight: bold }
.regestered { font-size: xx-small; vertical-align: super }
.pwrecovery {
	font-size:10px;
	text-decoration:underline;
	cursor:pointer;
	color:#ddd3bb;
	font-family: Arial, Verdana, Helvetica, Geneva, Swiss, SunSans-Regular;
}
.box { float: left; position: static; top: 20px; left: 0px }
.slug { color: white; font-style: italic; font-weight: bold; margin-top: 1px; margin-left: 20px }
.slug2 { margin-top: -1px; margin-left: 20px }
.loctitetable { color: #ddd3bb; font-size: 12px; line-height: 15px; font-family: Verdana, Arial, Helvetica, Geneva, Swiss, SunSans-Regular }
.cogsentry { font-size: 11px; line-height: 12px; font-family: "Times New Roman", Georgia, Times, Arial, Helvetica, Geneva, Swiss, SunSans-Regular }
.lpbullets { color: white; font-weight: bold; font-size: 15px; line-height: 17px; font-family: Arial, Helvetica, Geneva, Swiss, SunSans-Regular; list-style: disc url(images/checkmark.gif) outside; margin-top: 20px }
.subsubfirst { color: white; font-weight: bold; font-size: 15px; line-height: 17px; font-family: Arial, Helvetica, Geneva, Swiss, SunSans-Regular; text-indent: 48px }
--></style>
</head>

<body link="#ffff66" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<cfinclude template="../../includes/environment.cfm"> 

<table id="Table_01" width="745" height="1143" border="0" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td><img src="images/lp_01.jpg" width="34" height="81" alt=""></td>
		<td><img src="images/lp_02.jpg" width="222" height="81" alt=""></td>
		<td><img src="images/lp_03.jpg" width="471" height="81" alt=""></td>
		<td><img src="images/lp_04.jpg" width="18" height="81" alt=""></td>
	</tr>
	<tr>
		<td><img src="images/lp_05.jpg" width="34" height="726" alt=""></td>
		<td><img src="images/lp_06.jpg" width="222" height="726" alt=""></td>
		<td rowspan="2" background="images/lp_07.jpg">
			<img src="images/lp_header-art.gif" alt="" width="420" height="162" border="0">
			<p class="loctite">January 1, 2008 through December 31, 2008</p>
			<ul>
				<li class="lpbullets"><font color="white">All authorized Loctite&reg; distributor branches are eligible.</font>
				<li class="lpbullets">Growth from all channels count &#151; <br>ID Stock, Drop Ship and CTD.
				<li class="lpbullets">Branches must first register for promotion participation to establish and submit a baseline of Loctite&reg; Anaerobic COGS sold in 2007.  Click the Branch Registration button on the red banner.  A branch password will be emailed to you upon receipt of your registration.
				<li class="lpbullets">Once you are registered then return using this web address www.loctitepromotions.com and enter the Promotion Code ANA2008. 
				<li class="lpbullets">Next enter your branch password on the red banner to
				<li class="subsubfirst">log in and post 2007 Anaerobic COGS or <li class="subsubfirst">update quarterly 2008 Anaerobic COGS 
				<li class="lpbullets">Quarterly branch updates are due:
				<li class="subsubfirst">July 15th 2008
				<li class="subsubfirst">October 15th 2008
				<li class="subsubfirst">January 15th 2009 
				<li class="lpbullets">Hurry!  Sign-up period ends June 30, 2008.
			</ul>
			<h4 class="loctite"><img src="images/it-pays.gif" alt="" width="400" height="111" border="0"></h4>
		</td>
		<td><img src="images/lp_08.jpg" width="18" height="726" alt=""></td>
	</tr>
	<tr id="AnchorSpot">
		<td><img src="images/lp_09.jpg" width="34" height="217" alt=""></td>
		<td rowspan="2" background="images/lp_10.jpg" align="center">
			<p><a href="register.cfm"><img src="images/btn-branch-registration.gif" alt="" width="200" height="40" border="0"></a></p>
			<span id="SPAN_login" style="display:<cfif url.p>none<cfelse>block</cfif>">
				<form action="sales_entry.cfm" method="get" name="FormName">
					<span class="loctite">
						<b>
							Enter Password To<br>Post 2007 COGS And/Or<br>
							Update 2008 Quarterly<br>
							Anaerobic COGS
						</b>
					</span><br>
					<input type="password" name="username" size="24" border="0"><br>
					<img src="images/clear.gif" alt="" width="150" height="10" border="0"><br>
					<input type="image" src="images/btn-submit.gif" alt="" width="100" height="26" border="0">
				</form>
			</span>
			<span id="PWLink" class="pwrecovery" onClick="showPWRecovery();">Already Registered&mdash;Forgot Your Password?</span>
			<span id="SPAN_PW_Recovery" style="display:<cfif NOT url.p>none<cfelse>block</cfif>">
				<form action="forgot.cfm" method="post" name="PWRecoveryForm">
					<span class="loctite">
						<b>
							Enter the email address<br>
							that you used to register:<br>
						</b>
					</span><br>
					<input type="text" name="email" size="24" maxlength="128"><br>
					<img src="images/clear.gif" alt="" width="150" height="10" border="0"><br>
					<input type="image" src="images/btn-submit.gif" alt="" width="100" height="26" border="0">
				</form>
				<span class="pwrecovery" onClick="hidePWRecovery();">Cancel and return to login</span>
			</span>
			<script>
			function showPWRecovery() {
				var srcElement1 = document.getElementById('SPAN_PW_Recovery');
				var srcElement2 = document.getElementById('SPAN_login');
				var srcElement3 = document.getElementById('PWLink');
				srcElement1.style.display = 'block';
				srcElement2.style.display = 'none';
				srcElement3.style.display = 'none';
			}
			function hidePWRecovery() {
				var srcElement1 = document.getElementById('SPAN_PW_Recovery');
				var srcElement2 = document.getElementById('SPAN_login');
				var srcElement3 = document.getElementById('PWLink');
				srcElement1.style.display = 'none';
				srcElement2.style.display = 'block';
				srcElement3.style.display = 'block';
			}
			</script>
		</td>
		<td><img src="images/lp_11.jpg" width="18" height="217" alt=""></td>
	</tr>
	<tr>
		<td><img src="images/lp_12.jpg" width="34" height="50" alt=""></td>
		<td><img src="images/lp_13.jpg" width="471" height="50" alt=""></td>
		<td><img src="images/lp_14.jpg" width="18" height="50" alt=""></td>
	</tr>
	<tr>
		<td colspan="100%"><img src="images/lp_15.jpg" width="745" height="69" alt=""></td>
	</tr>
</table>
</body>
</html>