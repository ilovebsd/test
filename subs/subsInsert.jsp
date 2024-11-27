<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="dto.ZipCodeDTO" %>
<%@ page import="business.ZipCode"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="java.util.*" %>
<%@ page import="com.acromate.util.Str"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );

int 	zipCount = 0;
List 	zipCodeList = null;
//�����κ��� DataStatement ��ü�� �Ҵ�
DataStatement 	stmt = null;
try{
	stmt = ConnectionManager.allocStatement("EMS");
	ZipCode	zipCode		= new ZipCode();
	zipCodeList = zipCode.getData(stmt);	// ������ȣ ����Ÿ ��ȸ
	zipCount = zipCodeList.size();
}catch(Exception ex){
	ex.printStackTrace() ;
	if(nModeDebug==1){
		zipCodeList 	= new ArrayList<ZipCodeDTO>();
		ZipCodeDTO zipCodeDTO = new ZipCodeDTO("02","����(02)" );
		zipCodeList.add(zipCodeDTO) ;
		zipCount = zipCodeList.size();
	}
}
if (stmt != null) ConnectionManager.freeStatement(stmt);

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz ��Ż</title>
</head>

<body>
<form name="Savelayer" method="post" enctype="multipart/form-data">
<table width="450" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="3" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:����ü;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">Company ID �߰�</strong></td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="5" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7">&nbsp;</td>
    <td width="160" height="10" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="7" bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td width="7"></td>
  </tr>  
  <!-- ## start field -->
  <!-- # Company -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" colspan="3" align="center" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="left" style="width: 380px; border-bottom: 3px solid #ECECEC;"><strong> Company </strong></div>
	</td>
    <td>&nbsp;</td>
  </tr>
  <!-- Company ID -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right" ><strong>Company ID</strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" align="left" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="groupid" width="100"><label></label>
    	<input type="button" name="btnchkGroupid" width="100" value="�ߺ�üũ" onclick="javascript:goNewSaveDupCheck('groupid')">
	</td>
    <td>&nbsp;</td>
  </tr>
  <!-- # Manager Login -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" colspan="3" align="center" valign="middle" bgcolor="#FFFFFF" style="padding-right:5; ">
    	<div align="left" style="width: 380px; border-bottom: 3px solid #ECECEC;"><strong> Manager Login </strong></div>
	</td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- Login ID -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Login ID </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="loginid" width="100">
    	<input type="button" name="btnchkLoginid" width="100" value="�ߺ�üũ" onclick="javascript:goNewSaveDupCheck('regid')">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- Password -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Password </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="password" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- # Phone-Number -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" colspan="3" align="center" valign="middle" bgcolor="#FFFFFF" style="padding-right:5;">
    	<div align="left" style="width: 380px; border-bottom: 3px solid #ECECEC;"><strong> Phone-Number </strong></div>
	</td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- Domain ID -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Domain </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="txtDomain" width="100"/>
    	<input type="button" name="btnchkDomain" width="100" value="ã��" onclick="javascript:goDomain('I');"/>
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- ���۹�ȣ -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> ���۹�ȣ </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<select name="areanum" style="width:60px" class="select01">
			<!-- <option value="">������</option> -->
			<option value="070">070</option>
			<%																																						 
			ZipCodeDTO zipCodeDTO = null;
			for (int idx = 0; idx < zipCount ; idx++ ) {
				zipCodeDTO = (ZipCodeDTO)zipCodeList.get(idx);
				if(!"070".equals(zipCodeDTO.getCodeitemcd()))
					out.println("<option value='"+zipCodeDTO.getCodeitemcd()+"'>"+zipCodeDTO.getCodeitemcd()+"</option>") ;
			}
			%>   							
	   	</select>
    	<input type="text" name="localnum" style="width:50px" maxlength="4">-<input type="text" name="extnum" style="width:50px" maxlength="4">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- ������ȣ -->
  <!-- <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> ������ȣ </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="extnum" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr> -->
  <!-- ������ȣ -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> ������ȣ </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="authpasswd" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- ������ ��ȣ ���� -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> ������ ��ȣ ���� </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="createcount" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- # Routing -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" colspan="3" align="center" valign="middle" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="left" style="width: 380px; border-bottom: 3px solid #ECECEC;"><strong> Routing </strong></div>
	</td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- Outbound Proxy IP -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Outbound Proxy IP </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="outproxyip" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- Start Prefix -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Start Prefix </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="startprefix" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- End Prefix -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> End Prefix </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="endprefix" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- Minimum Digit -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Minimum Digit </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="mindigit" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- Maximum Digit -->
  <tr>
    <td height="35">&nbsp;</td>
    <td height="35" align="right" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<div align="right"><strong> Maximum Digit </strong></div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td height="35" bgcolor="#FFFFFF" style="padding-right:5 ">
    	<input type="text" name="maxdigit" width="100">
    </td>
    <td width="7">&nbsp;</td>
  </tr>
  <!-- ## end field -->
  
  <tr>
    <td height="13">&nbsp;</td>
    <td colspan="3" height="13" bgcolor="#FFFFFF">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
     
  <tr>
    <td height="10" colspan="5"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="5" style="padding-top:3 "><a href="javascript:goNewSaveDupCheck('group');" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image12','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image12" width="40" height="20" border="0"></a>  <a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image74','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image74" width="40" height="20" border="0"></a></td>
  </tr>
</table>

<input type="hidden" name="checkDupCount" value="0" >

<table width="100%" border="0">
  <tr>
    <th scope="row">&nbsp;</th>
  </tr>
</table>
</form>
</body>
</html>
