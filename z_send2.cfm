<cfparam name="url.doit" default="0">

<cfquery name="ProgramUsers" datasource="#application.DS#">
	SELECT p.ID, a.transfer_datetime, p.username, p.fname, p.lname, p.email, a.points
	FROM #application.database#.points_transfer a
	LEFT JOIN #application.database#.program_user p ON p.ID = a.from_user_ID
	WHERE a.transfer_datetime like '2008-10-31 16:17%'
</cfquery>

<cfset recpts = "">
<cfset thisEmailTo = application.ITCAdminEmail>

<cfloop query="ProgramUsers">
	<cfif url.doit>
		<cfset thisEmailTo = ProgramUsers.email>
	</cfif>
	<cfmail to="#thisEmailTo#" from="#application.AwardsFromEmail#" subject="Henkel Rewards Board" type="html">
<cfif NOT url.doit>
THIS IS A TEST<br />
<hr />
</cfif>
<img src="#application.SecureWebPath#/pics/program/47_image.jpg"> 
<br />
<br />
Dear #ProgramUsers.fname#,<br />
<br />
RE:  Henkel Rewards Board <br />
<br />
On Friday, October 31, 2008 you received an email containing incorrect content regarding the Henkel Rewards program rather than an email explaining the transfer of your Henkel Rewards points to the Kaman PEP program. Below is the correct communication.
<br /><br />
<hr />
<br />
10/31/2008<br />
<br />
#ProgramUsers.fname# #ProgramUsers.lname# <br />
<br />
Dear #ProgramUsers.fname#, <br />
<br />
As a participant in the Henkel Rewards Board, you are accruing points based on your Loctite&reg; Valued Selling activities. Every month, your Henkel Loctite&reg; points are transferred from the Henkel Rewards Board to the Kaman PEP Program. Points earned in both programs are combined into your Kaman PEP points account and can be redeemed through the Kaman PEP award site. Please see below for the total points transferred this month and instructions to log on to the Kaman PEP award site. <br />
<br />
<br />
Points transferred this month: #ProgramUsers.points# <br />
<br />
<br />
To redeem your points: <br />
<br />
Log on to - #application.SecureWebPath#/ <br />
<br />
Enter Company Name: Kaman <br />
<br />
Enter Password: Your password is the first 4 letters of your last name combined with the last 4 digits of your Social Security Number. Do not use spaces or dashes. If your last name consists of fewer than 4 letters, please use your entire last name. Examples: John Smith (smit1234); John Doe (doe1234). <br />
<br />
Press the Submit button. <br />
<br />
Click on View Gifts button. <br />
<br />
Select a PEP Point Credit to start browsing through the award selections. You may select a gift in any award amount to total your PEP Point Credits. <br />
<br />
If there are options, such as color or size, you must first choose your options and then select the gift. <br />
<br />
Once you have found your award choice, click on the picture and then the box marked Select This Gift. <br />
<br />
You may continue shopping or click on View Cart to be forwarded to the Cart Contents Screen where you can verify your award selection and check out. <br />
<br />
To remove a selection, click on the Red X. If your selections are correct, click on the box marked Checkout. <br />
<br />
If you exceed your PEP Point Credits, your personal credit card is needed to complete the transaction. <br />
<br />
Complete your shipping information (i.e. Name, Address). <br />
<br />
It is important to enter your correct email address. Your award confirmation will be sent to you via email only. <br />
<br />
Awards cannot be delivered to Post Office Boxes; please enter only your residential address. <br />
<br />
After all of your information is entered click the button marked Process Order. <br />
<br />
If you have any questions about this program please contact #application.AwardsProgramAdminName#, ITC Awards Administrator, toll free at 1-888-266-6108 or via email at #application.AwardsProgramAdminEmail#. <br />
<br />
<br />
Sincerely, <br />
<br />
#application.AwardsProgramAdminEmail#<br />
ITC Awards<br />
<br />
	</cfmail>
	<cfset recpts = ListAppend(recpts,ProgramUsers.email)>
	<cfif NOT url.doit>
		Sent test email.
		<cfbreak>
	</cfif>
</cfloop>
<br /><br />
End of processing.
<cfif url.doit>
	<cfmail to="#application.ITCAdminEmail#" from="#application.AwardsFromEmail#" subject="Henkel Rewards Board" type="html">
		Sent the apology email to the following:<br /><br />
		<cfloop list="#recpts#" index="x">
			#x#<br />
		</cfloop>
	</cfmail>
</cfif>