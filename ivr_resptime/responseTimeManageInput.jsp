<%@page import="acromate.common.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.IvrTelDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.KeyActionDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="com.acromate.framework.util.Str"%>
<%
	/* List responseModeDTOList = (List)request.getAttribute("responseModeDTOList");
	List keyActionDTOList = (List)request.getAttribute("keyActionDTOList");
	List hourList = (List)request.getAttribute("hourList");
	List minuteList = (List)request.getAttribute("minuteList");
	 */

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

List responseModeDTOList = new ArrayList();//(List)request.getAttribute("responseModeDTOList");
List keyActionDTOList = new ArrayList();//(List)request.getAttribute("keyActionDTOList");
List hourList = null;//(List)request.getAttribute("hourList");
List minuteList = null;//(List)request.getAttribute("minuteList");

DecimalFormat df = new DecimalFormat("00");
hourList = new ArrayList();
for(int i=0; i < 24; i++)
	hourList.add(df.format(i));
minuteList = new ArrayList();
for(int i=0; i < 60; i++)
	minuteList.add(df.format(i));

//서버로부터 DataStatement 객체를 할당
DataStatement stmt = null;
ResultSet rs = null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try {
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	/*  */
	sql = "SELECT sc_code, sc_name, sc_sponsor, sc_nextbox, sc_hour, sc_makecall_time, sc_lang, sc_logcheck, sc_again, sc_keyto, sc_key0,     \n";
	sql += "sc_key1, sc_key2, sc_key3, sc_key4, sc_key5, sc_key6, sc_key7, sc_key8, sc_key9, sc_keyas, sc_keysh, sc_keya, sc_keyb, sc_keyc,    \n";
	sql += "sc_keyd, sc_key_etc, sc_voicefile, dg_check, sc_file_change, sc_cid_route,                                                         \n";
	sql += "COALESCE( (select nwu_idx from nasa_wave_use where nwu_filename = sc_voicefile) , 0) as nwu_idx                                     \n";
	sql += "FROM nasa_callprocessor where sc_type = 'I' and sc_use = 'Y'  ";
// 	sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
	sql += "\n ORDER BY sc_code ASC ";
	System.out.print("sql : \n"+ sql);
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
	if(rs!=null) rs.close();
	
	/*  */
	sql = "\n SELECT ka_idx, ka_code, ka_name, ka_type, COALESCE(ka_description, '') as ka_description ";
	sql += "\n FROM nasa_keyaction_code ";
	sql += "\n WHERE ka_type = 'I' ";
// 	sql += "\n AND checkgroupid = '"+ authGroupid +"' ";
	sql += "\n ORDER BY ka_name ";
	System.out.print("sql : \n"+ sql);
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
	if(rs!=null) rs.close();
	
}catch(Exception ex){
	ex.printStackTrace();
}finally{
	try{
		if(rs!=null) rs.close();
	}catch(Exception ex){}
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
}

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<%-- <form name="addForm" action="<%=StaticString.ContextRoot%>/responseTimeManageInput.do2" method="post"> --%>
<form name="addForm" method="post">
<input type="hidden" name="scLang" id="scLang" value="kor">
<input type="hidden" name="scLogCheck" id="scLogCheck" value="N">
<input type="hidden" name="responseModeSize" id="responseModeSize" value="<%=responseModeDTOList.size()%>">


<table width="400" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
<tr height="30" >
  <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="5">
  <table  border="0" cellpadding="0" cellspacing="0" style="TABLE-LAYOUT: fixed">
   <tr>
    <td width="10">&nbsp;</td>
    <td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">응답시간추가</span></td>
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
			<input type="text" value="" name="amModeName" id="amModeName" MaxLength="25" style="width:150;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
		</td>
		<td width="10">&nbsp;</td>
	</tr>

	<tr>
	    <td width="10" height="25">&nbsp;</td>
	    <td colspan="3"  align="left" bgcolor="#FFFFFF" style="padding-right:5 ">
			&nbsp;&nbsp;&nbsp;응답스케줄 설명
			<input type="text" value="" name="amMemo" id="amMemo" MaxLength="100" style="width:150;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
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

		<table width="380" border="0" cellspacing="0" cellpadding="0">
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
	  <!--select name="naScCode" style="width:110 " class="select01" onChange="javascript:changeResponseMode(this.value,this.name, 'ADD_FORM');"-->

	  <select name="naScCode" id="naScCode" style="width:110 " class="select01">
<%
	for(int i = 0; i <responseModeDTOList.size(); i++) {

%>
        <option value="<%=((ResponseModeDTO)responseModeDTOList.get(i)).getScCode()%>"><%=((ResponseModeDTO)responseModeDTOList.get(i)).getScName()%></option>
<%
	}
%>
      </select>

	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif" onClick="javascript: insertTime('ADD_FORM');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_add_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" align="absmiddle">



				</td>

			</tr>
		</table>
		</td>
		<td width="10">&nbsp;</td>
	</tr>

    <tr>
	    <td width="10"  height="10">&nbsp;</td>

		<td colspan="3" bgcolor="#FFFFFF" style="padding-left:5">
		<table width="380" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td  colspan="3" bgcolor="#FFFFFF" style="padding-left:5">&nbsp;</td>
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
			</tbody>

		</table>
		</div>
		</td>
	    <td width="10">&nbsp;</td>
  </tr>

    <tr>
	    <td width="10"  height="10">&nbsp;</td>

		<td colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	    <td width="10" height="10">&nbsp;</td>
  </tr>

  <tr>
    <td height="35">&nbsp;</td>
    <td colspan="3" align="center" style="padding-top:3 ">
	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="add();" width="40" height="20">

	  <img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" 
	  	onClick="iframeClean(); hiddenAdCodeDiv();" width="40" height="20">
	</td>
    <td>&nbsp;</td>
  </tr>

</table>
</form>
</body>
</html>
