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
<%@ page import="system.RootList"%>
<%@ page import="dto.system.RouteStateDTO"%>
<%@ page import="dao.useconfig.AddServiceDAO"%>

<% 

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

/* SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String userID = Str.CheckNullString(scDTO.getSubsID()).trim();
response.setCharacterEncoding("euc-kr");
 */
 
 HttpSession ses = request.getSession(false);
 int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
 String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
 String userID = (String)ses.getAttribute("login.user") ;
 
 int prefixTypeVal = 4;
 String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
 DataStatement 	stmt2 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);

 RootList 	rootList	= new RootList();
 List 	rList = rootList.getRouteID2(stmt2);	// 데이타 조회
 int rCount = rList.size();
 
 if (stmt2 != null) ConnectionManager.freeStatement(stmt2);
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>
</head>

<body>
<form name="Insertlayer1" method="post">

<input type='hidden' name ='hiKeyNumberID_02' 	value="">
<input type='hidden' name ='hiHunt_02' 			value="">
<input type='hidden' name ='hiErrorType_02' 	value="">
<input type='hidden' name ='hiEndpointid_02' 	value="">
<input type='hidden' name ='hiStandTime_02' 	value="">
<input type='hidden' name ='hiStandTime2_02' 	value="">
<input type='hidden' name ='hiStartFile_02' 	value="">
<input type='hidden' name ='hiEndFile_02' 		value="">
<input type='hidden' name ='hiStand_02' 		value="">
<input type='hidden' name ='hiStandType_02' 	value="">
<input type='hidden' name ='hiDesc_02' 			value="">
<input type='hidden' name ='hiUserID'			value="<%=userID%>">

	<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
	  <tr>
	    <td height="30" colspan="4" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">부서대표번호 추가 </strong></td>
	    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
	    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
	  </tr>
	  <tr align="right">
	    <td height="6" colspan="7" style="padding-right:10; color:RGB(82,86,88)"></td>
	  </tr>  	  	  
	  
	  <tr>
	    <td height="5">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>  
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>부서대표번호 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <input type="text" name="txtKeyNumber" style="width:130px;" value="" size="10" >
		</td>
		<td colspan="2" bgcolor="#FFFFFF"></td>
		<td width="10">&nbsp;</td>
	  </tr>  

	  <tr>
	    <td height="3">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>착신유형 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <select name="huntType" style="width:120 " class="select01">
	        <option selected value="1">순차 착신</option>
			<option value="2">고정 착신</option>
			<option value="3">자동 착신</option>
			<option value="4">동시 착신</option>
	      </select>
		</td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>	  

	  <tr>
	    <td height="3">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>설명 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
		  <input type="text" name="txtDesc" style="width:200" value="" size="10">
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
	    

	<!-- ########################################## -->

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF">
			<!-- <hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="350" align="center"> -->
			<hr style="border-width: 1px; border-color:#aa99b2; border-style:dotted;" width="350" align="center">
		</td>
	    <td width="10">&nbsp;</td>
	  </tr>    

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	          <input name="standChk" type="checkbox" style="width:12"> <strong>무응답시 예외처리 </strong>&nbsp;<br>
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;대기시간&nbsp;
			  <select name="standTime" style="width:40 " class="select01" >
		        <option value="5">5</option>
		        <option value="10">10</option>
				<option value="15" selected>15</option>
				<option value="20">20</option>
				<option value="30">30</option>
				<option value="40">40</option>
				<option value="50">50</option>
				<option value="60">60</option>
				<option value="90">90</option>
				<option value="120">120</option>
		      </select>(초)
		</td>
	    <td width="10">&nbsp;</td>
	  </tr>

	  <tr>
	    <td height="3">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <strong>예외처리설정 </strong></td>
	    <td width="106" bgcolor="#FFFFFF" style="padding-right:5 ">
			  <select name="exceptType" style="width:170 " class="select01" onChange="exceptChange()">
		        <option value="0">호종료</option>
		        <!-- <option value="1">정해진 루트 호중계</option> -->
				<option value="3">정해진 전화번호로 호중계</option>
				<!-- <option value="4">통화중 호대기</option> -->
		      </select>
		</td>
	    <td colspan="2" bgcolor="#FFFFFF"></td>
	    <td width="10">&nbsp;</td>
	  </tr>

	<%if(prefixTypeVal==0){%>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div3" name="div3" style="position:absolute; left:15px; top:300px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;루트 ID&nbsp;
			    <select name="root" style="width:170" class="select01" >
					<option value="">선택하세요</option>
					<%																																						 
					RouteStateDTO 	routeStateDTO 	= null;
					for (int idx = 0; idx < rCount ; idx++ ) {
						routeStateDTO = (RouteStateDTO)rList.get(idx);
					%>																											
					<option value="<%=routeStateDTO.getEndpointid()%>,<%=routeStateDTO.getProtocol()%>"><%=routeStateDTO.getEndpointid()%></option>
					<% 
					}
					%>   							
		   	</select>
	    	</div>
	    	
	    	<div id="div4" name="div4" style="position:absolute; left:15px; top:300px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;전화번호&nbsp;
			    <input type="text" name="e164" style="width:170" value="" >
	    	</div>

	    	<div id="div5" name="div5" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;최대 대기호&nbsp;
			    <input type="text" name="stand" style="width:40" value="" >
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div5_1" name="div5_1" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;대기시간(분)
				  <select name="standTime2" style="width:40 " class="select01" >
			        <option selected value="0">0</option>
			        <option value="1">1</option>
			        <option value="2">2</option>
					<option value="3">3</option>
					<option value="5">5</option>
					<option value="7">7</option>
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
			      </select>
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div6" name="div6" style="position:absolute; left:15px; top:340px; width:380; overflow:hidden; display:none;"></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div7" name="div7" style="position:absolute; left:15px; top:350px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;대기 안내음&nbsp;
			<input type="file" name="wFile3" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div8" name="div8" style="position:absolute; left:15px; top:385px; width:380; overflow:hidden; display:none;"></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div9" name="div9" style="position:absolute; left:15px; top:395px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;대기 종료음&nbsp;
			<input type="file" name="wFile4" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	<%}else if(prefixTypeVal==1){%>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div3" name="div3" style="position:absolute; left:15px; top:300px; width:380; overflow:hidden;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;루트 ID&nbsp;
			    <select name="root" style="width:170" class="select01" >
					<option selected value="">선택하세요</option>
					<%																																						 
					RouteStateDTO 	routeStateDTO 	= null;
					for (int idx = 0; idx < rCount ; idx++ ) {
						routeStateDTO = (RouteStateDTO)rList.get(idx);
					%>																											
					<option value="<%=routeStateDTO.getEndpointid()%>,<%=routeStateDTO.getProtocol()%>"><%=routeStateDTO.getEndpointid()%></option>
					<% 
					}
					%>   							
		   	</select>
	    	</div>
	    	
	    	<div id="div4" name="div4" style="position:absolute; left:15px; top:300px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;전화번호&nbsp;
			    <input type="text" name="e164" style="width:170" value="" >
	    	</div>
	    	
	    	<div id="div5" name="div5" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;최대 대기호&nbsp;
			    <input type="text" name="stand" style="width:40" value="" >
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div5_1" name="div5_1" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;대기시간(분)
				  <select name="standTime2" style="width:40 " class="select01" >
			        <option selected value="0">0</option>
			        <option value="1">1</option>
			        <option value="2">2</option>
					<option value="3">3</option>
					<option value="5">5</option>
					<option value="7">7</option>
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
			      </select>
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div6" name="div6" style="position:absolute; left:15px; top:340px; width:380; overflow:hidden; display:none;"></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div7" name="div7" style="position:absolute; left:15px; top:350px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;대기 안내음&nbsp;
			<input type="file" name="wFile3" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div8" name="div8" style="position:absolute; left:15px; top:385px; width:380; overflow:hidden; display:none;"></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div9" name="div9" style="position:absolute; left:15px; top:395px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;대기 종료음&nbsp;
			<input type="file" name="wFile4" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	<%}else if(prefixTypeVal==3){%>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div3" name="div3" style="position:absolute; left:15px; top:300px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;루트 ID&nbsp;
			    <select name="root" style="width:170" class="select01" >
					<option value="">선택하세요</option>
					<%																																						 
					RouteStateDTO 	routeStateDTO 	= null;
					for (int idx = 0; idx < rCount ; idx++ ) {
						routeStateDTO = (RouteStateDTO)rList.get(idx);
					%>																											
					<option value="<%=routeStateDTO.getEndpointid()%>,<%=routeStateDTO.getProtocol()%>"><%=routeStateDTO.getEndpointid()%></option>
					<% 
					}
					%>   							
		   	</select>
	    	</div>
	    	
	    	<div id="div4" name="div4" style="position:absolute; left:15px; top:300px; width:380; overflow:hidden;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;전화번호&nbsp;
			    <input type="text" name="e164" style="width:170" value="" >
	    	</div>

	    	<div id="div5" name="div5" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;최대 대기호&nbsp;
			    <input type="text" name="stand" style="width:40" value="" >
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div5_1" name="div5_1" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;대기시간(분)
				  <select name="standTime2" style="width:40 " class="select01" >
			        <option selected value="0">0</option>
			        <option value="1">1</option>
			        <option value="2">2</option>
					<option value="3">3</option>
					<option value="5">5</option>
					<option value="7">7</option>
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
			      </select>
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div6" name="div6" style="position:absolute; left:15px; top:340px; width:380; overflow:hidden; display:none;"></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div7" name="div7" style="position:absolute; left:15px; top:350px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;대기 안내음&nbsp;
			<input type="file" name="wFile3" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div8" name="div8" style="position:absolute; left:15px; top:385px; width:380; overflow:hidden; display:none;"></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div9" name="div9" style="position:absolute; left:15px; top:395px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;대기 종료음&nbsp;
			<input type="file" name="wFile4" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	<%}else if(prefixTypeVal==4){%>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div3" name="div3" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;루트 ID&nbsp;
			    <select name="root" style="width:170" class="select01" >
					<option value="">선택하세요</option>
					<%																																						 
					RouteStateDTO 	routeStateDTO 	= null;
					for (int idx = 0; idx < rCount ; idx++ ) {
						routeStateDTO = (RouteStateDTO)rList.get(idx);
					%>																											
					<option value="<%=routeStateDTO.getEndpointid()%>,<%=routeStateDTO.getProtocol()%>"><%=routeStateDTO.getEndpointid()%></option>
					<% 
					}
					%>   							
		   	</select>
	    	</div>
	    	
	    	<div id="div4" name="div4" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;전화번호&nbsp;
			    <input type="text" name="e164" style="width:170" value="" >
	    	</div>
	    	
	    	<div id="div5" name="div5" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;최대 대기호&nbsp;
			    <input type="text" name="stand" style="width:40" value="" >
	    	</div>
	    	
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div5_1" name="div5_1" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
			    &nbsp;&nbsp;&nbsp;대기시간(분)
				  <select name="standTime2" style="width:40 " class="select01" >
			        <option selected value="0">0</option>
			        <option value="1">1</option>
			        <option value="2">2</option>
					<option value="3">3</option>
					<option value="5">5</option>
					<option value="7">7</option>
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="30">30</option>
			      </select>
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>

	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div6" name="div6" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
	    		&nbsp;&nbsp;&nbsp;대기 안내음&nbsp;&nbsp;&nbsp;<FONT color="blue"></FONT></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div7" name="div7" style="position:relative; left:15px; top:0px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="file" name="wFile3" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div8" name="div8" style="position:relative; left:15px; top:5px; width:380; overflow:hidden; display:none;">
	    		&nbsp;&nbsp;&nbsp;대기 종료음&nbsp;&nbsp;&nbsp;<FONT color="blue"></FONT></div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	  <tr>
	    <td width="10" height="30">&nbsp;</td>
	    <td colspan="4" bgcolor="#FFFFFF" style="padding-right:5">
	    	<div id="div9" name="div9" style="position:relative; left:15px; top:5px; width:380; overflow:hidden; display:none;">
		    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="file" name="wFile4" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
	    	</div>
	    </td>
	    <td width="10">&nbsp;</td>
	  </tr>
	<%}%>

	  <tr>
	    <td height="3">&nbsp;</td>
	    <td align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td colspan="3" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
	    <td>&nbsp;</td>
	  </tr>

	  <tr align="center">
	    <td height="35" colspan="6" style="padding-top:3 ">
	    	<a href="#" onclick="javascript:goNewSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image72','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)">
	    		<img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image72" width="40" height="20" border="0">
	    	</a> 
	    	<a href="#" onclick="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image174','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)">
	    		<img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image174" width="40" height="20" border="0">
	    	</a>
	    </td>
	  </tr>
	  
	  
	  
	</table>

</form>
</body>
</html>