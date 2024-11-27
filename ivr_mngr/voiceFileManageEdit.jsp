<%@page import="acromate.common.util.StringUtil"%>
<%@page import="acromate.ConnectionManager"%>
<%@page import="com.acromate.framework.util.Str"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.acromate.driver.db.DataStatement"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*"%>
<%@ page import="bizportal.nasacti.ipivr.dto.VoiceDTO"%>
<%@ page import="acromate.common.StaticString"%>
<%

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

String strWIndex = request.getParameter("wIndex");

VoiceDTO voiceDTO = new VoiceDTO();

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
	sql += "FROM NASA_WAV WHERE w_index = %s                                                                                                  ";
	sql = String.format(sql, strWIndex);

	System.out.print("sql : \n"+ sql);
	rs = stmt.executeQuery(sql);

	if(rs.next()) {
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

	//VoiceDTO voiceDTO = (VoiceDTO)request.getAttribute("voiceDTO");
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
</head>

<body>
<%-- <form name="editForm" action="<%=StaticString.ContextRoot%>/voiceFileManageEdit.do2" method="post" enctype="multipart/form-data"> --%>
<form name="editForm" method="post" enctype="multipart/form-data">
<input type="hidden" name="wIndex" value="<%=voiceDTO.getWIndex()%>">
<table width="487" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5">
	<!-- Top 여백-->
	<tr>
		<td>
		<table border="0" cellpadding="0" cellspacing="0" width="487">
			<tr>
				<td height="30" style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x">
				&nbsp;&nbsp;<span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">음성파일수정</span>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand">
				</td>
			</tr>
		</table>
		</td>
	</tr>

	<tr>
		<td>
		<table width="487" border="0" cellpadding="0" cellspacing="0">
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
								<td width="60"><span style="font-family:Gulim;font-size:11px;font-weight:bold;color:rgb(60,60,60);">음성 제목</span></td>
								<td width="400"><input type="text" name="wName" MaxLength="50"  value="<%=voiceDTO.getWName()%>" style="width:150px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);"></td>
							</tr>
						</table>
						</td>
					</tr>

					<tr>
						<td height="5"></td>
					</tr>

					<tr>
						<td height="20">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td width="60"><span style="font-family:Gulim;font-size:11px;font-weight:bold;color:rgb(60,60,60);">음성 파일</span></td>
								<td width="400">
								<table border="0" cellpadding="0" cellspacing="0">
									<tr>
										<td><input type="file" name="wFile" style="width:240px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);"></td>
									</tr>
								</table>
								</td>
							</tr>
						</table>
						</td>
					</tr>

					<tr>
						<td height="5"></td>
					</tr>

					<tr>
						<td height="20">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td width="60"></td>
								<td width="400"><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(60,60,60);">※파일명에는 영문,숫자,-,_,(,),. 만 사용할 수 있습니다.</span></td>
							</tr>
						</table>
						</td>
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
								<td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");' style="CURSOR:hand;" width="40" height="20" 
									onClick="goEdit();"></td>
								<td width="6"></td>
								<td align="left"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;" 
									onClick="hiddenAdCodeDiv();" width="40" height="20"></td>
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
</form>
</body>
</html>
