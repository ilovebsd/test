<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>
<body>
<%-- <form name="addForm" action="<%=StaticString.ContextRoot%>/voiceFileManageInput.do2" method="post" enctype="multipart/form-data"> --%>
<form name="addForm" method="post" enctype="multipart/form-data">
<table width="487" border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F9F5">
	<!-- Top 여백-->
	<tr>
		<td>
		<table border="0" cellpadding="0" cellspacing="0" width="487">
			<tr>
				<td height="30"  style="background:url('<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif') repeat-x">
				&nbsp;&nbsp;<span style="font-family:Gulim;font-size:12px;font-weight:bold;color:rgb(255,255,255);">음성파일추가</span>
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
								<td width="400"><input type="text" name="wName" MaxLength="50" style="width:150px;font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);"></td>
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
									<!--<tr>
										<td><input type="text" style="font-family:'12px Gulim'; font-size:12px; color:rgb(82,86,88);border: 1px solid rgb(207,207,207);"></td>
										<td width="6"></td>
										<td><img src="<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_search_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_search_p_btn.gif");' style="CURSOR:hand;" width="40" height="20"></td>
									</tr>-->
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
								<%-- <td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");'
									 style="CURSOR:hand;" onClick="javascript:add();" width="40" height="20"></td> --%>
								<td align="right"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif");'
									 style="CURSOR:hand;" onClick="javascript: goInsertPro();" width="40" height="20"></td>
								<td width="6"></td>
								<td align="left"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" onmouseout='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif");' onmouseover='javascript:fncOverOut(this,"<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif");'
									 style="CURSOR:hand;" onClick="hiddenAdCodeDiv();" width="40" height="20"></td>
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
