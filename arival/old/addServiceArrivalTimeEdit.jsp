<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List" %>
<%@ page import="addition.ArrivalSwitchList"%>
<%@ page import="dto.ArrivalSwitchDTO" %>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String e164			= new String(request.getParameter("e164").getBytes("8859_1"), "euc-kr");

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW");

ArrivalSwitchList 	arrivalSwitchList 	= new ArrivalSwitchList();

try{
	List 	iList 	= arrivalSwitchList.getDetailList(stmt, e164);		// 데이타 조회
	int 	iCount 	= iList.size();
	
	int 	tCount2 = arrivalSwitchList.getTimeCount(stmt, e164);
	//System.out.println("#################### tCount : "+tCount);
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="editForm" method="post">
<input type='hidden' name ='dataType'		value="">
<input type='hidden' name ='hiE164_Edit'	value="<%=e164%>">
<input type='hidden' name ='hiTimeCount2' 	value="<%=tCount2%>">

<table width="400" height="245" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">특정 시간대별 착신전환 [<%=e164%>]</strong></td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv3();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="4" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7" height="10"></td>
    <td width="336" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
  
  <tr>
    <td width="7">&nbsp;</td>
    <td colspan="2" align="center" bgcolor="#FFFFFF">
        <table width="365" border="0" cellspacing="0" cellpadding="0"  class="list_table">
            <tr bgcolor="rgb(243,247,245)"><td>&nbsp;</td>
            </tr>
            
            <tr bgcolor="rgb(243,247,245)">
              <td width="365" align="left">
		      	&nbsp;&nbsp;착신전환시간&nbsp;&nbsp;
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
              </td>
            </tr>

			<tr bgcolor="rgb(243,247,245)"><td height="5"> </td>
            </tr>
            
            <tr bgcolor="rgb(243,247,245)">
              <td width="365" align="left">
	              	&nbsp;&nbsp;착신전환번호&nbsp;&nbsp;
              		<input type='text' name='txtNumber2' id="txtNumber2" value="" style='width:100; margin:0 0 0 0' maxlength="14">&nbsp;&nbsp;<img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript:goAddPro2();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle">
              </td>
            </tr>

            <tr bgcolor="rgb(243,247,245)"><td height="5"> </td>
            </tr>
            
            <tr bgcolor="rgb(243,247,245)">
              <td valign="top">
              	<div style='width:365px;'>
				  <table width="365" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
		            <tr align="center" height="20" >
		              <td width="125" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">시간</td>
		              <td width="160" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">착신번호</td>
		              <td width="80" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">삭제</td>
		            </tr>
		          </table>
		         </div>
              </td>
            </tr>
            
            <tr>
              <td height="62" bgcolor="rgb(243,247,245)">
              	<div style='overflow-x:hidden; overflow-y:auto; width:365px; height:62px; border:0px solid red;'>
            	  <table width="365" border="0" cellspacing="0" cellpadding="0" align="left" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
            		<%
            		ArrivalSwitchDTO arrivalSwitchDTO = null;
            		
            		int chk = 0;
            		for ( int idx = 0; idx < iCount ; idx++ ) {
            			arrivalSwitchDTO = (ArrivalSwitchDTO)iList.get(idx);
            			
            			  if(chk == 0){
            		%>
            		<tr height="20" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="ffffff">
            			<td width="125" align="center" class="table_column"><%=arrivalSwitchDTO.getFromtime().substring(0,2)%>:<%=arrivalSwitchDTO.getFromtime().substring(2,4)%>~<%=arrivalSwitchDTO.getTotime().substring(0,2)%>:<%=arrivalSwitchDTO.getTotime().substring(2,4)%>&nbsp;</td>
            			<td width="160" align="center" class="table_column"><%=arrivalSwitchDTO.getForwardnumber()%>&nbsp;</td>
            			<td width="80" align="center" class="table_column"><a href="#" onclick="javascript:goDeletePro2('<%=e164%>','<%=arrivalSwitchDTO.getForwardnumber()%>','<%=arrivalSwitchDTO.getFromtime()%>','<%=arrivalSwitchDTO.getTotime()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image2<%=idx%>" width="34" height="18" border="0"></a></td>
            		</tr>
					<%
				            chk = 1;
				        }else{    
					%>
            		<tr height="20" bgcolor="rgb(243,247,245)" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="rgb(243,247,245)">
            			<td width="125" align="center" class="table_column"><%=arrivalSwitchDTO.getFromtime().substring(0,2)%>:<%=arrivalSwitchDTO.getFromtime().substring(2,4)%>~<%=arrivalSwitchDTO.getTotime().substring(0,2)%>:<%=arrivalSwitchDTO.getTotime().substring(2,4)%>&nbsp;</td>
            			<td width="160" align="center" class="table_column"><%=arrivalSwitchDTO.getForwardnumber()%>&nbsp;</td>
            			<td width="80" align="center" class="table_column"><a href="#" onclick="javascript:goDeletePro2('<%=e164%>','<%=arrivalSwitchDTO.getForwardnumber()%>','<%=arrivalSwitchDTO.getFromtime()%>','<%=arrivalSwitchDTO.getTotime()%>');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3<%=idx%>','','<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" name="Image3<%=idx%>" width="34" height="18" border="0"></a></td>
            		</tr>
            		<%
		            		chk = 0;
				        }
            		}
            		%>
            	  </table>
            	 </div>
              </td>
            </tr>
            
            <tr bgcolor="rgb(243,247,245)" align="center" ><td>&nbsp;</td>
            </tr>
        </table>
    </td>
    <td width="7"></td>
  </tr>
  <tr>
    <td width="7" height="10"></td>
    <td width="336" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
     
  <tr>
    <td height="5" colspan="4"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="4" style="padding-top:3 ">
		<img src="<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_exit_p_btn.gif");' style="CURSOR:hand;" onClick="hiddenAdCodeDiv3();" width="40" height="20">
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
<%
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		//할당받은 DataStatement 객체는 반납
		if (stmt != null ) ConnectionManager.freeStatement(stmt);
	}	
%>