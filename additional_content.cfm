<cfparam name="url.n" default="1">
<cfif NOT isnumeric(url.n)>
	<cfset url.n = 1>
</cfif>

<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="includes/function_library_itcawards.cfm">

<!--- authenticate program cookie and get program vars --->
<cfoutput>#GetProgramInfo()#</cfoutput>

<cfparam name="c" default="">
<cfparam name="p" default="">
<cfparam name="g" default="">
<cfparam name="OnPage" default="">

<cfinclude template="includes/header.cfm">
<cfoutput>

<table cellpadding="0" cellspacing="0" border="0" width="1200">

<tr>
<td width="200" valign="top" align="center">
	<img src="pics/shim.gif" width="200" height="1">
	<br /><br />
	<table cellpadding="8" cellspacing="1" border="0" width="150">
	
	<tr>
	<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='welcome.cfm'">Return To<br>Welcome Page</td>
	</tr>
	
	<tr>
	<td>&nbsp;</td>
	</tr>

	<tr>
	<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='main.cfm'">#welcome_button#</td>
	</tr>
		
	<cfif help_button NEQ "">
	
	<tr>
	<td>&nbsp;</td>
	</tr>
	
	<tr>
	<td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="openHelp()">#help_button#</td>
	</tr>
	
	</cfif>
<cfif LEFT(cookie.itc_pid,10) IS '1000000069'>
					<tr><td>&nbsp;</td></tr>
					<tr><td align="center" class="active_button" onMouseOver="mOver(this,'selected_button');" onMouseOut="mOut(this,'active_button');" onClick="window.location='henkel-register-cn.cfm'">Registration</td></tr>
</cfif>
	</table>
</td>

<cfif url.n NEQ 2>
	<cfset this_content = additional_content_message>
<cfelse>
	<cfset this_content = additional_content2_message>
</cfif>
<td width="725" valign="top" style="padding:25px">
	<div id="tiny_mce_clear">
		#Replace(this_content,chr(10),"<br>","ALL")#
	</div>
</td>
</tr>

</table>

</body>

</cfoutput>

</html>
