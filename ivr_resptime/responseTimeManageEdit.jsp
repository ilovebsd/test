<%@page import="acromate.common.util.StringUtil"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.IvrTelDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.KeyActionDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseTimeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ScheduleDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%
	/* List responseModeDTOList = (List)request.getAttribute("responseModeDTOList");
	List keyActionDTOList = (List)request.getAttribute("keyActionDTOList");
	List hourList = (List)request.getAttribute("hourList");
	List minuteList = (List)request.getAttribute("minuteList");
	ResponseTimeDTO responseTimeDTO = (ResponseTimeDTO)request.getAttribute("responseTimeDTO");
	List scheduleDTOList = (List)request.getAttribute("scheduleDTOList");
	 */
	response.setHeader("Pragma", "No-cache"); 
	response.setDateHeader("Expires", 0); 
	response.setHeader("Cache-Control", "no-Cache"); 

	HttpSession ses = request.getSession(false);
	int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
	String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
	String userID = (String)ses.getAttribute("login.user") ;

	String strAmIndex = request.getParameter("amIndex");

	String aMonthDayTmp[];
	String strMonthTmp = "";
	String strDayTmp = "";

	DataStatement 	stmt = null;
	ResultSet rs = null;
	String sql = "";

	ArrayList keyActionDTOList = new ArrayList();//(List)request.getAttribute("keyActionDTOList");
	ResponseTimeDTO responseTimeDTO = new ResponseTimeDTO();
	ArrayList responseModeDTOList = new ArrayList();//(List)request.getAttribute("responseModeDTOList");
	ArrayList scheduleDTOList = new ArrayList();//(List)request.getAttribute("scheduleDTOList");
	
	DecimalFormat df = new DecimalFormat("00");
	List hourList = new ArrayList();
	for(int i=0; i < 24; i++)
		hourList.add(df.format(i));

	List minuteList = new ArrayList();
	for(int i=0; i < 60; i++)
		minuteList.add(df.format(i));
	
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	try{
		stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);

		//
		try{
			sql = "SELECT am_index, am_mode_name, am_memo \n";
			sql += "FROM nasa_answer_mode WHERE am_index = %s \n";
// 			sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
			sql = String.format(sql, strAmIndex);
			System.out.println("sql : "+ sql);
			rs = stmt.executeQuery(sql);
			if(rs.next()) {
				responseTimeDTO.setAmIndex(String.valueOf(rs.getInt("am_index")));
				responseTimeDTO.setAmModeName(rs.getString("am_mode_name"));
				responseTimeDTO.setAmMemo(rs.getString("am_memo"));
			}
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			if(rs!=null){
				rs.close(); rs = null;
			}
		}
		
		//
		try{
			sql = "SELECT at_index, am_index, at_start_time, at_sc_code, at_sc_name, at_description \n";
			sql += "FROM nasa_answer_time WHERE am_index = %s ";
// 			sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
			sql += "\n ORDER BY at_start_time ASC ";
			sql = String.format(sql, strAmIndex);
			System.out.println("sql : "+ sql);
			rs = stmt.executeQuery(sql);
			while(rs.next()) {
				ScheduleDTO scheduleDTO = new ScheduleDTO();
				scheduleDTO.setAtIndex(String.valueOf(rs.getInt("at_index")));
				scheduleDTO.setAmIndex(String.valueOf(rs.getInt("am_index")));
				scheduleDTO.setAtStartTime(rs.getString("at_start_time"));
				scheduleDTO.setAtScode(String.valueOf(rs.getInt("at_sc_code")));
				scheduleDTO.setAtScName(rs.getString("at_sc_name"));
				scheduleDTO.setAtDescription(rs.getString("at_description"));
				scheduleDTOList.add(scheduleDTO);
			}
			if(scheduleDTOList != null) scheduleDTOList.trimToSize();
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			if(rs!=null){
				rs.close(); rs = null;
			}
		}
		
//	 	ArrayList keyActionDTOList = new ArrayList();//(List)request.getAttribute("keyActionDTOList");
		try{
			sql = "SELECT ka_idx, ka_code, ka_name, ka_type, COALESCE(ka_description, '') as ka_description  \n";
			sql += "FROM nasa_keyaction_code ";
			sql += "WHERE ka_type = 'I'  ";
// 			sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
			sql += "ORDER BY ka_name ";
			System.out.println("sql : "+sql);
			rs = stmt.executeQuery(sql);
			
			while(rs.next()) {
				KeyActionDTO keyActionDTO = new KeyActionDTO();
				keyActionDTO.setKaIdx(String.valueOf(rs.getInt("ka_idx")));
				keyActionDTO.setKaCode(rs.getString("ka_code"));
				keyActionDTO.setKaName(rs.getString("ka_name"));
				keyActionDTO.setKaType("ka_type");
				keyActionDTO.setKaDescription("ka_description");
				keyActionDTOList.add(keyActionDTO);
			}
			if(keyActionDTOList != null) keyActionDTOList.trimToSize();
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			if(rs!=null){
				rs.close(); rs = null;
			}
		}
		
		try{
			sql = "SELECT sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time, sc_lang, sc_logcheck, sc_again, sc_keyto, sc_key0, \n";
			sql += "sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6, sc_key7, sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc, \n";
			sql += "sc_keyd, sc_key_etc, sc_voicefile, dg_check, sc_file_change, sc_cid_route, \n";
			sql += "COALESCE( (select nwu_idx from nasa_wave_use where nwu_filename = sc_voicefile) , 0)as nwu_idx  \n";
			sql += "FROM nasa_callprocessor where sc_type = 'I' and sc_use = 'Y' ";
// 			sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
			sql += "\n ORDER BY sc_code ASC ";
			System.out.println("sql : "+sql);
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
		}
		
		//
		try{
			sql = "SELECT sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time, sc_lang, sc_logcheck, sc_again, sc_keyto, sc_key0,     \n";
			sql += "sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6, sc_key7, sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc,    \n";
			sql += "sc_keyd, sc_key_etc, sc_voicefile, dg_check, sc_file_change, sc_cid_route,                                                         \n";
			sql += "COALESCE( (select nwu_idx from nasa_wave_use where nwu_filename = sc_voicefile) , 0)as nwu_idx                                     \n";
			sql += "FROM nasa_callprocessor where sc_type = 'I' and sc_use = 'Y' ";
// 			sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
			sql += "\n ORDER BY sc_code ASC ";
			System.out.println("sql : "+sql);
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
		}
	}catch(Exception ex){
		
	}finally{
		if(rs!=null){
			rs.close(); rs = null;
		}
		if(stmt!=null) ConnectionManager.freeStatement(stmt) ;
	}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>

<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<%-- <form name="editForm" action="<%=StaticString.ContextRoot%>/responseTimeManageEdit.do2" method="post"> --%>
<form name="editForm" method="post">
<input type="hidden" name="scLang" id="scLang" value="kor">
<input type="hidden" name="scLogCheck" id="scLogCheck" value="N">
<input type="hidden" name="amIndex" id="amIndex" value="<%=responseTimeDTO.getAmIndex()%>">
<input type="hidden" name="responseModeSize" id="responseModeSize" value="<%=responseModeDTOList.size()%>">


<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">

<tr height="30" >
  <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="5">
  <table  border="0" cellpadding="0" cellspacing="0" style="TABLE-LAYOUT: fixed">
   <tr>
    <td width="10">&nbsp;</td>
    <td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">응답시간수정</span></td>
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
		    &nbsp;&nbsp;&nbsp;응답스케줄 이름
			<input type="text" value="<%=responseTimeDTO.getAmModeName()%>" name="amModeName" id="amModeName" MaxLength="25" style="width:150;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
		</td>
		<td width="10">&nbsp;</td>
	</tr>

	<tr>
	    <td width="10" height="25">&nbsp;</td>
	    <td colspan="3"  align="left" bgcolor="#FFFFFF" style="padding-right:5 ">
			&nbsp;&nbsp;&nbsp;응답스케줄 설명
			<input type="text" value="<%=responseTimeDTO.getAmMemo()%>" name="amMemo" id="amMemo" MaxLength="100" style="width:150;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
		</td>
		<td width="10">&nbsp;</td>
	</tr>

    <tr>
	    <td width="10" height="10">&nbsp;</td>
		<td  colspan="3" bgcolor="#FFFFFF" style="padding-left:5"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="380" align="center"></td>
	    <td width="10">&nbsp;</td>
    </tr>

    <tr>
	    <td width="10"  height="10">&nbsp;</td>

		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10">

		<table width="300" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
								<select name="time1" id="time1" style="width:40" class="select01">
<%
    for(int i=0; i < hourList.size(); i++) {
%>
                                <option value="<%=(String)hourList.get(i)%>"><%=(String)hourList.get(i)%></option>
<%
    }
%>
                                </select>시
								<select name="time2" id="time2" style="width:40" class="select01">
<%
    for(int i=0; i < minuteList.size(); i++) {
%>
                                <option value="<%=(String)minuteList.get(i)%>"><%=(String)minuteList.get(i)%></option>
<%
    }
%>
								</select>
                              분 부터

<!--20090210-->
	  <!--select name="naScCode" style="width:110 " class="select01" onChange="javascript:changeResponseMode(this.value,this.name, 'EDIT');"-->

	  <select name="naScCode" id="naScCode" style="width:110 " class="select01">
<%
	for(int i = 0; i <responseModeDTOList.size(); i++) {

%>
        <option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>"><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
	}
%>
      </select>

	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" 
	  	onClick="javascript: insertTime('EDIT_FORM');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle">

				</td>

			</tr>
		</table>
		</td>
		<td width="10">&nbsp;</td>
	</tr>

    <tr>
	    <td width="10"  height="10">&nbsp;</td>

		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:5">
		<table width="300" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td  colspan="3" bgcolor="#FFFFFF" style="padding-left:5"></td>
			</tr>
		</table>
		</td>
		<td width="10">&nbsp;</td>
	</tr>


    <tr>
	    <td width="10"  height="200">&nbsp;</td>
		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:10" valign="top">
		<div id="responseTimeDiv">
		<table id=box border="0" cellspacing="0" cellpadding="0" class="list_table">
			<tbody id="subTbody">
			<tr height="20" bgcolor="rgb(190,188,182)" align="center" >
				<td width="77" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">시간</td>
				<td width="210" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">응답모드명</td>
				<td width="77" class="table_header01" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">수정/삭제</td>
			</tr>
<%
	for(int i=0; i < scheduleDTOList.size(); i++) {
%>
			<tr height="20" bgcolor="<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>" onmouseout="style.backgroundColor='<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>'" align="center" name="subTr">
				<td id="tdIdx" name="tdIdx" class="table_column"><%=((ScheduleDTO)scheduleDTOList.get(i)).getAtStartTime().substring(0,2)%>:<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtStartTime().substring(3,5)%>부터</td>
				<td id="tdIdx2" name="tdIdx2" align="left" class="table_column"><%=((ScheduleDTO)scheduleDTOList.get(i)).getAtScName()%></td>
				<td><img id="editImg" name="editImg" src="<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif" onClick="goPopup2('<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtStartTime().substring(1,2)%>','<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtStartTime().substring(3,5)%>','<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtScode()%>','<%=i+1%>','EDIT_FORM');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_modify_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_modify_p_btn.gif");' style="CURSOR:hand;"  width="34" height="18" align="absmiddle">
				<img src="<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif" onClick="javscript: deleteTime('<%=i+1%>');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_delete_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/intable_delete_p_btn.gif");' style="CURSOR:hand;"  width="34" height="18" align="absmiddle">
				<input type="hidden" id="tdHidden1" name="tdHidden1" value="<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtStartTime().substring(0,2)%>">
				<input type="hidden" id="tdHidden2" name="tdHidden2" value="<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtStartTime().substring(3,5)%>">
				<input type="hidden" id="tdHidden3" name="tdHidden3" value="<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtScName()%>">
				<input type="hidden" id="tdHidden4" name="tdHidden4" value="<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtScode()%>">
				<input type="hidden" id="tdHidden5" name="tdHidden5" value="O">
				<input type="hidden" id="tdHidden6" name="tdHidden6" value="<%=((ScheduleDTO)scheduleDTOList.get(i)).getAtIndex()%>">
				</td>
			</tr>
<%
	}
%>
			</tbody>

		</table>
		</div>


		</td>
	    <td width="10">&nbsp;</td>
  </tr>


  <tr>
	    <td width="10"  height="10">&nbsp;</td>

		<td colspan="3" bgcolor="#FFFFFF">
		</td>
	    <td width="10" height="10">&nbsp;</td>
  </tr>



  <tr>
    <td height="35">&nbsp;</td>
    <td colspan="3" align="center" style="padding-top:3 ">
	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="goEdit();" width="40" height="20">

	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="iframeClean();hiddenAdCodeDiv();" width="40" height="20">
	</td>
    <td>&nbsp;</td>
  </tr>

</table>
</form>
</body>
</html>
