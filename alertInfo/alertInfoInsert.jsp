<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
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
<title>통화수신음</title>
</head>

<body>
<form name="Savelayer" method="post">
<input type='hidden' name ='dataType'	value="">

<table width="180" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">통화수신음 추가</strong></td>
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
    <td width="7" height="195">&nbsp;</td>
    <td colspan="2" align="center" bgcolor="#FFFFFF" valign="top">
        <table width="140" border="0" cellspacing="0" cellpadding="0"  class="list_table">
            <tr align="center" height="22" >
              	<td width="140" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">통화수신음 종류</td>
            </tr>
        </table>
        <table width="140" border="0" cellspacing="0" cellpadding="0"  class="list_table">
            <tr height="22" bgcolor="#F3F9F5">
              <td width="140" align="left">
              	<input type="radio" name="alertInfo" value="1" id="alertInfo_1">&nbsp;수신음 1<br>
              </td>
            </tr>
            <tr height="22" bgcolor="#F3F9F5" align="center" >
              <td width="140" align="left">
              	<input type="radio" name="alertInfo" value="2" id="alertInfo_2">&nbsp;수신음 2<br>
              </td>
            </tr>
            <tr height="22" bgcolor="#F3F9F5" align="center" >
              <td width="140" align="left">
              	<input type="radio" name="alertInfo" value="3" id="alertInfo_3">&nbsp;수신음 3<br>
              </td>
            </tr>
            <tr height="22" bgcolor="#F3F9F5" align="center" >
              <td width="140" align="left">
              	<input type="radio" name="alertInfo" value="4" id="alertInfo_4">&nbsp;수신음 4<br>
              </td>
            </tr>
            <tr height="22" bgcolor="#F3F9F5" align="center" >
              <td width="140" align="left">
              	<input type="radio" name="alertInfo" value="5" id="alertInfo_5">&nbsp;수신음 5<br>
              </td>
            </tr>
            <tr height="22" bgcolor="#F3F9F5" align="center" >
              <td width="140" align="left">
              	<input type="radio" name="alertInfo" value="6" id="alertInfo_6">&nbsp;수신음 6<br>
              </td>
            </tr>
            <tr height="22" bgcolor="#F3F9F5" align="center" >
              <td width="140" align="left">
              	<input type="radio" name="alertInfo" value="7" id="alertInfo_7">&nbsp;수신음 7<br>
              </td>
            </tr>
        </table>
    </td>
    <td width="7"></td>
  </tr>
     
  <tr>
    <td height="5" colspan="4"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="4" style="padding-top:3 "><a href="javascript:goNewSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image33','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image33" width="40" height="20" border="0"></a></td>
  </tr>
</table>



<table width="100%" border="0">
  <tr>
    <th  scope="row">&nbsp;</th>
  </tr>
</table>
</form>
</body>
</html>