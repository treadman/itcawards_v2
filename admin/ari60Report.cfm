<!--- import function libraries --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_page.cfm">

<!--- authenticate the admin user --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000086,true)>

<!--- variables used on this page --->
<cfparam name="pgfn" default="list">
<cfparam name="delete" default="">

<!--- search criteria cri_S=ColumnSort cri_T =SearchString cri_L=Letter --->
<!--- form fields --->
<cfset TotalMensSmall = 0>
<cfset TotalMensMedium = 0>
<cfset TotalMensLarge = 0>
<cfset TotalMensXLarge = 0>
<cfset TotalMens2XLarge = 0>
<cfset TotalMens3XLarge = 0>
<cfset TotalMens4XLarge = 0>
<cfset TotalWomensXSmall = 0>
<cfset TotalWomensSmall = 0>
<cfset TotalWomensMedium = 0>
<cfset TotalWomensLarge = 0>
<cfset TotalWomensXLarge = 0>
<cfset TotalWomens2XLarge = 0>
<cfset TotalLineTotal = 0>

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset request.main_width = 900>
<cfset leftnavon = "ari60Report">
<cfinclude template="includes/header.cfm">

<cfquery name="ReportQuery" datasource="#application.DS#">
	SELECT A1.city, A1.state, 
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'M' AND A2.size = 'Small') AS MensSmall,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND A2.gender = 'M' AND A2.size = 'Medium') AS MensMedium,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'M' AND A2.size = 'Large') AS MensLarge,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'M' AND A2.size = 'XLarge') AS MensXLarge,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'M' AND A2.size = '2 XLarge') AS Mens2XLarge,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'M' AND A2.size = '3 XLarge') AS Mens3XLarge,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'M' AND A2.size = '4 XLarge') AS Mens4XLarge,
	
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'W' AND A2.size = 'XSmall') AS WomensXSmall,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'W' AND A2.size = 'Small') AS WomensSmall,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND A2.gender = 'W' AND A2.size = 'Medium') AS WomensMedium,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'W' AND A2.size = 'Large') AS WomensLarge,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'W' AND A2.size = 'XLarge') AS WomensXLarge,
	
	(SELECT COUNT(*)
	FROM #application.database#.ari60 A2
	WHERE A2.city = A1.city AND A2.state = A1.state AND  A2.gender = 'W' AND A2.size = '2 XLarge') AS Womens2XLarge
	
	
	FROM #application.database#.ari60 A1
	WHERE A1.gender != '' AND A1.size != ''
	GROUP BY A1.state, A1.city
</cfquery>	

<table width="100%" cellpadding="5" cellspacing="1" border="0">
	<tr valign="top" class="content">
		<th align="right">&nbsp;</th>
		<th colspan="7">Mens</th>
		<th colspan="6">Womens</th>
		<th align="right">Line</th>
	</tr>
	<tr valign="top" class="content">
		<th>City, State</th>
		<th align="right">S</th>
		<th align="right">M</th>
		<th align="right">L</th>
		<th align="right">XL</th>
		<th align="right">2X</th>
		<th align="right">3X</th>
		<th align="right">4X</th>

		<th align="right">XS</th>
		<th align="right">S</th>
		<th align="right">M</th>
		<th align="right">L</th>
		<th align="right">XL</th>
		<th align="right">2X</th>
		<th align="right">Total</th>
	</tr>

<cfoutput query="ReportQuery">
	<cfif (CurrentRow MOD 2) is 0>
		<cfset rowcolor = "content">
	<cfelse>
		<cfset rowcolor = "content2">
	</cfif>
	<cfset LineTotal = MensSmall + MensMedium + MensLarge + MensXLarge + Mens2XLarge + Mens3XLarge + Mens4XLarge + WomensXSmall + WomensSmall + WomensMedium + WomensLarge + WomensXLarge + Womens2XLarge>
	<cfset TotalMensSmall = TotalMensSmall + MensSmall>
	<cfset TotalMensMedium = TotalMensMedium + MensMedium>
	<cfset TotalMensLarge = TotalMensLarge + MensLarge>
	<cfset TotalMensXLarge = TotalMensXLarge + MensXLarge>
	<cfset TotalMens2XLarge = TotalMens2XLarge + Mens2XLarge>
	<cfset TotalMens3XLarge = TotalMens3XLarge +Mens3XLarge >
	<cfset TotalMens4XLarge = TotalMens4XLarge + Mens4XLarge>
	<cfset TotalWomensXSmall = TotalWomensXSmall + WomensXSmall>
	<cfset TotalWomensSmall = TotalWomensSmall + WomensSmall>
	<cfset TotalWomensMedium = TotalWomensMedium + WomensMedium>
	<cfset TotalWomensLarge = TotalWomensLarge + WomensLarge>
	<cfset TotalWomensXLarge = TotalWomensXLarge + WomensXLarge>
	<cfset TotalWomens2XLarge = TotalWomens2XLarge + Womens2XLarge>
	<cfset TotalLineTotal = TotalLineTotal + LineTotal>
	<tr valign="top" class="#rowcolor#">
		<td>#City#, #State#</td>
		<td align="right">#MensSmall#</td>
		<td align="right">#MensMedium#</td>
		<td align="right">#MensLarge#</td>
		<td align="right">#MensXLarge#</td>
		<td align="right">#Mens2XLarge#</td>
		<td align="right">#Mens3XLarge#</td>
		<td align="right">#Mens4XLarge#</td>

		<td align="right">#WomensXSmall#</td>
		<td align="right">#WomensSmall#</td>
		<td align="right">#WomensMedium#</td>
		<td align="right">#WomensLarge#</td>
		<td align="right">#WomensXLarge#</td>
		<td align="right">#Womens2XLarge#</td>
		<td align="right">#LineTotal#</td>
	</tr>
</cfoutput>
<cfoutput>
	<tr valign="top" class="content">
		<th align="right">Total</th>
		<th align="right">#TotalMensSmall#</th>
		<th align="right">#TotalMensMedium#</th>
		<th align="right">#TotalMensLarge#</th>
		<th align="right">#TotalMensXLarge#</th>
		<th align="right">#TotalMens2XLarge#</th>
		<th align="right">#TotalMens3XLarge#</th>
		<th align="right">#TotalMens4XLarge#</th>

		<th align="right">#TotalWomensXSmall#</th>
		<th align="right">#TotalWomensSmall#</th>
		<th align="right">#TotalWomensMedium#</th>
		<th align="right">#TotalWomensLarge#</th>
		<th align="right">#TotalWomensXLarge#</th>
		<th align="right">#TotalWomens2XLarge#</th>
		<th align="right">#TotalLineTotal#</th>
	</tr>
</cfoutput>
</table>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->