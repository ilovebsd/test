<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
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

String 	endPointID	= new String(request.getParameter("endPointID").getBytes("8859_1"), "euc-kr");	// SIP 단말ID
String 	ei64		= new String(request.getParameter("e164").getBytes("8859_1"), "euc-kr");		// 전체 전화번호

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID = Str.CheckNullString(scDTO.getSubsID()).trim();

%>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

</head>
<body>
<form name="Deletelayer1" method="post">
<input type='hidden' name ='hiEndPointID' 		value="<%=endPointID%>">
<input type='hidden' name ='hiEi64' 			value="<%=ei64%>">

	<table width="307" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
	  <tr>
	    <!--td align="right" colspan="3"><img src="<%//=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td-->
        <td colspan="2" height="30" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">개인내선번호/단말 삭제</strong></td>
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
	    <td height="25" colspan="3"> <B>사용자 계정을 삭제 하시겠습니까 ?</B> </td>
	  </tr>
	  <tr>
	    <td colspan="4">&nbsp;</td>
	  </tr>	  
	  <!--
	  <tr>
	    <td width="39" rowspan="2" align="right"><img src="<%//=StaticString.ContextRoot%>/imgs/alarm_question_img.gif" width="32" height="37"></td>
	    <td colspan="2" width="242" align="left">&nbsp;<input name="deleteType" type="radio" style="width:15" value="Y" checked>
	    개인 정보와 함께 번호 / 아이디도 삭제</td>
	    <td width="8"></td>
	  </tr>
	  <tr>
	    <td align="left">&nbsp;<input name="deleteType" type="radio" style="width:15" value="N">
	    개인 정보만 삭제 </td>
	    <td width="8"></td>
	  </tr>
	  -->
	  <tr>
	    <td colspan="4">&nbsp;</td>
	  </tr>	  
	  <tr align="center">
	    <td colspan="4"><a href="#" onclick="javascript:goDelete();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3999','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image3999" width="40" height="20" border="0"></a>&nbsp;<a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4999','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4999" width="40" height="20" border="0"></a></td>
	  </tr>
	  <tr align="center">
	    <td colspan="4">&nbsp;</td>
	  </tr>
	</table>
	
</form>
</body>
</html>

