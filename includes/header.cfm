<CFSCRIPT>
	kFLGen_ImageSize = FLGen_ImageSize(application.FilePath & "pics/program/" & vLogo);
</CFSCRIPT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<link rel="shortcut icon" href="/favicon.ico" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>ITC Awards</title>

<!--- include variable style info --->
<cfif use_master_categories GT 2>
	<cfinclude template="program_style_tabs.cfm">
	<style type="text/css" media="screen"><!--
		#layer1 { position: absolute; top: 270px; left: 240px; width: 500px; height: 231px; visibility: visible; display: block }
	--></style>
<cfelse>
	<style type="text/css"> 
		<cfinclude template="program_style.cfm"> 
	</style>
</cfif>
<style>
	div#tiny_mce_clear, div#tiny_mce_clear * {
		margin: 0;
		padding: 0;
		border: 0;
		font-size: 100%;
	}
</style>

<!--- rollover function --->
<script>

	function mOver(item, newClass)

		{
		item.className=newClass
		}

	function mOut(item, newClass)

		{
		item.className=newClass
		}

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

</head>



<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0"<cfoutput>#main_bg#</cfoutput>>
<cfinclude template="environment.cfm"> 
<cftry>
	<cfset this_width = kFLGen_ImageSize.ImageWidth>
	<cfcatch>
		<cfset this_width = 0>
	</cfcatch>
</cftry>
<cfoutput>
<cfif this_width LT 265>

<!--- the logo is next to congrats --->
<table cellpadding="0" cellspacing="0" border="0" width="1200">
<tr>
<td rowspan="2" width="275" style="padding:5px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
<td rowspan="2" height="40" align="left" valign="bottom">#main_congrats#</td>
<td style="padding:12px" align="right" valign="bottom">
	<span style="padding:8px" class="checkout_off" onMouseOver="mOver(this,'checkout_over');" onMouseOut="mOut(this,'checkout_off');" onClick="window.location='main.cfm'">
		<b>&nbsp;&nbsp;Main Menu&nbsp;&nbsp;</b>
	</span>
</td>
</tr>
<tr>
<td style="padding:12px" align="right" valign="bottom">
	<span style="padding:8px" class="checkout_off" onMouseOver="mOver(this,'checkout_over');" onMouseOut="mOut(this,'checkout_off');" onClick="window.location='cart.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">
		<b>&nbsp;&nbsp;View&nbsp;Cart&nbsp;&nbsp;</b>
	</span>
</td>
</tr>
</table>

<cfelse>

<!--- the logo extends over the congrats --->
<table cellpadding="0" cellspacing="0" border="0" width="1200">
	<cfif welcome_congrats NEQ "&nbsp;" AND welcome_congrats NEQ "">
		<tr>
		<td colspan="2" style="padding:10px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
		<td style="padding:12px" align="right" valign="bottom">
			<span style="padding:8px" class="checkout_off" onMouseOver="mOver(this,'checkout_over');" onMouseOut="mOut(this,'checkout_off');" onClick="window.location='main.cfm'">
				<b>&nbsp;&nbsp;Main Menu&nbsp;&nbsp;</b>
			</span>
		</td>
		</tr>
		
		
		<tr>
		<td width="275"><img src="pics/program/shim.gif" width="275" height="1"></td>
		<td height="40" align="left" valign="bottom">#welcome_congrats#</td>
		<td style="padding:12px" align="right" valign="bottom">
			<span style="padding:8px" class="checkout_off" onMouseOver="mOver(this,'checkout_over');" onMouseOut="mOut(this,'checkout_off');" onClick="window.location='cart.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">
				<b>&nbsp;&nbsp;View&nbsp;Cart&nbsp;&nbsp;</b>
			</span>
		</td>
		
		</tr>
	<cfelse>
		<tr>
		<td colspan="2" rowspan="2" style="padding:10px"><img src="pics/program/#vLogo#" style="padding-left:21px"></td>
		<td style="padding:12px" align="right" valign="bottom">
			<span style="padding:8px" class="checkout_off" onMouseOver="mOver(this,'checkout_over');" onMouseOut="mOut(this,'checkout_off');" onClick="window.location='main.cfm'">
				<b>&nbsp;&nbsp;Main Menu&nbsp;&nbsp;</b>
			</span>
		</td>
		</tr>
		
		
		<tr>
		<td style="padding:12px" align="right" valign="top">
			<span style="padding:8px" class="checkout_off" onMouseOver="mOver(this,'checkout_over');" onMouseOut="mOut(this,'checkout_off');" onClick="window.location='cart.cfm?c=#c#&p=#p#&g=#g#&OnPage=#OnPage#'">
				<b>&nbsp;&nbsp;View&nbsp;Cart&nbsp;&nbsp;</b>
			</span>
		</td>
		
		</tr>
	</cfif>


</table>

</cfif>
</cfoutput>
