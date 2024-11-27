<%@page import="acromate.common.util.StringUtil"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="java.text.DecimalFormat"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.IvrTelDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.KeyActionDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%

response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession ses = request.getSession(false) ;
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String userID = (String)ses.getAttribute("login.user") ;

	/* List responseModeDTOList = (List)request.getAttribute("responseModeDTOList");
	List hourList = (List)request.getAttribute("hourList");
	List minuteList = (List)request.getAttribute("minuteList");

    String strTime1 = (String)request.getAttribute("time1");
    String strTime2 = (String)request.getAttribute("time2");
    String strScCode = (String)request.getAttribute("scCode");
    String strTrIdx = (String)request.getAttribute("trIdx");
    String strType = (String)request.getAttribute("type");
     */
     
    String strTime1 = request.getParameter("time1");
	String strTime2 = request.getParameter("time2");
	String strScCode = request.getParameter("scCode");
	String strTrIdx = request.getParameter("trIdx");
	String strType = request.getParameter("type");
	
	DecimalFormat df = new DecimalFormat("00");
	List hourList = new ArrayList();
	for(int i=0; i < 24; i++)
		hourList.add(df.format(i));
	List minuteList = new ArrayList();
	for(int i=0; i < 60; i++)
		minuteList.add(df.format(i));
	
	ArrayList responseModeDTOList = new ArrayList();
	
	DataStatement 	stmt = null;
	ResultSet rs = null;
	String sql = "";
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	try{
		stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
		
		sql = "SELECT sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time, sc_lang, sc_logcheck, sc_again, sc_keyto, sc_key0 ";
		sql += "\n ,sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6, sc_key7, sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc ";
		sql += "\n, sc_keyd, sc_key_etc, sc_voicefile, dg_check, sc_file_change, sc_cid_route ";
		sql += "\n, COALESCE( (select nwu_idx from nasa_wave_use where nwu_filename = sc_voicefile) , 0) as nwu_idx ";
		sql += "\n FROM nasa_callprocessor where sc_type = 'I' and sc_use = 'Y' ";
// 		sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
		sql += "\n ORDER BY sc_code ASC ";
		System.out.println("sql : "+ sql);
		rs = stmt.executeQuery(sql);
		while(rs.next()) {
			ResponseModeDTO rmDTO = new ResponseModeDTO();
			rmDTO.setScCode(String.valueOf(rs.getInt("sc_code")));
			rmDTO.setScName(rs.getString("sc_name"));
			rmDTO.setScSponsor(rs.getString("sc_sponsor"));
			rmDTO.setScNextBox(rs.getString("sc_nextbox"));
			rmDTO.setScHour(String.valueOf(rs.getInt("sc_hour")));
			rmDTO.setScMakeCallTime(String.valueOf(rs.getInt("sc_makecall_time")));
			rmDTO.setScLang(rs.getString("sc_lang"));
			rmDTO.setScLogCheck(rs.getString("sc_logcheck"));
			rmDTO.setScAgain(String.valueOf(rs.getInt("sc_again")));
			rmDTO.setScKeyTo(rs.getString("sc_keyto"));
			rmDTO.setScKey0(rs.getString("sc_key0"));
			rmDTO.setScKey1(rs.getString("sc_key1"));
			rmDTO.setScKey2(rs.getString("sc_key2"));
			rmDTO.setScKey3(rs.getString("sc_key3"));
			rmDTO.setScKey4(rs.getString("sc_key4"));
			rmDTO.setScKey5(rs.getString("sc_key5"));
			rmDTO.setScKey6(rs.getString("sc_key6"));
			rmDTO.setScKey7(rs.getString("sc_key7"));
			rmDTO.setScKey8(rs.getString("sc_key8"));
			rmDTO.setScKey9(rs.getString("sc_key9"));
			rmDTO.setScKeyAs(rs.getString("sc_keyas"));
			rmDTO.setScKeySh(rs.getString("sc_keysh"));
			rmDTO.setScKeyA(rs.getString("sc_keya"));
			rmDTO.setScKeyB(rs.getString("sc_keyb"));
			rmDTO.setScKeyC(rs.getString("sc_keyc"));
			rmDTO.setScKeyD(rs.getString("sc_keyd"));
			rmDTO.setScKeyEtc(rs.getString("sc_key_etc"));
			rmDTO.setScVoiceFile(rs.getString("sc_voicefile"));
			rmDTO.setDgCheck(rs.getString("dg_check"));
			rmDTO.setScFileChange(rs.getString("sc_file_change"));
			rmDTO.setScCidRoute(rs.getString("sc_cid_route"));
			rmDTO.setNwuIdx(String.valueOf(rs.getInt("nwu_idx")));
			responseModeDTOList.add(rmDTO);
		}
		if(responseModeDTOList != null) responseModeDTOList.trimToSize();
	}catch(Exception ex){
		ex.printStackTrace();
	}finally{
		if(rs!=null){
			rs.close(); rs = null;
		}
		if(stmt!=null) ConnectionManager.freeStatement(stmt);
	}
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>
<body>


<table width="274" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5" style="border:1px solid rgb(149,158,162);">
	<!-- Top 여백-->
<tr height="30" >
  <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="5">
  <table  border="0" cellpadding="0" cellspacing="0" style="TABLE-LAYOUT: fixed">
   <tr>
    <td width="10">&nbsp;</td>
    <td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">응답시간수정</span></td>
       <td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv2();" style="CURSOR:hand"></td>
    <td width="10">&nbsp;</td>
   </tr>

  </table>
  </td>
 </tr>
	<tr>
		<td>
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td height="14"></td>
			</tr>
		</table>
		</td>
	</tr>

	<tr>
		<td>
		<table width="274" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="10"></td>
				<td>
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="12">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td></td>
							</tr>
						</table>
						</td>
					</tr>

					<tr>
						<td height="20">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td width="460">

								<select name="newTime1" id="newTime1" style="width:40" class="select01">
<%
    for(int i=0; i < hourList.size(); i++) {
%>
                                <option value="<%=(String)hourList.get(i)%>" <%=Integer.parseInt(strTime1) == i ? "Selected" : ""%>><%=(String)hourList.get(i)%></option>
<%
    }
%>
                                </select>시
								<select name="newTime2" id="newTime2" style="width:40" class="select01">
<%
    for(int i=0; i < minuteList.size(); i++) {
%>
                                <option value="<%=(String)minuteList.get(i)%>" <%=Integer.parseInt(strTime2) == i ? "Selected" : ""%>><%=(String)minuteList.get(i)%></option>
<%
    }
%>
								</select>
                              분 부터


	  <select name="newScCode" id="newScCode" style="width:110 " class="select01" >
<%
	for(int i = 0; i <responseModeDTOList.size(); i++) {

%>
        <option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode().equals(strScCode) ? "Selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
	}
%>




      </select>

								</td>
							</tr>
						</table>
						</td>
					</tr>

					<tr>
						<td height="5"></td>
					</tr>




					<tr>
						<td height="12">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr height="1">
								<td colspan="2" bgcolor="#b6b6b6"></td>
							</tr>
						</table>

						</td>
					</tr>

					<tr>
						<td>
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td align="right"><img 
									onClick="editTime('<%=strType%>','<%=strTrIdx%>',document.getElementById('newTime1').value,document.getElementById('newTime2').value,document.getElementById('newScCode').value,document.getElementById('newScCode').options[document.getElementById('newScCode').selectedIndex].text);" src="<%=StaticString.ContextRoot%>/imgs/Content_modify_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_modify_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_modify_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle"></td>
								<td width="6"></td>
								<td align="left"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" 
									onClick="hiddenAdCodeDiv2();" width="40" height="20"></td>
							</tr>
						</table>
						</td>
					</tr>

				</table>
				</td>
				<td width="10"></td>
			</tr>
		</table>
		</td>
	</tr>

	<tr>
		<td>
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td height="14"></td>
			</tr>
		</table>
		</td>
	</tr>

</table>

</body>
</html>
