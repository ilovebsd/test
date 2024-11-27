<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="useconfig.AddServiceList"%>
<%@ page import="java.util.List" %>
<%@ page import="dto.KeynumberForwardDaysDTO"%>
<%@ page import="dto.KeynumberForwardWeekDTO"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses	= request.getSession(false);

//String userparam    = new String(request.getParameter("userparam")).trim();
String ei64			= new String(request.getParameter("e164").getBytes("8859_1"), "euc-kr");

String[] e164s = StringUtil.getParser(ei64, "");
boolean bModify = e164s.length==1 ;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);

AddServiceList 	addServiceList = new AddServiceList();
String[]	varTmp;
String		forwardtype 	= "";
String		forwardnum 		= "";
String		vmsforward 		= "";
int			countDays		= 0;
int			countWeek		= 0;

List 		iList = null;
List 		iList2 = null;
try{
	
	String 		strAnswer		= addServiceList.getDeptNumberForwardType(stmt, ei64);		// 데이타 조회
	
	varTmp 		= strAnswer.split("[|]");
	forwardtype	= varTmp[0];
	forwardnum	= varTmp[1];	                        	
	vmsforward	= varTmp[2];
	
	iList 		= addServiceList.getKeynumberForwardDaysList(stmt, ei64);		// 데이타 조회
	countDays 	= iList.size();
	iList2 		= addServiceList.getKeynumberForwardWeekList(stmt, ei64);
	countWeek 	= iList2.size();
	
	System.out.println("#################### strAnswer : "+strAnswer);
	
} catch (Exception e) {
	e.printStackTrace();
} finally {
	//할당받은 DataStatement 객체는 반납
	if (stmt != null ) ConnectionManager.freeStatement(stmt);
}
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="editForm" method="post">
<input type='hidden' name ='dataType'		value="">
<input type='hidden' name ='hiE164_Edit'	value="<%=ei64%>">

<table width="450" height="345" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">대표번호 착신전환 번호 <%=bModify?"수정 [대표번호: "+ei64+"]":"등록"%></strong></td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" 
    	onClick="hiddenAdCodeDiv2();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="4" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7" height="10"></td>
    <td width="386" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
  
  <tr>
    <td width="7">&nbsp;</td>
    <td colspan="2" align="center" bgcolor="#FFFFFF" valign="top">
        <table width="415" height="320" border="0" cellspacing="0" cellpadding="0"  class="list_table">
            <tr height="10" bgcolor="#F3F9F5" align="center" ><td></td></tr>
            
            <tr bgcolor="#F3F9F5">
            	<td width="410" align="left">
            		<div id="div_0" name="div_0" style="position:absolute; left:25px; top:67px; width:400px; overflow:hidden;">
            		<%if("1".equals(forwardtype)){%>
	            		<input type="radio" name="forwardingType" value="1" id="forwardingType_1" onClick="forwardingType_Chk_Edit();" checked>무조건 착신전환
	            		<input type="radio" name="forwardingType" value="2" id="forwardingType_2" onClick="forwardingType_Chk_Edit();" >조건별 착신전환
            		<%}else{%>
	            		<input type="radio" name="forwardingType" value="1" id="forwardingType_1" onClick="forwardingType_Chk_Edit();" >무조건 착신전환
	            		<input type="radio" name="forwardingType" value="2" id="forwardingType_2" onClick="forwardingType_Chk_Edit();" checked>조건별 착신전환
            		<%}%>
            		</div>
            	</td>
            </tr>
            <tr height="5" bgcolor="#F3F9F5" align="center" ><td></td></tr>
            
            <tr height="20" bgcolor="#F3F9F5">
              <td width="410" align="left">
              	<%if("1".equals(forwardtype)){%>
	              	<div id="div_1" name="div_1" style="position:absolute; left:41px; top:102px; width:400px; overflow:hidden;">	
	              		착신전환유형&nbsp;&nbsp;&nbsp;&nbsp;
					  <select id="callChangeType" name="callChangeType" style="width:100px" class="select01" onChange="callTypeChange_Edit()">
				        <option value="">선택하세요</option>
				        <option <%if("0".equals(vmsforward)){%> selected <%}%> value="1">일반착신전환</option>
						<option <%if("1".equals(vmsforward)){%> selected <%}%> value="2">VMS착신전환</option>
				      </select>
					</div>			      
					
	              	<div id="div_2" name="div_2" style="position:absolute; left:41px; top:102px; width:400px; display:none;">	
	              		착신전환조건&nbsp;&nbsp;&nbsp;&nbsp;
					  <select id="callForwarding" name="callForwarding" style="width:100px" class="select01" onChange="ForwardingTypeChange_Edit()">
				        <option value="">선택하세요</option>
				        <option value="1">일자별 시간</option>
						<option value="2">요일별 시간</option>
				      </select>
					</div>
				<%}else{%>
	              	<div id="div_1" name="div_1" style="position:absolute; left:41px; top:102px; width:400px; display:none;">	
	              		착신전환유형&nbsp;&nbsp;&nbsp;&nbsp;
					  <select id="callChangeType" name="callChangeType" style="width:100px" class="select01" onChange="callTypeChange_Edit()">
				        <option value="">선택하세요</option>
				        <option value="1">일반착신전환</option>
						<option value="2">VMS착신전환</option>
				      </select>
					</div>			      
					
	              	<div id="div_2" name="div_2" style="position:absolute; left:41px; top:102px; width:400px; overflow:hidden;">	
	              		착신전환조건&nbsp;&nbsp;&nbsp;&nbsp;
					  <select id="callForwarding" name="callForwarding" style="width:100px" class="select01" onChange="ForwardingTypeChange_Edit()">
				        <option value="">선택하세요</option>
				        <option value="1" selected>일자별 시간</option>
						<option value="2">요일별 시간</option>
				      </select>
					</div>
				<%}%>
              </td>
            </tr>
            
            <tr height="20" bgcolor="#F3F9F5">
              <td width="410" align="left">
	            <%if("1".equals(forwardtype)){%>
		            <%if("0".equals(vmsforward)){%>
			            <div id="div1_1" name="div1_1" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden;">
			              	착신전환번호&nbsp;&nbsp;&nbsp;&nbsp;
		              		<input type='text' name='txtNumber' id="txtNumber" value="<%=forwardnum%>" style='width:100px; margin:0 0 0 0' maxlength="14">
		              	</div>
			            <div id="div1_2" name="div1_2" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden; display:none;">
			              	음성사서함번호&nbsp;
		              		<input type='text' name='txtVmsNumber' id="txtVmsNumber" value="" style='width:100px; margin:0 0 0 0' maxlength="14">
		              	</div>
	              	<%}else{%>
			            <div id="div1_1" name="div1_1" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden; display:none;">
			              	착신전환번호&nbsp;&nbsp;&nbsp;&nbsp;
		              		<input type='text' name='txtNumber' id="txtNumber" value="" style='width:100px; margin:0 0 0 0' maxlength="14">
		              	</div>
			            <div id="div1_2" name="div1_2" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden;">
			              	음성사서함번호&nbsp;
		              		<input type='text' name='txtVmsNumber' id="txtVmsNumber" value="<%=forwardnum%>" style='width:100px; margin:0 0 0 0' maxlength="14">
		              	</div>
	              	<%}%>
	              	<div id="div2_1" name="div2_1" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden; display:none;">
				      	착신전환일자&nbsp;&nbsp;&nbsp;&nbsp;
				      	<select name="toMonth" id="toMonth">
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
						</select>월
						<select name="toDay" id="toDay">
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
							<option value="13">13</option>
							<option value="14">14</option>
							<option value="15">15</option>
							<option value="16">16</option>
							<option value="17">17</option>
							<option value="18">18</option>
							<option value="19">19</option>
							<option value="20">20</option>
							<option value="21">21</option>
							<option value="22">22</option>
							<option value="23">23</option>
							<option value="24">24</option>
							<option value="25">25</option>
							<option value="26">26</option>
							<option value="27">27</option>
							<option value="28">28</option>
							<option value="29">29</option>
							<option value="30">30</option>
							<option value="31">31</option>
						</select>일
	              	</div>
	              	
	              	<div id="div2_2" name="div2_2" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden; display:none;">
	              		착신전환요일&nbsp;&nbsp;&nbsp;&nbsp;
	              		<input name="chkSun" type="checkbox" id="chkSun" style="width:15 "/>일
	              		<input name="chkMon" type="checkbox" id="chkMon" style="width:15 "/>월
	              		<input name="chkTue" type="checkbox" id="chkTue" style="width:15 "/>화
	              		<input name="chkWed" type="checkbox" id="chkWed" style="width:15 "/>수
	              		<input name="chkThu" type="checkbox" id="chkThu" style="width:15 "/>목
	              		<input name="chkFri" type="checkbox" id="chkFri" style="width:15 "/>금
	              		<input name="chkSat" type="checkbox" id="chkSat" style="width:15 "/>토
	              	</div>
              	<%}else{%>
		            <div id="div1_1" name="div1_1" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden; display:none;">
		              	착신전환번호&nbsp;&nbsp;&nbsp;&nbsp;
	              		<input type='text' name='txtNumber' id="txtNumber" value="" style='width:100px; margin:0 0 0 0' maxlength="14">
	              	</div>
		            <div id="div1_2" name="div1_2" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden; display:none;">
		              	음성사서함번호&nbsp;
	              		<input type='text' name='txtVmsNumber' id="txtVmsNumber" value="" style='width:100px; margin:0 0 0 0' maxlength="14">
	              	</div>
	              	
	              	<div id="div2_1" name="div2_1" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden;">
				      	착신전환일자&nbsp;&nbsp;&nbsp;&nbsp;
				      	<select name="toMonth" id="toMonth">
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
						</select>월
						<select name="toDay" id="toDay">
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
							<option value="13">13</option>
							<option value="14">14</option>
							<option value="15">15</option>
							<option value="16">16</option>
							<option value="17">17</option>
							<option value="18">18</option>
							<option value="19">19</option>
							<option value="20">20</option>
							<option value="21">21</option>
							<option value="22">22</option>
							<option value="23">23</option>
							<option value="24">24</option>
							<option value="25">25</option>
							<option value="26">26</option>
							<option value="27">27</option>
							<option value="28">28</option>
							<option value="29">29</option>
							<option value="30">30</option>
							<option value="31">31</option>
						</select>일
	              	</div>
	              	
	              	<div id="div2_2" name="div2_2" style="position:absolute; left:41px; top:127px; width:400px; overflow:hidden; display:none;">
	              		착신전환요일&nbsp;&nbsp;&nbsp;&nbsp;
	              		<input name="chkSun" type="checkbox" id="chkSun" style="width:15 "/>일
	              		<input name="chkMon" type="checkbox" id="chkMon" style="width:15 "/>월
	              		<input name="chkTue" type="checkbox" id="chkTue" style="width:15 "/>화
	              		<input name="chkWed" type="checkbox" id="chkWed" style="width:15 "/>수
	              		<input name="chkThu" type="checkbox" id="chkThu" style="width:15 "/>목
	              		<input name="chkFri" type="checkbox" id="chkFri" style="width:15 "/>금
	              		<input name="chkSat" type="checkbox" id="chkSat" style="width:15 "/>토
	              	</div>
              	<%}%>
              </td>
            </tr>
            <tr height="20" bgcolor="#F3F9F5">
              <td width="410" align="left">
              	<%if("2".equals(forwardtype)||"0".equals(forwardtype)){%>
	              	<div id="div2_3" name="div2_3" style="position:absolute; left:41px; top:152px; width:400px; overflow:hidden;">
				      	착신전환시간&nbsp;&nbsp;&nbsp;&nbsp;
						<select name="toTimeSi" id="toTimeSi">
							<option value="00">00</option>
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
							<option value="13">13</option>
							<option value="14">14</option>
							<option value="15">15</option>
							<option value="16">16</option>
							<option value="17">17</option>
							<option value="18">18</option>
							<option value="19">19</option>
							<option value="20">20</option>
							<option value="21">21</option>
							<option value="22">22</option>
							<option value="23">23</option>
						</select>시
						<select name="toTimeBun" id="toTimeBun">
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
							<option value="59">59</option>
						</select>분~
						<select name="fromTimeSi" id="fromTimeSi">
							<option value="00">00</option>
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
							<option value="13">13</option>
							<option value="14">14</option>
							<option value="15">15</option>
							<option value="16">16</option>
							<option value="17">17</option>
							<option value="18">18</option>
							<option value="19">19</option>
							<option value="20">20</option>
							<option value="21">21</option>
							<option value="22">22</option>
							<option value="23">23</option>
						</select>시
						<select name="fromTimeBun" id="fromTimeBun">
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
							<option value="59">59</option>
						</select>분
	              	</div>
              	<%}%>
              </td>
            </tr>
            <tr height="20" bgcolor="#F3F9F5">
              <td width="410" align="left">
              	<%if("2".equals(forwardtype)||"0".equals(forwardtype)){%>
	              	<div id="div2_4" name="div2_4" style="position:absolute; left:41px; top:177px; width:400px; overflow:hidden;">	
	              		착신전환유형&nbsp;&nbsp;&nbsp;&nbsp;
					  <select id="callChangeType_02" name="callChangeType_02" style="width:100px" class="select01" onChange="callTypeChange_02_Edit()">
				        <option value="">선택하세요</option>
				        <option value="1" selected>일반착신전환</option>
						<option value="2">VMS착신전환</option>
				      </select>
					</div>
				<%}%>
              </td>
            </tr>

            <tr height="20" bgcolor="#F3F9F5">
              <td width="410" align="left">
	            <%if("2".equals(forwardtype)||"0".equals(forwardtype)){%>
		            <div id="div3_1" name="div3_1" style="position:absolute; left:41px; top:202px; width:400px; overflow:hidden;">
		              	착신전환번호&nbsp;&nbsp;&nbsp;&nbsp;
	              		<input type='text' name='txtNumber_02' id="txtNumber_02" value="" style='width:100px; margin:0 0 0 0' maxlength="14">
	              		&nbsp;&nbsp;<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript: goAddPro2();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle">
	              	</div>
		            <div id="div3_2" name="div3_2" style="position:absolute; left:41px; top:202px; width:400px; overflow:hidden; display:none;">
		              	음성사서함번호&nbsp;
	              		<input type='text' name='txtVmsNumber_02' id="txtVmsNumber_02" value="" style='width:100px; margin:0 0 0 0' maxlength="14">
	              		&nbsp;&nbsp;<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript: goAddPro2();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle">
	              	</div>
              	<%}%>
              </td>
            </tr>
<%if(bModify){ %>     
            <tr height="20" bgcolor="#F3F9F5">
              <td>
              	<%if("2".equals(forwardtype)||"0".equals(forwardtype)){%>
	            	<div id="div_table_01" name="div_table_01" style="position:absolute; left:25px; top:232px; width:400px; overflow:hidden; overflow:hidden;">
					  <table width="400" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
			            <tr align="center" height="20" >
			              <td width="40" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">유형</td>
			              <td width="135" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">조건</td>
			              <td width="80" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">시간</td>
			              <td width="80" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">착신번호</td>
			              <td width="65" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">삭제</td>
			            </tr>
			          </table>
	            	</div>
            	<%}%>
              </td>
            </tr>
       
            <tr height="20" bgcolor="#F3F9F5">
              <td>
              	<%if("2".equals(forwardtype)||"0".equals(forwardtype)){%>
	            	<div id="div_table_02" name="div_table_02" style="overflow-x:hidden; overflow-y:auto; position:absolute; left:25px; top:252px; width:400px; height:105; overflow:hidden;">
	            	  <table width="400" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
<%
						KeynumberForwardDaysDTO 	daysDTO 	= null;
					                  
				      	for ( int idx = 0; idx < countDays ; idx++ ) {
				      		daysDTO = (KeynumberForwardDaysDTO)iList.get(idx);        	
%>
	            		<tr height="20" bgcolor="#F3F9F5" align="center" onmouseover='this.style.backgroundColor="a8d3aa"' onmouseout='this.style.backgroundColor="#F3F9F5"'>
	            			<%if(daysDTO.getVmsForward()==0){%>
	            				<td width="40" align="center" class="table_column">일반</td>
	            			<%}else{%>
	            				<td width="40" align="center" class="table_column">VMS</td>
	            			<%}%>
	            			<td width="135" align="center" class="table_column"><%=daysDTO.getForwardDay().substring(0,2)%>월 <%=daysDTO.getForwardDay().substring(2,4)%>일</td>
	            			<td width="80" align="center" class="table_column"><%=daysDTO.getStartTime().substring(0,2)%>:<%=daysDTO.getStartTime().substring(2,4)%>~<%=daysDTO.getEndTime().substring(0,2)%>:<%=daysDTO.getEndTime().substring(2,4)%></td>
	            			<td width="80" align="center" class="table_column"><%=daysDTO.getForwardNumber()%></td>
	            			<td width="65" align="center" class="table_column"><a href="#" onclick="javascript: goDeletePro2('1','<%=ei64%>','<%=daysDTO.getForwardDay()%>','<%=daysDTO.getStartTime()%>','<%=daysDTO.getEndTime()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image1<%=idx%>" width="34" height="18" border="0"></a></td>
	            		</tr>
<% 
	        			}
%>
	            		
<%
						KeynumberForwardWeekDTO 	weekDTO 	= null;
					                  
				      	for ( int idx = 0; idx < countWeek ; idx++ ) {
				      		weekDTO = (KeynumberForwardWeekDTO)iList2.get(idx);
				      		
				      		String strWeek = "";
				      		String strTemp0 = weekDTO.getDayOftheWeek();
				      		if("1".equals(strTemp0.substring(0,1))){
				      			strWeek = strWeek + "일";
				      		}
				      		if("1".equals(strTemp0.substring(1,2))){
				      			if(!"".equals(strWeek))strWeek = strWeek + "/"; 
				      			strWeek = strWeek + "월";
				      		}
				      		if("1".equals(strTemp0.substring(2,3))){
				      			if(!"".equals(strWeek))strWeek = strWeek + "/";
				      			strWeek = strWeek + "화";
				      		}
				      		if("1".equals(strTemp0.substring(3,4))){
				      			if(!"".equals(strWeek))strWeek = strWeek + "/";
				      			strWeek = strWeek + "수";
				      		}
				      		if("1".equals(strTemp0.substring(4,5))){
				      			if(!"".equals(strWeek))strWeek = strWeek + "/";
				      			strWeek = strWeek + "목";
				      		}
				      		if("1".equals(strTemp0.substring(5,6))){
				      			if(!"".equals(strWeek))strWeek = strWeek + "/";
				      			strWeek = strWeek + "금";
				      		}
				      		if("1".equals(strTemp0.substring(6,7))){
				      			if(!"".equals(strWeek))strWeek = strWeek + "/";
				      			strWeek = strWeek + "토";
				      		}
%>
	            		<tr height="20" bgcolor="#F3F9F5" align="center" onmouseover='this.style.backgroundColor="a8d3aa"' onmouseout='this.style.backgroundColor="#F3F9F5"'>
	            			<%if(weekDTO.getVmsForward()==0){%>
	            				<td width="40" align="center" class="table_column">일반</td>
	            			<%}else{%>
	            				<td width="40" align="center" class="table_column">VMS</td>
	            			<%}%>
	            			<td width="135" align="center" class="table_column"><%=strWeek%></td>
	            			<td width="80" align="center" class="table_column"><%=weekDTO.getStartTime().substring(0,2)%>:<%=weekDTO.getStartTime().substring(2,4)%>~<%=weekDTO.getEndTime().substring(0,2)%>:<%=weekDTO.getEndTime().substring(2,4)%></td>
	            			<td width="80" align="center" class="table_column"><%=weekDTO.getForwardNumber()%></td>
	            			<td width="65" align="center" class="table_column"><a href="#" onclick="javascript: goDeletePro2('2','<%=ei64%>','<%=weekDTO.getDayOftheWeek()%>','<%=weekDTO.getStartTime()%>','<%=weekDTO.getEndTime()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image2<%=idx%>" width="34" height="18" border="0"></a></td>
	            		</tr>
<% 
	        			}
%>
	            	  </table>
	            	</div>
            	<%}%>
              </td>
            </tr>
<%} %>            
            <tr height="10" bgcolor="#F3F9F5" align="center" ><td></td></tr>
        </table>
    </td>
    <td width="7"></td>
  </tr>
  <tr>
    <td width="7" height="10"></td>
    <td width="386" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
     
  <tr>
    <td height="5" colspan="4"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="4" style="padding-top:3 ">
	  <%if("1".equals(forwardtype)){%>
		  <div id="div4" name="div4" style="position:absolute; left:120px; top:398px; width:200; overflow:hidden;">	
			<img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onClick="javascript: goAddPro3();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
		  	<img src="<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_p_btn.gif");' style="CURSOR:hand;" 
		  		onClick="hiddenAdCodeDiv2();" width="40" height="20">
		  </div>
		  <div id="div5" name="div5" style="position:absolute; left:120px; top:398px; width:200; overflow:hidden; display:none;">	
		  	<img src="<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_p_btn.gif");' style="CURSOR:hand;" 
		  		onClick="hiddenAdCodeDiv2();" width="40" height="20">
		  </div>
	  <%}else{%>
		  <div id="div4" name="div4" style="position:absolute; left:120px; top:398px; width:200; overflow:hidden; display:none;">	
			<img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onClick="javascript: goAddPro3();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" width="40" height="20">
		  	<img src="<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_p_btn.gif");' style="CURSOR:hand;" 
		  		onClick="hiddenAdCodeDiv2();" width="40" height="20">
		  </div>
		  <div id="div5" name="div5" style="position:absolute; left:120px; top:398px; width:200; overflow:hidden;">	
		  	<img src="<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_p_btn.gif");' style="CURSOR:hand;" 
		  		onClick="hiddenAdCodeDiv2();" width="40" height="20">
		  </div>
	  <%}%>
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
<script>
	forwardingType_Chk_Edit();
</script>
