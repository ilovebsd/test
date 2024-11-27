<%@page import="java.util.Calendar"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

if(1!=1){
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
	String phoneNum   = Str.CheckNullString(scDTO.getPhoneNum()).trim();
	String loginLevel = Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // 관리레벨(1:사용자, 2:관리자)
}  

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="Savelayer" method="post" enctype="multipart/form-data">
<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td colspan="3" height="30" align="center" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);"> 로그인</strong></td>
    <td colspan="3" align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td colspan="1" width="7" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td colspan="7" height="8" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 "><div align="right" > </div></td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="150" height="35" align="left" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
	</td>
    <td colspan="2" width="7" bgcolor="#FFFFFF"></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right" ><strong> ID </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td colspan="1" height="35" align="left" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<label>
      		<input type="text" name="loginid" tabindex="1"/>
		</label>
	</td>
	<td colspan="2" rowspan="2" height="35" bgcolor="#FFFFFF">
		<a href="javascript:onLoginPro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image12','','<%=StaticString.ContextRoot%>/imgs/Login_login_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Login_login_n_btn.gif" name="Image12" width="60" height="60" border="0" tabindex="3"></a>
	</td>
	<td>&nbsp;</td>
  </tr>
  <tr>
    <td width="7" height="35">&nbsp;</td>
    <td width="79" height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 
    	<div align="right"><strong> 비밀번호 </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td colspan="1" height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
	      <input type="password" name="psword" tabindex="2" onkeypress="javascript:if(event.keyCode == 13){onLoginPro();}" />
	</td>
	<!-- <td colspan="1" height="35" bgcolor="#FFFFFF">&nbsp;</td> -->
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="13">&nbsp;</td>
    <td colspan="3" height="13" bgcolor="#FFFFFF">&nbsp;</td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
     
  <tr>
    <td colspan="7" height="10"></td>
    </tr>   

</table>
</form>
</body>
</html>
