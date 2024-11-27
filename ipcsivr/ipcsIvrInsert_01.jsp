<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dto.ZipCodeDTO" %>
<%@ page import="business.ZipCode"%>
<%@ page import="business.CommonData"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<% 

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

System.out.println("프로그램 로그 : 33333");

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID = Str.CheckNullString(scDTO.getSubsID()).trim();
 */
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;
 
//String 	endPointID	= request.getParameter("hiEndPointID");							// SIP 단말ID
//String 	ei64		= request.getParameter("hiEi64");								// 전체 전화번호
//String 	extension	= request.getParameter("hiExtension");							// 내선번호
String	areacode	= StringUtil.null2Str(request.getParameter("hiAreaCode"),"070");	// 지역번호

//서버로부터 DataStatement 객체를 할당
ZipCode	zipCode		= new ZipCode();
List 	zipCodeList = zipCode.getData();//지역번호 데이타 조회
int zipCount = zipCodeList.size();
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt2 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);
CommonData		commonData	= new CommonData();
String 			groupid 	= commonData.getGroupID(stmt2);			// 가입자 그룹 조회
String 			domainID 	= commonData.getDomain(stmt2);			// 도메인 조회
String 			zoneCode 	= commonData.getZone(stmt2);			// 망관리 조회
String 			prefixID 	= commonData.getPrefixTableID(stmt2);	// 번호정책 조회

//할당받은 DataStatement 객체는 반납
if (stmt2 != null) ConnectionManager.freeStatement(stmt2);
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<%-- <link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css"> --%>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
</head>

<body>
<form name="Insertlayer1" method="post">
<input type='hidden' name ='hiGroupID' 	value="<%=groupid%>">
<input type='hidden' name ='hiDomainID' value="<%=domainID%>">
<input type='hidden' name ='hiZoneCode' value="<%=zoneCode%>">
<input type='hidden' name ='hiPrefixID' value="<%=prefixID%>">
<input type='hidden' name ='hiUserID'	value="<%=userID%>">

	<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
	  <tr>
	    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">음성안내번호 추가 </strong></td>
	    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
	    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
	  </tr>
	  <tr align="right">
	    <td height="6" colspan="6" style="padding-right:10; color:RGB(82,86,88)"></td>
	  </tr>  	  	  
	  
	  <tr>
	    <td height="5">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>  
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>번호타입 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <select name="numberType" style="width:120 " class="select01" onChange="NumberTypeChange()">
	        <option value="">선택하세요</option>
	        <option value="1">직통번호로 등록</option>
			<option value="2">단축번호로 등록</option>
	      </select>
		</td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>

	  <tr>
	    <td height="10">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>음성안내번호 </strong></td>
	    <td colspan="3" align="left" valign="bottom" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <div id="div1" name="div1" style="position:absolute; left:124px; top:97px; width:400px; overflow:hidden;">
		    <select name="areaNo" style="width:120px" class="select01"  onChange="AreaNoSelect()" disabled>
				<%																																						 
				ZipCodeDTO zipCodeDTO = null;
				for (int idx = 0; idx < zipCount ; idx++ ) {
					zipCodeDTO = (ZipCodeDTO)zipCodeList.get(idx);
				%>																											
				<option <%if(areacode.equals(zipCodeDTO.getCodeitemcd())){%> selected <%}%> value="<%=zipCodeDTO.getCodeitemcd()%>"><%=zipCodeDTO.getCodeitemdesc()%></option>
				<% 
				}
				%>   							
		   	</select>&nbsp;-&nbsp;<input type="text" name="txtNumber1" style="width:40" value="" size="4" maxlength="4">&nbsp;-&nbsp;<input type="text" name="txtNumber2" style="width:40" value="" size="4" maxlength="4">
		  </div>
		  <div id="div2" name="div2" style="position:absolute; left:124px; top:97px; width:400px; overflow:hidden;">
			<input type="text" name="txtExtension" style="width:120px" value="" size="10" maxlength="10" disabled>
		  </div>
		</td>
		<td width="10">&nbsp;</td>
	  </tr>  

	  <tr>
	    <td height="10">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>음성안내그룹 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <input type="text" name="txtName" style="width:200 ">
		</td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td height="30">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>
	    
	    
	  <tr align="center">
	    <td height="35" colspan="6" style="padding-top:3 ">
		    <a href="#" onclick="javascript: goUserInfoInsert();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image72','','<%=StaticString.ContextRoot%>/imgs/Content_next_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_next_n_btn.gif" name="Image72" width="40" height="20" border="0"></a>
		    &nbsp;<a href="#" onclick="javascript: hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image74','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image74" width="40" height="20" border="0"></a>
	    </td>
	  </tr>
	  
	  
	  
	</table>

</form>
</body>
</html>