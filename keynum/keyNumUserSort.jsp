<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dto.KeyNumberDTO" %>
<%@ page import="buddy.DeptList" %>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.List"%>
<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}

HttpSession 		hs 		= request.getSession();
String 				id 		= hs.getId();
BaseEntity 			entity 	= manager.getBaseEntity(id);
SubscriberInfoDTO 	scDTO 	= entity.getScDtoAttribute("scDTO");

String 	userID 		= Str.CheckNullString(scDTO.getSubsID()).trim();
 */
 
HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String authGroupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;
 
String 	deptnumber	= request.getParameter("deptnumber");			// 대표번호
//System.out.println("############# : "+deptnumber);
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);

try{
    // 착신번호
    DeptList deptList = new DeptList();

    List deptNumberList = deptList.getDeptNumberList(stmt, deptnumber);				// 데이타 조회

    int count = deptNumberList.size();
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="Sortlayer" method="post">
<input type='hidden' name ='count' 				value="<%=count%>">
<input type='hidden' name ='hiSortDeptnumber'	value="<%=deptnumber%>">

  <table width="300" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
    <tr>
        <td align="left" height="30" colspan="2" style="padding-left:10;padding-top:5 " background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">&nbsp;&nbsp;착신순서 변경</strong></td>
        <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
        <td background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"></td>
    </tr>
    <tr align="center">
        <td width="5" height="8" style="color:RGB(82,86,88)"></td>
        <td width="280" style="color:RGB(82,86,88)"></td>
        <td width="10" style="color:RGB(82,86,88)"></td>
        <td width="5" style="color:RGB(82,86,88)"></td>
    </tr>
    <tr align="center">
        <td width="5" height="5"></td>
        <td colspan="2" align="right" bgcolor="#FFFFFF" ></td>
        <td width="5"></td>
    </tr>
    <tr align="center">
      <td width="5" height="22">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF" style="padding-left:5;padding-right:5 ">
        <table width="280" border="0" cellspacing="0" cellpadding="0" align="center" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
          <tr align="center" height="22" >
            <td width="50" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">순서</td>
            <td width="120" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">이름</td>
            <td width="110" class="table_header01" style="cursor:hand" background="<%=StaticString.ContextRoot%>/imgs/table_header_img.gif">전화번호</td>
          </tr>
		</table>
      </td>
      <td width="5">&nbsp;</td>
    </tr>
    <tr align="center">
      <td width="5" height="22">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF" style="padding-left:5;padding-right:5 ">
        <table width="280" border="0" cellspacing="0" cellpadding="0" align="center" bgcolor="ffffff" style="border:1 solid rgb(160,160,160) ">
<%																																						 
	KeyNumberDTO keyNumberDTO = null;
    int chk = 0;
    for ( int idx = 0; idx < count ; idx++ ) {
    	keyNumberDTO = (KeyNumberDTO)deptNumberList.get(idx);																											
        if(chk == 0){
%>	          
          <tr height="22" bgcolor="#F3F9F5" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="#F3F9F5">
            <td width="50" class="table_column" >
                <select name="ranking" >
<%
            for(int i=1; i<=count; i++){    
%>
                <option value="<%=i%>" <%if(i == keyNumberDTO.getIndexno()) out.print("selected");%> ><%=i%></option>
<%
            }    
%>
                </select>
            </td>
            <td width="120" class="table_column" ><%=keyNumberDTO.getName()%>&nbsp;</td>
            <td width="110" class="table_column" ><%=keyNumberDTO.getE164()%>&nbsp;<input type="hidden" name="positionid" value="<%=keyNumberDTO.getE164()%>"></td>
          </tr>
<%
            chk = 1;
        }else{    
%>
          <tr height="22" align="center" onmouseover=this.style.backgroundColor="a8d3aa" onmouseout=this.style.backgroundColor="ffffff">
            <td width="50" class="table_column" >
                <select name="ranking" >
<%
            for(int i=1; i<=count; i++){    
%>
                <option value="<%=i%>" <%if(i == keyNumberDTO.getIndexno()) out.print("selected");%> ><%=i%></option>
<%
            }    
%>
                </select>
            </td>
            <td width="120" class="table_column" ><%=keyNumberDTO.getName()%>&nbsp;</td>
            <td width="110" class="table_column" ><%=keyNumberDTO.getE164()%>&nbsp;<input type="hidden" name="positionid" value="<%=keyNumberDTO.getE164()%>"></td>
          </tr>
<% 
            chk = 0;
        }
    }
%>
		</table>
      </td>
      <td width="5">&nbsp;</td>
    </tr>
    <tr align="center">
      <td height="5"></td>
      <td colspan="2" bgcolor="#FFFFFF"></td>
      <td></td>
    </tr>
    <tr align="center">
      <td height="35" colspan="4" style="padding-top:3 "><a href="javascript:goUserSortPro();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image3','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"> <img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image3" width="40" height="20" border="0"></a> <a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
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