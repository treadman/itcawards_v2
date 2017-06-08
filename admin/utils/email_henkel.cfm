<cfsetting enablecfoutputonly="yes" showdebugoutput="no">
<cfif isDefined("form.submit") AND form.emailText NEQ "">
	<cfset thisText = Replace(form.emailText,"#CHR(13)##CHR(10)#"," <br> ","ALL")>
	<!--- <cfoutput>#thisText#<br /><br /></cfoutput> --->
	<cfset thisPhrase = "">
	<cfset getNext = "">
	<cfset getActivity = false>
	<cfset email = "">
	<cfset ccemail = "">
	<cfset username = "">
	<cfset fname = "">
	<cfset lname = "">
	<cfset points = 0>
	<cfset activity = "">
	<cfset template_ID = 0>
	<cfif thisText CONTAINS "we have just posted points to your account">
		<cfset template_ID = 49>
	<cfelseif thisText CONTAINS "you have earned Henkel Rewards Board points based">
		<cfset template_ID = 50>
	<cfelse>
		<cfoutput>INVALID EMAIL!!!</cfoutput>
		<cfabort>
	</cfif>
	<cfloop list="#thisText#" delimiters=" " index="thisWord">
		<cfif getActivity AND template_ID EQ 49 AND thisWord EQ "Click">
			<cfset activity = Replace(thisPhrase,"<br> <br> <br>","<br>")>
			<cfset thisPhrase = "">
			<cfset getActivity = false>
		<cfelseif getActivity AND template_ID EQ 50 AND thisWord EQ "However,">
			<cfset activity = Replace(thisPhrase,"<br> <br> <br>","")>
			<cfset thisPhrase = "">
			<cfset getActivity = false>
		</cfif>
		<cfset thisPhrase = ListAppend(thisPhrase,thisWord," ")>
		<cfif getNext NEQ "">
		 	<cfswitch expression="#getNext#">
				<cfcase value="email">
					<cfset email = thisWord>
				</cfcase>
				<cfcase value="ccemail">
					<cfif thisWord NEQ "<br>">
						<cfset ccemail = thisWord>
					</cfif>
				</cfcase>
				<cfcase value="fname">
					<cfset fname = thisWord>
				</cfcase>
				<cfcase value="lname">
					<cfset lname = thisWord>
				</cfcase>
				<cfcase value="points">
					<cfset points = thisWord>
				</cfcase>
				<cfcase value="username">
					<cfset username = thisWord>
				</cfcase>
				<cfdefaultcase>
					<cfoutput>Unknown getNext: #getNext#</cfoutput>
					<cfabort>
				</cfdefaultcase>
			</cfswitch>
			<cfset thisPhrase = "">
			<cfif getNext EQ "fname">
				<cfset getNext = "lname">
			<cfelse>
				<cfset getNext = "">
			</cfif>
		</cfif>
		<cfif thisPhrase EQ "TESTING FOR EXISTING USERS AND BRANCH LEADERS: <br> Would have gone to">
			<cfset getNext = "email">
		<cfelseif thisPhrase EQ "<br> CC would have gone to">
			<cfset getNext = "ccemail">
		<cfelseif thisPhrase CONTAINS "9/24/2008 <br> <br>">
			<cfset getNext = "fname">
		<cfelseif thisPhrase CONTAINS "Number of Points Earned:">
			<cfset getNext = "points">
		<cfelseif thisPhrase CONTAINS "Valued Selling Activity:">
			<cfset getActivity = true>
			<cfset thisPhrase = "">
		<cfelseif thisPhrase CONTAINS "Enter Password:">
			<cfset getNext = "username">
		</cfif>
		<cfif getNext NEQ "">
			<cfset thisPhrase = "">
		</cfif>
	</cfloop>
	<cfoutput>
	Email: #email#<br />
	CC Email: #ccemail#<br />
	Username: #username#<br />
	First: #fname#<br />
	Last: #lname#<br />
	Points: #points#<br />
	Activity: #activity#
	Template: #template_ID#<br />
	</cfoutput>
	<cfquery name="getTemplate" datasource="#application.DS#">
		SELECT email_text
		FROM #application.database#.email_templates
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#template_ID#">
	</cfquery>
	<cfset user_email_text = getTemplate.email_text>
	<cfset user_email_text = Replace(user_email_text,"USER-NAME",username,"all")>
	<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",fname,"all")>
	<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",lname,"all")>
	<cfset user_email_text = Replace(user_email_text,"DATE-TODAY","9/24/2008","all")>
	<cfset user_email_text = Replace(user_email_text,"USER-POINTS-EARNED",points,"all")>
	<cfset user_email_text = Replace(user_email_text,"VALUED-SELLING-ACTIVITY",activity,"all")>
	<cfif ccemail NEQ "">
	<cfmail failto="#Application.ErrorEmailTo#" to="#email#" cc="#ccemail#" from="#application.AwardsFromEmail#" subject="Henkel Rewards Board Valued Selling" type="html">
#user_email_text#
		</cfmail>
	<cfelse>
	<cfmail failto="#Application.ErrorEmailTo#" to="#email#" from="#application.AwardsFromEmail#" subject="Henkel Rewards Board Valued Selling" type="html">
#user_email_text#
		</cfmail>
	</cfif>
	<cfoutput><br />Email sent!<br /><br /></cfoutput>
</cfif>
<cfoutput>
<form method="post">
	<textarea name="emailText" cols="78" rows="13"></textarea><br>
	<input type="submit" name="submit" value="  Submit  ">
</form>
</cfoutput>