<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.SubscriberInfoDTO" %>
<%@ page import="dto.DeptDTO" %>
<%@ page import="buddy.DeptList" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>
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

String userName   = Str.CheckNullString(scDTO.getName()).trim();
String userID     = Str.CheckNullString(scDTO.getSubsID()).trim();
String loginLevel = Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // 관리레벨(1:사용자, 2:관리자)
String menu       = "";  // 
String submenu    = "";  // 

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<title>Biz 포탈</title>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
</head>

<body onLoad="MM_preloadImages('<%=StaticString.ContextRoot%>/imgs/menu_calllist_select_btn.gif','<%=StaticString.ContextRoot%>/imgs/menu_premium_select_btn.gif')">
<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

<!--strat--상단페이지-->
<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td>
	<%@ include file="/menu/topMenu.jsp"%>
	</td>
  </tr>
</table>
<!--end--상단페이지-->

<table width="1000" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td >
		<!--strat--왼쪽페이지-->
		<table width="165" border="0" cellspacing="0" cellpadding="0"  align="left">
		<%  if("1".equals(loginLevel)){ %>
		<%@ include file="/menu/leftUserMenu.jsp"%>
		<%  }else if("2".equals(loginLevel)){   %>
		<%@ include file="/menu/leftAdminMenu.jsp"%>
		<%  }   %>
		</table>
		<!--end--왼쪽페이지-->

		<table width="835" border="0" cellspacing="0" cellpadding="0" align="left">
		  <tr>
		    <td>
		      <!--start_검색부분-->
		      <table width="835" border="0" cellspacing="0" cellpadding="0" align="left" style="margin:8 0 8 0 ">		
				  <tr>
				    <td width="835" height="35" bgcolor="#FFFFFF" style="padding-left:8"><p>&nbsp;</p>
				      <p><font color="RGB(82,86,88)"><br>
				              <br>
				              <img src="imgs/content_errormessage_img.gif" alt="Error Message" width="830" height="300"></font></p></td>
				  </tr>
			  </table>	
			  <!--end_검색부분-->
			</td>
		  </tr>
		</table>		
		<!--end--콘텐츠페이지-->

    </td>
  </tr>
</table>
</body>
</html>
