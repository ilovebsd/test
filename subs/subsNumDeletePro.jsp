<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="acromate.common.StaticString"%>
<%@ page import="acromate.common.util.*"%>
<%@ page import="dao.system.CommonDAO"%>
<%@ page import="com.acromate.driver.db.DataStatement"%>
<%@ page import="acromate.ConnectionManager"%>
<%@ page import="com.acromate.util.Str"%>
<%@ page import="java.util.*"%>

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
String grpid      = StringUtil.null2Str(request.getParameter("groupid"),"").trim();
//String[] grpids = grpid.indexOf("|") > -1 ? grpid.split("\\|") : new String[]{grpid};

String areanum     	= StringUtil.null2Str(request.getParameter("areanum"),"").trim();
String localnum   	= StringUtil.null2Str(request.getParameter("localnum"),"").trim();
String extnum       = StringUtil.null2Str(request.getParameter("extnum"),"").trim();
//String authpasswd   = StringUtil.null2Str(request.getParameter("authpasswd"),"").trim();
String deletecount  = StringUtil.null2Str(request.getParameter("createcount"),"").trim();

StringBuffer jsArray = new StringBuffer();
ArrayList envList = null;
String extensiongroupnum = null, domainid="";
// 서버로부터 DataStatement 객체를 할당
DataStatement 	stmt 			= null;
String sesSysGroupID = StringUtil.null2Str(request.getSession(false).getAttribute("login.sysgroupid"), "");
try{
	stmt 			= ConnectionManager.allocStatement("SSW", sesSysGroupID);
    //삭제 처리부분
    CommonDAO dao = new CommonDAO();
    envList = dao.select(stmt, "select extensiongroupnum, domain from Table_subscriberGroup where extensiongroupnum like '%*%' AND checkgroupid='"+grpid+"'", new String[]{"extensiongroupnum","domain"} ) ;
    if( envList.size() > 0 ){
        HashMap item = (HashMap)envList.get(0);
        extensiongroupnum = (String)item.get("extensiongroupnum") ;
        domainid = (String)item.get("domain") ;
    }
    
    int count = 0 ;
    StringBuffer sql = new StringBuffer();
    /** Phone-Number **/
    String number = "1" + extnum ;
    int extnumLength = extnum.length() ;
    int nPlus = Str.CheckNullInt( number ) ;
    int nCount = Str.CheckNullInt( deletecount ) + nPlus;
    String tailDomain = domainid.length()>0 ? "@"+domainid+":5060" : "@vpbx.callbox.kt.com:5060" ;
    
    if(stmt!=null) stmt.stxTransaction();
    while(nPlus < nCount){
    	extnum = String.valueOf(nPlus).substring(1) ;
        String phoneNumber = areanum + localnum + extnum ;
    	String endpointID = phoneNumber+tailDomain;//"@vpbx.callbox.kt.com:5060" ;
    	
    	sql.setLength(0) ;
        sql.append("DELETE FROM nasa_vms_user WHERE vms_id in ( Select E164 From table_E164 Where checkgroupid='").append(grpid).append("' AND E164='"+phoneNumber+"')") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("DELETE FROM table_alarmservice WHERE E164 in ( Select E164 From table_E164 Where checkgroupid='").append(grpid).append("' AND E164='"+phoneNumber+"')") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;
      
        sql.setLength(0) ;
        sql.append("DELETE FROM table_e164 WHERE checkgroupid='").append(grpid).append("' AND E164='"+phoneNumber+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("DELETE FROM table_e164route WHERE checkgroupid='").append(grpid).append("' AND E164='"+phoneNumber+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        /* ENDPOINT ID */
        sql.setLength(0) ;
        sql.append("DELETE FROM table_SIPENDPOINT WHERE checkgroupid='").append(grpid).append("' AND EndpointID='"+endpointID+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("DELETE FROM table_auth WHERE checkgroupid='").append(grpid).append("' AND EndpointID='"+endpointID+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("DELETE FROM table_subscriber WHERE checkgroupid='").append(grpid).append("' AND ID='"+endpointID+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;
        
        sql.setLength(0) ;
        sql.append("DELETE FROM table_featureservice WHERE checkgroupid='").append(grpid).append("' AND E164='"+phoneNumber+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        /* Others */
        sql.setLength(0) ;
        sql.append("DELETE FROM table_presence WHERE checkgroupid='").append(grpid).append("' AND EndpointID='"+endpointID+"'");//.append(" AND UserE164='"+phoneNumber+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("DELETE FROM table_presencereport WHERE checkgroupid='").append(grpid).append("' AND UserE164='"+phoneNumber+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;
        
        sql.setLength(0) ;
        sql.append("DELETE FROM Table_E164block WHERE checkgroupid='").append(grpid).append("' AND E164='"+phoneNumber+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;

        sql.setLength(0) ;
        sql.append("DELETE FROM Table_Forward WHERE checkgroupid='").append(grpid).append("' AND E164='"+phoneNumber+"'") ;
        System.out.println(sql.toString()) ;
        count += dao.delete(stmt, sql.toString()) ;


        nPlus++;
    }//while
    if(stmt!=null) stmt.endTransaction(true);
    
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
    	jsArray.delete(0, jsArray.length()) ;
    	jsArray.append("[{params:").append("[\""+grpid+"\",\"\"]}");
        jsArray.append("]");
%>
    <script>
    	alert("<%=grpid%> 가 삭제되었습니다.");
        parent.goNumDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
        //parent.location.href="./subsList.jsp";
    </script>
<%
    }else{
%>
    <script>
        alert("해제 중 오류가 발생하였습니다.");
        parent.hiddenAdCodeDiv();
    </script>
<%
    }
} catch (Exception e) {
    //e.printStackTrace();
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
        parent.goNumDeleteDone(<%=jsArray.toString()%>);
        parent.hiddenAdCodeDiv();
    </script>
<%
	}
} finally {
    //할당받은 DataStatement 객체는 반납
    if (stmt != null ) ConnectionManager.freeStatement(stmt);
}	
%>