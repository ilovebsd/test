<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.util.*,bizportal.nasacti.record.*"%>
<%@ page import="acromate.common.StaticString"%>
<%

String pageDir = "";//"/ems";

String parm = "";
String popTitle = "";
String msg1 = "";
String msg2 = "";


parm = request.getParameter("parm");

//System.out.println(parm);

if( parm == null){
	popTitle = "알림";
	msg1 = "다시 입력해 주세요.";
	msg2 = " ";
}

//channel_admin.jsp//
else if( parm.equals("alterCphone") ){
	
	popTitle = "통화 채널 수정";
	msg1 = "내선번호를";
	msg2 = "입력하세요.";

}
else if( parm.equals("alterCname") ){

	popTitle = "통화 채널 수정";
	msg1 = "이름을";
	msg2 = "입력하세요.";

}

else if (parm.equals("alertEdit") ){

	popTitle = "통화 채널 수정";
	msg1 = "수정하였습니다.";
	msg2 = "";

}


//channel_admin.jsp//

//record_search.jsp//
else if( parm.equals("alertCheck") ){

	popTitle = "녹음 파일 삭제";
	msg1 = "삭제할 데이터를";
	msg2 = "선택하세요.";
}
else if( parm.equals("alertFile") ){

	popTitle = "녹음 파일 삭제";
	msg1 = "파일이 ";
	msg2 = "존재하지 않습니다.";
}

else if( parm.equals("alertChangeFile") ){

	popTitle = "통화 녹음 듣기";
	msg1 = "백업파일이 ";
	msg2 = "변환중에 있습니다.";
}

else if( parm.equals("ftpChange") ){

	popTitle = "통화 녹음 듣기 ";
	msg1 = "내부망/외부망 선택을 ";
	msg2 = "바르게 선택하세요.";
}

else if( parm.equals("ftpfalse") ){

	popTitle = "통화 녹음 듣기 ";
	msg1 = "FTP 접속실패입니다.";
	msg2 = "";
}


//record_search.jsp//

//backup_setting_ok.jsp//
else if( parm.equals("alertIpaddr") ){

	popTitle = "녹음 파일 백업 설정";
	msg1 = "아이피 주소를";
	msg2 = "입력하세요.";

}

else if( parm.equals("alertBackuppath") ){

	popTitle = "녹음 파일 백업 설정";
	msg1 = "경로를 ";
	msg2 = "지정하세요.";

}

else if ( parm.equals("alertSave") ){

	popTitle = "녹음 파일 백업 설정";
	msg1 = "저장하였습니다.";
	msg2 = " ";
}

else if ( parm.equals("alertSocketFail") ) {

	popTitle = "녹음 파일 백업 설정";
	msg1 = "서버측과 ";
	msg2 = "연결이 되지않았습니다.";

}

else if( parm.equals("alertFtphost") ) {

	popTitle = "녹음 파일 백업 설정";
	msg1 = "아이피 주소를";
	msg2 = "입력하세요.";

}

else if( parm.equals("alertFtpport") ) {

	popTitle = "녹음 파일 백업 설정";
	msg1 = "포트를 입력하세요.";
	msg2 = "";

}

else if( parm.equals("alertFtpuser") ) {

	popTitle = "녹음 파일 백업 설정";
	msg1 = "사용자를 입력하세요.";
	msg2 = "";

}

else if( parm.equals("alertFtppassword") ) {

	popTitle = "녹음 파일 백업 설정";
	msg1 = "비밀번호를 입력하세요.";
	msg2 = "";

}

else if( parm.equals("alertFtpremotepath") ) {

	popTitle = "녹음 파일 백업 설정";
	msg1 = "경로를 입력하세요.";
	msg2 = "";

}

//backup_setting_ok.jsp//

//etc
else{

msg1 = "다시 입력해 주세요.";
msg2 = " ";

}
//etc
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<%-- <link href="<%=StaticString.ContextRoot%>/css/selectBox.css" rel="stylesheet"> --%>
</head>

<body>
<div>
<table width="200" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5">
	<!--Top 여백-->

	<tr height="30">
		<td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">
		<table width="200" border="0" cellpadding="0" cellspacing="0">
			
			<tr>
				<td width="10"></td>
				<td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);"><%=popTitle%></span></td>
			    <td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv2();" style="CURSOR:hand"></td>
				<td width="10"></td>
			</tr>

		</table>
		</td>
	</tr>


	<tr>
		<td>
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td height="10"></td>
			</tr>
		</table>
		</td>
	</tr>
	<!--Top 여백-->

	<tr>
		<!--왼쪽여백-->
		<td>
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="10"></td>
				<td><img src="<%=StaticString.ContextRoot%>/imgs/alarm_question_img.gif" width="32" height="37"></td>
				<td width="10"></td>
				<td>
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20"><%=msg1%></td>
					</tr>
					<tr>
						<td height="20"><%=msg2%></td>
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
				<td height="10"></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td>
		<table width="200" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td align="center"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" onClick="hiddenAdCodeDiv2();"   onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif");' style="CURSOR:hand;"  width="40" height="20"></td>
				<!--td width="6"></td>
				<td align="left"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;"  width="40" height="20" onClick="hiddenAdCodeDiv2();"></td-->
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td>
		<table border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td height="10"></td>
			</tr>
		</table>
		</td>
	</tr>
</table>
</div>
</body>
</html>
