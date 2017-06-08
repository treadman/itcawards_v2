<cfparam name="pgfn" default="get_user_ID">
<cfparam name="gender" default="M">
<cfset ErrorMessage = "">

<!--- ------------------------------------------------------------------------------------------------------ --->
<!--- --- CHECK FOR ERROR----------------------------------------------------------------------------------- --->
<!--- ------------------------------------------------------------------------------------------------------ --->
	<cfif pgfn is 'get_employee_data' OR  pgfn is 'save_employee_data'>
		<cfquery name="UserData" datasource="#application.DS#">
			SELECT ID, user_ID, company, fname, lname, email, title, address1, address2, address3, city, state, zip, country, phone, department, gender, size
			FROM #application.database#.ari60
			<cfif pgfn IS 'get_employee_data'>
				WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#USER_ID#" maxlength="16" />
			<cfelse>
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#" maxlength="10" />
			</cfif>
		</cfquery>
		<cfif UserData.RecordCount IS 0>
			<cfset ErrorMessage = 'Invalid Employee Number<br />Please Try Again<br /><br />For Assistance Contact '&application.AwardsProgramAdminName&', ITC<br />Toll Free 888.266.6108'>
			<cfset pgfn = 'get_user_ID'>
		</cfif>
		<cfif UserData.gender GT "" AND  UserData.size GT "">
			<cfset ErrorMessage = 'You Have Previously<br />Made A Selection<br /><br />For Assistance Contact '&application.AwardsProgramAdminName&', ITC<br />Toll Free 888.266.6108'>
			<cfset pgfn = 'get_user_ID'>
		</cfif>
	</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=ISO-8859-1">
<title>Mens Sizes</title>
<meta name="GENERATOR" content="Freeway 5 Pro 5.1.2">
<style type="text/css">
<!-- 
body { margin:0px; background-color:#fff; height:100% }
html { height:100% }
img { margin:0px; border-style:none }
button { margin:0px; border-style:none; padding:0px; background-color:transparent; vertical-align:top }
p:first-child { margin-top:0px }
table { empty-cells:hide }
.f-sp { font-size:1px; visibility:hidden }
.f-lp { margin-bottom:0px }
.f-fp { margin-top:0px }
.f-x1 {  }
.f-x2 {  }
.f-x3 {  }
em { font-style:italic }
h1 { font-size:18px }
h1:first-child { margin-top:0px }
strong { font-weight:bold }
.style2 { font-family:Arial,Helvetica,sans-serif; font-size:12px }
.style3 { font-family:Arial,Helvetica,sans-serif; font-size:13px }
.style4 { color:#000; font-family:Arial,Helvetica,sans-serif; font-size:12px }
.style6 { font-family:Arial,Helvetica,sans-serif; font-size:16px; font-weight:bold;}
.style8 { font-family:Arial,Helvetica,sans-serif; font-size:16px;}
-->
</style>
<!--[if lt IE 7]>
<link rel=stylesheet type="text/css" href="css/ie6.css">
<![endif]-->
</head>
<body>
<div id="PageDiv" style="position:relative; min-height:100%; margin:auto; width:550px">
<!--- ------------------------------------------------------------------------------------------------------ --->
<!--- --- INPUT -------------------------------------------------------------------------------------------- --->
<!--- ------------------------------------------------------------------------------------------------------ --->
<cfif pgfn is 'get_employee_data'>
<!--- ------------------------------------------------------------------------------------------------------ --->
<!--- --- INPUT MENS---------------------------------------------------------------------------------------- --->
<!--- ------------------------------------------------------------------------------------------------------ --->
	<cfif gender IS 'M'>
		<table border=0 cellspacing=0 cellpadding=0 width=533>
			<colgroup>
				<col width=30>
				<col width=118>
				<col width=12>
				<col width=117>
				<col width=10>
				<col width=245>
				<col width=1>
			</colgroup>
			<tr valign=top>
				<td height=14 colspan=6></td>
				<td height=14></td>
			</tr>
			<tr valign=top>
				<td height=1 colspan=5></td>
				<td height=271 rowspan=4>
				<table border=1 cellspacing=0 cellpadding=2>
					<tr>
						<td width=76 height=34 valign=top><p class="f-lp"><span class="style2">Mens Size</span></p>
						</td>
						<td width=83 height=34 valign=top><p class="f-lp"><span class="style2">Chest</span></p>
						</td>
						<td width=84 height=34 valign=top><p class="f-lp"><span class="style2">Sleeve Length</span></p>
						</td>
					</tr>
					<tr>
						<td width=76 height=33 valign=top><p class="f-lp"><span class="style2">Small</span></p>
						</td>
						<td width=83 height=33 valign=top><p class="f-lp"><span class="style2">35 &#8211; 38 inches</span></p>
						</td>
						<td width=84 height=33 valign=top><p class="f-lp"><span class="style2">33 &#8211; 34 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=76 height=33 valign=top><p class="f-lp"><span class="style2">Medium</span></p>
						</td>
						<td width=83 height=33 valign=top><p class="f-lp"><span class="style2">39 &#8211; 42 inches</span></p>
						</td>
						<td width=84 height=33 valign=top><p class="f-lp"><span class="style2">34 &#8211; 35 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=76 height=33 valign=top><p class="f-lp"><span class="style2">Large</span></p>
						</td>
						<td width=83 height=33 valign=top><p class="f-lp"><span class="style2">43 &#8211; 46 inches</span></p>
						</td>
						<td width=84 height=33 valign=top><p class="f-lp"><span class="style2">35 &#8211; 36 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=76 height=33 valign=top><p class="f-lp"><span class="style2">XLarge</span></p>
						</td>
						<td width=83 height=33 valign=top><p class="f-lp"><span class="style2">47 &#8211; 50 inches</span></p>
						</td>
						<td width=84 height=33 valign=top><p class="f-lp"><span class="style2">36 &#8211; 37 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=76 height=33 valign=top><p class="f-lp"><span class="style2">2 XLarge</span></p>
						</td>
						<td width=83 height=33 valign=top><p class="f-lp"><span class="style2">50 &#8211; 53 inches</span></p>
						</td>
						<td width=84 height=33 valign=top><p class="f-lp"><span class="style2">37 &#8211; 38 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=76 height=35 valign=top><p class="f-lp"><span class="style2">3 XLarge</span></p>
						</td>
						<td width=83 height=35 valign=top><p class="f-lp"><span class="style2">54 &#8211; 57 inches</span></p>
						</td>
						<td width=84 height=35 valign=top><p class="f-lp"><span class="style2">38 &#8211; 39 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=76 height=35 valign=top><p class="f-lp"><span class="style2">4 XLarge</span></p>
						</td>
						<td width=83 height=35 valign=top><p class="f-lp"><span class="style2">58 &#8211; 61 inches</span></p>
						</td>
						<td width=84 height=35 valign=top><p class="f-lp"><span class="style2">39 &#8211; 39.5 inches</span></p>
						</td>
					</tr>
				</table>
				</td>
				<td height=1></td>
			</tr>
			<tr valign=top>
				<td height=353 rowspan=4></td>
				<td height=353 rowspan=4><img src="pics/ari60/male.jpeg" border=0 width=118 height=353 alt="Male" style="float:left"></td>
				<td height=1 colspan=3></td>
				<td height=1></td>
			</tr>
			<tr valign=top>
				<td height=158></td>
				<td height=158><p><span class="style4"><strong>Chest &#8212;</strong> <br>Measure just under the arms one inch below armhole. </span></p>
				<p class="f-lp"><span class="style4"><strong>Sleeve Length &#8212;<br></strong>Measure from the centre back of the neck, over the point of shoulder and down the outer side of a slightly bent arm to the wrist bone.</span></p>
				</td>
				<td height=158></td>
				<td height=158></td>
			</tr>
			<tr valign=top>
				<td height=111 colspan=3></td>
				<td height=111></td>
			</tr>
			<tr valign=top>
				<td height=83 colspan=4></td>
				<td height=83></td>
			</tr>
			<tr class="f-sp">
				<td><img src="pics/ari60/shim.gif" border=0 width=30 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=118 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=12 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=117 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=10 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=245 height=1 alt="" style="float:left"></td>
				<td height=1><img src="pics/ari60/shim.gif" border=0 width=1 height=1 alt="" style="float:left"></td>
			</tr>
		</table>
<!--- ------------------------------------------------------------------------------------------------------ --->
<!--- --- INPUT WOMENS-------------------------------------------------------------------------------------- --->
<!--- ------------------------------------------------------------------------------------------------------ --->
	<cfelseif gender IS 'W'>
		<table border=0 cellspacing=0 cellpadding=0 width=535>
			<colgroup>
				<col width=34>
				<col width=104>
				<col width=22>
				<col width=117>
				<col width=12>
				<col width=245>
				<col width=1>
			</colgroup>
			<tr valign=top>
				<td height=14 colspan=6></td>
				<td height=14></td>
			</tr>
			<tr valign=top>
				<td height=1 colspan=5></td>
				<td height=233 rowspan=4>
				<table border=1 cellspacing=0 cellpadding=2>
					<tr>
						<td width=75 height=36 valign=top><p class="f-lp"><span class="style2">Women Size</span></p>
						</td>
						<td width=84 height=36 valign=top><p class="f-lp"><span class="style2">Chest</span></p>
						</td>
						<td width=84 height=36 valign=top><p class="f-lp"><span class="style2">Sleeve Length</span></p>
						</td>
					</tr>
					<tr>
						<td width=75 height=32 valign=top><p class="f-lp"><span class="style2">X Small</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">30 &#8211; 32 inches</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">30 &#8211; 31 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=75 height=32 valign=top><p class="f-lp"><span class="style2">Small</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">32 &#8211; 35 inches</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">31 &#8211; 32 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=75 height=32 valign=top><p class="f-lp"><span class="style2">Medium</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">35 &#8211; 38 inches</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">32 &#8211; 33 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=75 height=32 valign=top><p class="f-lp"><span class="style2">Large</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">38 &#8211; 41 inches</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">33 &#8211; 34 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=75 height=32 valign=top><p class="f-lp"><span class="style2">XLarge</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">41 &#8211; 44 inches</span></p>
						</td>
						<td width=84 height=32 valign=top><p class="f-lp"><span class="style2">34 &#8211; 35 inches</span></p>
						</td>
					</tr>
					<tr>
						<td width=75 height=35 valign=top><p class="f-lp"><span class="style2">2 XLarge</span></p>
						</td>
						<td width=84 height=35 valign=top><p class="f-lp"><span class="style2">44 &#8211; 46 inches</span></p>
						</td>
						<td width=84 height=35 valign=top><p class="f-lp"><span class="style2">35 &#8211; 36 inches</span></p>
						</td>
					</tr>
				</table>
				</td>
				<td height=1></td>
			</tr>
			<tr valign=top>
				<td height=320 rowspan=4></td>
				<td height=320 rowspan=4><img src="pics/ari60/female.jpeg" border=0 width=104 height=320 alt="Female" style="float:left"></td>
				<td height=1 colspan=3></td>
				<td height=1></td>
			</tr>
			<tr valign=top>
				<td height=158></td>
				<td height=158><p><span class="style4"><strong>Chest &#8212;</strong> <br>Measure just under the arms one inch below armhole. </span></p>
				<p class="f-lp"><span class="style4"><strong>Sleeve Length &#8212;</strong> <br>Measure from the centre back of the neck, over the point of shoulder and down the outer side of a slightly bent arm to the wrist bone.</span></p>
				</td>
				<td height=158></td>
				<td height=158></td>
			</tr>
			<tr valign=top>
				<td height=73 colspan=3></td>
				<td height=73></td>
			</tr>
			<tr valign=top>
				<td height=88 colspan=4></td>
				<td height=88></td>
			</tr>
			<tr class="f-sp">
				<td><img src="pics/ari60/shim.gif" border=0 width=34 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=104 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=22 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=117 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=12 height=1 alt="" style="float:left"></td>
				<td><img src="pics/ari60/shim.gif" border=0 width=245 height=1 alt="" style="float:left"></td>
				<td height=1><img src="pics/ari60/shim.gif" border=0 width=1 height=1 alt="" style="float:left"></td>
			</tr>
		</table>
	</cfif>
	<!--- ------------------------------------------------------------------------------------------------------ --->
	<!--- --- INPUT SIZE---------------------------------------------------------------------------------------- --->
	<!--- ------------------------------------------------------------------------------------------------------ --->
	<cfoutput>
		<form method="post" action="#CurrentPage#">
			<input type="hidden" name="gender" value="#gender#">
			<input type="hidden" name="pgfn" value="save_employee_data">
			<input type="hidden" name="ID" value="#UserData.ID#">
			<table border=0 cellspacing=5 cellpadding=0 align="center">
				<tr class="style2"><td valign="top" align="right"><strong>Employee Number</strong></td><td>#UserData.user_ID#</td></tr>
				<tr class="style2"><td valign="top" align="right"><strong>Employee Name</strong></td><td>#UserData.fname# #UserData.lname#</td></tr>
				<tr class="style2"><td valign="top" align="right"><strong>Department</strong></td><td>#UserData.department#</td></tr>
				<tr class="style2"><td valign="top" align="right"><strong>Email</strong></td><td>#UserData.email#</td></tr>
				<tr class="style2"><td valign="top" align="right"><strong>Gender</strong></td><td><cfif gender IS 'M'>Mens<cfelse>Women</cfif></td></tr>
				<tr class="style3">
					<td valign="top" align="right"><strong><font color="##12449D">Select Your Size</font></strong></td>
					<td>
						<select name="size">
							<option value=""> --- Select ---</option>
							<cfif gender IS 'W'><option value="XSmall"<cfif UserData.size EQ" XSmall"> selected</cfif> />XSmall</option></cfif>
							<option value="Small"<cfif UserData.size EQ "Small"> selected</cfif> />Small</option>
							<option value="Medium"<cfif UserData.size EQ "Medium"> selected</cfif> />Medium</option>
							<option value="Large"<cfif UserData.size EQ "Large"> selected</cfif> />Large</option>
							<option value="XLarge"<cfif UserData.size EQ "X Large"> selected</cfif> />XLarge</option>
							<option value="2 XLarge"<cfif UserData.size EQ "2 XLarge"> selected</cfif> />2 XLarge</option>
							<cfif gender IS 'M'><option value="3 XLarge"<cfif UserData.size EQ "3 XLarge"> selected</cfif> />3 XLarge</option></cfif>
							<cfif gender IS 'M'><option value="4 XLarge"<cfif UserData.size EQ "4 XLarge"> selected</cfif> />4 XLarge</option></cfif>
						</select>
					</td>
				</tr>

				<tr class="style2"><td valign="top" colspan="2" align="center">&nbsp;</td></tr>
				<tr class="style2"><td valign="top" colspan="2" align="center"><input type="submit" name="submit" value="Submit"></td></tr>
			</table>
		</form>
	</cfoutput>		
</cfif>
<!--- ------------------------------------------------------------------------------------------------------ --->
<!--- --- INPUT ID------------------------------------------------------------------------------------------ --->
<!--- ------------------------------------------------------------------------------------------------------ --->
<cfif pgfn is 'get_user_ID'>
	<cfoutput>
		<form method="post" action="#CurrentPage#">
			<input type="hidden" name="gender" value="#gender#">
			<input type="hidden" name="pgfn" value="get_employee_data">
	<table border=0 cellspacing=0 cellpadding=0 width=535>
		<colgroup>
			<col width=21>
			<col width=146>
			<col width=1>
		</colgroup>
		<tr valign=top>
			<td height=133></td>
			<td height=133><img src="pics/ari60/ari60th2logocolo.jpeg" border=0 width=146 height=133 alt="ARI60th2logoCOLORSM" style="float:left"></td>
			<td height=133></td>
		</tr>
	</table>
			<p>&nbsp;</p>
			<div class="style2" align="center"><cfif ErrorMessage GT ""><strong>#ErrorMessage#</strong><cfelse>&nbsp;</cfif></div>
			<p>&nbsp;</p>
			<table border=0 cellspacing=5 cellpadding=0 align="center">
				<tr><td valign="top" class="style6" align="left" colspan="3">Enter only your Employee Number to continue.<br /><br />Click the Submit button.<br /><br /></td></tr>
				<tr><td valign="top" class="style6">Employee Number  <input type="text" name="user_ID" size="6" maxlength="16"></td><td></td></tr>
				<tr class="style2"><td valign="top" colspan="3" align="center">&nbsp;</td></tr>
				<tr class="style2"><td valign="top" colspan="3" align="center"><input type="submit" name="submit" value="Submit"></td></tr>
			</table>
		</form>
	</cfoutput>
</cfif>
<!--- ------------------------------------------------------------------------------------------------------ --->
<!--- --- SAVE --------------------------------------------------------------------------------------------- --->
<!--- ------------------------------------------------------------------------------------------------------ --->
<cfif pgfn is 'save_employee_data'>
	<cfquery name="UpdateUserData" datasource="#application.DS#">
		UPDATE #application.database#.ari60 SET
			gender = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.gender#" maxlength="1" />,
			size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.size#" maxlength="16" />
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID#" maxlength="10" />
	</cfquery>
	<cfquery name="ThankYouData" datasource="#application.DS#">
		SELECT fname, lname, gender, size, email
		FROM #application.database#.ari60
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID#" maxlength="10" />
	</cfquery>
	<table border=0 cellspacing=0 cellpadding=0 width=535>
		<colgroup>
			<col width=21>
			<col width=146>
			<col width=1>
		</colgroup>
		<tr valign=top>
			<td height=12 colspan=2></td>
			<td height=12></td>
		</tr>
		<tr valign=top>
			<td height=133></td>
			<td height=133><img src="pics/ari60/ari60th2logocolo.jpeg" border=0 width=146 height=133 alt="ARI60th2logoCOLORSM" style="float:left"></td>
			<td height=133></td>
		</tr>
		<tr class="f-sp">
			<td><img src="pics/ari60/shim.gif" border=0 width=21 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=146 height=1 alt="" style="float:left"></td>
			<td height=30><img src="pics/ari60/shim.gif" border=0 width=1 height=1 alt="" style="float:left"></td>
		</tr>
		<tr class="style8">
			<td>&nbsp;</td>
			<td colspan="2" align="left">
			<cfoutput>
			Thank you #ThankYouData.fname# #ThankYouData.lname# for making your selection.<br /><br />
			Your request for a <cfif ThankYouData.gender IS "M">mens<cfelse>womens</cfif> #LCASE(ThankYouData.size)# jacket has been received.<br /><br />
			You will receive an email confirmation.
			</cfoutput>
			</td>
		</tr>
	</table>
	<cfmail to="#ThankYouData.email#" from="#application.AwardsFromEmail#" subject="60TH Anniversary Thank You Gift" type="html">
	<style type="text/css">
	<!-- 
	body { margin:0px; background-color:##fff; height:100% }
	html { height:100% }
	img { margin:0px; border-style:none }
	button { margin:0px; border-style:none; padding:0px; background-color:transparent; vertical-align:top }
	p:first-child { margin-top:0px }
	table { empty-cells:hide }
	.f-sp { font-size:1px; visibility:hidden }
	.f-lp { margin-bottom:0px }
	.f-fp { margin-top:0px }
	.f-x1 {  }
	.f-x2 {  }
	.f-x3 {  }
	em { font-style:italic }
	h1 { font-size:18px }
	h1:first-child { margin-top:0px }
	strong { font-weight:bold }
	.style2 { font-family:Arial,Helvetica,sans-serif; font-size:12px }
	.style4 { color:##000; font-family:Arial,Helvetica,sans-serif; font-size:12px }
	.style6 { font-family:Arial,Helvetica,sans-serif; font-size:16px; font-weight:bold;}
	.style8 { font-family:Arial,Helvetica,sans-serif; font-size:16px;}
	-->
	</style>
		<table border=0 cellspacing=0 cellpadding=0 width=535>
			<colgroup>
				<col width=21>
				<col width=146>
				<col width=1>
			</colgroup>
			<tr valign=top>
				<td height=12 colspan=2></td>
				<td height=12></td>
			</tr>
			<tr valign=top>
				<td height=133></td>
				<td height=133><img src="#application.SecureWebPath#/pics/ari60/ari60th2logocolo.jpeg" border=0 width=146 height=133 alt="ARI60th2logoCOLORSM" style="float:left"></td>
				<td height=133></td>
			</tr>
			<tr class="f-sp">
				<td><img src="#application.SecureWebPath#/pics/ari60/shim.gif" border=0 width=21 height=1 alt="" style="float:left"></td>
				<td><img src="#application.SecureWebPath#/pics/ari60/shim.gif" border=0 width=146 height=1 alt="" style="float:left"></td>
				<td height=30><img src="#application.SecureWebPath#/pics/ari60/shim.gif" border=0 width=1 height=1 alt="" style="float:left"></td>
			</tr>
			<tr class="style8">
				<td>&nbsp;</td>
				<td colspan="2" align="left">
				Thank you #ThankYouData.fname# #ThankYouData.lname# for making your selection.<br /><br />
				Your request for a <cfif ThankYouData.gender IS "M">mens<cfelse>womens</cfif> #LCASE(ThankYouData.size)# jacket has been received.<br /><br />
				This is your email confirmation.
				</td>
			</tr>
		</table>
	</cfmail>
</cfif>
</div>
</body>
</html>
