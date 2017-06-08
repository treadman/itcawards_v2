<cfsilent>

<cfif NOT CGI.SERVER_PORT_SECURE AND ( NOT isDefined("form.source") OR form.source NEQ "henkel" )>
	<cflocation url="https://#CGI.HTTP_HOST##CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#" addtoken="no">
</cfif>

<cfset CurrentPage = GetFileFromPath(GetBaseTemplatePath())>

<!--- <cfif cgi.remote_addr NEQ "10.0.0.83" AND CurrentPage NEQ "site_down.cfm">
	<cflocation url="/site_down.cfm" addtoken="false">
</cfif> --->

<cfapplication name="ITC Awards V2" applicationtimeout="#CreateTimeSpan(1, 0, 0, 0)#" sessionmanagement="yes">
	
<!--- Set application variables after server restart or application timeout --->
<cfif Not IsDefined("Application.Initialized") OR isDefined("url.init")>
	
	<cflock scope="application" type="exclusive" timeout="30">
		
		<cfset application.Initialized = true>
		<cfset Application.DevApp = false>

		<!--- Error handling --->
		<cfset Application.ErrorEmailSubject = "Error - " & Application.ApplicationName>
		<cfset Application.ErrorEmailTo = "treadmen@hotmail.com">
		<cfset Application.ErrorEmailBCC = "">

		<!--- Encryption/Hashing --->
		<cfset application.salt="ljS458lsel72g35kjhfg44DDwjohgjh8a0q332">
		
		<!--- TODO:  These should be in admin --->
		<cfset application.ITCAdminEmail = "lmene@itcsafety.com">
		<cfset application.AwardsProgramAdminName = "Alfred McNeill">
		<cfset application.AwardsProgramAdminEmail = "amcneill@itcawards.com">
		<cfset application.AwardsFromEmail = "orders@itcawards.com">

		<!--- Paths --->
		<cfset application.FilePath="/inetpub/wwwroot/content/htdocs/itcawards_v2/">
		<cfset application.AbsPath="/itcawards_v2/">
		<cfset application.AbsPathProdImages="/inetpub/wwwroot/content/htdocs/itcawards_v2/">
		<cfset application.WebPath="http://www2.itcawards.com">
		<cfset application.PlainURL="www2.itcawards.com">
		<cfset application.SecureWebPath="https://www2.itcawards.com">
		<cfset application.ComponentPath = "cfscripts.dfm_common.components">
		<cfset application.ProductImagePath="http://www2.itcawards.com/pics/products/">
		<cfset application.ManufLogoPath="http://www2.itcawards.com/pics/manuf_logos/">
		<cfset application.HenkelURL="http://henkel.itcawards.com">

		<!--- Database --->
		<cfset application.DS="DB">
		<cfset application.database="ITCAwards">
		<cfset application.product_database="ITCAwards">
		<cfset application.v3_database="ITCAwards_v3">

		<!--- Admin sessions --->
		<cfset application.AdminTimeout = "60">
			
		<!--- Misc. Variables--->
		<cfset application.x_login = "227itc19702">
		<cfset application.x_tran_key="3JkdpjvRy8ibPNju">
	</cflock>
	
</cfif>

<cferror type="validation" template="z_error_validation.cfm">
<cferror type="exception" template="z_error_exception.cfm" exception="any">
	
</cfsilent>