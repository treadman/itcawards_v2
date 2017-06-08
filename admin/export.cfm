<cfsetting requesttimeout="600" showdebugoutput="no">
<!---<cfset ftp_server = "65.182.222.162">--->
<!--- <cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm"> --->

<!--- ***************** --->
<!--- page variables    --->
<!--- ***************** --->
<cfset Q = '"'> <!--- Tab Char --->
<cfset QCQ = '","'> <!--- Tab Char --->
<cfset Blank = ''> <!--- Blank Char --->
<cfset NL = Chr(13) & Chr(10)> <!--- New Line --->
<!---<cfset ScratchFilePath = '/inetpub/wwwroot/scratch/'>--->
<cfset ScratchFilePath = '/inetpub/wwwroot/content/htdocs/itcawards_v2/henkel/reports/'>
<cfset OutString = "">

<!--- ----------------------------------------------------------- --->
<!--- ----------------------------------------------------------- --->
<!--- ANAEROBICS  From henkel-branch-registrations-export.cfm     --->
<!--- ----------------------------------------------------------- --->
<!--- ----------------------------------------------------------- --->

<!--- <cfquery name="branch_registrations" datasource="#application.DS#">
	SELECT r.ID, r.created_datetime, r.branch_email, r.branch_contact_fname, r.branch_contact_lname,
		r.branch_phone, r.company_name, r.branch_address, r.branch_city, r.branch_state, r.branch_zip,
		p.program_name, u.idh, u.registration_type, r.branch_reps, r.py_sales, r.jan_sales, r.feb_sales,
		r.mar_sales, r.apr_sales, r.may_sales, r.jun_sales, r.jul_sales, r.aug_sales, r.sep_sales,
		r.oct_sales, r.nov_sales, r.dec_sales, r.py_sales * 1.05 AS proj_sales,
		(r.jan_sales + r.feb_sales + r.mar_sales + r.apr_sales + r.may_sales + r.jun_sales + r.jul_sales +
			r.aug_sales + r.sep_sales + r.oct_sales + r.nov_sales + r.dec_sales) AS cy_sales,
		( 	SELECT SUM(points)
			FROM #application.database#.awards_points a
			WHERE a.user_ID = r.program_user_ID	) AS total_points
	FROM #application.database#.henkel_register_branch r
	LEFT JOIN #application.database#.program p ON r.program_ID = p.ID
	LEFT JOIN #application.database#.program_user u ON r.program_user_ID = u.ID
 	WHERE r.program_ID = <cfqueryparam value="1000000066" cfsqltype="CF_SQL_INTEGER">
	GROUP BY r.ID
	ORDER BY r.created_datetime
</cfquery>

<cfset OutString = '"Date Registered","IDH","Registration Type","Current Points","Email Address","First Name","Last Name","Phone","Company","Address","City","State","Zip Code","Program","Branch Reps","Prior Year","Projected","Current Year","Percent Met","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"' & NL>
<cfloop query="branch_registrations">
	<cfset PercentMet = "0%">
	<cfif proj_sales GT 0><cfif cy_sales GT 0><cfset PercentMet = "#round(cy_sales / proj_sales * 100)#%"></cfif></cfif>
	<cfset OutString = OutString & Q & DateFormat(created_datetime,'yyyy-mm-dd') & QCQ & idh & QCQ & registration_type & QCQ & total_points & QCQ & branch_email & QCQ & branch_contact_fname & QCQ & branch_contact_lname & QCQ & branch_phone & QCQ & company_name & QCQ & branch_address & QCQ & branch_city & QCQ & branch_state & QCQ & branch_zip & QCQ & program_name & QCQ & branch_reps & QCQ & py_sales & QCQ & round(proj_sales) & QCQ & cy_sales & QCQ & PercentMet & QCQ & jan_sales & QCQ & feb_sales & QCQ & mar_sales & QCQ & apr_sales & QCQ & may_sales & QCQ & jun_sales & QCQ & jul_sales & QCQ & aug_sales & QCQ & sep_sales & QCQ & oct_sales & QCQ & nov_sales & QCQ & dec_sales & Q & NL>
</cfloop>
<cffile action = "write" file = "#ScratchFilePath#us_anaerobics.csv" output="#OutString#">
<cfftp action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath#us_anaerobics.csv" remotefile="us_anaerobics.csv" transfermode="AUTO">
 --->
<!--- <cffile action="delete" file="#ScratchFilePath#us_anaerobics.csv"> --->

<cfquery name="GetHenkelPrograms" datasource="#application.DS#">
	SELECT program_ID, filename_extension
	FROM #application.database#.program_henkel
	WHERE do_report_export = 1 AND filename_extension != ''
</cfquery>

<cfloop query="GetHenkelPrograms">

	<!--- ----------------------------------------------------------- --->
	<!--- ----------------------------------------------------------- --->
	<!--- BRANCH REPORT   From henkel_report_branch.cfm               --->
	<!--- ----------------------------------------------------------- --->
	<!--- ----------------------------------------------------------- --->

	<!--- <cfquery name="GetList" datasource="#application.DS#">
		SELECT DISTINCT PU.idh, CONCAT(HD.company_name, ", ", HD.city, ", ", HD.state) AS Branch, PU.registration_type,
				CONCAT(PU.lname, ", ", PU.fname) AS Registrant, PU.email, HR.alternate_emails
		FROM #application.database#.program_user PU
		LEFT JOIN #application.database#.henkel_distributor HD ON PU.idh = HD.idh
		LEFT JOIN #application.database#.henkel_register HR ON PU.email = HR.email
		WHERE PU.program_ID = <cfqueryparam value="#GetHenkelPrograms.program_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10"> AND PU.idh > '' and PU.idh != '##N/A'
		ORDER BY HD.company_name, PU.idh, PU.registration_type, Registrant
	</cfquery>
	<cfset OutString = '"IDH","Branch","Registered as","Registrant","Email","Other Emails"' & NL>
	<cfoutput query="GetList">
		<cfset OutString = OutString & Q & idh & QCQ & Branch & QCQ & registration_type & QCQ & Registrant & QCQ & email & QCQ & alternate_emails & Q & NL>
	</cfoutput>
	<cffile action = "write" file = "#ScratchFilePath##GetHenkelPrograms.filename_extension#_branch_report.csv" output="#OutString#">
	 --->

	<!--- ----------------------------------------------------------- --->
	<!--- ----------------------------------------------------------- --->
	<!--- EXPORT REGISTRATIONS   From henkel_registrations-export.cfm --->
	<!--- ----------------------------------------------------------- --->
	<!--- ----------------------------------------------------------- --->
	<cfquery name="registrations" datasource="#application.DS#">
		SELECT u.ID, DATE_FORMAT(u.created_datetime,'%Y-%m-%d') AS created_date, u.email, u.fname, u.lname, u.phone, u.ship_company AS company,
			u.ship_address1 AS address1, u.ship_city AS city, u.ship_state AS state, u.ship_zip AS zip,
			r.region, p.program_name, r.alternate_emails,
			u.idh, u.registration_type, t.region AS henkel_region, t.division, t.grp, t.ty,
			t.fname AS terr_fname, t.lname AS terr_lname, t.email AS terr_email,
			(
				SELECT SUM(points)
				FROM #application.database#.awards_points a
				WHERE a.user_ID = u.ID
			) AS total_points
		FROM #application.database#.program_user u
		LEFT JOIN #application.database#.henkel_register r ON u.ID = r.program_user_ID
		LEFT JOIN #application.database#.program p ON u.program_ID = p.ID
		LEFT JOIN #application.database#.henkel_territory t ON CONCAT('00',r.region) = t.sap_ty AND u.program_ID = t.program_ID
		WHERE u.program_ID = <cfqueryparam value="#GetHenkelPrograms.program_ID#" cfsqltype="CF_SQL_INTEGER">
		AND u.registration_type <> 'BranchHQ'
		GROUP BY u.ID
		ORDER BY u.created_datetime
	</cfquery>
	<cfquery name="branch_registrations" datasource="#application.DS#">
		SELECT u.ID, DATE_FORMAT(u.created_datetime,'%Y-%m-%d') AS created_date, r.branch_email, r.branch_contact_fname, r.branch_contact_lname,
			r.branch_phone, r.company_name, r.branch_address, r.branch_city, r.branch_state, r.branch_zip,
			p.program_name, u.idh, u.registration_type,
			(
				SELECT SUM(points)
				FROM #application.database#.awards_points a
				WHERE a.user_ID = r.program_user_ID
			) AS total_points
		FROM #application.database#.henkel_register_branch r
		LEFT JOIN #application.database#.program_user u ON r.program_user_ID = u.ID
		LEFT JOIN #application.database#.program p ON u.program_ID = p.ID
		WHERE u.program_ID = <cfqueryparam value="#GetHenkelPrograms.program_ID#" cfsqltype="CF_SQL_INTEGER">
		AND u.registration_type <> 'BranchHQ'
		GROUP BY u.ID
		ORDER BY u.created_datetime
	</cfquery>

	<cffile action="write" addnewline="yes" file="#ScratchFilePath##GetHenkelPrograms.filename_extension#_registrations_export.csv" output='"Date Registered","IDH","Registration Type","Current Points","Email Address","First Name","Last Name","Phone","Company","Address","City","State","Zip Code","Region Code (sap_ty)","Region","Rep First Name","Rep Last Name","Rep Email","Division","Group","ty","Program","Branch Participants"'>
	<cfloop query="registrations">
		<cffile action="append" addnewline="yes" file="#ScratchFilePath##GetHenkelPrograms.filename_extension#_registrations_export.csv" output='"#created_date#","#idh#","#registration_type#","#total_points#","#email#","#fname#","#lname#","#phone#","#company#","#address1#","#city#","#state#","#zip#","#region#","#henkel_region#","#terr_fname#","#terr_lname#","#terr_email#","#division#","#grp#","#ty#","#program_name#","#alternate_emails#"'>
	</cfloop>
	<cfloop query="branch_registrations">
		<cffile action="append" addnewline="yes" file="#ScratchFilePath##GetHenkelPrograms.filename_extension#_registrations_export.csv" output='"#created_date#","#idh#","#registration_type#","#total_points#","#branch_email#","#branch_contact_fname#","#branch_contact_lname#","#branch_phone#","#company_name#","#branch_address#","#branch_city#","#branch_state#","#branch_zip#","","","","","","","","","#program_name#",""'>
	</cfloop>

	<!--- ----------------------- --->
	<!--- ----------------------- --->
	<!--- FTP FILES               --->
	<!--- ----------------------- --->
	<!--- ----------------------- --->
	<!--- <cfftp action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath##GetHenkelPrograms.filename_extension#_branch_report.csv" remotefile="#GetHenkelPrograms.filename_extension#_branch_report.csv" transfermode="AUTO"> --->
	<!---<cfftp connection="itcawards" action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath##GetHenkelPrograms.filename_extension#_registrations_export.csv" remotefile="#GetHenkelPrograms.filename_extension#_registrations_export.csv" transfermode="AUTO">--->

	<!--- --------------------------------------- --->
	<!--- --------------------------------------- --->
	<!--- DELETE TEMPORARY FILES                  --->
	<!--- --------------------------------------- --->
	<!--- --------------------------------------- --->
	<!--- <cffile action="delete" file="#ScratchFilePath##GetHenkelPrograms.filename_extension#_branch_report.csv">
	<cffile action="delete" file="#ScratchFilePath##GetHenkelPrograms.filename_extension#_registrations_export.csv"> --->

</cfloop>


<!--- Possible summary file: <cffile action = "write" file = "#ScratchFilePath#summary.txt" output="#thisSummary#"> --->
<!--- <cffile action="delete" file="#ScratchFilePath#summary.txt"> --->



<!--- UNUSED REPORTS: --->

<!--- ---------------------------------------------------- --->
<!--- ---------------------------------------------------- --->
<!--- BILLING REPORT   From henkel_report_billing.cfm      --->
<!--- ---------------------------------------------------- --->
<!--- ---------------------------------------------------- --->
<!--- <cfquery name="FindAllUsers" datasource="#application.DS#">
	SELECT DISTINCT u.fname, u.lname, u.ID, u.nickname, u.idh, u.email
	FROM #application.database#.program_user u
	JOIN #application.database#.order_info o ON o.created_user_ID = u.ID
	WHERE u.program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GetHenkelPrograms.program_ID#" maxlength="10">
		AND o.order_number > 0
		AND o.is_valid = 1
	<!---	AND o.created_datetime >= <cfqueryparam value="#formatFromDate#">
		AND o.created_datetime <= <cfqueryparam value="#formatToDate#"> --->
	ORDER BY u.lname ASC 
</cfquery>

<!---	
<cfquery name="UpdateRecord" datasource="#application.DS#">
	UPDATE #application.database#.app_member SET
		IsExported = 1
	WHERE IsExported = 0
</cfquery>
--->	
<cfset OutString = '"Name","Email","Loctite Rep","Company","Points Awarded","Points Used","Points Remaining","Last Order","Orders"' & NL>
<cfloop query="FindAllUsers">
	<cfset fname = FindAllUsers.fname>
	<cfset lname = FindAllUsers.lname>
	<cfset ID = FindAllUsers.ID>
	<cfset nickname = FindAllUsers.nickname>
	<cfset idh = FindAllUsers.idh>
	<cfset email = FindAllUsers.email>
	<cfset thisCompanyInfo = "">
	<cfset thisLoctiteRep = "">
	<cfif isNumeric(idh)>
		<cfquery name="getCompany" datasource="#application.DS#">
			SELECT company_name, address1, city, state, zip
			FROM #application.database#.henkel_distributor
			WHERE idh = <cfqueryparam cfsqltype="cf_sql_varchar" value="#idh#">
		</cfquery>
		<cfif getCompany.recordcount EQ 1>
			<cfset thisCompanyInfo = "#getCompany.company_name#, #getCompany.address1#, #getCompany.city#, #getCompany.state# #getCompany.zip#">
			<cfquery name="getRegion" datasource="#application.DS#">
				SELECT region
				FROM #application.database#.xref_zipcode_region
				WHERE zipcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getCompany.zip#">
			</cfquery>
			<cfif getRegion.recordcount GT 0>
				<cfquery name="getTerritory" datasource="#application.DS#">
					SELECT fname, lname
					FROM #application.database#.henkel_territory
					WHERE sap_ty = <cfqueryparam cfsqltype="cf_sql_varchar" value="00#getRegion.region#">
				</cfquery>
				<cfif getTerritory.recordcount GT 0>
					<cfset thisLoctiteRep = getTerritory.fname & " " & getTerritory.lname>
				<cfelse>
					<cfset thisLoctiteRep = "Territory Not Found">
				</cfif>
			<cfelse>
				<cfset thisLoctiteRep = "Region Not Found">
			</cfif>
		<cfelse>
			<cfset thisLoctiteRep = "No Distributor for IDH">
		</cfif>
	<cfelse>
		<cfset thisLoctiteRep = "No IDH number">
	</cfif>
	<cfquery name="getOrders" datasource="#application.DS#">
		SELECT ID, created_user_ID, created_datetime, order_number, points_used, cc_charge
		FROM #application.database#.order_info
		WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
			AND is_valid = 1
			<!--- AND created_datetime >= <cfqueryparam value="#formatFromDate#">
			AND created_datetime <= <cfqueryparam value="#formatToDate#"> --->
		ORDER BY created_datetime DESC
	</cfquery>
	<cfset ProgramUserInfoConstrained(ID)><!--- ,formatFromDate,formatToDate --->
	<cfset thisName = "#lname#, #fname#">
	<cfif nickname NEQ ""><cfset thisName = thisName & " (#nickname#)"></cfif>
	<cfset theseOrders = "">
	<cfif getOrders.recordcount GT 0>
		<cfloop query="getOrders">
			<cfif isNumeric(getOrders.points_used) and getOrders.points_used GT 0>
				<cfset theseOrders = "Order #getOrders.order_number# - #dateFormat(getOrders.created_datetime,"mm/dd/yyyy")# - #getOrders.points_used# points">
				<cfif isNumeric(getOrders.cc_charge) AND getOrders.cc_charge GT 0>
					 <cfset theseOrders = theseOrders & "#DollarFormat(getOrders.cc_charge)# charged">
				</cfif>
				<cfquery name="getItems" datasource="#application.DS#">
					SELECT quantity, snap_meta_name, snap_productvalue, snap_options
					FROM #application.database#.inventory
					WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getOrders.ID#">
				</cfquery>
				<cfif getItems.recordcount GT 0>
					<cfloop query="getItems">
						<cfset theseOrders = theseOrders & "#getItems.quantity# #getItems.snap_meta_name# #getItems.snap_options# (#DollarFormat(getItems.snap_productvalue)# value)">
					</cfloop>
				<cfelse>
					<cfset theseOrders = theseOrders & "NO LINE ITEMS FOUND!">
				</cfif>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset theseOrders = "NO ORDERS FOUND"><!--- This should never happen --->
	</cfif>
	<cfset OutString = OutString & Q & thisName & QCQ & email & QCQ & thisLoctiteRep & QCQ & thisCompanyInfo & QCQ & BRp_pospoints & QCQ & BRp_negpoints & QCQ & BRp_totalpoints & QCQ & BRp_last_order & QCQ & theseOrders & Q & NL>
</cfloop>

<cffile action = "write" file = "#ScratchFilePath##GetHenkelPrograms.filename_extension#_billing_report.csv" output="#OutString#"> --->


<!---
<!--- ---------------------------------------------------- --->
<!--- ---------------------------------------------------- --->
<!--- POINTS REPORT    From henkel_report_points.cfm       --->
<!--- ---------------------------------------------------- --->
<!--- ---------------------------------------------------- --->
<cfquery name="GetList" datasource="#application.DS#">
	SELECT CONCAT(HR.lname, ", ", HR.fname) AS fullname, IDH, PU.ID, HR.registration_type AS registration_type, IF (PU.ID > 0, "Active", "Pending") AS CurrentStatus,
	  IFNULL((SELECT SUM(points)
	   FROM #application.database#.awards_points AP
	   WHERE AP.user_ID = PU.ID),10) AS AwardedPoints
	FROM #application.database#.henkel_register HR
	LEFT JOIN #application.database#.program_user PU ON PU.ID = HR.program_user_ID
	WHERE HR.program_ID = <cfqueryparam value="#GetHenkelPrograms.program_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	
	UNION
	
	SELECT CONCAT(HR.branch_contact_lname, ", ", HR.branch_contact_fname) AS fullname, IDH, PU.ID, "BranchHQ" AS registration_type, IF (PU.ID > 0, "Active", "Pending") AS CurrentStatus,
	  IFNULL((SELECT SUM(points)
	   FROM #application.database#.awards_points AP
	   WHERE AP.user_ID = PU.ID),0) AS AwardedPoints
	FROM #application.database#.henkel_register_branch HR
	LEFT JOIN #application.database#.program_user PU ON PU.ID = HR.program_user_ID
	WHERE HR.program_ID = <cfqueryparam value="#GetHenkelPrograms.program_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
	
	ORDER BY registration_type, CurrentStatus, fullname
</cfquery>

<cfset OutString = '"Name","IDH","Registration Type","Points","Status"' & NL>

<cfoutput query="GetList">
	<cfset OutString = OutString & Q & fullname & QCQ & IDH & QCQ & registration_type & QCQ & AwardedPoints & QCQ & CurrentStatus & Q & NL>
</cfoutput>
<cffile action = "write" file = "#ScratchFilePath##GetHenkelPrograms.filename_extension#_points_report.csv" output="#OutString#">

--->

	<!--- <cfftp action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath#billing_report_us.csv" remotefile="billing_report_us.csv" transfermode="AUTO">
	<cfftp action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath#billing_report_ca.csv" remotefile="billing_report_ca.csv" transfermode="AUTO">
	<cfftp action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath#points_report_us.csv" remotefile="points_report_us.csv" transfermode="AUTO">
	<cfftp action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath#points_report_ca.csv" remotefile="points_report_ca.csv" transfermode="AUTO"> --->
	<!--- <cfftp action="putfile" server="#ftp_server#" stoponerror="no" passive="yes" username="henkel" password="43nkel" localfile="#ScratchFilePath#summary.txt" remotefile="summary.txt" transfermode="AUTO"> --->
	<!--- <cffile action="delete" file="#ScratchFilePath#billing_report_us.csv">
	<cffile action="delete" file="#ScratchFilePath#billing_report_ca.csv">
	<cffile action="delete" file="#ScratchFilePath#points_report_us.csv">
	<cffile action="delete" file="#ScratchFilePath#points_report_ca.csv"> --->
