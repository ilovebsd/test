<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

// String type      	= new String(request.getParameter("type")).trim();
// String ei64			= new String(request.getParameter("e164").getBytes("8859_1"), "euc-kr");

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;

String type     = new String(request.getParameter("type")).trim();
String e164 	= request.getParameter("e164") ;
String ei64		= e164==null?"":new String(e164.getBytes("8859_1"), "euc-kr");
String[] e164s 	= StringUtil.getParser(ei64, "");

String		tempStr 		= type+",a";
String[]	tempStr2		= tempStr.split("[,]");
String		displayNumber	= type.length()==0?"": tempStr2[1];                                                      
String		fromNumber		= type.length()==0?"": tempStr2[2];
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="editForm" method="post">
<input type='hidden' name ='e164' 		value="<%=ei64%>"/>

<table width="240" height="155" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> 
    	<strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">가상발신번호 <%=type.length()==0?"등록":"수정"%></strong>
    </td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="4" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7" height="10"></td>
    <td width="76" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
  
  <tr>
    <td width="7">&nbsp;</td>
    <td colspan="2" align="center" bgcolor="#FFFFFF" valign="top">
        <table width="200" border="0" cellspacing="0" cellpadding="0"  class="list_table">
            <tr height="10" bgcolor="#F3F9F5" align="center" ><td></td></tr>
            <tr height="22" bgcolor="#F3F9F5">
              <td width="200" align="left">&nbsp;&nbsp;&nbsp;가상발신번호
              	<input type='text' name='txtDisplayNumber' id="txtDisplayNumber" value="<%=displayNumber.trim()%>" style='width:95; margin:0 0 0 0' maxlength="14">
              </td>
            </tr>
            <tr height="5" bgcolor="#F3F9F5" align="center" ><td></td></tr>
            <tr height="22" bgcolor="#F3F9F5" align="center" >
              <td width="200" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;인증번호
              	<input type='text' name='txtFromNumber' id="txtFromNumber" value="<%=fromNumber.trim()%>" style='width:95; margin:0 0 0 0' maxlength="14">
              </td>
            </tr>
            
            <tr height="5" bgcolor="#F3F9F5" align="center" ><td></td></tr>
            <tr height="0" bgcolor="#F3F9F5" align="center" style="display: none;">
              <td width="260" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;패스워드
              	<input type='password' name='txtPasswd' id="txtPasswd" value="" style='width:95; margin:0 0 0 0' maxlength="14">
              </td>
            </tr>
            
            <tr height="10" bgcolor="#F3F9F5" align="center" ><td></td></tr>
        </table>
    </td>
    <td width="7"></td>
  </tr>
  <tr>
    <td width="7" height="10"></td>
    <td width="76" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
     
  <tr>
    <td height="5" colspan="4"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="4" style="padding-top:3 "><!-- onClick='vcidAdminCheck_Edit()' -->
		<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript:goInsertPro();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
	  	<img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" onClick="hiddenAdCodeDiv();" width="40" height="20">
    </td>
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
