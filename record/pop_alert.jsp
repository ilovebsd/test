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
	popTitle = "�˸�";
	msg1 = "�ٽ� �Է��� �ּ���.";
	msg2 = " ";
}

//channel_admin.jsp//
else if( parm.equals("alterCphone") ){
	
	popTitle = "��ȭ ä�� ����";
	msg1 = "������ȣ��";
	msg2 = "�Է��ϼ���.";

}
else if( parm.equals("alterCname") ){

	popTitle = "��ȭ ä�� ����";
	msg1 = "�̸���";
	msg2 = "�Է��ϼ���.";

}

else if (parm.equals("alertEdit") ){

	popTitle = "��ȭ ä�� ����";
	msg1 = "�����Ͽ����ϴ�.";
	msg2 = "";

}


//channel_admin.jsp//

//record_search.jsp//
else if( parm.equals("alertCheck") ){

	popTitle = "���� ���� ����";
	msg1 = "������ �����͸�";
	msg2 = "�����ϼ���.";
}
else if( parm.equals("alertFile") ){

	popTitle = "���� ���� ����";
	msg1 = "������ ";
	msg2 = "�������� �ʽ��ϴ�.";
}

else if( parm.equals("alertChangeFile") ){

	popTitle = "��ȭ ���� ���";
	msg1 = "��������� ";
	msg2 = "��ȯ�߿� �ֽ��ϴ�.";
}

else if( parm.equals("ftpChange") ){

	popTitle = "��ȭ ���� ��� ";
	msg1 = "���θ�/�ܺθ� ������ ";
	msg2 = "�ٸ��� �����ϼ���.";
}

else if( parm.equals("ftpfalse") ){

	popTitle = "��ȭ ���� ��� ";
	msg1 = "FTP ���ӽ����Դϴ�.";
	msg2 = "";
}


//record_search.jsp//

//backup_setting_ok.jsp//
else if( parm.equals("alertIpaddr") ){

	popTitle = "���� ���� ��� ����";
	msg1 = "������ �ּҸ�";
	msg2 = "�Է��ϼ���.";

}

else if( parm.equals("alertBackuppath") ){

	popTitle = "���� ���� ��� ����";
	msg1 = "��θ� ";
	msg2 = "�����ϼ���.";

}

else if ( parm.equals("alertSave") ){

	popTitle = "���� ���� ��� ����";
	msg1 = "�����Ͽ����ϴ�.";
	msg2 = " ";
}

else if ( parm.equals("alertSocketFail") ) {

	popTitle = "���� ���� ��� ����";
	msg1 = "�������� ";
	msg2 = "������ �����ʾҽ��ϴ�.";

}

else if( parm.equals("alertFtphost") ) {

	popTitle = "���� ���� ��� ����";
	msg1 = "������ �ּҸ�";
	msg2 = "�Է��ϼ���.";

}

else if( parm.equals("alertFtpport") ) {

	popTitle = "���� ���� ��� ����";
	msg1 = "��Ʈ�� �Է��ϼ���.";
	msg2 = "";

}

else if( parm.equals("alertFtpuser") ) {

	popTitle = "���� ���� ��� ����";
	msg1 = "����ڸ� �Է��ϼ���.";
	msg2 = "";

}

else if( parm.equals("alertFtppassword") ) {

	popTitle = "���� ���� ��� ����";
	msg1 = "��й�ȣ�� �Է��ϼ���.";
	msg2 = "";

}

else if( parm.equals("alertFtpremotepath") ) {

	popTitle = "���� ���� ��� ����";
	msg1 = "��θ� �Է��ϼ���.";
	msg2 = "";

}

//backup_setting_ok.jsp//

//etc
else{

msg1 = "�ٽ� �Է��� �ּ���.";
msg2 = " ";

}
//etc
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz ��Ż</title>
<%-- <link href="<%=StaticString.ContextRoot%>/css/selectBox.css" rel="stylesheet"> --%>
</head>

<body>
<div>
<table width="200" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5">
	<!--Top ����-->

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
	<!--Top ����-->

	<tr>
		<!--���ʿ���-->
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
