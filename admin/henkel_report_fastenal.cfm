<cfsetting enablecfoutputonly="true" requesttimeout="300">

<cfquery name="GetAll" datasource="#application.DS#">
	(
	SELECT 'Active' AS status, p.points, p.created_datetime, p.notes AS activity, u.fname, u.lname, u.email, CAST(u.created_datetime as char) as reg_date
	FROM ITCAwards.awards_points p
	LEFT JOIN ITCAwards.program_user u ON u.ID = p.user_ID
	WHERE u.program_ID = 1000000066
	AND u.email like '%fastenal%'
	AND	(
			p.created_datetime BETWEEN '2014-01-01' AND '2014-06-30'
		OR
			p.created_datetime BETWEEN '2015-01-01' AND '2015-06-30'
		)

	) UNION (

	SELECT 'Pending' AS status, p.points, p.created_datetime, p.source_import AS activity, '' AS fname, '' AS lname, p.email, '' as reg_date
	FROM ITCAwards.henkel_hold_user p
	WHERE p.program_ID = 1000000066
	AND p.email like '%fastenal%'
	AND	(
			p.created_datetime BETWEEN '2014-01-01' AND '2014-06-30'
		OR
			p.created_datetime BETWEEN '2015-01-01' AND '2015-06-30'
		)

	)

	ORDER BY created_datetime
</cfquery>
<!---<cfdump var="#GetAll#"><cfabort>--->
<cfoutput>Status,Type,Registered,Last Name,First Name,Email,Awarded,JAN-MAR 14 PTs Awarded,JAN-MAR 15 PTs Awarded,JAN-MAR Percent Change,APR-JUN 14 PTs Awarded,APR-JUN 15 PTs Awarded,APR-JUN Percent Change,Awarded<br></cfoutput>
<!---<cfset cnt=0>--->
<cfloop query="GetAll">

	<cfset this_activity = trim(Replace(GetAll.activity, "#chr(13)##chr(10)#", " ", "ALL"))>

	<!---<cfset show_debug = false>
	<cfif not ListFind("Automatically awarded from Henkel import file - Distributor Training School,Distributor Training School,Points Awarded for Distributor Training per Dave Carbone 3/18,Points Awarded for Joint Sales per Dave Carbone 3/18,Points added from duplicate account (txarl@stores.fastenal.com) per Linda,Consolidated Points to duplicate account (mware@fastenal.com) per Linda,10 points for registering Points awarded out of hold: 5 points for Joint Sales Call 40 points for MRO OEM,Manual Upload of Double Points for Fastenal Jan-March 2015 - Points doubled for 3/10 Joint Sales Upload,Manual Upload for Double Points for Fastenal Jan-March 2015 - Points doubled for 3/10 Joint Sales Upload,10 points for registering Points awarded out of hold: 25 points for MRO OEM,Manual Upload for Double Points for Fastenal for Jan-March 2015 - Points doubled for 3/10 Joint Sales Upload,Manual Upload for Double Points for Fastenal Jan-March 2015 for 3/10 Joint Sales Upload,Manual Upload for Double Points for Fastenal - Jan through March 2015,10 points for registering Points awarded out of hold: 10 points for Joint Sales Call 20 points for Joint Sales Call,10 points for registering Points awarded out of hold: 15 points for MRO OEM,10 points for registering Points awarded out of hold: 15 points for MRO OEM,10 points for registering Points awarded out of hold: 10 points for Joint Sales Call 10 points for Joint Sales Call,Points awarded out of hold: 130 points for MRO OEM,Transferred into account under tmiggins@fastenal.com,Transferred from account under txho5@stores.fastenal.com,10 points for registering Points awarded out of hold: 15 points for MRO OEM,10 points for registering Points awarded out of hold: 35 points for Joint Sales Call,10 points for registering Points awarded out of hold: 30 points for Joint Sales Call,10 points for registering Points awarded out of hold: 50 points for MRO OEM,10 points for registering Points awarded out of hold: 40 points for MRO OEM,10 points for registering Points awarded out of hold: 20 points for Joint Sales Call,10 points for registering Points awarded out of hold: 15 points for Joint Sales Call,2013 Pro of the Year Award,10 points for registering Points awarded out of hold: 5 points for Joint Sales Call,10 points for registering Points awarded out of hold: 15 points for Joint Sales Call 20 points for Joint Sales Call,10 points for registering Points awarded out of hold: 5 points for Joint Sales Call,Points awarded out of hold: 5 points for Joint Sales Call 5 points for Joint Sales Call 5 points for Joint Sales Call,MRO w/ 20+ heads per David Carbone,Joint Sales Call per David Carbone,Automatically awarded from Henkel import file - Loctite University,10 points for registering Points awarded out of hold: 10 points for Joint Sales Call,Automatically awarded from Henkel import file - Joint Sales Call,Automatically awarded from Henkel import file - MRO OEM,10 points for registering Points awarded out of hold: 5 points for Joint Sales Call 15 points for MRO OEM,Joint Sales Call,MRO OEM,10 points for registering,Approved in admin from Henkel registration form - 10 for registering",this_activity)>
		<cfset show_debug = true> 
		<cfoutput>{#GetAll.status# - #GetAll.email#} #this_activity#<br></cfoutput>
		<cfoutput><pre>#GetAll.activity#</pre><br></cfoutput>
	</cfif>
	<cfif cnt GT 15>
		<cfoutput><br><br>aborted run</cfoutput><cfabort>
	</cfif>--->

	<!--- -------------------------- --->
	<cfif GetAll.status EQ "Pending">
	<!--- -------------------------- --->

		<cfset this_last = "">
		<cfset this_first = "">
		<cfset this_table = "">
		<cfswitch expression="#this_activity#">
			<cfcase value="MRO OEM">
				<cfset this_table = "henkel_import_mro_oem">
			</cfcase>
			<cfcase value="Joint Sales Call">
				<cfset this_table = "henkel_import_jsc">
			</cfcase>
			<cfcase value="Distributor Training School">
				<cfset this_table = "henkel_import_dts">
			</cfcase>
			<cfcase value="2013 Pro of the Year Award">
			</cfcase>
			<cfdefaultcase>
				<cfoutput>#this_activity# not set up.</cfoutput><cfabort>
			</cfdefaultcase>
		</cfswitch>
		<cfif this_table NEQ "">
			<cfquery name="GetUser" datasource="#application.DS#">
				SELECT fname, lname
				FROM ITCAwards.#this_table#
				WHERE email = '#GetAll.email#'
			</cfquery>
			<cfif GetUser.recordcount GT 0>
				<cfloop query="GetUser">
					<cfif this_last EQ "">
						<cfset this_last = GetUser.lname>
					</cfif>
					<cfif this_first EQ "">
						<cfset this_first = GetUser.fname>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<cfoutput>#GetAll.status#,#this_activity#,,#this_last#,#this_first#,#GetAll.email#,#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#,#parsePoints(GetAll.created_datetime,GetAll.points)#</cfoutput>
		<cfoutput><br></cfoutput>
	<!--- -------------------------- --->
	<cfelseif GetAll.status EQ "Active">
	<!--- -------------------------- --->

<!---
	<br><br>
	<cfoutput>#this_activity#</cfoutput>
<br><br>
	<cfoutput><pre>#this_activity#</pre></cfoutput>
<br><br>
	<cfoutput>#htmlcodeformat(this_activity)#</cfoutput>
<br><br>
	<cfloop from="1" to="#len(this_activity)#" index="x">
		<cfset thisChar = mid(this_activity,x,1)>
		<cfoutput>#thisChar# = #ASC(thisChar)#<br></cfoutput>
	</cfloop>
	done parse<br>
<cfabort>

--->


		<cfloop condition = "Len(trim(this_activity)) GT 0">
			<cfset did_it = false>


			<cfset test = "10 points for registering">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = trim(mid(this_activity,len(test)+1,99999))>
			</cfif>

			<cfset test = "Approved in admin from Henkel registration form - 10 for registering">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = trim(mid(this_activity,len(test)+1,99999))>
			</cfif>


			<cfset test = "3/18">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = "">
			</cfif>
			<cfset test = "Transferred">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = "">
			</cfif>
			<cfset test = "Consolidated Points to duplicate account">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = "">
			</cfif>
			<cfset test = "Manual Upload for Double Points">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = "">
			</cfif>
			<cfset test = "Manual Upload of Double Points">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = "">
			</cfif>
			<cfset test = "Points added from duplicate account">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = "">
			</cfif>

			<cfset test = "Joint Sales Call per David Carbone">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = trim(mid(this_activity,len(test)+1,99999))>
				<cfoutput>#GetAll.status#,Joint Sales Call,#DateFormat(GetAll.reg_date,'mm-dd-yyyy')#,#GetAll.lname#,#GetAll.fname#,#GetAll.email#,#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#,#parsePoints(GetAll.created_datetime,GetAll.points)#</cfoutput>
				<cfoutput><br></cfoutput>
			</cfif>
			<cfset test = "Points Awarded for Joint Sales per Dave Carbone">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = trim(mid(this_activity,len(test)+1,99999))>
				<cfoutput>#GetAll.status#,Joint Sales Call,#DateFormat(GetAll.reg_date,'mm-dd-yyyy')#,#GetAll.lname#,#GetAll.fname#,#GetAll.email#,#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#,#parsePoints(GetAll.created_datetime,GetAll.points)#</cfoutput>
				<cfoutput><br></cfoutput>
			</cfif>
			<cfset test = "Points Awarded for Distributor Training per Dave Carbone">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = trim(mid(this_activity,len(test)+1,99999))>
				<cfoutput>#GetAll.status#,Distributor Training School,#DateFormat(GetAll.reg_date,'mm-dd-yyyy')#,#GetAll.lname#,#GetAll.fname#,#GetAll.email#,#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#,#parsePoints(GetAll.created_datetime,GetAll.points)#</cfoutput>
				<cfoutput><br></cfoutput>
			</cfif>

			<cfset test = "MRO w/ 20+ heads per David Carbone">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = trim(mid(this_activity,len(test)+1,99999))>
				<cfoutput>#GetAll.status#,MRO OEM,#DateFormat(GetAll.reg_date,'mm-dd-yyyy')#,#GetAll.lname#,#GetAll.fname#,#GetAll.email#,#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#,#parsePoints(GetAll.created_datetime,GetAll.points)#</cfoutput>
				<cfoutput><br></cfoutput>
			</cfif>


			<cfset test = "Automatically awarded from Henkel import file">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfoutput>#GetAll.status#,#trim(ListGetAt(this_activity,2,'-'))#,#DateFormat(GetAll.reg_date,'mm-dd-yyyy')#,#GetAll.lname#,#GetAll.fname#,#GetAll.email#,#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#,#parsePoints(GetAll.created_datetime,GetAll.points)#</cfoutput>
				<cfoutput><br></cfoutput>
				<!---<cfif not ListFind("Distributor Training School,Loctite University,Joint Sales Call,MRO OEM",trim(ListGetAt(this_activity,2,'-')))>
					<cfoutput><br>look at this some more #this_activity#</cfoutput><cfabort>
				</cfif>--->
				<cfset this_activity = "">
			</cfif>
				
			<cfset test = "Points awarded out of hold:">
			<cfif left(this_activity,len(test)) EQ test>
				<cfset did_it = true>
				<cfset this_activity = trim(mid(this_activity,len(test)+1,99999))>
				<cfset note_list = "">
				<cfset this_note = "">
				<cfloop list="#this_activity#" delimiters=" " index="x">
					<cfif isNumeric(x)>
						<cfif this_note NEQ "">
							<cfset note_list = ListAppend(note_list,this_note)>
							<cfset this_note = "">
						</cfif>
					</cfif>
					<cfset this_note = ListAppend(this_note,x," ")>
				</cfloop>
				<cfif this_note NEQ "">
					<cfset note_list = ListAppend(note_list,this_note)>
					<cfset this_note = "">
				</cfif>
				<cfif note_list NEQ "">
					<cfloop list="#note_list#" index="y">
						<cfset this_points = ListFirst(y," ")>
						<cfset y = ListDeleteAt(y,1," ")>
						<cfset y = ListDeleteAt(y,1," ")>
						<cfset y = ListDeleteAt(y,1," ")>
						<cfset this_activity = trim(y)> 

						<cfoutput>#GetAll.status#,#this_activity#,#DateFormat(GetAll.reg_date,'mm-dd-yyyy')#,#GetAll.lname#,#GetAll.fname#,#GetAll.email#,#DateFormat(GetAll.created_datetime,'mm-dd-yyyy')#,#parsePoints(GetAll.created_datetime,this_points)#</cfoutput>
						<cfoutput><br></cfoutput>

					</cfloop>
				</cfif>
				<cfset this_activity = "">
			</cfif>
			<cfif not did_it>
				<cfoutput>"#this_activity#" cannot be tested.</cfoutput><cfabort>
			</cfif> 
		</cfloop>

	<!--- -------------------------- --->
	<cfelse>
	<!--- -------------------------- --->
		<cfoutput>#GetAll.status# not a valid status.</cfoutput><cfabort>
	</cfif>
	<!---<cfif show_debug>
		<cfset cnt = cnt + 1>
	</cfif>--->
</cfloop>

<!---<cfoutput><br><br>end of run</cfoutput><cfabort>--->


<!---
<cfquery name="GetDTS" datasource="#application.DS#">
SELECT fname, lname, email, 'DTS' AS type
FROM ITCAwards.henkel_import_dts
WHERE program_ID = 1000000066
AND email like '%fastenal%'
ORDER BY email
</cfquery>

<cfquery name="GetJSC" datasource="#application.DS#">
SELECT fname, lname, email, 'JSC' AS type
FROM ITCAwards.henkel_import_jsc
WHERE program_ID = 1000000066
AND email like '%fastenal%'
ORDER BY email
</cfquery>

<cfquery name="GetLU" datasource="#application.DS#">
SELECT fname, lname, email, 'LU' AS type
FROM ITCAwards.henkel_import_lu
WHERE program_ID = 1000000066
AND email like '%fastenal%'
ORDER BY email
</cfquery>

<cfquery name="GetMRO" datasource="#application.DS#">
SELECT fname, lname, email, 'MRO' AS type
FROM ITCAwards.henkel_import_mro_oem
WHERE program_ID = 1000000066
AND email like '%fastenal%'
ORDER BY email
</cfquery>
--->

<!---<cfoutput>Status,Type, Last Name,First Name,Email,JAN-MAR 14 PTs Awarded,JAN-MAR 15 PTs Awarded, JAN-MAR Percent Change,APR-JUN 14 PTs Awarded,APR-JUN 15 PTs Awarded, APR-JUN Percent Change<br></cfoutput>
<cfloop list="dts,jsc,lu,mro_oem" index="this_activity" >
	<cfset this_year = 2014>
	<cfset this_month = 1>
	<cfoutput>Activity: #UCase(ListFirst(this_activity,'_'))#<br></cfoutput>
	<cfquery name="GetActivity" datasource="#application.DS#">
		SELECT DISTINCT email
		FROM ITCAwards.henkel_import_#this_activity#
		WHERE program_ID = 1000000066
		AND email like '%fastenal%'
		AND date_processed > '2014-01-01'
		ORDER BY email
	</cfquery>
	<cfloop query="GetActivity" >
		<cfset this_status = "">
		<cfquery name="GetActive" datasource="#application.DS#">
			SELECT fname, lname, email
			FROM ITCAwards.program_user
			WHERE program_ID = 1000000066
			AND is_active = 1
			AND email = '#GetActivity.email#'
		</cfquery>
		<cfif GetActive.recordcount GT 0>
			<cfset this_status = "Active">
		<cfelse>
			<cfquery name="GetPending" datasource="#application.DS#">
				SELECT email
				FROM ITCAwards.henkel_hold_user
				WHERE email = '#GetActivity.email#'
			</cfquery>
			<cfif GetPending.recordcount GT 0>
				<cfset this_status = "Pending">
			</cfif>
		</cfif>
		<cfif this_status NEQ "">
			<cfset awarded = StructNew()>
			<cfset awarded[2014] = StructNew()>
			<cfset awarded[2014][1] = 0>
			<cfset awarded[2014][2] = 0>
			<cfset awarded[2014][3] = 0>
			<cfset awarded[2014][4] = 0>
			<cfset awarded[2014][5] = 0>
			<cfset awarded[2014][6] = 0>
			<cfset awarded[2015] = StructNew()>
			<cfset awarded[2015][1] = 0>
			<cfset awarded[2015][2] = 0>
			<cfset awarded[2015][3] = 0>
			<cfset awarded[2015][4] = 0>
			<cfset awarded[2015][5] = 0>
			<cfset awarded[2015][6] = 0>
			<cfset this_ID = GetAll.ID>
			<cfset this_status = GetAll.status>
			<cfset this_type = GetAll.type>
			<cfset this_lname = GetAll.lname>
			<cfset this_fname = GetAll.fname>
			<cfset this_email = GetAll.email>
			<cfloop from="2014" to="2015" index="this_year">
				<cfloop from="1" to="6" index="this_month">
					<cfswitch expression="#this_activity#" >
						<cfcase value="mro_oem">
							<cfquery name="GetList" datasource="#application.DS#">
								SELECT i.ID, i.idh, i.fname, i.lname, i.email, i.date_entered_2,
									SUM((SELECT IFNULL(MAX(p.points),0) AS points_awarded
									FROM #application.database#.henkel_points_lookup p
									WHERE i.program_type = p.program_type AND p.minimum <= i.count)) AS awarded_points
								FROM #application.database#.henkel_import_mro_oem i
								WHERE i.program_ID = <cfqueryparam value="#request.henkel_ID#" cfsqltype="CF_SQL_INTEGER" maxlength="10">
								AND i.date_processed IS NULL
								GROUP BY i.email
							</cfquery>
						</cfcase>
					</cfswitch>
				</cfloop>
			</cfloop>
			<cfset total_awarded = 0>
			<cfloop from="2014" to="2015" index="this_year">
				<cfloop from="1" to="6" index="this_month">
					<cfset total_awarded = total_awarded + awarded[this_year][this_month]>
				</cfloop>
			</cfloop>
	
			<cfif total_awarded GT 0>
	
				<cfoutput>#this_status#,#this_type#,#this_lname#,#this_fname#,#this_email#,</cfoutput>
	
				<cfset this1 = awarded[2014][1] + awarded[2014][2] + awarded[2014][3]>
				<cfset this2 = awarded[2015][1] + awarded[2015][2] + awarded[2015][3]>
				<cfset sign = "+">
				<cfset diff = this2-this1>
				<cfif diff LT 0>
					<cfset sign = "-">
				</cfif>
				<cfif this1 GT 0>
					<cfset pct = int(abs(diff)/this1)*100>
				<cfelseif this2 GT 0>
					<cfset sign = "+">
					<cfset pct = "100">
				<cfelse>
					<cfset sign = "">
					<cfset pct = "0">
				</cfif>
				<cfoutput>#this1#,#this2#,#sign##pct#,</cfoutput>
	
				<cfset this1 = awarded[2014][4] + awarded[2014][5] + awarded[2014][6]>
				<cfset this2 = awarded[2015][4] + awarded[2015][5] + awarded[2015][6]>
				<cfset sign = "+">
				<cfset diff = this2-this1>
				<cfif diff LT 0>
					<cfset sign = "-">
				</cfif>
				<cfif this1 GT 0>
					<cfset pct = int(abs(diff)/this1)*100>
				<cfelseif this2 GT 0>
					<cfset sign = "+">
					<cfset pct = "100">
				<cfelse>
					<cfset sign = "">
					<cfset pct = "0">
				</cfif>
				<cfoutput>#this1#,#this2#,#sign##pct#<br></cfoutput>
			</cfif>
		</cfif>
	</cfloop>
</cfloop>
--->


<!---  This gets all the fastenal email address in active and hold:

<cfquery name="GetAll" datasource="#application.DS#">
	(
		SELECT email,'Active' AS status
		FROM ITCAwards.program_user
		WHERE program_ID = 1000000066
		AND is_active = 1
		AND email like '%fastenal%'
		
	) UNION (

		SELECT email,'Pending' AS status
		FROM ITCAwards.henkel_hold_user
		WHERE program_ID = 1000000066
		AND email like '%fastenal%'

	)
ORDER BY email
</cfquery>--->


<!---

<cfoutput>Status,Type, Last Name,First Name,Email,JAN-MAR 14 PTs Awarded,JAN-MAR 15 PTs Awarded, JAN-MAR Percent Change,APR-JUN 14 PTs Awarded,APR-JUN 15 PTs Awarded, APR-JUN Percent Change<br></cfoutput>

<cfset this_year = 2014>
<cfset this_month = 1>
<cfloop query="GetAll" >
	
		<cfset awarded = StructNew()>
		<cfset awarded[2014] = StructNew()>
		<cfset awarded[2014][1] = 0>
		<cfset awarded[2014][2] = 0>
		<cfset awarded[2014][3] = 0>
		<cfset awarded[2014][4] = 0>
		<cfset awarded[2014][5] = 0>
		<cfset awarded[2014][6] = 0>
		<cfset awarded[2015] = StructNew()>
		<cfset awarded[2015][1] = 0>
		<cfset awarded[2015][2] = 0>
		<cfset awarded[2015][3] = 0>
		<cfset awarded[2015][4] = 0>
		<cfset awarded[2015][5] = 0>
		<cfset awarded[2015][6] = 0>
		<cfset this_ID = GetAll.ID>
		<cfset this_status = GetAll.status>
		<cfset this_type = GetAll.type>
		<cfset this_lname = GetAll.lname>
		<cfset this_fname = GetAll.fname>
		<cfset this_email = GetAll.email>
		<cfloop from="2014" to="2015" index="this_year">
			<cfloop from="1" to="6" index="this_month">
				<cfif this_status EQ "Active">
					<cfquery name="GetTotalAwarded" datasource="#application.DS#">
						SELECT SUM(points) AS points_awarded
						FROM ITCAwards.awards_points
						WHERE user_id = #this_ID#
						AND YEAR(created_datetime) = '#this_year#'
						AND MONTH(created_datetime) = '#this_month#'
						GROUP BY user_ID
					</cfquery>
					<cfif GetTotalAwarded.recordcount EQ 1>
						<cfset awarded[this_year][this_month] = GetTotalAwarded.points_awarded>
					</cfif>
				<cfelseif this_status EQ "Pending">
					<cfquery name="GetTotalAwarded" datasource="#application.DS#">
						SELECT points AS points_awarded
						FROM ITCAwards.henkel_hold_user
						WHERE email = '#this_email#'
						AND YEAR(created_datetime) = '#this_year#'
						AND MONTH(created_datetime) = '#this_month#'
					</cfquery>
					<cfif GetTotalAwarded.recordcount EQ 1>
						<cfset awarded[this_year][this_month] = GetTotalAwarded.points_awarded>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		<cfset total_awarded = 0>
		<cfloop from="2014" to="2015" index="this_year">
			<cfloop from="1" to="6" index="this_month">
				<cfset total_awarded = total_awarded + awarded[this_year][this_month]>
			</cfloop>
		</cfloop>

		<cfif total_awarded GT 0>

			<cfoutput>#this_status#,#this_type#,#this_lname#,#this_fname#,#this_email#,</cfoutput>

			<cfset this1 = awarded[2014][1] + awarded[2014][2] + awarded[2014][3]>
			<cfset this2 = awarded[2015][1] + awarded[2015][2] + awarded[2015][3]>
			<cfset sign = "+">
			<cfset diff = this2-this1>
			<cfif diff LT 0>
				<cfset sign = "-">
			</cfif>
			<cfif this1 GT 0>
				<cfset pct = int(abs(diff)/this1)*100>
			<cfelseif this2 GT 0>
				<cfset sign = "+">
				<cfset pct = "100">
			<cfelse>
				<cfset sign = "">
				<cfset pct = "0">
			</cfif>
			<cfoutput>#this1#,#this2#,#sign##pct#,</cfoutput>

			<cfset this1 = awarded[2014][4] + awarded[2014][5] + awarded[2014][6]>
			<cfset this2 = awarded[2015][4] + awarded[2015][5] + awarded[2015][6]>
			<cfset sign = "+">
			<cfset diff = this2-this1>
			<cfif diff LT 0>
				<cfset sign = "-">
			</cfif>
			<cfif this1 GT 0>
				<cfset pct = int(abs(diff)/this1)*100>
			<cfelseif this2 GT 0>
				<cfset sign = "+">
				<cfset pct = "100">
			<cfelse>
				<cfset sign = "">
				<cfset pct = "0">
			</cfif>
			<cfoutput>#this1#,#this2#,#sign##pct#<br></cfoutput>

		</cfif>

</cfloop>

<cfdump var="#GetAll#">
<cfabort>

--->




<!---

<cfquery name="GetAll" datasource="#application.DS#">
<!---(

SELECT ID, lname, fname, email, 'Active' AS status, 'User' AS type
FROM ITCAwards.program_user
WHERE program_ID = 1000000066
AND is_active = 1
AND email like '%fastenal%'

) UNION (--->

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'DTS' AS type
FROM ITCAwards.henkel_import_dts
WHERE program_ID = 1000000066
AND email like '%fastenal%'

) UNION (

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'JSC' AS type
FROM ITCAwards.henkel_import_jsc
WHERE program_ID = 1000000066
AND email like '%fastenal%'

) UNION (

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'LU' AS type
FROM ITCAwards.henkel_import_lu
WHERE program_ID = 1000000066
AND email like '%fastenal%'

) UNION (

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'MRO' AS type
FROM ITCAwards.henkel_import_mro_oem
WHERE program_ID = 1000000066
AND email like '%fastenal%'

)
ORDER BY email, status, lname, fname

</cfquery>
<cfoutput>Status,Type, Last Name,First Name,Email,JAN-MAR 14 PTs Awarded,JAN-MAR 15 PTs Awarded, JAN-MAR Percent Change,APR-JUN 14 PTs Awarded,APR-JUN 15 PTs Awarded, APR-JUN Percent Change<br></cfoutput>
<cfset old_email = "FIRST_TIME">
<cfset this_year = 2014>
<cfset this_month = 1>
<cfloop query="GetAll" >
	<cfif GetAll.email NEQ old_email>
		<cfset awarded = StructNew()>
		<cfset awarded[2014] = StructNew()>
		<cfset awarded[2014][1] = 0>
		<cfset awarded[2014][2] = 0>
		<cfset awarded[2014][3] = 0>
		<cfset awarded[2014][4] = 0>
		<cfset awarded[2014][5] = 0>
		<cfset awarded[2014][6] = 0>
		<cfset awarded[2015] = StructNew()>
		<cfset awarded[2015][1] = 0>
		<cfset awarded[2015][2] = 0>
		<cfset awarded[2015][3] = 0>
		<cfset awarded[2015][4] = 0>
		<cfset awarded[2015][5] = 0>
		<cfset awarded[2015][6] = 0>
		<cfset this_ID = GetAll.ID>
		<cfset this_status = GetAll.status>
		<cfset this_type = GetAll.type>
		<cfset this_lname = GetAll.lname>
		<cfset this_fname = GetAll.fname>
		<cfset this_email = GetAll.email>
		<cfloop from="2014" to="2015" index="this_year">
			<cfloop from="1" to="6" index="this_month">
				<cfif this_status EQ "Active">
					<cfquery name="GetTotalAwarded" datasource="#application.DS#">
						SELECT SUM(points) AS points_awarded
						FROM ITCAwards.awards_points
						WHERE user_id = #this_ID#
						AND YEAR(created_datetime) = '#this_year#'
						AND MONTH(created_datetime) = '#this_month#'
						GROUP BY user_ID
					</cfquery>
					<cfif GetTotalAwarded.recordcount EQ 1>
						<cfset awarded[this_year][this_month] = GetTotalAwarded.points_awarded>
					</cfif>
				<cfelseif this_status EQ "Pending">
					<cfquery name="GetTotalAwarded" datasource="#application.DS#">
						SELECT SUM(points) AS points_awarded
						FROM ITCAwards.henkel_hold_user
						WHERE email = '#this_email#'
						AND YEAR(created_datetime) = '#this_year#'
						AND MONTH(created_datetime) = '#this_month#'
						GROUP BY email
					</cfquery>
					<cfif GetTotalAwarded.recordcount EQ 1>
						<cfset awarded[this_year][this_month] = GetTotalAwarded.points_awarded>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		<cfset total_awarded = 0>
		<cfloop from="2014" to="2015" index="this_year">
			<cfloop from="1" to="6" index="this_month">
				<cfset total_awarded = total_awarded + awarded[this_year][this_month]>
			</cfloop>
		</cfloop>

		<cfif total_awarded GT 0>

			<cfoutput>#this_status#,#this_type#,#this_lname#,#this_fname#,#this_email#,</cfoutput>

			<cfset this1 = awarded[2014][1] + awarded[2014][2] + awarded[2014][3]>
			<cfset this2 = awarded[2015][1] + awarded[2015][2] + awarded[2015][3]>
			<cfset sign = "+">
			<cfset diff = this2-this1>
			<cfif diff LT 0>
				<cfset sign = "-">
			</cfif>
			<cfif this1 GT 0>
				<cfset pct = int(abs(diff)/this1)*100>
			<cfelseif this2 GT 0>
				<cfset sign = "+">
				<cfset pct = "100">
			<cfelse>
				<cfset sign = "">
				<cfset pct = "0">
			</cfif>
			<cfoutput>#this1#,#this2#,#sign##pct#,</cfoutput>

			<cfset this1 = awarded[2014][4] + awarded[2014][5] + awarded[2014][6]>
			<cfset this2 = awarded[2015][4] + awarded[2015][5] + awarded[2015][6]>
			<cfset sign = "+">
			<cfset diff = this2-this1>
			<cfif diff LT 0>
				<cfset sign = "-">
			</cfif>
			<cfif this1 GT 0>
				<cfset pct = int(abs(diff)/this1)*100>
			<cfelseif this2 GT 0>
				<cfset sign = "+">
				<cfset pct = "100">
			<cfelse>
				<cfset sign = "">
				<cfset pct = "0">
			</cfif>
			<cfoutput>#this1#,#this2#,#sign##pct#<br></cfoutput>

		</cfif>
	</cfif>
	<cfset old_email = GetAll.email>
</cfloop>
--->





<!---

<cfset this_year = 2015>
<cfquery name="GetAll" datasource="#application.DS#">
(

SELECT ID, lname, fname, email, 'Active' AS status, 'User' AS type
FROM ITCAwards.program_user
WHERE program_ID = 1000000066
AND is_active = 1
AND email like '%fastenal%'

) UNION (

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'DTS' AS type
FROM ITCAwards.henkel_import_dts
WHERE program_ID = 1000000066
AND email like '%fastenal%'

) UNION (

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'JSC' AS type
FROM ITCAwards.henkel_import_jsc
WHERE program_ID = 1000000066
AND email like '%fastenal%'

) UNION (

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'LU' AS type
FROM ITCAwards.henkel_import_lu
WHERE program_ID = 1000000066
AND email like '%fastenal%'

) UNION (

SELECT 0 as ID, lname, fname, email, 'Pending' AS status, 'MRO' AS type
FROM ITCAwards.henkel_import_mro_oem
WHERE program_ID = 1000000066
AND email like '%fastenal%'

)
ORDER BY email, status, lname, fname

</cfquery>
<cfoutput>Status,Last Name,First Name,Email,JAN PTs Awarded,FEB PTs Awarded,MAR PTs Awarded,APR PTs Awarded,MAY PTs Awarded,JUN PTs Awarded,JUL PTs Awarded,AUG PTs Awarded,SEPT PTs Awarded,OCT PTs Awarded,NOV PTs Awarded,DEC PTs Awarded,TOTAL REDEEMED in #this_year#<br></cfoutput>
<cfset old_email = "FIRST_TIME">
<cfloop query="GetAll" >
	<cfif GetAll.email NEQ old_email>
		<cfset total_awarded = 0>
		<cfset total_redeemed = 0>
		<cfset this_ID = GetAll.ID>
		<cfset this_status = GetAll.status>
		<cfset this_lname = GetAll.lname>
		<cfset this_fname = GetAll.fname>
		<cfset this_email = GetAll.email>
		<cfif this_status EQ "Active">
			<cfquery name="GetTotalAwarded" datasource="#application.DS#">
				SELECT SUM(points) AS points_awarded
				FROM ITCAwards.awards_points
				WHERE user_id = #this_ID#
				AND YEAR(created_datetime) = '#this_year#'
				GROUP BY user_ID
			</cfquery>
			<cfif GetTotalAwarded.recordcount EQ 1>
				<cfset total_awarded = GetTotalAwarded.points_awarded>
			</cfif>
			<cfquery name="GetTotalRedeemed" datasource="#application.DS#">
				SELECT SUM(points_used) AS points_redeemed
				FROM ITCAwards.order_info
				WHERE is_valid=1
				AND created_user_ID = #this_ID#
				AND YEAR(created_datetime) = '#this_year#'
				GROUP BY created_user_ID
			</cfquery>
			<cfif GetTotalRedeemed.recordcount EQ 1>
				<cfset total_redeemed = GetTotalRedeemed.points_redeemed>
			</cfif>
		<cfelseif this_status EQ "Pending">
			<cfquery name="GetTotalAwarded" datasource="#application.DS#">
				SELECT SUM(points) AS points_awarded
				FROM ITCAwards.henkel_hold_user
				WHERE email = '#this_email#'
				AND YEAR(created_datetime) = '#this_year#'
				GROUP BY email
			</cfquery>
			<cfif GetTotalAwarded.recordcount EQ 1>
				<cfset total_awarded = GetTotalAwarded.points_awarded>
			</cfif>
		</cfif>
		<cfif total_awarded GT 0 OR total_redeemed GT 0>
			<cfoutput>#this_status#,#this_lname#,#this_fname#,#this_email#,</cfoutput>
			<cfif this_status EQ "Active">
				<cfloop from="1" to="12" index="this_month">
					<cfset total_month = 0>
					<cfquery name="GetTotalAwarded" datasource="#application.DS#">
						SELECT SUM(points) AS points_awarded
						FROM ITCAwards.awards_points
						WHERE user_id = #this_ID#
						AND YEAR(created_datetime) = '#this_year#'
						AND MONTH(created_datetime) = '#this_month#'
						GROUP BY user_ID
					</cfquery>
					<cfif GetTotalAwarded.recordcount EQ 1>
						<cfset total_month = GetTotalAwarded.points_awarded>
					</cfif>
					<cfoutput>#total_month#,</cfoutput>
				</cfloop>
			<cfelseif this_status EQ "Pending">
				<cfloop from="1" to="12" index="this_month">
					<cfset total_month = 0>
					<cfquery name="GetTotalAwarded" datasource="#application.DS#">
						SELECT SUM(points) AS points_awarded
						FROM ITCAwards.henkel_hold_user
						WHERE email = '#this_email#'
						AND YEAR(created_datetime) = '#this_year#'
						AND MONTH(created_datetime) = '#this_month#'
						GROUP BY email
					</cfquery>
					<cfif GetTotalAwarded.recordcount EQ 1>
						<cfset total_month = GetTotalAwarded.points_awarded>
					</cfif>
					<cfoutput>#total_month#,</cfoutput>
				</cfloop>
			</cfif>
			<cfoutput>#total_redeemed#<br></cfoutput>
		</cfif>
	</cfif>
	<cfset old_email = GetAll.email>
</cfloop>
--->

<cffunction name="parsePoints" output="true">
	<cfargument name="created_date">
	<cfargument name="award_points">
	<cfset var this_date = DateFormat(arguments.created_date,'mmyy')>
	<cfset var this_points = arguments.award_points>
	<cfif ListFind("0114,0214,0314",this_date)>
		<cfoutput>#this_points#</cfoutput>
	</cfif>
	<cfoutput>,</cfoutput>
	<cfif ListFind("0115,0215,0315",this_date)>
		<cfoutput>#this_points#</cfoutput>
	</cfif>
	<cfoutput>,</cfoutput>
	<cfoutput>,</cfoutput>
	<cfif ListFind("0414,0514,0614",this_date)>
		<cfoutput>#this_points#</cfoutput>
	</cfif>
	<cfoutput>,</cfoutput>
	<cfif ListFind("0415,0515,0615",this_date)>
		<cfoutput>#this_points#</cfoutput>
	</cfif>
	<cfoutput>,</cfoutput>
	<cfoutput>,</cfoutput>
	<cfoutput>#DateFormat(arguments.created_date,'mm-yy')#</cfoutput>
</cffunction>
