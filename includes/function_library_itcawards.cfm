<!--- 

Functions in this library

 * GetProgramInfo(ProgramID)
 * ADMIN_GetProgramInfo(ProgramID)
 * ProgramUserInfo(UserID)
 * AuthenticateProgramUserCookie()
 * CartItemCount()
 
 	write the survey cookie on the page before the survey
	delete the order/user cookie on the survey page
	
 * CustomerSurvey()
 * ProcessCustomerSurvey()
 * WriteSurveyCookie()
 * AuthenticateSurveyCookie()
 * PhysicalInvCalc()
 * FindProductOptions()
 * FLITC_GetProgramName(program_ID)

FOR ADMIN SITE

 * AuthenticateAdmin(string)
 * HasAdminAccess(string)
 * FLGen_UpdateModConcatSQL()
 * FLGen_DisplayModConcat()
 * HasLevel(string,string)
 * SelectPVMaster(string,[string])
 * SelectProgram()
 * FLITC_Show_Delete_Admin_User()

 --->


<!---
 * GetProgramInfo()
 * 
 * checks the program cookie, grabs program info and puts in vars 
 --->

<cffunction name="GetProgramInfo" output="false">

<cfif IsDefined('cookie.itc_pid') AND cookie.itc_pid IS NOT "">
	<!--- check itc_pid hash --->
	<cfif FLGen_CreateHash(ListGetAt(cookie.itc_pid,1,"-")) EQ ListGetAt(cookie.itc_pid,2,"-")>
		<cfset program_ID = ListGetAt(cookie.itc_pid,1,"-")>
		<!--- get program information  --->
		<cfquery name="SelectProgramInfo" datasource="#application.DS#">
			SELECT company_name, program_name, IF(is_one_item=1,"true","false") AS is_one_item, IF(can_defer=1,"true","false") AS can_defer, defer_msg, welcome_bg, welcome_instructions, welcome_message, welcome_congrats, welcome_button, welcome_admin_button, admin_logo, default_category, logo, cross_color, main_bg, main_congrats, main_instructions, return_button, text_active, bg_active, text_selected, bg_selected, cart_exceeded_msg, cc_exceeded_msg, cc_max_default, orders_to, orders_from, conf_email_text, program_email_subject , IF(has_survey=1,"true","false") AS has_survey, display_col, display_row, menu_text, credit_desc, accepts_cc, login_prompt, display_welcomeyourname, display_youhavexcredits, credit_multiplier, points_multiplier, additional_content_button, additional_content_message, additional_content2_button, additional_content2_message, email_form_button, email_form_message, email_form_recipient, help_button, help_message, use_master_categories, has_welcomepage
			FROM #application.database#.program
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">
		</cfquery>
		<!--- set vars --->
		<cfset company_name = HTMLEditFormat(SelectProgramInfo.company_name)>
		<cfset program_name = HTMLEditFormat(SelectProgramInfo.program_name)>
		<cfset is_one_item = SelectProgramInfo.is_one_item>
		<cfset can_defer = SelectProgramInfo.can_defer>
		<cfset defer_msg = SelectProgramInfo.defer_msg>
		<cfset welcome_bg = HTMLEditFormat(SelectProgramInfo.welcome_bg)>
		<cfset welcome_instructions = SelectProgramInfo.welcome_instructions>
		<cfset welcome_message = SelectProgramInfo.welcome_message>
		<cfset welcome_congrats = HTMLEditFormat(SelectProgramInfo.welcome_congrats)>
		<cfset welcome_button = SelectProgramInfo.welcome_button>
		<cfset welcome_admin_button = SelectProgramInfo.welcome_admin_button>
		<cfset default_category = HTMLEditFormat(SelectProgramInfo.default_category)>
		<cfset admin_logo = HTMLEditFormat(SelectProgramInfo.admin_logo)>
		<cfset logo = HTMLEditFormat(SelectProgramInfo.logo)>
		<cfset cross_color = HTMLEditFormat(SelectProgramInfo.cross_color)>
		<cfset main_bg = HTMLEditFormat(SelectProgramInfo.main_bg)>
		<cfset main_congrats = HTMLEditFormat(SelectProgramInfo.main_congrats)>
		<cfset main_instructions = HTMLEditFormat(SelectProgramInfo.main_instructions)>
		<cfset return_button = HTMLEditFormat(SelectProgramInfo.return_button)>
		<cfset text_active = HTMLEditFormat(SelectProgramInfo.text_active)>
		<cfset bg_active = HTMLEditFormat(SelectProgramInfo.bg_active)>
		<cfset text_selected = HTMLEditFormat(SelectProgramInfo.text_selected)>
		<cfset bg_selected = HTMLEditFormat(SelectProgramInfo.bg_selected)>
		<cfset cart_exceeded_msg = HTMLEditFormat(SelectProgramInfo.cart_exceeded_msg)>
		<cfset cc_exceeded_msg = HTMLEditFormat(SelectProgramInfo.cc_exceeded_msg)>
		<cfset cc_max_default = HTMLEditFormat(SelectProgramInfo.cc_max_default)>
		<cfset orders_to = HTMLEditFormat(SelectProgramInfo.orders_to)>		
		<cfset orders_from = HTMLEditFormat(SelectProgramInfo.orders_from)>
		<cfset conf_email_text = HTMLEditFormat(SelectProgramInfo.conf_email_text)>
		<cfset program_email_subject = HTMLEditFormat(SelectProgramInfo.program_email_subject)>
		<cfset has_survey = HTMLEditFormat(SelectProgramInfo.has_survey)>		
		<cfset display_col = HTMLEditFormat(SelectProgramInfo.display_col)>
		<cfset display_row = HTMLEditFormat(SelectProgramInfo.display_row)>
		<cfset menu_text = HTMLEditFormat(SelectProgramInfo.menu_text)>
		<cfset credit_desc = HTMLEditFormat(SelectProgramInfo.credit_desc)>
		<cfset accepts_cc = HTMLEditFormat(SelectProgramInfo.accepts_cc)>
		<cfset login_prompt = HTMLEditFormat(SelectProgramInfo.login_prompt)>
		<cfset display_welcomeyourname = HTMLEditFormat(SelectProgramInfo.display_welcomeyourname)>
		<cfset display_youhavexcredits = HTMLEditFormat(SelectProgramInfo.display_youhavexcredits)>
		<cfset credit_multiplier = HTMLEditFormat(SelectProgramInfo.credit_multiplier)>
		<cfset points_multiplier = HTMLEditFormat(SelectProgramInfo.points_multiplier)>
		<cfset additional_content_button = SelectProgramInfo.additional_content_button>
		<cfset additional_content_message = SelectProgramInfo.additional_content_message>
		<cfset additional_content2_button = SelectProgramInfo.additional_content2_button>
		<cfset additional_content2_message = SelectProgramInfo.additional_content2_message>
		<cfset email_form_button = SelectProgramInfo.email_form_button>
		<cfset email_form_message = SelectProgramInfo.email_form_message>
		<cfset email_form_recipient = SelectProgramInfo.email_form_recipient>
		<cfset help_button = SelectProgramInfo.help_button>
		<cfset help_message = SelectProgramInfo.help_message>
		<cfset use_master_categories = SelectProgramInfo.use_master_categories>
		<cfset has_welcomepage = SelectProgramInfo.has_welcomepage>

		<!--- massage the data --->
		<cfif welcome_bg NEQ "">
			<cfset welcome_bg = ' background="pics/program/' & welcome_bg & '"'>
		</cfif>
		<cfif welcome_congrats NEQ "">
			<cfset welcome_congrats = ' <img src="pics/program/#welcome_congrats#" style="padding: 0px 0px 5px 0px">'>
			<cfelse>
			<cfset welcome_congrats = "&nbsp;">
		</cfif>
		<!--- get the logo --->
		<cfif logo NEQ "">
			<cfset vLogo = HTMLEditFormat(logo)>
		<cfelse>
			<cfset vLogo = "shim.gif">
		</cfif>
		<!--- has the graphic cross? --->
		<cfif cross_color NEQ "">
			<cfset cross_color = ' style="background-color:###cross_color#"'>
		</cfif>
		<!--- set bg image --->
		<cfif main_bg NEQ "">
			<cfset main_bg = ' background="pics/program/' & main_bg & '"'>
		</cfif>
		<!---  get congrats image --->
		<cfif main_congrats NEQ "">
			<cfset main_congrats = ' <img src="pics/program/#main_congrats#" style="padding: 0px 0px 5px 0px">'>
		<cfelse>
			<cfset main_congrats = "&nbsp;">
		</cfif>
		<!--- welcome your name AND you have x credits messages --->
		<cfset display_message = "">
		<cfset subprogram_display_message = "">
		<cfif display_welcomeyourname EQ 1>
			<cfif IsDefined('cookie.itc_user') AND #cookie.itc_user# NEQ "">
				<cfquery name="GetUserName" datasource="#application.DS#">
					SELECT fname, lname, email
					FROM #application.database#.program_user
					WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(cookie.itc_user,1,"-")#" maxlength="10">
				</cfquery>
				<cfif GetUserName.fname NEQ "" AND GetUserName.lname NEQ "">
					<cfset display_message = display_message & 'Welcome <span class="main_cart_number">#GetUserName.fname# #GetUserName.lname#</span>'>
				<cfelse>
					<cfset display_message = display_message & 'Welcome'>
				</cfif>
				<!---
				<cfquery name="GetSubpoints" datasource="#application.DS#">
					SELECT S.subprogram_name, SUM(SP.subpoints) AS TTLPoints
					FROM #application.database#.subprogram_points SP
					LEFT JOIN #application.database#.subprogram S ON S.ID = SP.subprogram_ID
					WHERE SP.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(cookie.itc_user,1,"-")#" maxlength="10">
					GROUP BY SP.subprogram_ID
				</cfquery>
				<cfset TotalNonZeroSubprograms = 0>
				<cfif GetSubpoints.RecordCount GT 0>
					<cfloop query="GetSubpoints">
						<cfif GetSubpoints.TTLPoints GT 0>
							<cfset TotalNonZeroSubprograms = TotalNonZeroSubprograms + 1>
						</cfif>
					</cfloop>
				</cfif>
				<cfif TotalNonZeroSubprograms GTE 1>
					<cfset subprogram_display_message = subprogram_display_message & '<br>You have '>
						<cfloop query="GetSubpoints">
							<cfif GetSubpoints.TTLPoints GT 0>
								<cfset subprogram_display_message = subprogram_display_message & '<span class="main_cart_number">#GetSubpoints.TTLPoints#</span> #GetSubpoints.subprogram_name#, '>
							</cfif>
						</cfloop>
						<cfif TotalNonZeroSubprograms IS 1>
							<cfset subprogram_display_message = LEFT(subprogram_display_message, (LEN(subprogram_display_message) - 2))>
						<cfelse>
						</cfif>
					<cfset subprogram_display_message = subprogram_display_message & ' #credit_desc#.'>
				</cfif>
				--->
			</cfif>
		</cfif>
		
		<cfif IsDefined('cookie.itc_user') AND cookie.itc_user NEQ "" AND display_youhavexcredits EQ 1>
			<cfset display_message = display_message & ' You have <span class="main_cart_number">#(ListGetAt(cookie.itc_user,2,"-")*points_multiplier) - (CartTotal()*credit_multiplier)#</span> #credit_desc#.'>
		</cfif>
		<cfif display_message NEQ "">
			<cfset display_message = '<span class="selected_msg">#display_message##subprogram_display_message#</span>'>
		</cfif>
		<!--- Get username to check for certificate --->
		<cfif IsDefined('cookie.itc_user') AND cookie.itc_user NEQ "">
			<cfquery name="GetUsersUsername" datasource="#application.DS#">
				SELECT username
				FROM #application.database#.program_user
				WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(cookie.itc_user,1,"-")#" maxlength="10">
			</cfquery>
			<cfset users_username = GetUsersUsername.username>
		<cfelse>
			<cfset users_username = "">
		</cfif>
	<cfelse>
		<!--- if program cookie not authentic, kickout --->
		<cflocation addtoken="no" url="zkick.cfm">
	</cfif>
<cfelse>
	<!--- if no program cookie, kickout --->
	<cflocation addtoken="no" url="zkick.cfm">
</cfif>
</cffunction>

<!---
 * ADMIN_GetProgramInfo()
 * 
 * checks the program cookie, grabs program info and puts in vars 
 *                  
 --->

<cffunction name="ADMIN_GetProgramInfo" output="false">

<cfif IsDefined('cookie.itc_program') AND cookie.itc_program IS NOT "">
	<!--- check itc_program hash --->
	<cfif FLGen_CreateHash(ListGetAt(cookie.itc_program,1,"-")) EQ ListGetAt(cookie.itc_program,2,"-")>
		<cfset ADMIN_program_ID = ListGetAt(cookie.itc_program,1,"-")>
		<!--- get program information  --->
		<cfquery name="ADMIN_SelectProgramInfo" datasource="#application.DS#">
			SELECT company_name, program_name, IF(is_one_item=1,"true","false") AS is_one_item, IF(can_defer=1,"true","false") AS can_defer, defer_msg, welcome_bg, welcome_instructions, welcome_message, welcome_congrats, welcome_button, welcome_admin_button, admin_logo, default_category, logo, cross_color, main_bg, main_congrats, main_instructions, return_button, text_active, bg_active, text_selected, bg_selected, cart_exceeded_msg, cc_exceeded_msg, cc_max_default, orders_to, orders_from, program_email_subject , IF(has_survey=1,"true","false") AS has_survey, display_col, display_row, menu_text, credit_desc, accepts_cc, login_prompt, display_welcomeyourname, display_youhavexcredits, credit_multiplier, points_multiplier
			FROM #application.database#.program
			WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ADMIN_program_ID#">
		</cfquery>
		<!--- set vars --->
		<cfset company_name = HTMLEditFormat(ADMIN_SelectProgramInfo.company_name)>
		<cfset program_name = HTMLEditFormat(ADMIN_SelectProgramInfo.program_name)>
		<cfset is_one_item = ADMIN_SelectProgramInfo.is_one_item>
		<cfset can_defer = ADMIN_SelectProgramInfo.can_defer>
		<cfset defer_msg = ADMIN_SelectProgramInfo.defer_msg>
		<cfset welcome_bg = HTMLEditFormat(ADMIN_SelectProgramInfo.welcome_bg)>
		<cfset welcome_instructions = ADMIN_SelectProgramInfo.welcome_instructions>
		<cfset welcome_message = ADMIN_SelectProgramInfo.welcome_message>
		<cfset welcome_congrats = HTMLEditFormat(ADMIN_SelectProgramInfo.welcome_congrats)>
		<cfset welcome_button = HTMLEditFormat(ADMIN_SelectProgramInfo.welcome_button)>
		<cfset welcome_admin_button = HTMLEditFormat(ADMIN_SelectProgramInfo.welcome_admin_button)>
		<cfset default_category = HTMLEditFormat(ADMIN_SelectProgramInfo.default_category)>
		<cfset admin_logo = HTMLEditFormat(ADMIN_SelectProgramInfo.admin_logo)>
		<cfset logo = HTMLEditFormat(ADMIN_SelectProgramInfo.logo)>
		<cfset cross_color = HTMLEditFormat(ADMIN_SelectProgramInfo.cross_color)>
		<cfset main_bg = HTMLEditFormat(ADMIN_SelectProgramInfo.main_bg)>
		<cfset main_congrats = HTMLEditFormat(ADMIN_SelectProgramInfo.main_congrats)>
		<cfset main_instructions = HTMLEditFormat(ADMIN_SelectProgramInfo.main_instructions)>
		<cfset return_button = HTMLEditFormat(ADMIN_SelectProgramInfo.return_button)>
		<cfset text_active = HTMLEditFormat(ADMIN_SelectProgramInfo.text_active)>
		<cfset bg_active = HTMLEditFormat(ADMIN_SelectProgramInfo.bg_active)>
		<cfset text_selected = HTMLEditFormat(ADMIN_SelectProgramInfo.text_selected)>
		<cfset bg_selected = HTMLEditFormat(ADMIN_SelectProgramInfo.bg_selected)>
		<cfset cart_exceeded_msg = HTMLEditFormat(ADMIN_SelectProgramInfo.cart_exceeded_msg)>
		<cfset cc_exceeded_msg = HTMLEditFormat(ADMIN_SelectProgramInfo.cc_exceeded_msg)>
		<cfset cc_max_default = HTMLEditFormat(ADMIN_SelectProgramInfo.cc_max_default)>
		<cfset orders_to = HTMLEditFormat(ADMIN_SelectProgramInfo.orders_to)>		
		<cfset orders_from = HTMLEditFormat(ADMIN_SelectProgramInfo.orders_from)>
		<cfset program_email_subject = HTMLEditFormat(ADMIN_SelectProgramInfo.program_email_subject)>
		<cfset has_survey = HTMLEditFormat(ADMIN_SelectProgramInfo.has_survey)>		
		<cfset display_col = HTMLEditFormat(ADMIN_SelectProgramInfo.display_col)>
		<cfset display_row = HTMLEditFormat(ADMIN_SelectProgramInfo.display_row)>
		<cfset menu_text = HTMLEditFormat(ADMIN_SelectProgramInfo.menu_text)>
		<cfset credit_desc = HTMLEditFormat(ADMIN_SelectProgramInfo.credit_desc)>
		<cfset accepts_cc = HTMLEditFormat(ADMIN_SelectProgramInfo.accepts_cc)>
		<cfset login_prompt = HTMLEditFormat(ADMIN_SelectProgramInfo.login_prompt)>
		<cfset display_welcomeyourname = HTMLEditFormat(ADMIN_SelectProgramInfo.display_welcomeyourname)>
		<cfset display_youhavexcredits = HTMLEditFormat(ADMIN_SelectProgramInfo.display_youhavexcredits)>
		<cfset credit_multiplier = HTMLEditFormat(ADMIN_SelectProgramInfo.credit_multiplier)>
		<cfset points_multiplier = HTMLEditFormat(ADMIN_SelectProgramInfo.points_multiplier)>
		<!--- massage the data --->
		<cfif welcome_bg NEQ "">
			<cfset welcome_bg = ' background="pics/program/' & welcome_bg & '"'>
		</cfif>
		<cfif welcome_congrats NEQ "">
			<cfset welcome_congrats = ' <img src="pics/program/#welcome_congrats#" style="padding: 0px 0px 5px 0px">'>
			<cfelse>
			<cfset welcome_congrats = "&nbsp;">
		</cfif>
		<!--- set default cateogry variable --->
		<cfparam name="c" default="#default_category#">
		<!--- get the logo --->
		<cfif logo NEQ "">
			<cfset vLogo = HTMLEditFormat(logo)>
		<cfelse>
			<cfset vLogo = "shim.gif">
		</cfif>
		<!--- has the graphic cross? --->
		<cfif cross_color NEQ "">
			<cfset cross_color = ' style="background-color:###cross_color#"'>
		</cfif>
		<!--- set bg image --->
		<cfif main_bg NEQ "">
			<cfset main_bg = ' background="pics/program/' & main_bg & '"'>
		</cfif>
		<!--- get congrats image --->
		<cfif main_congrats NEQ "">
			<cfset main_congrats = ' <img src="pics/program/#main_congrats#" style="padding: 0px 0px 5px 0px">'>
		<cfelse>
			<cfset main_congrats = "&nbsp;">
		</cfif>
		<!--- welcome your name AND you have x credits messages --->
		<cfset display_message = "">
		<cfif display_welcomeyourname EQ 1>
			<cfif IsDefined('cookie.itc_user') AND cookie.itc_user NEQ "">
				<cfquery name="GetUserName" datasource="#application.DS#">
					SELECT fname, lname
					FROM #application.database#.program_user
					WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(cookie.itc_user,1,"-")#" maxlength="10">
				</cfquery>
				<cfif GetUserName.fname NEQ "" AND GetUserName.lname NEQ "">
					<cfset display_message = display_message & 'Welcome #GetUserName.fname# #GetUserName.lname#'>
				<cfelse>
					<cfset display_message = display_message & 'Welcome'>
				</cfif>
			</cfif>
		</cfif>
		<cfif IsDefined('cookie.itc_user') AND cookie.itc_user NEQ "" AND display_youhavexcredits EQ 1>
			<cfset display_message = display_message & ' You have <span class="main_cart_number">#NumberFormat(points_multiplier * ((ListGetAt(cookie.itc_user,2,"-")) - CartTotal()),'0,000')#</span> #credit_desc#.'>
		</cfif>
		<cfif display_message NEQ "">
			<cfset display_message = '<span class="selected_msg">#display_message#</span>'>
		</cfif>
	<cfelse>
		<!--- if program cookie not authentic, kickout --->
		<cflocation addtoken="no" url="zkick.cfm">
	</cfif>
<cfelse>
	<!--- if no program cookie, kickout --->
	<cflocation addtoken="no" url="zkick.cfm">
</cfif>
</cffunction>

<!---
 * ProgramUserInfo(UserID,[write_cookie])
 * 
 * calculates this users [available points] [defered points]
 * and, optionally, writes the itc_user cookie MUST have cc_max var set previously
 *                  
 --->

<cffunction name="ProgramUserInfo" output="false">
	<cfargument name="ProgramUserInfo_userID" type="string" required="yes">
	<cfargument name="ProgramUserInfo_writecookie" type="string" required="no" default="false">
	<!--- look in the points database for the starting point amount --->
	<cfquery name="PosPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM(points),0) AS pos_pt
		FROM #application.database#.awards_points
		WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ProgramUserInfo_userID#">
		AND is_defered = 0
	</cfquery>
	<!--- look in the order database for orders/points_used --->
	<cfquery name="NegPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) AS neg_pt, IFNULL(SUM(cc_charge),0) AS neg_cc
		FROM #application.database#.order_info
		WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ProgramUserInfo_userID#">
		AND is_valid = 1
	</cfquery>
	<!--- find defered points --->
	<cfquery name="DefPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM(points),0) AS def_pt
		FROM #application.database#.awards_points
		WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ProgramUserInfo_userID#">
		AND is_defered = 1
	</cfquery>
	<cfset user_totalpoints = PosPoints.pos_pt - NegPoints.neg_pt>
<cfset cookie_points = user_totalpoints>
<cfif user_totalpoints LT 0>
	<cfset cookie_points = 0>
</cfif>
	<cfset user_deferedpoints = DefPoints.def_pt>
	<cfif ProgramUserInfo_writecookie>
		<!--- write itc_user cookie ([user_ID]-[points left]-[cc_max]_HASH (of ID and points w/ salt) --->
		<cfset UserHash = FLGen_CreateHash(ProgramUserInfo_userID & "-" & cookie_points & "-" & cc_max)>
		<cfcookie name="itc_user" value="#ProgramUserInfo_userID#-#cookie_points#-#cc_max#_#UserHash#">
	</cfif>
</cffunction>

<!---
 * SubprogramPoints(subprogram_ID,user_ID)
 * 
 * calculates this user's points for a subprogram
 --->

<cffunction name="SubprogramPoints" output="true">
	<cfargument name="SubPoints_subprogram_ID" type="string" required="yes">
	<cfargument name="SubPoints_user_ID" type="string" required="yes">
	<cfquery name="SubPoints_FindSubprogramPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM(subpoints),0) AS subpoints
		FROM #application.database#.subprogram_points
		WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SubPoints_user_ID#"> 
			AND subprogram_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SubPoints_subprogram_ID#">
	</cfquery>
	<cfreturn SubPoints_FindSubprogramPoints.subpoints>
</cffunction>

<!---
 * ProgramUserInfoConstrained(UserID,FromDate,ToDate)
 * 
 * calculates this users [available points] [defered points] [used points]
 *                  
 --->

<cffunction name="ProgramUserInfoConstrained" output="false">
	<cfargument name="cxd_userID" required="yes">
	<cfargument name="cxd_fromdate" required="no" default="">
	<cfargument name="cxd_todate" required="no" default="">
	<!--- look in the points database for the starting point amount --->
	<cfquery name="PosPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM(points),0) AS pos_pt
		FROM #application.database#.awards_points
		WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cxd_userID#">
		AND is_defered = 0
		<cfif isDate(cxd_todate)>
			AND created_datetime <= <cfqueryparam value="#cxd_todate#">
		</cfif>
	</cfquery>
	<!--- look in the order database for orders/points_used --->
	<cfquery name="NegPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM((points_used*credit_multiplier)/points_multiplier),0) AS neg_pt, IFNULL(SUM(cc_charge),0) AS neg_cc
		FROM #application.database#.order_info
		WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cxd_userID#">
		AND is_valid = 1
		<cfif isDate(cxd_todate)>
			AND created_datetime <= <cfqueryparam value="#cxd_todate#">
		</cfif>
	</cfquery>
	<!--- find defered points --->
	<cfquery name="DefPoints" datasource="#application.DS#">
		SELECT IFNULL(SUM(points),0) AS def_pt
		FROM #application.database#.awards_points
		WHERE user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cxd_userID#">
		AND is_defered = 1
		<cfif isDate(cxd_todate)>
			AND created_datetime <= <cfqueryparam value="#cxd_todate#">
		</cfif>
	</cfquery>
	<!--- was last order within the date range --->
	<cfquery name="CheckOrderDate" datasource="#application.DS#">
		SELECT created_datetime 
		FROM #application.database#.order_info
		WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#cxd_userID#">
		AND is_valid = 1
		<cfif isDate(cxd_fromdate)>
			AND created_datetime >= <cfqueryparam value="#cxd_fromdate#">
		</cfif>
		<cfif isDate(cxd_todate)>
			AND created_datetime <= <cfqueryparam value="#cxd_todate#">
		</cfif>
		ORDER BY created_datetime DESC
		LIMIT 1
	</cfquery>
	<cfif CheckOrderDate.RecordCount EQ 0>
		<cfset BRp_order_in_range = false>
		<cfset BRp_last_order = "">
	<cfelse>
		<cfset BRp_order_in_range = true>
		<cfset BRp_last_order = FLGen_DateTimeToDisplay(CheckOrderDate.created_datetime)>
	</cfif>
	<cfset BRp_pospoints = PosPoints.pos_pt>
	<cfset BRp_negpoints = NegPoints.neg_pt>
	<cfset BRp_totalpoints = PosPoints.pos_pt - NegPoints.neg_pt>
	<cfset BRp_deferedpoints = DefPoints.def_pt>
</cffunction>

<!---
 * AuthenticateProgramUserCookie()
 * 
 * authenticates user cookie and sets user vars
 *                  
 --->

<cffunction name="AuthenticateProgramUserCookie" output="false" returntype="boolean">
	<cfif IsDefined('cookie.itc_user') AND cookie.itc_user IS NOT "">
		<!--- authenticate itc_user cookie --->
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_user,1,"_")) EQ ListGetAt(cookie.itc_user,2,"_")>
			<!--- set user vars --->
			<cfset user_ID = ListGetAt(cookie.itc_user,1,"-")>
			<cfset user_total = ListGetAt(cookie.itc_user,2,"-")>
			<cfset cc_max = ListGetAt(ListGetAt(cookie.itc_user,3,"-"),1,"_")>
			<cfreturn true>
		<cfelse>
			<!--- cookie not authentic, kick out --->
			<cflocation addtoken="no" url="zkick.cfm">
		</cfif>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<!---
 * CartItemCount()
 * 
 * returns number of items in cart 
 --->

<cffunction name="CartItemCount" output="false">
	<cfif IsDefined('cookie.itc_order') AND cookie.itc_order IS NOT "">
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_order,1,"-")) EQ ListGetAt(cookie.itc_order,2,"-")>
			<cfset order_ID = ListGetAt(cookie.itc_order,1,"-")>
			<!--- look in the points database for the starting point amount --->
			<cfquery name="CountCartItems" datasource="#application.DS#">
				SELECT IFNULL(SUM(quantity),0) AS itemcount
				FROM #application.database#.inventory 
				WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#">
			</cfquery>
			<cfset itemcount = CountCartItems.itemcount>
		</cfif>
	<cfelse>
		<cfset itemcount = 0>
	</cfif>
</cffunction>

<!---
 * CartTotal()
 * 
 * returns total point cost of the items in cart 
 *                  
 --->

<cffunction name="CartTotal" output="false">
	<cfset F_carttotal = 0>
	<cfif IsDefined('cookie.itc_order') AND cookie.itc_order IS NOT "">
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_order,1,"-")) EQ ListGetAt(cookie.itc_order,2,"-")>
			<cfset order_ID = ListGetAt(cookie.itc_order,1,"-")>
			<cfquery name="FindOrderItems" datasource="#application.DS#">
				SELECT ID AS inventory_ID, snap_meta_name, snap_description, snap_productvalue, quantity, snap_options
				FROM #application.database#.inventory
				WHERE order_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#order_ID#">
			</cfquery>
			<cfif FindOrderItems.RecordCount GT 0>
				<cfloop query="FindOrderItems">
					<cfset F_carttotal = F_carttotal + (snap_productvalue * quantity)>
				</cfloop>
			</cfif>
		</cfif>
	</cfif>
	<cfreturn F_carttotal>
</cffunction>



<!---
 * CustomerSurvey([where])
 * 
 * outputs survey 
 * @param action		this is action the user was performing
 *                  
 --->

<cffunction name="CustomerSurvey" output="true">
	<cfargument name="CustomerSurvey_action" type="string" required="yes">
	<table cellpadding="5" cellspacing="0" border="0" class="survey_box">
	<form method="post" action="#CurrentPage#" name="survey">
	<tr>
	<td colspan="2" align="left" valign="top"><b>Customer Satisfaction Survey</b></td>
	</tr>
	<tr>
	<td align="left">How would you rate the navigation of this website?</td>
	<td align="center" valign="top">Difficult 
	<img src="pics/program/worst-best.gif"> Easy<br>
	<input type="radio" name="navigation" value="1">1&nbsp;&nbsp;&nbsp;<input type="radio" name="navigation" value="2">2&nbsp;&nbsp;&nbsp;<input type="radio" name="navigation" value="3">3&nbsp;&nbsp;&nbsp;<input type="radio" name="navigation" value="4">4&nbsp;&nbsp;&nbsp;<input type="radio" name="navigation" value="5">5<input type="hidden" name="navigation_required" value="You must choose a website navigation rating">
	</td>
	</tr>
	<tr>
	<td align="left">How would you rate the product selection?</td>
	<td align="center" valign="top">Lowest 
	<img src="pics/program/worst-best.gif"> Highest<br>
	<input type="radio" name="selection" value="1">1&nbsp;&nbsp;&nbsp;<input type="radio" name="selection" value="2">2&nbsp;&nbsp;&nbsp;<input type="radio" name="selection" value="3">3&nbsp;&nbsp;&nbsp;<input type="radio" name="selection" value="4">4&nbsp;&nbsp;&nbsp;<input type="radio" name="selection" value="5">5<input type="hidden" name="selection_required" value="You must choose a product selection rating">
	</td>
	</tr>
	<tr>
	<td colspan="2" align="left">Please give us your suggestions for<br>website enhancements and/or product offerings.</td>
	</td>
	</tr>
	<tr>
	<td colspan="2" align="left"><textarea rows="5" cols="60" name="note"></textarea></td>
	</td>
	</tr>
	<tr>
	<td colspan="2" align="center">
		<input type="hidden" name="user_ID" value="#user_ID#">
		<input type="hidden" name="user_ID_required" value="User ID must be passed.  Contact the programmer.">
		<input type="hidden" name="action" value="#CustomerSurvey_action#">
		<input type="hidden" name="action_required" value="Variable 'action' must be passed.  Contact the programmer.">
		<input type="hidden" name="program_ID" value="#program_ID#">
		<input type="hidden" name="program_ID_required" value="Program ID must be passed.  Contact the programmer.">
		<input type="submit" name="submitsurvey" value="Submit"> Thank you ... we value your feedback!
	</td>
	</td>
	</tr>
	</form>
	</table>
</cffunction>

<!---
 * ProcessCustomerSurvey()
 * 
 * processes survey 
 *                  
 --->

<cffunction name="ProcessCustomerSurvey" output="false">
	<cfquery name="InsertNewSurvey" datasource="#application.DS#">
		INSERT INTO #application.database#.survey
		(created_user_ID, created_datetime, program_ID, action, navigation, selection, note)
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#user_ID#" maxlength="10">, 
			'#FLGen_DateTimeToMySQL()#', 
			<cfqueryparam cfsqltype="cf_sql_integer" value="#program_ID#" maxlength="10">, 
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.action#" maxlength="20">, 
			<cfqueryparam cfsqltype="cf_sql_integer" value="#form.navigation#" maxlength="1">, 
			<cfqueryparam cfsqltype="cf_sql_integer" value="#form.selection#" maxlength="1">, 
			<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#form.note#" null="#YesNoFormat(NOT Len(Trim(form.note)))#">)
	</cfquery>
	<cflocation addtoken="no" url="zkick.cfm?survey=yes">
</cffunction>


<!---
 * WriteSurveyCookie()
 * 
 * writes the survey specific info into a cookie 
 * [user_ID] [order_ID] 
 --->

<cffunction name="WriteSurveyCookie" output="false">
	<cfparam name="order_ID" default="0">
	<!--- hash info --->	
	<cfset WriteSurveyCookie_Hash = FLGen_CreateHash(#user_ID# & "-" & #order_ID# & "-" & #user_total#)>
	<!--- write cookie --->
	<cfcookie name="itc_survey" value="#user_ID#-#order_ID#-#user_total#_#WriteSurveyCookie_Hash#">
</cffunction>

<!---
 * AuthenticateSurveyCookie()
 * 
 * authenticates the survey cookie 
 *                  
 --->

<cffunction name="AuthenticateSurveyCookie" output="false">
	<!--- get user info --->
	<cfif IsDefined('cookie.itc_survey') AND cookie.itc_survey IS NOT "">
		<cfif FLGen_CreateHash(ListGetAt(cookie.itc_survey,1,"_")) EQ ListGetAt(cookie.itc_survey,2,"_")>
			<!--- set user vars --->
			<cfset user_ID = ListGetAt(cookie.itc_survey,1,"-")>
			<cfset order_ID = ListGetAt(ListGetAt(cookie.itc_survey,2,"-"),1,"_")>
			<cfset user_total = ListGetAt(ListGetAt(cookie.itc_survey,3,"-"),1,"_")>
		</cfif>
	<cfelse>
		<cflocation url="zkick.cfm" addtoken="no">
	</cfif>
</cffunction>

<!---
 * PhysicalInvCalc(product_ID)
 * 
 * calculates the inventory totals for the product passed 
 *                  
 --->

<cffunction name="PhysicalInvCalc" output="false">
	<cfargument name="PIC_prodID" required="yes">
	<!--- total manual adjustments --->
	<cfquery name="PIC_manual" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_total_manual
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PIC_prodID#">
			AND is_valid = 1 
			AND quantity <> 0 
			AND snap_is_dropshipped = 0  
			AND order_ID = 0 
			AND ship_date IS NULL 
			AND po_ID = 0
			AND po_rec_date IS NULL 
	</cfquery>
	<!--- total ordered not shipped --->
	<cfquery name="PIC_ordnotshipd" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_total_ordnotshipd
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PIC_prodID#">
			AND is_valid = 1 
			AND quantity <> 0 
			AND snap_is_dropshipped = 0  
			AND order_ID <> 0 
			AND ship_date IS NULL 
			AND po_ID = 0
			AND po_rec_date IS NULL 
	</cfquery>
	<!--- total ordered and shipped --->
	<cfquery name="PIC_ordshipd" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_total_ordshipd
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PIC_prodID#">
			AND is_valid = 1 
			AND quantity <> 0 
			AND snap_is_dropshipped = 0  
			AND order_ID <> 0 
			AND ship_date IS NOT NULL 
			AND po_ID = 0
			AND po_rec_date IS NULL 
	</cfquery>
	<!--- total po not recvd --->
	<cfquery name="PIC_ponotrec" datasource="#application.DS#">
		SELECT SUM(po_quantity) AS PIC_total_ponotrec
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PIC_prodID#">
			AND is_valid = 1 
			AND quantity = 0 
			AND snap_is_dropshipped = 0  
			AND order_ID = 0 
			AND ship_date IS NULL 
			AND po_ID <> 0
			AND po_rec_date IS NULL 
	</cfquery>
	<!--- total po recvd --->
	<cfquery name="PIC_porec" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_total_porec
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PIC_prodID#">
			AND is_valid = 1 
			AND quantity <> 0 
			AND snap_is_dropshipped = 0  
			AND order_ID = 0 
			AND ship_date IS NULL 
			AND po_ID <> 0
			AND po_rec_date IS NOT NULL 
	</cfquery>
	<!--- set variables --->
	<cfif PIC_manual.PIC_total_manual NEQ "">
		<cfset PIC_total_manual = PIC_manual.PIC_total_manual>
	<cfelse>
		<cfset PIC_total_manual = 0>
	</cfif>
	<cfif PIC_ordnotshipd.PIC_total_ordnotshipd NEQ "">
		<cfset PIC_total_ordnotshipd = PIC_ordnotshipd.PIC_total_ordnotshipd>
	<cfelse>
		<cfset PIC_total_ordnotshipd = 0>
	</cfif>
	<cfif PIC_ordshipd.PIC_total_ordshipd NEQ "">
		<cfset PIC_total_ordshipd = PIC_ordshipd.PIC_total_ordshipd>
	<cfelse>
		<cfset PIC_total_ordshipd = 0>
	</cfif>
	<cfif PIC_porec.PIC_total_porec NEQ "">
		<cfset PIC_total_porec = PIC_porec.PIC_total_porec>
	<cfelse>
		<cfset PIC_total_porec = 0>
	</cfif>
	<cfif PIC_ponotrec.PIC_total_ponotrec NEQ "">
		<cfset PIC_total_ponotrec = PIC_ponotrec.PIC_total_ponotrec>
	<cfelse>
		<cfset PIC_total_ponotrec = 0>
	</cfif>
	<cfset PIC_productID = PIC_prodID>
	<cfset PIC_total_physical = (PIC_total_manual + PIC_total_porec) - PIC_total_ordshipd>
	<cfset PIC_total_virtual = (PIC_total_physical + PIC_total_ponotrec) - PIC_total_ordnotshipd>
	<!--- ALL VARIABLES
		PIC_productID
		PIC_total_manual
		PIC_total_ordnotshipd
		PIC_total_ordshipd
		PIC_total_porec
		PIC_total_ponotrec
		PIC_total_physical
		PIC_total_virtual
	 --->
</cffunction>

<!---
 * CalcPhysicalInventory(product_ID)
 * 
 * calculates the physical inventory total for the product passed 
 *                  
 --->

<cffunction name="CalcPhysicalInventory" output="false">
	<cfargument name="CALC_product_ID" required="yes">
	<!--- total manual adjustments --->
	<cfquery name="PIC_manual" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_total_manual
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CALC_product_ID#">
			AND is_valid = 1 
			AND quantity <> 0 
			AND snap_is_dropshipped = 0  
			AND order_ID = 0 
			AND ship_date IS NULL 
			AND (
				(po_ID = 0 AND po_rec_date IS NULL)
				OR
				(po_ID <> 0 AND po_rec_date IS NOT NULL)
				)
	</cfquery>
	<!--- total ordered and shipped --->
	<cfquery name="PIC_ordshipd" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_total_ordshipd
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CALC_product_ID#">
			AND is_valid = 1 
			AND quantity <> 0 
			AND snap_is_dropshipped = 0  
			AND order_ID <> 0 
			AND ship_date IS NOT NULL 
			AND po_ID = 0
			AND po_rec_date IS NULL 
	</cfquery>
	<!--- set variables --->
	<cfif PIC_manual.PIC_total_manual NEQ "">
		<cfset PIC_total_manual = PIC_manual.PIC_total_manual>
	<cfelse>
		<cfset PIC_total_manual = 0>
	</cfif>
	<cfif PIC_ordshipd.PIC_total_ordshipd NEQ "">
		<cfset PIC_total_ordshipd = PIC_ordshipd.PIC_total_ordshipd>
	<cfelse>
		<cfset PIC_total_ordshipd = 0>
	</cfif>
	<cfreturn (PIC_total_manual - PIC_total_ordshipd)>
</cffunction>

<!---
 * CalcVirtualInventory(product_ID)
 * 
 * calculates the virtual inventory total for the product passed 
 *                  
 --->

<cffunction name="CalcVirtualInventory" output="false">
	<cfargument name="CALC_product_ID" required="yes">
	<cfquery name="PIC_positive" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_positive_total_1, SUM(po_quantity) AS PIC_positive_total_2
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CALC_product_ID#">
			AND is_valid = 1 
			AND snap_is_dropshipped = 0  
			AND order_ID = 0 
			AND ship_date IS NULL 
			AND (
				(quantity <> 0 AND po_ID = 0 AND po_rec_date IS NULL)
				OR
				(quantity <> 0 AND po_ID <> 0 AND po_rec_date IS NOT NULL)
				OR
				(quantity = 0 AND po_ID <> 0 AND po_rec_date IS NULL)
				)
	</cfquery>
	<!--- total ordered not shipped --->
	<cfquery name="PIC_negative" datasource="#application.DS#">
		SELECT SUM(quantity) AS PIC_negative_total
		FROM #application.database#.inventory
		WHERE product_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CALC_product_ID#">
			AND is_valid = 1 
			AND quantity <> 0 
			AND snap_is_dropshipped = 0  
			AND order_ID <> 0 
			AND po_ID = 0
			AND po_rec_date IS NULL 
	</cfquery>
	<!--- set variables --->
	<cfif PIC_positive.PIC_positive_total_1 NEQ "">
		<cfset positive_total = PIC_positive.PIC_positive_total_1>
	<cfelse>
		<cfset positive_total = 0>
	</cfif>
	<cfif PIC_positive.PIC_positive_total_2 NEQ "">
		<cfset positive_total = positive_total + PIC_positive.PIC_positive_total_2>
	</cfif>
	<cfif PIC_negative.PIC_negative_total NEQ "">
		<cfset negative_total = PIC_negative.PIC_negative_total>
	<cfelse>
		<cfset negative_total = 0>
	</cfif>
	<cfreturn (positive_total - negative_total)>
</cffunction>

<!---
 * FindProductOptions(product_ID)
 * 
 * create a variable that equals the product options in brackets
 * 
 * @param product_ID
 *                  
 --->
<cffunction name="FindProductOptions" output="false">
	<cfargument name="FindProductOptions_productID" type="string" required="yes">
	<!--- get the product's options --->
	<cfquery name="FindProdOptions" datasource="#application.DS#">
		SELECT pmo.option_name, pmoc.category_name
		FROM #application.product_database#.product p
			JOIN #application.product_database#.product_option po ON p.ID = po.product_ID
			JOIN #application.product_database#.product_meta_option pmo ON pmo.ID = po.product_meta_option_ID
			JOIN #application.product_database#.product_meta_option_category pmoc ON pmoc.ID = pmo.product_meta_option_category_ID
		WHERE p.ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FindProductOptions_productID#">
		ORDER BY pmoc.sortorder, pmo.sortorder
	</cfquery>
	
	<cfset FPO_theseoptions = "">
	<cfif FindProdOptions.RecordCount NEQ 0>
		<cfloop query="FindProdOptions">
			<cfset FPO_theseoptions = FPO_theseoptions & " [#category_name#: #option_name#] ">
		</cfloop>
		<cfset FPO_theseoptions = Trim(FPO_theseoptions)>
	</cfif>
</cffunction>

<!---
 * FLITC_GetProgramName(program_ID)
 * 
 * returns "Company_Name [Program Name]"
 * 
 * @param program_ID
 *                  
 --->
<cffunction name="FLITC_GetProgramName" output="false">
	<cfargument name="thisprogramID" type="string" required="yes">
	<cfquery name="ProgramName" datasource="#application.DS#">
		SELECT company_name, program_name 
		FROM #application.database#.program
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisprogramID#">
	</cfquery>
	<cfreturn HTMLEditFormat(ProgramName.company_name) & " [" & HTMLEditFormat(ProgramName.program_name) & "]">
</cffunction>

<cffunction name="FLITC_GetVendorName" output="false">
	<cfargument name="thisprogramID" type="string" required="yes">
	<cfquery name="ProgramName" datasource="#application.DS#">
		SELECT vendor
		FROM #application.product_database#.vendor
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisprogramID#">
	</cfquery>
	<cfreturn HTMLEditFormat(ProgramName.vendor)>
</cffunction>

<!---
 * SelectPVMaster([string],[string])
 * 
 * creates a select of the productvalue_master productvalues with the ID value
 * 
 * @param	name of the select, default "productvalue_master_ID"
 * @param 	selected ID, default ""
 *                  
 --->
<cffunction name="SelectPVMaster" output="true">
	<cfargument name="SelectPVMasterNAME" type="string" required="no" default="productvalue_master_ID">
	<cfargument name="SelectPVMasterSelectedID" type="string" required="no" default="">
	<!--- do query on pv_master table --->
	<cfquery name="GetMasterPV" datasource="#application.DS#">
		SELECT ID, productvalue
		FROM #application.product_database#.productvalue_master
		ORDER BY sortorder ASC 
	</cfquery>
	<select name="#SelectPVMasterNAME#">
		<option value=""<cfif SelectPVMasterSelectedID EQ ""> selected</cfif>>-- Select a Product Category --</option>
		<cfloop query="GetMasterPV">
		<option value="#ID#"<cfif SelectPVMasterSelectedID EQ ID> selected</cfif>>#productvalue#</option>
		</cfloop>
	</select>
</cffunction>

<!---
 * SelectProgram([selected_ID],[firstoptiontext])
 * 
 * creates a select of all programs
 --->
<cffunction name="SelectProgram" output="true">
	<cfargument name="SelectProgram_selected" required="no" default="">
	<cfargument name="SelectProgram_firstoption" required="no" default="-- Select a Program --">
	<cfargument name="SelectProgram_selectname" required="no" default="program_ID">
	<cfargument name="SelectProgram_selectID" required="no" default="program_ID">
	<cfargument name="SelectProgram_onlyactive" required="no" default="false">
	<!--- do query on pv_master table --->
	<cfquery name="GetProgramNames" datasource="#application.DS#">
		SELECT ID, company_name, program_name 
		FROM #application.database#.program
		<cfif SelectProgram_onlyactive>
		WHERE is_active = 1
		</cfif>
		ORDER BY company_name, program_name
	</cfquery>
	<select name="#SelectProgram_selectname#" id="#SelectProgram_selectID#">
		<option value="">#SelectProgram_firstoption#</option>
		<cfloop query="GetProgramNames">
		<option value="#ID#"<cfif SelectProgram_selected EQ ID> selected</cfif>>#company_name# [#program_name#]</option>
		</cfloop>
	</select>
		
</cffunction>


<!---
 * SelectVendor([selected_ID],[firstoptiontext],[selectname])
 * 
 * creates a select of all vendors
 --->
<cffunction name="SelectVendor" output="true">
	<cfargument name="SelectVendor_selected" required="no" default="">
	<cfargument name="SelectVendor_firstoption" required="no" default="-- Select a Vendor --">
	<cfargument name="SelectVendor_selectname" required="no" default="vendor_ID">
	<!--- do query on vendor table --->
	<cfquery name="GetVendorNames" datasource="#application.DS#">
		SELECT ID, vendor 
		FROM #application.product_database#.vendor
		ORDER BY vendor ASC 
	</cfquery>
	<select name="#SelectVendor_selectname#">
		<option value="">#SelectVendor_firstoption#</option>
		<cfloop query="GetVendorNames">
		<option value="#ID#"<cfif SelectVendor_selected EQ ID> selected</cfif>>#vendor#</option>
		</cfloop>
	</select>
</cffunction>

<!---
 * FLITC_Show_Delete_Admin_User(Admin User ID)
 * 
 * determines whether an admin user can be deleted
 --->
<cffunction name="FLITC_Show_Delete_Admin_User" output="false">
	<cfargument name="this_admin_user_ID" required="yes">
	<cfset FLITC_show_delete = true>
	<!--- check every table for activity --->
	<cfquery name="Count_admin_level" datasource="#application.DS#">
		SELECT Count(ID) AS current_count
		FROM #application.database#.admin_level
		WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
	</cfquery>
	<cfif Count_admin_level.current_count GT 0>
		<cfset FLITC_show_delete = false>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_admin_lookup" datasource="#application.DS#">
			SELECT Count(ID) as current_count 
			FROM #application.database#.admin_lookup
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_admin_lookup.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_admin_users" datasource="#application.DS#">
			SELECT COUNT(ID) as current_count 
			FROM #application.database#.admin_users
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_admin_users.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_awards_points" datasource="#application.DS#">
			SELECT COUNT(ID) as current_count 
			FROM #application.database#.awards_points
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_awards_points.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_inventory" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.inventory
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_inventory.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_manuf_logo" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.manuf_logo
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_manuf_logo.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_product" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.product
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_product.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_product_meta" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.product_meta
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_product_meta.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_product_meta_group" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.product_meta_group
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_product_meta_group.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_product_meta_group_lookup" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.product_meta_group_lookup
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_product_meta_group_lookup.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_product_meta_option" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.product_meta_option
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_product_meta_option.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_product_meta_option_category" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.product_meta_option_category
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_product_meta_option_category.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_product_option" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.product_option
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_product_option.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_productvalue_master" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.productvalue_master
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_productvalue_master.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_productvalue_program" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.productvalue_program
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_productvalue_program.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_program" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.program
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_program.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_program_login" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.program_login
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_program_login.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_program_product_exclude" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.program_product_exclude
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_program_product_exclude.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_purchase_order" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.purchase_order
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_purchase_order.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_program_user" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.database#.program_user
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_program_user.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_vendor" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.vendor
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_vendor.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
	<cfif FLITC_show_delete>
		<cfquery name="Count_vendor_lookup" datasource="#application.DS#">
			SELECT COUNT(ID) AS current_count 
			FROM #application.product_database#.vendor_lookup
			WHERE created_user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#this_admin_user_ID#">
		</cfquery>
		<cfif Count_vendor_lookup.current_count GT 0>
			<cfset FLITC_show_delete = false>
		</cfif>
	</cfif>
</cffunction>

<!--- Trivia stuff --->

<cffunction name="GetQuestion" output="false">
	<cfargument name="date_available" type="string" required="no" default="#Now()#">
	<cfquery name="FindQuestion" datasource="#application.DS#">
		SELECT ID, question, award_points, sort_order
		FROM #application.product_database#.trivia_question
		WHERE date_start <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date_available#">
		AND date_end >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date_available#">
	</cfquery>
	<cfreturn FindQuestion>
</cffunction>

<cffunction name="GetQuestionByID" output="false">
	<cfargument name="question_id" type="numeric" required="yes">
	<cfargument name="validate_date" type="boolean" required="no" default="true">
	<cfargument name="date_available" type="string" required="no" default="#Now()#">
	<cfquery name="FindQuestion" datasource="#application.DS#">
		SELECT ID, question, award_points, sort_order
		FROM #application.product_database#.trivia_question
		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.question_id#">
		<cfif arguments.validate_date>
			AND date_start <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date_available#">
			AND date_end >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.date_available#">
		</cfif>
	</cfquery>
	<cfreturn FindQuestion>
</cffunction>

<cffunction name="GetAnswers" output="false">
	<cfargument name="question_id" type="numeric" required="yes">
	<cfquery name="FindAnswers" datasource="#application.DS#">
		SELECT ID, answer, is_correct
		FROM #application.product_database#.trivia_answer
		WHERE trivia_question_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.question_id#">
		ORDER BY sort_order
	</cfquery>
	<cfreturn FindAnswers>
</cffunction>

<cffunction name="CheckAnswer" output="false">
	<cfargument name="question_id" type="numeric" required="yes">
	<cfargument name="answer_id" type="numeric" required="yes">
	<cfset return_val = false>
	<cfquery name="FindAnswer" datasource="#application.DS#">
		SELECT ID, answer, is_correct
		FROM #application.product_database#.trivia_answer
		WHERE trivia_question_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.question_id#">
		AND ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.answer_id#">
	</cfquery>
	<cfif FindAnswer.RecordCount EQ 1 AND FindAnswer.is_correct>
		<cfset return_val = true>
	</cfif>
	<cfreturn return_val>
</cffunction>

<cffunction name="GetUserAnswer" output="false">
	<cfargument name="question_id" type="numeric" required="yes">
	<cfargument name="user_id" type="numeric" required="yes">
	<cfquery name="FindUserAnswer" datasource="#application.DS#">
		SELECT x.ID, q.question, a.answer, x.was_correct, x.created_datetime
		FROM #application.product_database#.xref_trivia_user x
		INNER JOIN #application.product_database#.trivia_question q ON q.ID = x.trivia_question_ID 
		INNER JOIN #application.product_database#.trivia_answer a ON a.ID = x.trivia_answer_ID 
		WHERE x.trivia_question_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.question_id#">
		AND x.program_user_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.user_id#">
	</cfquery>
	<cfreturn FindUserAnswer>
</cffunction>

