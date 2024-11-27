<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dto.CommonCodeDTO" %>
<%@ page import="system.RootList"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

HttpSession 		ses 		= request.getSession();
String checkgroupid     = Str.CheckNullString((String) ses.getAttribute("login.name"));

//String userName   = Str.CheckNullString(scDTO.getName()).trim();
//String phoneNum   = Str.CheckNullString(scDTO.getPhoneNum()).trim();
String userID     = Str.CheckNullString((String) ses.getAttribute("login.user")).trim();
String loginLevel = Str.CheckNullString((String) ses.getAttribute("login.level")).trim();   // 관리레벨(1:사용자, 2:관리자)

String type      = Str.CheckNullString(request.getParameter("type")).trim();
String formType  = Str.CheckNullString(request.getParameter("formtype")).trim();
System.out.println("formType1111 : "+formType);
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);

RootList 	rootList	= new RootList();
List 	idList;

try{
	int 	count = 0;
		
	idList = rootList.getZone(stmt);	// 데이타 조회
	count = idList.size();
    
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="Addrlayer" method="post">
<input type='hidden' name ='dataType' value="<%=type%>">
<input type='hidden' name ='formType' value="<%=formType%>">

<table width="200" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">Zone Code 선택</strong></td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv2();" style="CURSOR:hand"></td>
    <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
  </tr>
  <tr align="right">
    <td height="8" colspan="4" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="7" height="10"></td>
    <td width="76" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="10" bgcolor="#FFFFFF"></td>
    <td width="7"></td>
  </tr>  
  
  <tr>
    <td width="7" height="230">&nbsp;</td>
    <td colspan="2" align="center" bgcolor="#FFFFFF" valign="top">
        <div style="left:0px; top:0px; width:180; height:22; overflow:hidden;">
        <table width="160" border="0" cellspacing="0" cellpadding="0"  class="list_table">
            <tr align="center" height="22" >
		    	<!--td width="160" class="table_header01" background="<%//=StaticString.ContextRoot%>/imgs/table_header_img.gif">Zone Code</td-->
		    	<td width="80" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">Code</td>
		    	<td width="80" class="table_header01" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">Zone</td>
            </tr>
        </table>
        </div>
        <div style="left:0px; top:0px; width:180; height:235; overflow-x:hidden; overflow-y:auto;">
        <table width="160" border="0" cellspacing="0" cellpadding="0"  class="list_table">
<%
	CommonCodeDTO 	commonCodeDTO 	= null;
	int chk = 0;
    for ( int idx = 0; idx < count ; idx++ ) {
    	commonCodeDTO = (CommonCodeDTO)idList.get(idx);
        if(chk == 0){
%>
            <tr height="22" bgcolor="F3F9F5" align="center" onClick="goAddZone(this,'<%=commonCodeDTO.getCodeId()%>','<%=formType%>');">
              <!--td width="160" class="table_column"><%//=commonCodeDTO.getCodeId()%>&nbsp;</td-->
              <td width="80" class="table_column"><%=commonCodeDTO.getCodeId()%>&nbsp;</td>
              <td width="80" class="table_column"><%=commonCodeDTO.getCodeName()%>&nbsp;</td>
            </tr>
<%
            chk = 1;
        }else{
%>
            <tr height="22" align="center" onClick="goAddZone(this,'<%=commonCodeDTO.getCodeId()%>','<%=formType%>');">
              <!--td width="160" class="table_column"><%//=commonCodeDTO.getCodeId()%>&nbsp;</td-->
              <td width="80" class="table_column"><%=commonCodeDTO.getCodeId()%>&nbsp;</td>
              <td width="80" class="table_column"><%=commonCodeDTO.getCodeName()%>&nbsp;</td>
            </tr>
<% 
            chk = 0;
        }
    }

    if(count < 10){
        for ( int idx = 0; idx < (10 - count) ; idx++ ) {
            if(chk == 0){
%>
            <tr height="22" bgcolor="F3F9F5" align="center" >
              <!--td width="160" class="table_column">&nbsp;</td-->
              <td width="80" class="table_column">&nbsp;</td>
              <td width="80" class="table_column">&nbsp;</td>
            </tr>
<%
                chk = 1;
            }else{    
%>
            <tr height="22" align="center" >
              <!--td width="160" class="table_column">&nbsp;</td-->
              <td width="80" class="table_column">&nbsp;</td>
              <td width="80" class="table_column">&nbsp;</td>
            </tr>
<% 
                chk = 0;
            }
        }
    }
%> 
        </table>
        </div>
    </td>
    <td width="7"></td>
  </tr>
     
  <tr>
    <td height="5" colspan="4"></td>
    </tr>   
  <tr align="center">
    <td height="35" colspan="4" style="padding-top:3 "><a href="javascript:hiddenAdCodeDiv2();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image74','','<%=StaticString.ContextRoot%>/imgs/Content_ok_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_ok_n_btn.gif" name="Image74" width="40" height="20" border="0"></a></td>
  </tr>
</table>



<table width="100%" border="0">
  <tr>
    <th scope="row">&nbsp;</th>
  </tr>
</table>
</form>
</body>
</html>
<%
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		//할당받은 DataStatement 객체는 반납
		if (stmt != null ) ConnectionManager.freeStatement(stmt);
	}	
%>