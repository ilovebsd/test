<%@page import="acromate.common.util.StringUtil"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>

<%

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

String strType = Str.CheckNullString(request.getParameter("type"));
//List voiceDTOList = (List)request.getAttribute("voiceDTOList");
List voiceDTOList = new ArrayList();//(List)request.getAttribute("keyActionDTOList");

String strKey = "w_div", strValue = "U";

//서버로부터 DataStatement 객체를 할당
DataStatement stmt = null;
ResultSet rs = null;
String sql = "";
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try {
	stmt = ConnectionManager.allocStatement("SSW", sesSysGroupID);
	
	sql = "SELECT w_index, COALESCE(server_ip, '') as server_ip, COALESCE(w_name, '') as w_name, COALESCE(w_file, '') as w_file,          \n";
	sql += "COALESCE(w_memo, '') as w_memo, COALESCE(w_div, '') as w_div, COALESCE(w_send, '') as w_send, COALESCE(w_kind, '') as w_kind,  \n";
	sql += "COALESCE(w_sendfile, '') as w_sendfile, COALESCE(w_regdate, '') AS w_regdate, COALESCE(w_acceptdate, '') AS w_acceptdate       \n";
	sql += "FROM NASA_WAV                                                                                                                  \n";
	if(strKey != null && !strKey.equals(""))
		sql += "WHERE " + strKey + " LIKE '%" + strValue + "%' \n";
	sql += "ORDER BY w_index ";

	System.out.print("sql : \n"+ sql);
	rs = stmt.executeQuery(sql);       

	while(rs.next()) {
		VoiceDTO vDTO = new VoiceDTO();
		vDTO.setWIndex(String.valueOf(rs.getInt("w_index")));
		vDTO.setServerIp(rs.getString("server_ip"));
		vDTO.setWName(rs.getString("w_name"));
		vDTO.setWFile(rs.getString("w_file"));
		vDTO.setWMemo(rs.getString("w_memo"));
		vDTO.setWDiv(rs.getString("w_div"));
		vDTO.setWSend(rs.getString("w_send"));
		vDTO.setWKind(rs.getString("w_kind"));
		vDTO.setWSendFile(rs.getString("w_sendfile"));
		vDTO.setWRegDate(rs.getString("w_regdate"));
		vDTO.setWAcceptDate(rs.getString("w_acceptdate"));
		voiceDTOList.add(vDTO);
	}
}catch(Exception ex){
	ex.printStackTrace();
}finally{
	if(rs!=null) rs.close();
	if(stmt!=null) ConnectionManager.freeStatement(stmt);
}
			
%>
&nbsp;  <!-- 레이어에서 스타일을 적용하기 위해선 공백을 넣어줘야한다. -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<style>
<!--
#scroll03{width:310; height:100; overflow:auto; padding:0px; border:0 solid; margin:0 0 0 0}    // 스크롤관련 스타일
//-->
</style>
</head>

<body>
<table width="330" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5" style="border:1px solid rgb(149,158,162);">
	<!-- Top 여백-->
	<tr>
		<td>
		<table width="330" border="0" cellpadding="0" cellspacing="0">
			<tr style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x">
				<td height="30">&nbsp;&nbsp;<span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">음성파일선택</span></td>
				<td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv2();" style="CURSOR:hand">&nbsp;&nbsp;</td>
			</tr>
		</table>
		</td>
	</tr>

	<tr>
		<td>
		<table width="330" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="10"></td>
				<td>
				<table width="310" border="0" cellpadding="0" cellspacing="0">
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
						<td>
						<div id="scroll03">     <!-- 스크롤 적용 시작-->
						<table border="0" cellpadding="0" cellspacing="1"   bgcolor="rgb(203,203,203)" >
						   <tr height="15" bgcolor="rgb(190,188,182)" align="center" style="background:url('<%=StaticString.ContextRoot%>/imgs/table_header_img.gif') repeat-x">
						       <td width="140" class="table_header01">파일선택</td>
						       <td width="170" class="table_header01">미리듣기</td>
						   </tr>
<%
	for(int i=0; i < voiceDTOList.size(); i++) {
		if(strType.equals("ADD")) {
%>
							<tr align="center"  bgcolor="<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>" onmouseover="style.background='a8d3aa'" onmouseout="style.backgroundColor='<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>'" 
								onclick="document.addForm.wfile.value='<%=((VoiceDTO)voiceDTOList.get(i)).getWFile()%>';document.addForm.wcode.value='<%=((VoiceDTO)voiceDTOList.get(i)).getWIndex()%>';">
<%
		} else if(strType.equals("EDIT")) {
%>
							<tr align="center"  bgcolor="<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>" onmouseover="style.background='a8d3aa'" onmouseout="style.backgroundColor='<%=i%2 == 1 ? "rgb(255,255,255)" : "#F3F9F5"%>'" 
								onclick="document.editForm.wfile.value='<%=((VoiceDTO)voiceDTOList.get(i)).getWFile()%>';document.editForm.wcode.value='<%=((VoiceDTO)voiceDTOList.get(i)).getWIndex()%>';">
<%
		}
%>
								<td width="140"><%=((VoiceDTO)voiceDTOList.get(i)).getWName()%></td>
								<td width="170"><a style="color:black" href="<%
										String sesSysGroupName = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupname"), "");
										String print_html = "/MS/"+sesSysGroupName;
										out.print(print_html);
									%>/ipcs_files/fileupwav/<%=((VoiceDTO)voiceDTOList.get(i)).getWFile()%>"><%=((VoiceDTO)voiceDTOList.get(i)).getWFile()%></a></td>
							</tr>
<%
	}
%>
						</table>
						</div>              <!-- 스크롤 적용 끝-->
						</td>
					</tr>


					<tr>
						<td height="5"></td>
					</tr>

					<tr>
						<td>
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td align="center"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" 
									onClick="hiddenAdCodeDiv2();"></td>
								<!--td width="6"></td>
								<td align="left"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" onClick="hiddenAdCodeDiv2();" width="40" height="20"></td-->
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
