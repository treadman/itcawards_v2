<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Award Email Sample</title>
</head>

<body>

<cfoutput>

		<!--- get a user's information --->
		<cfquery name="SelectUserInfo" datasource="#application.DS#">
			SELECT ID AS program_user_ID, fname, lname
			FROM #application.database#.program_user
			WHERE program_ID = 1000000009
			LIMIT 1,1
		</cfquery>
		<!--- set vars --->
		<cfset program_user_ID = HTMLEditFormat(SelectUserInfo.program_user_ID)>
		<cfset fname = HTMLEditFormat(SelectUserInfo.fname)>
		
		#ProgramUserInfo(program_user_ID)#

		<!--- get program information  --->
		<cfquery name="SelectProgramInfo" datasource="#application.DS#">
			SELECT company_name, logo, credit_desc, login_prompt
			FROM #application.database#.program
			WHERE ID = 1000000009
		</cfquery>
		
		<!--- set vars --->
		<cfset company_name = HTMLEditFormat(SelectProgramInfo.company_name)>
		<cfset logo = HTMLEditFormat(SelectProgramInfo.logo)>
		<cfset credit_desc = HTMLEditFormat(SelectProgramInfo.credit_desc)>
		<cfset login_prompt = HTMLEditFormat(SelectProgramInfo.login_prompt)>
	
		<!--- get the logo --->
		<cfif logo NEQ "">
			<cfset vLogo = HTMLEditFormat(logo)>
		<cfelse>
			<cfset vLogo = "shim.gif">
		</cfif>
				
		<cfinclude template="program_award_email.txt">
	
</cfoutput>

</body>
</html>
