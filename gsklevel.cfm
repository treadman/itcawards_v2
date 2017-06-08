<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link rel="shortcut icon" href="/favicon.ico" />
<title>Untitled Document</title>
</head>

<body>

<cfquery name="Winners" datasource="xfer">
	SELECT *
	FROM #application.database#.GSK_2005_winners
</cfquery>

<cfloop query="Winners">
	<cfquery name="CheckIfInTable" datasource="xfer">
		SELECT *
		FROM #application.database#.GSK_userdb
		WHERE gsk_id = '#Winners.gsk_id#'
	</cfquery>
	<cfif CheckIfInTable.RecordCount GT 0>
		<cfquery name="UpdatePoints" datasource="xfer">
			UPDATE #application.database#.GSK_userdb SET
			award_amt = #Winners.award_amt#
			WHERE gsk_id = '#Winners.gsk_id#'
		</cfquery>
	<cfelse>
		<cfquery name="AwardPoints" datasource="xfer">
			INSERT INTO #application.database#.GSK_userdb
			(gsk_id, fname, lname, email, phone_day, defered, award_amt)
			VALUES
			('#Winners.gsk_id#', '#Winners.fname#', '#Winners.lname#', '#Winners.email#', '#Winners.phone_day#', 0, #Winners.award_amt#)
		</cfquery>
	</cfif>
</cfloop>

</body>
</html>
