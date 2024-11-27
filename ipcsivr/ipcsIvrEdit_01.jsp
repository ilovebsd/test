<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<% 

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

System.out.println("프로그램 로그 : 33333");

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID = Str.CheckNullString(scDTO.getSubsID()).trim();
 */
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;
 
response.setCharacterEncoding("euc-kr");
// String 	ei64		= new String(request.getParameter("e164").getBytes("8859_1"), "euc-kr");			// 음성안내 번호
// String 	scCompany	= new String(request.getParameter("scCompany").getBytes("8859_1"), "utf-8");		// 음성안내 그룹
String 	ei64 		= new String(Str.CheckNullString(request.getParameter("e164")).getBytes("8859_1"), "euc-kr").trim();		//음성안내 번호
String 	scCompany 	= new String(Str.CheckNullString(request.getParameter("scCompany")).getBytes("8859_1"), "utf-8").trim();		//음성안내 그룹
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<%-- <link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css"> --%>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
</head>

<body>
<form name="Editlayer1" method="post">
	<table width="400px" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
	  <tr>
	    <td height="30" colspan="2" style="padding-left:10;padding-top:5 ;" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> 
	    	<strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">음성안내번호 수정 </strong></td>
	    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
	    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
	  </tr>
	  <tr align="right">
	    <td height="6" colspan="4" style="padding-right:10; color:RGB(82,86,88)"></td>
	  </tr>  	  	  
	  
	  <tr>
	    <td height="30">&nbsp;</td>
	    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>
	  	  
	  <tr>
	    <td width="4" height="30">&nbsp;</td>
	    <td width="140px" align="right" bgcolor="#FFFFFF" style="padding-right:5 " colspan=> <div align="right"><strong>음성안내 번호 :</strong></div></td>
	    <td bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtE164" style="width:150" value="<%=ei64%>" disabled></td>
	    <td width="6">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td height="5">&nbsp;</td>
	    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>  
	  	  
	  <tr>
	    <td width="4" height="30">&nbsp;</td>
	    <td width="140px" align="right" bgcolor="#FFFFFF" style="padding-right:5 " colspan=> <div align="right"><strong>음성안내 그룹 :</strong></div></td>
	    <td bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtGroupName" style="width:150" value="<%=scCompany%>"></td>
	    <td width="6">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td height="30">&nbsp;</td>
	    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>
	    
	    
	  <tr align="center">
	    <td height="35" colspan="4" style="padding-top:3 ">
		    <a href="#" onclick="javascript: goSaveEdit();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image3" width="40" height="20" border="0"></a>
		    &nbsp;<a href="#" onclick="javascript: hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a>
	    </td>
	  </tr>
	  	  
	  
	</table>

</form>
</body>
</html>