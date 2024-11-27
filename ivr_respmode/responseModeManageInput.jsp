
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.ResponseModeDTO"%>
<%@ page import="bizportal.nasacti.ipivr.dto.KeyActionDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="acromate.common.util.StringUtil"%>

<%

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

List keyActionDTOList = new ArrayList();//(List)request.getAttribute("keyActionDTOList");

//서버로부터 DataStatement 객체를 할당
DataStatement stmt = null;
ResultSet rs = null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try {
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	sql = "\n SELECT ka_idx, ka_code, ka_name, ka_type, COALESCE(ka_description, '') as ka_description ";
	sql += "\n FROM nasa_keyaction_code ";
	sql += "\n WHERE ka_type = 'I' ";
// 	sql += "AND checkgroupid = '"+ authGroupid +"' ";
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
}catch(Exception ex){
	ex.printStackTrace();
}finally{
	if(rs!=null) rs.close();
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
}

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<%-- <link href="<%=StaticString.ContextRoot%>/css/td_style.css" rel="stylesheet" type="text/css"> --%>
<script	language='javaScript' src='<%=StaticString.ContextRoot%>/js/select_design.js'></script>
</head>

<body>
<%-- <form name="addForm" action="<%=StaticString.ContextRoot%>/responseModeManageInput.do2" method="post"> --%>
<form name="addForm" method="post">
<input type="hidden" name="scLang" value="kor">
<input type="hidden" name="scLogCheck" value="N">


<table width="760" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <!--<tr>
    <td height="35" colspan="6" style="padding-left:10 "> <strong>응답 모드 추가</strong></td>
  </tr>-->
  <!--
<tr height="30" >
  <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="5">
  <table  border="1" cellpadding="0" cellspacing="0" style="TABLE-LAYOUT: fixed">
   <tr>
    <td width="6">&nbsp;</td>
    <td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">응답모드추가</span></td>
       <td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td width="8">&nbsp;</td>
   </tr>

  </table>
  </td>
 </tr>-->
  <tr >
    <td width="8" height="30" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x">&nbsp;</td>
    <td colspan="3" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x"><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">응답모드추가</span></td>
	<td align="right" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td width="8" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x">&nbsp;</td>
  </tr>
  <tr>
    <td height="8">&nbsp;</td>
    <td colspan="4">&nbsp;</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td colspan="4" bgcolor="#FFFFFF" style="padding-left:10;color:993333 "><strong>응답 모드 상세 내용</strong>&#13; </td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 응답 모드 이름 </td>
    <td bgcolor="#FFFFFF"><input type="text" name="scName" MaxLength="25" style="width:135;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);"></td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="323" rowspan="16" align="center" valign="top" bgcolor="#FFFFFF" style="border-left:#aa99b2 1 dotted soild; "><table width="296" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="22" height="30" align="left"><span class="table_header02">
          <input name="dgCheck" type="checkbox" value="Y" style="width:15" checked>
        </span></td>
        <td width="274">멘트 도중 번호 인식</td>
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
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
												</select>
	        </td>
            <td id="option1" width="148" align="center" bgcolor="eaeaea"><input type="hidden" name="word1" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">2</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key2" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option2" align="center" bgcolor="eaeaea"><input type="hidden" name="word2" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">3</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key3" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option3" align="center" bgcolor="eaeaea"><input type="hidden" name="word3" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">4</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key4" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option4" align="center" bgcolor="eaeaea"><input type="hidden" name="word4" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">5</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key5" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option5" align="center" bgcolor="eaeaea"><input type="hidden" name="word5" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">6</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key6" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option6" align="center" bgcolor="eaeaea"><input type="hidden" name="word6" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">7</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key7" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option7" align="center" bgcolor="eaeaea"><input type="hidden" name="word7" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">8</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key8" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option8" align="center" bgcolor="eaeaea"><input type="hidden" name="word8" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">9</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key9" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option9" align="center" bgcolor="eaeaea"><input type="hidden" name="word9" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">0</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="key0" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="option0" align="center" bgcolor="eaeaea"><input type="hidden" name="word0" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">*</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="keyas" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="optionas" align="center" bgcolor="eaeaea"><input type="hidden" name="wordas" value = ""></td>
          </tr>
          <tr>
            <td height="30" align="center" bgcolor="#FFFFCC">#</td>
            <td align="center" bgcolor="eaeaea">
			  <select name="keysh" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:100; font-size:8pt">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
            <td id="optionsh" align="center" bgcolor="eaeaea"><input type="hidden" name="wordsh" value = ""></td>
          </tr>
        </table></td>
      </tr>
    </table>	</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 음성 파일 </td>
    <td width="140" bgcolor="#FFFFFF"><input type="text" name="wfile" readonly style="width:135;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);"><input type="hidden" name="wcode" value="0"> </td>
    <td width="168" bgcolor="#FFFFFF"><img src="<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif" onClick ="goPopup('ADD');" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif");' style="CURSOR:hand;" width="40" height="20"></td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 시간 초과</td>
    <td width="140" bgcolor="#FFFFFF"><input type="text" name="scHour" MaxLength="2" value="5" style="width:20;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
      초 이상 응답 없을 때 </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 자동 종료 </td>
    <td width="140" bgcolor="#FFFFFF"><input name="scAgain" type="text" MaxLength="2" value="3" style="width:20;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);">
      회 이상 입력 오류 시 </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td colspan="3" bgcolor="#FFFFFF" style="padding-left:5"><hr style="border-top:#aa99b2 1 dotted soild;" color="#FFFFFF" width="270" align="center"></td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td colspan="2" bgcolor="#FFFFFF" style="padding-left:10 "><li> <strong>조건부 호전환 옵션</strong></td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 호 전환 시간 </td>
    <td bgcolor="#FFFFFF"><input name="scMakeCallTime" type="text" MaxLength="2" value="30" style="width:20;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);" size="5">
    초후  </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> CID 표시</td>
    <td colspan="2" bgcolor="#FFFFFF">
	<select name="scCidRoute" style="width:180 " class="select01">
		<option value="Y">ARS만 표시</option>
		<option value="N">수신번호 + ARS 함께 표시</option>
    </select>
	</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="15">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp; </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 시간 초과 </td>
    <td colspan="2" rowspan="5" valign="top" bgcolor="ffffff">
		<table width="94%" border="#eaeaea 1 soild" bordercolorlight="#c1c1c1" bordercolordark="ffffff" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	      <tr align="center" bgcolor="eaeaea">
	        <td width="44%" height="25">

			  <select name="keyto" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
			  </select>
			</td>
			<td width="56%" id="optionto">&nbsp;<input type="hidden" name="wordto" value = ""></td>
		  </tr>
		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keya" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				  <option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>
			</td>
			<td width="56%" id="optiona">&nbsp;<input type="hidden" name="worda" value = ""></td>
		  </tr>
		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keyb" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
				  <option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>
			</td>
			<td  id="optionb">&nbsp;<input type="hidden" name="wordb" value = ""></td>
          </tr>
		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keyc" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
					<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>

			</td>
			<td id="optionc">&nbsp;<input type="hidden" name="wordc" value = ""></td>
		  </tr>




		  <tr align="center" bgcolor="eaeaea">
			<td height="25">
				<select name="keyd" class="select01" onChange="javascript:changeOption(this.value,this.name);" style="width:85%">
<%
	for(int i=0; i < keyActionDTOList.size(); i++) {
%>
					<option value="<%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode()%>" <%=((KeyActionDTO)keyActionDTOList.get(i)).getKaCode().equals("10") ? "selected" : ""%>><%=((KeyActionDTO)keyActionDTOList.get(i)).getKaName()%></option>
<%
	}
%>
				</select>

			</td>
			<td id="optiond">&nbsp;<input type="hidden" name="wordd" value = ""></td>
		  </tr>








		</table>

	</td>
    <td width="8">&nbsp;</td>
  </tr>
    <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 통화 중 </td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 부재 중 </td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 잘못된 번호 </td>
    <td width="8" >&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" bgcolor="#FFFFFF" style="padding-right:5 "> 기타오류 </td>
    <td width="8" rowspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="25">&nbsp;</td>
    <td width="104" align="right" valign="top" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td colspan="2" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td width="8" height="50">&nbsp;</td>
    <td width="104" align="right" valign="top" bgcolor="#FFFFFF" style="padding-right:5 ">&nbsp;</td>
    <td colspan="2" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
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
