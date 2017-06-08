<cfparam name="ex_first" default="">
<cfparam name="ex_last" default="">
<cfparam name="ex_user" default="">
<cfparam name="ex_points" default="">
<cfparam name="ex_activity" default="">
<cfparam name="pe_first" default="">
<cfparam name="pe_last" default="">
<cfparam name="pe_user" default="">
<cfparam name="pe_points" default="">
<cfparam name="pe_activity" default="">
<cfparam name="bl_first" default="">
<cfparam name="bl_last" default="">
<cfparam name="bl_participant" default="">
<cfparam name="bl_points" default="">
<cfparam name="bl_activity" default="">
<cfparam name="bp_first" default="">
<cfparam name="bp_last" default="">
<cfparam name="bp_leader" default="">
<cfparam name="bp_user" default="">
<cfparam name="bp_points" default="">
<cfparam name="bp_activity" default="">
<cfif isDefined("form.test_email")>
	<cfif trim(form.emailTo) NEQ "" AND FLGen_IsValidEmail(form.emailTo)>
		<cfset user_email_text = ex_email_text>
		<cfset user_email_text = Replace(user_email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",ex_first,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",ex_last,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-NAME",ex_user,"all")>
		<cfset user_email_text = Replace(user_email_text,"USER-POINTS-EARNED",ex_points,"all")>
		<cfset user_email_text = Replace(user_email_text,"VALUED-SELLING-ACTIVITY","<br>"&ex_activity,"all")>
		<cfmail to="#form.emailTo#" from="#form.emailFrom#" subject="#form.emailSubject# - Existing User" type="html">
#user_email_text#
		</cfmail>
		<cfif NOT request.selected_henkel_program.is_registration_closed>
			<cfset user_email_text = pe_email_text>
			<cfset user_email_text = Replace(user_email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",pe_first,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",pe_last,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-NAME",pe_user,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-POINTS-EARNED",pe_points,"all")>
			<cfset user_email_text = Replace(user_email_text,"VALUED-SELLING-ACTIVITY","<br>"&pe_activity,"all")>
			<cfmail to="#form.emailTo#" from="#form.emailFrom#" subject="#form.emailSubject# - Pending User" type="html">
#user_email_text#
			</cfmail>
		</cfif>
		<cfif request.selected_henkel_program.has_branch_participation>
			<cfset user_email_text = bl_email_text>
			<cfset user_email_text = Replace(user_email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",bl_first,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",bl_last,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-NAME",bl_user,"all")>
			<cfset user_email_text = Replace(user_email_text,"BRANCH-PARTICIPANT",bl_participant,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-POINTS-EARNED",bl_points,"all")>
			<cfset user_email_text = Replace(user_email_text,"VALUED-SELLING-ACTIVITY","<br>"&bl_activity,"all")>
			<cfmail to="#form.emailTo#" from="#form.emailFrom#" subject="#form.emailSubject# - Branch Leader" type="html">
#user_email_text#
			</cfmail>
			<cfset user_email_text = bp_email_text>
			<cfset user_email_text = Replace(user_email_text,"DATE-TODAY",DateFormat(Now(),'m/d/yyyy'),"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-FIRST-NAME",bp_first,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-LAST-NAME",bp_last,"all")>
			<cfset user_email_text = Replace(user_email_text,"PARTICIPANT-LEADER",bp_leader,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-NAME",bp_user,"all")>
			<cfset user_email_text = Replace(user_email_text,"USER-POINTS-EARNED",bp_points,"all")>
			<cfset user_email_text = Replace(user_email_text,"VALUED-SELLING-ACTIVITY","<br>"&bp_activity,"all")>
			<cfmail to="#form.emailTo#" from="#form.emailFrom#" subject="#form.emailSubject# - Branch Participant" type="html">
#user_email_text#
			</cfmail>
		</cfif>
	<cfelse>
		<span class="alert">Please enter a test email address.</span><br /><br />
	</cfif>
</cfif>