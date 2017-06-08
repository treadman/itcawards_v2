<!--- import function library --->
<cfinclude template="/cfscripts/dfm_common/function_library_general.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_form.cfm">
<cfinclude template="/cfscripts/dfm_common/function_library_page.cfm">
<cfinclude template="../includes/function_library_itcawards.cfm">

<!--- *************************** --->
<!--- authenticate the admin user --->
<!--- *************************** --->
<cfset FLGen_AuthenticateAdmin()>
<cfset FLGen_HasAdminAccess(1000000082,true)>

<!--- ************************************ --->
<!--- param all variables used on this page --->
<!--- ************************************ --->
<cfparam name="x" default="">
<cfparam name="ID" default="">
<cfparam name="datasaved" default="no">
<cfparam name="delete" default="">
<cfparam name="alert_msg" default="">

<!--- ************************** --->
<!--- START form processing code --->
<!--- ************************** --->

<cfif IsDefined('form.Submit')>
	<cfset upload_results = FLGen_UploadThis("upload_file_field","admin/upload/","ups_file")>
	<cfif upload_results NEQ "false,false">
		<cfset alert_msg = "The new file was uploaded.">
	<cfelse>
		<cfset alert_msg = "The new file was NOT uploaded.">
	</cfif>
</cfif>

<!--- ************************--->
<!--- END form processing code --->
<!--- ************************ --->

<!--- *********************** --->
<!--- START page display code --->
<!--- *********************** --->

<cfset leftnavon = "ups_group_upload">
<cfinclude template="includes/header.cfm">

<span class="pagetitle">Upload A UPS .CSV From WorldShip</span>
<br /><br />
<span class="pageinstructions" style="display:block">There can only be one UPS .csv file on the server at a time.  When you upload a new file it is saved over the existing file.</span>
<br /><br />

<cfoutput>

<form method="post" action="#CurrentPage#" enctype="multipart/form-data">

	<table cellpadding="5" cellspacing="1" border="0" width="100%">
	
	<tr class="content">
	<td align="right"><input type="file" name="upload_file_field" size="50"></td>
	<td><input type="submit" name="submit" value="Upload File" ></td>
	</tr>
				
	</table>

</form>

	<br><br>
	<cftry>
	
	<cffile action="read" file="#application.AbsPath#admin/upload/ups_file.csv" variable="display_file">
	
	<cfif display_file EQ "">
		There is no file or the file has no content to display.	
	<cfelse>
		<cfif ListLen(display_file,chr(13) & chr(10)) EQ 1>
			There are no entries in this file.
		<cfelse>
			<cfif ListLen(display_file,"#chr(13) & chr(10)#,") MOD 4 NEQ 0>
				The .csv file is not properly formatted.
			<cfelse>
			
	<b>Current file contains [ <cfoutput>#ListLen(display_file,"#chr(13) & chr(10)#,")/4 - 1#</cfoutput> ] records:</b>
	<br /><br />			
		
		<table border="1" cellpadding="2" style="border-width:1px;border-style:solid;border-color:##CCCCCC;border-collapse:collapse">
		<cfloop list="#display_file#" delimiters="#chr(13) & chr(10)#" index="i">
		<tr>
			<cfloop list="#i#" delimiters="," index="j">
			<td>
			#j#
			</td>
			</cfloop>
		</tr>
		</cfloop>
		</table>
	
			</cfif>
		</cfif>
	</cfif>
	
	<cfcatch>
	There is no current .csv file.
	</cfcatch>
	
	</cftry>
	
</cfoutput>

<cfinclude template="includes/footer.cfm">

<!--- ********************* --->
<!--- END page display code --->
<!--- ********************* --->