<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%
	//String strAmIndex = (String)request.getAttribute("amIndex");
	String deleteCheck = (String)request.getParameter("deleteCheck");
	String deleteStr = (String)request.getParameter("deleteStr");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz ��Ż</title>
<link href="<%=StaticString.ContextRoot%>/css/selectBox.css" rel="stylesheet">
</head>

<body>
<%-- <form name="delForm" action="<%=StaticString.ContextRoot%>/responseTimeManageDelete.do2" method="post"> --%>
<form name="delForm" method="post">
<%-- <input type="hidden" name="amIndex" id="amIndex" value="<%=strAmIndex%>"> --%>
<input type="hidden" name="deleteStr" value="<%=deleteStr%>">
<table width="200" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5">
	<!--Top ����-->
	<tr height="30">
		<td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif" colspan="6">
		<table width="200" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="10"></td>
				<td><span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">����ð�����</span></td>
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
<%
if(deleteCheck.equals("Y")){
%>
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20">������ ���佺������</td>
					</tr>
					<tr>
						<td height="20">�����Ͻðڽ��ϱ�?</td>
					</tr>
				</table>
<%
}else{
%>
				<table border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="40">���õ� �׸��� �����ϴ�.</td>
					</tr>
				</table>
<%
}
%>
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
<%
if(deleteCheck.equals("Y")){
%>
		<table width="200" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" 
					onClick="goDeletePro();" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif");' style="CURSOR:hand;"  width="40" height="20"></td>
				<td width="6"></td>
				<td align="left"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");' style="CURSOR:hand;"  width="40" height="20" 
					onClick="hiddenAdCodeDiv();"></td>
			</tr>
		</table>
<%
}else{
%>
		<table width="200" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td align="center"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif");' style="CURSOR:hand;"  width="40" height="20" 
					onClick="hiddenAdCodeDiv();"></td>
			</tr>
		</table>
<%
}
%>
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