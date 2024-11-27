<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.util.Str"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

/* SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
} 
HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID = Str.CheckNullString(scDTO.getSubsID()).trim();
*/

HttpSession 		ses 		= request.getSession();
String userID = (String)ses.getAttribute("login.user") ;
String checkgroupid = (String)ses.getAttribute("login.name") ;

String 	endpointId	= new String(request.getParameter("endpointId").getBytes("8859_1"), "euc-kr");	// SIP 단말ID

%>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

</head>
<body>
<form name="unRegisterLayer" method="post">
<input type='hidden' name ='hiUnEndpointId' 		value="<%=endpointId%>">

	<table width="357" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
	  <tr>
        <td colspan="2" height="30" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">등록 해제</strong></td>
        <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
        <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
      </tr>  	  
	  <tr>
	    <td width="39">&nbsp;</td>
	    <td width="245"></td>
	    <td width="65"></td>
	    <td width="8"></td>
	  </tr>
	  <tr align="center">
	    <td width="39" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/alarm_question_img.gif" width="32" height="37"></td>
	    <td height="25" colspan="2"><B>단말기 등록을 해제하시겠습니까?</BR></BR>현재 통화 중인 단말은 통화가 강제 종료됩니다.</B></td>
	    <td width="8"></td>
	  </tr>
	  <tr>
	    <td colspan="4">&nbsp;</td>
	  </tr>	  
	  <tr align="center">
	    <td colspan="4"><a href="javascript: unRegisterPro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image33','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image33" width="40" height="20" border="0"></a>&nbsp;<a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image444','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image444" width="40" height="20" border="0"></a></td>
	  </tr>
	  <tr align="center">
	    <td colspan="4">&nbsp;</td>
	  </tr>
	</table>
	
</form>
</body>
</html>

