<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.util.Str"%>
<% 

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID 		= Str.CheckNullString(scDTO.getSubsID()).trim();
String forwardingIp	= new String(request.getParameter("forwardingIp").getBytes("8859_1"), "euc-kr");
System.out.println("######### forwardingIp : "+forwardingIp);

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

</head>
<body>
<form name="ipForwarding" method="post">
<input type='hidden' name = 'hiForwardingIp'	value="<%=forwardingIp%>">

	<table width="307" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
	  <tr>
        <td colspan="2" height="30" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">단말접속 알림</strong></td>
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
	    <td height="25" colspan="2"><B>포트포워딩 방식으로 접속하시겠습니까?</B></td>
	    <td width="8"></td>
	  </tr>
	  
	  <tr align="center">
	    <td width="39" align="right">&nbsp;</td>
	    <td height="25" align="left" colspan="2">&nbsp;&nbsp;&nbsp;단말 포트&nbsp;&nbsp;<input type="text" name="txtPort" id="txtPort" value="" style="width:80" maxlength="4"></td>
	    <td width="8"></td>
	  </tr>
	  
	  <tr>
	    <td colspan="4">&nbsp;</td>
	  </tr>	  
	  <tr align="center">
	    <td colspan="4"><a href="javascript:ipForwarding_OK();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image33','','<%=StaticString.ContextRoot%>/imgs/Content_yes_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_yes_n_btn.gif" name="Image33" width="48" height="20" border="0"></a>&nbsp;<a href="javascript:ipForwarding_NO();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image441','','<%=StaticString.ContextRoot%>/imgs/Content_no_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_no_n_btn.gif" name="Image441" width="48" height="20" border="0"></a></td>
	  </tr>
	  <tr align="center">
	    <td colspan="4">&nbsp;</td>
	  </tr>
	</table>
	
</form>
</body>
</html>

