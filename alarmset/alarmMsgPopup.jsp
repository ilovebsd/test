<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="waf.*"%>
<%@ page import="com.acromate.util.Str"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

response.setCharacterEncoding("euc-kr");

/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID   = Str.CheckNullString(scDTO.getSubsID()).trim();
*/

String titlemsg = new String (Str.CheckNullString(request.getParameter("titlemsg")).getBytes("8859_1"), "utf-8");
String msg      = new String (Str.CheckNullString(request.getParameter("msg")).getBytes("8859_1"), "utf-8");

%>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz Æ÷Å»</title>

<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

</head>
<body>
<form name="Deletelayer1" method="post">

	<table width="307" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
      <tr>
        <td colspan="2" height="30" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:±¼¸²Ã¼;font-size:10pt; text-decoration:none; color:RGB(255,255,255);"><%=titlemsg%></strong></td>
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
	    <td height="25" colspan="2"><B><%=msg%></B></td>
	    <td width="8"></td>
	  </tr>
	  <tr>
	    <td colspan="4">&nbsp;</td>
	  </tr>	  
	  <tr align="center">
	    <td colspan="4"><a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image33','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image33" width="40" height="20" border="0"></a></td>
	  </tr>
	  <tr align="center">
	    <td colspan="4">&nbsp;</td>
	  </tr>
	</table>
	
</form>
</body>
</html>

