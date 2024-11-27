<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dto.organization.DeptListDTO" %>
<%@ page import="dto.organization.PositionDTO" %>
<%@ page import="dto.ipcs.IpcsDetailDTO" %>
<%@ page import="business.ipcs.IpcsList"%>
<%@ page import="business.CommonData"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>

<%@ page import="system.SystemConfigSet"%>

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
String 	userID		= new String(request.getParameter("id").getBytes("8859_1"), "euc-kr");			// ID

String	oldExtension	= "";

//String	strTemp		= userID.substring(userID.length()-4, userID.length());							// 내선번호(4자리)

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW");
try{	
	CommonData	commonData		= new CommonData();
	List 		deptList 		= commonData.getDeptList(stmt);		// 부서명 조회
	int 		deptCount 		= deptList.size();	
	List 		positionList 	= commonData.getPositionList(stmt);	// 직급 데이타 조회
	int 		positionCount 	= positionList.size();

	IpcsList 		ipcsList 		= new IpcsList();
	List 			iList 			= ipcsList.getDetail(stmt, endPointID);	// 데이타 조회
	int				userCount		= iList.size();		
	IpcsDetailDTO 	ipcsDetailDTO 	= null;
	int				routeCount		= ipcsList.getRouteCount(stmt, ei64);
	
	String 			tempExtension	= "";
	if(userCount>0){	
		ipcsDetailDTO 	= (IpcsDetailDTO)iList.get(0);
		oldExtension	= ipcsDetailDTO.getExtension();
	}else{
		tempExtension 	= ipcsList.getExtension(stmt, ei64);	// 내선번호 조회
		oldExtension	= tempExtension;
	}
	
    //##인증설정
	//Auth Mode를 판단하기위해 Table_NeighborProxy의 AuthMode를 이용한다.
	// 전화번호 : 2048(사용안함), Port :1,  IP : 2, 비밀번호 : 128 ,
	// Regester IP변경시 :64,  Regester 항상: 0,   Register Stele: 8
	// Invite 인증안함 :0,  Invite IP변경시 Reject : 32, Invite IP변경시: 48, Invite 항상: 16
	
	int authE164		= 0;	//전화번호
	int authIPChk 		= 0;	//IP
	int authPortChk		= 0;	//port
	int auth_MD5 		= 0;	//md5 (인증ID, Password)
	int authRegister 	= 0;	//Register
	int authStale 		= 0;	//Register  Stale
	int authInvite 		= 0;	//authInvite
	int authMode		= 0;
	
	if(userCount>0){
		authMode = ipcsDetailDTO.getAuthmode();
	}
	
	System.out.println("인증모드 1 :"+authMode);
	
	if ((authMode - 2048) >= 0){ //전화번호
		authE164 	= 1;
		authMode 	= authMode - 2048;
	}

	if ((authMode - 128) >= 0){ //md5 (인증ID, Password)
		auth_MD5 = 1;
		authMode = authMode - 128;
	}

	if ((authMode - 64) >= 0){ //Regester IP변경시
		authRegister = 1;
		authMode 	 = authMode - 64;
	}

	if ((authMode - 48) >= 0){ //Invite IP변경시
		authInvite 	= 3;
		authMode 	= authMode - 48;
	}

	if ((authMode - 32) >= 0){ //Invite IP변경시 Reject
		authInvite 	= 2;
		authMode 	= authMode - 32;
	}
	
	if ((authMode - 16) >= 0){ //Invite 항상
		authInvite 	= 4;
		authMode 	= authMode - 16;
	}

	if ((authMode - 8) >= 0){ //Stale
		authStale  	= 1;
		authMode 	= authMode - 8;
	}
	
	if ((authMode - 2) >= 0){ //IP
		authIPChk  	= 1;
		authMode 	= authMode - 2;
	}

	if (authMode == 1){ //port
		authPortChk = 1;
	}	
	//--------------------------------
	
//	System.out.println("전화번호 :"+authE164);
//	System.out.println("IP :"+authIPChk);
//	System.out.println("port :"+authPortChk);
//	System.out.println("md5 :"+auth_MD5);
//	System.out.println("Register :"+authRegister);
//	System.out.println("Register  Stale :"+authStale);
//	System.out.println("authInvite :"+authInvite);
//	System.out.println("인증모드 2 :"+authMode);
	
//제품명(모델명) 버전 조회
SystemConfigSet 	systemConfig 	= new SystemConfigSet();
String 				goodsName_02 	= systemConfig.getGoodsName();						// 제품명(모델명)
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css">
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>


</head>
<body>
<form name="Editlayer1" method="post">
<input type='hidden' name ='hiEndPointID' 		value="<%=endPointID%>">
<input type='hidden' name ='hiEi64' 			value="<%=ei64%>">
<input type='hidden' name ='hiOldExtension' 	value="<%=oldExtension%>">

<div id="menu1" style="display:;" >	
<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">개인내선번호 수정 </strong></td>
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
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 "><input type="text" name="txtId" style="width:100" value="<%=userID%>" disabled></td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>비밀번호 </strong></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<%if(userCount>0){%>
    		<input name="txtPass" type="password" id="pw" style="width:100" value="<%=ipcsDetailDTO.getPwd()%>" style="width:85px;height:14px;font-size:7px; ime-mode:inactive;" disabled>
    	<%}else{%>
    		<input name="txtPass" type="password" id="pw" style="width:100" value="" style="width:85px;height:14px;font-size:7px; ime-mode:inactive;">
    	<%}%>
    </td>
    <td colspan="2" bgcolor="#FFFFFF"></td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>내선번호</strong></td>
    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<%if(userCount>0){%>
    		<%if(routeCount>0){%>
    			<input name="txtExtension" type="text" id="inside" style="width:100" value="<%=ipcsDetailDTO.getExtension()%>" maxlength="4"></td><td colspan="2" bgcolor="#FFFFFF">&nbsp;
    		<%}else{%>
    			<input name="txtExtension" type="text" id="inside" style="width:100" value="<%=ipcsDetailDTO.getExtension()%>" maxlength="4" disabled></td><td colspan="2" bgcolor="#FFFFFF">&nbsp;
    		<%}%>		
    	<%}else{%>
    		<%if(routeCount>0){%>
    			<input name="txtExtension" type="text" id="inside" style="width:100" value="<%=tempExtension%>" maxlength="4"></td><td colspan="2" bgcolor="#FFFFFF">&nbsp;
    		<%}else{%>
    			<input name="txtExtension" type="text" id="inside" style="width:100" value="<%=tempExtension%>" maxlength="4" disabled></td><td colspan="2" bgcolor="#FFFFFF">&nbsp;
    		<%}%>
    	<%}%>
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
    <td colspan="2" bgcolor="#FFFFFF"> <img src="<%=StaticString.ContextRoot%>/imgs/menu_privateinform_user_normal_btn.gif" width="165" height="22"></td>
    <td colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong><font color="#FF0000">*</font> 이름</strong></td>
    <%if(userCount>0){%>
    	<td width="106" bgcolor="#FFFFFF"><input name="txtName" type="text" id="name" style="width:100" value="<%=ipcsDetailDTO.getName()%>"></td>
    <%}else{%>
    	<td width="106" bgcolor="#FFFFFF"><input name="txtName" type="text" id="name" style="width:100" value=""></td>
    <%}%>
    <td width="46" align="right" style="padding-right:5 " bgcolor="#FFFFFF"><strong><font color="#FF0000">*</font> 직급 </strong></td>
    <td width="159" bgcolor="#FFFFFF">
	  <%if(userCount>0){%>
		  <select name="position" style="width:100 " class="select01">
		  		<option value="">선택하세요</option>
		  	<%																																						 		
		  	String tempPosition = ipcsDetailDTO.getPosition();
		  	PositionDTO positionDTO = null;	  	
		  	for (int idx = 0; idx < positionCount ; idx++ ) {
				positionDTO = (PositionDTO)positionList.get(idx);																													
			%>
				<option <%if(tempPosition.equals(positionDTO.getPositionName())){%> selected <%}%> value="<%=positionDTO.getPositionName()%>"><%=positionDTO.getPositionName()%></option>
			<% 
			}
			%>
	      </select>
      <%}else{%>
		  <select name="position" style="width:100 " class="select01">
		  		<option value="">선택하세요</option>
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
      <%}%>
	</td>
    <td width="10">&nbsp;</td>
  </tr>
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong><font color="#FF0000">*</font> 부서 </strong></td>
    <td width="106" bgcolor="#FFFFFF">
      <%if(userCount>0){%>
		  <select name="dept" style="width:100 " class="select01">
		  		<option value="">선택하세요</option>
			<%																																						 
			int tempDept = ipcsDetailDTO.getDepartment();
			DeptListDTO deptListDTO = null;
			for (int idx = 0; idx < deptCount ; idx++ ) {
				deptListDTO = (DeptListDTO)deptList.get(idx);																														
			%>																											
				<option <%if(tempDept==deptListDTO.getDeptID()){%> selected <%}%> value="<%=deptListDTO.getDeptID()%>|<%=deptListDTO.getParentID()%>"><%=deptListDTO.getDeptName()%></option>
			<% 
			}
			%>
	      </select>
      <%}else{%>
		  <select name="dept" style="width:100 " class="select01">
				<option value="">선택하세요</option>
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
      <%}%>
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
    <%if(userCount>0){%>
    	<input name="txtMobile" type="text" id="hp" style="width:100 " value="<%=Str.CheckNullString(ipcsDetailDTO.getMobile())%>" maxlength="12">
    <%}else{%>
    	<input name="txtMobile" type="text" id="hp" style="width:100 " value="" maxlength="12">
    <%}%>
    </td>
    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10">&nbsp;</td>
  </tr>     
  <tr>
    <td width="10" height="30">&nbsp;</td>
    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>집</strong></td>
    <td width="106" bgcolor="#FFFFFF">	
	<%if(userCount>0){%>
		<input name="txtHomeNumber" type="text" id="tel" style="width:100 " value="<%=Str.CheckNullString(ipcsDetailDTO.getHomeNumber())%>" maxlength="12">
	<%}else{%>
		<input name="txtHomeNumber" type="text" id="tel" style="width:100 " value="" maxlength="12">
	<%}%>
	</td>
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
    <td colspan="3" bgcolor="#FFFFFF">
    <%if(userCount>0){%>
    	<input name="txtMail" type="text" id="email" style="width:275 " value="<%=Str.CheckNullString(ipcsDetailDTO.getMailaddress())%>" maxlength="30">
    <%}else{%>
    	<input name="txtMail" type="text" id="email" style="width:275 " value="" maxlength="30">
    <%}%>
    </td>
    <td width="10">&nbsp;</td>
  </tr>  
  <tr>
    <td width="10"></td>
    <td colspan="4" height="10" bgcolor="#FFFFFF"></td>
    <td width="10"></td>
  </tr>   
  <tr align="center">
    <td height="35" colspan="6" style="padding-top:3 "><a href="#" onclick="javascript:goSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image3" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
  </tr>
</table>
</div>

<div id="menu2" style="display:none;" >	
<%if(userCount>0){%>
	<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
	  <tr>
	    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">개인내선번호 수정 </strong></td>
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
	
	  <%if(auth_MD5==0){%>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;
		    	<!--input name="md5Auth" type="checkbox" style="width:20" onclick="chkMd5Auth_Edit();"-->
		    </td>
		    <td colspan="3" bgcolor="#FFFFFF">&nbsp;<strong>MD5 인증 </strong></td>
		    <td width="10">&nbsp;</td>
		  </tr>  
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;[Register]</td>
		    <td colspan="2" bgcolor="#FFFFFF">
			  <select name="register" style="width:100 " class="select01" >
					<option value="1">IP변경시 인증</option>
					<option value="2" selected>항상인증</option>
		      </select>&nbsp;
		      <input name="staleAuth" type="checkbox" style="width:15" style="padding-right:5 " >Stale 모드
		    </td>
		    <td width="10">&nbsp;</td>
		  </tr>  
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;[Invite]</td>
		    <td colspan="2" bgcolor="#FFFFFF">
			  <select name="invite" style="width:120 " class="select01" >
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
		    <td colspan="2" bgcolor="#FFFFFF"><input name="txtid" type="text" id="id" value="<%=userID%>" style="width:120 "  maxlength="32" disabled></td>
		    <td width="10">&nbsp;</td>
		  </tr>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;비밀번호</td>
		    <!--td colspan="2" bgcolor="#FFFFFF"><input name="txtpassword" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td-->
		    <td colspan="2" bgcolor="#FFFFFF"><input name="txtpassword" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td>
		    <td width="10">&nbsp;</td>
		  </tr>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;비밀번호 확인</td>
		    <!--td colspan="2" bgcolor="#FFFFFF"><input name="txtpass_chk" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td-->
		    <td colspan="2" bgcolor="#FFFFFF"><input name="txtpass_chk" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td>
		    <td width="10">&nbsp;</td>
		  </tr>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF"></td>
		    <td colspan="2" bgcolor="#FFFFFF">(6자 이상 영문,숫자,특수문자 조합)</td>
		    <td width="10">&nbsp;</td>
		  </tr>
	  <%}else{%>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;
		    	<!--input name="md5Auth" type="checkbox" style="width:20" onclick="chkMd5Auth_Edit();" checked-->
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
					<option <%if(authRegister==1){%> selected <%}%> value="1">IP변경시 인증</option>
					<option <%if(authRegister==0){%> selected <%}%> value="2">항상인증</option>
		      </select>&nbsp;
		      <%if(authStale==0){%>
		      	<input name="staleAuth" type="checkbox" style="width:15" style="padding-right:5 ">Stale 모드
		      <%}else{%>
		        <input name="staleAuth" type="checkbox" style="width:15" style="padding-right:5 " checked>Stale 모드
		      <%}%>
		    </td>
		    <td width="10">&nbsp;</td>
		  </tr>  
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;[Invite]</td>
		    <td colspan="2" bgcolor="#FFFFFF">
			  <select name="invite" style="width:120 " class="select01">
					<option <%if(authInvite==0){%> selected <%}%> value="1">인증안함</option>
					<option <%if(authInvite==2){%> selected <%}%> value="2">IP변경시 Reject</option>
					<option <%if(authInvite==3){%> selected <%}%> value="3">IP변경시 인증</option>
					<option <%if(authInvite==4){%> selected <%}%> value="4">항상인증</option>
		      </select>
		    </td>
		    <td width="10">&nbsp;</td>
		  </tr>  
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;인증 ID</td>
		    <td colspan="2" bgcolor="#FFFFFF"><input name="txtid" type="text" id="id" value="<%=userID%>" style="width:120 "  maxlength="32" disabled></td>
		    <td width="10">&nbsp;</td>
		  </tr>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;비밀번호</td>
		    <!-- ####### IMS 용 ####### -->
		    <%if("ACRO-CBS-IMS".equals(goodsName_02)||"ACRO-HCBS-IMS".equals(goodsName_02)){%>
		    	<td colspan="2" bgcolor="#FFFFFF"><input name="txtpassword" type="password" id="pass" value="<%=Str.CheckNullString(ipcsDetailDTO.getBeforePassword())%>" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32"></td>
		    <%}else{%>
				<td colspan="2" bgcolor="#FFFFFF"><input name="txtpassword" type="password" id="pass" value="<%=Str.CheckNullString(ipcsDetailDTO.getPassword())%>" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" ></td>		    	
		    <%}%>
		    <!-- ##################### -->
		    <td width="10">&nbsp;</td>
		  </tr>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;비밀번호 확인</td>
		    <!-- ####### IMS 용 ####### -->
		    <%if("ACRO-CBS-IMS".equals(goodsName_02)||"ACRO-HCBS-IMS".equals(goodsName_02)){%>
				<td colspan="2" bgcolor="#FFFFFF"><input name="txtpass_chk" type="password" id="pass" value="<%=Str.CheckNullString(ipcsDetailDTO.getBeforePassword())%>" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32"></td>		    
		    <%}else{%>
		    	<td colspan="2" bgcolor="#FFFFFF"><input name="txtpass_chk" type="password" id="pass" value="<%=Str.CheckNullString(ipcsDetailDTO.getPassword())%>" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" ></td>
		    <%}%>
		    <!-- ##################### -->
		    <td width="10">&nbsp;</td>
		  </tr>
		  <tr>
		    <td width="10" height="30">&nbsp;</td>
		    <td width="69" bgcolor="#FFFFFF"></td>
		    <td width="106" bgcolor="#FFFFFF"></td>
		    <td colspan="2" bgcolor="#FFFFFF">(6자 이상 영문,숫자,특수문자 조합)</td>
		    <td width="10">&nbsp;</td>
		  </tr>
	  <%}%>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<%if(authE164==0){%>
	    		<input name="e164Auth" type="checkbox" style="width:20">
	    	<%}else{%>
	    		<input name="e164Auth" type="checkbox" style="width:20" checked>
	    	<%}%>
	    </td>
	    <td colspan="3" bgcolor="#FFFFFF">&nbsp;<strong>전화번호 인증 </strong></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<%if(authIPChk==0){%>
	    		<input name="ipAuth" type="checkbox" style="width:20" onclick="chkIpAuth_Edit();">
	    	<%}else{%>
	    		<input name="ipAuth" type="checkbox" style="width:20" onclick="chkIpAuth_Edit();" checked>
	    	<%}%>
	    </td>
	    <td width="106" bgcolor="#FFFFFF">&nbsp;<strong>IP 인증 </strong></td>
	    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<%if(authIPChk==0){%>
	    		<input name="txtip" type="text" id="ip" style="width:120" value=""  maxlength="15" disabled>
	    	<%}else{%>
	    		<input name="txtip" type="text" id="ip" style="width:120" value="<%=Str.CheckNullString(ipcsDetailDTO.getIpaddress())%>"  maxlength="15">
	    	<%}%>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>  
	
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<%if(authPortChk==0){%>
	    		<%if(authIPChk==0){%>
	    			<input name="ipPort" type="checkbox" style="width:20" onclick="chkPort_Edit();" disabled>
	    		<%}else{%>
	    			<input name="ipPort" type="checkbox" style="width:20" onclick="chkPort_Edit();">
	    		<%}%>	
	    	<%}else{%>
	    		<input name="ipPort" type="checkbox" style="width:20" onclick="chkPort_Edit();" checked>
	    	<%}%>
	    </td>
	    <td width="106" bgcolor="#FFFFFF">&nbsp;Port </td>
	    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<%if(ipcsDetailDTO.getIpport()>0){%>
	    		<input name="txtport" type="text" id="port" style="width:40" value="<%=ipcsDetailDTO.getIpport()%>"  maxlength="5" disabled>
	    	<%}else{%>
	    		<input name="txtport" type="text" id="port" style="width:40" value=""  maxlength="5" disabled>
	    	<%}%>
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
	    	<input type="text" name="txtZone" value="<%=Str.CheckNullString(ipcsDetailDTO.getZonecode())%>" style="width:100 " disabled>
	    	<a href="javascript:goZone_Edit('U');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image77','','<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif',1)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif" name="Image77" width="40" height="20" border="0" align="absmiddle" id="Image7" /></a>
	    	&nbsp;&nbsp;ZONE 사용
	    	<select name="zoneChk" style="width:75;height:15; font-size:12px; " onChange="javascript:selectZone_Edit()">
	      		<option <%if("".equals(ipcsDetailDTO.getZonecode().trim())){%> selected <%}%> value="1">자동설정</option>
	      		<option <%if(!"".equals(ipcsDetailDTO.getZonecode().trim())){%> selected <%}%> value="2">수동설정</option>
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
	    <td height="35" colspan="6" style="padding-top:3 "><a href="#" onclick="javascript:goSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image3" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
	  </tr>
	</table>
<%}else{%>
	<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
	  <tr>
	    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">개인내선번호 수정 </strong></td>
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
	    	<!--input name="md5Auth" type="checkbox" style="width:20" onclick="chkMd5Auth_Edit();"-->
	    </td>
	    <td colspan="3" bgcolor="#FFFFFF">&nbsp;<strong>MD5 인증 </strong></td>
	    <td width="10">&nbsp;</td>
	  </tr>  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" bgcolor="#FFFFFF"></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;[Register]</td>
	    <td colspan="2" bgcolor="#FFFFFF">
		  <select name="register" style="width:100 " class="select01" >
				<option value="1">IP변경시 인증</option>
				<option value="2" selected>항상인증</option>
	      </select>&nbsp;
	      <input name="staleAuth" type="checkbox" style="width:15" style="padding-right:5 " >Stale 모드
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" bgcolor="#FFFFFF"></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;[Invite]</td>
	    <td colspan="2" bgcolor="#FFFFFF">
		  <select name="invite" style="width:120 " class="select01" >
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
	    <td colspan="2" bgcolor="#FFFFFF"><input name="txtid" type="text" id="id" value="<%=userID%>" style="width:120 "  maxlength="32" disabled></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" bgcolor="#FFFFFF"></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;비밀번호</td>
	    <!--td colspan="2" bgcolor="#FFFFFF"><input name="txtpassword" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td-->
	    <td colspan="2" bgcolor="#FFFFFF"><input name="txtpassword" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" bgcolor="#FFFFFF"></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;&nbsp;비밀번호 확인</td>
	    <!--td colspan="2" bgcolor="#FFFFFF"><input name="txtpass_chk" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td-->
	    <td colspan="2" bgcolor="#FFFFFF"><input name="txtpass_chk" type="password" id="pass" value="" style="width:120;height:14px;font-size:7px; ime-mode:inactive;"  maxlength="32" disabled></td>
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
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<input name="e164Auth" type="checkbox" style="width:20">
	    </td>
	    <td colspan="3" bgcolor="#FFFFFF">&nbsp;<strong>전화번호 인증 </strong></td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<input name="ipAuth" type="checkbox" style="width:20" onclick="chkIpAuth_Edit();">
	    </td>
	    <td width="106" bgcolor="#FFFFFF">&nbsp;<strong>IP 인증 </strong></td>
	    <td colspan="2" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<input name="txtip" type="text" id="ip" style="width:120" value=""  maxlength="15" disabled>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="69" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
	    	<input name="ipPort" type="checkbox" style="width:20" onclick="chkPort_Edit();" disabled>
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
	    	<input type="text" name="txtZone" style="width:100 " disabled>
	    	<a href="javascript:goZone_Edit('U');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image77','','<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif',1)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif" name="Image77" width="40" height="20" border="0" align="absmiddle" id="Image7" /></a>
	    	&nbsp;&nbsp;ZONE 사용
	    	<select name="zoneChk" style="width:75;height:15; font-size:12px; " onChange="javascript:selectZone_Edit()">
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
	    <td height="35" colspan="6" style="padding-top:3 "><a href="#" onclick="javascript:goSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image3" width="40" height="20" border="0"></a> <a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
	  </tr>
	</table>
<%}%>
</div>

<div id="menu3" style="display:none;">
</div>
<div id="menu4" style="display:none;">
</div>

</form>
</body>
</html>

<%
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		//할당받은 DataStatement 객체는 반납
		if (stmt != null ) ConnectionManager.freeStatement(stmt);
	}	
%>