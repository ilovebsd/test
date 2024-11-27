<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="dto.ZipCodeDTO" %>
<%@ page import="business.ZipCode"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.util.*" %>
<%@ page import="com.acromate.util.Str"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

String firstNumber = Str.CheckNullString( request.getParameter("e164") ) ;
String fstAreaNum = "", fstLocalNum = "", fstLastNum = ""; 

if(firstNumber.length()>4)
	fstLastNum = firstNumber.substring(firstNumber.length()-4) ;

int 	zipCount = 0;
List 	zipCodeList = null;
//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt = null;
try{
	stmt = ConnectionManager.allocStatement("EMS");
	ZipCode	zipCode		= new ZipCode();
	zipCodeList = zipCode.getData(stmt);	// 지역번호 데이타 조회
	zipCount = zipCodeList.size();
}catch(Exception ex){
	ex.printStackTrace() ;
	if(nModeDebug==1){
		zipCodeList 	= new ArrayList<ZipCodeDTO>();
		ZipCodeDTO zipCodeDTO = new ZipCodeDTO("02","서울(02)" );
		zipCodeList.add(zipCodeDTO) ;
		zipCount = zipCodeList.size();
	}
}
if (stmt != null) ConnectionManager.freeStatement(stmt);

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="Updatelayer1" method="post" >
<table width="450" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="3" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">
    	<strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">내선번호 변경</strong>
    </td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="5" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7">&nbsp;</td>
    <td width="160" height="10" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="7" bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="7"></td>
  </tr>  
  <!-- ## start field -->
  <!-- 시작번호 -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> 전화번호의 시작번호 </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<select name="areanum" style="width:60px" class="select01">
			<!-- <option value="">사용안함</option> -->
			<!-- <option value="070">070</option> -->
			<%																																						 
			ZipCodeDTO zipCodeDTO = null;
			for (int idx = 0; idx < zipCount ; idx++ ) {
				zipCodeDTO = (ZipCodeDTO)zipCodeList.get(idx);
				//if(!"070".equals(zipCodeDTO.getCodeitemcd())){
					if(firstNumber.startsWith(zipCodeDTO.getCodeitemcd())){
						fstAreaNum = zipCodeDTO.getCodeitemcd();
						if(fstAreaNum.length()+fstLastNum.length() > 0)
							fstLocalNum = firstNumber.substring(fstAreaNum.length(), firstNumber.length()-4);
						out.println("<option value='"+zipCodeDTO.getCodeitemcd()+"' selected>"+zipCodeDTO.getCodeitemcd()+"</option>") ;
					}else
						out.println("<option value='"+zipCodeDTO.getCodeitemcd()+"'>"+zipCodeDTO.getCodeitemcd()+"</option>") ;
				//}
			}
			%>   							
	   	</select>
    	<input type="text" name="localnum" style="width:50px" maxlength="4" value="<%=fstLocalNum%>" onkeydown="return onlyNumber(event);">
    	- <input type="text" name="extnum" style="width:50px" maxlength="4" value="<%=fstLastNum%>" onkeydown="return onlyNumber(event);">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- 내선번호 -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> 내선번호 시작번호 </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="startextnum" width="100" maxlength="4" onkeydown="return onlyNumber(event);" >
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- 생성할 번호 개수 -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> 생성할 번호 개수 </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="createcount" width="100" onkeydown="return onlyNumber(event);" >
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- ## end field -->
  
  <tr>
    <td height="13">&nbsp;</td>
    <td colspan="3" height="13" bgcolor="#FFFFFF">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
     
  <tr>
    <td height="10" colspan="5"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="5" style="padding-top:3 "><a href="javascript:goExtNumUpdatePro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image12','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image12" width="40" height="20" border="0"></a>  <a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image74','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image74" width="40" height="20" border="0"></a></td>
  </tr>
</table>

<input type="hidden" name="checkDupCount" value="0" >

<table width="100%" border="0">
  <tr>
    <th scope="row">&nbsp;</th>
  </tr>
</table>
</form>
</body>
</html>
