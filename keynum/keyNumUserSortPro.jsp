<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="waf.*"%>
<%@ page import="dto.SubscriberInfoDTO"%>
<%@ page import="dao.buddy.DeptDAO"%>
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

String userID    		= Str.CheckNullString(scDTO.getSubsID()).trim();
 */

HttpSession ses = request.getSession(false);
int nModeDebug = Str.CheckNullInt( (String)ses.getAttribute("login.debug") );
String groupid = ses != null?(String)ses.getAttribute("login.name") : null;
String userID = (String)ses.getAttribute("login.user") ;
 
String pageDir = "";//"/ems";

String sortStr 			= StringUtil.null2Str(request.getParameter("sortStr"),"");
String sortDeptnumber 	= StringUtil.null2Str(request.getParameter("hiSortDeptnumber"),"");
System.out.println("############# sortDeptnumber : "+sortDeptnumber);
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);

try{
    //삭제 처리부분
    //DeptDAO deptDAO = new DeptDAO();
    int 	count 	= 0;//deptDAO.updateSortPro(stmt, sortStr, sortDeptnumber);
    
    int      nResult = 0;
    String[] positionStr = StringUtil.getParser(sortStr, "");
    
    try {      
        if(positionStr != null){
        	// 트랜잭션 시작
			stmt.stxTransaction();
			
			for(int i=0; i < positionStr.length; i++){
				String[] dataStr = StringUtil.getParser(positionStr[i], "|");
				if (stmt != null) {
	                String sql = "\n UPDATE TABLE_Keynumber  " ;
	                sql = sql +  "\n    Set indexno    = " + dataStr[1];
	                sql = sql +  "\n  Where e164 = '" + dataStr[0] + "' ";
	                sql = sql +  "\n    And keynumberid = '" + sortDeptnumber + "' ";
	                nResult = stmt.executeUpdate(sql);
	                if (nResult >= 1)
	                    System.out.println("수정  성공");
	                else
	                    System.out.println("수정  실패");		                
				}
			}
			
			/* if(smsNumber!=null&& smsNumber.length()>0){
                String sql2 = "\n UPDATE table_keynumber_sms  Set e164 = '" + smsNumber + "'  Where keynumberid = '" + sortDeptnumber + "' ";
                nResult = stmt.executeUpdate(sql2);
			} */
            
			if (stmt != null)
				stmt.endTransaction(true);
        }
    } catch (Exception e) {
        e.printStackTrace();
        if (stmt != null)
			stmt.endTransaction(false);
    } finally {
        //return nResult ;
    	count = nResult;
    }
    
    if(count > 0){
%>
    <script>
        alert("변경되었습니다.");
        parent.hiddenAdCodeDiv();
        <%-- parent.location.href="<%=StaticString.ContextRoot+pageDir%>/ipcs/ipcsVirtualDeptNumberList.jsp"; --%>
    </script>
<%
    }else{
%>
    <script>
        alert("변경 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
        <%-- parent.location.href="<%=StaticString.ContextRoot+pageDir%>/buddy/ipcsVirtualDeptNumberList.jsp"; --%>
    </script>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>