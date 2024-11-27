<%@page import="acromate.common.util.StringUtil"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="acromate.ConnectionManager"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.UsedVoiceDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.KeyActionDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%
	/*  UsedVoiceDTO usedVoiceDTO = (UsedVoiceDTO)request.getAttribute("usedVoiceDTO");
	VoiceDTO voiceDTO = (VoiceDTO)request.getAttribute("voiceDTO");
	ResponseModeDTO responseModeDTO = (ResponseModeDTO)request.getAttribute("responseModeDTO");
	List responseModeDTOList = (List)request.getAttribute("responseModeDTOList");
	List keyActionDTOList = (List)request.getAttribute("keyActionDTOList");
	 */
	 
	response.setHeader("Pragma", "No-cache"); 
	response.setDateHeader("Expires", 0); 
	response.setHeader("Cache-Control", "no-Cache"); 

	HttpSession ses = request.getSession(false);
	int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
	String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
	String userID = (String)ses.getAttribute("login.user") ;

	//String strAdIndex = Str.CheckNullString(request.getParameter("adIndex"));
	String strScCode = Str.CheckNullString(request.getParameter("scCode"));

	String aMonthDayTmp[];
	String strMonthTmp = "";
	String strDayTmp = "";

	DataStatement 	stmt = null;
	ResultSet rs = null;
	String sql = "";

	ArrayList keyActionDTOList = new ArrayList();//(List)request.getAttribute("keyActionDTOList");
	ResponseModeDTO responseModeDTO = new ResponseModeDTO();
	UsedVoiceDTO usedVoiceDTO = null;//(UsedVoiceDTO)request.getAttribute("usedVoiceDTO");
	VoiceDTO voiceDTO = null;//(VoiceDTO)request.getAttribute("voiceDTO");
	ArrayList responseModeDTOList = new ArrayList();//(List)request.getAttribute("responseModeDTOList");
	String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
	try{
		stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	    

//	 	ArrayList keyActionDTOList = new ArrayList();//(List)request.getAttribute("keyActionDTOList");
		try{
			sql = "SELECT ka_idx, ka_code, ka_name, ka_type, COALESCE(ka_description, '') as ka_description  \n";
			sql += "FROM nasa_keyaction_code ";
			sql += "WHERE ka_type = 'I'  ";
// 			sql += "AND checkgroupid = '"+ authGroupid +"' ";
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
			sql = "SELECT sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time, sc_lang, sc_logcheck, \n";
			sql += "sc_again, sc_keyto, sc_key0, sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6, sc_key7, \n";
			sql += "sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc, sc_keyd, sc_key_etc, sc_voicefile, \n";
			sql += "dg_check, sc_file_change, sc_cid_route \n";
			sql += "FROM nasa_callprocessor WHERE sc_code = %s  ";
// 			sql += "AND checkgroupid = '"+ authGroupid +"' ";
			sql = String.format(sql, strScCode);
			System.out.println("sql : "+sql);
			rs = stmt.executeQuery(sql);
			
			while(rs.next()) {
				responseModeDTO.setScCode(String.valueOf(rs.getInt("sc_code")));
				responseModeDTO.setScName(rs.getString("sc_name"));
				responseModeDTO.setScSponsor(rs.getString("sc_sponsor"));
				responseModeDTO.setScNextBox(rs.getString("sc_nextbox"));
				responseModeDTO.setScHour(String.valueOf(rs.getInt("sc_hour")));
				responseModeDTO.setScMakeCallTime(String.valueOf(rs.getInt("sc_makecall_time")));
				responseModeDTO.setScLang(rs.getString("sc_lang"));
				responseModeDTO.setScLogCheck(rs.getString("sc_logcheck"));
				responseModeDTO.setScAgain(String.valueOf(rs.getInt("sc_again")));
				responseModeDTO.setScKeyTo(rs.getString("sc_keyto"));
				responseModeDTO.setScKey0(rs.getString("sc_key0"));
				responseModeDTO.setScKey1(rs.getString("sc_key1"));
				responseModeDTO.setScKey2(rs.getString("sc_key2"));
				responseModeDTO.setScKey3(rs.getString("sc_key3"));
				responseModeDTO.setScKey4(rs.getString("sc_key4"));
				responseModeDTO.setScKey5(rs.getString("sc_key5"));
				responseModeDTO.setScKey6(rs.getString("sc_key6"));
				responseModeDTO.setScKey7(rs.getString("sc_key7"));
				responseModeDTO.setScKey8(rs.getString("sc_key8"));
				responseModeDTO.setScKey9(rs.getString("sc_key9"));
				responseModeDTO.setScKeyAs(rs.getString("sc_keyas"));
				responseModeDTO.setScKeySh(rs.getString("sc_keysh"));
				responseModeDTO.setScKeyA(rs.getString("sc_keya"));
				responseModeDTO.setScKeyB(rs.getString("sc_keyb"));
				responseModeDTO.setScKeyC(rs.getString("sc_keyc"));
				responseModeDTO.setScKeyD(rs.getString("sc_keyd"));
				responseModeDTO.setScKeyEtc(rs.getString("sc_key_etc"));
				responseModeDTO.setScVoiceFile(rs.getString("sc_voicefile"));
				responseModeDTO.setDgCheck(rs.getString("dg_check"));
				responseModeDTO.setScFileChange(rs.getString("sc_file_change"));
				responseModeDTO.setScCidRoute(rs.getString("sc_cid_route"));
			}
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			if(rs!=null){
				rs.close(); rs = null;
			}
		}
		
//	 	UsedVoiceDTO usedVoiceDTO = new UsedVoiceDTO();//(UsedVoiceDTO)request.getAttribute("usedVoiceDTO");
		try{
			sql = "select nwu_idx, w_index, nwu_type, nwu_filename, nwu_definition, ns_idx \n";
			sql += "from nasa_wave_use \n";
			sql += "where nwu_filename = %s \n";
			sql = String.format(sql, "'"+responseModeDTO.getScVoiceFile()+"'");
			System.out.println("sql : "+ sql);
			rs = stmt.executeQuery(sql);
			if(rs.next()) {
				usedVoiceDTO = new UsedVoiceDTO();
				usedVoiceDTO.setNwuIdx(String.valueOf(rs.getInt("nwu_idx")));
				usedVoiceDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
				usedVoiceDTO.setNwuType(rs.getString("nwu_type"));
				usedVoiceDTO.setNwuFileName(rs.getString("nwu_filename"));
				usedVoiceDTO.setNwuDefinition(rs.getString("nwu_definition"));
				usedVoiceDTO.setNsIdx(String.valueOf(rs.getInt("ns_idx")));
			}
		}catch(Exception ex){
			ex.printStackTrace();
		}finally{
			if(rs!=null){
				rs.close(); rs = null;
			}
		}
		
		if(usedVoiceDTO!=null){
			voiceDTO = new VoiceDTO();
			
			try{
				sql = "SELECT w_index, COALESCE(server_ip, '') as server_ip, COALESCE(w_name, '') as w_name, COALESCE(w_file, '') as w_file,  \n";
				sql += "COALESCE(w_memo, '') as w_memo, COALESCE(w_div, '') as w_div, COALESCE(w_send, '') as w_send, COALESCE(w_kind, '') as w_kind, \n";
				sql += "COALESCE(w_sendfile, '') as w_sendfile, COALESCE(w_regdate, '') AS w_regdate, COALESCE(w_acceptdate, '') AS w_acceptdate \n";
				sql += "FROM NASA_WAV WHERE w_index = %s \n";
				sql = String.format(sql, usedVoiceDTO.getWIndex());
				System.out.println("sql : "+ sql);
				rs = stmt.executeQuery(sql);
				if(rs.next()) {
					//voiceDTO = new VoiceDTO();
					voiceDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
					voiceDTO.setServerIp(rs.getString("server_ip"));
					voiceDTO.setWName(rs.getString("w_name"));
					voiceDTO.setWFile(rs.getString("w_file"));
					voiceDTO.setWMemo(rs.getString("w_memo"));
					voiceDTO.setWDiv(rs.getString("w_div"));
					voiceDTO.setWSend(rs.getString("w_send"));
					voiceDTO.setWKind(rs.getString("w_kind"));
					voiceDTO.setWSendFile(rs.getString("w_sendfile"));
					voiceDTO.setWRegDate(rs.getString("w_regdate"));
					voiceDTO.setWAcceptDate(rs.getString("w_acceptdate"));
				}
			}catch(Exception ex){
				ex.printStackTrace();
			}finally{
				if(rs!=null){
					rs.close(); rs = null;
				}
			}
		}
		
//	 	ArrayList responseModeDTOList = new ArrayList();//(List)request.getAttribute("responseModeDTOList");
		try{
			
			sql = "SELECT sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time, sc_lang, sc_logcheck, sc_again, sc_keyto, sc_key0,     \n";
			sql += "sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6, sc_key7, sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc,    \n";
			sql += "sc_keyd, sc_key_etc, sc_voicefile, dg_check, sc_file_change, sc_cid_route,                                                         \n";
			sql += "COALESCE( (select nwu_idx from nasa_wave_use where nwu_filename = sc_voicefile) , 0)as nwu_idx                                     \n";
			sql += "FROM nasa_callprocessor where sc_type = 'I' and sc_use = 'Y'  						                                                ";
// 			sql += "AND checkgroupid = '"+ authGroupid +"' ";
			sql += "ORDER BY sc_code ASC   ";
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
<link href="<%=StaticString.ContextRoot%>/css/selectBox.css" rel="stylesheet">
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<%-- <form name="editForm" action="<%=StaticString.ContextRoot%>/responseModeManageEdit.do2" method="post"> --%>
<form name="editForm" method="post">
<input type="hidden" name="scCode" value="<%=responseModeDTO.getScCode()%>">
<input type="hidden" name="scVoiceFile" value="<%=responseModeDTO.getScVoiceFile()%>">
<input type="hidden" name="waveUseInsert" value="<%=usedVoiceDTO!=null ? "N" : "Y"%>">
<input type="hidden" name="scLang" value="kor">
<input type="hidden" name="scLogCheck" value="N">


<table width="760" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <!--<tr>
    <td height="35" colspan="6" style="padding-left:10 "> <strong>응답 모드 수정</strong></td>
  </tr>-->

  <tr>
    <td width="8" height="30" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x">&nbsp;</td>
    <td colspan="3" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x"><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">응답모드수정</span></td>
	<td align="right" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td width="8" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="10">&nbsp;</td>
    <td colspan="4">&nbsp;</td>
    <td width="17">&nbsp;</td>
  </tr>


  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF" style="padding-left:10;color:993333 "><strong>응답 모드 상세 내용</strong>&#13; </td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 응답 모드 이름 </td>
    <td bgcolor="#FFFFFF"><input type="text" name="scName" MaxLength="25" style="width:135;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);" value="<%=responseModeDTO.getScName()%>"></td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="323" rowspan="17" align="center" valign="top" bgcolor="#FFFFFF" style="border-left:#aa99b2 1 dotted soild; "><table width="296" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="22" height="30" align="left"><span class="table_header02"><input name="dgCheck" type="checkbox" value="Y" <%=responseModeDTO.getDgCheck().equals("Y") ? "Checked" : ""%> style="width:15 "></span></td>
        <td width="274" align="left">멘트 도중 번호 인식</td>
      </tr>
      <tr>
        <td colspan="2" align="center" bgcolor="#CCCCCC"><table width="299" border="0" cellspacing="1" cellpadding="0" bordercolor="#e0e0e0">
          <tr>
            <td width="27" height="25" align="center" bgcolor="#FFFFCC">1</td>
            <td width="120" align="center" bgcolor="eaeaea">
			  <select name="key1" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
			    <option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey1().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
	        </td>
            <td id="option1" width="148" align="center" bgcolor="eaeaea">

<%
    if(responseModeDTO.getScKey1().substring(0,2).equals("01") || responseModeDTO.getScKey1().substring(0,2).equals("02")
       || responseModeDTO.getScKey1().substring(0,2).equals("06") || responseModeDTO.getScKey1().substring(0,2).equals("07")
	   || responseModeDTO.getScKey1().substring(0,2).equals("08") || responseModeDTO.getScKey1().substring(0,2).equals("41")
	   || responseModeDTO.getScKey1().substring(0,2).equals("44")) {
%>
												<input name="word1" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey1().substring(2,responseModeDTO.getScKey1().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey1().substring(0,2).equals("04") || responseModeDTO.getScKey1().substring(0,2).equals("09")) {
%>
												<select name="word1" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey1().substring(2,responseModeDTO.getScKey1().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey1().substring(0,2).equals("05")) {
%>
												<select name="word1" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey1().substring(2,responseModeDTO.getScKey1().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey1().substring(2,responseModeDTO.getScKey1().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey1().substring(0,2).equals("10") || responseModeDTO.getScKey1().substring(0,2).equals("03")
              || responseModeDTO.getScKey1().substring(0,2).equals("31") || responseModeDTO.getScKey1().substring(0,2).equals("32")
			  || responseModeDTO.getScKey1().substring(0,2).equals("33") || responseModeDTO.getScKey1().substring(0,2).equals("34")
			  || responseModeDTO.getScKey1().substring(0,2).equals("35") || responseModeDTO.getScKey1().substring(0,2).equals("36")
              || responseModeDTO.getScKey1().substring(0,2).equals("37") || responseModeDTO.getScKey1().substring(0,2).equals("38")
              || responseModeDTO.getScKey1().substring(0,2).equals("39") || responseModeDTO.getScKey1().substring(0,2).equals("40")
			  || responseModeDTO.getScKey1().substring(0,2).equals("42") || responseModeDTO.getScKey1().substring(0,2).equals("43")
			  || responseModeDTO.getScKey1().substring(0,2).equals("45") || responseModeDTO.getScKey1().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word1" value = "">
<%
    }
%>

			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">2</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key2" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey2().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option2" align="center" bgcolor="eaeaea">

<%
    if(responseModeDTO.getScKey2().substring(0,2).equals("01") || responseModeDTO.getScKey2().substring(0,2).equals("02")
       || responseModeDTO.getScKey2().substring(0,2).equals("06") || responseModeDTO.getScKey2().substring(0,2).equals("07")
	   || responseModeDTO.getScKey2().substring(0,2).equals("08") || responseModeDTO.getScKey2().substring(0,2).equals("41")
	   || responseModeDTO.getScKey2().substring(0,2).equals("44")) {
%>
												<input name="word2" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey2().substring(2,responseModeDTO.getScKey2().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey2().substring(0,2).equals("04") || responseModeDTO.getScKey2().substring(0,2).equals("09")) {
%>
												<select name="word2" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey2().substring(2,responseModeDTO.getScKey2().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey2().substring(0,2).equals("05")) {
%>
												<select name="word2" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey2().substring(2,responseModeDTO.getScKey2().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey2().substring(2,responseModeDTO.getScKey2().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey2().substring(0,2).equals("10") || responseModeDTO.getScKey2().substring(0,2).equals("03")
              || responseModeDTO.getScKey2().substring(0,2).equals("31") || responseModeDTO.getScKey2().substring(0,2).equals("32")
			  || responseModeDTO.getScKey2().substring(0,2).equals("33") || responseModeDTO.getScKey2().substring(0,2).equals("34")
			  || responseModeDTO.getScKey2().substring(0,2).equals("35") || responseModeDTO.getScKey2().substring(0,2).equals("36")
              || responseModeDTO.getScKey2().substring(0,2).equals("37") || responseModeDTO.getScKey2().substring(0,2).equals("38")
              || responseModeDTO.getScKey2().substring(0,2).equals("39") || responseModeDTO.getScKey2().substring(0,2).equals("40")
			  || responseModeDTO.getScKey2().substring(0,2).equals("42") || responseModeDTO.getScKey2().substring(0,2).equals("43")
			  || responseModeDTO.getScKey2().substring(0,2).equals("45") || responseModeDTO.getScKey2().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word2" value = "">
<%
    }
%>

			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">3</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key3" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey3().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>			  </select>
			</td>
            <td id="option3" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey3().substring(0,2).equals("01") || responseModeDTO.getScKey3().substring(0,2).equals("02")
       || responseModeDTO.getScKey3().substring(0,2).equals("06") || responseModeDTO.getScKey3().substring(0,2).equals("07")
	   || responseModeDTO.getScKey3().substring(0,2).equals("08") || responseModeDTO.getScKey3().substring(0,2).equals("41")
	   || responseModeDTO.getScKey3().substring(0,2).equals("44")) {
%>
												<input name="word3" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey3().substring(2,responseModeDTO.getScKey3().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey3().substring(0,2).equals("04") || responseModeDTO.getScKey3().substring(0,2).equals("09")) {
%>
												<select name="word3" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey3().substring(2,responseModeDTO.getScKey3().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey3().substring(0,2).equals("05")) {
%>
												<select name="word3" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey3().substring(2,responseModeDTO.getScKey3().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey3().substring(2,responseModeDTO.getScKey3().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey3().substring(0,2).equals("10") || responseModeDTO.getScKey3().substring(0,2).equals("03")
              || responseModeDTO.getScKey3().substring(0,2).equals("31") || responseModeDTO.getScKey3().substring(0,2).equals("32")
			  || responseModeDTO.getScKey3().substring(0,2).equals("33") || responseModeDTO.getScKey3().substring(0,2).equals("34")
			  || responseModeDTO.getScKey3().substring(0,2).equals("35") || responseModeDTO.getScKey3().substring(0,2).equals("36")
              || responseModeDTO.getScKey3().substring(0,2).equals("37") || responseModeDTO.getScKey3().substring(0,2).equals("38")
              || responseModeDTO.getScKey3().substring(0,2).equals("39") || responseModeDTO.getScKey3().substring(0,2).equals("40")
			  || responseModeDTO.getScKey3().substring(0,2).equals("42") || responseModeDTO.getScKey3().substring(0,2).equals("43")
			  || responseModeDTO.getScKey3().substring(0,2).equals("45") || responseModeDTO.getScKey3().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word3" value = "">
<%
    }
%>
			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">4</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key4" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey4().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option4" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey4().substring(0,2).equals("01") || responseModeDTO.getScKey4().substring(0,2).equals("02")
       || responseModeDTO.getScKey4().substring(0,2).equals("06") || responseModeDTO.getScKey4().substring(0,2).equals("07")
	   || responseModeDTO.getScKey4().substring(0,2).equals("08") || responseModeDTO.getScKey4().substring(0,2).equals("41")
	   || responseModeDTO.getScKey4().substring(0,2).equals("44")) {
%>
												<input name="word4" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey4().substring(2,responseModeDTO.getScKey4().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey4().substring(0,2).equals("04") || responseModeDTO.getScKey4().substring(0,2).equals("09")) {
%>
												<select name="word4" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey4().substring(2,responseModeDTO.getScKey4().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey4().substring(0,2).equals("05")) {
%>
												<select name="word4" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey4().substring(2,responseModeDTO.getScKey4().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey4().substring(2,responseModeDTO.getScKey4().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey4().substring(0,2).equals("10") || responseModeDTO.getScKey4().substring(0,2).equals("03")
              || responseModeDTO.getScKey4().substring(0,2).equals("31") || responseModeDTO.getScKey4().substring(0,2).equals("32")
			  || responseModeDTO.getScKey4().substring(0,2).equals("33") || responseModeDTO.getScKey4().substring(0,2).equals("34")
			  || responseModeDTO.getScKey4().substring(0,2).equals("35") || responseModeDTO.getScKey4().substring(0,2).equals("36")
              || responseModeDTO.getScKey4().substring(0,2).equals("37") || responseModeDTO.getScKey4().substring(0,2).equals("38")
              || responseModeDTO.getScKey4().substring(0,2).equals("39") || responseModeDTO.getScKey4().substring(0,2).equals("40")
			  || responseModeDTO.getScKey4().substring(0,2).equals("42") || responseModeDTO.getScKey4().substring(0,2).equals("43")
			  || responseModeDTO.getScKey4().substring(0,2).equals("45") || responseModeDTO.getScKey4().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word4" value = "">
<%
    }
%>
			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">5</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key5" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey5().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option5" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey5().substring(0,2).equals("01") || responseModeDTO.getScKey5().substring(0,2).equals("02")
       || responseModeDTO.getScKey5().substring(0,2).equals("06") || responseModeDTO.getScKey5().substring(0,2).equals("07")
	   || responseModeDTO.getScKey5().substring(0,2).equals("08") || responseModeDTO.getScKey5().substring(0,2).equals("41")
	   || responseModeDTO.getScKey5().substring(0,2).equals("44")) {
%>
												<input name="word5" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey5().substring(2,responseModeDTO.getScKey5().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey5().substring(0,2).equals("04") || responseModeDTO.getScKey5().substring(0,2).equals("09")) {
%>
												<select name="word5" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey5().substring(2,responseModeDTO.getScKey5().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey5().substring(0,2).equals("05")) {
%>
												<select name="word5" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey5().substring(2,responseModeDTO.getScKey5().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey5().substring(2,responseModeDTO.getScKey5().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey5().substring(0,2).equals("10") || responseModeDTO.getScKey5().substring(0,2).equals("03")
              || responseModeDTO.getScKey5().substring(0,2).equals("31") || responseModeDTO.getScKey5().substring(0,2).equals("32")
			  || responseModeDTO.getScKey5().substring(0,2).equals("33") || responseModeDTO.getScKey5().substring(0,2).equals("34")
			  || responseModeDTO.getScKey5().substring(0,2).equals("35") || responseModeDTO.getScKey5().substring(0,2).equals("36")
              || responseModeDTO.getScKey5().substring(0,2).equals("37") || responseModeDTO.getScKey5().substring(0,2).equals("38")
              || responseModeDTO.getScKey5().substring(0,2).equals("39") || responseModeDTO.getScKey5().substring(0,2).equals("40")
			  || responseModeDTO.getScKey5().substring(0,2).equals("42") || responseModeDTO.getScKey5().substring(0,2).equals("43")
			  || responseModeDTO.getScKey5().substring(0,2).equals("45") || responseModeDTO.getScKey5().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word5" value = "">
<%
    }
%>

			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">6</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key6" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey6().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option6" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey6().substring(0,2).equals("01") || responseModeDTO.getScKey6().substring(0,2).equals("02")
       || responseModeDTO.getScKey6().substring(0,2).equals("06") || responseModeDTO.getScKey6().substring(0,2).equals("07")
	   || responseModeDTO.getScKey6().substring(0,2).equals("08") || responseModeDTO.getScKey6().substring(0,2).equals("41")
	   || responseModeDTO.getScKey6().substring(0,2).equals("44")) {
%>
												<input name="word6" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey6().substring(2,responseModeDTO.getScKey6().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey6().substring(0,2).equals("04") || responseModeDTO.getScKey6().substring(0,2).equals("09")) {
%>
												<select name="word6" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey6().substring(2,responseModeDTO.getScKey6().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey6().substring(0,2).equals("05")) {
%>
												<select name="word6" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey6().substring(2,responseModeDTO.getScKey6().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey6().substring(2,responseModeDTO.getScKey6().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey6().substring(0,2).equals("10") || responseModeDTO.getScKey6().substring(0,2).equals("03")
              || responseModeDTO.getScKey6().substring(0,2).equals("31") || responseModeDTO.getScKey6().substring(0,2).equals("32")
			  || responseModeDTO.getScKey6().substring(0,2).equals("33") || responseModeDTO.getScKey6().substring(0,2).equals("34")
			  || responseModeDTO.getScKey6().substring(0,2).equals("35") || responseModeDTO.getScKey6().substring(0,2).equals("36")
              || responseModeDTO.getScKey6().substring(0,2).equals("37") || responseModeDTO.getScKey6().substring(0,2).equals("38")
              || responseModeDTO.getScKey6().substring(0,2).equals("39") || responseModeDTO.getScKey6().substring(0,2).equals("40")
			  || responseModeDTO.getScKey6().substring(0,2).equals("42") || responseModeDTO.getScKey6().substring(0,2).equals("43")
			  || responseModeDTO.getScKey6().substring(0,2).equals("45") || responseModeDTO.getScKey6().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word6" value = "">
<%
    }
%>
			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">7</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key7" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey7().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option7" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey7().substring(0,2).equals("01") || responseModeDTO.getScKey7().substring(0,2).equals("02")
       || responseModeDTO.getScKey7().substring(0,2).equals("06") || responseModeDTO.getScKey7().substring(0,2).equals("07")
	   || responseModeDTO.getScKey7().substring(0,2).equals("08") || responseModeDTO.getScKey7().substring(0,2).equals("41")
	   || responseModeDTO.getScKey7().substring(0,2).equals("44")) {
%>
												<input name="word7" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey7().substring(2,responseModeDTO.getScKey7().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey7().substring(0,2).equals("04") || responseModeDTO.getScKey7().substring(0,2).equals("09")) {
%>
												<select name="word7" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey7().substring(2,responseModeDTO.getScKey7().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey7().substring(0,2).equals("05")) {
%>
												<select name="word7" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey7().substring(2,responseModeDTO.getScKey7().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey7().substring(2,responseModeDTO.getScKey7().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey7().substring(0,2).equals("10") || responseModeDTO.getScKey7().substring(0,2).equals("03")
              || responseModeDTO.getScKey7().substring(0,2).equals("31") || responseModeDTO.getScKey7().substring(0,2).equals("32")
			  || responseModeDTO.getScKey7().substring(0,2).equals("33") || responseModeDTO.getScKey7().substring(0,2).equals("34")
			  || responseModeDTO.getScKey7().substring(0,2).equals("35") || responseModeDTO.getScKey7().substring(0,2).equals("36")
              || responseModeDTO.getScKey7().substring(0,2).equals("37") || responseModeDTO.getScKey7().substring(0,2).equals("38")
              || responseModeDTO.getScKey7().substring(0,2).equals("39") || responseModeDTO.getScKey7().substring(0,2).equals("40")
			  || responseModeDTO.getScKey7().substring(0,2).equals("42") || responseModeDTO.getScKey7().substring(0,2).equals("43")
			  || responseModeDTO.getScKey7().substring(0,2).equals("45") || responseModeDTO.getScKey7().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word7" value = "">
<%
    }
%>
			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">8</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key8" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey8().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option8" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey8().substring(0,2).equals("01") || responseModeDTO.getScKey8().substring(0,2).equals("02")
       || responseModeDTO.getScKey8().substring(0,2).equals("06") || responseModeDTO.getScKey8().substring(0,2).equals("07")
	   || responseModeDTO.getScKey8().substring(0,2).equals("08") || responseModeDTO.getScKey8().substring(0,2).equals("41")
	   || responseModeDTO.getScKey8().substring(0,2).equals("44")) {
%>
												<input name="word8" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey8().substring(2,responseModeDTO.getScKey8().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey8().substring(0,2).equals("04") || responseModeDTO.getScKey8().substring(0,2).equals("09")) {
%>
												<select name="word8" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey8().substring(2,responseModeDTO.getScKey8().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey8().substring(0,2).equals("05")) {
%>
												<select name="word8" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey8().substring(2,responseModeDTO.getScKey8().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey8().substring(2,responseModeDTO.getScKey8().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey8().substring(0,2).equals("10") || responseModeDTO.getScKey8().substring(0,2).equals("03")
              || responseModeDTO.getScKey8().substring(0,2).equals("31") || responseModeDTO.getScKey8().substring(0,2).equals("32")
			  || responseModeDTO.getScKey8().substring(0,2).equals("33") || responseModeDTO.getScKey8().substring(0,2).equals("34")
			  || responseModeDTO.getScKey8().substring(0,2).equals("35") || responseModeDTO.getScKey8().substring(0,2).equals("36")
              || responseModeDTO.getScKey8().substring(0,2).equals("37") || responseModeDTO.getScKey8().substring(0,2).equals("38")
              || responseModeDTO.getScKey8().substring(0,2).equals("39") || responseModeDTO.getScKey8().substring(0,2).equals("40")
			  || responseModeDTO.getScKey8().substring(0,2).equals("42") || responseModeDTO.getScKey8().substring(0,2).equals("43")
			  || responseModeDTO.getScKey8().substring(0,2).equals("45") || responseModeDTO.getScKey8().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word8" value = "">
<%
    }
%>
			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">9</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key9" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey9().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option9" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey9().substring(0,2).equals("01") || responseModeDTO.getScKey9().substring(0,2).equals("02")
       || responseModeDTO.getScKey9().substring(0,2).equals("06") || responseModeDTO.getScKey9().substring(0,2).equals("07")
	   || responseModeDTO.getScKey9().substring(0,2).equals("08") || responseModeDTO.getScKey9().substring(0,2).equals("41")
	   || responseModeDTO.getScKey9().substring(0,2).equals("44")) {
%>
												<input name="word9" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey9().substring(2,responseModeDTO.getScKey9().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey9().substring(0,2).equals("04") || responseModeDTO.getScKey9().substring(0,2).equals("09")) {
%>
												<select name="word9" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey9().substring(2,responseModeDTO.getScKey9().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey9().substring(0,2).equals("05")) {
%>
												<select name="word9" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey9().substring(2,responseModeDTO.getScKey9().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey9().substring(2,responseModeDTO.getScKey9().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey9().substring(0,2).equals("10") || responseModeDTO.getScKey9().substring(0,2).equals("03")
              || responseModeDTO.getScKey9().substring(0,2).equals("31") || responseModeDTO.getScKey9().substring(0,2).equals("32")
			  || responseModeDTO.getScKey9().substring(0,2).equals("33") || responseModeDTO.getScKey9().substring(0,2).equals("34")
			  || responseModeDTO.getScKey9().substring(0,2).equals("35") || responseModeDTO.getScKey9().substring(0,2).equals("36")
              || responseModeDTO.getScKey9().substring(0,2).equals("37") || responseModeDTO.getScKey9().substring(0,2).equals("38")
              || responseModeDTO.getScKey9().substring(0,2).equals("39") || responseModeDTO.getScKey9().substring(0,2).equals("40")
			  || responseModeDTO.getScKey9().substring(0,2).equals("42") || responseModeDTO.getScKey9().substring(0,2).equals("43")
			  || responseModeDTO.getScKey9().substring(0,2).equals("45") || responseModeDTO.getScKey9().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word9" value = "">
<%
    }
%>
			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">0</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key0" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKey0().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option0" align="center" bgcolor="eaeaea">
<%
    if(responseModeDTO.getScKey0().substring(0,2).equals("01") || responseModeDTO.getScKey0().substring(0,2).equals("02")
       || responseModeDTO.getScKey0().substring(0,2).equals("06") || responseModeDTO.getScKey0().substring(0,2).equals("07")
	   || responseModeDTO.getScKey0().substring(0,2).equals("08") || responseModeDTO.getScKey0().substring(0,2).equals("41")
	   || responseModeDTO.getScKey0().substring(0,2).equals("44")) {
%>
												<input name="word0" type="text" MaxLength="14" value="<%=responseModeDTO.getScKey0().substring(2,responseModeDTO.getScKey0().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKey0().substring(0,2).equals("04") || responseModeDTO.getScKey0().substring(0,2).equals("09")) {
%>
												<select name="word0" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKey0().substring(2,responseModeDTO.getScKey0().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKey0().substring(0,2).equals("05")) {
%>
												<select name="word0" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKey0().substring(2,responseModeDTO.getScKey0().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKey0().substring(2,responseModeDTO.getScKey0().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKey0().substring(0,2).equals("10") || responseModeDTO.getScKey0().substring(0,2).equals("03")
              || responseModeDTO.getScKey0().substring(0,2).equals("31") || responseModeDTO.getScKey0().substring(0,2).equals("32")
			  || responseModeDTO.getScKey0().substring(0,2).equals("33") || responseModeDTO.getScKey0().substring(0,2).equals("34")
			  || responseModeDTO.getScKey0().substring(0,2).equals("35") || responseModeDTO.getScKey0().substring(0,2).equals("36")
              || responseModeDTO.getScKey0().substring(0,2).equals("37") || responseModeDTO.getScKey0().substring(0,2).equals("38")
              || responseModeDTO.getScKey0().substring(0,2).equals("39") || responseModeDTO.getScKey0().substring(0,2).equals("40")
			  || responseModeDTO.getScKey0().substring(0,2).equals("42") || responseModeDTO.getScKey0().substring(0,2).equals("43")
			  || responseModeDTO.getScKey0().substring(0,2).equals("45") || responseModeDTO.getScKey0().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="word0" value = "">
<%
    }
%>
			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">*</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="keyas" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKeyAs().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="optionas" align="center" bgcolor="eaeaea">

<%
    if(responseModeDTO.getScKeyAs().substring(0,2).equals("01") || responseModeDTO.getScKeyAs().substring(0,2).equals("02")
       || responseModeDTO.getScKeyAs().substring(0,2).equals("06") || responseModeDTO.getScKeyAs().substring(0,2).equals("07")
	   || responseModeDTO.getScKeyAs().substring(0,2).equals("08") || responseModeDTO.getScKeyAs().substring(0,2).equals("41")
	   || responseModeDTO.getScKeyAs().substring(0,2).equals("44")) {
%>
												<input name="wordas" type="text" MaxLength="14" value="<%=responseModeDTO.getScKeyAs().substring(2,responseModeDTO.getScKeyAs().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKeyAs().substring(0,2).equals("04") || responseModeDTO.getScKeyAs().substring(0,2).equals("09")) {
%>
												<select name="wordas" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKeyAs().substring(2,responseModeDTO.getScKeyAs().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKeyAs().substring(0,2).equals("05")) {
%>
												<select name="wordas" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKeyAs().substring(2,responseModeDTO.getScKeyAs().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKeyAs().substring(2,responseModeDTO.getScKeyAs().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKeyAs().substring(0,2).equals("10") || responseModeDTO.getScKeyAs().substring(0,2).equals("03")
              || responseModeDTO.getScKeyAs().substring(0,2).equals("31") || responseModeDTO.getScKeyAs().substring(0,2).equals("32")
			  || responseModeDTO.getScKeyAs().substring(0,2).equals("33") || responseModeDTO.getScKeyAs().substring(0,2).equals("34")
			  || responseModeDTO.getScKeyAs().substring(0,2).equals("35") || responseModeDTO.getScKeyAs().substring(0,2).equals("36")
              || responseModeDTO.getScKeyAs().substring(0,2).equals("37") || responseModeDTO.getScKeyAs().substring(0,2).equals("38")
              || responseModeDTO.getScKeyAs().substring(0,2).equals("39") || responseModeDTO.getScKeyAs().substring(0,2).equals("40")
			  || responseModeDTO.getScKeyAs().substring(0,2).equals("42") || responseModeDTO.getScKeyAs().substring(0,2).equals("43")
			  || responseModeDTO.getScKeyAs().substring(0,2).equals("45") || responseModeDTO.getScKeyAs().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="wordas" value = "">
<%
    }
%>

			</td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">#</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="keysh" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKeySh().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="optionsh" align="center" bgcolor="eaeaea">

<%
    if(responseModeDTO.getScKeySh().substring(0,2).equals("01") || responseModeDTO.getScKeySh().substring(0,2).equals("02")
       || responseModeDTO.getScKeySh().substring(0,2).equals("06") || responseModeDTO.getScKeySh().substring(0,2).equals("07")
	   || responseModeDTO.getScKeySh().substring(0,2).equals("08") || responseModeDTO.getScKeySh().substring(0,2).equals("41")
	   || responseModeDTO.getScKeySh().substring(0,2).equals("44")) {
%>
												<input name="wordsh" type="text" MaxLength="14" value="<%=responseModeDTO.getScKeySh().substring(2,responseModeDTO.getScKeySh().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKeySh().substring(0,2).equals("04") || responseModeDTO.getScKeySh().substring(0,2).equals("09")) {
%>
												<select name="wordsh" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKeySh().substring(2,responseModeDTO.getScKeySh().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKeySh().substring(0,2).equals("05")) {
%>
												<select name="wordsh" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKeySh().substring(2,responseModeDTO.getScKeySh().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKeySh().substring(2,responseModeDTO.getScKeySh().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKeySh().substring(0,2).equals("10") || responseModeDTO.getScKeySh().substring(0,2).equals("03")
              || responseModeDTO.getScKeySh().substring(0,2).equals("31") || responseModeDTO.getScKeySh().substring(0,2).equals("32")
			  || responseModeDTO.getScKeySh().substring(0,2).equals("33") || responseModeDTO.getScKeySh().substring(0,2).equals("34")
			  || responseModeDTO.getScKeySh().substring(0,2).equals("35") || responseModeDTO.getScKeySh().substring(0,2).equals("36")
              || responseModeDTO.getScKeySh().substring(0,2).equals("37") || responseModeDTO.getScKeySh().substring(0,2).equals("38")
              || responseModeDTO.getScKeySh().substring(0,2).equals("39") || responseModeDTO.getScKeySh().substring(0,2).equals("40")
			  || responseModeDTO.getScKeySh().substring(0,2).equals("42") || responseModeDTO.getScKeySh().substring(0,2).equals("43")
			  || responseModeDTO.getScKeySh().substring(0,2).equals("45") || responseModeDTO.getScKeySh().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="wordsh" value = "">
<%
    }
%>

			</td>
          </tr>
        </table></td>
      </tr>
    </table>	</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 음성 파일 </td>
    <td width="140" bgcolor="#FFFFFF"><input type="text" name="wfile" readonly style="width:135;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);"><input type="hidden" name="wcode" value="<%=usedVoiceDTO!=null ? usedVoiceDTO.getWIndex() : ""%>"><input type="hidden" name="beforewcode" value="<%=usedVoiceDTO!=null ? usedVoiceDTO.getWIndex() : ""%>">
	</td>
    <td width="168" bgcolor="#FFFFFF"><img src="<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif" onClick ="goPopup('EDIT');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif");' style="CURSOR:hand;" width="40" height="20"></td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 적용된 음성 </td>
    <td width="140" bgcolor="#FFFFFF"><%
    		String sesSysGroupName = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupname"), "");
    		String print_html = usedVoiceDTO!=null ? "<a style=\"color:black\" href=\""+ "/MS/"+sesSysGroupName +"/ipcs_files/fileup/" + usedVoiceDTO.getNwuFileName() + "\">" + voiceDTO.getWName() + "</a>" : "없음";
    		out.print(print_html);
    		%>
	</td>
    <td width="168" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 시간 초과</td>
    <td width="140" bgcolor="#FFFFFF"><input type="text" name="scHour" MaxLength="2" value="<%=responseModeDTO.getScHour()%>" style="width:20;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
      초 이상 응답 없을 때 </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 자동 종료 </td>
    <td width="140" bgcolor="#FFFFFF"><input name="scAgain" type="text" MaxLength="2" value="<%=responseModeDTO.getScAgain()%>" style="width:20;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
      회 이상 입력 오류 시 </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td colspan="3" bgcolor="#FFFFFF" style="padding-left:5"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="270" align="center"></td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td colspan="2" bgcolor="#FFFFFF" style="padding-left:10 "><li> <strong>조건부 호전환 옵션</strong></td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 호 전환 시간 </td>
    <td bgcolor="#FFFFFF"><input name="scMakeCallTime" type="text" MaxLength="2" value="<%=responseModeDTO.getScMakeCallTime()%>" style="width:20;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);" size="5">
    초후  </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> CID 표시</td>
    <td colspan="2" bgcolor="#FFFFFF">
	<select name="scCidRoute" style="width:180 " class="select01">
	  <option value="Y" <%=responseModeDTO.getScCidRoute().equals("Y") ? "Selected" : ""%>>ARS만 표시</option>
	  <option value="N" <%=responseModeDTO.getScCidRoute().equals("N") ? "Selected" : ""%>>수신번호 + ARS 함께 표시
    </select>
	</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="15">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp; </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="17">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 시간 초과</td>
    <td colspan="2" rowspan="5" valign="top" bgcolor="ffffff">
		<table width="94%"  border="#eaeaea 1 soild" bordercolorlight="#c1c1c1" bordercolordark="ffffff" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	      <tr align="center" bgcolor="eaeaea">
	        <td width="44%" height="25">

			  <select name="keyto" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
			    <option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKeyTo().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>



			</td>
			<td width="56%" id="optionto">
<%
    if(responseModeDTO.getScKeyTo().substring(0,2).equals("01") || responseModeDTO.getScKeyTo().substring(0,2).equals("02")
       || responseModeDTO.getScKeyTo().substring(0,2).equals("06") || responseModeDTO.getScKeyTo().substring(0,2).equals("07")
	   || responseModeDTO.getScKeyTo().substring(0,2).equals("08") || responseModeDTO.getScKeyTo().substring(0,2).equals("41")
	   || responseModeDTO.getScKeyTo().substring(0,2).equals("44")) {
%>
												<input name="wordto" type="text" MaxLength="14" value="<%=responseModeDTO.getScKeyTo().substring(2,responseModeDTO.getScKeyTo().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKeyTo().substring(0,2).equals("04") || responseModeDTO.getScKeyTo().substring(0,2).equals("09")) {
%>
												<select name="wordto" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKeyTo().substring(2,responseModeDTO.getScKeyTo().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKeyTo().substring(0,2).equals("05")) {
%>
												<select name="wordto" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKeyTo().substring(2,responseModeDTO.getScKeyTo().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKeyTo().substring(2,responseModeDTO.getScKeyTo().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKeyTo().substring(0,2).equals("10") || responseModeDTO.getScKeyTo().substring(0,2).equals("03")
              || responseModeDTO.getScKeyTo().substring(0,2).equals("31") || responseModeDTO.getScKeyTo().substring(0,2).equals("32")
			  || responseModeDTO.getScKeyTo().substring(0,2).equals("33") || responseModeDTO.getScKeyTo().substring(0,2).equals("34")
			  || responseModeDTO.getScKeyTo().substring(0,2).equals("35") || responseModeDTO.getScKeyTo().substring(0,2).equals("36")
              || responseModeDTO.getScKeyTo().substring(0,2).equals("37") || responseModeDTO.getScKeyTo().substring(0,2).equals("38")
              || responseModeDTO.getScKeyTo().substring(0,2).equals("39") || responseModeDTO.getScKeyTo().substring(0,2).equals("40")
			  || responseModeDTO.getScKeyTo().substring(0,2).equals("42") || responseModeDTO.getScKeyTo().substring(0,2).equals("43")
			  || responseModeDTO.getScKeyTo().substring(0,2).equals("45") || responseModeDTO.getScKeyTo().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="wordto" value = "">
<%
    }
%>
			</td>
		  </tr>
		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keya" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
													<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKeyA().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>

			</td>
			<td width="56%" id="optiona">

<%
    if(responseModeDTO.getScKeyA().substring(0,2).equals("01") || responseModeDTO.getScKeyA().substring(0,2).equals("02")
       || responseModeDTO.getScKeyA().substring(0,2).equals("06") || responseModeDTO.getScKeyA().substring(0,2).equals("07")
	   || responseModeDTO.getScKeyA().substring(0,2).equals("08") || responseModeDTO.getScKeyA().substring(0,2).equals("41")
	   || responseModeDTO.getScKeyA().substring(0,2).equals("44")) {
%>
												<input name="worda" type="text" MaxLength="14" value="<%=responseModeDTO.getScKeyA().substring(2,responseModeDTO.getScKeyA().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKeyA().substring(0,2).equals("04") || responseModeDTO.getScKeyA().substring(0,2).equals("09")) {
%>
												<select name="worda" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKeyA().substring(2,responseModeDTO.getScKeyA().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKeyA().substring(0,2).equals("05")) {
%>
												<select name="worda" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKeyA().substring(2,responseModeDTO.getScKeyA().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKeyA().substring(2,responseModeDTO.getScKeyA().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKeyA().substring(0,2).equals("10") || responseModeDTO.getScKeyA().substring(0,2).equals("03")
              || responseModeDTO.getScKeyA().substring(0,2).equals("31") || responseModeDTO.getScKeyA().substring(0,2).equals("32")
			  || responseModeDTO.getScKeyA().substring(0,2).equals("33") || responseModeDTO.getScKeyA().substring(0,2).equals("34")
			  || responseModeDTO.getScKeyA().substring(0,2).equals("35") || responseModeDTO.getScKeyA().substring(0,2).equals("36")
              || responseModeDTO.getScKeyA().substring(0,2).equals("37") || responseModeDTO.getScKeyA().substring(0,2).equals("38")
              || responseModeDTO.getScKeyA().substring(0,2).equals("39") || responseModeDTO.getScKeyA().substring(0,2).equals("40")
			  || responseModeDTO.getScKeyA().substring(0,2).equals("42") || responseModeDTO.getScKeyA().substring(0,2).equals("43")
			  || responseModeDTO.getScKeyA().substring(0,2).equals("45") || responseModeDTO.getScKeyA().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="worda" value = "">
<%
    }
%>
			</td>
		  </tr>
		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keyb" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				  <option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKeyB().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>
			</td>
			<td id="optionb">
<%
    if(responseModeDTO.getScKeyB().substring(0,2).equals("01") || responseModeDTO.getScKeyB().substring(0,2).equals("02")
       || responseModeDTO.getScKeyB().substring(0,2).equals("06") || responseModeDTO.getScKeyB().substring(0,2).equals("07")
	   || responseModeDTO.getScKeyB().substring(0,2).equals("08") || responseModeDTO.getScKeyB().substring(0,2).equals("41")
	   || responseModeDTO.getScKeyB().substring(0,2).equals("44")) {
%>
												<input name="wordb" type="text" MaxLength="14" value="<%=responseModeDTO.getScKeyB().substring(2,responseModeDTO.getScKeyB().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKeyB().substring(0,2).equals("04") || responseModeDTO.getScKeyB().substring(0,2).equals("09")) {
%>
												<select name="wordb" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKeyB().substring(2,responseModeDTO.getScKeyB().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKeyB().substring(0,2).equals("05")) {
%>
												<select name="wordb" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKeyB().substring(2,responseModeDTO.getScKeyB().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKeyB().substring(2,responseModeDTO.getScKeyB().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKeyB().substring(0,2).equals("10") || responseModeDTO.getScKeyB().substring(0,2).equals("03")
              || responseModeDTO.getScKeyB().substring(0,2).equals("31") || responseModeDTO.getScKeyB().substring(0,2).equals("32")
			  || responseModeDTO.getScKeyB().substring(0,2).equals("33") || responseModeDTO.getScKeyB().substring(0,2).equals("34")
			  || responseModeDTO.getScKeyB().substring(0,2).equals("35") || responseModeDTO.getScKeyB().substring(0,2).equals("36")
              || responseModeDTO.getScKeyB().substring(0,2).equals("37") || responseModeDTO.getScKeyB().substring(0,2).equals("38")
              || responseModeDTO.getScKeyB().substring(0,2).equals("39") || responseModeDTO.getScKeyB().substring(0,2).equals("40")
			  || responseModeDTO.getScKeyB().substring(0,2).equals("42") || responseModeDTO.getScKeyB().substring(0,2).equals("43")
			  || responseModeDTO.getScKeyB().substring(0,2).equals("45") || responseModeDTO.getScKeyB().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="wordb" value = "">
<%
    }
%>

			</td>
          </tr>
		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keyc" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				  <option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKeyC().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>

			</td>
			<td id="optionc">
<%
    if(responseModeDTO.getScKeyC().substring(0,2).equals("01") || responseModeDTO.getScKeyC().substring(0,2).equals("02")
       || responseModeDTO.getScKeyC().substring(0,2).equals("06") || responseModeDTO.getScKeyC().substring(0,2).equals("07")
	   || responseModeDTO.getScKeyC().substring(0,2).equals("08") || responseModeDTO.getScKeyC().substring(0,2).equals("41")
	   || responseModeDTO.getScKeyC().substring(0,2).equals("44")) {
%>
												<input name="wordc" type="text" MaxLength="14" value="<%=responseModeDTO.getScKeyC().substring(2,responseModeDTO.getScKeyC().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKeyC().substring(0,2).equals("04") || responseModeDTO.getScKeyC().substring(0,2).equals("09")) {
%>
												<select name="wordc" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKeyC().substring(2,responseModeDTO.getScKeyC().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKeyC().substring(0,2).equals("05")) {
%>
												<select name="wordc" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKeyC().substring(2,responseModeDTO.getScKeyC().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKeyC().substring(2,responseModeDTO.getScKeyC().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKeyC().substring(0,2).equals("10") || responseModeDTO.getScKeyC().substring(0,2).equals("03")
              || responseModeDTO.getScKeyC().substring(0,2).equals("31") || responseModeDTO.getScKeyC().substring(0,2).equals("32")
			  || responseModeDTO.getScKeyC().substring(0,2).equals("33") || responseModeDTO.getScKeyC().substring(0,2).equals("34")
			  || responseModeDTO.getScKeyC().substring(0,2).equals("35") || responseModeDTO.getScKeyC().substring(0,2).equals("36")
              || responseModeDTO.getScKeyC().substring(0,2).equals("37") || responseModeDTO.getScKeyC().substring(0,2).equals("38")
              || responseModeDTO.getScKeyC().substring(0,2).equals("39") || responseModeDTO.getScKeyC().substring(0,2).equals("40")
			  || responseModeDTO.getScKeyC().substring(0,2).equals("42") || responseModeDTO.getScKeyC().substring(0,2).equals("43")
			  || responseModeDTO.getScKeyC().substring(0,2).equals("45") || responseModeDTO.getScKeyC().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="wordc" value = "">
<%
    }
%>

			</td>
		  </tr>




		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keyd" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				  <option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals(responseModeDTO.getScKeyD().substring(0,2)) ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>

			</td>
			<td id="optiond">

<%
    if(responseModeDTO.getScKeyD().substring(0,2).equals("01") || responseModeDTO.getScKeyD().substring(0,2).equals("02")
       || responseModeDTO.getScKeyD().substring(0,2).equals("06") || responseModeDTO.getScKeyD().substring(0,2).equals("07")
	   || responseModeDTO.getScKeyD().substring(0,2).equals("08") || responseModeDTO.getScKeyD().substring(0,2).equals("41")
	   || responseModeDTO.getScKeyD().substring(0,2).equals("44")) {
%>
												<input name="wordd" type="text" MaxLength="14" value="<%=responseModeDTO.getScKeyD().substring(2,responseModeDTO.getScKeyD().length())%>" style="width:140;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
<%
    } else if(responseModeDTO.getScKeyD().substring(0,2).equals("04") || responseModeDTO.getScKeyD().substring(0,2).equals("09")) {
%>
												<select name="wordd" class="input_box" style='width:130px'>
												    <option value="" selected></option>
<%
        for(int i=0; i < responseModeDTOList.size(); i++) {
%>
													<option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>" <%=responseModeDTO.getScKeyD().substring(2,responseModeDTO.getScKeyD().length()).equals(((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()) ? "selected" : ""%>><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
        }
%>
												</select>
<%
    } else if(responseModeDTO.getScKeyD().substring(0,2).equals("05")) {
%>
												<select name="wordd" class="input_box" style='width:130px'>
												    <option value="" <%=responseModeDTO.getScKeyD().substring(2,responseModeDTO.getScKeyD().length()).equals("") ? "selected" : ""%>></option>
													<option value="Q" <%=responseModeDTO.getScKeyD().substring(2,responseModeDTO.getScKeyD().length()).equals("Q") ? "selected" : ""%>>Quit</option>
												</select>
<%
    } else if(responseModeDTO.getScKeyD().substring(0,2).equals("10") || responseModeDTO.getScKeyD().substring(0,2).equals("03")
              || responseModeDTO.getScKeyD().substring(0,2).equals("31") || responseModeDTO.getScKeyD().substring(0,2).equals("32")
			  || responseModeDTO.getScKeyD().substring(0,2).equals("33") || responseModeDTO.getScKeyD().substring(0,2).equals("34")
			  || responseModeDTO.getScKeyD().substring(0,2).equals("35") || responseModeDTO.getScKeyD().substring(0,2).equals("36")
              || responseModeDTO.getScKeyD().substring(0,2).equals("37") || responseModeDTO.getScKeyD().substring(0,2).equals("38")
              || responseModeDTO.getScKeyD().substring(0,2).equals("39") || responseModeDTO.getScKeyD().substring(0,2).equals("40")
			  || responseModeDTO.getScKeyD().substring(0,2).equals("42") || responseModeDTO.getScKeyD().substring(0,2).equals("43")
			  || responseModeDTO.getScKeyD().substring(0,2).equals("45") || responseModeDTO.getScKeyD().substring(0,2).equals("46")) {
%>
												<input type="hidden" name="wordd" value = "">
<%
    }
%>

			</td>
		  </tr>
		</table>

	</td>
    <td width="17">&nbsp;</td>
  </tr>
    <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 통화 중</td>
    <td width="17"></td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 부재 중</td>
    <td width="17"></td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 잘못된 번호</td>
    <td width="17" ></td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 기타오류</td>
    <td width="17" rowspan="3"></td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" valign="top" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td colspan="2" valign="top" bgcolor="#FFFFFF"></td>
  </tr>
  <tr>
    <td width="8" height="50">&nbsp;</td>
    <td width="104" align="right" valign="top" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td colspan="2" valign="top" bgcolor="#FFFFFF"></td>
  </tr>
  <!--tr>
    <td width="8" height="10">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF" >&nbsp;1</td>
    <td width="12">&nbsp;</td>
  </tr-->
  <tr>
    <td height="35">&nbsp;</td>
    <td colspan="4" align="center" style="padding-top:3 ">
	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="goEdit();" width="40" height="20">

	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="hiddenAdCodeDiv();" width="40" height="20">
	</td>
    <td>&nbsp;</td>
  </tr>






</table>

















</form>
</body>
</html>
