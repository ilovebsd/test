<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="dto.ArrivalSwitchDTO" %>
<%@ page import="addition.ArrivalSwitchList"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>

<%@ page import="business.CommonData"%>
<%@ page import="system.SystemConfigSet"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession 		ses 		= request.getSession();
String userID = (String)ses.getAttribute("login.user") ;
String authGroupid = (String)ses.getAttribute("login.name") ;

String e164 	= new String(request.getParameter("hiEi64").getBytes("8859_1"), "euc-kr");
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
//서버로부터 DataStatement 객체를 할당
DataStatement 		stmt 				= ConnectionManager.allocStatement("SSW", sesSysGroupID);

ArrivalSwitchList 	arrivalSwitchList 	= new ArrivalSwitchList();

String 		temp_Result 	= arrivalSwitchList.getAnswerService(stmt, e164);		// 데이타 조회
String[] 	dataStr 		= StringUtil.getParser(temp_Result, "|");
String 		tempAnswer		= dataStr[0];
String 		tempCommon  	= dataStr[1];
String 		directForward  	= dataStr[2];
String 		answerService 	= tempAnswer.substring(3, 4);
String 		commonservice 	= tempCommon.substring(8, 9);

String		forwardNumber_0	= "";
int			forwardType_0	= 100;
String		toTime_0		= "";
String		fromTime_0		= "";
String		forwardNumber_1	= "";
int			forwardType_1	= 0;
int			WaitTime_1		= 0;
String		forwardNumber_2	= "";
int			forwardType_2	= 0;
String		forwardNumber_3	= "";
int			forwardType_3	= 0;
	
String 		toTime_si		= "0";
String 		toTime_bun		= "0";
String 		fromTime_si		= "0";
String 		fromTime_bun	= "0";	

List 	iList 	= arrivalSwitchList.getList(stmt, e164);		// 데이타 조회
int 	iCount 	= iList.size();

int 	tCount 	= arrivalSwitchList.getTimeCount(stmt, e164);

ArrivalSwitchDTO arrivalSwitchDTO = null;
int colorChk = 0;
for ( int idx = 0; idx < iCount ; idx++ ) {
	arrivalSwitchDTO = (ArrivalSwitchDTO)iList.get(idx);		
	if(arrivalSwitchDTO.getForwardtype()==0){
		forwardNumber_0	= arrivalSwitchDTO.getForwardnumber();
		forwardType_0	= arrivalSwitchDTO.getForwardtype();
		toTime_0		= arrivalSwitchDTO.getFromtime();
		fromTime_0		= arrivalSwitchDTO.getTotime();

		toTime_si		= toTime_0.substring(0,2);
		toTime_bun		= toTime_0.substring(2,4);
		fromTime_si		= fromTime_0.substring(0,2);
		fromTime_bun	= fromTime_0.substring(2,4);	
	}
	if(arrivalSwitchDTO.getForwardtype()==1){
		forwardNumber_1	= arrivalSwitchDTO.getForwardnumber();
		forwardType_1	= arrivalSwitchDTO.getForwardtype();
		WaitTime_1		= arrivalSwitchDTO.getForwardwaittime();
	}
	if(arrivalSwitchDTO.getForwardtype()==2){
		forwardNumber_2	= arrivalSwitchDTO.getForwardnumber();
		forwardType_2	= arrivalSwitchDTO.getForwardtype();
	}
	if(arrivalSwitchDTO.getForwardtype()==3){
		forwardNumber_3	= arrivalSwitchDTO.getForwardnumber();
		forwardType_3	= arrivalSwitchDTO.getForwardtype();
	}	
}


//할당받은 DataStatement 객체는 반납
if (stmt != null ) ConnectionManager.freeStatement(stmt);
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="icon" type="image/x-icon" />
<link href="<%=StaticString.ContextRoot%>/olleh.ico" rel="shortcut icon" type="image/x-icon" />
<title>ID: , Ver: ></title>
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/selcet.js"></script>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/common.js'></script>

<script type="text/JavaScript">

</script>
</head>

<body onLoad="MM_preloadImages('imgs/menu_calllist_select_btn.gif','<%=StaticString.ContextRoot%>/imgs/menu_premium_select_btn.gif')">
<script type="text/javascript" src="js/selcet.js"></script>
<!-- <div> -->
<!-- ajax source file -->
<script language="JavaScript" src="<%=StaticString.ContextRoot%>/js/ajax.js"></script>
<!-- Drag and Drop source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/wz_dragdrop.js" ></script>
<!-- Shadow Div source file -->
<script type="text/javascript" src="<%=StaticString.ContextRoot%>/js/shadow_div.js" ></script>
<script language="JavaScript" type="text/JavaScript">

</script>

<form name="frmPopup" method="post">
<input type='hidden' name ='hiEi64' 		value="<%=e164%>">
<input type='hidden' name ='hiTimeCount' 	value="<%=tCount%>">

<table width="810" border="0" cellspacing="0" cellpadding="0" align="center" bgcolor="eaeaea">
  <tr>
    <td>
	  <table width="810" border="0" cellspacing="0" cellpadding="0" align="center">
	    <tr>
		    <td height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> 
		    	<strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">착신전환 수정 [<%=e164%>]</strong>
		    </td>
		    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">
		    	<img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand">&nbsp;&nbsp;
		    </td>
		    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
	    </tr>
	  </table>
	</td>
  </tr>	
  <tr>
    <td>
		<!--star--콘텐츠페이지-->
		<table width="810" border="0" cellspacing="0" cellpadding="0" align="center">
		  <tr>
		    <td style="padding-top:10; padding-bottom:5; background:eeeff0; border-bottom:1 solid #cdcecf; height:325" valign="top">
		      <table width="775" border="0" cellspacing="0" cellpadding="1	" align="left" style="margin:0 0 0 8 ">
		        <tr>
		          <td height="290" valign="top">
		            <table width="775" border="0" cellspacing="0" cellpadding="1">
		            	<tr>
		              		<td>수신되는 전화를 특정 조건에 따라 지정한 번호나 음성 사서함으로 돌려줄 수 있습니다<br><br>
		                		<%if(answerService.equals("0")){%>
		                			<input type="radio" name="arrivalType" value="1" id="arrivalType_1" onClick="forwardType_New(1);" checked>착신 전화 사용하지 않음<br>
		                		<%}else{%>
		                			<input type="radio" name="arrivalType" value="1" id="arrivalType_1" onClick="forwardType_New(1);">착신 전화 사용하지 않음<br>
		                		<%}%>
		                		
		                		<%if(answerService.equals("1")||answerService.equals("3")){%>
		                			<input type="radio" name="arrivalType" value="2" id="arrivalType_2" onClick="forwardType_New(2);" checked>모든 수신 전화를 무조건 다음으로 착신 전환
		                		<%}else{%>
		                			<input type="radio" name="arrivalType" value="2" id="arrivalType_2" onClick="forwardType_New(2);">모든 수신 전화를 무조건 다음으로 착신 전환
		                		<%}%>	
		                	</td>
		            	</tr>
		            	<tr>
		              		<td style="padding-bottom:5 ">
		              			<table width="775" border="0" cellspacing="0" cellpadding="0">
		                  			<%if(answerService.equals("1")||answerService.equals("3")){%>
		                  			<tr>
		                    			<td width="44"></td>
		                    			<td width="122" valign="bottom">&nbsp;
		                    				<select name="selectType1" id="selectType1" onChange="javascript:selectType()">
		                        				<option <%if(answerService.equals("1")){%> selected <%}%> value="1">지정 번호</option>
		                        				<option <%if(answerService.equals("3")){%> selected <%}%> value="2">음성 사서함</option>
		                      				</select>
		            					</td>
		                    			<td width="407">
		                    				<%if(answerService.equals("1")){%>
		                    					<input type="text" name="txtNumber1" id="txtNumber1" value="<%=directForward%>" style="width:173">
		                    				<%}else{%>
		                    					<input type="text" name="txtNumber1" id="txtNumber1" value=""style="width:173" disabled>
		                    				<%}%>
		                    			</td>
		                    			<td width="202" align="left" valign="top" style="padding-right:6 "></td>
		                  			</tr>
		                  			<%}else{%>
		                  			<tr>
		                    			<td width="44"></td>
		                    			<td width="122" valign="bottom">&nbsp;
		                    				<select name="selectType1" id="selectType1" onChange="javascript:selectType()" disabled>
		                        				<option value="1">지정 번호</option>
		                        				<option value="2">음성 사서함</option>
		                      				</select>
		            					</td>
		                    			<td width="407"><input type="text" name="txtNumber1" id="txtNumber1" style="width:173" disabled></td>
		                    			<td width="202" align="left" valign="top" style="padding-right:6 "></td>
		                  			</tr>		                  			
		                  			<%}%>
		              			</table>
		                		<span>
		                		<%if(answerService.equals("2")){%>
		                			<input type="radio" name="arrivalType" value="3" id="arrivalType_3" onClick="forwardType_New(3);" checked>조건부 착신 전환
		                		<%}else{%>
		                			<input type="radio" name="arrivalType" value="3" id="arrivalType_3" onClick="forwardType_New(3);">조건부 착신 전환
		                		<%}%>			                			
		                		</span>
		                		<table width="97%" border="0" align="right">
		                  			<%if(answerService.equals("2")){%>
			                  			
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">
			                    				<span class="table_column">
			                      				<%if(forwardType_2==2){%>
			                      					<input name="chkForward_2" type="checkbox" id="chkForward_2" style="width:15 " checked />
			                      				<%}else{%>
			                      					<input name="chkForward_2" type="checkbox" id="chkForward_2" style="width:15 " />
			                      				<%}%>
			                    				</span>
			                    			</th>
			                    			<td height="22" colspan="2" valign="middle">통화 중일 때 항상 착신 전환 </td>
			                    			<td height="22">&nbsp;</td>
			                    			<td height="22">&nbsp;착신전환 지정 번호</td>
			                    			<td height="22"><input type="text" name="txtNumber4" id="txtNumber4" value="<%=forwardNumber_2%>" style="width:173 "></td>
			                  			</tr>
			                  			<tr>
			                    			<td height="2" colspan="6"> </td>
			                  			</tr>
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">
			                    				<span class="table_column">
			                      				<%if(forwardType_3==3){%>
			                      					<input name="chkForward_3" type="checkbox" id="chkForward_3" style="width:15 " checked />
			                      				<%}else{%>
			                      					<input name="chkForward_3" type="checkbox" id="chkForward_3" style="width:15 " />
			                      				<%}%>
			                    				</span>
			                    			</th>
			                    			<td height="22" colspan="2" valign="middle">단말 장애일 때 항상 착신 전환 </td>
			                    			<td height="22">&nbsp;</td>
			                    			<td height="22">&nbsp;착신전환 지정 번호</td>
			                    			<td height="22"><input type="text" name="txtNumber5" id="txtNumber5" value="<%=forwardNumber_3%>" style="width:173 "></td>
			                  			</tr>
			                  			<tr>
			                    			<td height="2" colspan="6"> </td>
			                  			</tr>
			                  			
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">
			                    				<span class="table_column">
			                      				<%if(forwardType_1==1){%>
			                      					<input name="chkForward_1" type="checkbox" id="chkForward_1" style="width:15 " checked />
			                      				<%}else{%>
			                      					<input name="chkForward_1" type="checkbox" id="chkForward_1" style="width:15 " />
			                      				<%}%>
			                    				</span>
			                    			</th>
						                    <td height="22" colspan="2" valign="middle">무응답일 때 항상 착신 전환 </td>
						                    <td height="22">&nbsp;</td>
						                    <td height="22">&nbsp;</td>
						                    <td height="22">&nbsp;</td>
			                  			</tr>
			                  			<tr>
			                    			<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">&nbsp;</th>			                    			 
			                        		<%if(forwardType_1==1){%>
			                        		<td height="22" colspan="2">대기 시간
			                        		<select name="waitTime" id="waitTime">
						                        <option <%if(WaitTime_1==0){%> selected <%}%> value="00">00</option>
						                        <option <%if(WaitTime_1==5){%> selected <%}%> value="05">05</option>
						                        <option <%if(WaitTime_1==10){%> selected <%}%> value="10">10</option>
												<option <%if(WaitTime_1==15){%> selected <%}%> value="15">15</option>
						                        <option <%if(WaitTime_1==20){%> selected <%}%> value="20">20</option>
						                        <option <%if(WaitTime_1==25){%> selected <%}%> value="25">25</option>
												<option <%if(WaitTime_1==30){%> selected <%}%> value="30">30</option>
						                        <option <%if(WaitTime_1==35){%> selected <%}%> value="35">35</option>
						                        <option <%if(WaitTime_1==40){%> selected <%}%> value="40">40</option>
												<option <%if(WaitTime_1==45){%> selected <%}%> value="45">45</option>
						                        <option <%if(WaitTime_1==50){%> selected <%}%> value="50">50</option>
						                        <option <%if(WaitTime_1==55){%> selected <%}%> value="55">55</option>
												<option <%if(WaitTime_1==60){%> selected <%}%> value="60">60</option>
			                        		</select> 초 이상 일때 착신 전환
			                        		</td>
			                    			<td height="22">&nbsp;</td>
			                    			<td height="22">&nbsp;착신전환 지정 번호</td>
			                    			<td height="22"><input type="text" name="txtNumber3" id="txtNumber3" value="<%=forwardNumber_1%>" style="width:173 "></td>
			                    			<%}else{%>
			                    			<td height="22" colspan="2">대기 시간
			                        		<select name="waitTime" id="waitTime">
						                        <option value="00">00</option>
						                        <option value="05">05</option>
						                        <option value="10">10</option>
												<option value="15">15</option>
						                        <option value="20">20</option>
						                        <option value="25">25</option>
												<option value="30">30</option>
						                        <option value="35">35</option>
						                        <option value="40">40</option>
												<option value="45">45</option>
						                        <option value="50">50</option>
						                        <option value="55">55</option>
												<option value="60">60</option>
			                        		</select> 초 이상 일때 착신 전환
			                        		</td>
			                    			<td height="22">&nbsp;</td>
			                    			<td height="22">&nbsp;착신전환 지정 번호</td>
			                    			<td height="22"><input type="text" name="txtNumber3" id="txtNumber3" style="width:173 "></td>			                    			
			                    			<%}%>
			                  			</tr>

			                  			<tr>
			                    			<td height="2" colspan="6"> </td>
			                  			</tr>

			                  			<tr>
			                  				<td width="3%">&nbsp;</td>
			                    			<th width="3%" scope="row">
			                    				<span class="table_column">
			                      				<%if(forwardType_0==0){%>
			                      					<input name="chkForward_0" type="checkbox" id="chkForward_0" style="width:15 " onclick="chkTimeArrival('<%=e164%>');" checked />
			                      				<%}else{%>
			                      					<input name="chkForward_0" type="checkbox" id="chkForward_0" style="width:15 " onclick="chkTimeArrival('<%=e164%>');" />
			                      				<%}%>
			                    				</span>
			                    			</th>
			                    			<td colspan="2" align="left" valign="middle">특정 시간대 별 항상 착신 전환 </td>
			                    			<td width="9%">&nbsp;</td>
			                    			<td colspan="2">&nbsp;</td>
			                  			</tr>
			                  			
										<tr>
			                  				<td width="3%"></td>
			                    			<td></td>
			                    			<td colspan="2">
			                    			<%if(forwardType_0==0){%>
			                    				<div id="div1" name="div1" style="position:absolute; overflow:hidden;"><a href="javascript:goEditPopup('<%=e164%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image111','','<%=StaticString.ContextRoot%>/imgs/Content_Arrival_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_Arrival_d_btn.gif" name="Image111" width="130" height="20" border="0"></a></div>
			                    			<%}else{%>
			                    				<div id="div1" name="div1" style="position:absolute; overflow:hidden; display:none;"><a href="javascript:goEditPopup('<%=e164%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image111','','<%=StaticString.ContextRoot%>/imgs/Content_Arrival_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_Arrival_d_btn.gif" name="Image111" width="130" height="20" border="0"></a></div>
			                    			<%}%>
			                    			</td>
			                    			<td></td>
			                    			<td></td>
			                    			<td></td>
			                  			</tr>
			                  			
			                  			<tr>
			                    			<td height="10" colspan="6"> </td>
			                  			</tr>
			                  			
			                  		<%}else{%>
			                  			
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">
			                    				<span class="table_column">
			                      				<input name="chkForward_2" type="checkbox" id="chkForward_2" style="width:15 " disabled />
			                    				</span>
			                    			</th>
			                    			<td height="22" colspan="2" valign="middle">통화 중일 때 항상 착신 전환 </td>
			                    			<td height="22">&nbsp;</td>
			                    			<td height="22">&nbsp;착신전환 지정 번호</td>
			                    			<td height="22"><input type="text" name="txtNumber4" id="txtNumber4" style="width:173 " disabled></td>
			                  			</tr>
			                  			<tr>
			                    			<td height="2" colspan="6"> </td>
			                  			</tr>
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">
			                    				<span class="table_column">
			                      				<input name="chkForward_3" type="checkbox" id="chkForward_3" style="width:15 " disabled />
			                    				</span>
			                    			</th>
			                    			<td height="22" colspan="2" valign="middle">단말 장애일 때 항상 착신 전환 </td>
			                    			<td height="22">&nbsp;</td>
			                    			<td height="22">&nbsp;착신전환 지정 번호</td>
			                    			<td height="22"><input type="text" name="txtNumber5" id="txtNumber5" style="width:173 " disabled></td>
			                  			</tr>
			                  			<tr>
			                    			<td height="2" colspan="6"> </td>
			                  			</tr>
			                  			
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">
			                    				<span class="table_column">
			                      				<input name="chkForward_1" type="checkbox" id="chkForward_1" style="width:15 " disabled />
			                    				</span>
			                    			</th>
						                    <td height="22" colspan="2" valign="middle">무응답일 때 항상 착신 전환 </td>
						                    <td height="22">&nbsp;</td>
						                    <td height="22">&nbsp;</td>
						                    <td height="22">&nbsp;</td>
			                  			</tr>
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th height="22" scope="row">&nbsp;</th>
			                    			<td height="22" colspan="2">대기 시간 
			                        		<select name="waitTime" id="waitTime" disabled>
						                        <option value="00">00</option>
						                        <option value="05">05</option>
						                        <option value="10">10</option>
												<option value="15">15</option>
						                        <option value="20">20</option>
						                        <option value="25">25</option>
												<option value="30">30</option>
						                        <option value="35">35</option>
						                        <option value="40">40</option>
												<option value="45">45</option>
						                        <option value="50">50</option>
						                        <option value="55">55</option>
												<option value="60">60</option>
			                        		</select> 초 이상 일때 착신 전환
			                        		</td>
			                    			<td height="22">&nbsp;</td>
			                    			<td height="22">&nbsp;착신전환 지정 번호</td>
			                    			<td height="22"><input type="text" name="txtNumber3" id="txtNumber3" style="width:173 " disabled></td>
			                  			</tr>

			                  			<tr>
			                    			<td height="2" colspan="6"> </td>
			                  			</tr>
			                  			
			                  			<tr>
			                  				<td width="3%" height="22">&nbsp;</td>
			                    			<th width="3%" height="22" scope="row">
			                    				<span class="table_column">
			                      				<input name="chkForward_0" type="checkbox" id="chkForward_0" style="width:15 " onclick="chkTimeArrival('<%=e164%>');" disabled />
			                    				</span>
			                    			</th>
			                    			<td height="22" colspan="2" align="left" valign="middle">특정 시간대 별 항상 착신 전환 </td>
			                    			<td width="9%" height="22">&nbsp;</td>
			                    			<td height="22" colspan="2">&nbsp;</td>
			                  			</tr>
			                  			<tr>
			                  				<td width="3%"></td>
			                    			<td></td>
			                    			<td colspan="2">
			                    				<div id="div1" name="div1" style="position:absolute; overflow:hidden; display:none;"><a href="javascript:goEditPopup('<%=e164%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image111','','<%=StaticString.ContextRoot%>/imgs/Content_Arrival_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_Arrival_d_btn.gif" name="Image111" width="130" height="20" border="0"></a></div>
			                    			</td>
			                    			<td></td>
			                    			<td></td>
			                    			<td></td>
			                  			</tr>
			                  			
			                  			<tr>
			                    			<td height="10" colspan="6"> </td>
			                  			</tr>

			                  		<%}%>
		                		</table>
		                		<span>                
		                		</span>
		                	</td>
		            	</tr>
		          </table>
		          <div align="center"><br>
		          </div>            
		          <div align="center"><a href="javascript:goInsertPro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image222','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image222" width="40" height="20" border="0"></a> <a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image444','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image444" width="40" height="20" border="0"></a></div></td>
		        </tr>
		      </table>
		    </td>
		  </tr>
		</table>
		
		<!--end--콘텐츠페이지-->

    </td>
  </tr>

</table>
</form>

<!-- </div> -->
</body>
</html>
