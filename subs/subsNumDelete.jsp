<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="dto.ZipCodeDTO" %>
<%@ page import="business.ZipCode"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.util.*" %>

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

<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">

</head>
<body>
<form name="Deletelayer1" method="post">
	
	<input type="hidden" name="groupid" value="<%=grpid%>"/>
	
	<table width="357" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
	  <tr>
        <td colspan="2" height="30" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> 
        	<strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">전화번호 삭제 [ <%=grpid%> ]</strong>
        </td>
        <td width="15" align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
        <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
      </tr>  	  
	  <tr>
	    <td width="39">&nbsp;</td>
	    <td width="245"></td>
	    <td width="15"></td>
	    <td width="8"></td>
	  </tr>
	  <tr>
	    <td colspan="4" align="center"> 
	    	<table border="0">
	  			<tr>
				  	<td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
				  		<div align="right"><strong> 시작번호 </strong></div>
				  	</td>
				    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
				    	<!--  -->
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
				    	<!--  -->
				    </td>
				  </tr>
				  <tr>
				  	<td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
				  		<div align="right"><strong> 삭제할 번호 개수 </strong></div>
				  	</td>
				    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
				    	<input type="text" name="deletecount" width="100">
				    </td>
				  </tr>  		
	    	</table>
	    </td>
	  </tr>
	  
	  <tr align="center">
	    <td width="39" align="right"><img src="<%=StaticString.ContextRoot%>/imgs/alarm_question_img.gif" width="32" height="37"></td>
	    <td height="25" colspan="2"><B>삭제 하시겠습니까?</B></td>
	    <td width="8"></td>
	  </tr>
	  <tr>
	    <td colspan="4">&nbsp;</td>
	  </tr>	  	  
	  <tr align="center">
	    <td colspan="4"><a href="javascript:goNumDeletePro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image3" width="40" height="20" border="0"></a>&nbsp;<a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
	  </tr>
	  <tr align="center">
	    <td colspan="4">&nbsp;</td>
	  </tr>
	</table>
	
</form>
</body>
</html>

