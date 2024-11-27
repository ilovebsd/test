<%@page import="acromate.common.util.StringUtil"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.IvrTelDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseTimeDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="java.text.DecimalFormat"%>
<%

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

DataStatement 	stmt = null;
ResultSet rs = null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);

    DecimalFormat df = new DecimalFormat("00");
    ArrayList ivrTelDTOList = new ArrayList();//(List)request.getAttribute("ivrTelDTOList");
	
	try{
		sql = "SELECT system_idx, tr_idx, server_ip, ivr_tel, display_tel, ssw_reg, ssw_server_ip, ssw_domain_name, ssw_local_port, ssw_remote_port, sc_company, use_yn, trunk_type, vms_prefix    \n";
		sql += "FROM NASA_TRUNK_SET                       \n";
		sql += "WHERE trunk_type = 'N' AND use_yn = 'Y'     ";
// 		sql += "AND checkgroupid = '"+ authGroupid +"' ";
		System.out.println("sql : "+sql);
		rs = stmt.executeQuery(sql);
		
		while(rs.next()) {
			IvrTelDTO ivrTelDTO = new IvrTelDTO();
			ivrTelDTO.setSystemIdx(String.valueOf(rs.getInt("system_idx")));
			ivrTelDTO.setTrIdx(String.valueOf(rs.getInt("tr_idx")));
			ivrTelDTO.setServerIp(rs.getString("server_ip"));
			ivrTelDTO.setIvrTel(rs.getString("ivr_tel"));
			ivrTelDTO.setDisplayTel(rs.getString("display_tel"));
			ivrTelDTO.setSswReg(rs.getString("ssw_reg"));
			ivrTelDTO.setSswServerIp(rs.getString("ssw_server_ip"));
			ivrTelDTO.setSswDomainName(rs.getString("ssw_domain_name"));
			ivrTelDTO.setSswLocalPort(String.valueOf(rs.getInt("ssw_local_port")));
			ivrTelDTO.setSswRemotePort(String.valueOf(rs.getInt("ssw_remote_port")));
			ivrTelDTO.setScCompany(rs.getString("sc_company"));
			ivrTelDTO.setUseYN(rs.getString("use_yn"));
			ivrTelDTO.setTrunkType(rs.getString("trunk_type"));
			ivrTelDTO.setVmsPrefix(rs.getString("vms_prefix"));
			ivrTelDTOList.add(ivrTelDTO);
		}
	}catch(Exception ex){
		ex.printStackTrace();
	}finally{
		if(rs!=null){
			rs.close(); rs = null;
		}
	}
	
	ArrayList responseTimeDTOList = new ArrayList();//(List)request.getAttribute("responseTimeDTOList");
	try{
		sql = "SELECT am_index, am_mode_name, am_memo           \n";
		sql += "FROM nasa_answer_mode ";
// 		sql += "WHERE checkgroupid = '"+authGroupid+"' ";
		sql += "ORDER BY am_index ASC  ";
		System.out.println("sql : "+sql);
		rs = stmt.executeQuery(sql);
		
		while(rs.next()) {
			ResponseTimeDTO responseTimeDTO = new ResponseTimeDTO();
			responseTimeDTO.setAmIndex(String.valueOf(rs.getInt("am_index")));
			responseTimeDTO.setAmModeName(rs.getString("am_mode_name"));
			responseTimeDTO.setAmMemo(rs.getString("am_memo"));
			responseTimeDTOList.add(responseTimeDTO);
		}
	}catch(Exception ex){
		ex.printStackTrace();
	}finally{
		if(rs!=null){
			rs.close(); rs = null;
		}
	}
	
	if(stmt!=null) ConnectionManager.freeStatement(stmt) ;
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<%-- <link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css"> --%>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<%-- <form name="addForm" action="<%=StaticString.ContextRoot%>/voiceGuideSettingInput.do2" method="post"> --%>
<form name="addForm" method="post">

<table width="519" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <!--<tr>
    <td height="35" colspan="5" style="padding-left:10" width="509"><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">음성 안내 추가asdas</span></td>
    <td align="right" width="10"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
  </tr>-->
  <tr height="30">
	  <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="6">
		  <table width="519" border="0" cellpadding="0" cellspacing="0">
		   <tr>
			<td width="8"></td>
			<td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">음성안내추가</span></td>
			<td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
			<td width="8"></td>
		   </tr>

		  </table>
	  </td>
  </tr>
  <tr>
	  <td colspan="6">
		  <table border="0" cellpadding="0" cellspacing="0">
		   <tr>
			<td height="7"></td>
		   </tr>
		  </table>
	  </td>
  </tr>
  <tr>
    <td width="8" height="10">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF" >&nbsp;</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 응답 대표 번호</td>
    <td width="376" bgcolor="#FFFFFF">
                                <select id="trIdx" name="trIdx" style="width:180 " class="select01">
<%
    for(int i=0; i < ivrTelDTOList.size(); i++) {
%>
                                  <option value="<%=((IvrTelDTO)ivrTelDTOList.get(i)).getTrIdx()%>"><%=((IvrTelDTO)ivrTelDTOList.get(i)).getIvrTel()%></option>
<%
    }
%>
                                </select>
	</td>
    <td colspan="2" bgcolor="#FFFFFF"></td>
    <td width="8">&nbsp;</td>
  </tr>


  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 응답 시간</td>
    <td colspan="3" bgcolor="#FFFFFF" id="time_setting">

	<table width="380" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td>
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td>
						<input id="adDateType" name="adDateType" type="radio" style="width:20" value="D" checked onClick="javascript: checkDateType(this.value);">일자지정
					</td>
					<td width="6"></td>
					<td>
						<select id="startMonth" name="startMonth" class="select01" style="width:40; font-size:8pt">
<%
	for(int i=1; i < 13; i++) {
%>
							<option value="<%=df.format(i)%>"><%=df.format(i)%></option>
<%
	}
%>
						</select>월
					</td>
					<td width="6"></td>
					<td>
						<select id="startDay" name="startDay" class="select01" style="width:40; font-size:8pt">
<%
	for(int i=1; i < 32; i++) {
%>
							<option value="<%=df.format(i)%>"><%=df.format(i)%></option>
<%
	}
%>
						</select>일
					</td>
					<td width="6"></td>
					<td>~</td>
					<td width="6"></td>
					<td>
						<select id="endMonth" name="endMonth" class="select01" style="width:40; font-size:8pt">
<%
	for(int i=1; i < 13; i++) {
%>
							<option value="<%=df.format(i)%>"><%=df.format(i)%></option>
<%
	}
%>
						</select>월
					</td>
					<td width="6"></td>
					<td>
						<select id="endDay" name="endDay" class="select01" style="width:40; font-size:8pt">
<%
	for(int i=1; i < 32; i++) {
%>
							<option value="<%=df.format(i)%>"><%=df.format(i)%></option>
<%
	}
%>
						</select>일
					</td>
				</tr>
			</table>
			</td>
		</tr>
		<tr>
			<td>
			<table width="380" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="90"><input id="adDateType" name="adDateType" type="radio" value="W" style="width:20" onClick="javascript: checkDateType(this.value);">요일지정</td>
					<td width="6"></td>
					<td width="30"><input id="adWeekMon" name="adWeekMon" disabled type="checkbox" value="Y" style="width:20">월</td>
					<td width="6"></td>
					<td width="30"><input id="adWeekTue" name="adWeekTue" disabled type="checkbox" value="Y" style="width:20">화</td>
					<td width="6"></td>
					<td width="30"><input id="adWeekWed" name="adWeekWed" disabled type="checkbox" value="Y" style="width:20">수</td>
					<td width="6"></td>
					<td width="30"><input id="adWeekThu" name="adWeekThu" disabled type="checkbox" value="Y" style="width:20">목</td>
					<td width="6"></td>
					<td width="30"><input id="adWeekFri" name="adWeekFri" disabled type="checkbox" value="Y" style="width:20">금</td>
					<td width="6"></td>
					<td width="30"><input id="adWeekSat" name="adWeekSat" disabled type="checkbox" value="Y" style="width:20">토</td>
					<td width="6"></td>
					<td width="30"><input id="adWeekSun" name="adWeekSun" disabled type="checkbox" value="Y" style="width:20">일</td>
					<td width="38"></td>
				</tr>
			</table>
			</td>
		</tr>
	</table>

	</td>
    <td width="8"></td>
  </tr>

  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="109" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 응답스케줄</td>
    <td colspan="3" bgcolor="#FFFFFF">
	  <select id="amIndex" name="amIndex" style="width:180 " class="select01">
<%
	for(int i = 0; i <responseTimeDTOList.size(); i++) {

%>
        <option value="<%=((ResponseTimeDTO)responseTimeDTOList.get(i)).getAmIndex()%>"><%=((ResponseTimeDTO)responseTimeDTOList.get(i)).getAmModeName()%></option>
<%
	}
%>
      </select>
	</td>
    <td width="8">&nbsp;</td>
  </tr>


  <tr>
    <td height="35">&nbsp;</td>
    <td colspan="4" align="center" style="padding-top:3 ">
	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="add();" width="40" height="20">

	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="hiddenAdCodeDiv();" width="40" height="20">
	</td>
    <td>&nbsp;</td>
  </tr>



</table>



</form>
</body>
</html>
