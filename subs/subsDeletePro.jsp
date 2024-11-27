<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>

<% 
response.setHeader("Pragma", "No-cache"); 
response.setDateHeader("Expires", 0); 
response.setHeader("Cache-Control", "no-Cache"); 

int nModeDebug = Str.CheckNullInt( (String)request.getSession(false).getAttribute("login.debug") );
/* 
SessionManager manager = SessionManager.getInstance();
if (manager.isLogin(request) == false) {
	response.sendRedirect(StaticString.ContextRoot+"/index.jsp");
	return ;
}
 */
String grpid      = StringUtil.null2Str(request.getParameter("groupid"),"");
//String[] grpids = grpid.indexOf("|") > -1 ? grpid.split("\\|") : new String[]{grpid};
StringBuffer jsArray = new StringBuffer();

// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    CommonDAO dao = new CommonDAO();
    int count = 0 ;
    
    if(stmt!=null) stmt.stxTransaction() ;
    
    StringBuffer sql = new StringBuffer();
    sql.append("DELETE FROM Table_subscriberGroup WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM Table_subscriber WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;
    
    sql.setLength(0) ;
    sql.append("DELETE FROM table_subgroup WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM Table_ConditionalReplace WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_dept WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_groupblock WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_neighborproxy WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_position WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_routestate WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM Table_prefixtableid WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_prefixtable WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

  	//hc-add : 170327 : req. chun
    sql.setLength(0) ;
    sql.append("DELETE FROM table_routeservice WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;
    
  	//hc-add : 170329 : req. chun
    sql.setLength(0) ;
    sql.append("DELETE FROM Table_RecordBackupftp WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;
    
   	/**
   	 * number 
   	 */

    sql.setLength(0) ;
    sql.append("DELETE FROM nasa_vms_user WHERE vms_id in ( Select E164 From table_E164 Where checkgroupid='").append(grpid).append("')") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_alarmservice WHERE E164 in ( Select E164 From table_E164 Where checkgroupid='").append(grpid).append("')") ;
    count += dao.delete(stmt, sql.toString()) ;
  
    sql.setLength(0) ;
    sql.append("DELETE FROM table_e164 WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_e164route WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_presence WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_presencereport WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_SIPENDPOINT WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_auth WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM table_featureservice WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;
    
    sql.setLength(0) ;
    sql.append("DELETE FROM table_subscriber WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM Table_E164block WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    sql.setLength(0) ;
    sql.append("DELETE FROM Table_Forward WHERE checkgroupid='").append(grpid).append("'") ;
    count += dao.delete(stmt, sql.toString()) ;

    //sql.setLength(0) ;
    //sql.append("DELETE FROM table_alarmservice WHERE checkgroupid='").append(grpid).append("'") ;
    //count += dao.delete(stmt, sql.toString()) ;
    
    /* 
    for(String strid : grpids)
    	if( (strid = strid.trim()).length()>0 ){
    		if(jsArray.length()==0)	jsArray.append("[{params:");
       		else					jsArray.append(",{params:");
    		count += dao.delete(stmt, "DELETE FROM Table_subscriberGroup WHERE groupid='"+strid+"'") ;
    		
    		jsArray.append("[\""+strid+"\",\"\"]}");
       	}
    if(jsArray.length()>0)	jsArray.append("]");
    */
    
    if( count > 0 ){
    	if(stmt!=null) stmt.endTransaction(true) ;
    	
    	jsArray.delete(0, jsArray.length()) ;
    	jsArray.append("[{params:").append("[\""+grpid+"\",\"\"]}");
        jsArray.append("]");
%>
    <script>
    	alert("<%=grpid%> 가 삭제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./subsList.jsp";
    </script>
<%
    }else{
    	if(stmt!=null) stmt.endTransaction(false) ;    	
%>
    <script>
        alert("삭제 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    //e.printStackTrace();
    if(stmt!=null) stmt.endTransaction(false) ;
    
    if(nModeDebug==1){
    	/*
    	for(String strid : grpids)
	       	if( (strid = strid.trim()).length()>0 ){
	       		if(jsArray.length()==0)	jsArray.append("[{params:");
	       		else					jsArray.append(",{params:");
	       		
	       		jsArray.append("[\""+strid+"\",\"\"]}");
	       	}
        if(jsArray.length()>0)	jsArray.append("]");
 		*/
 		jsArray.delete(0, jsArray.length()) ;
 		jsArray.append("[{params:").append("[\""+grpid+"\",\"\"]}");
        jsArray.append("]");
 %>
    <script>
    	alert("<%=grpid%> 가 삭제되었습니다.");
        parent.goDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>