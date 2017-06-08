
			<cfcookie name="itc_program" expires="now" value="">
			<cfcookie name="itc_pid" expires="now" value="">
			<cfcookie name="itc_user" expires="now" value="">
			<cfcookie name="itc_order" expires="now" value="">
			<cfcookie name="itc_survey" expires="now" value="">
			<cfcookie name="itc_userwelcome" expires="now" value="">
			<cfcookie name="itc_SAdemo" expires="now" value="">
			
			<cfcookie name="admin_login" expires="now" value="">

			<cfif IsDefined('url.survey') AND url.survey IS NOT "">
				<cflocation addtoken="no" url="survey_thanks.cfm">
			<cfelse>
				<cflocation addtoken="no" url="index.cfm">
			</cfif>