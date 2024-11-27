<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="business.CommonData"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<% 
System.out.println("프로그램 로그_03 : 11111");

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

System.out.println("프로그램 로그_03 : 22222");

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

System.out.println("프로그램 로그_03 : 33333");

response.setCharacterEncoding("euc-kr");

String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// SIP 단말ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// 전체 전화번호
String 	pwd			= new String(request.getParameter("hiPwd").getBytes("8859_1"), "euc-kr");			// 비밀번호
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr");		// 내선번호

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String 		userID 	= Str.CheckNullString(scDTO.getSubsID()).trim();

System.out.println("프로그램 로그_02 : 4444444");
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>


</head>
<body>
<form name="Insertlayer3" method="post">


<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">개인내선번호 추가 </strong></td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="6" colspan="7" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  	  
  <tr>
    <td width="4"></td>
    <td colspan="4" height="10" bgcolor="#FFFFFF"><br>&nbsp;
      번호가 성공적으로 추가 되었습니다. </td>
    <td width="6"></td>
  </tr>  
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td colspan="4" align="right" bgcolor="#FFFFFF" style="padding-right:5 "><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center"></td>
    <td width="6">&nbsp;</td>
  </tr>  
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td width="90" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <div align="right"><strong>아이디 :</strong></div></td>
    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtID" style="width:150" value="<%=endPointID%>" disabled></td>
    <td width="6">&nbsp;</td>
  </tr>
<!--
  <tr>
    <td height="30">&nbsp;</td>
    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "><div align="right"><strong>비밀번호 :</strong></div></td>
    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtPwd" style="width:150" value="<%//=pwd%>" disabled></td>
    <td>&nbsp;</td>
  </tr>
-->
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td width="90" align="center" bgcolor="#FFFFFF" style="padding-right:5 "> <div align="right"><strong>내선번호 :</strong></div></td>
    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtExtension" style="width:150" value="<%=extension%>" disabled></td>
    <td width="6">&nbsp;</td>
  </tr>  
  <tr>
    <td width="4" height="0">&nbsp;</td>
    <td colspan="4" rowspan="2" align="right" bgcolor="#FFFFFF"></td>
    <td width="6">&nbsp;</td>
  </tr>  
  <tr>
    <td width="4" height="0">&nbsp;</td>
    <td width="6">&nbsp;</td>
  </tr>    
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center"></td>
    <td width="6">&nbsp;</td>
  </tr>    
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td colspan="4" rowspan="2" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td width="6">&nbsp;</td>
  </tr>     
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td width="6">&nbsp;</td>
  </tr>    
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="6">&nbsp;</td>
  </tr>    
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td width="90" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td width="203" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="32" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td width="65" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="6">&nbsp;</td>
  </tr>    
  <tr>
    <td width="4" height="30">&nbsp;</td>
    <td width="90" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="6">&nbsp;</td>
  </tr>  
  <tr>
    <td width="4"></td>
    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
    <td width="6"></td>
  </tr>   
  <tr align="center">
    <td height="35" colspan="6" style="padding-top:3 "><a href="#" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','<%=StaticString.ContextRoot%>/imgs/Content_before_p_btn.gif',0)"></a> <a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image3" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:goNextSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_addcontinue_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_addcontinue_n_btn.gif" name="Image4" width="64" height="20" border="0"></a></td>
  </tr>
</table>



<table width="100%" border="0">
  <tr>
    <th scope="row">&nbsp;</th>
  </tr>
</table>
</form>
</body>
</html>