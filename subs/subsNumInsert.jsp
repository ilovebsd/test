<%@page import="java.util.Calendar"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
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

String grpid      = StringUtil.null2Str(request.getParameter("groupid"),"");

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

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
<form name="Savelayer" method="post" enctype="multipart/form-data">

<input type="hidden" name="groupid" value="<%=grpid%>"/>

<table width="450" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> 
    	<strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">
    		번호 추가 [ Company ID : <%=grpid%> ]
    	</strong>
    </td>
    <td width="10" align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="6" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7">&nbsp;</td>
    <td width="160" height="10" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="7" bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF" colspan="2">&nbsp;</td>
    <td width="7"></td>
  </tr>  
  <!-- ## start field -->
  <!-- # Phone-Number 
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" colspan="3" align="center" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="center" ><strong> =================== Phone-Number =================== </strong></div>
	</td>
    <td width="7">&nbsp;</td>
  </tr>-->
  <!-- 시작번호 -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> 시작번호 </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<select name="areanum" style="width:180" class="select01">
			<!-- <option value="">사용안함</option> -->
			<option value="070">070</option>
			<%																																						 
			ZipCodeDTO zipCodeDTO = null;
			for (int idx = 0; idx < zipCount ; idx++ ) {
				zipCodeDTO = (ZipCodeDTO)zipCodeList.get(idx);
				if(!"070".equals(zipCodeDTO.getCodeitemcd()))
					out.println("<option value='"+zipCodeDTO.getCodeitemcd()+"'>"+zipCodeDTO.getCodeitemcd()+"</option>") ;
			}
			%>   							
	   	</select>
		<input type="text" name="localnum" style="width:50px" maxlength="4">-<input type="text" name="extnum" style="width:50px" maxlength="4">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- 내선번호 -->
  <!-- <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> 내선번호 </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="extnum" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr> -->
  <!-- 인증암호 -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> 인증암호 </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="authpasswd" width="100">
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
    <td height="35" colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="createcount" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- # Routing 
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" colspan="3" align="center" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="center" ><strong> ====================== Routing ====================== </strong></div>
	</td>
    <td width="7">&nbsp;</td>
  </tr>-->
  <!-- Outbound Proxy IP 
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Outbound Proxy IP </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="outproxyip" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>-->
  <!-- Start Prefix 
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Start Prefix </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="startprefix" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>-->
  <!-- End Prefix 
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> End Prefix </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="endprefix" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>-->
  <!-- Minimum Digit 
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Minimum Digit </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="mindigit" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>-->
  <!-- Maximum Digit 
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Maximum Digit </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="maxdigit" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>-->
  <!-- ## end field -->
  
  <tr>
    <td height="13">&nbsp;</td>
    <td colspan="4" height="13" bgcolor="#FFFFFF">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
     
  <tr>
    <td height="10" colspan="6"></td>
  </tr>   
  <tr align="center">
    <td height="35" colspan="6" style="padding-top:3 "><a href="javascript:goNewSaveDupCheck('num');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image12','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image12" width="40" height="20" border="0"></a>  <a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image74','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image74" width="40" height="20" border="0"></a></td>
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
