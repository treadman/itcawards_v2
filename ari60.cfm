<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv=Content-Type content="text/html; charset=ISO-8859-1">
<title>Jacket Sizes</title>
<meta name="GENERATOR" content="Freeway 5 Pro 5.1.2">
<style type="text/css">
<!-- 
body { margin:0px; background-color:#fff; height:100% }
html { height:100% }
img { margin:0px; border-style:none }
button { margin:0px; border-style:none; padding:0px; background-color:transparent; vertical-align:top }
p:first-child { margin-top:0px }
table { empty-cells:hide }
.f-sp { font-size:1px; visibility:hidden }
.f-lp { margin-bottom:0px }
.f-fp { margin-top:0px }
.f-x1 {  }
.f-x2 {  }
.f-x3 {  }
em { font-style:italic }
h1 { font-size:18px }
h1:first-child { margin-top:0px }
strong { font-weight:bold }
.style8 { font-family:Arial,Helvetica,sans-serif; font-size:16px;}
-->
</style>
<!--[if lt IE 7]>
<link rel=stylesheet type="text/css" href="ie6.css">
<![endif]-->

<script type="text/javascript">//<![CDATA[
var usingIEFix = false;
//]]></script>

<!--[if lt IE 7]>
<script type="text/javascript">//<![CDATA[
usingIEFix = true;
//]]></script>
<![endif]-->


<script type="text/javascript">//<![CDATA[

function FWStripFileFromFilterString(filterString)
{
	var start,end;
	var strSrc = "src='";
	var strRes = "";

	start = filterString.indexOf(strSrc);

	if(start != -1)
	{
		start += strSrc.length;
		
		end = filterString.indexOf("',",start);
		if(end != -1)
		{
			strRes = filterString.substring(start,end);
		}
	}

	return strRes;
}


var fwIsNetscape = navigator.appName == 'Netscape';


fwLoad = new Object;
function FWLoad(image)
{
	if (!document.images)
		return null;
	if (!fwLoad[image])
	{
		fwLoad[image]=new Image;
		fwLoad[image].src=image;
	}
	return fwLoad[image].src;
}


fwRestore = new Object;
function FWRestore(msg,chain) 
{
	if (document.images) 
		for (var i in fwRestore)
		{
			var r = fwRestore[i];
			if (r && (!chain || r.chain==chain) && r.msg==msg)
			{
				r.src = FWLoad(r.old);
				fwRestore[i]=null;
			}
		}
}


function FWLSwap(name,msg,newImg,layer,chain,trigger) 
{
	var r = fwRestore[name];
	if (document.images && (!r || r.msg < msg)) 
	{
		var uselayers = fwIsNetscape && document.layers && layer != '';
		var hld;
		if (uselayers)
			hld = document.layers[layer].document;
		else
			hld = document;
		var im = hld.getElementById(name);
		if (!im.old)
		{
			if(usingIEFix && im.runtimeStyle.filter)
				im.old = FWStripFileFromFilterString(im.runtimeStyle.filter);
			else
				im.old = im.src;
		}
		
		im.msg = msg;
		im.chain = chain;
		im.trigger = trigger;
		if (newImg) im.src = FWLoad(newImg);
		fwRestore[name] = im;
	}
}


function FWCallHit(func,targNum,msg)
{
	if(func)
		for (var i in func)
			func[i](targNum,msg);
}
function FW_Hit(frameset,chain,targNum,msg)
{
	if (frameset && frameset.length)
		for (var i=0 ; i <frameset.length ; i++)
		{
			try
			{
				FW_Hit(frameset[i].frames,chain,targNum,msg);
				FWCallHit(top["FT_"+chain],targNum,msg);
				FWCallHit(frameset[i].window["FT_"+chain],targNum,msg);
			}
			catch(err)
			{
			}
		}
	else
		FWCallHit(window["FT_"+chain],targNum,msg);
}


fwHit = new Object;
function FWSlave(frameset,chain,targNum,msg)
{
	if (msg==1) fwHit[chain]=targNum;
	FW_Hit(frameset,chain,targNum,1);
}

function FWSRestore(frameset,chain)
{
	var hit=fwHit[chain];
	if (hit)
		FW_Hit(frameset,chain,hit,0);
	fwHit[chain]=null;
}

function FWPreload()
{
	FWLoad("pics/ari60/mensbttnnormala.jpeg");
	FWLoad("pics/ari60/mensbttnnormal.jpeg");
	FWLoad("pics/ari60/bttnwomensnormala.jpeg");
	FWLoad("pics/ari60/bttnwomensnormal.jpeg");
}
//]]></script></head>
<body onload="FWPreload()">
	<cfinclude template="includes/environment.cfm"> 

<div id="PageDiv" style="position:relative; min-height:100%; margin:auto; width:612px">
	<table border=0 cellspacing=0 cellpadding=0 width=168>
		<colgroup>
			<col width=21>
			<col width=146>
			<col width=1>
		</colgroup>
		<tr valign=top>
			<td height=12 colspan=2></td>
			<td height=12></td>
		</tr>
		<tr valign=top>
			<td height=133></td>
			<td height=133><img src="pics/ari60/ari60th2logocolo.jpeg" border=0 width=146 height=133 alt="ARI60th2logoCOLORSM" style="float:left"></td>
			<td height=133></td>
		</tr>
		<tr class="f-sp">
			<td><img src="pics/ari60/shim.gif" border=0 width=21 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=146 height=1 alt="" style="float:left"></td>
			<td height=30><img src="pics/ari60/shim.gif" border=0 width=1 height=1 alt="" style="float:left"></td>
		</tr>
	</table>
	<table border=0 cellspacing=0 cellpadding=0 width=505>
		<colgroup>
			<col width=98>
			<col width=191>
			<col width=24>
			<col width=191>
			<col width=1>
		</colgroup>
		<tr valign=top>
			<td></td>
			<td colspan="3" align="left" class="style8"><strong>Our 60th Anniversary Thank You Gift</strong><br /><br /><!--- Please select either the mens jacket or the womens jacket<br />by clicking the appropriate button. --->Ordering is now closed.<br /><br /></td>
			<td></td>
		</tr>
		<tr valign=top>
			<td height=205></td>
			<td height=205><img src="pics/ari60/stormtechmensjac.jpeg" border=0 width=191 height=205 alt="StormtechMensJacket" style="float:left"></td>
			<td height=205></td>
			<td height=205><img src="pics/ari60/stormtechwomensj.jpeg" border=0 width=191 height=205 alt="StormTechWomensJacket" style="float:left"></td>
			<td height=205></td>
		</tr>
		<tr class="f-sp">
			<td><img src="pics/ari60/shim.gif" border=0 width=98 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=191 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=24 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=191 height=1 alt="" style="float:left"></td>
			<td height=5><img src="pics/ari60/shim.gif" border=0 width=1 height=1 alt="" style="float:left"></td>
		</tr>
	</table>
<!---	
	<table border=0 cellspacing=0 cellpadding=0 width=472>
		<colgroup>
			<col width=128>
			<col width=129>
			<col width=93>
			<col width=129>
			<col width=1>
		</colgroup>
		<tr valign=top>
			<td height=68></td>
			<td height=68><a href="ari60order.cfm?gender=M" onmouseover="FWRestore(1,'Indigo');FWSRestore(top.frames,'Indigo');FWLSwap('img1',1,'pics/ari60/mensbttnnormal.jpeg','','Indigo')" onmouseout="FWRestore(1,'Indigo');FWSRestore(top.frames,'Indigo')" onclick="setTimeout('FWRestore(2,\'Indigo\');FWLSwap(\'img1\',2,\'pics/ari60/mensbttnnormal.jpeg\',\'\',\'Indigo\')',0)"><img src="pics/ari60/mensbttnnormala.jpeg" border=0 width=129 height=68 alt="MensBttnNormal" style="float:left" id="img1"></a></td>
			<td height=68></td>
			<td height=68><a href="ari60order.cfm?gender=W" onmouseover="FWRestore(1,'Indigo');FWSRestore(top.frames,'Indigo');FWLSwap('img2',1,'pics/ari60/bttnwomensnormal.jpeg','','Indigo')" onmouseout="FWRestore(1,'Indigo');FWSRestore(top.frames,'Indigo')" onclick="setTimeout('FWRestore(2,\'Indigo\');FWLSwap(\'img2\',2,\'pics/ari60/bttnwomensnormal.jpeg\',\'\',\'Indigo\')',0)"><img src="pics/ari60/bttnwomensnormala.jpeg" border=0 width=129 height=68 alt="BttnWomensNormal" style="float:left" id="img2"></a></td>
			<td height=68></td>
		</tr>
		<tr class="f-sp">
			<td><img src="pics/ari60/shim.gif" border=0 width=128 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=129 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=93 height=1 alt="" style="float:left"></td>
			<td><img src="pics/ari60/shim.gif" border=0 width=129 height=1 alt="" style="float:left"></td>
			<td height=1><img src="pics/ari60/shim.gif" border=0 width=1 height=1 alt="" style="float:left"></td>
		</tr>
	</table>
	<table border=0 cellspacing=0 cellpadding=0 width=472>
--->	
</div>
</body>
</html>
