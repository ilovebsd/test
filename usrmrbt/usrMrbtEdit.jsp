<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*" %>
<%@ page import="waf.*" %>
<%@ page import="dto.AddMrbtDTO" %>
<%@ page import="useconfig.AddServiceList"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>

<%
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;

String 	ei64		= new String(request.getParameter("e164").getBytes("8859_1"), "euc-kr");
String[] e164s 	= StringUtil.getParser(ei64, "");
String 	mrbtFile	= request.getParameter("filename");

boolean bModify = mrbtFile!=null && mrbtFile.length()>0 ;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
//서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 		= ConnectionManager.allocStatement("SSW", sesSysGroupID);

AddServiceList 	addServiceList 	= new AddServiceList();
List 			iList 			= addServiceList.getAddMrbtList(stmt, ei64);	// 데이타 조회
int				mrbtCount		= iList.size();		

//할당받은 DataStatement 객체는 반납
if (stmt != null ) ConnectionManager.freeStatement(stmt);

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<form name="editForm" method="post" enctype="multipart/form-data">
<input type="hidden" name="scLang" value="kor">
<input type="hidden" name="scLogCheck" value="N">
<input type="hidden" name="responseModeSize" value="">

<input type='hidden' name ='e164' 				value="<%=ei64%>"/>
<input type='hidden' name ='hiEi64_03' 			value="<%=ei64%>"/>
<input type='hidden' name ='hiVirtualc1_02'		value=""/>
<input type='hidden' name ='hiVirtualc2_02'		value=""/>
<input type='hidden' name ='uploadfilename_03'	value=""/>
<input type='hidden' name ='hiStartTime_03'		value=""/>
<input type='hidden' name ='hiEndTime_03'		value=""/>
<input type='hidden' name ='hiDayValue_03'		value=""/>
<input type='hidden' name ='deleteStr_02' 		value=""/>
<input type='hidden' name ='insertStr_02' 		value=""/>

<input type='hidden' name ='hiUserID'			value="<%=authGroupid%>">

<table width="500" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
<tr height="30" >
  <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="5">
  <table  border="0" cellpadding="0" cellspacing="0" style="TABLE-LAYOUT: fixed">
   <tr>
    <td width="10">&nbsp;</td>
    <td colspan="2"><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">통화연결음 <%=bModify? "수정 [번호 : "+ei64+"]":"추가" %></span></td>
       <td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td width="10">&nbsp;</td>
   </tr>

  </table>
  </td>
 </tr>

	<tr>
	  	<td colspan="5" height="7"></td>
	</tr>

	<tr>
	    <td width="10" height="25">&nbsp;</td>
	    <td colspan="3"  align="left" bgcolor="#FFFFFF" style="padding-right:5 ">
		    &nbsp;&nbsp;&nbsp;&nbsp;통화연결음 파일&nbsp;&nbsp;
			<input type="file" name="wFile_2" style="width:260px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
		</td>
		<td width="10">&nbsp;</td>
	</tr>

    <tr>
	    <td width="10" height="10">&nbsp;</td>
		<td  colspan="3" bgcolor="#FFFFFF" style="padding-left:5"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="480" align="center"></td>
	    <td width="10">&nbsp;</td>
    </tr>

    <tr>
	    <td width="10"  height="10">&nbsp;</td>

		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10">

		<table width="480" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>&nbsp;
				    <select name="naScCode_2" style="width:65 " class="select01">
			        	<option value="EEEEEEEE">매일</option>
			        	<option value="EEEEEEE1">일요일</option>
			        	<option value="EEEEEEE2">월요일</option>
			        	<option value="EEEEEEE3">화요일</option>
			        	<option value="EEEEEEE4">수요일</option>
			        	<option value="EEEEEEE5">목요일</option>
			        	<option value="EEEEEEE6">금요일</option>
			        	<option value="EEEEEEE7">토요일</option>
			        </select>&nbsp;

					<select name="time1_2" style="width:40" class="select01">
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
					<select name="time2_2" style="width:40" class="select01">
                       	<option value="00">00</option>
                       	<option value="10">10</option>
                       	<option value="20">20</option>
                       	<option value="30">30</option>
                       	<option value="40">40</option>
                       	<option value="50">50</option>
					</select>분 ~ 
					<select name="time3_2" style="width:40" class="select01">
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
                       	<option value="24" selected>24</option>
                    </select>시
					<select name="time4_2" style="width:40" class="select01">
                       	<option value="00">00</option>
                       	<option value="10">10</option>
                       	<option value="20">20</option>
                       	<option value="30">30</option>
                       	<option value="40">40</option>
                       	<option value="50">50</option>
					</select>분&nbsp;&nbsp;
					<%if(bModify){ %>
						<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript:goEditAddPro('<%=ei64%>');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle">
					<%} %>
				</td>

			</tr>
		</table>
		</td>
		<td width="10">&nbsp;</td>
	</tr>

    <tr>
	    <td width="10"  height="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:5">
		<table width="480" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td colspan="3" bgcolor="#FFFFFF" style="padding-left:5">&nbsp;</td>
			</tr>
		</table>
		</td>
		<td width="10">&nbsp;</td>
	</tr>
<%
if(bModify){
%>
    <tr>
	    <td width="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10" valign="top">
		<!--div id="responseTimeDiv"-->
		<table id=box border="0" cellspacing="0" cellpadding="0" class="list_table">
			<!--tbody id="subTbody"-->
			<tr height="20" bgcolor="rgb(190,188,182)" align="center">
				<td width="77" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">요일 설정</td>
				<td width="75" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">시작 시간</td>
				<td width="75" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">종료 시간</td>
				<td width="180" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">파일명</td>
				<td width="57" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">삭제</td>
			</tr>
			<!--/tbody-->
		</table>
		<!--/div-->
		</td>
	    <td width="10">&nbsp;</td>
  	</tr>

	<tr>
	    <td width="10">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10" valign="top">
			
	        <table border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
<%
			AddMrbtDTO 	addMrbtDTO 	= null;
			int chk = 0;  
		                  
	      	for ( int idx = 0; idx < mrbtCount ; idx++ ) {
	      		addMrbtDTO = (AddMrbtDTO)iList.get(idx);        	
	            if(chk == 0){
%>    
				<tr height="22" bgcolor="#F3F9F5" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="#F3F9F5">
					<%if("EEEEEEEE".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">매일&nbsp;</td>
					<%}else if("EEEEEEE1".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">일요일&nbsp;</td>
					<%}else if("EEEEEEE2".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">월요일&nbsp;</td>
					<%}else if("EEEEEEE3".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">화요일&nbsp;</td>
					<%}else if("EEEEEEE4".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">수요일&nbsp;</td>
					<%}else if("EEEEEEE5".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">목요일&nbsp;</td>
					<%}else if("EEEEEEE6".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">금요일&nbsp;</td>
					<%}else if("EEEEEEE7".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">토요일&nbsp;</td>					
					<%}%>
					<td width="75" class="table_column"><%=addMrbtDTO.getStarttime()%>&nbsp;</td>
					<td width="75" class="table_column"><%=addMrbtDTO.getEndtime()%>&nbsp;</td>
					<td width="180" class="table_column"><%=addMrbtDTO.getSound()%>&nbsp;</td>
					<td width="57" class="table_column"><a href="#" onclick="javascript: showEditDelete('<%=ei64%>','<%=addMrbtDTO.getDayvalue()%>','<%=addMrbtDTO.getStarttime()%>','<%=addMrbtDTO.getEndtime()%>','<%=addMrbtDTO.getSound()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image1<%=idx%>" width="34" height="18" border="0"></a></td>
				</tr>
<%
	                chk = 1;
	            }else{    
%>
				<tr height="22" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="ffffff">
					<%if("EEEEEEEE".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">매일&nbsp;</td>
					<%}else if("EEEEEEE1".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">일요일&nbsp;</td>
					<%}else if("EEEEEEE2".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">월요일&nbsp;</td>
					<%}else if("EEEEEEE3".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">화요일&nbsp;</td>
					<%}else if("EEEEEEE4".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">수요일&nbsp;</td>
					<%}else if("EEEEEEE5".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">목요일&nbsp;</td>
					<%}else if("EEEEEEE6".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">금요일&nbsp;</td>
					<%}else if("EEEEEEE7".equals(addMrbtDTO.getDayvalue())){%>
						<td width="77" class="table_column">토요일&nbsp;</td>					
					<%}%>
					<td width="75" class="table_column"><%=addMrbtDTO.getStarttime()%>&nbsp;</td>
					<td width="75" class="table_column"><%=addMrbtDTO.getEndtime()%>&nbsp;</td>
					<td width="180" class="table_column"><%=addMrbtDTO.getSound()%>&nbsp;</td>
					<td width="57" class="table_column"><a href="#" onclick="javascript: showEditDelete('<%=ei64%>','<%=addMrbtDTO.getDayvalue()%>','<%=addMrbtDTO.getStarttime()%>','<%=addMrbtDTO.getEndtime()%>','<%=addMrbtDTO.getSound()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image1<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image1<%=idx%>" width="34" height="18" border="0"></a></td>
				</tr>
<% 
	                chk = 0;
	            }
	        }
%>
			</table>
		</td>
	</tr>
<%
}//e164s.length==1
%>	
    <tr>
	    <td width="10"  height="10">&nbsp;</td>

		<td colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10" height="10">&nbsp;</td>
  </tr>

  <tr>
    <td height="35">&nbsp;</td>
    <td colspan="3" align="center" style="padding-top:3 ">
      <%if(bModify){ %>
      	<img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif");' style="CURSOR:hand;" onClick="hiddenAdCodeDiv()" width="40" height="20">	
      <%}else{ %>
	  	<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript:goInsertPro('<%=ei64%>');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle">
	  <%} %>
	</td>
    <td>&nbsp;</td>
  </tr>

</table>
</form>
</body>
</html>
