<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dto.organization.DeptListDTO" %>
<%@ page import="dto.organization.PositionDTO" %>
<%@ page import="business.CommonData"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<% 
//System.out.println("프로그램 로그_02 : 11111");

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

//System.out.println("프로그램 로그_02 : 22222");

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

//System.out.println("프로그램 로그_02 : 33333");
request.setCharacterEncoding("euc-kr");

String 	groupid		= new String(request.getParameter("hiGroupID").getBytes("8859_1"), "euc-kr");		// 가입자 그룹ID
String 	domainID	= new String(request.getParameter("hiDomainID").getBytes("8859_1"), "euc-kr");		// 도메인
String 	zoneCode	= new String(StringUtil.null2Str(request.getParameter("hiZoneCode"),"").getBytes("8859_1"), "euc-kr");		// 망관리
String 	prefixID	= new String(request.getParameter("hiPrefixID").getBytes("8859_1"), "euc-kr");		// 번호정책
String 	endPointID	= new String(request.getParameter("hiEndPointID").getBytes("8859_1"), "euc-kr");	// SIP 단말ID
String 	ei64		= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");			// 전체 전화번호
String 	extension	= new String(request.getParameter("hiExtension").getBytes("8859_1"), "euc-kr");		// 내선번호
String 	areacode	= new String(request.getParameter("hiAreaCode").getBytes("8859_1"), "euc-kr");		// 지역번호
String	e164Route2	= new String(request.getParameter("hiE164Route2").getBytes("8859_1"), "euc-kr");	// 지역번호 제외한 전화번호
String 	numberType	= new String(request.getParameter("hiNumberType").getBytes("8859_1"), "euc-kr");	// 내선번호 유형(1:직통번호, 2:단축번호)

String	mac			= new String(request.getParameter("hiMac").getBytes("8859_1"), "euc-kr");			// Mac
String	macDisplay	= request.getParameter("hiMacDisplay");		// 
String	macWanIp	= new String(request.getParameter("hiMacIp").getBytes("8859_1"), "euc-kr");			// 
String	macAuto		= new String(request.getParameter("hiMacAuto").getBytes("8859_1"), "euc-kr");		// 
String	macAutoNo	= new String(request.getParameter("hiMacAutoNo").getBytes("8859_1"), "euc-kr");		// 
String	macAddrType	= new String(request.getParameter("hiMacAddrType").getBytes("8859_1"), "euc-kr");	// 콜박스주소 (1: IP, 2: Domain)

//System.out.println("콜박스주소 : "+macAddrType);

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID = Str.CheckNullString(scDTO.getSubsID()).trim();

//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");

CommonData	commonData		= new CommonData();
List 		deptList 		= commonData.getDeptList(stmt);		// 부서명 조회
int 		deptCount 		= deptList.size();

List 		positionList 	= commonData.getPositionList(stmt);	// 직급 데이타 조회
int 		positionCount 	= positionList.size();

//할당받은 DataStatement 객체는 반납
if (stmt != null) ConnectionManager.freeStatement(stmt);

//System.out.println("프로그램 로그_02 : 4444444");
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>


</head>
<body>
<form name="Insertlayer2" method="post">
<input type='hidden' name ='hiGroupID' 		value="<%=groupid%>">
<input type='hidden' name ='hiDomainID' 	value="<%=domainID%>">
<input type='hidden' name ='hiZoneCode' 	value="<%=zoneCode%>">
<input type='hidden' name ='hiPrefixID' 	value="<%=prefixID%>">
<input type='hidden' name ='hiEndPointID' 	value="<%=endPointID%>">
<input type='hidden' name ='hiEi64' 		value="<%=ei64%>">
<input type='hidden' name ='hiExtension' 	value="<%=extension%>">
<input type='hidden' name ='hiAreaCode' 	value="<%=areacode%>">
<input type='hidden' name ='hiNumberType' 	value="<%=numberType%>">
<input type='hidden' name ='hiE164Route2'	value="<%=e164Route2%>">
<input type='hidden' name ='hiMac'			value="<%=mac%>">
<input type='hidden' name ='hiMacDisplay'	value="<%=macDisplay%>">
<input type='hidden' name ='hiMacIp'		value="<%=macWanIp%>">
<input type='hidden' name ='hiMacAuto'		value="<%=macAuto%>">
<input type='hidden' name ='hiMacAutoNo'	value="<%=macAutoNo%>">
<input type='hidden' name ='hiMacAddrType'	value="<%=macAddrType%>">
<div id="menu1" style="display:;" >	
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
    <td width="10"></td>
    <td colspan="4" ><a href="#"  onclick="DisplayMenu(1);" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_setupgene_p_btn_01.gif" width="73" height="20" border="0"></a><a href="#"  onclick="DisplayMenu(2)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_setupconfirm_p_btn.gif" width="73" height="20" border="0"></a></td>
    <td width="10"></td>
  </tr>

  <tr>
    <td width="10"></td>
    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
    <td width="10"></td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>아이디 </strong></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtId" style="width:100" value="<%=endPointID%>" disabled></td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>비밀번호 </strong></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 "><input name="txtPass" type="text" id="pw" style="width:100" value=""></td>
    <td colspan="2" bgcolor="#FFFFFF">(6자 이상 영문,숫자,특수문자 조합)</td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>내선번호</strong></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<%if(numberType.equals("2")){%>
    		<input name="txtExtension" type="text" id="inside" style="width:100" value="<%=extension%>" maxlength="4" disabled>
    	<%}else{%>
    		<input name="txtExtension" type="text" id="inside" style="width:100" value="<%=extension%>" maxlength="4">
    	<%}%>
    </td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF">
		<hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center">
	</td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td colspan="2" bgcolor="#FFFFFF"> <img src="<%=StaticString.ContextRoot%>/imgs/menu_privateinform_user_normal_btn.gif" width="165" height="22"></td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong><font color="#FF0000">*</font> 이름</strong></td>
    <td width="106" bgcolor="#FFFFFF"><input name="txtName" type="text" id="name" style="width:100 "></td>
    <td width="46" align="right" style="padding-right:5 " bgcolor="#FFFFFF"><strong><font color="#FF0000">*</font> 직급 </strong></td>
    <td width="159" bgcolor="#FFFFFF">
	  <select name="position" style="width:100 " class="select01">
	  	<%																																						 
		PositionDTO positionDTO = null;
		for (int idx = 0; idx < positionCount ; idx++ ) {
			positionDTO = (PositionDTO)positionList.get(idx);																													
		%>
			<option value="<%=positionDTO.getPositionName()%>"><%=positionDTO.getPositionName()%></option>
		<% 
		}
		%>
      </select>
	</td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong><font color="#FF0000">*</font> 부서 </strong></td>
    <td width="106" bgcolor="#FFFFFF">
	  <select name="dept" style="width:100 " class="select01">
		<%																																						 
		DeptListDTO deptListDTO = null;
		for (int idx = 0; idx < deptCount ; idx++ ) {
			deptListDTO = (DeptListDTO)deptList.get(idx);																														
		%>																											
			<option value="<%=deptListDTO.getDeptID()%>|<%=deptListDTO.getParentID()%>"><%=deptListDTO.getDeptName()%></option>
		<% 
		}
		%>
      </select>
    </td>
    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 "></td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>    
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF">
		<hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center">
	</td>
    <td width="10">&nbsp;</td>
  </tr>    
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>핸드폰 </strong></td>
    <td width="106" bgcolor="#FFFFFF">	
    <input name="txtMobile" type="text" id="hp" style="width:100 " maxlength="12"></td>
    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>     
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>집</strong></td>
    <td width="106" bgcolor="#FFFFFF">
	<input name="txtHomeNumber" type="text" id="tel" style="width:100 " maxlength="12">	</td>
    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>    
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF">
		<hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center">
	</td>
    <td width="10">&nbsp;</td>
  </tr>    
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>이메일</strong></td>
    <td colspan="3" bgcolor="#FFFFFF"><input name="txtMail" type="text" id="email" style="width:275 " maxlength="30"></td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10"></td>
    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
    <td width="10"></td>
  </tr>   
  <tr align="center">
    <td height="35" colspan="6" style="padding-top:3 "><a href="#" onclick="javascript:goUserBefore();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','<%=StaticString.ContextRoot%>/imgs/Content_before_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_before_n_btn.gif" name="Image2" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:goNewSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_next_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_next_n_btn.gif" name="Image3" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
  </tr>
</table>
</div>

<div id="menu2" style="display:none;" >	
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
    <td width="10"></td>
    <td colspan="4" ><a href="#"  onclick="DisplayMenu(1)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_setupgene_p_btn.gif" width="73" height="20" border="0"></a><a href="#"  onclick="DisplayMenu(2)" style="cursor:hand"><img src="<%=StaticString.ContextRoot%>/imgs/Tab_setupconfirm_p_btn_01.gif" width="73" height="20" border="0"></a></td>
    <td width="10"></td>
  </tr>

  <tr>
    <td width="10"></td>
    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
    <td width="10"></td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td colspan="2" bgcolor="#FFFFFF"> <img src="<%=StaticString.ContextRoot%>/imgs/menu_privateinform_auth_btn.gif" width="165" height="22"></td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>

  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;
    	<!--input name="md5Auth" type="checkbox" style="width:20" onclick="chkMd5Auth();" checked-->
    </td>
    <td colspan="3" bgcolor="#FFFFFF">&nbsp;<strong>MD5 인증 </strong></td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" bgcolor="#FFFFFF"></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;[Register]</td>
    <td colspan="2" bgcolor="#FFFFFF">
	  <select name="register" style="width:100 " class="select01">
			<option value="1">IP변경시 인증</option>
			<option value="2" selected>항상인증</option>
      </select>&nbsp;
      <input name="staleAuth" type="checkbox" style="width:15" style="padding-right:5 ">Stale 모드
    </td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" bgcolor="#FFFFFF"></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;[Invite]</td>
    <td colspan="2" bgcolor="#FFFFFF">
	  <select name="invite" style="width:120 " class="select01">
			<option value="1" selected>인증안함</option>
			<option value="2">IP변경시 Reject</option>
			<option value="3">IP변경시 인증</option>
			<option value="4">항상인증</option>
      </select>
    </td>
    <td width="10">&nbsp;</td>
  </tr>  

  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" bgcolor="#FFFFFF"></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;인증 ID</td>
    <td colspan="2" bgcolor="#FFFFFF"><input name="txtid" type="text" id="id" value="<%=endPointID%>" style="width:120 "  maxlength="32" disabled></td>
    <td width="10">&nbsp;</td>
  </tr>

  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" bgcolor="#FFFFFF"></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;IP단말 비밀번호</td>
    <td colspan="2" bgcolor="#FFFFFF"><input name="txtpassword" type="password" id="pass" value="" style="width:120 "  maxlength="32"></td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" bgcolor="#FFFFFF"></td>
    <td width="106" bgcolor="#FFFFFF"></td>
    <td colspan="2" bgcolor="#FFFFFF">(6자 이상 영문,숫자,특수문자 조합)</td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" bgcolor="#FFFFFF"></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;비밀번호 확인</td>
    <td colspan="2" bgcolor="#FFFFFF"><input name="txtpass_chk" type="password" id="pass" value="" style="width:120 "  maxlength="32"></td>
    <td width="10">&nbsp;</td>
  </tr>

  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input name="e164Auth" type="checkbox" style="width:20">
    </td>
    <td colspan="3" bgcolor="#FFFFFF">&nbsp;<strong>전화번호 인증 </strong></td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input name="ipAuth" type="checkbox" style="width:20" onclick="chkIpAuth();">
    </td>
    <td width="106" bgcolor="#FFFFFF">&nbsp;<strong>IP 인증 </strong></td>
    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input name="txtip" type="text" id="ip" style="width:120" value=""  maxlength="15" disabled>
    </td>
    <td width="10">&nbsp;</td>
  </tr>  
<!--
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF"></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-left:5 ">
    	<input name="ipPort" type="checkbox" style="width:15" onclick="chkPort();" disabled> Port&nbsp;&nbsp;
    	<input name="txtport" type="text" id="port" style="width:40" value=""  maxlength="5" disabled>
    </td>
    <td colspan="2" bgcolor="#FFFFFF"></td>
    <td width="10">&nbsp;</td>
  </tr>  
-->
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input name="ipPort" type="checkbox" style="width:20" onclick="chkPort();" disabled>
    </td>
    <td width="106" bgcolor="#FFFFFF">&nbsp;Port </td>
    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input name="txtport" type="text" id="port" style="width:40" value=""  maxlength="5" disabled>
    </td>
    <td width="10">&nbsp;</td>
  </tr>


  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF">
		<hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center">
	</td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td colspan="2" bgcolor="#FFFFFF"> <img src="<%=StaticString.ContextRoot%>/imgs/menu_privateinform_natZone_btn.gif" width="165" height="22"></td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>Zone</strong></td>
    <td colspan="3" bgcolor="#FFFFFF">
    	<input type="text" name="txtZone" style="width:90 " disabled>
    	<a href="javascript:goZone('I');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image77','','<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif',1)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif" name="Image77" width="40" height="20" border="0" align="absmiddle" id="Image7" /></a>
    	&nbsp;&nbsp;ZONE 사용
    	<select name="zoneChk" style="width:75;height:15; font-size:12px; " onChange="javascript:selectZone()">
      		<option value="1">자동설정</option>
      		<option value="2">수동설정</option>
    	</select>    	
    </td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10"></td>
    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
    <td width="10"></td>
  </tr>   
  <tr align="center">
    <td height="35" colspan="6" style="padding-top:3 "><a href="#" onclick="javascript:goUserBefore();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','<%=StaticString.ContextRoot%>/imgs/Content_before_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_before_n_btn.gif" name="Image2" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:goNewSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_next_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_next_n_btn.gif" name="Image3" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
  </tr>
</table>
</div>

<div id="menu3" style="display:none;">
</div>
<div id="menu4" style="display:none;">
</div>

</form>
</body>
</html>