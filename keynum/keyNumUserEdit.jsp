<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dto.ipcs.IpcsVirtualDeptE164DTO" %>
<%@ page import="business.ipcs.IpcsDeptList"%>
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

String userID 		= Str.CheckNullString(scDTO.getSubsID()).trim();
String groupID 		= Str.CheckNullString(scDTO.getLoginGroup()).trim();

response.setCharacterEncoding("euc-kr");
 */
 
HttpSession ses = request.getSession(false);
String groupID = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;

String endpointId 	= StringUtil.null2Str(request.getParameter("hiEndpointId"),"");
String deptName		= new String(request.getParameter("hiDeptName").getBytes("8859_1"), "utf-8");
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);

try{
    //조회 부분
    //IpcsDeptList ipcsDeptList = new IpcsDeptList();
    String type;
    
    List subPickupList  = null;//ipcsDeptList.getE164List(stmt, endpointId, "1", groupID);
    if(1==1){
    	type = "1" ;
    	
    	IpcsVirtualDeptE164DTO ipcsVirtualDeptE164DTO;
        List<IpcsVirtualDeptE164DTO> subGroupList = new ArrayList<IpcsVirtualDeptE164DTO>();
        
        String sql = "\n SELECT a.e164, a.subid, ";
        /*sql = sql +  "\n        coalesce(b.id, '') AS id, " ;
        sql = sql +  "\n        coalesce(b.name, '') AS name, " ;
        sql = sql +  "\n        coalesce(b.phonenum, '') AS phonenum, " ;
        sql = sql +  "\n        coalesce(b.position, '') AS position, " ;
        sql = sql +  "\n        coalesce(c.ranking, 100) AS rank, " ;*/
        sql = sql +  "\n        b.id AS id, " ;
        sql = sql +  "\n        b.name AS name, " ;
        sql = sql +  "\n        b.phonenum AS phonenum, " ;
        sql = sql +  "\n        b.position AS position, " ;
        sql = sql +  "\n        c.ranking AS rank, " ;
        sql = sql +  "\n        b.department as s_deptid, " ;
        sql = sql +  "\n        (select deptid from table_dept where keynumber = '"+endpointId+"') as d_deptid " ;
        sql = sql +  "\n   FROM table_e164 a " ;
        sql = sql +  "\n   LEFT OUTER JOIN table_subscriber b " ;
        sql = sql +  "\n                ON a.e164  = b.phonenum " ;
        sql = sql +  "\n   LEFT OUTER JOIN table_position c " ;
        //sql = sql +  "\n                ON b.position = c.positionname AND a.groupid = c.groupid " ;
        sql = sql +  "\n                ON b.position = c.positionname AND a.groupid = c.checkgroupid " ;
        if("1".equals(type)){
        	sql = sql +  "\n  WHERE a.e164 not in (select e164 from table_keynumber where keynumberid = '"+endpointId+"') " ;
        }else{
        	sql = sql +  "\n  WHERE a.e164 in (select e164 from table_keynumber where keynumberid = '"+endpointId+"') " ;
        }
        if(groupID!=null&& groupID.length()>0)
        	sql = sql +  "\n  AND a.groupid= '"+groupID+"' " ;
        sql = sql +  "\n  Order By rank ASC, b.name ASC ";               

        System.out.println("SQL :\n "+sql);
        ResultSet rs = null;
        try {
            if (stmt != null) {
                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                	ipcsVirtualDeptE164DTO = new IpcsVirtualDeptE164DTO();
                	
                	ipcsVirtualDeptE164DTO.setE164(Str.CheckNullString(rs.getString("e164")));
                	ipcsVirtualDeptE164DTO.setE164SubID(Str.CheckNullString(rs.getString("subid")));
                	ipcsVirtualDeptE164DTO.setSubScriberID(Str.CheckNullString(rs.getString("id")));
                	ipcsVirtualDeptE164DTO.setName(Str.CheckNullString(rs.getString("name")));
                	ipcsVirtualDeptE164DTO.setPhoneNum(Str.CheckNullString(rs.getString("phonenum")));
                	ipcsVirtualDeptE164DTO.setPosition(Str.CheckNullString(rs.getString("position")));
                	ipcsVirtualDeptE164DTO.setRanking(rs.getInt("rank"));
                	ipcsVirtualDeptE164DTO.setS_deptid(rs.getInt("s_deptid"));
                	ipcsVirtualDeptE164DTO.setD_deptid(rs.getInt("d_deptid"));
                	subGroupList.add(ipcsVirtualDeptE164DTO);
                }
                rs.close();
            } else           
                System.out.println("데이터베이스에 연결할 수 없습니다.");            
        } catch (Exception e) {
            System.out.println(e.getMessage());
            //return subGroupList;
        } finally {
            try {
                if (rs != null)
                    rs.close();
            } catch (Exception e) {}
        }
        
        subPickupList = subGroupList;
    }///
    
    List subPickupList2 = null;//ipcsDeptList.getE164List(stmt, endpointId, "2", groupID);
    if(1==1){
    	type = "2" ;
    	
    	IpcsVirtualDeptE164DTO ipcsVirtualDeptE164DTO;
        List<IpcsVirtualDeptE164DTO> subGroupList = new ArrayList<IpcsVirtualDeptE164DTO>();
        
        String sql = "\n SELECT a.e164, a.subid, ";
        /*sql = sql +  "\n        coalesce(b.id, '') AS id, " ;
        sql = sql +  "\n        coalesce(b.name, '') AS name, " ;
        sql = sql +  "\n        coalesce(b.phonenum, '') AS phonenum, " ;
        sql = sql +  "\n        coalesce(b.position, '') AS position, " ;
        sql = sql +  "\n        coalesce(c.ranking, 100) AS rank, " ;*/
        sql = sql +  "\n        b.id AS id, " ;
        sql = sql +  "\n        b.name AS name, " ;
        sql = sql +  "\n        b.phonenum AS phonenum, " ;
        sql = sql +  "\n        b.position AS position, " ;
        sql = sql +  "\n        c.ranking AS rank, " ;
        sql = sql +  "\n        b.department as s_deptid, " ;
        sql = sql +  "\n        (select deptid from table_dept where keynumber = '"+endpointId+"') as d_deptid " ;
        sql = sql +  "\n   FROM table_e164 a " ;
        sql = sql +  "\n   LEFT OUTER JOIN table_subscriber b " ;
        sql = sql +  "\n                ON a.e164  = b.phonenum " ;
        sql = sql +  "\n   LEFT OUTER JOIN table_position c " ;
        //sql = sql +  "\n                ON b.position = c.positionname AND a.groupid = c.groupid " ;
        sql = sql +  "\n                ON b.position = c.positionname AND a.groupid = c.checkgroupid " ;
        if("1".equals(type)){
        	sql = sql +  "\n  WHERE a.e164 not in (select e164 from table_keynumber where keynumberid = '"+endpointId+"') " ;
        }else{
        	sql = sql +  "\n  WHERE a.e164 in (select e164 from table_keynumber where keynumberid = '"+endpointId+"') " ;
        }
        if(groupID!=null&& groupID.length()>0)
        	sql = sql +  "\n  AND a.groupid= '"+groupID+"' " ;
        sql = sql +  "\n  Order By rank ASC, b.name ASC ";               

        System.out.println("SQL :\n "+sql);
        ResultSet rs = null;
        try {
            if (stmt != null) {
                rs = stmt.executeQuery(sql);
                while (rs.next()) {
                	ipcsVirtualDeptE164DTO = new IpcsVirtualDeptE164DTO();
                	
                	ipcsVirtualDeptE164DTO.setE164(Str.CheckNullString(rs.getString("e164")));
                	ipcsVirtualDeptE164DTO.setE164SubID(Str.CheckNullString(rs.getString("subid")));
                	ipcsVirtualDeptE164DTO.setSubScriberID(Str.CheckNullString(rs.getString("id")));
                	ipcsVirtualDeptE164DTO.setName(Str.CheckNullString(rs.getString("name")));
                	ipcsVirtualDeptE164DTO.setPhoneNum(Str.CheckNullString(rs.getString("phonenum")));
                	ipcsVirtualDeptE164DTO.setPosition(Str.CheckNullString(rs.getString("position")));
                	ipcsVirtualDeptE164DTO.setRanking(rs.getInt("rank"));
                	ipcsVirtualDeptE164DTO.setS_deptid(rs.getInt("s_deptid"));
                	ipcsVirtualDeptE164DTO.setD_deptid(rs.getInt("d_deptid"));
                	subGroupList.add(ipcsVirtualDeptE164DTO);
                }
                rs.close();
            } else           
                System.out.println("데이터베이스에 연결할 수 없습니다.");            
        } catch (Exception e) {
            System.out.println(e.getMessage());
            //return subGroupList;
        } finally {
            try {
                if (rs != null)
                    rs.close();
            } catch (Exception e) {}
        }
        
        subPickupList2 = subGroupList;
    }///
    
    int count  = subPickupList.size();
    int count2 = subPickupList2.size();

    IpcsVirtualDeptE164DTO 	ipcsVirtualDeptE164DTO = null;    
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Biz 포탈</title>
</head>

<body>
<form name="Editlayer" method="post">
<input type='hidden' name ='hiGroupID' 	value="">
<input type='hidden' name ='hiSubID' 	value="">

<table width="700" border="0" cellpadding="0" cellspacing="0" bgcolor="eaeaea">
  <tr>
    <td width="8" height="5" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">&nbsp;</td>
    <td height="30" style="padding-left:10;padding-top:5" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"> <strong style="font-family:굴림체;font-size:10pt; text-decoration:none; color:RGB(255,255,255);">대표번호 사용자 관리 수정</strong></td>
    <td align="right" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif"><img src="<%=StaticString.ContextRoot%>/imgs/icon_x.gif" onClick="hiddenAdCodeDiv();" style="CURSOR:hand"></td>
    <td width="8" background="<%=StaticString.ContextRoot%>/imgs/layer_titlebg_img.gif">&nbsp;</td>
  </tr>
  <tr align="right">
    <td height="8" colspan="4" style="padding-right:10; color:RGB(82,86,88)"></td>
  </tr>  
  <tr>
    <td width="8" height="5">&nbsp;</td>
    <td bgcolor="#FFFFFF" colspan="2">
        <table width="98%" border="0" align="center">
          <tr>
            <td width="15%" valign="middle" class="title" align="right"><strong>대표번호</strong> &nbsp;</td>
            <td width="85%" height="20" align="left" valign="middle">
            	<input type='text' name ='txtDeptNumber' value="<%=endpointId%>" style="width:100" disabled>
            	<%-- &nbsp;&nbsp;[부서명 : <%=deptName%>] --%>
            </td>
          </tr>
        </table>
    </td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="4" height="7"></td>
  </tr>
  <tr>
    <td width="8" height="5">&nbsp;</td>
    <td bgcolor="#FFFFFF" colspan="2">
        <table width="98%" border="0" align="center">
            <tr>
                <td width="45%" height="25" scope="row"><strong>추가 가능한 사용자 </strong></td>
                <td width="10%" height="25" scope="row"></td>
                <td width="45%" height="25" scope="row"><strong>추가된 사용자 </strong></td>
            </tr>
            <tr>
                <td width="45%" height="300" scope="row" valign="top">
                    <table width="100%" border="0">
                        <tr>
                            <td>
                                <select multiple size="18" name="list1" style="width:100%;" onDblClick="move(document.Editlayer.list1,document.Editlayer.list2)">
<%																																						 
	ipcsVirtualDeptE164DTO = null;
    for ( int idx = 0; idx < count ; idx++ ) {
    	ipcsVirtualDeptE164DTO = (IpcsVirtualDeptE164DTO)subPickupList.get(idx);
%>
                                    <option value="<%=ipcsVirtualDeptE164DTO.getE164()%>;<%=ipcsVirtualDeptE164DTO.getS_deptid()%>;<%=ipcsVirtualDeptE164DTO.getD_deptid()%>"><%=ipcsVirtualDeptE164DTO.getE164()+" ("+ipcsVirtualDeptE164DTO.getName()+/* " "+ipcsVirtualDeptE164DTO.getPosition()+ */")"%></option>
<%    
    }    
%>
                                </select>
                            </td>
                        </tr>
                    </table>
                </td>
                <td width="10%" height="300" scope="row">
                    <table width="100%" border="0">
                        <tr>
                            <td>
                                <a href="javascript:move(document.Editlayer.list1,document.Editlayer.list2);" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image22','','<%=StaticString.ContextRoot%>/imgs/Content_add02_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_add02_n_btn.gif" name="Image22" width="36" height="20" border="0"></a><br/>
                                <br /><a href="javascript:move2(document.Editlayer.list2,document.Editlayer.list1);" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image21','','<%=StaticString.ContextRoot%>/imgs/Content_delete02_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_delete02_n_btn.gif" name="Image21" width="36" height="20" border="0"></a>
                            </td>
                        </tr>
                    </table>
                </td>
                <td width="45%" height="300" scope="row" valign="top">
                    <table width="100%" border="0">
                        <tr>
                            <td>
                                <select multiple size="18" name="list2" style="width:100%;" onDblClick="move(document.Editlayer.list2,document.Editlayer.list1)">
<%																																						 
ipcsVirtualDeptE164DTO = null;
    for ( int idx = 0; idx < count2 ; idx++ ) {
    	ipcsVirtualDeptE164DTO = (IpcsVirtualDeptE164DTO)subPickupList2.get(idx);
        if(ipcsVirtualDeptE164DTO.getS_deptid()==ipcsVirtualDeptE164DTO.getD_deptid()){
%>
                                    <option value="<%=ipcsVirtualDeptE164DTO.getE164()%>;<%=ipcsVirtualDeptE164DTO.getS_deptid()%>;<%=ipcsVirtualDeptE164DTO.getD_deptid()%>"><%=ipcsVirtualDeptE164DTO.getE164()+" ("+ipcsVirtualDeptE164DTO.getName()+/* " "+ipcsVirtualDeptE164DTO.getPosition()+ */")"%> [조직도 이용자]</option>
<%  
        }else{
%>
									<option value="<%=ipcsVirtualDeptE164DTO.getE164()%>;<%=ipcsVirtualDeptE164DTO.getS_deptid()%>;<%=ipcsVirtualDeptE164DTO.getD_deptid()%>"><%=ipcsVirtualDeptE164DTO.getE164()+" ("+ipcsVirtualDeptE164DTO.getName()+/* " "+ipcsVirtualDeptE164DTO.getPosition()+ */")"%></option>
<%	
        }
    }    
%>
                                </select>
                            </td>
                        </tr>
                    </table>
                </td>            
            </tr>
        </table>
    </td>
    <td width="8">&nbsp;</td>
  </tr>
  <tr>
    <td height="35">&nbsp;</td>
    <td align="center" colspan="2" style="padding-top:3 "> <a href="javascript:goUserEditPro(document.Editlayer.list2);" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image2','','<%=StaticString.ContextRoot%>/imgs/Content_save_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_save_n_btn.gif" name="Image2" width="40" height="20" border="0"></a> <a href="javascript:hiddenAdCodeDiv();" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image4','','<%=StaticString.ContextRoot%>/imgs/Content_cancel_p_btn.gif',0)"><img src="<%=StaticString.ContextRoot%>/imgs/Content_cancel_n_btn.gif" name="Image4" width="40" height="20" border="0"></a></td>
    <td>&nbsp;</td>
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