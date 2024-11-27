<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>

<%
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

String 	strE164 	= request.getParameter("e164");
String[] e164s 	= StringUtil.getParser(strE164, "");

String 	mrbtFile	= request.getParameter("filename");

boolean bModify = mrbtFile!=null && mrbtFile.length()>0 ;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<form name="editForm" method="post" enctype="multipart/form-data">
<input type="hidden" name="scLang" value="kor">
<input type="hidden" name="scLogCheck" value="N">
<input type="hidden" name="responseModeSize" value="">

<input type='hidden' name ='e164' 					value="<%=strE164%>"/>
<input type='hidden' name ='hiEi64_03' 				value="<%=strE164%>"/>
<input type='hidden' name ='uploadfilename_03'		value=""/>
<input type='hidden' name ='deleteStr_02' 			value=""/>
<input type='hidden' name ='insertStr_02' 			value=""/>

<input type='hidden' name ='hiUserID'				value="<%=userID%>">

<table width="500" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
<tr height="30" >
  <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="5">
  <table  border="0" cellpadding="0" cellspacing="0" style="TABLE-LAYOUT: fixed">
   <tr>
    <td width="10">&nbsp;</td>
    <td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">통화대기음 <%=bModify?"수정":"등록" %></span></td>
       <td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td width="10">&nbsp;</td>
   </tr>

  </table>
  </td>
 </tr>

	<tr>
	  	<td colspan="5" height="7"></td>
	</tr>

    <tr>
	    <td width="10" height="10">&nbsp;</td>
		<td  colspan="3" bgcolor="#FFFFFF" style="padding-left:5"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="480" align="center"></td>
	    <td width="10">&nbsp;</td>
    </tr>

	<tr>
	    <td width="10" height="25">&nbsp;</td>
	    <td colspan="3"  align="left" bgcolor="#FFFFFF" style="padding-right:5 ">
		    &nbsp;&nbsp;&nbsp;&nbsp;통화대기음 파일&nbsp;&nbsp;
			<input type="file" name="wFile_2" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
		</td>
		<td width="10">&nbsp;</td>
	</tr>
<% if(bModify){ %>
	<tr>
	    <td width="10" height="25">&nbsp;</td>
	    <td colspan="3"  align="left" bgcolor="#FFFFFF" style="padding-right:5 ">
		    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;사용중인 파일&nbsp;&nbsp;&nbsp;&nbsp;<%=mrbtFile%>
		</td>
		<td width="10">&nbsp;</td>
	</tr>
<% } %>
    <tr>
	    <td width="10" height="10">&nbsp;</td>
		<td  colspan="3" bgcolor="#FFFFFF" style="padding-left:5"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="480" align="center"></td>
	    <td width="10">&nbsp;</td>
    </tr>

  	<tr>
	    <td height="35">&nbsp;</td>
	    <td colspan="3" align="center" style="padding-top:3 ">
			<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript:goInsertPro();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
			<img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" onClick="hiddenAdCodeDiv();" width="40" height="20">
		</td>
	    <td>&nbsp;</td>
  </tr>

</table>
</form>
</body>
</html>
