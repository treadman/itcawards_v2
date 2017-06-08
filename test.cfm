<html>
<head>
    <title>HTTP Upload</title>
</head>
<body>
<!--- <cfhttp method="Post" url="http://www4.itcawards.com/upload.cfm">
	<cfhttpparam type="Formfield" name="UploadID" value="10009">
	<cfhttpparam type="Formfield" name="Name" value="Test 10009">
	<cfhttpparam type="Formfield" name="Description" value="This is a test of the file uploader">
	<cfhttpparam type="File" name="UploadFile" file="#application.AbsPath#test.csv">
</cfhttp> --->
<cfoutput>
File Content:<hr>
#cfhttp.filecontent#<hr>
Mime Type:#cfhttp.MimeType#<br>
</cfoutput>
</body>
</html>


