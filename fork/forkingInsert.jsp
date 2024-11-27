<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="com.acromate.util.Str"%>
<% 

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 


HttpSession ses	= request.getSession();
String e164 = request.getParameter("e164") ;
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

</head>
<body>
<form name="Insertlayer1" method="post">
	
	<input type="hidden" name="e164" value="<%=e164%>"/>
	
	<table width="307" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
	  <tr>
        <td colspan="2" height="30" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">원넘버멀티폰 추가</strong></td>
        <td width="15" align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
        <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
      </tr>  	  
	  <tr>
	    <td width="39">&nbsp;</td>
	    <td width="245"></td>
	    <td width="15"></td>
	    <td width="8"></td>
	  </tr>
	  <tr align="center">
	    <td width="39" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/alarm_question_img.gif" width="32" height="37"></td>
	    <td height="25" colspan="2"><B>원넘버멀티폰을 추가 하시겠습니까?</B></td>
	    <td width="8"></td>
	  </tr>
	  <tr>
	    <td colspan="4">&nbsp;</td>
	  </tr>	  
	  <tr align="center">
	    <td colspan="4"><a href="javascript:goInsertPro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image3" width="40" height="20" border="0"></a>&nbsp;<a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
	  </tr>
	  <tr align="center">
	    <td colspan="4">&nbsp;</td>
	  </tr>
	</table>
	
</form>
</body>
</html>

