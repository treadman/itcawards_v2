<cfsetting requesttimeout="600" />

<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<cfif request.henkel_ID NEQ "1000000066">
	<cflocation url="index.cfm" addtoken="no">
</cfif>

<cfparam name="form.do_report" default="" >
<cfparam name="form.distributor" default="" >
<cfparam name="form.school" default="All">
<cfparam name="url.cn" default="">

<cfparam name="FromDate" default="">
<cfparam name="ToDate" default="">
<cfparam name="formatFromDate" default="">
<cfparam name="formatToDate" default="">

<cfif FromDate NEQ "">
	<cfset FromDate = FLGen_DateTimeToDisplay(FromDate)>
	<cfset formatFromDate = FLGen_DateTimeToMySQL(FromDate)>
	<cfif ToDate NEQ "">
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
		<cfset ToDate = FLGen_DateTimeToDisplay(ToDate)>
	<cfelse>
		<cfset ToDate = FLGen_DateTimeToDisplay()>
		<cfset formatToDate = FLGen_DateTimeToMySQL(ToDate & "23:59:59")>
	</cfif>
</cfif>	

<cfset crlf = "#CHR(13)##CHR(10)#">

<cfif (form.do_report EQ "" OR form.distributor EQ "") AND (url.cn EQ "" OR NOT ListFindNoCase("Fastenal,Lawson-points,Erie,Lawson-lu,Applied,TAI",url.cn))>
	<cfset leftnavon = 'csv_reports'>
	<cfinclude template="includes/header.cfm">
	<span class="highlight"><cfoutput>#request.selected_henkel_program.program_name#</cfoutput></span>
	<span class="pagetitle">Download CSV files based on email address:</span>
	<br><br>
	<table cellpadding="8" width="100%">
		<tr class="contenthead">
			<td width="20%" class="headertext">Download link</td>
			<td width="20%" class="headertext">Email contains</td>
			<td width="60%" class="headertext">Description</td>
		</tr>
		<tr height="30px">
			<td><a href="<cfoutput>#CurrentPage#</cfoutput>?cn=Fastenal">Fastenal</a></td>
			<td>"fastenal"</td>
			<td>Shows points awarded and redeemed within each year from 2012 to 2014.</td>
		</tr>
		<tr height="30px">
			<td><a href="<cfoutput>#CurrentPage#</cfoutput>?cn=Lawson-points">Lawson</a></td>
			<td>"lawsonproducts"</td>
			<td>Shows points awarded and redeemed within each year from 2012 to 2014, including points in the holding tank.</td>
		</tr>
		<tr height="30px">
			<td><a href="<cfoutput>#CurrentPage#</cfoutput>?cn=Lawson-lu">Lawson (LU Only)</a></td>
			<td>"lawsonproducts"</td>
			<td>Shows all points awarded and redeemed for Loctite University, including points in the holding tank.</td>
		</tr>
		<tr height="30px">
			<td><a href="<cfoutput>#CurrentPage#</cfoutput>?cn=Applied">Applied</a></td>
			<td>"applied"</td>
			<td>Shows all points awarded for Loctite University in 2014, grouped by month, including points in the holding tank.</td>
		</tr>
		<tr height="30px">
			<td><a href="<cfoutput>#CurrentPage#</cfoutput>?cn=TAI">T&amp;A Industrial</a></td>
			<td>"taindustrial"</td>
			<td>Shows points awarded and redeemed within each year from 2012 to 2014.</td>
		</tr>
		<tr height="30px">
			<td><a href="<cfoutput>#CurrentPage#</cfoutput>?cn=Erie">Erie Bearings</a></td>
			<td>"eriebearings"</td>
			<td>Shows points awarded and redeemed within each year from 2012 to 2015, including points in the holding tank.</td>
		</tr>
	</table>
	<hr>
	<cfif form.do_report NEQ "" AND form.distributor EQ "">
		<script>alert("Please select a distributor.");</script>
	</cfif>
	<form action="<cfoutput>#CurrentPage#</cfoutput>" method="post">
	<table cellpadding="5" cellspacing="0" border="0" width="800">
		<tr>
			<td class="contenthead" colspan="2">Distributor Report</td>
		</tr>
		<tr>
			<td class="content" valign="top" align="right">Distributor:</td>
			<td class="content">
				<table cellpadding="0" cellspacing="0" border="0" width="100%">
					<tr>
						<td><input type="radio" name="distributor" value="Applied"> Applied</td>
						<td>applied.com, applied.com.mx, appliedcanada.com, appliedproducts.com</td>
					</tr>
					<tr>
						<td><input type="radio" name="distributor" value="Fastenal"> Fastenal</td>
						<td>fastenal.com, fastenal.stores.com, store.fastenal.com</td>
					</tr>
					<tr>
						<td><input type="radio" name="distributor" value="Lawson"> Lawson</td>
						<td>lawson.com, lawsonproduct.com, lawsonproducts.com, lawsonproductss.com</td>
					</tr>
					<tr>
						<td><input type="radio" name="distributor" value="TAI"> T&A Industrial</td>
						<td>taindustrial.com</td>
					</tr>
					<tr>
						<td><input type="radio" name="distributor" value="Motion"> Motion Industries</td>
						<td>motion-ind.com</td>
					</tr>
					<tr>
						<td><input type="radio" name="distributor" value="all"> All Companies</td>
						<td></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="content" align="right">School:</td>
			<td class="content">
				<cfset schools = "lu,dts,jsc,mro_oem,dcse,leak">
				<cfset schoolnames = "Loctite University,Distributor Training School,Joint Sales Call,MRO OEM,Documented Cost Savings Event,Air Leak or Hydraulic Leak Survey">
				<!--- <cfset schoolsblocked = "0,1,1,1">
				<cfset schoolsblocked = "0,0,0,0,0,0,0"> --->
				<cfset schoolsblocked = "0,1,1,1,1,1,1">
				<input type="radio" name="school" value="all" checked> All Schools &nbsp;
				<cfloop from="1" to="#ListLen(schools)#" index="n">
					<cfoutput><input type="radio" name="school" value="#ListGetAt(schools,n)#" <cfif ListGetAt(schoolsblocked,n)>disabled</cfif>>#ListGetAt(schoolnames,n)#</cfoutput> &nbsp;
				</cfloop>
			</td>
		</tr>
<!---
		<tr>
			<td class="content" align="right">Starting:</td>
			<td class="content">
				<cfset checked = "checked">
				<cfloop from="#Year(now())#" to="#Year(now())-10#" index="this_year" step="-1">
					<cfif this_year GTE 2008>
						<cfoutput><input type="radio" name="starting" value="#this_year#" #checked#>#this_year#</cfoutput> &nbsp;
						<cfset checked = "">
					</cfif>
				</cfloop>
			</td>
		</tr>
		<tr>
			<td class="content" align="right">Ending:</td>
			<td class="content">
				<cfset checked = "checked">
				<cfloop from="#Year(now())#" to="#Year(now())-10#" index="this_year" step="-1">
					<cfif this_year GTE 2008>
						<cfoutput><input type="radio" name="ending" value="#this_year#" #checked#>#this_year#</cfoutput> &nbsp;
						<cfset checked = "">
					</cfif>
				</cfloop>
			</td>
		</tr>
--->
	<tr class="BGlight1" height="30px;">
	<td class="content" align="right">From Date: </td>
	<td class="content" align="left"><input type="text" name="FromDate" value="<cfoutput>#FromDate#</cfoutput>" size="12"></td>
	</tr>
	
	<tr>
	<td class="content" align="right">To Date:</td>
	<td class="content" align="left"><input type="text" name="ToDate" value="<cfoutput>#ToDate#</cfoutput>" size="12"></td>
	</tr>
		<tr class="content">
			<td colspan="2" align="center"><br><input type="submit" name="do_report" value="Download Report"></td>
		</tr>
	</table>
	</form>
<!---
	<cfquery name="getDomains" datasource="#application.DS#">
		SELECT DISTINCT SUBSTR(email, INSTR(email, '@') + 1) AS domain
		FROM #application.database#.henkel_import_lu
		WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
		AND SUBSTR(email, INSTR(email, '@') + 1) like '%fastenal%'
		ORDER BY SUBSTR(email, INSTR(email, '@') + 1)
	</cfquery>
	<cfdump var="#getDomains#">
applied.com
applied.com.mx
appliedcanada.com
appliedproducts.com

fastenal.com
fastenal.stores.com

lawson.com
lawsonproduct.com
lawsonproducts.com
lawsonproductss.com
--->
	<cfinclude template="includes/footer.cfm">
<cfelse>
	<cfif form.do_report NEQ "">
		<cfset filename = form.distributor & '_' & DateFormat(now(), "mmddyy") />
	<cfelse>
		<cfset filename = url.cn & '_' & DateFormat(now(), "mmddyy") />
	</cfif>
	<cfsetting enablecfoutputonly="yes" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<cfheader name="Content-Disposition" value="filename=#filename#.csv">
	<cfcontent type="application/msexcel" />
	<cfif form.do_report EQ "">
		<cfswitch expression="#ListFirst(url.cn,'-')#">
			<cfcase value="Fastenal">
				<cfquery name="SelectList" datasource="#application.DS#">
					SELECT ID, username, fname, lname, email, is_active
					FROM #application.database#.program_user
					WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
					AND is_active = 1
					AND email LIKE '%fastenal%'
					ORDER BY lname, fname
				</cfquery>
			</cfcase>
			<cfcase value="TAI">
				<cfquery name="SelectList" datasource="#application.DS#">
					SELECT ID, username, fname, lname, email, is_active
					FROM #application.database#.program_user
					WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
					AND is_active = 1
					AND email LIKE '%taindustrial.com%'
					ORDER BY lname, fname
				</cfquery>
			</cfcase>
			
			<cfcase value="Lawson,Applied,Erie">
				<cfquery name="SelectList" datasource="#application.DS#">
					(
						SELECT ID, is_active, 'Active' AS username, fname, lname, email, 0 AS points
						FROM #application.database#.program_user
						WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
						AND is_active = 1
						AND email LIKE
						<cfswitch expression="#ListFirst(url.cn,'-')#">
							<cfcase value = 'Applied'>
								'%applied%'
							</cfcase>
							<cfcase value = 'Lawson'>
								'%lawsonproducts%'
							</cfcase>
							<cfcase value = 'Erie'>
								'%@eriebearings%'
							</cfcase>
						</cfswitch>
					) UNION (
						SELECT 0 AS ID, 2 AS is_active, 'Pending' AS username, email as fname, 'n/a' as lname, email, sum(points) AS points
						FROM #application.database#.henkel_hold_user
						WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
						AND email LIKE 
						<cfswitch expression="#ListFirst(url.cn,'-')#">
							<cfcase value = 'Applied'>
								'%applied%'
							</cfcase>
							<cfcase value = 'Lawson'>
								'%lawsonproducts%'
							</cfcase>
							<cfcase value = 'Erie'>
								'%@eriebearings%'
							</cfcase>
						</cfswitch>
						GROUP BY email
					)
					ORDER BY is_active, fname, lname
				</cfquery>
			</cfcase>
		</cfswitch>
		
		<cfset sub_awarded = 0>
		<cfset sub_redeemed = 0>
		<cfset grand_awarded = 0>
		<cfset grand_redeemed = 0>
		
		<cfswitch expression="#url.cn#">
			<cfcase value="Fastenal">
				<cfset year_list = "2012,2013,2014">
			</cfcase>
			<cfcase value="TAI">
				<cfset year_list = "2012,2013,2014">
			</cfcase>
			<cfcase value="Lawson-points">
				<cfset year_list = "2012,2013,2014">
			</cfcase>
			<cfcase value="Erie">
				<cfset year_list = "2012,2013,2014,2015">
			</cfcase>
			
			<cfcase value="Lawson-lu">
				<cfset year_list = "9999">
			</cfcase>
			<cfcase value="Applied">
				<cfset year_list = "2014">
			</cfcase>
			<cfdefaultcase>
				<cfset year_list = "">
			</cfdefaultcase>
		</cfswitch>
		<cfswitch expression="#url.cn#">
			<cfcase value="Fastenal">
				<cfoutput>Last Name,First Name,Email,Awarded,Redeemed#crlf#</cfoutput>
			</cfcase>
			<cfcase value="TAI">
				<cfoutput>Last Name,First Name,Email,Awarded,Redeemed#crlf#</cfoutput>
			</cfcase>
			
			<cfcase value="Lawson-points,Erie">
				<cfoutput>Status,Last Name,First Name,Email,Awarded,Redeemed#crlf#</cfoutput>
			</cfcase>
			<cfcase value="Lawson-lu,Applied">
				<cfoutput>Status,Last Name,First Name,Email,LU Date,Awarded#crlf#</cfoutput>
			</cfcase>
		</cfswitch>
		
		<cfloop list="#year_list#" index="this_year">
		<cfloop list="1,2,3,4,5,6,7,8,9,10,11,12" index="this_month">
			<cfif url.cn NEQ "Applied" AND this_month GT 1>
				<cfbreak>
			</cfif>
			<cfset userList = "">
			<cfoutput>#url.cn# <cfif ListFindNoCase('Lawson-lu,Applied,TAI',url.cn)>(Loctite University)</cfif> <cfif url.cn EQ "Applied">#this_month#/</cfif><cfif this_year LT 3000>#this_year#</cfif>#crlf#</cfoutput>
			<cfoutput query="SelectList">
				<cfif SelectList.is_active EQ 1 AND ListFindNoCase('Fastenal,Lawson-points,Erie,TAI',url.cn)>
					<cfquery name="PosPoints" datasource="#application.DS#">
						SELECT IFNULL(SUM(points),0) AS pos_pt
						FROM #application.database#.awards_points
						WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
						AND is_defered = 0
						<cfif this_year LT 3000>
							AND YEAR(created_datetime) = '#this_year#'
						</cfif>
					</cfquery>
					<!--- look in the order database for orders/points_used --->
					<cfquery name="NegPoints" datasource="#application.DS#">
						SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) AS neg_pt, IFNULL(SUM(cc_charge),0) AS neg_cc
						FROM #application.database#.order_info
						WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
						<cfif this_year LT 3000>
							AND YEAR(created_datetime) = '#this_year#'
						</cfif>
						AND is_valid = 1
					</cfquery>
				</cfif>
				<cfswitch expression="#url.cn#">
					<cfcase value="Fastenal">
						<cfif PosPoints.pos_pt GT 0 OR NegPoints.neg_pt GT 0>
							#SelectList.lname#,#SelectList.fname#,#SelectList.email#,#PosPoints.pos_pt#,#NegPoints.neg_pt##crlf#
							<cfset sub_awarded = sub_awarded + PosPoints.pos_pt>
							<cfset sub_redeemed = sub_redeemed + NegPoints.neg_pt>
							<cfset grand_awarded = grand_awarded + PosPoints.pos_pt>
							<cfset grand_redeemed = grand_redeemed + NegPoints.neg_pt>
						</cfif>
					</cfcase>
					<cfcase value="TAI">
						<cfif PosPoints.pos_pt GT 0 OR NegPoints.neg_pt GT 0>
							#SelectList.lname#,#SelectList.fname#,#SelectList.email#,#PosPoints.pos_pt#,#NegPoints.neg_pt##crlf#
							<cfset sub_awarded = sub_awarded + PosPoints.pos_pt>
							<cfset sub_redeemed = sub_redeemed + NegPoints.neg_pt>
							<cfset grand_awarded = grand_awarded + PosPoints.pos_pt>
							<cfset grand_redeemed = grand_redeemed + NegPoints.neg_pt>
						</cfif>
					</cfcase>
					
					<cfcase value="Lawson-points,Erie">
						<cfset awarded = 0>
						<cfset redeemed = 0>
						<cfif SelectList.is_active EQ 1>
							<cfset awarded = PosPoints.pos_pt>
							<cfset redeemed = NegPoints.neg_pt>
							<cfset firstname = SelectList.fname>
							<cfset lastname = SelectList.lname>
						<cfelse>
							<!---<cfset awarded = SelectList.points> This is only when not separating years--->
							<cfquery name="GetHoldPoints" datasource="#application.DS#">
								SELECT sum(points) AS points
								FROM #application.database#.henkel_hold_user
								WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectList.email#">
								AND created_datetime BETWEEN <cfqueryparam value="#formatFromDate#"> AND <cfqueryparam value="#formatToDate#">
								<!---AND YEAR(created_datetime) = '#this_year#'--->
								GROUP BY email
							</cfquery>
							<cfset firstname = "">
							<cfset lastname = "">
							<cfset awarded = GetHoldPoints.points>
							<cfif awarded GT 0>
								<cfloop list="lu,dts,jsc,mro_oem,dcse,leak" index="thistable">
									<cfquery name="GetFirstLast" datasource="#application.DS#">
										SELECT fname, lname
										FROM #application.database#.henkel_import_#thistable#
										WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectList.email#">
									</cfquery>
									<cfif GetFirstLast.recordcount GT 0>
										<cfif trim(GetFirstLast.fname) NEQ "">
											<cfset firstname = GetFirstLast.fname>
										</cfif>
										<cfif trim(GetFirstLast.lname) NEQ "">
											<cfset lastname = GetFirstLast.lname>
										</cfif>
									</cfif>
									<cfif firstname NEQ "" AND lastname NEQ "">
										<cfbreak>
									</cfif>
								</cfloop>
							</cfif>
						</cfif>
						<cfif awarded GT 0 OR redeemed GT 0>
							#SelectList.username#,#lastname#,#firstname#,#SelectList.email#,#awarded#,#redeemed##crlf#
							<cfset sub_awarded = sub_awarded + PosPoints.pos_pt>
							<cfset sub_redeemed = sub_redeemed + NegPoints.neg_pt>
							<cfset grand_awarded = grand_awarded + PosPoints.pos_pt>
							<cfset grand_redeemed = grand_redeemed + NegPoints.neg_pt>
						</cfif>
					</cfcase>
					<cfcase value="Lawson-lu">
						<cfif NOT ListFindNoCase(userList,SelectList.email)>
							<cfquery name="GetLoctiteU" datasource="#application.DS#">
								SELECT fname, lname, date_entered_2
								FROM #application.database#.henkel_import_lu
								WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectList.email#">
								<cfif this_year LT 3000>
									AND YEAR(date_entered_2) = '#this_year#'
								</cfif>
							</cfquery>
							<cfif GetLoctiteU.RecordCount GT 0>
								#SelectList.username#,#GetLoctiteU.lname#,#GetLoctiteU.fname#,#SelectList.email#,#DateFormat(GetLoctiteU.date_entered_2,"yyyy-mm-dd")##crlf#
							</cfif>
							<cfset userList = ListAppend(userList,SelectList.email)>
						</cfif>
					</cfcase>
					<cfcase value="Applied">
						<cfif NOT ListFindNoCase(userList,SelectList.email)>
							<cfquery name="GetLoctiteU" datasource="#application.DS#">
								SELECT fname, lname, date_entered_2
								FROM #application.database#.henkel_import_lu
								WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectList.email#">
								AND YEAR(date_entered_2) = '#this_year#'
								AND MONTH(date_entered_2) = '#this_month#'
							</cfquery>
							<cfif GetLoctiteU.RecordCount GT 0>
								#SelectList.username#,#GetLoctiteU.lname#,#GetLoctiteU.fname#,#SelectList.email#,#DateFormat(GetLoctiteU.date_entered_2,"yyyy-mm-dd")#,5#crlf#
							</cfif>
							<cfset userList = ListAppend(userList,SelectList.email)>
						</cfif>
					</cfcase>
				</cfswitch>
			</cfoutput>
			<cfif ListFindNoCase('Fastenal,Lawson-points,Erie,TAI',url.cn)>
				<cfoutput>,,,Total<cfif this_year LT 3000> for #this_year#</cfif>:,#sub_awarded#,#sub_redeemed##crlf#</cfoutput>
				<cfset sub_awarded = 0>
				<cfset sub_redeemed = 0>
			</cfif>
		</cfloop>
		</cfloop>
		<cfif ListFindNoCase('Fastenal,Lawson-points,Erie,TAI',url.cn)>
			<cfoutput>,,,Grand Total for #ListFirst(year_list)# through #ListLast(year_list)#:,#grand_awarded#,#grand_redeemed##crlf#</cfoutput>
		</cfif>
	<cfelse>
		<!--- ----------------------------- --->
		<!--- ---- New Form --------------- --->
		<!--- ----------------------------- --->
		<cfquery name="SelectList" datasource="#application.DS#">
			(
				SELECT ID, is_active, 'Active' AS username, fname, lname, email, 0 AS points, SUBSTR(email, INSTR(email, '@') + 1) AS domain
				FROM #application.database#.program_user
				WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
				AND is_active = 1
				<cfif form.distributor NEQ "all">
					AND SUBSTR(email, INSTR(email, '@') + 1) IN
					<cfswitch expression="#form.distributor#">
						<cfcase value="Applied">
							('applied.com', 'applied.com.mx', 'appliedcanada.com', 'appliedproducts.com')
						</cfcase>
						<cfcase value="Fastenal">
							('fastenal.com', 'fastenal.stores.com')
						</cfcase>
						<cfcase value="TAI">
							('taindustrial.com')
						</cfcase>
						
						<cfcase value="Lawson">
							('lawson.com', 'lawsonproduct.com', 'lawsonproducts.com', 'lawsonproductss.com')
						</cfcase>
						<cfcase value="Motion">
							('motion-ind.com')
						</cfcase>
						<cfdefaultcase>
							('')
						</cfdefaultcase>
					</cfswitch>
				</cfif>
			) UNION (
				SELECT 0 AS ID, 2 AS is_active, 'Pending' AS username, email as fname, 'n/a' as lname, email, sum(points) AS points, SUBSTR(email, INSTR(email, '@') + 1) AS domain
				FROM #application.database#.henkel_hold_user
				WHERE program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.henkel_ID#">
				<cfif form.distributor NEQ "all">
					AND SUBSTR(email, INSTR(email, '@') + 1) IN
					<cfswitch expression="#form.distributor#">
						<cfcase value="Applied">
							('applied.com', 'applied.com.mx', 'appliedcanada.com', 'appliedproducts.com')
						</cfcase>
						<cfcase value="Fastenal">
							('fastenal.com', 'fastenal.stores.com')
						</cfcase>
						<cfcase value="TAI">
							('taindustrial.com')
						</cfcase>
						<cfcase value="Lawson">
							('lawson.com', 'lawsonproduct.com', 'lawsonproducts.com', 'lawsonproductss.com')
						</cfcase>
						<cfcase value="Motion">
							('motion-ind.com')
						</cfcase>
						<cfdefaultcase>
							('')
						</cfdefaultcase>
					</cfswitch>
				</cfif>
				GROUP BY email
			)
			ORDER BY
			<cfif form.distributor EQ "all">
				domain,
			</cfif>
			is_active, fname, lname
		</cfquery>
		<!---<cfdump var="#SelectList#"><cfabort>--->
		<cfif form.school EQ "All">

	
	
	
			
		<cfset sub_awarded = 0>
		<cfset sub_redeemed = 0>
		<cfset grand_awarded = 0>
		<cfset grand_redeemed = 0>
		
		<cfoutput><cfif form.distributor EQ "all">Domain,</cfif>Status,Last Name,First Name,Email,Awarded,Redeemed#crlf#</cfoutput>
		<!---<cfloop from="#form.starting#" to="#form.ending#" index="this_year">--->
			<cfset userList = "">
			<cfoutput><cfif form.distributor NEQ "all">#form.distributor# </cfif><!---#this_year#--->#crlf#</cfoutput>
			<cfloop query="SelectList">
				<cfif SelectList.is_active EQ 1>
					<cfquery name="PosPoints" datasource="#application.DS#">
						SELECT IFNULL(SUM(points),0) AS pos_pt
						FROM #application.database#.awards_points
						WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
						AND is_defered = 0
						AND created_datetime BETWEEN <cfqueryparam value="#formatFromDate#"> AND <cfqueryparam value="#formatToDate#">
						<!--- AND created_datetime BETWEEN '2015-01-01 00:00:00' AND '2015-06-30 23:59:59'--->
						<!--- AND YEAR(created_datetime) = '#this_year#' --->
					</cfquery>
					<!--- look in the order database for orders/points_used --->
					<cfquery name="NegPoints" datasource="#application.DS#">
						SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) AS neg_pt, IFNULL(SUM(cc_charge),0) AS neg_cc
						FROM #application.database#.order_info
						WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SelectList.ID#">
						AND created_datetime BETWEEN <cfqueryparam value="#formatFromDate#"> AND <cfqueryparam value="#formatToDate#">
						<!--- AND created_datetime BETWEEN '2015-01-01 00:00:00' AND '2015-06-30 23:59:59'--->
						<!--- AND YEAR(created_datetime) = '#this_year#' --->
						AND is_valid = 1
					</cfquery>
				</cfif>
						<cfset awarded = 0>
						<cfset redeemed = 0>
						<cfif SelectList.is_active EQ 1>
							<cfset awarded = PosPoints.pos_pt>
							<cfset redeemed = NegPoints.neg_pt>
							<cfset firstname = SelectList.fname>
							<cfset lastname = SelectList.lname>
						<cfelse>
							<!---<cfset awarded = SelectList.points> This is only when not separating years--->
							<cfquery name="GetHoldPoints" datasource="#application.DS#">
								SELECT sum(points) AS points
								FROM #application.database#.henkel_hold_user
								WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectList.email#">
								AND created_datetime BETWEEN <cfqueryparam value="#formatFromDate#"> AND <cfqueryparam value="#formatToDate#">
								<!--- AND created_datetime BETWEEN '2015-01-01 00:00:00' AND '2015-06-30 23:59:59'--->
								<!--- AND YEAR(created_datetime) = '#this_year#' --->
								GROUP BY email
							</cfquery>
							<cfset firstname = "">
							<cfset lastname = "">
							<cfset awarded = GetHoldPoints.points>
							<cfif awarded GT 0>
								<cfloop list="lu,dts,jsc,mro_oem,dcse,leak" index="thistable">
									<cfquery name="GetFirstLast" datasource="#application.DS#">
										SELECT fname, lname
										FROM #application.database#.henkel_import_#thistable#
										WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectList.email#">
									</cfquery>
									<cfif GetFirstLast.recordcount GT 0>
										<cfif trim(GetFirstLast.fname) NEQ "">
											<cfset firstname = GetFirstLast.fname>
										</cfif>
										<cfif trim(GetFirstLast.lname) NEQ "">
											<cfset lastname = GetFirstLast.lname>
										</cfif>
									</cfif>
									<cfif firstname NEQ "" AND lastname NEQ "">
										<cfbreak>
									</cfif>
								</cfloop>
							</cfif>
						</cfif>
						<cfif awarded GT 0 OR redeemed GT 0>
							<cfoutput><cfif form.distributor EQ "all">#SelectList.domain#,</cfif>#SelectList.username#,#lastname#,#firstname#,#SelectList.email#,#awarded#,#redeemed##crlf#</cfoutput>
							<cfset sub_awarded = sub_awarded + awarded>
							<cfset sub_redeemed = sub_redeemed + redeemed>
							<cfset grand_awarded = grand_awarded + awarded>
							<cfset grand_redeemed = grand_redeemed + redeemed>
						</cfif>
			</cfloop>
				<cfoutput><cfif form.distributor EQ "all">,</cfif>,,,Total<!---<cfif this_year LT 3000> for #this_year#</cfif>--->:,#sub_awarded#,#sub_redeemed##crlf#</cfoutput>
				<cfset sub_awarded = 0>
				<cfset sub_redeemed = 0>
		<!---</cfloop>--->
			<cfoutput><cfif form.distributor EQ "all">,</cfif>,,,Grand Total for #FromDate# through #ToDate#:,#grand_awarded#,#grand_redeemed##crlf#</cfoutput>





		<cfelseif form.school EQ "lu">
			<cfoutput>Status,Last Name,First Name,Email,LU Date,Awarded#crlf#</cfoutput>
			<!---<cfloop from="#form.starting#" to="#form.ending#" index="this_year">--->
				<cfset userList = "">
				<cfoutput>#form.distributor# (Loctite University) <!---#this_year#--->#crlf#</cfoutput>
				<cfloop query="SelectList">
					<cfif NOT ListFindNoCase(userList,SelectList.email)>
						<cfquery name="GetLoctiteU" datasource="#application.DS#">
							SELECT fname, lname, MAX(date_entered_2) as latest, COUNT(id) AS num_times
							FROM #application.database#.henkel_import_lu
							WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SelectList.email#">
							AND date_entered_2 BETWEEN <cfqueryparam value="#formatFromDate#"> AND <cfqueryparam value="#formatToDate#">
							<!--- AND YEAR(date_entered_2) = '#this_year#' --->
							GROUP BY email
						</cfquery>
						<cfif GetLoctiteU.RecordCount GT 0>
							<cfoutput>#SelectList.username#,#GetLoctiteU.lname#,#GetLoctiteU.fname#,#SelectList.email#,#DateFormat(GetLoctiteU.latest,"yyyy-mm-dd")#,#GetLoctiteU.num_times*5##crlf#</cfoutput>
						</cfif>
						<cfset userList = ListAppend(userList,SelectList.email)>
					</cfif>
				</cfloop>
			<!---</cfloop>--->
		</cfif>
	</cfif>
</cfif>
<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->
