<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfparam name="pgfn" default="input">
<cfparam name="ID" default=0>
<cfparam name="username" default="">
<cfparam name="ErrorMessage" default="">
<cfparam name="py_sales" default=0.00>
<cfparam name="jan_sales" default=0.00>
<cfparam name="feb_sales" default=0.00>
<cfparam name="mar_sales" default=0.00>
<cfparam name="apr_sales" default=0.00>
<cfparam name="may_sales" default=0.00>
<cfparam name="jun_sales" default=0.00>
<cfparam name="jul_sales" default=0.00>
<cfparam name="aug_sales" default=0.00>
<cfparam name="sep_sales" default=0.00>
<cfparam name="oct_sales" default=0.00>
<cfparam name="nov_sales" default=0.00>
<cfparam name="dec_sales" default=0.00>
<cfset company_name="">
<cfset branch_ID="">
<cfset created_user_ID = 1000000066>
<cfset program_ID = 1000000066>
<cfset ErrorMessage = "">

<cfif NOT isNumeric(py_sales)><cfset py_sales = 0></cfif>
<cfif NOT isNumeric(jan_sales)><cfset jan_sales = 0></cfif>
<cfif NOT isNumeric(feb_sales)><cfset feb_sales = 0></cfif>
<cfif NOT isNumeric(mar_sales)><cfset mar_sales = 0></cfif>
<cfif NOT isNumeric(apr_sales)><cfset apr_sales = 0></cfif>
<cfif NOT isNumeric(may_sales)><cfset may_sales = 0></cfif>
<cfif NOT isNumeric(jun_sales)><cfset jun_sales = 0></cfif>
<cfif NOT isNumeric(jul_sales)><cfset jul_sales = 0></cfif>
<cfif NOT isNumeric(aug_sales)><cfset aug_sales = 0></cfif>
<cfif NOT isNumeric(sep_sales)><cfset sep_sales = 0></cfif>
<cfif NOT isNumeric(oct_sales)><cfset oct_sales = 0></cfif>
<cfif NOT isNumeric(nov_sales)><cfset nov_sales = 0></cfif>
<cfif NOT isNumeric(dec_sales)><cfset dec_sales = 0></cfif>

<cfif pgfn IS 'save_data' AND isNumeric(ID) AND ID GT 0>
	<cfquery name="SaveSalesData" datasource="#application.DS#">
		UPDATE #application.database#.henkel_register_branch SET
			py_sales = <cfqueryparam value="#py_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			jan_sales = <cfqueryparam value="#jan_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			feb_sales = <cfqueryparam value="#feb_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			mar_sales = <cfqueryparam value="#mar_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			apr_sales = <cfqueryparam value="#apr_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			may_sales = <cfqueryparam value="#may_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			jun_sales = <cfqueryparam value="#jun_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			jul_sales = <cfqueryparam value="#jul_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			aug_sales = <cfqueryparam value="#aug_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			sep_sales = <cfqueryparam value="#sep_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			oct_sales = <cfqueryparam value="#oct_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			nov_sales = <cfqueryparam value="#nov_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">,
			dec_sales = <cfqueryparam value="#dec_sales#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
		WHERE ID = <cfqueryparam value="#ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	</cfquery>
<html>
	<head>
		<meta http-equiv="content-type" content="text/html;charset=ISO-8859-1">
		<meta name="generator" content="Adobe GoLive 6">
		<title>Baseline</title>
		<style type="text/css" media="screen"><!--
td   { font-weight: bold; font-size: 12px; line-height: 14px; font-family: Arial, Helvetica, Geneva, Swiss, SunSans-Regular }
.months { margin: 0px 5px 0px 0px }
--></style>
	</head>

	<body bgcolor="#ffffff" link="#ffff66" onLoad="CalcTotals();">
<cfinclude template="../../includes/environment.cfm"> 
		<div align="center">
			<table id="Table_01" width="890" height="615" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td><img src="images/board_01.jpg" width="17" height="148" alt=""></td>
					<td><img src="images/board_02.jpg" width="856" height="148" alt=""></td>
					<td><img src="images/board_03.jpg" width="17" height="148" alt=""></td>
				</tr>
				<tr>
					<td><img src="images/board_04.jpg" width="17" height="455" alt=""></td>
					<td background="images/board_05.jpg" align="center">
						<img src="images/thank-you.gif" border="0">
					</td>
					<td><img src="images/board_06.jpg" width="17" height="455" alt=""></td>
				</tr>
				<tr>
					<td><img src="images/board_07.jpg" width="17" height="12" alt=""></td>
					<td><img src="images/board_08.jpg" width="856" height="12" alt=""></td>
					<td><img src="images/board_09.jpg" width="17" height="12" alt=""></td>
				</tr>
			</table>
		</div>
	</body>
</html>
</cfif>

<cfif pgfn IS 'input' AND (ID GT 0 OR username GT "")>
	<cfquery name="SalesData" datasource="#application.DS#">
		SELECT ID, username, company_name, branch_id, py_sales, jan_sales, feb_sales, mar_sales, apr_sales, may_sales, jun_sales, jul_sales, aug_sales, sep_sales, oct_sales, nov_sales, dec_sales
		FROM #application.database#.henkel_register_branch 
		<cfif username GT "">
			WHERE username = <cfqueryparam value="#username#" cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			WHERE ID = <cfqueryparam value="#ID#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
	</cfquery>
	<cfif SalesData.RecordCount IS 1>
		<cfset ID = SalesData.ID>
		<cfset username = SalesData.username>
		<cfset company_name = SalesData.company_name>
		<cfset branch_id = SalesData.branch_id>
		<cfset py_sales = SalesData.py_sales>
		<cfset jan_sales = SalesData.jan_sales>
		<cfset feb_sales = SalesData.feb_sales>
		<cfset mar_sales = SalesData.mar_sales>
		<cfset apr_sales = SalesData.apr_sales>
		<cfset may_sales = SalesData.may_sales>
		<cfset jun_sales = SalesData.jun_sales>
		<cfset jul_sales = SalesData.jul_sales>
		<cfset aug_sales = SalesData.aug_sales>
		<cfset sep_sales = SalesData.sep_sales>
		<cfset oct_sales = SalesData.oct_sales>
		<cfset nov_sales = SalesData.nov_sales>
		<cfset dec_sales = SalesData.dec_sales>
	</cfif>
<html>
	<head>
		<meta http-equiv="content-type" content="text/html;charset=ISO-8859-1">
		<meta name="generator" content="Adobe GoLive 6">
		<title>Baseline</title>
		<style type="text/css" media="screen"><!--
td   { font-weight: bold; font-size: 12px; line-height: 14px; font-family: Arial, Helvetica, Geneva, Swiss, SunSans-Regular }
.months { margin: 0px 5px 0px 0px }
--></style>
<script language="JavaScript" type="text/javascript" />
function CalcTotals () {
	PercentComplete = 0.00
	form_entry.py_sales.value=form_entry.py_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.jan_sales.value=form_entry.jan_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.feb_sales.value=form_entry.feb_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.mar_sales.value=form_entry.mar_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.apr_sales.value=form_entry.apr_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.may_sales.value=form_entry.may_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.jun_sales.value=form_entry.jun_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.jul_sales.value=form_entry.jul_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.aug_sales.value=form_entry.aug_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.sep_sales.value=form_entry.sep_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.oct_sales.value=form_entry.oct_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.nov_sales.value=form_entry.nov_sales.value.replace(/[^0-9\.]*/g,'')
	form_entry.dec_sales.value=form_entry.dec_sales.value.replace(/[^0-9\.]*/g,'')
	
	Q1_Total = (form_entry.jan_sales.value * 1) + (form_entry.feb_sales.value * 1) + (form_entry.mar_sales.value * 1)
	Q2_Total = (form_entry.apr_sales.value * 1) + (form_entry.may_sales.value * 1) + (form_entry.jun_sales.value * 1)
	Q3_Total = (form_entry.jul_sales.value * 1) + (form_entry.aug_sales.value * 1) + (form_entry.sep_sales.value * 1)
	Q4_Total = (form_entry.oct_sales.value * 1) + (form_entry.nov_sales.value * 1) + (form_entry.dec_sales.value * 1)
	Grand_Total = Q1_Total + Q2_Total + Q3_Total + Q4_Total
	COGSTarget = (form_entry.py_sales.value * 1.05)
	if (Grand_Total!=0){
		if (COGSTarget!=0){
			PercentComplete = ((Grand_Total / COGSTarget) * 100)
		}
	}
	form_entry.q1total.value = Q1_Total.toFixed(0)
	form_entry.q2total.value = Q2_Total.toFixed(0)
	form_entry.q3total.value = Q3_Total.toFixed(0)
	form_entry.q4total.value = Q4_Total.toFixed(0)
	form_entry.grandtotal.value = Grand_Total.toFixed(0)
	form_entry.cogs_target.value = COGSTarget.toFixed(0)
	form_entry.percent_completed.value = PercentComplete.toFixed(2)
	
}
</script>
	</head>

	<body bgcolor="#ffffff" link="#ffff66" onLoad="CalcTotals();">
<cfinclude template="../../includes/environment.cfm"> 
		<div align="center">
<cfif SalesData.RecordCount IS 1>		
		<cfoutput>
		<form action="#CurrentPage#" method="post" NAME="form_entry" onSubmit="return CalcTotals();">
			<input type="hidden" name="pgfn" value="save_data">
			<input type="hidden" name="ID" value="#ID#">
			<!-- ImageReady Slices (board.psd) -->
			<table id="Table_01" width="890" height="615" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td><img src="images/board_01.jpg" width="17" height="148" alt=""></td>
					<td><img src="images/board_02.jpg" width="856" height="148" alt=""></td>
					<td><img src="images/board_03.jpg" width="17" height="148" alt=""></td>
				</tr>
				<tr>
					<td><img src="images/board_04.jpg" width="17" height="455" alt=""></td>
					<td background="images/board_05.jpg">
						<div align="center">
							<table width="95%" border="0" cellspacing="0" cellpadding="0" height="95%">
								<tr>
									<td valign="top" width="12%"><br>
									</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="16%"></td>
								</tr>
								<tr>
									<td colspan="4" valign="top">Distributor Company Name <input name="company_name" type="text" disabled tabindex="0" value="#company_name#" size="24" readonly="true"></td>
									<td width="12%"></td>
									<td colspan="2">
										<div align="right">
											<p class="months">Please enter your <br>
												2007 Total Anaerobic COGS</p>
										</div>
									</td>
									<td valign="top" width="16%"><input type="text" name="py_sales" onChange="CalcTotals();" value="#py_sales#" size="14" border="0"></td>
								</tr>
								<tr>
									<td colspan="4" valign="top"> Branch ID Code or ## <input name="username" type="text" disabled value="#username#" size="23" readonly="true"></td>
									<td width="12%"></td>
									<td colspan="2" valign="top">
										<div align="right">
											</div>
									</td>
									<td valign="top" width="16%"></td>
								</tr>
								<tr>
									<td valign="top" width="12%"><br>
									</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="16%"> </td>
								</tr>
								<tr>
									<td colspan="5" valign="top">Please enter below your 2008 Anaerobic COGS data monthly or quarterly.<br>
										Here is a list of <a href="item-list.xls">Loctite&reg; products</a> that qualify.</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="16%"></td>
								</tr>
								<tr>
									<td valign="top" width="12%"><br>
									</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="16%"></td>
								</tr>
								<tr>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%">1st Quarter</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%">2nd Quarter</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%">3rd Quarter</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="16%">4th Quarter</td>
								</tr>
								<tr>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">January</p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input name="jan_sales" type="text" onChange="CalcTotals();" value="#jan_sales#" size="14" /></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">April</p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="apr_sales" onChange="CalcTotals();" value="#apr_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">July </p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="jul_sales" onChange="CalcTotals();" value="#jul_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">October</p>
										</div>
									</td>
									<td valign="bottom" width="16%"><input type="text" name="oct_sales" onChange="CalcTotals();" value="#oct_sales#" size="14" border="0"></td>
								</tr>
								<tr>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">February</p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="feb_sales" onChange="CalcTotals();" value="#feb_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">May</p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="may_sales" onChange="CalcTotals();" value="#may_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">August </p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="aug_sales" onChange="CalcTotals();" value="#aug_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">November</p>
										</div>
									</td>
									<td valign="bottom" width="16%"><input type="text" name="nov_sales" onChange="CalcTotals();" value="#nov_sales#" size="14" border="0"></td>
								</tr>
								<tr>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">March</p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="mar_sales" onChange="CalcTotals();" value="#mar_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">June</p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="jun_sales" onChange="CalcTotals();" value="#jun_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">September </p>
										</div>
									</td>
									<td valign="bottom" width="12%"><input type="text" name="sep_sales" onChange="CalcTotals();" value="#sep_sales#" size="14" border="0"></td>
									<td valign="bottom" width="12%">
										<div align="right">
											<p class="months">December</p>
										</div>
									</td>
									<td valign="bottom" width="16%"><input type="text" name="dec_sales" onChange="CalcTotals();" value="#dec_sales#" size="14" border="0"></td>
								</tr>
								<tr>
									<td valign="top" width="12%"><br>
									</td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="16%"></td>
								</tr>
								<tr>
									<td valign="top" width="12%">
										<div align="right">
											<p class="months">Total 1st <br>
												Quarter </p>
										</div>
									</td>
									<td valign="top" width="12%"><input name="q1total" type="text" disabled value="0.00" size="14" readonly="true"></td>
									<td valign="top" width="12%">
										<div align="right">
											<p class="months">Total 2nd <br>
												Quarter </p>
										</div>
									</td>
									<td valign="top" width="12%"><input type="text" name="q2total" value="0.00" size="14" border="0" disabled  readonly="true"></td>
									<td valign="top" width="12%">
										<div align="right">
											<p class="months">Total 3rd <br>
												Quarter </p>
										</div>
									</td>
									<td valign="top" width="12%"><input type="text" name="q3total" value="0.00" size="14" border="0" disabled  readonly="true"></td>
									<td valign="top" width="12%">
										<div align="right">
											<p class="months">Total 4th <br>
												Quarter </p>
										</div>
									</td>
									<td valign="top" width="16%"><input type="text" name="q4total" value="0.00" size="14" border="0" disabled  readonly="true"></td>
								</tr>
								<tr>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="16%"></td>
								</tr>
								<tr>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%">
										<div align="right"></div>
									</td>
									<td colspan="2" valign="top">
										<div align="right">
											<p class="months">
											2008 Total <br>
												
											Anaerobic COGS</p>
										</div>
									</td>
									<td valign="top" width="16%"><input type="text" name="grandtotal" value="0.00" size="14" border="0" disabled  readonly="true"></td>
								</tr>
								<tr>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td valign="top" width="12%"></td>
									<td colspan="2" valign="top">
										<div align="right">
											<p class="months">Percent Achieved<br>of Growth Target</p>
										</div>
									</td>
									<td valign="top" width="16%"><input type="text" name="percent_completed" size="14" border="0" disabled  readonly="true"></td>
								</tr>
								<tr>
									<td colspan="2" valign="bottom">COGS=Cost Of Goods Sold</td>
									<td valign="top" width="12%">
										<div align="right"></div>
									</td>
									<td width="12%"></td>
									<td width="12%"></td>
									<td colspan="2" valign="bottom">
										<div align="right">
											<p class="months">2008 COGS Growth Target</p>
										</div>
									</td>
									<td valign="bottom" width="16%"><input type="text" name="cogs_target" size="14" border="0" disabled  readonly="true"></td>
								</tr>
								<tr>
									<td valign="top" width="12%" colspan="7">All data subject to audit by Henkel Corporation.</td>
								</tr>
								<tr>
								<td valign="top" width="12%"></td>
								<td valign="top" width="12%"></td>
								<td valign="top"></td>
								<td valign="top"></td>
								<td valign="top" width="12%"></td>
								<td valign="top" width="12%"></td>
								<td valign="top" width="12%"></td>
								<td valign="top" width="16%"><input type="image" src="images/btn-savedata.gif" alt="" width="100" height="26" border="0"></td>
								</tr>
							</table>
						</div>
					</td>
					<td><img src="images/board_06.jpg" width="17" height="455" alt=""></td>
				</tr>
				<tr>
					<td><img src="images/board_07.jpg" width="17" height="12" alt=""></td>
					<td><img src="images/board_08.jpg" width="856" height="12" alt=""></td>
					<td><img src="images/board_09.jpg" width="17" height="12" alt=""></td>
				</tr>
			</table>
			<!-- End ImageReady Slices -->
		</form>
		</cfoutput>
<cfelse>
			<table id="Table_01" width="890" height="615" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td><img src="images/board_01.jpg" width="17" height="148" alt=""></td>
					<td><img src="images/board_02.jpg" width="856" height="148" alt=""></td>
					<td><img src="images/board_03.jpg" width="17" height="148" alt=""></td>
				</tr>
				<tr>
					<td><img src="images/board_04.jpg" width="17" height="455" alt=""></td>
					<td background="images/board_05.jpg" align="center">
						<p class="months">We cannot find your registration information.  Please <a href="index.cfm">try again</a>.</p>
					</td>
					<td><img src="images/board_06.jpg" width="17" height="455" alt=""></td>
				</tr>
				<tr>
					<td><img src="images/board_07.jpg" width="17" height="12" alt=""></td>
					<td><img src="images/board_08.jpg" width="856" height="12" alt=""></td>
					<td><img src="images/board_09.jpg" width="17" height="12" alt=""></td>
				</tr>
			</table>
</cfif>
		</div>
	</body>
</html>

</cfif>							
