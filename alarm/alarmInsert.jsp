<%@page import="java.util.Calendar"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

if(1!=1){
	SessionManager manager = SessionManager.getInstance();
	if (manager.isLogin(request) == false) {
		response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
		return ;
	}
	
	HttpSession 		hs 		= request.getSession();
	String 				id 		= hs.getId();
	BaseEntity 			entity 	= manager.getBaseEntity(id);
	SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");
	
	String userName   = Str.CheckNullString(scDTO.getName()).trim();
	String userID     = Str.CheckNullString(scDTO.getSubsID()).trim();
	String phoneNum   = Str.CheckNullString(scDTO.getPhoneNum()).trim();
	String loginLevel = Str.CheckNullString(""+scDTO.getLoginLevel()).trim();   // 관리레벨(1:사용자, 2:관리자)
}  

	Calendar calendar = Calendar.getInstance() ;
	calendar.setTimeInMillis( calendar.getTimeInMillis()+(1000*60*60*24) ) ;
	
	int year = calendar.get(Calendar.YEAR) ;
	int month = calendar.get(Calendar.MONTH)+1 ;
	int day = calendar.get(Calendar.DAY_OF_MONTH) ;
	
// 	int hour = calendar.get(Calendar.HOUR_OF_DAY) ;
// 	int min = calendar.get(Calendar.MINUTE); ;
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="Savelayer" method="post" enctype="multipart/form-data">
<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="3" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">알람 통보 추가</strong></td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="7" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7"></td>
    <td colspan="2" height="10" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="7" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
  
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 "><div align="right" ><strong>알림 기간 </strong></div></td>
    <td width="307" height="35" align="left" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
	    <select name="alarmtype" >
        <option value="1">특정날짜</option>
        <!-- <option value="2">매일</option>
        <option value="3">월~토</option>
		<option value="4">월~금</option> -->
      </select>
	</td>
    <td width="7" bgcolor="#FFFFFF"></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 "><div align="right" ><strong> 시간 </strong></div></td>
    <td height="35" colspan="2" align="left" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 "><label>
      <select name="alarmtime_1">
        <option value="1">오전</option>
        <option value="2">오후</option>
      </select>
      <select name="alarmtime_2">
        <option value="1">01</option>
        <option value="2">02</option>
        <option value="3">03</option>
        <option value="4">04</option>
        <option value="5">05</option>
        <option value="6">06</option>
        <option value="7" selected >07</option>
        <option value="8">08</option>
        <option value="9">09</option>
        <option value="10">10</option>
        <option value="11">11</option>
        <option value="12">12</option>
      </select>
시
<select name="alarmtime_3">
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
</select>
분</label></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="7" height="35">&nbsp;</td>
    <td width="79" height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> <div align="right"><strong>날짜 </strong></div></td>
    <td height="35" colspan="2" bgcolor="#FFFFFF" style="padding-right:5 "><select name="alarmdate_1" >
        <option value="01" <%=month==1?"selected":""%> >01</option>
        <option value="02" <%=month==2?"selected":""%> >02</option>
        <option value="03" <%=month==3?"selected":""%> >03</option>
        <option value="04" <%=month==4?"selected":""%> >04</option>
        <option value="05" <%=month==5?"selected":""%> >05</option>
        <option value="06" <%=month==6?"selected":""%> >06</option>
        <option value="07" <%=month==7?"selected":""%> >07</option>
        <option value="08" <%=month==8?"selected":""%> >08</option>
        <option value="09" <%=month==9?"selected":""%> >09</option>
        <option value="10" <%=month==10?"selected":""%> >10</option>
        <option value="11" <%=month==11?"selected":""%> >11</option>
        <option value="12" <%=month==12?"selected":""%> >12</option>
      <br>
    </select>
월
<select name="alarmdate_2" >
    <option value="01" <%=day==1?"selected":""%> >01</option>
    <option value="02" <%=day==2?"selected":""%> >02</option>
    <option value="03" <%=day==3?"selected":""%> >03</option>
    <option value="04" <%=day==4?"selected":""%> >04</option>
    <option value="05" <%=day==5?"selected":""%> >05</option>
    <option value="06" <%=day==6?"selected":""%> >06</option>
    <option value="07" <%=day==7?"selected":""%> >07</option>
    <option value="08" <%=day==8?"selected":""%> >08</option>
    <option value="09" <%=day==9?"selected":""%> >09</option>
    <option value="10" <%=day==10?"selected":""%> >10</option>
    <option value="11" <%=day==11?"selected":""%> >11</option>
    <option value="12" <%=day==12?"selected":""%> >12</option>
    <option value="13" <%=day==13?"selected":""%> >13</option>
    <option value="14" <%=day==14?"selected":""%> >14</option>
    <option value="15" <%=day==15?"selected":""%> >15</option>
    <option value="16" <%=day==16?"selected":""%> >16</option>
    <option value="17" <%=day==17?"selected":""%> >17</option>
    <option value="18" <%=day==18?"selected":""%> >18</option>
    <option value="19" <%=day==19?"selected":""%> >19</option>
    <option value="20" <%=day==20?"selected":""%> >20</option>
    <option value="21" <%=day==21?"selected":""%> >21</option>
    <option value="22" <%=day==22?"selected":""%> >22</option>
    <option value="23" <%=day==23?"selected":""%> >23</option>
    <option value="24" <%=day==24?"selected":""%> >24</option>
    <option value="25" <%=day==25?"selected":""%> >25</option>
    <option value="26" <%=day==26?"selected":""%> >26</option>
    <option value="27" <%=day==27?"selected":""%> >27</option>
    <option value="28" <%=day==28?"selected":""%> >28</option>
    <option value="29" <%=day==29?"selected":""%> >29</option>
    <option value="30" <%=day==30?"selected":""%> >30</option>
    <option value="31" <%=day==31?"selected":""%> >31</option>
 
</select> 
일
</td>
    <td width="7">&nbsp;</td>
  </tr>
  <tr>
    <td height="13">&nbsp;</td>
    <td colspan="3" height="13" bgcolor="#FFFFFF">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
     
  <tr>
    <td height="10" colspan="5"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="5" style="padding-top:3 "><a href="javascript:goNewSave();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image12','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image12" width="40" height="20" border="0"></a>  <a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image74','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image74" width="40" height="20" border="0"></a></td>
  </tr>
</table>

<input type="hidden" name="alarmdate_0" value="<%=year%>" >

<table width="100%" border="0">
  <tr>
    <th scope="row">&nbsp;</th>
  </tr>
</table>
</form>
</body>
</html>
