<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%
	String strWIndex = (String)request.getParameter("wIndex");
	String strWFile = (String)request.getParameter("wFileName");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
<link href="<%=StaticString.ContextRoot%>/css/selectBox.css" rel="stylesheet">
</head>

<body>
<%-- <form name="delForm" action="<%=StaticString.ContextRoot%>/voiceFileManageDelete.do2" method="post"> --%>
<form name="delForm" method="post">
<input type="hidden" name="wIndex" value="<%=strWIndex%>">
<input type="hidden" name="wFile" value="<%=strWFile%>">
<table width="200" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5">
	<!--Top 여백-->
	<tr height="30">
		<td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="6">
		<table width="200" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="10"></td>
				<td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">음성파일삭제</span></td>
				<td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
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
						<td height="20">선택한 음성파일을</td>
					</tr>
					<tr>
						<td height="20">삭제하시겠습니까?</td>
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
				<td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif");' style="CURSOR:hand;"  width="40" height="20" 
					onClick="javascript: goDelete();"></td>
				<td width="6"></td>
				<td align="left"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;"  width="40" height="20" 
					onClick="hiddenAdCodeDiv();"></td>
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
</form>
</body>
</html>
