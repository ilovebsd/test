<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<% 
response.setHeader("Pragma", "No-cache");
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>인터컴</title>
</head>

<body>
<form name="Savelayer" method="post">
<input type='hidden' name ='dataType'	value="">

<table width="240" height="155" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">
      <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">입력값 추가</strong>
    </td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">
      <img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand">
    </td>
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
              <td width="200" align="left">&nbsp;입력값
              	<input type='text' name='txtNumber' id="txtNumber" value="" style='width:95; margin:0 0 0 0' maxlength="14">
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
    <td height="35" colspan="4" style="padding-top:3 ">
		<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript:goNewSave();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
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
